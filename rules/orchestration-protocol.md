# Orchestration Protocol

## Delegation Context (MANDATORY)

When spawning subagents via Task tool, **ALWAYS** include in prompt:

1. **Work Context Path**: The git root of the PRIMARY files being worked on
2. **Reports Path**: `{work_context}/plans/reports/` for that project
3. **Plans Path**: `{work_context}/plans/` for that project

**Example:**
```
Task prompt: "Fix parser bug.
Work context: /path/to/project-b
Reports: /path/to/project-b/plans/reports/
Plans: /path/to/project-b/plans/"
```

**Rule:** If CWD differs from work context (editing files in different project), use the **work context paths**, not CWD paths.

---

#### Sequential Chaining
Chain subagents when tasks have dependencies or require outputs from previous steps:
- **Planning → Implementation → Simplification → Testing → Review**: Use for feature development (tests verify simplified code)
- **Research → Design → Code → Documentation**: Use for new system components
- Each agent completes fully before the next begins
- Pass context and outputs between agents in the chain

#### Parallel Execution
Spawn multiple subagents simultaneously for independent tasks:
- **Code + Tests + Docs**: When implementing separate, non-conflicting components
- **Multiple Feature Branches**: Different agents working on isolated features
- **Cross-platform Development**: iOS and Android specific implementations
- **Careful Coordination**: Ensure no file conflicts or shared resource contention
- **Merge Strategy**: Plan integration points before parallel execution begins

---

## Subagent Status Protocol

Subagents MUST report one of these statuses when completing work:

| Status | Meaning | Controller Action |
|--------|---------|-------------------|
| **DONE** | Task completed successfully | Proceed to next step (review, next task) |
| **DONE_WITH_CONCERNS** | Completed but flagged doubts | Read concerns → address if correctness/scope issue → proceed if observational |
| **BLOCKED** | Cannot complete task | Assess blocker → provide context / break task / escalate to user |
| **NEEDS_CONTEXT** | Missing information to proceed | Provide missing context → re-dispatch |

### Handling Rules

- **Never** ignore BLOCKED or NEEDS_CONTEXT — something must change before retry
- **Never** force same approach after BLOCKED — try: more context → simpler task → more capable model → escalate
- **DONE_WITH_CONCERNS** about file growth or tech debt → note for future, proceed now
- **DONE_WITH_CONCERNS** about correctness → address before review
- If subagent fails 3+ times on same task → escalate to user, don't retry blindly

### Reporting Format

Subagents should end their response with:

```
**Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
**Summary:** [1-2 sentence summary]
**Concerns/Blockers:** [if applicable]
```

---

## Context Isolation Principle

**Subagents receive only the context they need.** Never pass full session history.

### Rules

1. **Craft prompts explicitly** — Provide task description, relevant file paths, acceptance criteria. Not "here's what we discussed."
2. **No session history** — Subagent gets fresh context. Summarize relevant decisions, don't replay conversation.
3. **Scope file references** — List specific files to read/modify. Not "look at the codebase."
4. **Include plan context** — If working from a plan, provide the specific phase text, not the entire plan.
5. **Preserve controller context** — Coordination work stays in main agent. Don't dump coordination details into subagent prompts.

### Prompt Template

```
Task: [specific task description]
Files to modify: [list]
Files to read for context: [list]
Acceptance criteria: [list]
Constraints: [any relevant constraints]
Plan reference: [phase file path if applicable]

Work context: [project path]
Reports: [reports path]
```

### Anti-Patterns

| Bad | Good |
|-----|------|
| "Continue from where we left off" | "Implement X feature per spec in phase-02.md" |
| "Fix the issues we discussed" | "Fix null check in auth.ts:45, root cause: missing validation" |
| "Look at the codebase and figure out" | "Read src/api/routes.ts and add POST /users endpoint" |
| Passing 50+ lines of conversation | 5-line task summary with file paths |

---

## Agent Board — Checkin/Checkout (MANDATORY)

**Mọi agent (lead hoặc subagent) làm việc trên dự án PHẢI tuân thủ quy trình checkin/checkout.**

Board path: `<storage-project>/agent-infra/board/`

### Quy trình bắt buộc

#### 1. Trước khi bắt đầu làm việc:
- **Đọc** `<storage-project>/agent-infra/board/BOARD.md` → biết agents khác đang làm gì, files nào đang bị lock
- **Tạo checkin** file: `<storage-project>/agent-infra/board/checkins/{agent-type}-{YYMMDD-HHMM}.md`
- **Update BOARD.md** → thêm dòng mới vào bảng Active Agents + đăng ký File Lock

#### 2. Trong quá trình làm việc:
- **Update checkin file** khi hoàn thành sub-task hoặc gặp lỗi
- **Nếu cần sửa file đã bị agent khác lock** → KHÔNG báo sếp. Tự xử lý:
  1. Kiểm tra agent đó còn ACTIVE không (đọc checkin file, xem last updated)
  2. Nếu agent đó còn hoạt động → **đợi** agent đó hoàn thành, rồi check lại
  3. Nếu agent đó đã ngừng/mất kết nối (checkin > 30 phút không update) → đóng checkin cũ, nhận lock
  4. Nếu cần phối hợp → dùng SendMessage liên hệ agent đó trực tiếp
  5. Ghi conflict + resolution vào BOARD.md Conflict Log
- **Không sửa file ngoài phạm vi files_owned** đã đăng ký

#### 3. Khi hoàn thành:
- **Update checkin file**: status → DONE, liệt kê files đã modified
- **Update BOARD.md**: chuyển từ Active → Recently Completed, xóa File Lock
- **Move checkin** sang `history/` (optional)

### Checkin File Format

```markdown
---
agent: {type}
task: {mô tả ngắn}
status: ACTIVE | DONE | BLOCKED | PAUSED
started: {YYYY-MM-DD HH:MM}
files_owned: [glob patterns agent sẽ sửa]
cto_directive: {# directive từ BOARD.md, nếu có}
---

## Why (Tại sao làm task này)
- the CTO yêu cầu: {tóm tắt yêu cầu gốc}
- Mục đích: {task này giúp gì cho sản phẩm/người dùng}
- Tác động: {nếu không làm thì sao}

## Progress
- [x] Step done
- [ ] Step pending

## Issues
- Lỗi gặp phải, đã fix chưa

## Files Modified
- path/to/file.ts (created/modified/deleted)

## Retrospective (ghi khi DONE)
- **Khó khăn:** {vấn đề gặp phải trong quá trình làm}
- **Bài học:** {điều rút ra, cần nhớ cho lần sau}
- **Cải thiện:** {việc chưa làm được, cần follow-up}
- **Memory cần update:** {có thông tin nào cần lưu vào memory cho sessions sau không}

## Knowledge Enrichment (ghi khi DONE — nếu có)
Sau mỗi task, agent tự hỏi và ghi lại:
- **Pattern mới?** → Nếu có pattern tái sử dụng → thêm vào <storage-project>/resources/skill-library/
- **Error pattern mới?** → Lỗi mới gặp + cách fix → thêm vào system-knowledge/common-error-patterns.md
- **API contract thay đổi?** → Endpoint mới/sửa → update system-knowledge/extension-api-contracts.md
- **CSS/Component mới?** → Reusable → thêm vào resources/css-library/ hoặc resources/snippets/
- **Data flow thay đổi?** → Flow mới/sửa → update system-knowledge/data-flow-maps.md
```

### BOARD.md Sections bắt buộc

1. **CTO Directives** — Ghi yêu cầu gốc của sếp Hảo, tóm tắt mục đích, trạng thái
2. **Active Agents** — Ai đang làm gì
3. **Recently Completed** — Lịch sử hoàn thành
4. **File Lock Registry** — Files đang bị lock
5. **Conflict Log** — Ghi conflict nếu có
6. **Retrospective Log** — Sau mỗi task: khó khăn, bài học, memory cần update

### Quy tắc File Lock
- Agent PHẢI đăng ký file patterns vào File Lock Registry trước khi sửa
- Nếu 2 agents cần cùng file → lead agent quyết định ai được lock
- Lock tự động hết hạn khi agent checkout (DONE)

### Checkout bắt buộc
- Agent PHẢI checkout khi hoàn thành: update checkin status → DONE, xóa file lock, chuyển vào Recently Completed
- Nếu agent mất kết nối (crash/timeout), agent tiếp theo PHẢI:
  1. Kiểm tra checkin file: nếu last updated > 30 phút → coi như agent đã ngừng
  2. Đóng checkin cũ (status → ABANDONED), ghi note lý do
  3. Xóa file lock của agent cũ
  4. Tiếp tục công việc hoặc nhận lại task

### Tổ chức thư mục theo ngày
Checkins tổ chức theo ngày: 
History cũng theo ngày: 
Giúp phân loại rõ ràng, dễ cleanup.

### Lead Agent phải:
- Khi dispatch subagent → include instruction: "Đọc BOARD.md trước khi làm, tạo checkin file"
- Khi nhận kết quả → update BOARD.md + đảm bảo subagent đã checkout

### Real-time BOARD Updates
- BOARD.md có thể được cập nhật bất cứ lúc nào bởi agent khác hoặc sếp Hảo
- Agent PHẢI đọc lại BOARD.md **trước mỗi bước quan trọng** (trước khi sửa file mới, trước khi commit)
- Nếu phát hiện thay đổi mới (directive mới, agent mới, conflict mới) → điều chỉnh kế hoạch ngay
- Không được bỏ qua cập nhật mới với lý do "đang bận làm việc"

### Tinh thần trợ giúp lẫn nhau (Team Spirit)
- Nếu agent phát hiện agent khác đang BLOCKED/gặp khó khăn trong Retrospective Log → **chủ động đề xuất giải pháp**
- Ghi đề xuất vào BOARD.md section Retrospective Log hoặc gửi message qua SendMessage
- Ví dụ: Agent B thấy Agent A gặp lỗi Prisma → Agent B ghi: "Đề xuất cho Agent A: thử chạy prisma-safe.ps1 generate"
- Khi nhận được trợ giúp → ghi nhận trong checkin file
- **Triết lý:** Mỗi agent là một thành viên công ty — chia sẻ kiến thức, giúp đỡ nhau, cùng hoàn thành mục tiêu chung

---

## Agent Teams (Optional)

For multi-session parallel collaboration, activate the `/nc:team` skill.
Not part of the default orchestration workflow. See `.claude/skills/team/SKILL.md` for templates, decision criteria, and spawn instructions.
