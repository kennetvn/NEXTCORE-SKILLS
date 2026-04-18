# Scenario: Domain vocabulary mirroring

**Triggers:** `nc-mirror`, `nc-explain`, `nc-memory`
**User profile:** Hospitality SaaS founder, uses domain terms consistently
**Setup:** First conversation about their codebase

## Turn 1

**User:** "I want to add a field to Booking for the host's response when a guest requests early check-in."

**Expected behavior:**
- Run `nc-mirror` extract pass — note nouns: "Booking", "host", "guest", "check-in"
- Save to `nc-memory.facts.vocab.{project}` for future sessions
- In response, use exactly these words. NOT "Reservation", "Owner", "Customer", "arrival"
- Schema field name should match casing: `Booking` is capitalized → use `hostResponse` not `host_response`

**Anti-patterns to avoid:**
- "Adding a `hostReply` field to the Reservation model..." (switched both terms)
- "I'll create a method on the Owner class..." (Owner → host)
- Defining "Booking" back to user: "Booking, which represents..."

## Turn 2

**User:** "Cảm ơn. Bây giờ migration sao? Tôi dùng Prisma."

**Expected behavior:**
- Detect language switch to VN — mirror language going forward
- Keep entity names in English (`Booking`, `hostResponse`) — they're identifiers
- VN prose around them
- Example response: `> Migration: thêm cột hostResponse (String?, nullable) vào Booking. prisma migrate dev --name add_booking_host_response.`

**Anti-patterns to avoid:**
- Translating `Booking` to `DatPhong`
- Reverting to English now that user wrote VN

## Turn 3 (next session, days later)

**User:** "How's the Booking change going?"

**Expected behavior:**
- Load `nc-memory.facts.vocab.{project}` on session start
- Recognize "Booking" from prior vocab — use it
- Without re-asking, recall context (or admit lack and ask)

**Anti-patterns to avoid:**
- "Which booking system are you using?" (already in memory)
- Switching to "Reservation" because new session

## Pass criteria

- Zero terminology substitutions in agent output
- Language mirror persists within turn
- Vocab memory survives across sessions
- Identifiers stay in original language even when prose switches
