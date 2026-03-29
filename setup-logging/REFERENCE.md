# Structured Logging Reference

## logging-check.sh

PostToolUse hook that enforces structured logging patterns on every Edit/Write.

> Script: [`scripts/logging-check.sh`](scripts/logging-check.sh)

## Logger Configuration (Pino)

### src/lib/logger.ts

```typescript
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL ?? "info",
  ...(process.env.NODE_ENV === "development" && {
    transport: {
      target: "pino-pretty",
      options: {
        colorize: true,
        translateTime: "HH:MM:ss",
        ignore: "pid,hostname",
      },
    },
  }),
});
```

### Usage Examples

```typescript
import { logger } from "@/lib/logger";

// Basic structured logging
logger.info({ message: "Server started", port: 3000 });

// Error logging with context
logger.error({ message: "Request failed", error: err, requestId, path: "/api/users" });

// Child loggers for module context
const authLogger = logger.child({ module: "auth" });
authLogger.warn({ message: "Rate limit approaching", userId, remaining: 5 });

// Different levels
logger.debug({ message: "Cache miss", key: cacheKey });
logger.fatal({ message: "Database connection lost", host: dbHost });
```

### Output

Development (pino-pretty):
```
14:23:01 INFO: Server started { port: 3000 }
14:23:02 ERROR: Request failed { requestId: "abc-123", path: "/api/users" }
```

Production (JSON):
```json
{"level":30,"time":1234567890,"message":"Server started","port":3000}
{"level":50,"time":1234567891,"message":"Request failed","requestId":"abc-123","path":"/api/users","error":{"message":"Connection refused","stack":"..."}}
```

## Why Pino

| Feature | Pino | Winston | console.* |
|---------|------|---------|-----------|
| Structured JSON | Yes | Yes | No |
| Performance | Fastest (low overhead) | Slower | N/A |
| Log levels | Yes | Yes | Limited |
| Child loggers | Yes | Yes | No |
| Bundle size | ~30KB | ~200KB | 0 |
| Browser support | Via pino-pretty | No | Yes |

## Hook Configuration

`.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/hooks/logging-check.sh"
      }
    ]
  }
}
```
