---
name: nc:queues
description: "Background job queues: BullMQ, Redis, RabbitMQ, AWS SQS. Use for async work (emails, image processing, webhooks, scheduled jobs) or decoupling services via message passing."
license: MIT
argument-hint: "[bullmq|rabbitmq|sqs|pattern]"
---

# Job Queues

## When to queue

Queue work when:
- User request shouldn't wait (email sends, thumbnail generation)
- Work may fail/retry (webhook calls, external API)
- Work is expensive (PDF export, video transcoding)
- Work is scheduled (daily reports, cleanup jobs)

**Don't queue** sync-critical work the user waits for.

## BullMQ (Redis-backed, Node.js)

```ts
import { Queue, Worker } from "bullmq";

const queue = new Queue("emails", { connection: redis });

// Enqueue
await queue.add("welcome", { userId: 42, template: "welcome" }, {
  attempts: 3,
  backoff: { type: "exponential", delay: 1000 },
  removeOnComplete: 100,  // keep last 100
  removeOnFail: 1000,
});

// Worker
new Worker("emails", async (job) => {
  const { userId, template } = job.data;
  await sendEmail(userId, template);
}, { connection: redis, concurrency: 5 });
```

## Delayed + scheduled jobs

```ts
// Delayed
await queue.add("reminder", { orderId }, { delay: 1000 * 60 * 60 });  // 1 hour

// Recurring (cron)
await queue.add("cleanup", {}, {
  repeat: { pattern: "0 2 * * *" }  // daily at 2am
});
```

## Failure handling

### Exponential backoff

Retry 1 → 1s, retry 2 → 2s, retry 3 → 4s, retry N → 2^N seconds

### Dead letter queue

After max retries, move to DLQ for manual inspection:

```ts
new Worker("emails", async (job) => { /* ... */ }, {
  connection: redis,
});

queue.on("failed", async (job, err) => {
  if (job.attemptsMade >= job.opts.attempts) {
    await dlq.add("failed-email", { job: job.toJSON(), error: err.message });
  }
});
```

### Idempotency

Jobs can retry — make handlers idempotent:

```ts
async function sendEmail({ userId, messageId }) {
  const sent = await db.emailLog.findUnique({ where: { messageId } });
  if (sent) return;  // already processed
  await mailer.send(...);
  await db.emailLog.create({ data: { messageId, userId } });
}
```

## NextCore job system pattern

Following the `<website-project>/example-homestay.com/src/lib/jobs/` convention:

```ts
// definitions/cleanup-expired-vip.ts
import { defineJob } from "../registry";

export default defineJob({
  name: "cleanup-expired-vip",
  schedule: "0 3 * * *",  // 3am daily
  description: "Mark PENDING VIP orders >24h as CANCELLED",
  async handler() {
    const cutoff = new Date(Date.now() - 24 * 3600 * 1000);
    const result = await db.vipOrder.updateMany({
      where: { status: "PENDING_PAYMENT", createdAt: { lt: cutoff } },
      data: { status: "CANCELLED" },
    });
    return { cancelled: result.count };
  },
});
```

Registry auto-discovers + DB mutex prevents PM2 cluster duplicate execution.

## Priorities

```ts
await queue.add("urgent", data, { priority: 1 });  // high
await queue.add("normal", data, { priority: 10 });
await queue.add("background", data, { priority: 100 });  // low
```

## Monitoring

- **Queue depth** — alert if > threshold (workers falling behind)
- **Failure rate** — alert if > 5%
- **Processing time** — p95 should be stable
- **DLQ count** — should be zero; any entry = investigation needed

## Anti-patterns

- Long-running jobs in web process (blocks requests)
- No idempotency on retry-able jobs
- Synchronous DB writes in job worker without transaction
- No monitoring (silent failures)
- Running jobs in-process when you have multiple web instances (race conditions)

## Alternatives by scale

| Scale | Tool |
|---|---|
| Small (< 1k jobs/day) | BullMQ + Redis |
| Medium (< 100k/day) | BullMQ + Redis cluster, or pg-boss (Postgres-backed) |
| Large (> 100k/day) | RabbitMQ, Kafka, AWS SQS |
| Realtime push | Kafka, NATS |

## Integration

- `nc-caching` — Redis serves both cache + queue (share connection, separate DB)
- `nc-observability` — track queue metrics
- `nc-websockets` — job completion → broadcast to subscribed clients
