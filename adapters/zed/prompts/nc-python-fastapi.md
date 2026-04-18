---
description: Python backend with FastAPI, SQLAlchemy, Pydantic. Use when building Python APIs, ML-adjacent services, async Python, or evaluating FastAPI vs Django/Flask.
---

# Python FastAPI

## When FastAPI

- Python ecosystem required (ML/data science adjacent)
- Need async + high performance
- Want auto-generated OpenAPI docs
- Type-safe request/response via Pydantic

When NOT: CPU-bound heavy (Python GIL limits) — consider Go/Rust.

## Minimal app

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class User(BaseModel):
    id: int
    email: str

@app.get("/users/{user_id}", response_model=User)
async def get_user(user_id: int) -> User:
    return User(id=user_id, email="test@example.com")
```

Run: `uvicorn main:app --reload`

Auto docs: `/docs` (Swagger) and `/redoc`.

## Pydantic models (v2)

```python
from pydantic import BaseModel, EmailStr, Field

class CreateUserRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    name: str | None = None

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    model_config = {"from_attributes": True}  # ORM mode
```

Validation is automatic. Errors return 422 with field-specific details.

## Dependency injection

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session

@app.get("/users/{id}")
async def get_user(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.get(User, id)
    if not result:
        raise HTTPException(404, "Not found")
    return result
```

## SQLAlchemy 2.0 (async)

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase): pass

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str]

engine = create_async_engine("postgresql+asyncpg://user:pass@host/db")
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)

# Query
async with SessionLocal() as session:
    user = await session.get(User, 42)
```

## Alembic migrations

```bash
alembic init alembic
alembic revision --autogenerate -m "add users"
alembic upgrade head
```

## Background tasks

```python
from fastapi import BackgroundTasks

def send_email(email: str):
    # sync code, runs after response sent
    pass

@app.post("/signup")
async def signup(req: CreateUserRequest, tasks: BackgroundTasks):
    user = await create_user(req)
    tasks.add_task(send_email, req.email)
    return user
```

For heavy jobs: use **Celery** or **Dramatiq** with Redis.

## Middleware + CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://example.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Testing

```python
from fastapi.testclient import TestClient

client = TestClient(app)

def test_get_user():
    r = client.get("/users/1")
    assert r.status_code == 200
    assert r.json()["id"] == 1
```

## Deploy

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

Production: `uvicorn` with `gunicorn` workers for multi-process:
```bash
gunicorn main:app -k uvicorn.workers.UvicornWorker -w 4
```

## Anti-patterns

- Sync code in async endpoint (blocks event loop)
- Using `SQLAlchemy` sync API with `async` FastAPI (use async API)
- No Pydantic validation (Python type hints alone don't validate at runtime)
- Monolithic `main.py` (split into routers per domain)
- Missing `response_model` (loses auto docs + validation)

## Integration

- `nc-api-contracts` — FastAPI auto-generates OpenAPI at `/openapi.json`
- `nc-observability` — OpenTelemetry instrumentation + Sentry
- `nc-databases` — SQLAlchemy 2.0 async + Alembic
