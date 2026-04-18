---
description: Authentication + authorization patterns: OAuth2, JWT, session cookies, passwordless, MFA, RBAC. Use when designing auth flow, evaluating auth libraries, or hardening an existing auth system.
auto_execution_mode: 1
---

# Authentication & Authorization

## Session vs JWT decision

| Session cookies | JWT tokens |
|---|---|
| Server-side state (DB lookup) | Stateless (self-contained) |
| Easy to revoke (delete session) | Hard to revoke (blocklist or short TTL) |
| Work natively with CSRF protection | Need explicit CSRF handling if cookie-based |
| Smaller payload | Larger (header+payload+signature) |

**Recommendation:** Session cookies for web apps. JWT for stateless APIs + mobile.

## Session cookie pattern

```ts
// Login
const session = await db.session.create({
  data: { userId, expiresAt: new Date(Date.now() + 7 * 24 * 3600 * 1000) }
});
res.cookie("sid", session.id, {
  httpOnly: true,
  secure: true,
  sameSite: "lax",
  maxAge: 7 * 24 * 3600 * 1000,
});

// Middleware
async function authMiddleware(req) {
  const sid = req.cookies.sid;
  if (!sid) return null;
  const session = await db.session.findUnique({
    where: { id: sid, expiresAt: { gt: new Date() } },
    include: { user: true }
  });
  return session?.user;
}
```

## JWT pattern

```ts
import jwt from "jsonwebtoken";

// Sign
const token = jwt.sign(
  { sub: userId, email, role },
  process.env.JWT_SECRET,
  { expiresIn: "15m" }  // short TTL
);

// Refresh token stored in DB (can revoke)
const refreshToken = await db.refreshToken.create({ data: { userId, expiresAt: ... } });

// Verify
const payload = jwt.verify(token, process.env.JWT_SECRET);
```

**JWT rules:**
- Short TTL (15 min) + refresh token (7 days, revocable)
- RS256 (asymmetric) for public-facing APIs; HS256 only for internal
- Never store secrets in JWT payload (it's base64, not encrypted)
- Validate `iss`, `aud`, `exp`, `nbf` on every request

## OAuth2 / OIDC

Use for: "Sign in with Google/GitHub/Apple", B2B SSO.

Libraries: `better-auth`, `next-auth`, `@auth/core`, `passport`.

Flow (Authorization Code + PKCE):

```
Client → redirect to /authorize (with PKCE challenge)
Provider → login → redirect back with code
Client → POST /token (exchange code + verifier)
Provider → returns access_token + id_token
Client → store tokens, use for API calls
```

## Passwordless (magic link)

```ts
// Request
async function sendMagicLink(email) {
  const token = crypto.randomBytes(32).toString("hex");
  await db.magicToken.create({
    data: { email, token, expiresAt: new Date(Date.now() + 15 * 60 * 1000) }
  });
  await sendEmail(email, `https://app.com/auth/verify?token=${token}`);
}

// Verify
async function verifyMagicLink(token) {
  const record = await db.magicToken.findUnique({
    where: { token, expiresAt: { gt: new Date() } }
  });
  if (!record) throw new Error("Invalid or expired");
  await db.magicToken.delete({ where: { token } });  // single-use
  return createSession(record.email);
}
```

## MFA (TOTP)

```ts
import { authenticator } from "otplib";

// Enroll
const secret = authenticator.generateSecret();
const qr = authenticator.keyuri(email, "MyApp", secret);
// Show QR code to user, save secret encrypted

// Verify
const valid = authenticator.verify({ token, secret });
```

Always: provide backup codes (one-time recovery).

## RBAC (Role-Based Access Control)

```ts
const PERMISSIONS = {
  admin: ["*"],
  manager: ["read:*", "write:orders", "write:users"],
  user: ["read:own:*", "write:own:profile"],
};

function can(user, action, resource) {
  const perms = PERMISSIONS[user.role] || [];
  if (perms.includes("*") || perms.includes(`${action}:*`)) return true;
  if (perms.includes(`${action}:own:*`) && resource.ownerId === user.id) return true;
  return perms.includes(`${action}:${resource.type}`);
}
```

For complex cases: ABAC (attribute-based) via Casbin, OPA.

## Security checklist

- [ ] Passwords: bcrypt/argon2, never MD5/SHA1
- [ ] Cookies: httpOnly, secure, sameSite
- [ ] CSRF: double-submit cookie or SameSite=strict
- [ ] Rate limit: login, password reset, signup endpoints
- [ ] Session rotation on privilege change
- [ ] Logout invalidates session (session table) or rotates signing key (JWT)
- [ ] Audit log: admin actions, failed logins

## Anti-patterns

- Storing passwords in plaintext or MD5
- JWT in localStorage (XSS steals it)
- No rate limit on login (brute force)
- Long-lived JWTs without revocation path
- MFA without backup codes
- Missing CSRF protection on state-changing endpoints

## Integration

- `nc-env-secrets` — JWT secrets, OAuth client secrets
- `nc-caching` — rate limit counters in Redis
- `nc-observability` — alert on failed login spikes
