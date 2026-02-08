# [LEARN] Perr00bot Behavior Patterns — Common Failure Modes

## Summary
Perr00bot (the Coach agent on Nanobot) has recurring behavior issues that follow predictable patterns. This documents the 3 most common failure modes and how to detect/fix them.

## Failure Mode 1: Context Loss / Hallucination
- **Symptoms:** Perr00bot starts talking about unrelated topics (e.g. enrolling user at University of South Dakota), loses track of conversation, outputs nonsensical responses
- **Cause:** Wrong model — coding-only models (qwen3-coder, etc.) hallucinate wildly in conversation
- **Detection:** Monitor Telegram responses for off-topic content; check `~/.nanobot/config.json` → `agents.defaults.model` — if it contains "coder" in the name, it's wrong
- **Fix:** Switch model to `gemini/gemini-2.0-flash` in config, restart gateway
- **Rule:** NEVER use coding-only models for Perr00bot

## Failure Mode 2: Identity Confusion
- **Symptoms:** Perr00bot thinks he's Nexus, reads wrong HEARTBEAT.md/SOUL.md, takes on Nexus's tasks
- **Cause:** Workspace path misconfigured — reading root `~/SOUL.md` instead of `~/coach/SOUL.md`
- **Detection:** Check `~/.nanobot/config.json` → `agents.defaults.workspace` — must be `/home/moltbot/coach`
- **Fix:** Ensure workspace points to `/home/moltbot/coach/`, verify all identity files exist in `coach/` directory (AGENTS.md, IDENTITY.md, SOUL.md, USER.md, MEMORY.md, perr00bot-system.md)

## Failure Mode 3: "Can't Code / Can't Deploy" + Excessive Link Spam
- **Symptoms:** Perr00bot says he cannot write code or deploy, defers everything to user; sends random internet links with every response
- **Cause:** System prompt (`coach/perr00bot-system.md`) too restrictive or missing tool permissions; search behavior unconstrained
- **Detection:** User reports Perr00bot is unhelpful or spammy
- **Fix:** Update `coach/perr00bot-system.md` — add exec/code permissions, add guardrail against unsolicited link sharing

## Relevant Files
- Config: `~/.nanobot/config.json`
- System prompt: `/home/moltbot/coach/perr00bot-system.md`
- Identity: `/home/moltbot/coach/AGENTS.md`, `SOUL.md`, `IDENTITY.md`
- Memory: `/home/moltbot/coach/MEMORY.md`
- Gateway port: 18791

## Recommended Action
When detecting Perr00bot issues:
1. Check model in config (not a coder model?)
2. Check workspace path (points to /home/moltbot/coach?)
3. Check if gateway is running: `curl -s localhost:18791`
4. If model/workspace wrong → fix config → `pkill -f "nanobot gateway"` → restart

---
*Submitted by Claude Code via /teach-marvin on 2026-02-08*
