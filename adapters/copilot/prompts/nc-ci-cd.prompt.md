---
description: CI/CD pipeline patterns for GitHub Actions, GitLab CI, Jenkins. Use when setting up automated testing, build+deploy pipelines, matrix builds, or secrets-aware deployment workflows.
mode: agent
---

# CI/CD Pipeline Patterns

## GitHub Actions templates

### Standard Node.js pipeline

```yaml
name: CI
on:
  push: { branches: [main, develop] }
  pull_request: { branches: [main] }

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test
      - run: npm run build

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: bash scripts/deploy.sh
```

### Matrix test (multiple Node/OS)

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: [20, 22]
    runs-on: ${{ matrix.os }}
```

### Docker build + push

```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- uses: docker/build-push-action@v5
  with:
    push: true
    tags: |
      ghcr.io/${{ github.repository }}:latest
      ghcr.io/${{ github.repository }}:${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## GitLab CI templates

```yaml
stages: [test, build, deploy]

test:
  stage: test
  image: node:22-alpine
  script:
    - npm ci
    - npm test
  cache:
    key: $CI_COMMIT_REF_SLUG
    paths: [node_modules/]

deploy:
  stage: deploy
  only: [main]
  script:
    - bash scripts/deploy.sh
  environment:
    name: production
    url: https://example.com
```

## Patterns

### Fail-fast + concurrency control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Artifact passing between jobs

```yaml
- uses: actions/upload-artifact@v4
  with: { name: build, path: dist/ }

# In next job:
- uses: actions/download-artifact@v4
  with: { name: build, path: dist/ }
```

### Conditional steps

```yaml
- if: github.event_name == 'pull_request'
  run: npm run test:integration

- if: startsWith(github.ref, 'refs/tags/v')
  run: npm publish
```

### Secrets

- Repository secrets for per-repo
- Organization secrets for shared (API keys, deploy keys)
- Environment secrets for production-only (`environment: production`)
- Never echo secrets in logs

## Deployment strategies

| Strategy | When |
|---|---|
| **Direct push** | Solo/small team, main = prod |
| **Blue-green** | Zero-downtime, need prior version standby |
| **Canary** | Risky changes, gradual rollout (5% → 25% → 100%) |
| **Rolling update** | Orchestrator-native (k8s), batches of pods |
| **Feature flags** | Deploy code, gate feature (decouple deploy/release) |

## Anti-patterns

- Building in deploy job (do build in test stage, pass artifact)
- Running slow tests on every push (use schedule or label-gated)
- Secrets in plain `env:` value (use `secrets.FOO` reference)
- No timeout on jobs (runaway = cost)
- No concurrency control (race conditions on shared deploy targets)

## Integration

- `nc-docker` — build images in CI
- `nc-env-secrets` — secret management in pipelines
- `nc-ship` — local pipeline that mirrors CI
