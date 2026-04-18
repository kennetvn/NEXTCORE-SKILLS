---
description: Spawn Engineer+UX iterative team for feature $ARGUMENTS (realtime audit loop)
---

Spawn Agent Team 2 members: 1 engineer + 1 UX tester làm việc iteratively. Engineer build, UX tester audit, feedback realtime, loop cho đến khi approved.

**Feature spec:** $ARGUMENTS

## Execute ngay

1. **Call `TeamCreate`** với slug từ feature (prefix "ux-").

2. **Call `TaskCreate` x 2**:
   - Engineer task: "Build <feature> + iterate trên UX feedback. Fix NGAY khi nhận SendMessage từ ux-tester. Mark completed khi 'APPROVED'."
   - UX-tester task: "Audit <feature> across 7 dimensions sau mỗi engineer commit. Write round report plans/reports/ux-audit-round-N.md. SendMessage engineer feedback priority (CRITICAL/IMPORTANT/MODERATE). Mark completed khi zero issues."

3. **Spawn engineer**:
   ```
   Agent(subagent_type: "fullstack-developer", name: "engineer",
         model: "opus", isolation: "worktree", run_in_background: true,
         prompt: <engineer role + iterate protocol + CK Context>)
   ```

4. **Spawn ux-tester** (read-only, không edit code):
   ```
   Agent(subagent_type: "ui-ux-designer", name: "ux-tester",
         model: "opus", run_in_background: true,
         prompt: <UX audit 7 dimensions + SendMessage feedback loop + CK Context>)
   ```

5. **Monitor** team messages + reports:
   - UX-tester round reports xuất hiện trong `plans/reports/ux-audit-round-*.md`
   - Nếu loop >5 rounds → lead intervene, review latest report, refine spec

6. **Hoàn thành** khi ux-tester gửi "APPROVED ✓":
   - Engineer merge worktree → main
   - Lead `shutdown_request` cả 2 + `TeamDelete`
   - Report: "Feature approved sau N rounds. Issues fixed: CRITICAL=X, IMPORTANT=Y."

## UX audit 7 dimensions (cho ux-tester prompt)
1. **Accessibility**: ARIA labels, focus ring, keyboard nav (Tab/Enter/Esc)
2. **Responsive**: <480px không overflow, touch target ≥44px
3. **Loading state**: disabled + spinner khi async
4. **Empty state**: clear message + disabled action khi no data
5. **Error state**: toast/message khi fail, retry option
6. **Contrast**: WCAG AA (4.5:1 text, 3:1 UI)
7. **Visual hierarchy**: không chen ngang existing UI, icon consistent

## CK Context (include trong prompts)
- Work dir: F:/workspace/project
- Project: <website-project>/example-homestay.com
- Reports: plans/reports/
- Branch: main
- Read `.claude/rules/team-coordination-rules.md` + `no-inline-styles.md`

## Prereqs
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` enabled
- CLI terminal
- Git clean

Nếu `TeamCreate` error → STOP + báo sếp restart CLI.
