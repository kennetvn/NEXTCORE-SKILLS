---
description: Caching strategies: Redis, in-memory LRU, HTTP cache headers, CDN. Use when optimizing read-heavy endpoints, reducing DB load, or architecting multi-layer cache.
auto_execution_mode: 1
---

# Caching Strategies

## Cache layers (fastest to slowest)

1. **Browser** — HTTP cache headers (`Cache-Control`, `ETag`)
2. **CDN** — Cloudflare, Fastly, AWS CloudFront (edge)
3. **Reverse proxy** — Varnish, nginx (origin edge)
4. **Application memory** — LRU in-process (Node `lru-cache`)
5. **Distributed** — Redis, Memcached (cross-instance)
6. **Database** — query result cache (Postgres shared_buffers)

## HTTP cache headers

```
Cache-Control: public, max-age=3600, s-maxage=86400
ETag: "abc123"
Vary: Accept-Encoding, Authorization
```

- `max-age` — browser cache seconds
- `s-maxage` — CDN cache seconds (overrides max-age for shared caches)
- `public` — cacheable by shared caches; `private` — browser only
- `stale-while-revalidate=60` — serve stale up to 60s while refetching in bg
- `immutable` — never revalidate (for hashed static assets)

## Redis patterns

### Cache-aside (read-through)

```ts
async function getUser(id) {
  const key = `user:${id}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const user = await db.user.findUnique({ where: { id } });
  await redis.setex(key, 300, JSON.stringify(user));  // 5 min TTL
  return user;
}
```

### Write-through

```ts
async function updateUser(id, data) {
  const user = await db.user.update({ where: { id }, data });
  await redis.setex(`user:${id}`, 300, JSON.stringify(user));
  return user;
}
```

### Cache invalidation

```ts
async function deleteUser(id) {
  await db.user.delete({ where: { id } });
  await redis.del(`user:${id}`);
  // Also invalidate related caches
  await redis.del(`users:list:*`);  // pattern delete — see below
}
```

### Rate limiting

```ts
async function rateLimit(userId, limit = 100, windowSec = 60) {
  const key = `rate:${userId}:${Math.floor(Date.now() / 1000 / windowSec)}`;
  const count = await redis.incr(key);
  if (count === 1) await redis.expire(key, windowSec);
  return count <= limit;
}
```

## In-memory LRU

Good for small, hot, per-instance data:

```ts
import { LRUCache } from "lru-cache";

const cache = new LRUCache<string, User>({
  max: 500,
  ttl: 1000 * 60 * 5,  // 5 min
});

function getUser(id) {
  let user = cache.get(id);
  if (user) return user;
  user = await db.user.findUnique({ where: { id } });
  cache.set(id, user);
  return user;
}
```

## CDN strategies

- **Static assets**: cache forever with content-hash in filename (`/app.abc123.js`)
- **HTML pages**: short cache (5-60s) with stale-while-revalidate
- **API responses**: CDN for public GET; bypass for authenticated
- **Purge**: support explicit purge on deploy (CDN API)

## Cache invalidation strategies

| Strategy | When |
|---|---|
| **TTL expiry** | Eventually-consistent data (user profiles, product lists) |
| **Explicit invalidate** | On write (delete cached key after DB update) |
| **Tag-based** | Group related caches, invalidate by tag (Redis + tagged keys) |
| **Write-through** | Update cache atomically with DB write |
| **Never cache** | Strongly consistent data (user balance, auth tokens) |

## Cache stampede protection

When cache expires + many concurrent requests → DB floods.

```ts
// Use lock or probabilistic early expiration
async function getUserWithLock(id) {
  const key = `user:${id}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const lockKey = `lock:${key}`;
  const acquired = await redis.set(lockKey, "1", "NX", "EX", 5);
  if (!acquired) {
    await new Promise(r => setTimeout(r, 100));
    return getUserWithLock(id);  // retry
  }

  const user = await db.user.findUnique({ where: { id } });
  await redis.setex(key, 300, JSON.stringify(user));
  await redis.del(lockKey);
  return user;
}
```

## Anti-patterns

- Caching frequently-changing data (defeats cache)
- No TTL (memory leak in Redis/LRU)
- Caching personalized responses as `public`
- Cache key collisions (forgot user scope)
- No stampede protection on hot keys

## Integration

- `nc-websockets` — cache doesn't apply to realtime, use pub/sub
- `nc-observability` — metric: cache hit rate, eviction rate
- `nc-databases` — ORM query cache complements app-level cache
