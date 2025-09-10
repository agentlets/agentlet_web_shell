import { OpenAI } from 'openai';
import OpenAIChatResponse from './OpenAIChatResponse.js';
import OpenAiChatError from './OpenAiChatError.js';

class OpenAIChatClient {
  constructor(config) {
    this.apiKey = config.apiKey;
    this.model = config.model;
    this.toolChoice = config.toolChoice || 'auto';
    this.temperature = config.temperature;
    // Este modelo no admite temperature, por lo que no lo configuramos
    this.maxTokens = config.maxTokens || 1000;
    this.logger = config.logger; 
    this.client = new OpenAI({
       apiKey: this.apiKey
       //baseURL: 'https://485e6ce3fc0d4af5888d99e3d1f35d1d.api.mockbin.io/'
       });
  }

  /**
   * Enviar un mensaje al modelo y obtener una respuesta estructurada.
   * @param {string|Array} messages - Array de mensajes.
   * @param {Array} functions - Array de funciones para herramientas.
   * @returns {Promise<OpenAIChatResponse>}
   */
  async sendMessage(messages, functions = []) {
    const requestBody = this._buildRequestBody(messages, functions);
    this._logRequest(requestBody);

    const startTime = Date.now();

    try {
      const response = await this.client.responses.create(requestBody);      
      this._logResponse(response);

      const responseTimeMs = Date.now() - startTime;
      const content = this._extractContent(response);
      const usageStats = this._extractUsageStats(response);
      const webSearchCalls = this._countWebSearchCalls(response);

      return new OpenAIChatResponse({
        content,
        ...usageStats,
        webSearchCalls,
        responseTimeMs,
      });
    } catch (error) {
      throw new OpenAiChatError('Error al comunicarse con OpenAI', {
        statusCode: error.response?.status,
        details: error.response?.data || error.message,
      });
    }
  }

  /**
   * Construye el cuerpo de la solicitud para enviar al modelo.
   * @param {Array} messages - Array de mensajes.
   * @param {Array} functions - Array de funciones para herramientas.
   * @returns {Object} Cuerpo de la solicitud con los parámetros configurados.
   */
  _buildRequestBody(messages, functions) {
    return {
      model: this.model,
      input: messages,
      tools: functions.map(fn => ({ type: 'function', ...fn })),
      tool_choice: functions.length > 0 ? this.toolChoice : 'auto',
      max_output_tokens: this.maxTokens,
      temperature: this.temperature,
      parallel_tool_calls: false,
      service_tier: 'default'
    };
  }

  /**
   * Registra los detalles de la solicitud si hay un logger disponible.
   * @param {Object} requestBody
   */
  _logRequest(requestBody) {
    if (this.logger) {
      this.logger.info(`Enviando solicitud al modelo ${this.model}`);
      this.logger.debug(`RequestBody: ${JSON.stringify(requestBody, null, 2)}`);
    }
  }

  /**
   * Registra la respuesta cruda si el nivel de logging es 'debug'.
   * @param {Object} response
   */
  _logResponse(response) {
    if (this.logger?.level === 'debug') {
      this.logger.debug(`Respuesta cruda: ${JSON.stringify(response, null, 2)}`);
    }
  }

  /**
   * Extrae el contenido textual de la respuesta del modelo.
   * @param {Object} response
   * @returns {string} Contenido de texto extraído.
   */
  _extractContent(response) {
    if (typeof response.text === 'string') {
      return response.text;
    } else if (Array.isArray(response.output)) {
      const message = response.output.find(o => o.type === 'message');
      const outputText = message?.content?.find(c => c.type === 'output_text');
      return outputText?.text || '';
    }
    return '';
  }

  /**
   * Extrae estadísticas de uso de tokens de la respuesta.
   * @param {Object} response
   * @returns {Object} Estadísticas de tokens: promptTokens, completionTokens y totalTokens.
   */
  _extractUsageStats(response) {
    const usage = response.usage || {};
    const promptTokens = usage.input_tokens || 0;
    const completionTokens = usage.output_tokens || 0;
    return {
      promptTokens,
      completionTokens,
      totalTokens: promptTokens + completionTokens,
    };
  }

  /**
   * Cuenta cuántas llamadas a búsqueda web se realizaron en la respuesta.
   * @param {Object} response
   * @returns {number} Número de llamadas a búsqueda web.
   */
  _countWebSearchCalls(response) {
    return Array.isArray(response.output)
      ? response.output.filter(item => item.type === 'web_search_call').length
      : 0;
  }
}

export default OpenAIChatClient;
