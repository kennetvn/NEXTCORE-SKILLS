---
name: nc:docker
description: "Containerization patterns with Docker, Compose, multi-stage builds, and production-ready images. Use when creating Dockerfiles, docker-compose.yml, optimizing image size, or setting up dev containers."
license: MIT
argument-hint: "[dockerfile|compose|optimize|dev-container]"
---

# Docker & Containerization

## Principles

- **Minimal base** — alpine > slim > full, when runtime supports it
- **Multi-stage builds** — separate build deps from runtime
- **Layer caching** — copy lockfiles before source; order COPY by change frequency
- **No root user** in production
- **Health checks** mandatory for long-running services
- **Secrets** via env + docker-compose `secrets:` or orchestrator; never bake into image

## Dockerfile templates

### Node.js (Next.js/Express)

```dockerfile
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app
RUN addgroup -g 1001 app && adduser -u 1001 -G app -s /bin/sh -D app
USER app
COPY --from=builder --chown=app:app /app/.next/standalone ./
COPY --from=builder --chown=app:app /app/.next/static ./.next/static
COPY --from=builder --chown=app:app /app/public ./public
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget --spider -q http://localhost:3000/api/health || exit 1
CMD ["node", "server.js"]
```

### Python (FastAPI/Django)

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
RUN useradd -m -u 1001 app
COPY --from=builder --chown=app /root/.local /home/app/.local
COPY --chown=app . .
USER app
ENV PATH=/home/app/.local/bin:$PATH
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## docker-compose.yml patterns

### Dev stack (app + db + redis)

```yaml
services:
  app:
    build: .
    ports: ["3000:3000"]
    environment:
      DATABASE_URL: postgres://postgres:pass@db:5432/app
      REDIS_URL: redis://redis:6379
    depends_on:
      db: { condition: service_healthy }
      redis: { condition: service_started }
    volumes:
      - .:/app
      - /app/node_modules
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: pass
    healthcheck:
      test: pg_isready -U postgres
      interval: 5s
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
volumes:
  redis_data:
```

## Image optimization

- **Layer order** — least-changing first (package.json before src/)
- **.dockerignore** — exclude node_modules, .git, tests, docs
- **Squash** — `--squash` flag in buildkit for fewer layers
- **Distroless** — `gcr.io/distroless/nodejs22-debian12` for smallest runtime
- **Size target** — Node < 200MB, Python < 150MB, Go < 50MB

## Common mistakes

- `COPY . .` before install → cache busted on every source change
- Running as root → security hole, breaks non-root volume mounts
- No health check → orchestrator can't detect zombie
- Secrets in `ENV` or `LABEL` → leaked in image history

## Dev containers (.devcontainer/)

For consistent dev environments (VS Code/Codespaces):

```json
{
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/git:1": {}
  },
  "postCreateCommand": "npm install",
  "forwardPorts": [3000]
}
```

## Production deploy

- **Orchestrator** — Kubernetes (enterprise), Docker Swarm (simple), Fly.io (PaaS)
- **Registry** — GitHub Container Registry (free), Docker Hub, AWS ECR
- **Tagging** — `:latest` never in prod; use `:v1.2.3` or `:<git-sha>`
- **Rollback** — keep 3-5 previous image tags for rollback

## Integration

- `nc-ci-cd` — build + push images in pipeline
- `nc-env-secrets` — inject secrets at runtime, not build time
- `nc-observability` — sidecar pattern for log/metric collection
