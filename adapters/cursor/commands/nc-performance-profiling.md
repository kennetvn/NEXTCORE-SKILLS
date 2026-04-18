---
description: Find and fix performance bottlenecks empirically. Use when something is slow but you don't know why, before optimizing speculatively, or when establishing performance baselines. Measure first, optimize second.
---

# Performance Profiling Skill

Premature optimization wastes time. Measurement-first patterns by domain.

## The 3 questions before profiling

1. **Is it actually slow?** Define the baseline. p50? p95? worst case?
2. **Does it matter?** UX-critical path or batch job nobody waits on?
3. **What's the budget?** "Make it faster" is open-ended. "<200ms p95" is actionable.

If you skip these, you'll optimize the wrong thing.

## Domain-specific tooling

### Node.js / JS

```bash
# CPU profile
node --cpu-prof --cpu-prof-name=cpu.cpuprofile app.js
# Open in Chrome DevTools → Performance tab → Load profile

# Memory snapshot
node --inspect app.js
# Chrome DevTools → Memory tab → Heap snapshot

# Quick bottleneck spot
clinic doctor -- node app.js     # npm i -g clinic
clinic flame -- node app.js      # flamegraph
clinic bubbleprof -- node app.js # async io patterns
```

### Python

```bash
# CPU
python -m cProfile -o output.prof script.py
snakeviz output.prof              # pip install snakeviz

# Line-by-line
pip install line_profiler
@profile
def slow_fn(): ...
kernprof -l -v script.py

# Memory
pip install memray
memray run script.py
memray flamegraph memray-script.bin
```

### Web (browser)

- Chrome DevTools → Performance → Record → measure interactions
- **Core Web Vitals** in production: LCP, INP, CLS via web-vitals lib
- **Lighthouse** in CI for regression detection
- React: React DevTools Profiler → flame graph of renders

### Database

```sql
-- Postgres
EXPLAIN ANALYZE SELECT ...;
-- Look for: Seq Scan on big tables, Sort spills, Hash Join with high cost
SELECT * FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;

-- MySQL
EXPLAIN FORMAT=JSON SELECT ...;
-- slow query log: long_query_time = 1
```

## Bottleneck taxonomy

| Symptom | Likely | Tool |
|---|---|---|
| 1 CPU pegged at 100% | Sync compute, regex disasters | CPU profiler |
| All CPUs idle, slow response | I/O wait, lock contention | Async profiler, db EXPLAIN |
| Memory grows unbounded | Leak, missing limit | Heap snapshots compared over time |
| GC pauses | Allocation churn | GC logs, allocation profiler |
| Slow first request, fast subsequent | Cold cache, JIT | Cache, prewarm |
| Slow under concurrency only | Lock contention, connection pool exhaustion | Thread/lock profiler |
| Network-heavy, slow remote | DNS, TLS handshake, RTT | mtr, tcpdump |

## Common wins (often more impact than micro-optimizations)

1. **Don't N+1 the database** — 1 query joining > 100 queries
2. **Add the index** — EXPLAIN ANALYZE shows seq scans
3. **Cache the hot read** — even 1-second TTL helps
4. **Defer the slow thing** — queue + worker > inline
5. **Stream don't buffer** — large payloads → backpressure
6. **Compress text payloads** — gzip/brotli at edge
7. **Pool connections** — DB, HTTP, Redis
8. **Move CPU to edge** — CDN for assets, ISR for pages

## Optimization protocol

```
1. Measure baseline (p50, p95, worst)
2. Profile the slow case (don't guess)
3. Find the biggest contributor
4. Fix it
5. Re-measure
6. If still slow, repeat from step 3
7. Stop when budget met or diminishing returns
```

Document each iteration. "Reduced p95 from 800ms → 180ms by adding index on `users.email`."

## Anti-patterns

- Optimizing without measuring (often the bottleneck is elsewhere)
- Micro-optimizing (`++i` vs `i++`) when DB is doing 200ms scan
- Caching everything (cache invalidation is the hard problem)
- Adding parallelism without measuring lock contention first
- Profiling local env (different perf characteristics from prod)
- Optimizing cold paths (the rare slow query that runs once a day)
- Calling something "fast enough" without numeric target

## Integration

- `nc-debugging-advanced` — when slow + buggy together
- `nc-databases` — DB-specific perf patterns (indexes, EXPLAIN)
- `nc-observability` — production perf metrics
- `nc-react-best-practices` — React perf patterns
- `nc-incident-response` — perf regression as incident
- `nc-ai-evaluation` — measure latency in LLM apps
