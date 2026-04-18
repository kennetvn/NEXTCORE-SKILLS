---
description: Spawn FE+BE pair team for feature $ARGUMENTS (parallel worktree, plan approval)
---

Spawn Agent Team với 2 fullstack-developer teammates (1 BE + 1 FE) để build feature sau:

**Feature spec:** $ARGUMENTS

## Execute ngay, không hỏi lại

1. **Phân tích feature** — suy ra file ownership:
   - `dev-be` owns: `src/app/api/**`, `src/lib/**`, `prisma/**`
   - `dev-fe` owns: `src/app/dashboard/**/*.tsx`, `src/components/**`, `*.css`

2. **Call `TeamCreate`** với `team_name` slug từ feature description.

3. **Call `TaskCreate` 3 lần**:
   - Task BE: implement backend theo spec, expose API contract
   - Task FE: build UI consume API contract từ BE
   - Task tester: `addBlockedBy: [be_id, fe_id]`, run vitest + tsc + smoke

4. **Spawn 2 teammates parallel** qua `Agent`:
   ```
   Agent(subagent_type: "fullstack-developer", name: "dev-be",
         model: "opus", isolation: "worktree", run_in_background: true,
         prompt: <BE task description + file ownership + contract-first protocol + CK Context>)

   Agent(subagent_type: "fullstack-developer", name: "dev-fe",
         model: "opus", isolation: "worktree", run_in_background: true,
         prompt: <FE task description + file ownership + consume BE contract + CK Context>)
   ```

5. **Plan approval**: mỗi dev `ExitPlanMode` → lead approve qua `plan_approval_response`

6. **Monitor TaskCompleted**. Khi cả 2 dev tasks completed:
   - Spawn `Agent(subagent_type: "tester", name: "tester", model: "opus")`
   - Tester chạy `npx tsc --noEmit`, `npx vitest run`, smoke endpoints

7. **Merge worktrees** → main. Resolve conflicts nếu có.

8. **Shutdown** via `SendMessage(type: "shutdown_request")` x 3, then `TeamDelete`.

9. **Report**: "Feature shipped. N tests pass. Files changed: M. Commits: K."

## CK Context (include trong mọi spawn prompt)
- Work dir: <YOUR_WORKSPACE>/project
- Project: <website-project>/example-homestay.com (hoặc infer từ feature)
- Reports: plans/reports/
- Branch: main
- Commits: conventional (feat:, fix:, refactor:)
- Read `.claude/rules/team-coordination-rules.md` trước khi start
- Đọc BOARD `<storage-project>/agent-infra/board/BOARD.md` trước, tạo checkin

## Prereqs
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` enabled (đã có trong settings.json)
- CLI terminal (không VSCode extension)
- Git clean

Nếu `TeamCreate` returns error → STOP + báo sếp restart CLI.
