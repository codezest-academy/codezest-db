/**
 * @codezest/db - Logger
 *
 * Production-ready logger using Winston
 */

import winston from 'winston';

const logLevel = process.env.LOG_LEVEL || 'info';
const nodeEnv = process.env.NODE_ENV || 'development';

export const logger = winston.createLogger({
  level: logLevel,
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
  ),
  defaultMeta: { service: 'codezest-db' },
  transports: [
    new winston.transports.Console({
      format:
        nodeEnv === 'development'
          ? winston.format.combine(
              winston.format.colorize(),
              winston.format.printf(({ level, message, timestamp, ...metadata }) => {
                let msg = `${timestamp} [${level}]: ${message}`;
                if (Object.keys(metadata).length > 0) {
                  msg += ` ${JSON.stringify(metadata)}`;
                }
                return msg;
              })
            )
          : winston.format.json(),
    }),
  ],
});

// Silent in test environment
if (process.env.NODE_ENV === 'test') {
  logger.silent = true;
}
