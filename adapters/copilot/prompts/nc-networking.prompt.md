---
description: Network troubleshooting + design. Use when debugging connectivity issues, configuring DNS/TLS/CDN, designing VPC/subnet topology, diagnosing latency, or setting up reverse proxies (nginx/Caddy).
mode: agent
---

# Networking Skill

OSI-layer-aware troubleshooting. Start at the lowest layer that could explain the symptom; don't jump to L7 if L3 is broken.

## Diagnostic ladder

| Symptom | Layer to check first | Tool |
|---|---|---|
| Site won't load | DNS (L7), TLS, then HTTP | `dig`, `curl -v` |
| "Connection refused" | L4 (port) | `nc -vz host port`, `ss -tnlp` |
| "Connection timeout" | L3 (route/firewall) | `traceroute`, `mtr`, firewall rules |
| Slow but works | L4 RTT, L7 backend | `mtr`, `time curl`, app logs |
| Random packet loss | L1/L2/L3 | `mtr`, ISP, link errors |
| TLS errors | L7 cert/SNI | `openssl s_client` |

## DNS

```bash
# Resolve
dig example.com                            # full record
dig example.com +short                     # just answer
dig @1.1.1.1 example.com                   # bypass local resolver
dig example.com ANY                        # all record types
dig example.com MX                         # mail records
dig +trace example.com                     # walk from root → authoritative

# Reverse
dig -x 1.1.1.1                             # IP → name

# Caching debug
systemd-resolve --statistics               # if using systemd-resolved
resolvectl flush-caches                    # clear cache
```

### DNS records cheat sheet

| Type | Purpose | Example |
|---|---|---|
| A | name → IPv4 | `@ A 1.2.3.4` |
| AAAA | name → IPv6 | `@ AAAA ::1` |
| CNAME | alias | `www CNAME example.com.` |
| MX | mail server | `@ MX 10 mail.example.com.` |
| TXT | arbitrary (SPF, DKIM, verification) | `@ TXT "v=spf1 include:..."` |
| SRV | service discovery | `_sip._tcp SRV 0 5 5060 sip.example.com.` |
| CAA | who can issue certs | `@ CAA 0 issue "letsencrypt.org"` |

### TTL strategy

- Stable records (A, AAAA, MX): TTL 3600+ (1h)
- About to migrate: drop TTL to 60-300 a day before, raise after stable
- Health-checked failover (Route53 etc.): low TTL (60s)

## TLS / certificates

```bash
# Inspect server cert
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -dates -subject -issuer

# Check chain
openssl s_client -connect example.com:443 -showcerts </dev/null

# Verify cert against private key
openssl x509 -noout -modulus -in cert.pem | openssl md5
openssl rsa  -noout -modulus -in key.pem  | openssl md5
# Must match

# Generate self-signed (dev only)
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 -subj "/CN=localhost"

# Let's Encrypt (most production)
apt install certbot python3-certbot-nginx
certbot --nginx -d example.com -d www.example.com
# Auto-renews via systemd timer
```

### TLS gotchas

- Mismatch: cert for `example.com` won't validate for `www.example.com` unless SAN includes both
- SNI required: many servers serve different certs per Host header — `--resolve` in curl for testing
- Intermediate chain missing: browsers OK (have CA bundle), strict clients fail — always serve full chain
- HSTS: once `Strict-Transport-Security` sent, browser refuses HTTP for `max-age` seconds — careful with development domains

## Reverse proxy patterns

### Nginx (most common)

```nginx
# /etc/nginx/sites-available/api
upstream api_backend {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
    keepalive 32;
}

server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;        # redirect HTTP → HTTPS
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;

    client_max_body_size 10m;

    location / {
        proxy_pass         http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;

        # WebSocket support
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";
    }

    location /static/ {
        alias /var/www/static/;
        expires 30d;
    }
}
```

After change: `nginx -t && systemctl reload nginx` (test before reload — never blind restart).

### Caddy (zero-config TLS)

```caddyfile
api.example.com {
    reverse_proxy localhost:8080 localhost:8081
    encode gzip
    header X-Frame-Options "SAMEORIGIN"
}
```

Caddy auto-provisions Let's Encrypt certs. Best for new projects with no existing nginx.

## Connectivity debugging

```bash
# Can I reach port?
nc -vz host 443                            # TCP probe
nc -vzu host 53                            # UDP (less reliable)

# Where does it die?
mtr -rwc 100 example.com                   # combined ping + traceroute, 100 packets
traceroute -T -p 443 example.com           # TCP traceroute (better than ICMP if firewalled)

# What's listening locally?
ss -tnlp                                   # TCP listening
ss -tunp                                   # all TCP/UDP with PID
ss -s                                      # summary

# Active connections to specific port
ss -tn dst :443

# Capture packets
tcpdump -i any -n 'port 443'               # quick look
tcpdump -i any -w /tmp/cap.pcap 'host 1.2.3.4'  # save for Wireshark
```

## VPC / subnet topology (cloud)

Layered defense:

```
Internet
   │
   ↓
Public subnet (NAT GW, ALB, bastion)
   │
   ↓
Private subnet (app servers — no public IP)
   │
   ↓
Data subnet (DB, cache — even more isolated)
```

Rules:
- Public subnet: route 0.0.0.0/0 → Internet GW
- Private: route 0.0.0.0/0 → NAT GW (for egress only)
- Data: no internet route at all
- Cross-AZ for HA (at least 2 AZs)
- Security groups (stateful) for app rules
- NACLs (stateless) for subnet-level deny

## CDN considerations

Use CDN (Cloudflare / Fastly / CloudFront) for:
- Static assets (images, CSS, JS)
- Read-heavy APIs (with smart cache headers)
- DDoS protection
- TLS termination at edge

Don't put behind CDN:
- Webhook endpoints (CDN may cache, transform, or deny)
- WebSocket without explicit support
- Pages with per-user content unless using `Cache-Control: private`

## Anti-patterns

- DNS TTL = 86400 right before a migration (24h to propagate fully)
- Self-signed cert in production (browsers warn, APIs reject)
- Allowing 0.0.0.0/0 on DB port (constant scanning)
- One huge VPC for everything (blast radius)
- Reverse proxy without `X-Forwarded-For` (app sees only proxy IP)
- TLS 1.0/1.1 enabled (PCI-failing, deprecated)
- Mixed HTTP/HTTPS pages (browser blocks, looks broken)
- Long timeouts on user-facing endpoints (let them retry, don't burn threads)

## Integration

- `nc-deploy-vps` — sets up nginx + Let's Encrypt
- `nc-kubernetes` — Ingress = same patterns at L7
- `nc-terraform` — VPC/subnet provisioning
- `nc-security` — TLS audit, port scanning
- `nc-observability` — RTT / connection metrics
- `nc-incident-response` — diagnostic ladder during outage
