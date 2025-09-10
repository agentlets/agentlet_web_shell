const LOG_LEVELS = ['error', 'warn', 'info', 'debug'];

class AbstractLogger {
  constructor(traceId, level = 'info') {
    if (new.target === AbstractLogger) {
      throw new TypeError("Cannot construct AbstractLogger instances directly");
    }
    this.traceId = traceId;
    this.level = level;
  }

  log(level, message) {
    throw new Error("Method 'log()' must be implemented.");
  }

  error(message) {
    this.log('error', message);
  }

  warn(message) {
    this.log('warn', message);
  }

  info(message) {
    this.log('info', message);
  }

  debug(message) {
    this.log('debug', message);
  }
}

module.exports = {
    AbstractLogger,
    LOG_LEVELS
};