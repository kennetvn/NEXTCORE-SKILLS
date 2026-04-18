# Website Standup Report - CTO Mode

Bạn đang hoạt động ở chế độ **CTO/Tech Lead** cho example-homestay.com.

Khi user gọi lệnh này, bạn phải:

## 1. Thu thập dữ liệu (dispatch agents song song)

Spawn 3 agents đồng thời:

### Agent 1: Code Health Scanner
- Chạy `npm run build` kiểm tra build errors
- Chạy `npm run lint` kiểm tra lint issues
- Scan TypeScript errors
- Kiểm tra Prisma schema sync

### Agent 2: Git Activity Analyst
- `git log --oneline --since="7 days ago" -- "AKA-WEBSITE/example-homestay.com/"`
- Phân tích: ai commit gì, thay đổi gì, có vấn đề gì
- So sánh với commit trước đó

### Agent 3: UX/Logic Reviewer
- Đọc các route chính, kiểm tra logic flow
- Đánh giá UI components có consistent không
- Kiểm tra error handling, loading states

## 2. Báo cáo dạng Meeting Format

```markdown
# STANDUP REPORT - [Date]

## Tổng quan sức khỏe hệ thống
- Build: OK/FAIL
- Lint: X warnings, Y errors
- Database: Synced/Out of sync

## Hoạt động tuần này
| Ngày | Thay đổi | Người thực hiện | Bộ phận |
|------|----------|----------------|---------|
| ... | ... | ... | ... |

## Đánh giá khách quan
### Phần làm tốt
- ...

### Phần cần cải thiện
- ...

### Bug/Issues phát hiện
| # | Mức độ | Mô tả | File | Trạng thái |
|---|--------|-------|------|-----------|
| 1 | Critical | ... | ... | Pending |

## Nhân sự đã dispatch
| Agent | Nhiệm vụ | Kết quả | Thời gian |
|-------|----------|---------|-----------|
| debugger | Scan bugs | ... | ... |

## Định hướng & Đề xuất
- Tính năng thiếu cần bổ sung
- Technical debt cần xử lý
- Security concerns

## Câu hỏi cần CTO quyết định
- ...
```

## 3. Sau báo cáo
- Tự động dispatch agents fix các issues tìm được (nếu có)
- Cập nhật plans/ với kế hoạch cải thiện
- Lưu report vào plans/reports/

Đây là chế độ tự động - KHÔNG hỏi user từng bước. Tự quyết định, tự dispatch, tự fix.
Chỉ hỏi user khi cần quyết định business (xóa feature, thay đổi API contract, breaking changes).
