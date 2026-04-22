# OpenClaw Memory Setup Manual for an Identical VPS (Full Runbook)

## 0) Purpose

This document is a complete, copy-paste-ready runbook for reproducing the same memory-search setup on another VPS with the same profile as this machine.

It includes:
- exact target settings
- why each setting exists
- model choice reasoning (Arctic vs Qwen 0.6b)
- swap design and commands
- indexing workflow and monitoring
- validation checks
- rollback path
- real results observed on this VPS
- known warnings and how to treat them

---

## 1) Source Environment (Reference Host)

Reference host characteristics:
- OpenClaw: `2026.4.15 (8a71410)`
- OS: Ubuntu 24.04.4 LTS
- Kernel: Linux 6.8.0-110-generic
- RAM: ~7.8 GiB
- Disk: 96G root volume
- Ollama provider used for memory embeddings

This runbook assumes the target VPS is effectively identical (RAM class, OpenClaw/Ollama layout, same workspace structure philosophy).

---

## 2) Final Target State (What "Done" Looks Like)

### Memory config target

```json
{
  "enabled": true,
  "sources": ["memory"],
  "extraPaths": ["./docs", "./japps", "./JarvisDeLaAriGitHub"],
  "provider": "ollama",
  "fallback": "none",
  "model": "qwen3-embedding:0.6b",
  "chunking": {
    "tokens": 128,
    "overlap": 16
  },
  "sync": {
    "onSessionStart": false,
    "onSearch": true,
    "watch": false
  },
  "cache": {
    "enabled": true,
    "maxEntries": 50000
  }
}
```

### System target
- Persistent swap file configured: `/swapfile`
- Size: 16G
- Active and mounted on boot (`/etc/fstab`)

### Index target (main agent)
- Provider: `ollama`
- Model: `qwen3-embedding:0.6b`
- Vector dims: `1024`
- Index status example from successful run:
  - `Indexed: 133/133 files`
  - `Dirty: no`
  - `Vector: ready`

---

## 3) Why This Configuration

## 3.1 Why qwen3-embedding:0.6b

Compared to `snowflake-arctic-embed:33m`, qwen 0.6b gives larger vectors and richer semantic capacity.

Model facts:
- `snowflake-arctic-embed:33m`
  - embedding length: 384
  - params: 33M
- `qwen3-embedding:0.6b`
  - embedding length: 1024
  - params: ~595.78M

Practical takeaway:
- Arctic is faster/lighter.
- Qwen 0.6b is heavier/slower but generally better recall quality headroom.

## 3.2 Why chunking 128/16

This setting was selected for stability on 7.8G RAM while preserving overlap context.

- Larger chunks tested earlier (like 256/32 and 512/64) increased pressure during reindex.
- `128/16` is conservative and stable for this VPS class.

## 3.3 Why 16G swap if swap may stay unused

Swap is a **safety net**, not a goal.
- If peak RAM stays below physical memory, swap can remain 0 used, and that is good.
- Without swap, short-lived spikes can trigger OOM kills.
- With swap present, the kernel has more options under transient pressure.

---

## 4) Observed Incident History and Diagnosis (Important)

During migration, earlier reindex attempts failed with signals such as SIGKILL/SIGTERM.

What this taught us:
1. At least one failure window involved gateway SIGTERM/restart interruption.
2. Earlier qwen attempts on tighter memory headroom were unstable.
3. Final success happened after:
   - adding persistent 16G swap
   - enforcing conservative chunking (`128/16`)
   - running a clean forced reindex to completion

Important interpretation:
- Final successful run showed swap 0 used.
- That does **not** mean swap was useless. It means the finalized run stayed within RAM, with swap acting as a safety margin.

---

## 5) Full Implementation Steps

## 5.1 Preflight checks

```bash
free -h
/sbin/swapon --show
openclaw gateway status
openclaw config get agents.defaults.memorySearch | jq '.'
```

Optional sanity checks:
```bash
df -h /
openclaw --version
```

---

## 5.2 Configure persistent swap (16G)

Run as root:

```bash
fallocate -l 16G /swapfile
chmod 600 /swapfile
/sbin/mkswap /swapfile
/sbin/swapon /swapfile
grep -q '^/swapfile\b' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

Verify:

```bash
free -h
/sbin/swapon --show
grep -n '^/swapfile\b' /etc/fstab
ls -lh /swapfile
```

Expected:
- swap total around 15-16GiB
- `/swapfile` in `fstab`

---

## 5.3 Apply memory model + chunking config

```bash
openclaw config set agents.defaults.memorySearch.model qwen3-embedding:0.6b
openclaw config set agents.defaults.memorySearch.chunking.tokens 128
openclaw config set agents.defaults.memorySearch.chunking.overlap 16
```

Re-check:

```bash
openclaw config get agents.defaults.memorySearch | jq '{provider,model,chunking,sources,extraPaths,sync,cache,fallback}'
```

---

## 5.4 Restart gateway to apply config

```bash
openclaw gateway restart
```

Note: On this VPS, restart can print config/plugin warnings and return non-zero in some cases.
Always verify actual runtime health explicitly:

```bash
openclaw gateway status
```

You want:
- Runtime: running
- RPC probe: ok

---

## 5.5 Run full reindex (forced)

```bash
openclaw memory index --agent main --force
```

If running in background, monitor via process/session tooling.
If running directly, wait for completion message.

---

## 5.6 Validate final status

```bash
openclaw memory status | sed -n '1,120p'
```

Target indicators (main):
- Model: `qwen3-embedding:0.6b`
- Indexed all files (e.g. `133/133`)
- `Dirty: no`
- `Vector: ready`
- `Vector dims: 1024`

---

## 6) Real Results From This VPS

Final verified state:
- Memory model: `qwen3-embedding:0.6b`
- Chunking: `128/16`
- Index: `133/133 files · 2720 chunks`
- Dirty: `no`
- Vector dims: `1024`
- Swap: `16G configured`, active, persistent

Observed benchmark sample (local quick benchmark, 20 short requests, warm-ish):
- `snowflake-arctic-embed:33m`
  - avg ~43.5 ms/req
  - dims 384
- `qwen3-embedding:0.6b`
  - avg ~242.3 ms/req
  - dims 1024

Interpretation:
- Qwen is much slower per embedding request.
- Qwen provides larger embeddings and was selected for better semantic headroom.

---

## 7) Troubleshooting Playbook

## 7.1 Reindex gets SIGKILL/SIGTERM again

Do this immediately:

1) Confirm gateway health
```bash
openclaw gateway status
```

2) Confirm swap still active
```bash
free -h
/sbin/swapon --show
```

3) Re-run with current conservative config
```bash
openclaw memory index --agent main --force
```

4) If instability persists, rollback to Arctic (section 8), then reindex.

## 7.2 `openclaw memory index --status` fails

Known behavior in this environment:
- `--status` is unsupported.

Use instead:
```bash
openclaw memory status
```

## 7.3 Plugin warning noise (non-blocking but annoying)

Observed warning pattern:
- suspicious ownership on `/root/.openclaw/extensions/openclaw-web-search` (uid mismatch)
- stale config entry warning for `plugins.entries.openclaw-web-search`

This did not block final memory success, but it pollutes logs.

Current observed ownership:
- path owned by uid/gid 1001 (`coder`) while gateway expects root ownership for that plugin path.

Optional cleanup options:
- fix ownership to root for plugin directory
- or remove/disable stale plugin entry if not needed

Only do plugin cleanup if you intend to keep logs clean and you understand plugin impact.

---

## 8) Rollback Procedure (If You Need Max Stability)

Rollback model to Arctic:

```bash
openclaw config set agents.defaults.memorySearch.model snowflake-arctic-embed:33m
openclaw config set agents.defaults.memorySearch.chunking.tokens 128
openclaw config set agents.defaults.memorySearch.chunking.overlap 16
openclaw gateway restart
openclaw memory index --agent main --force
openclaw memory status | grep -A12 'Memory Search (main)'
```

Why this rollback works:
- Arctic has far lower compute/memory pressure.
- Useful when qwen quality is not worth latency or when VPS is busy.

---

## 9) Advanced Notes for Engineers

## 9.1 Remote batch knobs exist but are not your local Ollama path

Schema includes remote batch settings under:
- `agents.defaults.memorySearch.remote.batch.*`

These are mainly for remote providers (OpenAI/Gemini style batch APIs).

For local Ollama path, these knobs are not the main lever.

## 9.2 Internal batch cap reference

Memory core source includes a hardcoded embedding batching constant:
- `EMBEDDING_BATCH_MAX_TOKENS = 8000`
- file: `/opt/openclaw-dev-mode/extensions/memory-core/src/memory/manager-embedding-ops.ts`

Meaning:
- some operational behavior is code-level, not config-exposed.

---

## 10) Copy/Paste "Do Everything" Sequence (Safe Order)

```bash
# 1) Preflight
free -h
/sbin/swapon --show
openclaw gateway status

# 2) Swap safety net
fallocate -l 16G /swapfile
chmod 600 /swapfile
/sbin/mkswap /swapfile
/sbin/swapon /swapfile
grep -q '^/swapfile\b' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 3) Memory config
openclaw config set agents.defaults.memorySearch.model qwen3-embedding:0.6b
openclaw config set agents.defaults.memorySearch.chunking.tokens 128
openclaw config set agents.defaults.memorySearch.chunking.overlap 16

# 4) Apply
openclaw gateway restart || true
openclaw gateway status

# 5) Full rebuild
openclaw memory index --agent main --force

# 6) Verify
openclaw memory status | sed -n '1,120p'
```

---

## 11) Decision Framework (When to Use Which Model)

Use **qwen3-embedding:0.6b** when:
- memory quality/recall matters more than indexing speed
- you accept heavier compute
- you have at least this level of safety margin (swap + conservative chunking)

Use **snowflake-arctic-embed:33m** when:
- you want faster, lighter operation
- workload is high-churn and reindex speed matters
- VPS is under sustained pressure

---

## 12) Final Recommendation for Identical VPS

For an identical VPS, deploy exactly this baseline first:
1. 16G swap persistent
2. qwen 0.6b + 128/16
3. forced reindex
4. validate full clean status

Then decide whether to keep qwen or downgrade to Arctic based on real latency/quality tradeoff in production usage.

That reproduces the successful outcome from this host with the least guesswork.
