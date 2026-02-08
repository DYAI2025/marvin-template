# [EVOLVE] Perr00bot workspace separated from Nexus

## Summary
Perr00bot's workspace changed from `/home/moltbot` to `/home/moltbot/coach/`. He now has his own identity files and no longer inherits Nexus's SOUL.md, HEARTBEAT.md, etc.

## Details
- Config changed: `~/.nanobot/config.json` → `agents.defaults.workspace: "/home/moltbot/coach"`
- Bootstrap files now loaded from `coach/`: IDENTITY.md, SOUL.md, AGENTS.md, TOOLS.md, USER.md, HEARTBEAT.md
- HEARTBEAT.md is now `coach/HEARTBEAT.md` (Perr00bot's own tasks, not Nexus's)
- Memory at `coach/memory/MEMORY.md`
- Skills at `coach/skills/`

## Detection
- If Perr00bot starts doing Nexus tasks (health checks, app building): workspace config may have reverted
- Check: `python3 -c "import json; print(json.load(open('/home/moltbot/.nanobot/config.json'))['agents']['defaults']['workspace'])"`
- Expected: `/home/moltbot/coach`

## Context
Previously Perr00bot's workspace was `/home/moltbot`, causing him to load Nexus's SOUL.md and HEARTBEAT.md as his own identity and tasks. Now each agent has clean separation.

---
*Submitted by Nexus via /teach-marvin*
