---
name: nc:api-contracts
description: "API contract design: OpenAPI, tRPC, GraphQL, gRPC schemas. Use when designing REST API, generating clients from specs, enforcing contracts between frontend/backend, or versioning APIs."
license: MIT
argument-hint: "[openapi|trpc|graphql|grpc]"
---

# API Contracts

## Contract-first development

Define schema → generate types, clients, docs. Single source of truth.

## OpenAPI (REST)

```yaml
openapi: 3.1.0
info: { title: "My API", version: "1.0.0" }
paths:
  /users/{id}:
    get:
      parameters:
        - name: id
          in: path
          required: true
          schema: { type: integer }
      responses:
        "200":
          content:
            application/json:
              schema: { $ref: "#/components/schemas/User" }
        "404":
          content:
            application/json:
              schema: { $ref: "#/components/schemas/Error" }
components:
  schemas:
    User:
      type: object
      required: [id, email]
      properties:
        id: { type: integer }
        email: { type: string, format: email }
```

Tools:
- **Generate clients** — `openapi-generator-cli` (TS, Python, Go, etc.)
- **Mock server** — Prism, json-server
- **Validation** — `@apidevtools/swagger-parser`, express-openapi-validator

## tRPC (TypeScript end-to-end)

No schema file — types flow from server to client via inference:

```ts
// server
export const appRouter = router({
  user: router({
    byId: publicProcedure
      .input(z.object({ id: z.number() }))
      .query(async ({ input }) => {
        return await db.user.findUnique({ where: { id: input.id } });
      }),
  }),
});
export type AppRouter = typeof appRouter;

// client — type-safe, auto-completion
const user = await trpc.user.byId.query({ id: 42 });
// ^ typed as User | null
```

Best when: Full TypeScript stack, monorepo, rapid iteration.

## GraphQL

Strong schema, flexible queries:

```graphql
type User {
  id: ID!
  email: String!
  orders(limit: Int = 10): [Order!]!
}

type Query {
  user(id: ID!): User
}

type Mutation {
  createUser(input: CreateUserInput!): User!
}
```

Best when: Multiple clients with different data needs (mobile + web + partner).

## gRPC (performance, polyglot)

```proto
syntax = "proto3";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc StreamUsers(StreamRequest) returns (stream User);
}

message User {
  int64 id = 1;
  string email = 2;
  google.protobuf.Timestamp created_at = 3;
}
```

Best when: Internal microservices, streaming, polyglot (Go + Node + Python).

## Versioning

### URL-based

```
/api/v1/users
/api/v2/users  (breaking change)
```

Simple, clear. Preferred for public APIs.

### Header-based

```
Accept: application/vnd.myapp.v2+json
```

More "RESTful" but harder to test/debug.

### Deprecation workflow

1. Release v2 alongside v1
2. Add `Deprecation: true` + `Sunset: 2027-01-01` headers to v1
3. Notify consumers (docs, email, dashboard)
4. Monitor v1 usage
5. When v1 usage < threshold, remove

## Error format (consistent)

```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with id 42 not found",
    "details": { "id": 42 },
    "requestId": "req_abc123"
  }
}
```

Include `requestId` for support correlation.

## Idempotency

Mutation endpoints should accept `Idempotency-Key: <uuid>` header — retry-safe:

```ts
async function createOrder(data, idempotencyKey) {
  const existing = await db.order.findUnique({ where: { idempotencyKey } });
  if (existing) return existing;
  return db.order.create({ data: { ...data, idempotencyKey } });
}
```

## Anti-patterns

- Breaking changes in existing endpoint (always version)
- No pagination on list endpoints (OOM risk)
- Different error shapes per endpoint
- Stringly-typed fields (use enums)
- Exposing internal IDs as-is (use opaque IDs for public API)

## Integration

- `nc-auth-patterns` — authenticate API requests
- `nc-caching` — HTTP cache headers based on contract
- `nc-observability` — log requestId for tracing
