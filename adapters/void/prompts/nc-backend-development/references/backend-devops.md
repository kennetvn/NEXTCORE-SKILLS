# Backend DevOps Practices

CI/CD pipelines, containerization, deployment strategies, and monitoring (2025).

## Deployment Strategies

### Blue-Green Deployment

**Concept:** Two identical environments (Blue = current, Green = new)

```
Production Traffic → Blue (v1.0)
                     Green (v2.0) ← Deploy & Test

Switch:
Production Traffic → Green (v2.0)
                     Blue (v1.0) ← Instant rollback available
```

**Pros:**
- Zero downtime
- Instant rollback
- Full environment testing before switch

**Cons:**
- Requires double infrastructure
- Database migrations complex

### Canary Deployment

**Concept:** Gradual rollout (1% → 5% → 25% → 100%)

```bash
# Kubernetes canary deployment
kubectl set image deployment/api api=myapp:v2
kubectl rollout pause deployment/api  # Pause at initial replicas

# Monitor metrics, then continue
kubectl rollout resume deployment/api
```

**Pros:**
- Risk mitigation
- Early issue detection
- Real user feedback

**Cons:**
- Requires monitoring
- Longer deployment time

### Feature Flags (Progressive Delivery)

**Impact:** 90% fewer deployment failures when combined with canary

```typescript
import { LaunchDarkly } from 'launchdarkly-node-server-sdk';

const client = LaunchDarkly.init(process.env.LD_SDK_KEY);

// Check feature flag
const showNewCheckout = await client.variation('new-checkout', user, false);

if (showNewCheckout) {
  return newCheckoutFlow(req, res);
} else {
  return oldCheckoutFlow(req, res);
}
```

**Use Cases:**
- Gradual feature rollout
- A/B testing
- Kill switch for problematic features
- Decouple deployment from release

## Containerization with Docker

### Multi-Stage Builds (Optimize Image Size)

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app

# Copy only necessary files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./

# Security: Run as non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

**Benefits:**
- Smaller image size (50-90% reduction)
- Faster deployments
- Reduced attack surface

### Docker Compose (Local Development)

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres-data:
```

## Kubernetes Orchestration

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
