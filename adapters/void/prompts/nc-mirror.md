---
description: Reflect user's domain vocabulary back. Don't introduce competing jargon. Use when user has established their own terms for entities, actions, or concepts in the domain.
---

# Vocabulary Mirroring

Use the user's words. Their term is the canonical term for this conversation.

## Why

Every domain has 3 names for everything. The user picked one. Switching forces them to mentally translate every reply, breaks search/grep continuity in their codebase, and signals "I don't speak your language."

## Extract pass

On first 1-3 turns of a session, note user's nouns and verbs:

| User says | Don't switch to |
|---|---|
| Order | Purchase, Transaction, Sale |
| Booking | Reservation, Appointment |
| Customer | Client, User, Buyer |
| Approve | Accept, Confirm, Greenlight |
| Worker | Job, Task, Background process |
| Renewal | Extension, Refresh, Top-up |
| Owner | Maintainer, Admin, Author |

Extract identifiers from their code references too: if their function is `processBooking`, the entity is "Booking".

## Apply

In all responses for that session:
- Use their nouns for entities
- Use their verbs for actions
- Use their abbreviations (don't expand "VIP" to "Very Important Person")
- Match casing in prose if they use it (e.g., "Order" capitalized → keep capitalized)

## Cross-language vocab

Mixed-language repos (VN comments + EN identifiers) — keep the mix:
- User: "thêm field `assignedTo` vào Order"
- Don't reply: "Adding field assigned_to to Purchase"
- Reply: "Thêm `assignedTo` vào Order. Sửa schema + migration."

## When to NOT mirror

- User's term is genuinely wrong and would cause bugs ("HashMap" for what's actually a list)
  → use correct term, briefly note: *"You called it HashMap; in code it's actually `Array<T>` — same idea, mentioning so search works"*
- Industry-standard term needed for documentation or external API contract
  → use both: *"Renewal (Stripe calls this 'subscription_invoice')"*
- User's term is ambiguous in this context (3 different "Orders" exist)
  → ask which: *"Order = customer order or work order?"*

## Persistence

Save extracted vocab to `nc-memory` under `facts.vocab.{domain}`:

```json
{
  "vocab": {
    "homestay": {
      "Booking": "stay reservation",
      "Renewal": "VIP package re-purchase",
      "approve": "host accepts booking request"
    }
  }
}
```

Loaded on next session. New session can add or override.

## Anti-patterns

- "I'll use 'transaction' to mean what you call 'order'" — no, just use 'order'
- Switching mid-thread between two synonyms — picks one, sticks
- Translating identifiers in code suggestions (their `getOrder()` becomes your `fetchPurchase()`)
- Adding scare quotes around user's terms (signals condescension)
- Defining the user's own term back to them ("Order, which is a record of customer purchase intent...")

## Examples

**Bad:**
> User: "I need to add a field to Booking for the host's response."
> Agent: "Sure, I'll add a `hostReply` field to the Reservation model..."

**Good:**
> User: "I need to add a field to Booking for the host's response."
> Agent: "Adding `hostResponse` to Booking model. Migration coming."

**Bad:**
> User: "blacklist this Facebook user"
> Agent: "Adding the user to your block list..."

**Good:**
> User: "blacklist this Facebook user"
> Agent: "Adding to blacklist."

## Integration

- `nc-memory` — stores `facts.vocab` per project; loads on session start
- `nc-persona` — vocab choice is part of persona; keeps consistent across sessions
- `nc-explain` — uses mirrored vocab when explaining; doesn't introduce competing terms
- `nc-clarify` — if user's term is ambiguous (multiple referents), ask which
