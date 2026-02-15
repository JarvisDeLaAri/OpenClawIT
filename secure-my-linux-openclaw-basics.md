# Secure My Linux (OpenClaw) Basics

> **For AI assistants like OpenClaw.** Follow these steps sequentially on a fresh Ubuntu or Debian VPS.  
> Detect the OS first: `cat /etc/os-release` — adapt package names accordingly.  
> **Debian users**: `apt install apparmor apparmor-utils ufw unattended-upgrades` before starting.

---

## 0. Detect OS

```bash
source /etc/os-release
echo "OS: $ID $VERSION_ID"
```

If `$ID` = `debian`, install prerequisites first:
```bash
apt update && apt install -y apparmor apparmor-utils ufw unattended-upgrades
```

---

## 1. SSH Hardening

### 1.1 Change SSH Port

Ask user to pick a random port between 10000–65000. Use that everywhere below as `$SSH_PORT`.

```bash
SSH_PORT=<user-chosen-port>

# Update SSH config
cat > /etc/ssh/sshd_config.d/99-hardened.conf << EOF
Port $SSH_PORT

# Authentication
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
PermitEmptyPasswords no
MaxAuthTries 3
AllowUsers root

# Connection Limits
MaxStartups 3:50:10
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable unnecessary features
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
Banner none
DebianBanner no
EOF
```

If using systemd socket (Ubuntu 22.04+):
```bash
mkdir -p /etc/systemd/system/ssh.socket.d
cat > /etc/systemd/system/ssh.socket.d/override.conf << EOF
[Socket]
ListenStream=
ListenStream=$SSH_PORT
EOF
systemctl daemon-reload
```

Fix any conflicting configs:
```bash
# Ensure no other file overrides PasswordAuthentication
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/*.conf 2>/dev/null
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 2>/dev/null
```

Restart SSH:
```bash
systemctl restart ssh
```

**⚠️ Test new port in a NEW terminal before closing the current session!**

### 1.2 SSH Cryptography Hardening

Append to `/etc/ssh/sshd_config.d/99-hardened.conf`:
```bash
cat >> /etc/ssh/sshd_config.d/99-hardened.conf << 'EOF'

# Crypto hardening — remove weak algorithms
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
EOF

systemctl restart ssh
```

### 1.3 Install Fail2ban

```bash
apt install -y fail2ban

cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
findtime = 600
EOF

systemctl enable fail2ban
systemctl restart fail2ban
```

---

## 2. Firewall — Close EVERYTHING Except 443 + SSH

```bash
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp comment 'SSH'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
ufw status verbose
```

**That's it. Only 443 and your SSH port are open. Everything else is blocked.**

If you need additional ports later, explicitly allow them:
```bash
ufw allow <port>/tcp comment '<description>'
```

---

## 3. Automatic Security Updates

```bash
apt install -y unattended-upgrades

# Enable auto-updates
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF
```

Verify the config includes security repos:
```bash
grep -i "security" /etc/apt/apt.conf.d/50unattended-upgrades | head -5
```

---

## 4. Kernel Hardening (sysctl)

```bash
cat > /etc/sysctl.d/99-security.conf << 'EOF'
# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Enable SYN cookies (SYN flood protection)
net.ipv4.tcp_syncookies = 1

# Log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Reject bogus ICMP responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable IPv6 Router Advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Disable SysRq key
kernel.sysrq = 0

# Restrict dmesg to root
kernel.dmesg_restrict = 1

# Hide kernel pointers
kernel.kptr_restrict = 2

# Disable core dumps
fs.suid_dumpable = 0
EOF

sysctl --system
```

---

## 5. Disable Core Dumps

```bash
echo 'kernel.core_pattern = |/bin/false' >> /etc/sysctl.d/99-security.conf
sysctl --system

echo '* hard core 0' >> /etc/security/limits.conf
```

---

## 6. Disable Unnecessary Services & Kernel Modules

```bash
# Stop modem/bluetooth/printing if present
systemctl disable --now ModemManager 2>/dev/null
systemctl mask ModemManager 2>/dev/null

# On Ubuntu with snap cups:
snap disable cups 2>/dev/null

# On Debian with cups:
systemctl disable --now cups 2>/dev/null

# Blacklist unnecessary kernel modules
cat > /etc/modprobe.d/blacklist-unnecessary.conf << 'EOF'
blacklist usb_storage
blacklist firewire_core
blacklist firewire_ohci
blacklist thunderbolt
blacklist pcspkr
blacklist bluetooth
blacklist btusb
EOF

# Blacklist unused network protocols
cat > /etc/modprobe.d/blacklist-protocols.conf << 'EOF'
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc
EOF
```

---

## 7. AppArmor

```bash
# Check status
aa-status

# Move any complain profiles to enforce
aa-complain /etc/apparmor.d/* 2>/dev/null
aa-enforce /etc/apparmor.d/* 2>/dev/null
```

---

## 8. File Integrity Monitoring (AIDE)

```bash
apt install -y aide

# Initialize baseline database
aideinit
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Daily check cron
cat > /etc/cron.d/aide-check << 'EOF'
0 4 * * * root /usr/bin/aide --config /etc/aide/aide.conf --check 2>&1 | head -50
EOF
```

---

## 9. Rootkit Detection

```bash
apt install -y rkhunter chkrootkit

# Update rkhunter database
rkhunter --update
rkhunter --propupd

# Fix rkhunter config (common issue)
sed -i 's|^WEB_CMD="/bin/false"|WEB_CMD=""|' /etc/rkhunter.conf 2>/dev/null

# Daily crons
cat > /etc/cron.d/rootkit-checks << 'EOF'
0 3 * * * root /usr/bin/rkhunter --check --skip-keypress --quiet 2>&1 | grep -i warning
30 3 * * * root /usr/sbin/chkrootkit 2>&1 | grep -i infected
EOF
```

---

## 10. Port Scan Detection (psad)

```bash
apt install -y psad

# Enable logging for UFW
ufw logging on

systemctl enable psad
systemctl restart psad
```

---

## 11. Security Auditing (Lynis)

```bash
apt install -y lynis
```

---

## 12. Harden File Permissions

Lock down sensitive files — credentials, env files, SSH keys.

```bash
# SSH directory
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys 2>/dev/null
chmod 600 ~/.ssh/id_* 2>/dev/null

# Find and lock .env files
find / -name ".env" -type f -exec chmod 600 {} \; 2>/dev/null

# Lock /etc/shadow
chmod 640 /etc/shadow
```

Tell the AI: scan for any config files containing passwords, API keys, or tokens and ensure they are chmod 600 (owner read/write only).

---

## 13. Password Auth Instant Permaban

Since the server is key-only, ANY password attempt is hostile. Ban on first try, forever.

```bash
cat > /etc/fail2ban/filter.d/sshd-password.conf << 'EOF'
[Definition]
failregex = ^.*sshd\[.*\]: Connection closed by authenticating user .* <HOST> port .* \[preauth\]$
            ^.*sshd\[.*\]: Disconnected from authenticating user .* <HOST> port .* \[preauth\]$
            ^.*sshd\[.*\]: Failed password for .* from <HOST> port .*$
            ^.*sshd\[.*\]: Failed password for invalid user .* from <HOST> port .*$
            ^.*sshd\[.*\]: Connection closed by invalid user .* <HOST> port .*$
            ^.*sshd\[.*\]: Invalid user .* from <HOST> port .*$
            ^.*sshd\[.*\]: User .* from <HOST> not allowed because not listed in AllowUsers$
            ^.*sshd\[.*\]: Disconnected from invalid user .* <HOST> port .* \[preauth\]$
ignoreregex =
EOF

cat >> /etc/fail2ban/jail.local << EOF

[sshd-password-attempt]
enabled = true
port = $SSH_PORT
filter = sshd-password
logpath = /var/log/auth.log
maxretry = 1
bantime = -1
findtime = 31536000
EOF

fail2ban-client reload
```

Verify — check if any IPs were already caught from historical logs:
```bash
fail2ban-client status sshd-password-attempt
```

---

## 14. TLS Hardening (if running web services)

For any service behind Nginx:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
```

For Python apps using ssl module:
```python
ctx.minimum_version = ssl.TLSVersion.TLSv1_2
```

Node.js defaults to TLS 1.2+ — no changes needed.

### Nginx Security Headers (if using Nginx)

```bash
cat > /etc/nginx/conf.d/security-headers.conf << 'EOF'
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
server_tokens off;
EOF

nginx -t && systemctl reload nginx
```

### Nginx Rate Limiting (if using Nginx)

```bash
cat > /etc/nginx/conf.d/rate-limit.conf << 'EOF'
# Rate limiting: 10 req/sec per IP, burst up to 20
limit_req_zone $binary_remote_addr zone=global:10m rate=10r/s;
limit_req zone=global burst=20 nodelay;
EOF

nginx -t && systemctl reload nginx
```

---

## 15. Harden Umask & Clean Up

```bash
# Set stricter default umask
sed -i 's/^UMASK.*022/UMASK\t\t027/' /etc/login.defs

# Purge leftover package configs
dpkg --purge $(dpkg -l | awk '/^rc/ {print $2}') 2>/dev/null

# Install debsums for package integrity verification
apt install -y debsums
```

---

## 16. Weekly Security Audit (Automated)

### Option A: AlertJarvisFromProd

If you run [JarvisHub](https://github.com/JarvisDeLaAri/YourJarvisHub) on a separate server, you can route ALL alerts through SSH instead of email — zero SMTP credentials, zero email configuration:

👉 **[AlertJarvisFromProd](https://github.com/JarvisDeLaAri/AlertJarvisFromProd)** — Secure SSH-based alert pipeline. Monitoring scripts SSH into your hub server via a locked-down user (forced command, no shell, no forwarding) and POST alerts to JarvisHub, which wakes your AI assistant to notify you on WhatsApp/Telegram/etc.

Set it up after completing this gist, then wire all monitoring scripts to `alert-jarvis.sh` instead of `mail`.

### Option B: OpenClaw Machine (cron-based)

If OpenClaw is running on this machine, set up a weekly cron job via OpenClaw:

```
Use the OpenClaw cron tool to create a weekly job:
- Name: "Weekly Security Audit"
- Schedule: cron "0 8 * * 6" (Saturday 08:00) with user's timezone
- Session: isolated
- Task: "Run a security audit on this VPS. Check: SSH config (ssh-audit if installed), 
  UFW rules, fail2ban status, running services and their users, open ports, pending updates, 
  file permissions on sensitive dirs, disk usage, uptime, and any suspicious auth log entries 
  from the past week. Also run lynis audit system --quick if installed. 
  Format as a clean report and send it to the user on their messaging channel."
- Delivery: announce
```

OpenClaw will run the audit in an isolated session and deliver results directly to your chat.

### Option C: Email alerts (msmtp)

Ask the user for their email provider details:
- SMTP host (e.g., smtp.gmail.com)
- SMTP port (e.g., 587)
- Email address
- App password (NOT their regular password — for Gmail, generate at myaccount.google.com → Security → App passwords)

```bash
apt install -y msmtp msmtp-mta

cat > /etc/msmtprc << EOF
defaults
auth           on
tls            on
tls_starttls   on
logfile        /var/log/msmtp.log

account default
host           <SMTP_HOST>
port           <SMTP_PORT>
from           <EMAIL>
user           <EMAIL>
password       <APP_PASSWORD>
EOF

chmod 600 /etc/msmtprc
```

Create the weekly audit script:

```bash
cat > /usr/local/bin/weekly-security-audit.sh << 'SCRIPT'
#!/bin/bash
REPORT="/tmp/security-report-$(date +%Y%m%d).txt"
EMAIL="<USER_EMAIL>"

{
echo "=============================="
echo "  WEEKLY SECURITY AUDIT"
echo "  $(date '+%Y-%m-%d %H:%M %Z')"
echo "=============================="
echo ""

echo "--- SSH Config ---"
sshd -T 2>/dev/null | grep -E "^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|allowusers)"
echo ""

echo "--- Firewall ---"
ufw status numbered
echo ""

echo "--- Fail2ban ---"
fail2ban-client status sshd 2>/dev/null || echo "fail2ban not running"
echo ""

echo "--- Auth Log (past week, suspicious only) ---"
grep -i "failed\|invalid\|break-in\|POSSIBLE" /var/log/auth.log 2>/dev/null | tail -20
echo ""

echo "--- Open Ports ---"
ss -tlnp | grep LISTEN
echo ""

echo "--- Pending Updates ---"
apt list --upgradable 2>/dev/null | tail -20
echo ""

echo "--- Disk Usage ---"
df -h / | tail -1
echo ""

echo "--- Uptime & Load ---"
uptime
echo ""

echo "--- Lynis Score ---"
lynis audit system --quick --no-colors 2>/dev/null | grep -E "Hardening index|Warning|Suggestion"
echo ""

echo "--- rkhunter ---"
rkhunter --check --skip-keypress --quiet --no-colors 2>&1 | tail -5
echo ""

echo "--- chkrootkit ---"
chkrootkit 2>&1 | grep -i "infected" || echo "No infections found"
echo ""

} > "$REPORT" 2>&1

# Send via email
cat "$REPORT" | mail -s "Weekly Security Audit - $(hostname) - $(date +%Y-%m-%d)" "$EMAIL"
rm -f "$REPORT"
SCRIPT

chmod +x /usr/local/bin/weekly-security-audit.sh

# Weekly cron — Saturday 08:00 (adjust timezone as needed)
cat > /etc/cron.d/weekly-security-audit << 'EOF'
0 8 * * 6 root /usr/local/bin/weekly-security-audit.sh
EOF
```

Test email delivery:
```bash
echo "Security audit email test from $(hostname)" | mail -s "Test - Security Audit" <USER_EMAIL>
```

### Connect ALL Monitoring to Email

Once email works, update all monitoring scripts to send alerts via email:

```bash
# AIDE daily check — email on changes
cat > /etc/cron.d/aide-check << 'EOF'
0 4 * * * root OUTPUT=$(/usr/bin/aide --config /etc/aide/aide.conf --check 2>&1); if [ $? -ne 0 ]; then echo "$OUTPUT" | mail -s "⚠️ AIDE File Changes - $(hostname)" root; fi
EOF

# rkhunter — email on warnings
cat > /usr/local/bin/rkhunter-check.sh << 'SCRIPT'
#!/bin/bash
OUTPUT=$(/usr/bin/rkhunter --check --skip-keypress --report-warnings-only 2>&1)
if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT" | mail -s "⚠️ rkhunter Warning - $(hostname)" root
fi
SCRIPT
chmod 755 /usr/local/bin/rkhunter-check.sh

# chkrootkit — email on INFECTED
cat > /usr/local/bin/chkrootkit-check.sh << 'SCRIPT'
#!/bin/bash
OUTPUT=$(/usr/sbin/chkrootkit 2>&1)
if echo "$OUTPUT" | grep -qi "infected"; then
  echo "$OUTPUT" | mail -s "🚨 chkrootkit INFECTED - $(hostname)" root
fi
SCRIPT
chmod 755 /usr/local/bin/chkrootkit-check.sh

# Update rootkit crons to use email-enabled scripts
cat > /etc/cron.d/rootkit-checks << 'EOF'
0 3 * * * root /usr/local/bin/rkhunter-check.sh
30 3 * * * root /usr/local/bin/chkrootkit-check.sh
EOF

# Auth monitor — email on suspicious activity
# (update the alert section in auth-monitor.sh)
sed -i '/echo "\[🔐 Auth Alert\]/a\    echo -e "$ALERTS" | mail -s "🔐 Auth Alert - $(hostname)" root' /usr/local/bin/auth-monitor.sh 2>/dev/null

# Service health — email on failures
# (update the alert section in service-health.sh)
sed -i '/echo -e "\[🚨 Service Health/a\    echo -e "$FAILURES" | mail -s "🚨 Service Down - $(hostname)" root' /usr/local/bin/service-health.sh 2>/dev/null

# Login notify — email on SSH login
sed -i 's|logger -t login-notify "$MSG"|logger -t login-notify "$MSG"\n  echo -e "$MSG" \| mail -s "🔐 SSH Login: $PAM_USER from $PAM_RHOST" root|' /usr/local/bin/login-notify.sh 2>/dev/null
```

---

## 17. Auth Log Monitoring

Monitor `/var/log/auth.log` every 5 minutes for suspicious activity.

```bash
cat > /usr/local/bin/auth-monitor.sh << 'SCRIPT'
#!/bin/bash
STATE_FILE="/var/run/auth-monitor-pos"
LOG="/var/log/auth.log"

# Get last position
LAST_POS=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
CURRENT_SIZE=$(stat -c%s "$LOG" 2>/dev/null || echo "0")

# If log rotated (smaller), reset
[ "$CURRENT_SIZE" -lt "$LAST_POS" ] && LAST_POS=0

# Extract new lines
ALERTS=$(tail -c +$((LAST_POS + 1)) "$LOG" 2>/dev/null | grep -iE "failed sudo|COMMAND.*sudo|useradd|userdel|passwd|groupadd|usermod" | grep -v "root" | grep -v "CRON" | head -20)

# Save position
echo "$CURRENT_SIZE" > "$STATE_FILE"

# Alert if anything found
if [ -n "$ALERTS" ]; then
    echo "[🔐 Auth Alert] Suspicious activity detected:"
    echo "$ALERTS"
fi
SCRIPT

chmod +x /usr/local/bin/auth-monitor.sh

cat > /etc/cron.d/auth-monitor << 'EOF'
*/5 * * * * root /usr/local/bin/auth-monitor.sh 2>&1 | logger -t auth-monitor
EOF
```

For OpenClaw machines, pipe alerts to the gateway. For email machines, pipe to `mail`.

---

## 18. Service Health Monitoring

Check critical services every 10 minutes. Alert only when something is DOWN.

```bash
cat > /usr/local/bin/service-health.sh << 'SCRIPT'
#!/bin/bash
FAILURES=""

check_service() {
    local name="$1"
    local port="$2"
    local unit="$3"
    
    if [ -n "$unit" ]; then
        if ! systemctl is-active --quiet "$unit" 2>/dev/null; then
            FAILURES="$FAILURES\n❌ $name ($unit) — service not active"
            return
        fi
    fi
    
    if [ -n "$port" ]; then
        if ! ss -tlnp | grep -q ":${port} " 2>/dev/null; then
            FAILURES="$FAILURES\n❌ $name — port $port not listening"
            return
        fi
    fi
}

# Add your services here:
check_service "SSH" "" "ssh"
check_service "Firewall" "" "ufw"
check_service "Fail2ban" "" "fail2ban"
# check_service "Nginx" "443" "nginx"       # Uncomment if using Nginx
# check_service "MyApp" "8080" "myapp"       # Add your apps

if [ -n "$FAILURES" ]; then
    echo -e "[🚨 Service Health Alert]$FAILURES"
fi
SCRIPT

chmod +x /usr/local/bin/service-health.sh

cat > /etc/cron.d/service-health << 'EOF'
*/10 * * * * root /usr/local/bin/service-health.sh 2>&1 | logger -t service-health
EOF
```

Tell the user to add their own services to the `check_service` calls in the script.

---

## 19. Run Full Audit & Report (One-Time)

```bash
echo "=============================="
echo "  SECURITY AUDIT REPORT"
echo "=============================="
echo ""

echo "--- OS ---"
cat /etc/os-release | grep -E "^(PRETTY_NAME|VERSION)"
echo ""

echo "--- SSH ---"
sshd -T 2>/dev/null | grep -E "^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|allowusers)"
echo ""

echo "--- Firewall ---"
ufw status numbered
echo ""

echo "--- Fail2ban ---"
fail2ban-client status sshd 2>/dev/null || echo "fail2ban not running"
echo ""

echo "--- AppArmor ---"
aa-status 2>/dev/null | head -5
echo ""

echo "--- Listening Ports ---"
ss -tlnp | grep LISTEN
echo ""

echo "--- Lynis Score ---"
lynis audit system --quick --no-colors 2>/dev/null | grep -E "Hardening index|Warning|Suggestion"
echo ""

echo "--- rkhunter ---"
rkhunter --check --skip-keypress --quiet --no-colors 2>&1 | tail -5
echo ""

echo "--- chkrootkit ---"
chkrootkit 2>&1 | grep -i "infected" || echo "No infections found"
echo ""

echo "--- debsums ---"
debsums -s 2>&1 | head -10 || echo "All packages verified"
echo ""

echo "=============================="
echo "  AUDIT COMPLETE"
echo "=============================="
```

---

## Summary of What This Does

| Layer | Protection |
|-------|-----------|
| SSH | Non-standard port, key-only, no passwords, strong crypto, rate limiting |
| Firewall | ALL ports closed except 443 + SSH — deny by default |
| Brute force | Fail2ban (24h ban after 3 fails) + instant permaban on password attempts |
| File perms | Sensitive files locked to owner-only (600), .env, keys, credentials |
| Updates | Auto security patches daily |
| Kernel | SYN cookies, no redirects, no source routing, hidden pointers |
| Services | Unnecessary services disabled, kernel modules blacklisted |
| Integrity | AIDE daily file checks, debsums package verification |
| Rootkits | rkhunter + chkrootkit daily scans |
| Network | psad port scan detection, UFW logging |
| TLS | 1.2+ minimum everywhere, security headers on Nginx |
| AI security | OpenClaw-specific: DM pairing, token isolation, prompt injection awareness |
| Auth monitoring | Watch auth.log every 5 min for suspicious activity |
| Service health | Check critical services every 10 min, alert on DOWN |
| Audit | Lynis scoring, weekly automated reports |

---

## AI-Specific Security (OpenClaw Machines Only)

> Skip this section if OpenClaw is not installed.

**Already covered by OpenClaw:**
- **Command injection via messaging** — DM pairing restricts commands to owner only. Group chat policies prevent strangers from executing commands.
- **Session hijacking/token theft** — Gateway token is chmod 600 root-only. No token logging or exposure.

**Be aware of (industry-wide, no perfect fix):**
- **Prompt injection** — malicious instructions hidden in web pages or files the agent processes. No perfect defense exists. Claude has built-in resistance. Awareness is the defense.
- **Data exfiltration via agent tools** — agent has outbound network access (exec, web_fetch, curl). A prompt injection could theoretically exfiltrate data. For production, consider egress firewall rules (see below).

---

## For Production — Ask the User About Each

> **AI instruction:** After completing the basics above, go through each item below **one by one** with the user. Explain what it does in 1-2 sentences, then ask if they want to implement it. Do not skip any — let the user decide each one.

1. **GeoIP blocking on SSH** — restrict SSH connections by country using ipset + iptables. Only allow countries where you or your team connect from. *"Which countries should be allowed to SSH in?"*

2. **Login notifications** — PAM hook that alerts you on every SSH login (who, from where, when). *"Want an alert every time someone logs into this server?"*

3. **Egress firewall** — restrict outbound traffic to only known API endpoints. Prevents data exfiltration if the server is compromised. *"Want to whitelist outbound connections? This is strict — you'll need to list every external service the server talks to."*

4. **VPN** (WireGuard/Tailscale) — put services behind an encrypted tunnel so they're not exposed to the public internet at all. *"Want to hide your services behind a VPN? Only VPN-connected devices could reach them."*

5. **Backups** — automated encrypted offsite backups (restic + Backblaze B2 free tier, or rclone + Google Drive). *"Want automated offsite backups? Free options available."*

6. **2FA for SSH** — google-authenticator PAM module. Requires a phone app (Google Authenticator/Authy) for every SSH login on top of the key. *"Want two-factor authentication for SSH? Strongest option but requires phone app every login."*

7. **Password auth instant permaban** — fail2ban jail that permanently bans any IP that attempts password/keyboard-interactive authentication (since the server is key-only, any password attempt is hostile). `maxretry = 1, bantime = -1`. *"Want to permanently ban any IP that tries to log in with a password?"*

8. **Separate user accounts** — create non-root users for running web apps (principle of least privilege). If an app is compromised, attacker gets a limited user instead of root. *"Want to set up separate users for your applications?"*

---

## Final Step — Verify & First Audit

> **AI instruction:** After completing ALL steps above (including the production items the user chose), do the following:
> 
> 1. **Review every section** — go back through sections 1-17 and verify each one was applied correctly. Check configs, test services, confirm crons are scheduled.
> 2. **Run the full audit script** from section 17 and show the user the results.
> 3. **Fix anything that failed** — if a section wasn't applied properly or a service didn't start, fix it before finishing.
> 4. **Summarize** — give the user a clean summary of everything that was done, what's active, and what they chose to skip.
> 5. **Save the report** — if on an OpenClaw machine, save to a memory file. If email, send the first report to confirm delivery works.

---

Built by Jarvis de la Ari & Ariel @ Bresleveloper AI 🦞


---

[![YouTube](https://img.shields.io/badge/YouTube-BresleveloperAI-red?logo=youtube)](https://www.youtube.com/@BresleveloperAI/videos)

[ישראלי/דובר עברית? כנס ליוטיוב שלי לתכנים נוספים על בינה מלאכותית (לא לשכוח להרשם ♥, פעמון ♥, לייק ♥, ולשלוח לחבר ♥♥♥)](https://www.youtube.com/@BresleveloperAI/videos)

