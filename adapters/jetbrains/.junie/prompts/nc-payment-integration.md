---
description: Integrate payments with SePay (VietQR), Polar, Stripe, Paddle (MoR subscriptions), Creem.io (licensing). Checkout, webhooks, subscriptions, QR codes, multi-provider orders.
---

# Payment Integration

Production-proven payment processing with SePay (Vietnamese banks), Polar (global SaaS), Stripe (global infrastructure), Paddle (MoR subscriptions), and Creem.io (MoR + licensing).

## When to Use

- Payment gateway integration (checkout, processing)
- Subscription management (trials, upgrades, billing)
- Webhook handling (notifications, idempotency)
- QR code payments (VietQR, NAPAS)
- Software licensing (device activation)
- Multi-provider order management
- Revenue splits and commissions

## Platform Selection

| Platform | Best For |
|----------|----------|
| **SePay** | Vietnamese market, VND, bank transfers, VietQR |
| **Polar** | Global SaaS, subscriptions, automated benefits (GitHub/Discord) |
| **Stripe** | Enterprise payments, Connect platforms, custom checkout |
| **Paddle** | MoR subscriptions, global tax compliance, churn prevention |
| **Creem.io** | MoR + licensing, revenue splits, no-code checkout |

## Quick Reference

### SePay
- `nc-payment-integration/references/sepay/overview.md` - Auth, supported banks
- `nc-payment-integration/references/sepay/api.md` - Endpoints, transactions
- `nc-payment-integration/references/sepay/webhooks.md` - Setup, verification
- `nc-payment-integration/references/sepay/sdk.md` - Node.js, PHP, Laravel
- `nc-payment-integration/references/sepay/qr-codes.md` - VietQR generation
- `nc-payment-integration/references/sepay/best-practices.md` - Production patterns

### Polar
- `nc-payment-integration/references/polar/overview.md` - Auth, MoR concept
- `nc-payment-integration/references/polar/products.md` - Pricing models
- `nc-payment-integration/references/polar/checkouts.md` - Checkout flows
- `nc-payment-integration/references/polar/subscriptions.md` - Lifecycle management
- `nc-payment-integration/references/polar/webhooks.md` - Event handling
- `nc-payment-integration/references/polar/benefits.md` - Automated delivery
- `nc-payment-integration/references/polar/sdk.md` - Multi-language SDKs
- `nc-payment-integration/references/polar/best-practices.md` - Production patterns

### Stripe
- `nc-payment-integration/references/stripe/stripe-best-practices.md` - Integration design
- `nc-payment-integration/references/stripe/stripe-sdks.md` - Server SDKs
- `nc-payment-integration/references/stripe/stripe-js.md` - Payment Element
- `nc-payment-integration/references/stripe/stripe-cli.md` - Local testing
- `nc-payment-integration/references/stripe/stripe-upgrade.md` - Version upgrades
- External: https://docs.stripe.com/llms.txt

### Paddle
- `nc-payment-integration/references/paddle/overview.md` - MoR, auth, entity IDs
- `nc-payment-integration/references/paddle/api.md` - Products, prices, transactions
- `nc-payment-integration/references/paddle/paddle-js.md` - Checkout overlay/inline
- `nc-payment-integration/references/paddle/subscriptions.md` - Trials, upgrades, pause
- `nc-payment-integration/references/paddle/webhooks.md` - SHA256 verification
- `nc-payment-integration/references/paddle/sdk.md` - Node, Python, PHP, Go
- `nc-payment-integration/references/paddle/best-practices.md` - Production patterns
- External: https://developer.paddle.com/llms.txt

### Creem.io
- `nc-payment-integration/references/creem/overview.md` - MoR, auth, global support
- `nc-payment-integration/references/creem/api.md` - Products, checkout sessions
- `nc-payment-integration/references/creem/checkouts.md` - No-code links, storefronts
- `nc-payment-integration/references/creem/subscriptions.md` - Trials, seat-based
- `nc-payment-integration/references/creem/licensing.md` - Device activation
- `nc-payment-integration/references/creem/webhooks.md` - Signature verification
- `nc-payment-integration/references/creem/sdk.md` - Next.js, Better Auth
- External: https://docs.creem.io/llms.txt

### Multi-Provider
- `nc-payment-integration/references/multi-provider-order-management-patterns.md` - Unified orders, currency conversion

### Scripts
- `scripts/sepay-webhook-verify.js` - SePay webhook verification
- `scripts/polar-webhook-verify.js` - Polar webhook verification
- `scripts/checkout-helper.js` - Checkout session generator

## Key Capabilities

| Platform | Highlights |
|----------|------------|
| **SePay** | QR/bank/cards, 44+ VN banks, webhooks, 2 req/s |
| **Polar** | MoR, subscriptions, usage billing, benefits, 300 req/min |
| **Stripe** | CheckoutSessions, Billing, Connect, Payment Element |
| **Paddle** | MoR, overlay/inline checkout, Retain (churn prevention), tax |
| **Creem.io** | MoR, licensing, revenue splits, no-code checkout |

## Implementation

See `nc-payment-integration/references/implementation-workflows.md` for step-by-step guides per platform.

**General flow:** auth → products → checkout → webhooks → events
