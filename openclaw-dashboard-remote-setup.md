# OpenClaw Dashboard — Remote HTTPS Setup (Top to Bottom)

This guide makes the OpenClaw Control UI dashboard accessible remotely over HTTPS.

## Prerequisites
- OpenClaw installed and running (`openclaw gateway start`)
- SSH root access to the server
- Server IP known (referred to as `SERVER_IP` below)

## Step 1: Check Current State

```bash
# Confirm gateway is running
ps aux | grep openclaw-gateway

# Find which ports it's using
ss -tlnp | grep openclaw
```

You should see two ports:
- **18789** — main gateway (serves dashboard UI + WebSocket)
- **18792** — internal control port (localhost only)

## Step 2: Ensure Gateway Binds to LAN

Check current bind mode:
```bash
cat ~/.openclaw/openclaw.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('gateway',{}).get('bind','not set'))"
```

If it says `loopback`, change to `lan`:
```bash
# Edit ~/.openclaw/openclaw.json
# Set: "gateway" → "bind": "lan"
# Then restart:
openclaw gateway restart
```

If it already says `lan`, skip this step.

## Step 3: Ensure TLS is Enabled

```bash
ls -la ~/.openclaw/gateway.crt ~/.openclaw/gateway.key 2>/dev/null
```

If files exist, TLS is already configured. If not:
```bash
# OpenClaw auto-generates on next restart if tls.autoGenerate is true
# Or manually generate:
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
  -keyout ~/.openclaw/gateway.key -out ~/.openclaw/gateway.crt \
  -days 3650 -nodes -subj "/CN=$(hostname)"
chmod 600 ~/.openclaw/gateway.key
```

Ensure config has TLS enabled:
```json
{
  "gateway": {
    "tls": {
      "enabled": true,
      "certPath": "/root/.openclaw/gateway.crt",
      "keyPath": "/root/.openclaw/gateway.key"
    }
  }
}
```

## Step 4: Remove Any Conflicting NAT Rules

Check for port redirects that interfere:
```bash
nft list ruleset 2>/dev/null | grep -i "<new-port>\|18789\|redirect"
```

If you see a redirect rule (e.g., `tcp dport <new-port> redirect to :18789`), remove it:
```bash
# List rules with handles
nft -a list chain ip nat PREROUTING

# Delete by handle number
nft delete rule ip nat PREROUTING handle <HANDLE_NUMBER>
```

## Step 5: Open Firewall Port

```bash
# UFW
ufw allow <new-port>/tcp

# Or iptables
iptables -A INPUT -p tcp --dport <new-port> -j ACCEPT
```

If using a cloud provider (Hostinger, DigitalOcean, AWS, etc.), also open port <new-port> in the **provider's firewall/security group** settings.

## Step 6: Verify External Access

From another machine:
```bash
curl -sk -o /dev/null -w "%{http_code}" https://SERVER_IP:<new-port>/
```

Should return `200`. If it times out, the provider firewall is likely blocking it.

## Step 7: Accept Self-Signed Certificate in Browser

1. Open `https://SERVER_IP:<new-port>` in the browser
2. Accept the self-signed certificate warning ("Advanced" → "Proceed")
3. You should see the OpenClaw Control UI login page

## Step 8: Get the Gateway Auth Token

On the server:
```bash
grep token ~/.openclaw/openclaw.json
```

Copy the token value (long hex string).

## Step 9: Pair the Device

The first remote connection requires device pairing approval.

The browser will show: **"disconnected (1008): pairing required"**

On the server, run:
```bash
# List pending pairing requests
openclaw devices list

# Approve the pending request by its Request ID
openclaw devices approve <REQUEST_ID>
```

The dashboard should connect immediately after approval.

## Step 10: Enter the Token

In the dashboard settings/connection panel, paste the gateway auth token from Step 8.

---

## Troubleshooting

### "pairing required" keeps repeating
- Run `openclaw devices list` — there must be a pending request to approve
- Each browser/profile has a unique device ID; clearing browser data requires re-pairing

### Dashboard loads but shows "offline"
- The WebSocket connection is failing
- Check that TLS cert is accepted in browser (visit `https://SERVER_IP:<new-port>` directly)
- Check gateway logs: `tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`

### ERR_SSL_PROTOCOL_ERROR
- Port is open but not serving TLS
- Verify `gateway.tls.enabled: true` in config
- Restart gateway after config changes

### Connection timeout from outside
- Cloud provider firewall blocking the port
- Check provider dashboard (Hostinger VPS Firewall, AWS Security Groups, etc.)
- Test with `nc -zv SERVER_IP <new-port>` from external machine

### `openclaw` CLI errors about Node version
- OpenClaw requires Node ≥22.12.0
- Use nvm: `nvm install 24 && nvm use 24`
- Then re-run openclaw commands

### NAT rules interfering
- `nft list ruleset` or `iptables -t nat -L` to check
- Remove any redirect rules on the gateway port

---

## Security Notes

- Self-signed certs are fine for personal use; for production use Let's Encrypt or Caddy
- Consider setting `gateway.auth.rateLimit` to prevent brute-force:
  ```json
  "auth": {
    "rateLimit": {
      "maxAttempts": 10,
      "windowMs": 60000,
      "lockoutMs": 300000
    }
  }
  ```
- Revoke devices: `openclaw devices revoke --device <ID> --role <ROLE>`
- Local connections (127.0.0.1) are auto-approved; remote connections always require explicit approval
