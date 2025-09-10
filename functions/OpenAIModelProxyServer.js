import OpenAIChatClient from './lib/OpenAIChatClient';
import OpenAiChatError from './lib/OpenAiChatError';
import Logger from './lib/AppWriteLogger';


export default async function ({ req, res, log, error }) {
  const traceId = Date.now().toString();
  const logLevel = process.env.LOG_LEVEL || 'info';
  const logger = new Logger(traceId, logLevel, log, error);

  log(`method=${req.method}, path=${req.path}`);
  log('headers:', req.headers);

  if (req.bodyText) logger.log('bodyText:', req.bodyText);
  try{
    if (req.bodyJson) logger.log('bodyJson:', JSON.stringify(req.bodyJson));
  } finally {}
  if (req.bodyBinary) logger.log('bodyBinary length:', req.bodyBinary.length);

  let userMessages;

  // Caso 1: llamada directa por subdominio (bodyText contiene el JSON crudo)
  if (req.bodyText) {
    logger.log("bodyText exists!");
    try {
      // Intento parsear por si viene como string JSON
      const parsedBody = JSON.parse(req.bodyText);
      if (Array.isArray(parsedBody)) {
        userMessages = parsedBody;
      } else if (parsedBody && Array.isArray(parsedBody.messages)) {
        userMessages = parsedBody.messages;
      } else {
        userMessages = [{ role: "user", content: req.bodyText }];
      }
    } catch {
      userMessages = [{ role: "user", content: req.bodyText }];
    }
  } else {
    logger.log("bodyText is empty... trying bodyJson...");

    // Caso 2: llamada interna (bodyJson ya está procesado por Appwrite)
    if (req.bodyJson && req.bodyJson.data) {
      try {
        const parsedData = JSON.parse(req.bodyJson.data);
        if (Array.isArray(parsedData)) {
          userMessages = parsedData;
        } else if (parsedData && Array.isArray(parsedData.messages)) {
          userMessages = parsedData.messages;
        } else {
          userMessages = [{ role: "user", content: req.bodyJson.data }];
        }
      } catch {
        userMessages = [{ role: "user", content: req.bodyJson.data }];
      }
    }
  }

  if (!Array.isArray(userMessages) || userMessages.length === 0) {
    var message = 'Prompt no proporcionado o vacío.';
    logger.error(message);
    return res.json({ error: message }, 400);
  }

  const config = {
    apiKey: process.env.OPENAI_API_KEY,
    model: process.env.DEFAULT_MODEL || 'gpt-4o',
    maxTokens: parseInt(process.env.MAX_TOKENS || '1000', 10),
    toolChoice: 'required',
    temperature: parseFloat(process.env.TEMPERATURE || '0.7'),
    logger
  };

  const client = new OpenAIChatClient(config);

  try {
    const response = await client.sendMessage(userMessages);
    let parsedContent;
    try {
      parsedContent = JSON.parse(response.content);
    } catch (e) {
      logger.error('Error al parsear response.content: ' + e.message);
      parsedContent = { raw: response.content };
    }

    return res.json({
      content: parsedContent,
      metrics: {
        promptTokens: response.promptTokens,
        completionTokens: response.completionTokens,
        totalTokens: response.totalTokens,
        webSearchCalls: response.webSearchCalls,
        responseTimeMs: response.responseTimeMs,
      }
    });
  } catch (error) {
    const errorDetails = error instanceof OpenAiChatError ? {
      message: error.message,
      statusCode: error.statusCode,
      details: error.details
    } : {
      message: error.message || 'Error inesperado',
      statusCode: 500,
    };

    logger.error(errorDetails.message);
    return res.json({ error: errorDetails }, errorDetails.statusCode);
  }
};