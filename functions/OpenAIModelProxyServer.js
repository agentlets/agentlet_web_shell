import OpenAIChatClient from './lib/OpenAIChatClient.js';
import OpenAiChatError from './lib/OpenAiChatError.js';
import Logger from './lib/AppWriteLogger.js';


export default async function ({ req, res, log, error }) {
  const traceId = Date.now().toString();
  const logLevel = process.env.LOG_LEVEL || 'info';
  const logger = new Logger(traceId, logLevel, log, error);

  log(`method=${req.method}, path=${req.path}`);
  log('headers:', req.headers);

  // CORS handling and route/method restrictions
  const origin = req.headers?.origin || '';
  const allowedOrigins = ['http://localhost', 'http://localhost:3000', 'https://localhost', 'https://agentlet.org', 'http://agentlet.org'];
  const isAllowedOrigin = allowedOrigins.some(o => origin && origin.startsWith(o));

  // Only allow the route /invoke_llm
  if (req.path !== '/invoke_llm') {
    // For non-matching routes, return 404
    return res.json({ error: 'Not Found' }, 404);
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    const headers = {
      'Access-Control-Allow-Origin': isAllowedOrigin ? origin : 'http://localhost',
      'Vary': 'Origin',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, x-appwrite-user-jwt',
      'Access-Control-Max-Age': '86400'
    };
    return res.send('', 204, headers);
  }

  // Enforce POST for actual invocation
  if (req.method !== 'POST') {
    const headers = {
      'Access-Control-Allow-Origin': isAllowedOrigin ? origin : 'http://localhost',
      'Vary': 'Origin'
    };
    return res.json({ error: 'Method Not Allowed' }, 405, headers);
  }

  // CORS header for successful POST responses will be attached in responses below

  if (req.bodyText) logger.log('bodyText:', req.bodyText);
  try {
    if (req.bodyJson) logger.log('bodyJson:', JSON.stringify(req.bodyJson));
  } finally { }
  if (req.bodyBinary) logger.log('bodyBinary length:', req.bodyBinary.length);

  let userMessages = [];
  let functions = [];

  const body = req.bodyJson || (req.bodyText ? JSON.parse(req.bodyText) : null);

  if (body) {
    if (Array.isArray(body.messages)) {
      userMessages = body.messages;
    }

    if (Array.isArray(body.function_call)) {
      functions = body.function_call;
    }
  }

  if (!Array.isArray(userMessages) || userMessages.length === 0) {
    var message = 'Prompt no proporcionado o vacío.';
    logger.error(message);
    const headers = {
      'Access-Control-Allow-Origin': isAllowedOrigin ? origin : 'http://localhost',
      'Vary': 'Origin'
    };
    return res.json({ error: message }, 400, headers);
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
    const response = await client.sendMessage(userMessages, functions);
    let parsedContent;
    try {
      parsedContent = JSON.parse(response.content);
    } catch (e) {
      logger.error('Error al parsear response.content: ' + e.message);
      parsedContent = { raw: response.content };
    }

    const headers = {
      'Access-Control-Allow-Origin': isAllowedOrigin ? origin : 'http://localhost',
      'Vary': 'Origin'
    };

    return res.json({
      content: parsedContent,
      metrics: {
        promptTokens: response.promptTokens,
        completionTokens: response.completionTokens,
        totalTokens: response.totalTokens,
        webSearchCalls: response.webSearchCalls,
        responseTimeMs: response.responseTimeMs,
      }
    }, 200, headers);
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
    const headers = {
      'Access-Control-Allow-Origin': isAllowedOrigin ? origin : 'http://localhost',
      'Vary': 'Origin'
    };
    return res.json({ error: errorDetails }, errorDetails.statusCode, headers);
  }
};
