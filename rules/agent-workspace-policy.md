# Agent Workspace Policy — Quy định lưu trữ file tạm

## Rule: KHÔNG để file tạm ở root hoặc thư mục project

Mọi file tạm (screenshots, logs, test data, snapshots) PHẢI lưu vào:
```
<storage-project>/agent-infra/workspace/
├── screenshots/     ← ảnh chụp màn hình, UI captures
├── debug-logs/      ← console logs, network dumps
├── temp/            ← mọi file tạm khác
```

## Đặt tên file

Format: `{context}-{YYMMDD}-{HHMM}-{mô-tả}.{ext}`

```
screenshots/vip-260405-1012-dashboard-overview.png
debug-logs/ext-approve-260402-0800-console.log
temp/test-260406-2100-overlap-check.js
```

## Khi nào áp dụng

| Tình huống | Lưu vào |
|-----------|---------|
| Agent chụp screenshot debug | `agent-workspace/screenshots/` |
| Playwright/Chrome DevTools MCP tạo log | `agent-workspace/debug-logs/` |
| Agent tạo file test tạm, data export | `agent-workspace/temp/` |
| QA screenshots cần lưu lâu dài | `<storage-project>/agent-infra/qa-screenshots/` (không phải workspace) |
| Source code, config, docs | Thư mục project tương ứng (KHÔNG workspace) |

## Playwright MCP / Chrome DevTools

Khi dùng Playwright MCP hoặc Chrome DevTools MCP:
- Screenshots → `<storage-project>/agent-infra/workspace/screenshots/`
- Console logs → `<storage-project>/agent-infra/workspace/debug-logs/`
- Page snapshots → `<storage-project>/agent-infra/workspace/debug-logs/`
- KHÔNG để output mặc định vào `.playwright-mcp/` hoặc root

## Dọn dẹp

- Agent PHẢI dọn file tạm của mình khi checkout (DONE)
- Files > 7 ngày trong `temp/` → xóa tự do
- Files > 30 ngày trong `screenshots/`, `debug-logs/` → review trước khi xóa
- Khi bắt đầu session mới, kiểm tra workspace — xóa file cũ > 7 ngày

## Vi phạm

Nếu phát hiện file tạm ở root hoặc thư mục project:
1. Di chuyển vào `agent-workspace/` đúng subfolder
2. Ghi note trong checkin file
3. Không commit file tạm lên git
