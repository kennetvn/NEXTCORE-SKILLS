# Post-Fix Deploy Flow (BẮT BUỘC)

> Quy trình sau khi fix bug hoặc implement feature cần deploy.
> Agent PHẢI tuân theo đúng thứ tự. Không bỏ bước.

## Khi nào áp dụng

- Sau khi fix bug trên code website (example-homestay.com)
- Sau khi implement feature mới cho website
- Sau khi sửa API routes
- Sau khi thay đổi Prisma schema
- **KHÔNG áp dụng:** Chrome extensions, docs, agent configs, local-only changes

## Flow

```
1. FIX CODE
   ↓
2. BUILD LOCAL (npm run build)
   ↓ pass
3. BACKUP DB (VPS → localhost)
   ↓
4. DEPLOY (zero-downtime)
   ↓
5. HEALTH CHECK (HTTP 200 + logs)
   ↓ pass              ↓ fail
6. VERIFY PRODUCTION   → ROLLBACK → quay lại bước 1
   ↓ pass
7. COMMIT + PUSH (tự động)
```

## Chi tiết từng bước

### 1. Fix Code
- Fix bug hoặc implement feature
- TypeScript compile check: `npx tsc --noEmit` — chỉ cần 0 errors trong file mình sửa
- Không cần fix pre-existing errors ở file khác

### 2. Build Local
```bash
cd <website-project>/example-homestay.com && npm run build
```
- Build PHẢI pass. Không deploy code lỗi.
- Nếu build fail → fix → build lại

### 3. Backup DB Production
**BẮT BUỘC trước MỌI deploy.** Download về localhost.

```bash
SSH_CMD="ssh -F /dev/null -i ~/.ssh/id_ed25519 root@<YOUR_VPS_IP>"
SCP_CMD="scp -F /dev/null -i ~/.ssh/id_ed25519"
BACKUP_NAME="pre-deploy-$(date +%y%m%d-%H%M).sql"
VPS_PATH="/www/wwwroot/example-homestay.com"
LOCAL_BACKUP="<storage-project>/agent-infra/backups"

# Parse DB credentials from DATABASE_URL trong .env
$SSH_CMD "DB_URL=\$(grep DATABASE_URL $VPS_PATH/.env | cut -d'\"' -f2) && \
  DB_USER=\$(echo \$DB_URL | sed 's|mysql://\([^:]*\):.*|\1|') && \
  DB_PASS=\$(echo \$DB_URL | sed 's|mysql://[^:]*:\([^@]*\)@.*|\1|') && \
  DB_NAME=\$(echo \$DB_URL | sed 's|.*/\([^?]*\).*|\1|') && \
  mysqldump -u \$DB_USER -p\$DB_PASS \$DB_NAME > /tmp/$BACKUP_NAME && \
  echo 'DB Backup OK'"

# Download về localhost
$SCP_CMD root@<YOUR_VPS_IP>:/tmp/$BACKUP_NAME $LOCAL_BACKUP/$BACKUP_NAME

# Verify size (phải > 1MB, nếu nhỏ hơn có thể dump lỗi)
ls -lh $LOCAL_BACKUP/$BACKUP_NAME
```

**File backup KHÔNG được commit lên git** (đã có trong .gitignore).

### 4. Deploy
```bash
cd <website-project>/example-homestay.com && bash scripts/deploy.sh --skip-build
```
- Deploy script đã có: pre-stage deps → atomic swap → cluster reload
- Zero-downtime nhờ PM2 cluster mode (2 instances, rolling reload)

### 5. Health Check
Deploy script tự động check HTTP 200. Nếu cần kiểm tra thêm:
```bash
SSH_CMD="ssh -F /dev/null -i ~/.ssh/id_ed25519 root@<YOUR_VPS_IP>"

# HTTP status
$SSH_CMD "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000"

# PM2 logs (5 dòng gần nhất, không lỗi)
$SSH_CMD "pm2 logs homestay-lamdong --lines 5 --nostream"

# PM2 status (2 instances online)
$SSH_CMD "pm2 ls | grep homestay-lamdong"
```

**Nếu FAIL:**
```bash
# Rollback
$SSH_CMD "cd /www/wwwroot/example-homestay.com && \
  [ -d .next-old ] && rm -rf .next && mv .next-old .next && \
  [ -d src.old ] && rm -rf src && mv src.old src && \
  pm2 reload homestay-lamdong"
```
→ Quay lại bước 1, fix lại.

### 6. Verify Production
- Kiểm tra feature/fix trên production URL thực tế
- Nếu có Chrome DevTools MCP / Playwright → screenshot + verify
- Nếu không → `curl` API endpoints hoặc báo user tự kiểm tra

### 7. Commit + Push (Tự động)
Sau khi verify OK:
```bash
# Tạo branch nếu đang ở main (theo git-workflow.md)
# Stage changed files
git add [specific files]
git commit -m "fix(scope): mô tả ngắn

Giải thích WHY, không chỉ WHAT."

# Push
git push origin [branch]
```

**Quy tắc commit:**
- Dùng conventional commits: `fix()`, `feat()`, `refactor()`
- Body giải thích WHY
- Không commit: .env, backups, temp files, node_modules

## Trường hợp đặc biệt

### Có DB migration
Thêm bước giữa 4 và 5:
```bash
$SSH_CMD "cd /www/wwwroot/example-homestay.com && npx prisma migrate deploy"
```
KHÔNG dùng `prisma db push` trên production.

### Fix nhỏ (chỉ sửa 1-2 file, không đổi logic phức tạp)
- Vẫn PHẢI backup DB
- Có thể skip deploy-gate nếu không thay đổi schema/API
- Vẫn PHẢI health check + verify

### Deploy thất bại nhiều lần (>2 lần)
- Dừng lại, không retry thêm
- Kiểm tra VPS logs chi tiết: `pm2 logs --lines 50`
- Báo user tình trạng + đề xuất giải pháp
- Khôi phục DB từ backup nếu cần

## Backup Retention

| Thư mục | Giữ lại | Dọn |
|---------|---------|-----|
| `<storage-project>/agent-infra/backups/` | 5 bản gần nhất | Xóa bản cũ hơn |
| VPS `/tmp/pre-deploy-*` | 3 bản gần nhất | Xóa bản cũ hơn |

Agent nên dọn backup cũ khi tạo backup mới.

## Tóm tắt cho Agent

Khi user nói "fix xong rồi" hoặc sau khi agent fix xong code website:

1. ✅ Build pass?
2. ✅ Backup DB → localhost?
3. ✅ Deploy OK?
4. ✅ Health check 200?
5. ✅ Verify trên production?
6. ✅ Commit + push?

Nếu bất kỳ bước nào fail → rollback + fix → lặp lại từ bước 1.
