---
description: Backup strategy + disaster recovery drills. Use when designing backup policy, testing restore (the only test that matters), planning RPO/RTO targets, or implementing 3-2-1 backups for databases/files/configs.
auto_execution_mode: 1
---

# Backup + Recovery Skill

A backup that's never been restored is not a backup. Test restores quarterly minimum.

## RPO + RTO

- **RPO** (Recovery Point Objective): how much data loss is acceptable?
- **RTO** (Recovery Time Objective): how long can we be down?

Drives strategy:

| RPO | RTO | Strategy |
|---|---|---|
| 24h | 24h | Nightly dump, manual restore |
| 1h | 4h | Hourly snapshot + replication, scripted restore |
| <5min | <30min | Streaming replication + automated failover |
| Zero | Seconds | Multi-region active-active |

Never promise 5-min RPO without spending the engineering to deliver it.

## 3-2-1 rule

- **3** copies of data (1 prod + 2 backups)
- **2** different storage media types (e.g., disk + object storage)
- **1** off-site (different region or provider)

Example:
- Prod: PostgreSQL on VPS in SG
- Backup 1: Daily `pg_dump` to local disk (fast restore)
- Backup 2: Hourly WAL → S3 in different region (disaster recovery)

## Database backups

### PostgreSQL

```bash
# Logical backup (pg_dump) — portable, slow on large DBs
pg_dump -Fc -f /backups/myapp-$(date +%F).dump dbname

# Restore
pg_restore -d dbname_new /backups/myapp-2026-04-18.dump

# Continuous archiving (WAL streaming) — minimal RPO
# postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = 'aws s3 cp %p s3://wal-archive/%f'

# Point-in-time recovery (PITR)
# 1. Restore base backup
# 2. Replay WAL up to target time
```

### MySQL / MariaDB

```bash
# Logical
mysqldump --single-transaction --routines --triggers dbname > /backups/myapp-$(date +%F).sql
gzip /backups/myapp-*.sql

# Point-in-time: enable binlog
# my.cnf: log-bin = mysql-bin

# Restore
mysql dbname < /backups/myapp-2026-04-18.sql
mysqlbinlog --start-datetime="2026-04-18 14:00:00" mysql-bin.* | mysql dbname
```

### MongoDB

```bash
mongodump --db myapp --archive=/backups/myapp-$(date +%F).archive --gzip
mongorestore --archive=/backups/myapp-2026-04-18.archive --gzip --drop
```

## File backups

### rsync (incremental, simple)

```bash
# Pull from server to backup host
rsync -avz --delete --backup --backup-dir=/backups/diff/$(date +%F) \
  user@server:/var/www/uploads/ /backups/uploads/

# --backup keeps deleted files in dated dir; great for ransomware recovery
```

### restic (deduped, encrypted, S3-backed)

```bash
# Init repo (once)
export RESTIC_PASSWORD_FILE=/root/.restic-pass
restic -r s3:s3.amazonaws.com/mybucket init

# Backup
restic -r s3:... backup /var/www/uploads /etc /home

# List snapshots
restic -r s3:... snapshots

# Restore
restic -r s3:... restore latest --target /restored

# Prune old (keep daily 7d, weekly 4w, monthly 12m)
restic -r s3:... forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
```

## Config / IaC backups

- Terraform state → already in S3 with versioning (just enable bucket versioning)
- k8s manifests → git is the backup
- Server configs (`/etc/`) → rsync or `etckeeper` (git-tracks /etc)
- Secrets → backup the secret manager (AWS SM, Vault) separately, encrypted

## Object storage versioning + lifecycle

```bash
# AWS S3 versioning (one-time)
aws s3api put-bucket-versioning --bucket mybucket --versioning-configuration Status=Enabled

# Lifecycle: move to Glacier after 90d, delete after 1y
cat <<EOF > lifecycle.json
{
  "Rules": [{
    "ID": "archive-old",
    "Status": "Enabled",
    "Filter": {},
    "Transitions": [{"Days": 90, "StorageClass": "GLACIER"}],
    "Expiration": {"Days": 365}
  }]
}
EOF
aws s3api put-bucket-lifecycle-configuration --bucket mybucket --lifecycle-configuration file://lifecycle.json
```

## Backup script template

```bash
#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=/backups
TIMESTAMP=$(date +%Y%m%d-%H%M)
S3_BUCKET=s3://myorg-backups
RETAIN_DAYS=30

log() { echo "[$(date +%FT%T)] $*"; }

log "Starting backup $TIMESTAMP"

# 1. DB
pg_dump -Fc dbname | gzip > "$BACKUP_DIR/db-$TIMESTAMP.dump.gz"
log "DB dump: $(du -h "$BACKUP_DIR/db-$TIMESTAMP.dump.gz" | cut -f1)"

# 2. Files
tar -czf "$BACKUP_DIR/files-$TIMESTAMP.tar.gz" /var/www/uploads /etc/myapp
log "Files dump: $(du -h "$BACKUP_DIR/files-$TIMESTAMP.tar.gz" | cut -f1)"

# 3. Upload to S3 (different region for off-site)
aws s3 cp "$BACKUP_DIR/db-$TIMESTAMP.dump.gz" "$S3_BUCKET/db/" --storage-class STANDARD_IA
aws s3 cp "$BACKUP_DIR/files-$TIMESTAMP.tar.gz" "$S3_BUCKET/files/" --storage-class STANDARD_IA
log "S3 upload done"

# 4. Local retention
find "$BACKUP_DIR" -name "*.gz" -mtime +$RETAIN_DAYS -delete
log "Pruned local backups older than $RETAIN_DAYS days"

# 5. Verify (smoke test)
LATEST=$(ls -t "$BACKUP_DIR"/db-*.dump.gz | head -1)
gunzip -t "$LATEST" || { log "FAIL: latest backup corrupt"; exit 1; }
log "Verified $LATEST"

log "Backup complete"
```

Run via systemd timer (see `nc-linux-sysadmin`).

## Restore drill (mandatory quarterly)

The drill, not the backup, is what saves you. Schedule it.

```
1. Spin up fresh VM (or namespace in k8s)
2. Pull latest backup from S3
3. Restore DB to fresh instance
4. Restore files to fresh path
5. Start app pointing to restored data
6. Smoke test: login, view records, create one
7. Time the whole thing — that's your real RTO
8. Document gotchas; update runbook
9. Tear down test instance
```

If the drill fails or RTO is worse than promised → fix BEFORE you need it.

## Database-specific PITR drills

PostgreSQL PITR drill (test once monthly):
```bash
# In test instance
pg_basebackup -h prod-host -D /var/lib/postgresql/data -P
# In recovery.conf: restore_command = 'aws s3 cp s3://wal-archive/%f %p'
# In postgresql.conf: recovery_target_time = '2026-04-18 14:35:00'
systemctl start postgresql
# Verify: did the data get restored to that exact moment?
```

## Encryption

- Backups WITH secrets MUST be encrypted at rest (S3 server-side OK; client-side better)
- restic encrypts by default — good
- pg_dump is plaintext — gpg-encrypt before upload:
  ```bash
  pg_dump db | gzip | gpg --encrypt -r ops@example.com > backup.gz.gpg
  ```
- Encryption key must NOT be on the same machine being backed up

## Anti-patterns

- "We have backups" without ever doing a restore drill
- Backups on same disk as data (disk fails → both gone)
- Backups in same region as prod (region fails → both gone)
- Cron job that silently fails for 6 months (no monitoring)
- No retention policy → disk fills up → no new backups
- Encrypted backups with key in same backup
- Restoring to prod to "test" (you'll wipe real data eventually)
- Snapshots only (snapshots are not backups — they're tied to source storage)

## Integration

- `nc-linux-sysadmin` — systemd timer for scheduling
- `nc-incident-response` — restore is part of recovery playbook
- `nc-databases` — DB-specific dump/restore commands
- `nc-deploy-vps` — pre-deploy backup pattern
- `nc-security` — encryption, key management
- `nc-kubernetes` — Velero for k8s-native backup/restore
