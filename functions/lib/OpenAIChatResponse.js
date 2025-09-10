

class OpenAIChatResponse {
  /**
   * Constructor para crear una respuesta de chat inmutable.
   * @param {Object} params
   * @param {string} params.content - Respuesta del modelo.
   * @param {number} params.promptTokens - Tokens usados en el prompt.
   * @param {number} params.completionTokens - Tokens usados en la respuesta.
   * @param {number} params.totalTokens - Tokens totales usados.
   * @param {number} params.webSearchCalls - Número de llamadas a búsqueda web.
   * @param {number} params.responseTimeMs - Tiempo de inferencia en milisegundos.
   */
  constructor({ content, promptTokens, completionTokens, totalTokens, webSearchCalls, responseTimeMs }) {
    this._content = content;
    this._promptTokens = promptTokens;
    this._completionTokens = completionTokens;
    this._totalTokens = totalTokens;
    this._webSearchCalls = webSearchCalls;
    this._responseTimeMs = responseTimeMs;

    Object.freeze(this);
  }

  /** @returns {string} */
  get content() {
    return this._content;
  }

  /** @returns {number} */
  get promptTokens() {
    return this._promptTokens;
  }

  /** @returns {number} */
  get completionTokens() {
    return this._completionTokens;
  }

  /** @returns {number} */
  get totalTokens() {
    return this._totalTokens;
  }

  /** @returns {number} */
  get webSearchCalls() {
    return this._webSearchCalls;
  }

  /** @returns {number} */
  get responseTimeMs() {
    return this._responseTimeMs;
  }
}

export default OpenAIChatResponse;