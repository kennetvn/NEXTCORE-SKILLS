---
description: Linux system administration patterns. Use when investigating server issues, managing services with systemd, configuring users/permissions, tuning kernel params, troubleshooting disk/CPU/memory, or bootstrapping a new VPS.
auto_execution_mode: 1
---

# Linux Sysadmin Skill

Practical patterns for Ubuntu/Debian (apt) and RHEL/Rocky (dnf) on real servers. Defaults to Ubuntu 22.04+ syntax; calls out RHEL diffs.

## Diagnostic first hour

When SSH'd into a sick server, in this order:

```bash
# 1. Why did I get paged?
uptime                                     # load avg vs CPU count
free -h                                    # mem pressure?
df -h                                      # disk full?
dmesg -T | tail -50                        # OOM killer? hardware errors?

# 2. What's running hot?
top -bn1 | head -30                        # snapshot top processes
ps auxf | head -50                         # tree view
iostat -xz 1 5                             # disk I/O (apt install sysstat)

# 3. Network healthy?
ss -tunap | head                           # what's listening / connected
ip -br a                                   # IPs per interface
ping -c3 1.1.1.1                          # internet?
ping -c3 8.8.8.8                          # DNS independent path?

# 4. Recent changes?
journalctl --since "1 hour ago" -p err     # errors in past hour
last -10                                   # who logged in
ls -lat /var/log/ | head                   # what's been written
cat /var/log/auth.log | tail -30           # SSH attempts (RHEL: /var/log/secure)
```

Don't change anything until you have the picture. Capture state first.

## systemd service management

```bash
# Status (single source of truth — not `service` legacy)
systemctl status nginx
systemctl is-active nginx
systemctl is-enabled nginx

# Lifecycle
systemctl start|stop|restart|reload nginx
systemctl enable nginx                     # start on boot
systemctl disable nginx
systemctl mask nginx                       # prevent any way to start (stronger)

# Logs (structured, no more grep /var/log/...)
journalctl -u nginx                        # all
journalctl -u nginx -f                     # follow
journalctl -u nginx --since "10 min ago"
journalctl -u nginx -p err                 # errors only
journalctl --disk-usage                    # how much space logs take
journalctl --vacuum-time=30d               # purge >30d

# Failed services overview
systemctl list-units --failed
systemctl list-timers                      # cron replacement
```

### Custom service

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My App
After=network.target
Requires=postgresql.service

[Service]
Type=simple
User=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/server
Restart=on-failure
RestartSec=5
Environment="NODE_ENV=production"
EnvironmentFile=/etc/myapp/env

# Resource limits
MemoryMax=512M
CPUQuota=50%
TasksMax=200

# Hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/lib/myapp /var/log/myapp

[Install]
WantedBy=multi-user.target
```

After edit: `systemctl daemon-reload && systemctl restart myapp`.

## Users + permissions

```bash
# Create user with sudo (Ubuntu)
adduser deploy                              # interactive
usermod -aG sudo deploy                     # add to sudo group
# RHEL: usermod -aG wheel deploy

# Service-only user (no shell, no home)
useradd -r -s /usr/sbin/nologin myapp

# SSH key auth (disable password!)
mkdir -p /home/deploy/.ssh
echo "ssh-ed25519 AAAA... user@host" > /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

# Disable password SSH (in /etc/ssh/sshd_config)
# PasswordAuthentication no
# PermitRootLogin prohibit-password
systemctl restart sshd

# File perms cheat sheet
chmod 644 file       # rw- r-- r--   normal file
chmod 600 secret     # rw- --- ---   private (key, .env)
chmod 755 script     # rwx r-x r-x   executable
chmod 700 .ssh       # rwx --- ---   ssh dir

# Sticky / setuid (rare, careful)
chmod 1777 /tmp      # sticky: only owner can delete own files
chmod 4755 binary    # setuid: runs as owner (only if you fully understand)
```

## Disk + filesystem

```bash
# Where's space?
df -h                                       # mounted FS overview
du -sh /var/* 2>/dev/null | sort -h         # by dir
ncdu /                                      # interactive (apt install ncdu)

# Find big files
find / -type f -size +100M 2>/dev/null | xargs ls -lh 2>/dev/null | sort -k5 -h | tail -20

# What's holding space (deleted but open)
lsof | grep deleted | sort -k7 -n | tail   # restart the holder to free

# Inode exhaustion (df -h shows space but writes fail)
df -i

# Mount info
mount | column -t
findmnt                                     # tree view

# Add disk → format → mount
lsblk                                       # see new disk (e.g., /dev/sdb)
mkfs.ext4 /dev/sdb1
mkdir /mnt/data
mount /dev/sdb1 /mnt/data
echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /mnt/data ext4 defaults 0 2" >> /etc/fstab
```

## Performance tuning

```bash
# Memory pressure
vmstat 1 5                                  # si/so columns = swapping (bad)
sysctl vm.swappiness                        # default 60; for DB servers, set 10
echo "vm.swappiness=10" >> /etc/sysctl.d/99-tuning.conf
sysctl -p /etc/sysctl.d/99-tuning.conf

# File descriptors
ulimit -n                                   # current soft limit
cat /proc/sys/fs/file-max                   # system-wide max
# Per-service: in systemd unit, LimitNOFILE=65536

# TCP tuning for high-conn services
cat <<EOF >> /etc/sysctl.d/99-network.conf
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
EOF
sysctl -p /etc/sysctl.d/99-network.conf
```

## Cron alternatives

Prefer systemd timers over cron — better logging, dependency awareness.

```ini
# /etc/systemd/system/nightly-backup.timer
[Unit]
Description=Nightly backup at 02:00

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/nightly-backup.service
[Unit]
Description=Nightly backup

[Service]
Type=oneshot
ExecStart=/opt/scripts/backup.sh
```

`systemctl enable --now nightly-backup.timer`

## Hardening checklist (new VPS)

- [ ] Update: `apt update && apt full-upgrade -y && apt autoremove -y`
- [ ] Create non-root sudo user, copy SSH key
- [ ] Disable root SSH + password SSH (sshd_config)
- [ ] Install + enable UFW (Ubuntu) or firewalld (RHEL)
- [ ] Allow only required ports: `ufw allow OpenSSH; ufw allow 80; ufw allow 443; ufw enable`
- [ ] Install `unattended-upgrades` for auto security patches
- [ ] Set timezone: `timedatectl set-timezone Asia/Bangkok`
- [ ] Set hostname: `hostnamectl set-hostname <name>`
- [ ] Install `fail2ban` (jails common services)
- [ ] Disable unused services: `systemctl disable --now <svc>`
- [ ] Backup `.ssh/authorized_keys` somewhere offline

## Anti-patterns

- Editing `/etc/passwd` / `/etc/shadow` directly (use `usermod` / `passwd`)
- Modifying `/etc/sysctl.conf` (use drop-in `/etc/sysctl.d/*.conf`)
- `chmod 777` to "fix" perms (massive sec hole)
- Running services as root (use service accounts)
- SSH password auth in production
- Cron with no logging (use systemd timer or wrap with journald)
- `apt-get install` in `/root/script.sh` with no idempotency check
- Editing on prod without backup of original config

## Integration

- `nc-deploy-vps` — uses these patterns for AaPanel/PM2 deploys
- `nc-incident-response` — diagnostic-first-hour applies during incidents
- `nc-backup-recovery` — backup script patterns
- `nc-observability` — node_exporter + Prometheus on Linux
- `nc-networking` — sysctl tuning, ip/ss commands
- `nc-security` — hardening + auth audit
