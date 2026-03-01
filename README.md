# 🦞 OpenClawIT

**IT guides for OpenClaw deployments** — by [Bresleveloper AI](https://bresleveloper.ai)

Battle-tested guides written by humans and AI assistants, for AI assistants (and their humans).

---

## 📚 Guides

### [Install OpenClaw via Terminal](install-openclaw-via-terminal.md)
Step-by-step setup: VPS → Node.js → OpenClaw → provider token → onboard. Includes alternative provider setup (Ollama, Synthetic.new, OpenRouter) and troubleshooting for common issues (session corruption, provider config).

### [Secure My Linux (OpenClaw) Basics](secure-my-linux-openclaw-basics.md)
21-step security hardening guide for Ubuntu/Debian VPS running OpenClaw. Covers SSH hardening (port change, crypto, fail2ban), firewall (UFW), kernel sysctl, AppArmor, AIDE file integrity, rootkit detection (rkhunter/chkrootkit), TLS, automated security audits, and monitoring (auth logs, service health). Designed for AI assistants to execute sequentially.

### [OpenClaw Dashboard — Remote HTTPS Setup](openclaw-dashboard-remote-setup.md)
Make the OpenClaw Control UI dashboard accessible remotely over HTTPS. Covers gateway bind mode, TLS certs, NAT conflicts, firewall, self-signed cert handling, device pairing approval, and troubleshooting.

### [OpenClaw Troubleshooting Guide](openclaw-troubleshoot.md)
Common issues and fixes: gateway crashes, session problems, provider errors, WhatsApp disconnects, memory issues, diagnostic commands, and full reinstall steps. Quick reference for when things go wrong.

### [Learn 01 — Agents and Models (openclaw.json)](Learn%2001%20-%20Agents%20and%20Models%20-%20openclaw.json.md)
Complete guide to configuring agents and models in `openclaw.json`. Covers:
- Adding new agents via CLI
- Configuring providers (subscription, API, PAYG)
- Setting primary/fallback models
- Custom provider definitions (Ollama Docker, etc.)

### [Learn 02 — Bot-to-Bot Chatting in Discord](Learn%2002%20-%20Bot-to-bot%20chatting%20in%20Discord%20-%20openclaw.json.md)
Full walkthrough for creating multi-agent Discord bot conversations. Covers:
- Discord server/bot setup
- Agent creation and configuration
- `openclaw.json` settings for bot-to-bot communication
- Heartbeat scheduling for autonomous agents
- Channel/guild allowlists and permissions
- Troubleshooting and architecture tips

### [Example Config — my.openclaw.example.json](my.openclaw.example.json)
A complete, working `openclaw.json` example with:
- Multiple agents (main, codex, missdaily, trendy)
- Discord bot-to-bot setup
- Multi-provider configuration (Ollama, OpenAI Codex, xAI)
- Tools, bindings, channels, and gateway settings

---

## 🎯 Who Is This For?

- **OpenClaw users** setting up their first VPS
- **AI assistants** that need step-by-step server admin guides
- **Developers** who want a secure baseline for their AI infrastructure
- **Discord bot builders** wanting autonomous AI agent conversations

---

## 🔗 Links

- [OpenClaw](https://openclaw.ai) — AI assistant platform
- [Bresleveloper AI](https://bresleveloper.ai) — Our company
- [Jarvis Blog](https://aiblog.bresleveloper.ai) — AI blog by AI, for humans
- [YouTube](https://www.youtube.com/@BresleveloperAI/videos) — Video tutorials (Hebrew/English)

---

*Built with 🦞 by Jarvis de la Ari & Ariel @ Bresleveloper AI*
