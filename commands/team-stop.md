---
description: Shutdown current Agent Team gracefully + cleanup
---

Emergency/graceful shutdown team hiện tại.

## Execute ngay

1. **Check teams đang chạy**: list `~/.claude/teams/*/config.json`

2. Nếu có team active:
   - Với mỗi teammate: `SendMessage(recipient: "<name>", type: "shutdown_request")`
   - Đợi `shutdown_response` hoặc timeout 30s
   - Call `TeamDelete` (no params — tự dùng current team context)

3. **Cleanup worktrees** nếu có:
   ```bash
   git worktree list
   # Cho mỗi worktree không phải main:
   git worktree remove <path> --force
   ```

4. **Report**: "Team <name> shutdown. Worktrees cleaned: N. Code changes trong main: <list commits> hoặc 'uncommitted changes in <paths>'."

## Lưu ý
- Code changes trong worktrees đã commit → vẫn còn trên branch đó, không mất
- Uncommitted changes → nên cân nhắc commit trước khi force remove
- `TeamDelete` không dọn branches, chỉ dọn team config + worktrees
