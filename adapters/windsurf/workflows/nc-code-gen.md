---
description: Code generation from specs: OpenAPI → TS client, Prisma → types, GraphQL → types, protobuf → services. Use when you have a schema and want type-safe generated code.
auto_execution_mode: 1
---

# Code Generation

Generate boilerplate + ensure compile-time safety between layers.

## OpenAPI → TypeScript client

```bash
npx openapi-typescript https://api.example.com/openapi.json -o src/api-types.ts
# Types only, no runtime

# OR for runtime client + types:
npx @openapitools/openapi-generator-cli generate \
  -i ./openapi.yaml -g typescript-fetch -o src/api
```

```ts
import { UsersApi, Configuration } from "./api";
const api = new UsersApi(new Configuration({ basePath: "https://api.example.com" }));
const user = await api.getUser({ id: 42 });  // typed
```

## Prisma → TS types

```bash
npx prisma generate
# Reads schema.prisma, outputs @prisma/client with full type safety
```

```ts
import { PrismaClient, User, Order } from "@prisma/client";
const prisma = new PrismaClient();

const users: User[] = await prisma.user.findMany();
// ^ type-safe, autocomplete on fields
```

## GraphQL → TS types (codegen)

```bash
npx graphql-codegen
```

Config:

```yaml
# codegen.yml
schema: http://localhost:4000/graphql
documents: 'src/**/*.graphql'
generates:
  src/gql/:
    preset: client
    plugins: []
```

```ts
import { graphql } from "./gql";
const USER_QUERY = graphql(`query GetUser($id: ID!) { user(id: $id) { email } }`);
const { data } = useQuery(USER_QUERY, { variables: { id: "1" } });
// data.user.email — typed
```

## Protobuf → gRPC service

```bash
protoc --plugin=./node_modules/.bin/protoc-gen-ts_proto \
  --ts_proto_out=./gen \
  --ts_proto_opt=outputServices=grpc-js \
  ./proto/service.proto
```

## Prisma → Zod schemas (validation)

```bash
npx prisma-zod-generator
```

Generates Zod schemas matching Prisma models — useful for API input validation.

## Orval (OpenAPI → React Query hooks)

```bash
npx orval --config orval.config.ts
```

```ts
// Auto-generated hooks
const { data: user } = useGetUser({ id: 42 });
const { mutate } = useCreateUser();
```

## Custom codegen patterns

### TypeScript Compiler API

```ts
import * as ts from "typescript";

// Parse source file, modify AST, emit new code
const source = ts.createSourceFile("x.ts", code, ts.ScriptTarget.Latest);
const transformer = context => node => ts.visitEachChild(node, ...);
const result = ts.transform(source, [transformer]);
```

### String templates (simple)

```ts
const model = { name: "User", fields: [...] };
const code = `
export interface ${model.name} {
${model.fields.map(f => `  ${f.name}: ${f.type};`).join("\n")}
}
`;
fs.writeFileSync(`src/types/${model.name}.ts`, code);
```

## Generate in CI

```yaml
# .github/workflows/codegen.yml
- run: npx openapi-typescript api/openapi.yaml -o src/api-types.ts
- name: Check diff
  run: git diff --exit-code  # fail if generated code drifted
```

## Re-generation workflow

1. Update source schema (openapi.yaml, schema.prisma, etc.)
2. Run generator
3. Check diff — review new types match expectations
4. Commit both schema + generated code
5. Generated files should have header: "DO NOT EDIT — auto-generated"

## Anti-patterns

- Hand-edit generated code (lost on regeneration)
- Generate into git-ignored dir (other devs lack types)
- Generate without CI check (drift between schema + generated)
- Over-generating (tiny schema → 5000 LOC of code)
- Mixing generators (Prisma types + OpenAPI types conflict)

## Integration

- `nc-api-contracts` — schema source (OpenAPI, gRPC)
- `nc-prisma-helper` — Prisma generate workflow
- `nc-ci-cd` — codegen drift check in pipeline
