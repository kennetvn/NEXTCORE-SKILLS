---
description: Microservice architecture: service boundaries, communication patterns, saga/outbox, service mesh. Use when designing distributed systems, breaking up a monolith, or integrating multiple services.
auto_execution_mode: 1
---

# Microservices

## When NOT to use microservices

- Team < 10 engineers
- Product still finding fit (architecture churn)
- No existing DevOps maturity
- Single deployable solves the problem (monolith is fine)

Start monolith. Extract services when pain justifies overhead.

## Service boundary design

### By domain (DDD bounded context)

User domain, Order domain, Payment domain, Inventory domain.

Each service owns its data. No cross-service DB joins — all communication via API.

### Ownership rules

- One team owns 1-3 services (not shared)
- Service has clear contract (OpenAPI / gRPC)
- Service can deploy independently
- Service can scale independently

## Communication patterns

### Synchronous (HTTP/gRPC)

```
Client → Order Service → User Service (validate user) → Payment Service (charge)
                  ↓
                Database
```

Pros: simple, strong consistency  
Cons: cascading failures, latency adds up, tight coupling

### Asynchronous (events)

```
Order Service → [OrderCreated event] → Queue/Bus
                                        ├→ Email Service (send confirmation)
                                        ├→ Inventory Service (reserve)
                                        └→ Analytics Service (log)
```

Pros: loose coupling, resilient  
Cons: eventual consistency, harder to trace

### Recommendation

- Sync for request/response where caller needs answer
- Async (events) for notifications, side effects, decoupling

## Saga pattern (distributed transaction)

Example: Place Order = reserve inventory + charge payment + create order.

No 2PC — use compensating actions:

```
1. Reserve inventory (can undo: release)
2. Charge payment (can undo: refund)
3. Create order (can undo: cancel)

If step N fails, run compensations for 1..N-1 in reverse.
```

Orchestrator (central coordinator) or Choreography (each service emits events, others react) — choose per domain.

## Outbox pattern

Problem: "Save order AND publish OrderCreated event" — no distributed transaction.

Solution:

```
1. In same DB transaction:
   - Insert order into orders table
   - Insert event into outbox table
2. Separate worker polls outbox → publishes to message bus → marks sent
```

Guaranteed: event published if and only if order saved.

## Service mesh (Istio, Linkerd)

For: > 10 services, need traffic management, mTLS, fine-grained observability.

Features:
- **mTLS** between services
- **Circuit breaker** — stop calling failing service
- **Retry + backoff** — automatic
- **Canary routing** — 5% traffic to v2
- **Distributed tracing** — automatic span propagation

If < 10 services: overkill. Use lightweight patterns (client-side circuit breakers).

## API gateway

Single entry point for external clients:

```
Client → API Gateway → { User, Order, Payment services }
                       ↑
                       auth, rate limit, caching, logging
```

Tools: Kong, AWS API Gateway, Cloudflare Workers, Traefik.

## Data ownership

**Rule:** one service owns a table. Other services read via API, never direct DB.

### Data duplication is OK

User Service owns `users`. Order Service cache `userId + userName` per order — denormalized intentionally for query efficiency.

Staleness handled via events: `UserUpdated` → update cache.

## Service discovery

- **DNS** — simple: `http://user-service.internal`
- **Service registry** — Consul, etcd (for dynamic hosts)
- **Kubernetes Services** — native in k8s

## Distributed debugging

- **Trace ID** propagated via `traceparent` header
- **OpenTelemetry** instrumentation per service
- **Central log aggregation** — ELK, Datadog, Grafana Loki

Without this, debugging a cross-service bug is a nightmare.

## Anti-patterns

- Shared DB across services (distributed monolith, worst of both worlds)
- Sync calls in long chains (5-hop latency)
- No distributed tracing (can't debug prod)
- Fine-grained services (nano-services overhead > monolith pain)
- Premature extraction (extract when pain justifies)

## Integration

- `nc-api-contracts` — OpenAPI / gRPC schemas per service
- `nc-observability` — distributed tracing across services
- `nc-queues` — event bus for async communication
