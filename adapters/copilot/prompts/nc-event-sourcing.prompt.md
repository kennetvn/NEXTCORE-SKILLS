---
description: Event sourcing + CQRS patterns. Use for audit-heavy domains (finance, healthcare), when you need full history replay, time-travel debugging, or complex domain models.
mode: agent
---

# Event Sourcing & CQRS

## Core idea

State = reduce(events). Don't store current state — store append-only event log. Derive state by replaying events.

## Example: Order domain

Traditional:

```
UPDATE orders SET status = 'SHIPPED' WHERE id = 42;
-- Previous state lost
```

Event-sourced:

```
INSERT INTO events (stream_id, type, payload, version) VALUES
  (42, 'OrderCreated', {...}, 1),
  (42, 'PaymentReceived', {...}, 2),
  (42, 'Shipped', {tracking: 'XYZ'}, 3);

-- Current state: fold(events for stream 42)
```

## When to use

Good fit:
- **Finance / accounting** — audit trail mandatory
- **E-commerce orders** — show "what happened when"
- **Collaborative editing** — replay other users' changes
- **Versioned configuration** — deployment history
- **Compliance-heavy** (HIPAA, SOC 2)

Bad fit:
- Simple CRUD app
- Real-time low-latency (projection rebuild is slow)
- Small team without event discipline

## CQRS: Command vs Query side

```
Write side (commands):
  POST /orders/42/ship → validate → emit ShippedEvent → append to event store

Read side (queries):
  GET /orders/42 → read from projection table (denormalized, optimized)
```

Separate models. Write side optimizes for business logic. Read side optimizes for queries.

## Event schema

```ts
type Event = {
  streamId: string;       // "order-42"
  version: number;        // monotonic within stream
  type: string;           // "OrderCreated"
  payload: Record<string, unknown>;
  metadata: {
    userId: string;
    timestamp: Date;
    correlationId: string;
  };
};
```

Event table:

```sql
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  stream_id TEXT NOT NULL,
  version INT NOT NULL,
  type TEXT NOT NULL,
  payload JSONB NOT NULL,
  metadata JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (stream_id, version)  -- optimistic concurrency
);
CREATE INDEX ON events (stream_id, version);
```

## Rebuilding state

```ts
async function getOrder(id: number): Promise<Order> {
  const events = await db.event.findMany({
    where: { streamId: `order-${id}` },
    orderBy: { version: "asc" },
  });
  return events.reduce(applyEvent, { id, status: "pending", items: [] });
}

function applyEvent(order: Order, event: Event): Order {
  switch (event.type) {
    case "OrderCreated": return { ...order, ...event.payload };
    case "PaymentReceived": return { ...order, paidAt: event.metadata.timestamp };
    case "Shipped": return { ...order, status: "shipped", tracking: event.payload.tracking };
    default: return order;
  }
}
```

## Snapshots (performance)

Problem: replaying 10,000 events per query is slow.

Solution: periodic snapshots:

```ts
// Every 100 events, store snapshot
if (order.version % 100 === 0) {
  await db.snapshot.create({
    data: { streamId, version: order.version, state: order }
  });
}

// On read: load snapshot, apply events since snapshot.version
const snapshot = await db.snapshot.findFirst({
  where: { streamId },
  orderBy: { version: "desc" },
});
const events = await db.event.findMany({
  where: { streamId, version: { gt: snapshot.version } },
});
const order = events.reduce(applyEvent, snapshot.state);
```

## Projections (read models)

Maintain denormalized tables for fast queries:

```ts
// On new event, update projection
async function projectOrderEvent(event: Event) {
  switch (event.type) {
    case "OrderCreated":
      await db.orderReadModel.create({ data: { ...event.payload } });
      break;
    case "Shipped":
      await db.orderReadModel.update({
        where: { id: event.streamId },
        data: { status: "shipped" }
      });
      break;
  }
}
```

Queries hit `orderReadModel`, not event stream.

## Event versioning

Events are immutable. If schema evolves:

1. **Upcasters** — transform old events to new format on read
2. **Versioned event types** — `OrderCreatedV2` alongside `OrderCreatedV1`
3. **Never delete or edit** past events (breaks audit)

## Libraries

- **EventStoreDB** — purpose-built event store
- **Marten** (.NET) — Postgres-backed event sourcing
- **Axon** (Java) — full CQRS framework
- **Equinox** (F#/.NET) — functional event sourcing
- **Custom with Postgres JSONB** — simplest, works for most cases

## Anti-patterns

- Event sourcing "everything" (overkill for simple domains)
- Editing past events (breaks history, defeats purpose)
- No snapshots with large streams (slow reads)
- Projections + event store in separate DB (eventual consistency nightmare)
- Storing full state in each event (not events, snapshots with extra steps)

## Integration

- `nc-queues` — async projection update after event append
- `nc-observability` — metric: event lag (write → projection update time)
- `nc-databases` — Postgres JSONB for event payload storage
