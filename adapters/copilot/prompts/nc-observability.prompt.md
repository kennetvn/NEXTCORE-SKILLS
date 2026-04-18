---
description: Logging, metrics, tracing, and alerting for production systems. Use when setting up Sentry, OpenTelemetry, Datadog, structured logging, or when debugging production issues with existing telemetry.
mode: agent
---

# Observability

Three pillars: **logs** (what happened), **metrics** (how many/fast), **traces** (where time went).

## Logging

### Structured logs (JSON, not plain text)

```ts
import pino from "pino";
const log = pino({ level: process.env.LOG_LEVEL || "info" });

log.info({ userId: 42, action: "checkout" }, "user completed purchase");
// {"level":30,"userId":42,"action":"checkout","msg":"user completed purchase","time":...}
```

### Log levels

- `fatal` — unrecoverable, process exits
- `error` — handled exception, investigation needed
- `warn` — degraded state, not fatal
- `info` — business events (user signup, order placed)
- `debug` — detail for development
- `trace` — very verbose, disabled in prod

### Never log

- Secrets (API keys, passwords, tokens)
- PII without consent (GDPR — hash email, no credit card)
- Full request/response bodies by default (sample if needed)

## Metrics

### Golden signals (SRE)

1. **Latency** — p50, p95, p99 of request duration
2. **Traffic** — requests per second
3. **Errors** — error rate (5xx / total)
4. **Saturation** — CPU, memory, queue depth

### Prometheus + Grafana

```ts
import { Counter, Histogram } from "prom-client";

const httpRequests = new Counter({
  name: "http_requests_total",
  help: "Total HTTP requests",
  labelNames: ["method", "route", "status"],
});

const httpDuration = new Histogram({
  name: "http_request_duration_seconds",
  labelNames: ["method", "route"],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
});
```

## Tracing (OpenTelemetry)

Distributed trace across services:

```ts
import { trace } from "@opentelemetry/api";

const tracer = trace.getTracer("myapp");

async function checkout(order) {
  const span = tracer.startSpan("checkout");
  try {
    await chargePayment(order);
    await sendEmail(order);
    span.setStatus({ code: 0 });
  } catch (e) {
    span.recordException(e);
    span.setStatus({ code: 2, message: e.message });
    throw e;
  } finally {
    span.end();
  }
}
```

Export to Jaeger, Tempo, Datadog, Honeycomb.

## Error tracking (Sentry)

```ts
import * as Sentry from "@sentry/node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,  // 10% of requests traced
  release: process.env.GIT_SHA,
});

try { /* ... */ } catch (e) {
  Sentry.captureException(e, { tags: { feature: "checkout" } });
  throw e;
}
```

## Alerting

### SLO-based alerts (not threshold-based)

Bad: "CPU > 80%" (fires on normal spikes)  
Good: "error rate > 1% over 5 min" (user-facing symptom)

### Alert fatigue

- Every alert should be actionable (page someone)
- If alert fires > 5x/week without action → tune or delete
- Use notification channels: page (critical), slack (warning), email (info)

## NextCore integration

For `example-homestay.com`:

```ts
// src/lib/logger.ts
import pino from "pino";
export const log = pino({
  level: process.env.LOG_LEVEL || "info",
  transport: process.env.NODE_ENV === "development"
    ? { target: "pino-pretty" }
    : undefined,
});

// src/app/api/vip/route.ts
log.info({ userId, amount }, "vip subscription created");
```

## Anti-patterns

- `console.log` in production (no structured, no level filter)
- Logging secrets/PII
- Alerting on everything → alert fatigue
- No error tracking (bugs invisible to team)
- Traces with sample rate 100% → storage cost explodes

## Integration

- `nc-security` — log security events (auth failures, admin actions)
- `nc-env-secrets` — inject DSN/API keys securely
- `nc-queues` — trace job execution across queue boundary
