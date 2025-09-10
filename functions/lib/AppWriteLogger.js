import { AbstractLogger, LOG_LEVELS } from './AbstractLogger';

class AppWriteLogger extends AbstractLogger {
     constructor(traceId, level = 'info', stdOut, stdErr) {
        super(traceId, level);
        this.stdOut = stdOut;
        this.stdErr = stdErr;
      }

  log(level, message) {
    const levelIndex = LOG_LEVELS.indexOf(level);
    const currentLevelIndex = LOG_LEVELS.indexOf(this.level);

    if (levelIndex <= currentLevelIndex) {
      const timestamp = new Date().toISOString();
      const entry = `[${timestamp}] [${level.toUpperCase()}] [traceId=${this.traceId}] ${message}`;
      switch (level) {
        case 'error':
          this.stdErr(entry);
          break;
        default:
          this.stdOut(entry);
      }
    }
  }
}

export default AppWriteLogger;