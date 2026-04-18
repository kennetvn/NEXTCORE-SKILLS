---
description: Deploy Next.js, PHP, or Python apps to VPS <YOUR_VPS_IP> via your hosting panel. Safe deploy with backup, rollback, health check. Use when deploying or troubleshooting production.
auto_execution_mode: 1
---

# Safe VPS Deployment

> **Nguyên tắc vàng:** Code đi lên, Data không đi lên. Production DB và uploads KHÔNG BAO GIỜ bị ghi đè.

## MANDATORY Pre-deploy Gate
**BẮT BUỘC chạy trước MỌI deploy:**
```bash
cd <website-project>/example-homestay.com && bash .agent/scripts/deploy-gate.sh
```
Nếu gate FAIL → KHÔNG được deploy. Fix issues trước.
Script kiểm tra: Prisma schema sync, build OK, DB ↔ code match, no secrets.

## Server Info
- **IP:** <YOUR_VPS_IP> | **Panel:** your hosting panel | **Root:** `/var/www/`
- **SSH:** `ssh -F /dev/null -i ~/.ssh/id_ed25519 root@<YOUR_VPS_IP>` (bypass BOM config)

## Services

| App | Type | PM2 Name | Port |
|-----|------|----------|------|
| example-homestay.com | Next.js | `homestay-lamdong` | 3000 |
| api.example.com | PHP | PHP-FPM (your hosting panel) | — |

## $ARGUMENTS
Deploy target (optional): homestay | api | all

## Deploy Next.js (example-homestay.com)

### Variables
```bash
SSH_CMD="ssh -F /dev/null -i ~/.ssh/id_ed25519 root@<YOUR_VPS_IP>"
SCP_CMD="scp -F /dev/null -i ~/.ssh/id_ed25519"
VPS_PATH="/var/www/example-homestay.com"
LOCAL_PATH="AKA-WEBSITE/example-homestay.com"
```

### Step 0: Backup Database (BẮT BUỘC)
```bash
$SSH_CMD "mysqldump -u homestay_user -p'\$(grep DB_PASSWORD $VPS_PATH/.env | cut -d= -f2)' homestay_lamdong > /tmp/pre_deploy_\$(date +%Y%m%d_%H%M).sql && echo 'DB Backup OK'"
```

### Step 1: Build Local
```bash
cd "$LOCAL_PATH" && npm run build
```
> Build PHẢI pass 0 errors. Không deploy code lỗi.

### Step 2: Backup Code Cũ trên VPS
```bash
$SSH_CMD "cp -r $VPS_PATH/src $VPS_PATH/src.backup && cp -r $VPS_PATH/.next $VPS_PATH/.next.backup"
```

### Step 3: Upload Build + Source
Upload `.next` (pre-built) + source files. KHÔNG upload `node_modules`, `.env`, `.git`, `public/uploads/`.

```bash
# Upload .next build output
$SCP_CMD -r .next root@<YOUR_VPS_IP>:$VPS_PATH/

# Upload source + configs
$SCP_CMD -r src root@<YOUR_VPS_IP>:$VPS_PATH/
$SCP_CMD package.json root@<YOUR_VPS_IP>:$VPS_PATH/
$SCP_CMD next.config.ts root@<YOUR_VPS_IP>:$VPS_PATH/
$SCP_CMD ecosystem.config.js root@<YOUR_VPS_IP>:$VPS_PATH/
$SCP_CMD -r prisma root@<YOUR_VPS_IP>:$VPS_PATH/
```

### Step 4: Install + Prisma Generate + Restart
```bash
$SSH_CMD "cd $VPS_PATH && rm -f schema.prisma && npm install --production && npx prisma generate && pm2 restart homestay-lamdong --update-env"
```
> `rm -f schema.prisma`: xóa stale cache ở root (known issue)

### Step 5: Health Check (BẮT BUỘC)
```bash
$SSH_CMD "sleep 5 && curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 && echo '' && pm2 logs homestay-lamdong --lines 5 --nostream"
```
Expected: HTTP 200, no errors.

### Step 6: Rollback (nếu lỗi)
```bash
$SSH_CMD "cd $VPS_PATH && rm -rf src .next && mv src.backup src && mv .next.backup .next && pm2 restart homestay-lamdong"
```

## Schema Migration (chỉ khi có DB changes)
```bash
$SSH_CMD "cd $VPS_PATH && npx prisma migrate deploy"
```
> KHÔNG dùng `prisma db push` trên production. Chỉ `migrate deploy`.

## Upload Rules

| Thành phần | Upload? | Lý do |
|-----------|---------|-------|
| `src/`, `prisma/`, configs | ✅ Lên VPS | Code release |
| `.next/` (pre-built) | ✅ Lên VPS | Tránh build trên VPS (chậm, RAM thấp) |
| `node_modules/` | ❌ | `npm install` trên VPS |
| `.env`, `.env.local` | ❌ | Production env riêng |
| `public/uploads/` | ❌ | User-generated content |
| `.git/` | ❌ | Không cần trên VPS |

## References
- Safe deploy guide: `.agent/workflows/safe-deploy.md`
- VPS skill: `<storage-project>/resources/skill-library/vps-deployment/SKILL.md`
- DevOps: `<storage-project>/resources/skill-library/devops-automation/SKILL.md`
