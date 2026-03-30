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

## Logger Comparison

| Feature | Pino | Winston | Bunyan | console.* |
|---------|------|---------|--------|-----------|
| Structured JSON | Yes | Yes | Yes | No |
| Performance | Fastest | Slower | Medium | N/A |
| Log levels | Yes | Yes | Yes | Limited |
| Child loggers | Yes | Yes | Yes | No |
| Bundle size | ~30KB | ~200KB | ~50KB | 0 |

The hook is **library-agnostic** — it checks for `logger.X(...)` calls and string concatenation patterns. Any logger that uses `logger.error({...})` syntax will work.

## Complementary Tools

Structured logging and error tracking are different concerns:

| Concern | What it does | Examples |
|---------|-------------|----------|
| **Structured logger** | Formats log lines as JSON, writes to stdout/transport | Pino, Winston, Bunyan |
| **Log aggregation** | Stores, indexes, and queries log lines | Axiom, Grafana Loki, Datadog, BetterStack |
| **Error tracking** | Captures unhandled exceptions with stack traces and context | Sentry, PostHog, GlitchTip |
| **Feature flags** | Toggle features without deploys | PostHog, Flagsmith, Unleash |

A typical production stack combines one from each category. This skill only enforces the **logging pattern** — pick your own tools for the rest.
