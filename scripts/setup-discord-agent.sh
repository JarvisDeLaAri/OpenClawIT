#!/usr/bin/env bash
set -euo pipefail

# ── Constants ──
OWNER_ID="1059...your user id"
GUILD_ID="147... your server id"
CONFIG="/root/.openclaw/openclaw.json"

# ── Usage ──
usage() {
  echo "Usage: $0 <agent> <token> <userId> <channelId> [workspace-prefix]"
  echo ""
  echo "  agent            Agent name (e.g. marketing-cold-emails)"
  echo "  token            Discord bot token"
  echo "  userId           Discord bot user ID (= appId)"
  echo "  channelId        Discord channel ID for this agent"
  echo "  workspace-prefix Workspace parent folder name (optional, e.g. software-company)"
  exit 1
}

[[ $# -lt 4 ]] && usage

AGENT="$1"
TOKEN="$2"
USER_ID="$3"
CHANNEL_ID="$4"
PREFIX="${5:-}"

if [[ -n "$PREFIX" ]]; then
  WORKSPACE="/root/.openclaw/${PREFIX}/workspace-${AGENT}"
else
  WORKSPACE="/root/.openclaw/workspace-${AGENT}"
fi

echo "=== Setting up agent: ${AGENT} ==="

# ── Step 1: Create agent via openclaw CLI ──
if jq -e ".agents.list[] | select(.id == \"${AGENT}\")" "$CONFIG" >/dev/null 2>&1; then
  echo "[skip] Agent '${AGENT}' already in agents.list"
else
  echo "[1/4] Creating agent..."
  openclaw agents add "$AGENT" --workspace "$WORKSPACE"
  echo "[ok] Agent created"
fi

# ── Step 2: Wake agent ──
echo "[2/4] Waking agent..."
openclaw agent --agent "$AGENT" --message "wake up"
echo "[ok] Agent woken"

# ── Step 3: Backup config ──
cp "$CONFIG" "${CONFIG}.bak"

# ── Step 4: Add binding (if not exists) ──
if jq -e ".bindings[]? | select(.agentId == \"${AGENT}\")" "$CONFIG" >/dev/null 2>&1; then
  echo "[skip] Binding for '${AGENT}' already exists"
else
  echo "[3/4] Adding binding..."
  jq --arg agent "$AGENT" '
    .bindings = (.bindings // []) + [{
      agentId: $agent,
      match: {
        channel: "discord",
        accountId: $agent
      }
    }]
  ' "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
  echo "[ok] Binding added"
fi

# ── Step 5: Add discord account config (if not exists) ──
if jq -e ".channels.discord.accounts[\"${AGENT}\"]" "$CONFIG" >/dev/null 2>&1; then
  echo "[skip] Discord account '${AGENT}' already configured"
else
  echo "[4/4] Adding Discord account config..."
  jq --arg agent "$AGENT" \
     --arg token "$TOKEN" \
     --arg uid "$USER_ID" \
     --arg chid "$CHANNEL_ID" \
     --arg owner "$OWNER_ID" \
     --arg guild "$GUILD_ID" '
    .channels.discord.accounts[$agent] = {
      name: $agent,
      token: $token,
      groupPolicy: "allowlist",
      streaming: "off",
      allowFrom: [
        $uid,
        ("discord:user:" + $uid),
        $owner,
        ("discord:user:" + $owner)
      ],
      guilds: {
        ($guild): {
          users: [$uid, $owner],
          channels: {
            ($chid): {
              allow: true,
              requireMention: false
            }
          }
        }
      }
    }
  ' "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
  echo "[ok] Discord account configured"
fi

echo "=== Done: ${AGENT} ==="
