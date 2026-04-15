# SSH Journey Log (The Full "Why Was This So Painful" Story)

## Goal

Harden VPS security from a baseline guide, move SSH to port `30022`, keep `22` open until confirmed, then close `22` on request.

Also set up key-only SSH access for root and verify remote connectivity from Windows.

## Requested constraints

- Use `30022` for SSH.
- Do not close `22` until explicit confirmation from user.
- Allow additional app port `30080`.
- Later, close `22` and `443` after user confirmed successful SSH on `30022`.

## What happened, in order

## 1) Initial hardening run started

Started broad hardening sequence based on requested document and user direction.

Actions attempted:
- Package installs (security stack)
- SSH hardening config
- Fail2ban setup
- UFW setup
- sysctl hardening
- monitoring scripts/crons

### First blocker
Run stopped at SSH validation with:
- `sshd: command not found`

Root cause:
- `sshd` existed but was not in shell PATH during scripted call.

Fix approach:
- Resolve `sshd` via `/usr/sbin/sshd` fallback.

## 2) Second blocker during firewall phase

Next hardening pass failed with:
- `ufw: command not found`

Root cause:
- `ufw` binary missing from PATH and in that run stage not reliably installed/resolved.

Fix approach:
- Explicit install and explicit binary path fallback to `/usr/sbin/ufw`.

## 3) Key setup flow

User provided public key from Windows:
- `ssh-ed25519 ... admin@DESKTOP-XXXXXX`

Applied on server:
- Created `/root/.ssh`
- Ensured `700` on `/root/.ssh`
- Appended key to `/root/.ssh/authorized_keys`
- Ensured `600` on `authorized_keys`

Verified:
- Key entry present
- Permissions correct

## 4) SSH config state achieved

Configured SSH with hardened file under:
- `/etc/ssh/sshd_config.d/99-hardened.conf`

Key effective directives during migration window:
- `Port 22`
- `Port 30022`
- `PasswordAuthentication no`
- `PubkeyAuthentication yes`
- `AuthenticationMethods publickey`
- `PermitRootLogin prohibit-password`
- `AllowUsers root`

Confirmed with `sshd -T` that both ports and key-only auth were active.

## 5) UFW enforced successfully

UFW active with allow rules:
- `22/tcp`
- `30022/tcp`
- `30080/tcp`
- `443/tcp` (preserved during stabilization)

Defaults:
- deny incoming
- allow outgoing

## 6) Why `30022` still timed out

User still saw:
- `ssh ... -p 30022 ...: Connection timed out`

Diagnostics found:
- SSH listening on `30022`
- UFW allow existed for `30022`
- But packet counters for `30022` were zero initially

Interpretation:
- Traffic was not reaching host for `30022` at that moment (upstream path issue likely).

## 7) Why port `22` later returned `Connection refused`

User then saw:
- `ssh ... -p 22 ...: Connection refused`

Deep diagnosis showed a critical issue:
- `ssh.socket` activation path and binding behavior caused broken IPv4 reachability despite apparent listeners.

Evidence:
- service looked active
- but direct local/public IPv4 `/dev/tcp` checks failed with `Connection refused`

## 8) Critical fix that resolved connectivity

Applied fix:
- Disabled socket activation: `ssh.socket`
- Restarted direct `ssh.service`

Result:
- SSH bound explicitly on:
  - `0.0.0.0:22`
  - `0.0.0.0:30022`
  - and IPv6 equivalents
- Local IPv4 tests passed for both ports
- Public self-connect checks passed for both ports

This was the turning point that made remote login functional.

## 9) User confirmed both ports working

User reported:
- SSH works on both `22` and `30022`.

Then requested final lockdown step:
- close `22`
- close `443`

## 10) Final lock-down applied

Final SSH state:
- Only `30022` listening
- `22` removed from SSH listener

Final UFW inbound allows:
- `30022/tcp`
- `30080/tcp`

Removed from UFW:
- `22/tcp`
- `443/tcp`

Note:
- Local service may still listen on `443` internally, but inbound is blocked by UFW.

## Important config and service state (final)

- `ssh.socket`: disabled/inactive
- `ssh.service`: enabled/active
- `sshd` effective auth: key-only
- root login: allowed only with key
- UFW: active, deny incoming default
- Allowed inbound: only `30022`, `30080`

## Main root causes learned

1. PATH assumptions in automation are unsafe for system binaries.
   - Use absolute paths for `sshd`, `ufw`, `sysctl`, `iptables`.

2. Socket activation can hide real bind behavior and create confusing connectivity states.
   - For predictable remote SSH on VPS, direct `ssh.service` mode is simpler and safer.

3. `timeout` vs `refused` are very different signals.
   - `timeout` suggests path/firewall/upstream drop.
   - `refused` means host reachable but no acceptor on that tuple.

4. Staged migration with dual-port SSH is correct.
   - Keep old port until new port is proven from real client path.

## Commands that mattered most

### SSH debug/verify
- `sshd -t`
- `sshd -T | grep -E 'port|passwordauthentication|authenticationmethods|allowusers|permitrootlogin'`
- `ss -ltnp | grep -E '(:22 |:30022 )'`
- `systemctl status ssh`
- `systemctl status ssh.socket`

### Firewall verify
- `ufw status verbose`
- `iptables -L ufw-user-input -v -n`

### Connectivity sanity checks (local)
- `bash -lc 'exec 3<>/dev/tcp/127.0.0.1/30022'`
- `bash -lc 'exec 3<>/dev/tcp/<public-ip>/30022'`

### Final service-mode correction
- `systemctl disable --now ssh.socket`
- `systemctl restart ssh`

## Final user connect command

```cmd
ssh -i "%USERPROFILE%\.ssh\vps_ed25519" -p 30022 root@123.123.123.123
```

## Closing note

This was painful because several independent issues overlapped:
- missing-path binaries in scripts,
- interrupted hardening phases,
- and most importantly socket-activation SSH behavior causing misleading port status.

Once `ssh.socket` was removed from the path and direct `ssh.service` was used, behavior became deterministic and stable.
