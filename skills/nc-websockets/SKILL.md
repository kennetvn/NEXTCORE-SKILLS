---
name: nc:websockets
description: "Realtime patterns: WebSockets, Server-Sent Events (SSE), polling. Use when building chat, live dashboards, notifications, collaborative editing, or choosing realtime transport."
license: MIT
argument-hint: "[ws|sse|polling|scale]"
---

# Realtime Patterns

## Transport choice

| Transport | Pros | Cons | Use when |
|---|---|---|---|
| **WebSockets** | Bidirectional, binary, low overhead | Complex scaling, sticky sessions | Chat, collab, games |
| **SSE** | HTTP-native, auto-reconnect, simple | One-way (server→client), no binary | Notifications, dashboards, feeds |
| **Long polling** | Works everywhere, simple | Inefficient at scale | Fallback only |
| **Short polling** | Trivial | Wasteful, high latency | Low-frequency data |

## SSE (recommended for 80% of use cases)

```ts
// Server (Next.js route)
export async function GET() {
  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    start(controller) {
      const interval = setInterval(() => {
        const msg = `data: ${JSON.stringify({ time: Date.now() })}\n\n`;
        controller.enqueue(encoder.encode(msg));
      }, 1000);
      // Cleanup on disconnect
      return () => clearInterval(interval);
    }
  });
  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive"
    }
  });
}

// Client
const es = new EventSource("/api/events");
es.onmessage = (e) => {
  const data = JSON.parse(e.data);
  // handle
};
es.onerror = () => {
  // browser auto-reconnects with Last-Event-ID
};
```

## WebSocket (bidirectional)

```ts
// Server (ws lib)
import { WebSocketServer } from "ws";
const wss = new WebSocketServer({ port: 8080 });

wss.on("connection", (ws, req) => {
  const userId = authFromReq(req);
  if (!userId) return ws.close(4001, "Unauthorized");

  ws.on("message", (data) => {
    const msg = JSON.parse(data.toString());
    // broadcast or handle
  });

  ws.on("close", () => {
    // cleanup
  });
});

// Client
const ws = new WebSocket("wss://example.com/socket");
ws.onopen = () => ws.send(JSON.stringify({ type: "hello" }));
ws.onmessage = (e) => {
  const msg = JSON.parse(e.data);
};
```

## Scaling realtime

### Problem: multiple app instances

User A connected to instance 1, User B to instance 2. A sends message to B → instance 1 doesn't know B exists.

### Solution: Redis pub/sub

```ts
// On message from client
await redis.publish(`chat:${roomId}`, JSON.stringify(msg));

// On each instance, subscribe
redis.subscribe(`chat:${roomId}`);
redis.on("message", (chan, msg) => {
  // forward to connected clients in this room on THIS instance
  localRoomClients.forEach(ws => ws.send(msg));
});
```

### Sticky sessions

Load balancer must route same user's requests to same instance (required for WebSocket reconnect handling):

- nginx: `ip_hash`
- AWS ALB: sticky cookies
- Cloudflare: session affinity

SSE avoids this — stateless HTTP, any instance can handle.

## Reconnection + replay

SSE native: browser sends `Last-Event-ID` header on reconnect.

```ts
// Server: assign unique ID to each event
controller.enqueue(encoder.encode(`id: ${eventId}\ndata: ...\n\n`));

// On reconnect with Last-Event-ID header:
const lastId = req.headers.get("Last-Event-ID");
// Replay missed events from lastId to now
```

## NextCore pattern (example-homestay.com)

NextCore uses SSE for:
- VIP order status updates (PENDING → PAID → ACTIVE)
- Invoice updates
- Finance transaction stream

Pattern: multi-channel emit — mutation emits to all affected entity channels.

```ts
// On webhook PAID event
await emitSSE('vip-subscriptions', { subId, status: 'ACTIVE' });
await emitSSE('vip-orders', { orderId, status: 'PAID' });
await emitSSE('finance-transactions', { txId });
```

## Anti-patterns

- WebSocket for one-way server push → use SSE (simpler)
- Polling every 1s → use SSE or WS
- No auth on WS → anyone can eavesdrop
- No reconnection logic on client → silent failure on network blip
- No backpressure handling → message queue overflow

## Integration

- `nc-caching` — Redis pub/sub for cross-instance
- `nc-auth-patterns` — authenticate WS/SSE connection at handshake
- `nc-observability` — track connection count, message rate
