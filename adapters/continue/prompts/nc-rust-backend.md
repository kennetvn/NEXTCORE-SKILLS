---
description: Rust backend development: Actix, Axum, Tokio, SQLx. Use when building performance-critical services, safety-critical systems, or evaluating Rust vs Go for backend.
---

# Rust Backend

## When Rust

- Performance-critical (highest throughput + lowest latency)
- Memory-safe without GC overhead
- Long-running daemons where reliability matters
- Team has Rust chops (steep learning curve)

When NOT: rapid iteration needed, small team new to Rust (productivity cost).

## Axum (2026 recommended)

Ergonomic, async, Tokio-native:

```rust
use axum::{routing::get, Router, Json};
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct User { id: i32, email: String }

async fn get_user() -> Json<User> {
    Json(User { id: 1, email: "test@example.com".into() })
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/users", get(get_user));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## Extractors (typed params)

```rust
use axum::extract::{Path, Query, State};

async fn get_user(
    Path(id): Path<i32>,
    State(db): State<DbPool>,
) -> Result<Json<User>, AppError> {
    let user = sqlx::query_as!(User, "SELECT * FROM users WHERE id=$1", id)
        .fetch_one(&db).await?;
    Ok(Json(user))
}
```

## Error handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("not found")]
    NotFound,
    #[error("db error: {0}")]
    Db(#[from] sqlx::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let code = match self {
            AppError::NotFound => StatusCode::NOT_FOUND,
            AppError::Db(_) => StatusCode::INTERNAL_SERVER_ERROR,
        };
        (code, self.to_string()).into_response()
    }
}
```

## Database (sqlx)

```rust
// Compile-time checked queries
let user = sqlx::query_as!(
    User,
    "SELECT id, email FROM users WHERE id = $1",
    42
).fetch_one(&pool).await?;
```

Requires `DATABASE_URL` at compile time. Use `sqlx prepare` for offline mode in CI.

## Concurrency (Tokio)

```rust
// Spawn async task
tokio::spawn(async move {
    process_order(order).await;
});

// Parallel futures
let (a, b) = tokio::join!(
    fetch_user(1),
    fetch_user(2)
);

// Channel
let (tx, mut rx) = tokio::sync::mpsc::channel::<Event>(100);
tokio::spawn(async move {
    tx.send(Event::Created).await.unwrap();
});
while let Some(event) = rx.recv().await { /* ... */ }
```

## Ownership rules (critical)

- **Owned** (`String`, `Vec<T>`): one owner at a time; moves on assignment
- **Borrowed** (`&T`, `&mut T`): no owner change; lifetime-bounded
- **Rc/Arc** for shared ownership; `Mutex`/`RwLock` for shared mutation

In async: use `Arc<Mutex<T>>` for state shared between tasks.

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_user() {
        let result = get_user(Path(1)).await;
        assert!(result.is_ok());
    }
}
```

Run: `cargo test`

## Deploy (Docker)

```dockerfile
FROM rust:1.83 AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=builder /app/target/release/myapp /usr/local/bin/
EXPOSE 8080
CMD ["myapp"]
```

Use `cargo-chef` for faster Docker builds (layer cache deps).

## Anti-patterns

- Cloning everywhere to avoid borrow checker (performance loss)
- `unwrap()` in production (crashes)
- Blocking operations in async (`std::thread::sleep` in Tokio)
- Over-using generics early (compile time explodes)
- Not using `cargo clippy` (lints catch issues)

## Integration

- `nc-api-contracts` — tonic for gRPC, OpenAPI via `utoipa` macro
- `nc-observability` — `tracing` + OpenTelemetry
- `nc-databases` — sqlx for Postgres, seaorm for ORM alternative
