---
name: nc:go-backend
description: "Go backend development: HTTP servers, routing, database, goroutines. Use when building Go APIs/microservices, evaluating Go vs Node, or writing performance-critical backend services."
license: MIT
argument-hint: "[http|chi|gin|db|concurrency]"
---

# Go Backend

## When Go

- High concurrency (goroutines scale easily)
- Low latency / high throughput
- Single binary deploy (no runtime needed)
- Team comfortable with static typing, pointer semantics

## HTTP server (stdlib)

```go
package main

import (
    "encoding/json"
    "net/http"
)

type User struct {
    ID    int    `json:"id"`
    Email string `json:"email"`
}

func main() {
    http.HandleFunc("/users/", handleUser)
    http.ListenAndServe(":8080", nil)
}

func handleUser(w http.ResponseWriter, r *http.Request) {
    u := User{ID: 1, Email: "test@example.com"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(u)
}
```

## Frameworks

### Chi (lightweight router)

```go
import "github.com/go-chi/chi/v5"

r := chi.NewRouter()
r.Use(middleware.Logger)
r.Get("/users/{id}", getUserHandler)
http.ListenAndServe(":8080", r)
```

### Gin (high-perf, feature-rich)

```go
r := gin.Default()
r.GET("/users/:id", func(c *gin.Context) {
    c.JSON(200, User{ID: 1, Email: "..."})
})
r.Run(":8080")
```

### Fiber (Express-like)

```go
app := fiber.New()
app.Get("/users/:id", func(c *fiber.Ctx) error {
    return c.JSON(User{})
})
app.Listen(":8080")
```

## Database

### sqlx (recommended, simple)

```go
import "github.com/jmoiron/sqlx"

db, err := sqlx.Connect("postgres", connStr)

var user User
err = db.Get(&user, "SELECT * FROM users WHERE id=$1", 42)

users := []User{}
err = db.Select(&users, "SELECT * FROM users WHERE active=true")
```

### sqlc (codegen from SQL)

Write SQL → generate type-safe Go:

```sql
-- query.sql
-- name: GetUser :one
SELECT * FROM users WHERE id = $1;
```

```bash
sqlc generate  # produces typed Go functions
```

## Concurrency

```go
// Goroutines
go processOrder(order)  // fire-and-forget

// WaitGroup (wait for all)
var wg sync.WaitGroup
for _, u := range users {
    wg.Add(1)
    go func(u User) {
        defer wg.Done()
        processUser(u)
    }(u)
}
wg.Wait()

// Channels (communicate)
results := make(chan Result, 10)
go func() {
    results <- compute()
}()
r := <-results

// Context (cancellation)
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
result, err := longRunningOp(ctx)
```

## Error handling

Explicit `if err != nil` — no exceptions. Wrap errors with context:

```go
result, err := doWork()
if err != nil {
    return fmt.Errorf("doing work: %w", err)
}
```

## Project layout (standard)

```
cmd/server/main.go      # entry point
internal/               # not importable outside
  api/                  # HTTP handlers
  db/                   # database
  service/              # business logic
pkg/                    # importable by others
go.mod
```

## Testing

```go
func TestGetUser(t *testing.T) {
    u := User{ID: 1, Email: "test@example.com"}
    if u.ID != 1 {
        t.Errorf("expected ID=1, got %d", u.ID)
    }
}
```

Run: `go test ./...`

Table-driven tests:

```go
tests := []struct {
    name string
    in   int
    want string
}{
    {"zero", 0, "zero"},
    {"one", 1, "one"},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        if got := toName(tt.in); got != tt.want {
            t.Errorf("got %s, want %s", got, tt.want)
        }
    })
}
```

## Deploy

```dockerfile
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o server ./cmd/server

FROM scratch
COPY --from=builder /app/server /
EXPOSE 8080
ENTRYPOINT ["/server"]
```

Final image: <20MB. Single binary = easy rollback.

## Anti-patterns

- `panic()` for expected errors (use `error` return)
- Unbounded goroutines (OOM at scale)
- Sharing memory between goroutines without sync (data race)
- Ignoring `context.Context` in long operations (no cancellation)
- Over-engineering interfaces before they're needed

## Integration

- `nc-api-contracts` — protobuf + grpc-go for typed RPC
- `nc-databases` — sqlc for type-safe Postgres
- `nc-observability` — OpenTelemetry Go SDK
