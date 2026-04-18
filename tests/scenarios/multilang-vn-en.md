# Scenario: Mixed VN/EN persistence + identifier preservation

**Triggers:** `nc-persona`, `nc-mirror`, `nc-memory`
**User profile:** Vietnamese senior dev, code identifiers in English
**Setup:** Fresh session, no prior identity

## Turn 1

**User:** "Thêm field `assignedTo` vào model Order, kiểu String? (nullable)."

**Expected behavior:**
- Detect VN prose + EN identifiers → save to `nc-memory.preferences.language = "vn-en-mixed"`
- Reply same shape: VN prose, EN identifiers preserved
- Example: `> Thêm field assignedTo (String?, optional) vào Order. Tạo migration: prisma migrate dev --name add_order_assigned_to.`

**Anti-patterns to avoid:**
- Replying entirely in English
- Translating `assignedTo` to `nguoiDuocGiao`
- Translating `Order` to `DonHang`
- Translating `String?` to `Chuoi?`
- Adding English subtitles "Add field assignedTo (in English: assigned to)..."

## Turn 2

**User:** "Generate migration command and explain what it does."

**Expected behavior:**
- Migration command: `npx prisma migrate dev --name add_order_assigned_to`
- Explanation in VN (matching established mode): "Lệnh này sẽ tạo file SQL migration mới trong `prisma/migrations/`, đặt tên prefix bằng timestamp, áp dụng vào DB local..."
- Code blocks stay in English

**Anti-patterns to avoid:**
- Switching explanation to English just because it's "explaining"
- Adding `// English: ...` comments to code

## Turn 3 (new session next day)

**User:** "Show me the latest migrations"

**Expected behavior:**
- Load `nc-memory.preferences.language = "vn-en-mixed"`
- User wrote in EN this turn — but prior session profile suggests VN-EN mix
- Match user's CURRENT message language (EN) — don't force VN
- Note: persona persists, but specific message language is per-message

**Anti-patterns to avoid:**
- Forcing VN reply when user wrote EN
- Forgetting prior identity entirely

## Turn 4 (same session, user reverts)

**User:** "Cảm ơn, vậy rollback migration cuối cùng làm sao?"

**Expected behavior:**
- User switched back to VN → reply in VN
- Continue with same identifier-preservation rules

## Pass criteria

- VN prose + EN identifiers preserved 100%
- Language mode tracked per-message but identity persists
- No translation of code symbols, file paths, or commands
- Cross-session memory recalls language preference for default
