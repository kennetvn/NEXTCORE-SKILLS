# Git Workflow — Enterprise-Grade Version Control

## Golden Rules
1. **KHÔNG sửa code trên main** — luôn tạo branch trước
2. **Mỗi thay đổi = 1 commit** có mô tả rõ ràng (dù nhỏ nhất)
3. **Tag trước khi sửa component** — baseline để rollback
4. **Commit TRƯỚC khi sửa thêm** — không để nhiều thay đổi chồng chéo

---

## Branch Strategy

```
main (stable, production)
  └─ ext/approve-post-optimize    ← feature branch
  └─ web/vip-renewal-fix          ← feature branch
  └─ ext/blacklist-cleanup        ← feature branch
```

### Branch Naming
```
{scope}/{short-description}

Scopes:
  ext/    → Chrome Extensions (<extensions-project>/)
  web/    → Website (AKA-WEBSITE/example-homestay.com)
  api/    → PHP API (AKA-WEBSITE/api.example.com)
  infra/  → DevOps, CI/CD, scripts
  docs/   → Documentation only
```

### Trước khi code BẤT KỲ thay đổi nào:
```bash
# 1. Tạo branch từ main
git checkout main
git pull origin main
git checkout -b ext/approve-post-optimize

# 2. Tag baseline (nếu là component quan trọng)
git tag -a ext-approve-v2.0-pre-optimize -m "Baseline before optimization"

# 3. Code, commit từng bước nhỏ (xem Commit Convention bên dưới)

# 4. Khi xong — merge về main
git checkout main
git merge ext/approve-post-optimize

# 5. Tag version mới
git tag -a ext-approve-v2.1 -m "Optimized: remove Lark, reduce polling"

# 6. Push
git push origin main --tags
```

---

## Commit Convention

### Format
```
{type}({scope}): {mô tả ngắn}

{body — giải thích WHY, không chỉ WHAT}

{footer — breaking changes, references}
```

### Types
| Type | Khi nào | Ví dụ |
|------|---------|-------|
| `feat` | Thêm tính năng mới | `feat(ext): add auth header to API calls` |
| `fix` | Sửa bug | `fix(ext): polling timeout after 20 retries` |
| `refactor` | Đổi code nhưng không đổi behavior | `refactor(ext): remove Lark host permission` |
| `perf` | Tối ưu performance | `perf(ext): increase alarm interval 5s→30s` |
| `chore` | Cleanup, config, tooling | `chore: remove clone-version.sh` |
| `docs` | Documentation | `docs: add extension architecture report` |
| `security` | Security fix | `security(api): add CORS origin validation` |

### Scopes (for this repo)
| Scope | Covers |
|-------|--------|
| `ext` | <extensions-project>/* |
| `ext-approve` | Specifically APPROVE-POST-AI-AGENT |
| `ext-blacklist` | Specifically BLACKLIST extension |
| `web` | example-homestay.com |
| `api` | api.example.com |
| `vip` | VIP system (cross-cutting) |
| `css` | Design system / CSS |

### Commit Body — BẮT BUỘC ghi WHY
```bash
# BAD — chỉ nói WHAT
git commit -m "refactor(ext): change polling interval"

# GOOD — giải thích WHY
git commit -m "$(cat <<'EOF'
perf(ext-approve): increase data sync interval 5s→30s

VIP/Blacklist data thay đổi không thường xuyên (vài lần/ngày)
nhưng extension fetch mỗi 5s = 36 req/phút, gây load không cần thiết.
30s vẫn đủ nhanh để detect blacklist mới.
EOF
)"
```

---

## Tag Convention

### Khi nào tag
- **Trước khi bắt đầu optimize** component → `{component}-v{X}-pre-{task}`
- **Sau khi hoàn thành** thay đổi stable → `{component}-v{X}.{Y}`
- **Trước khi deploy** lên production → `deploy-{date}`

### Tag Format
```
# Component version
ext-approve-v2.0              ← stable release
ext-approve-v2.1              ← after optimization
ext-blacklist-v1.3            ← blacklist extension

# Pre-change baseline
ext-approve-v2.0-pre-optimize ← before starting work

# Deploy marker
deploy-20260406               ← production deploy
```

### Xem và rollback
```bash
# Xem tất cả tags
git tag -l "ext-approve-*"

# Xem thay đổi giữa 2 versions
git diff ext-approve-v2.0..ext-approve-v2.1 -- <extensions-project>/NEXTCORE-APPROVE-POST-AI-AGENT/

# Xem log giữa 2 versions
git log ext-approve-v2.0..ext-approve-v2.1 --oneline

# Rollback 1 file về version cũ
git checkout ext-approve-v2.0 -- <extensions-project>/.../V2/postAnalyzer/aiEngine.js

# Rollback toàn bộ component
git checkout ext-approve-v2.0 -- <extensions-project>/NEXTCORE-APPROVE-POST-AI-AGENT/V2/

# Push tags lên GitHub (backup)
git push origin --tags
```

---

## Quy trình cho Claude Code Agents

### Trước khi sửa code:
1. Kiểm tra đang ở branch nào (`git branch --show-current`)
2. Nếu đang ở `main` → tạo feature branch trước
3. Tag baseline nếu sửa component quan trọng

### Trong khi code:
4. Commit **từng bước nhỏ** — mỗi thay đổi logic = 1 commit
5. Commit message PHẢI có body giải thích WHY
6. KHÔNG gộp nhiều thay đổi không liên quan vào 1 commit

### Sau khi xong:
7. Review diff toàn bộ branch: `git diff main...HEAD`
8. Merge về main (hoặc tạo PR nếu cần review)
9. Tag version mới
10. Push main + tags

### Khi gặp lỗi:
- **Lỗi nhỏ** (1-2 file) → `git checkout {tag} -- {file}` rollback file cụ thể
- **Lỗi lớn** (toàn bộ feature) → `git checkout main` bỏ branch, tag vẫn còn
- **KHÔNG dùng** `git reset --hard` hoặc `git push --force` trừ khi CTO cho phép

---

## Ví dụ thực tế: Optimize Approve Post Extension

```bash
# 1. Chuẩn bị
git checkout main && git pull
git checkout -b ext/approve-post-optimize
git tag -a ext-approve-v2.0-pre-optimize -m "Baseline before optimization"

# 2. Bước 1: Remove Lark
# ... sửa manifest.json, xóa lark references ...
git add -A && git commit -m "$(cat <<'EOF'
refactor(ext-approve): remove Lark host permission

Lark API không còn được gọi trực tiếp từ extension.
Mọi data đã migrate sang example-homestay.com API.
host_permissions chỉ cần facebook.com + example-homestay.com.
EOF
)"

# 3. Bước 2: Optimize polling
# ... sửa background.js alarm interval ...
git add -A && git commit -m "$(cat <<'EOF'
perf(ext-approve): increase data sync interval 5s→30s

VIP/Blacklist data thay đổi vài lần/ngày, 5s polling quá aggressive.
Giảm từ 36 req/phút xuống 2 req/phút. Vẫn đủ responsive.
EOF
)"

# 4. Merge + tag
git checkout main
git merge ext/approve-post-optimize
git tag -a ext-approve-v2.1 -m "Optimized: remove Lark, reduce polling"
git push origin main --tags
```
