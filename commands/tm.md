---
description: Team cheat sheet + list teams đang chạy + status tasks
---

Hiển thị cheat sheet ngắn cho Agent Team commands + status teams hiện tại.

## Execute ngay

1. **In bảng cheat sheet**:

```
╔═════════════════════════════════════════════════════════════════╗
║ AGENT TEAM — SHORT COMMANDS CHEAT SHEET                         ║
╠═════════════════════════════════════════════════════════════════╣
║ /pair <feature>      → FE + BE parallel team (worktree)         ║
║                        vd: /pair "add VIP expiry reminder"      ║
║                                                                  ║
║ /ux-audit <feature>  → Engineer + UX tester iterative loop      ║
║                        vd: /ux-audit "PDF export button"        ║
║                                                                  ║
║ /team-stop           → Shutdown team hiện tại + cleanup         ║
║                                                                  ║
║ /tm                  → Cheat sheet này + status                 ║
╠═════════════════════════════════════════════════════════════════╣
║ Built-in cũng dùng được:                                        ║
║ /nc:team cook <spec> --devs N --worktree                        ║
║ /nc:team review <scope> --reviewers N                           ║
║ /nc:team debug <issue> --debuggers N                            ║
║ /nc:team research <topic> --researchers N                       ║
╚═════════════════════════════════════════════════════════════════╝
```

2. **List teams đang chạy**: 
   ```bash
   ls ~/.claude/teams/ 2>/dev/null
   ```

3. Nếu có teams → cho mỗi team, hiện:
   - Tên team
   - Số teammates đang ACTIVE
   - Task count: pending / in_progress / completed
   - Messages gần nhất (tail 3)

4. **Observe realtime** (gợi ý):
   ```bash
   # Messages stream
   watch -n 2 'tail -30 ~/.claude/teams/<team>/messages.jsonl'

   # Task status
   watch -n 2 'cat ~/.claude/teams/<team>/tasks.json | jq ".tasks[] | \"\\(.status) \\(.owner)\\t\\(.subject)\""'

   # UX reports (scenario ux-audit)
   watch -n 1 'ls -lt plans/reports/ux-audit-*.md 2>/dev/null | head -5'
   ```

5. Nếu không team nào đang chạy → in: "Chưa có team active. Dùng /pair hoặc /ux-audit để bắt đầu."
