
class OpenAiChatError extends Error {
  /**
   * Error personalizado para errores de interacción con OpenAI API.
   * @param {string} message - Mensaje de error.
   * @param {Object} [options] - Opciones adicionales.
   * @param {number} [options.statusCode] - Código de estado HTTP, si aplica.
   * @param {any} [options.details] - Información extra para depuración.
   */
  constructor(message, { statusCode, details } = {}) {
    super(message);
    this.name = 'OpenAiChatError';
    this.statusCode = statusCode || null;
    this.details = details || null;

    // Mantener el stack trace limpio si está disponible
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, OpenAiChatError);
    }

    // Hacer la instancia inmutable
    Object.freeze(this);
  }
}

export default OpenAiChatError;