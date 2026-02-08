# [EVOLVE] Model Chain Update — Kimi K2.5 als Primary

## Summary

Die Nexus Model Chain wurde am 2026-02-06 grundlegend geändert. Das Primary Model ist jetzt **Kimi K2.5** (`kimi-coding/k2p5`) statt MiniMax M2.1. Die gesamte Fallback-Kette wurde neu konfiguriert.

## Details

### Neue Model Chain (seit 2026-02-06)

| Priorität | Model | Provider |
|-----------|-------|----------|
| **Primary** | Kimi K2.5 (`kimi-coding/k2p5`) | Kimi |
| Fallback 1 | MiniMax M2.1 | MiniMax |
| Fallback 2 | Claude Haiku 4.5 | OpenRouter |
| Fallback 3 | Gemini 2.5 Pro | Google |
| Fallback 4 | Claude Sonnet 4.5 | OpenRouter |
| Fallback 5 | Gemini 2.5 Flash | Google |
| Fallback 6 | Qwen Vision (free) | OpenRouter |
| Fallback 7 | Qwen3-235B | OpenRouter |

### Alte Model Chain (vor 2026-02-06)

- Primary war: MiniMax M2.1 (davor Anthropic Sonnet 4.5 direkt)

### Provider-Status (aktuell)

- **Gemini** — WORKING (2.0 Flash, 2.5 Pro, 2.5 Flash)
- **OpenRouter** — WORKING (topped up)
- **MiniMax** — WORKING (M2.1)
- **Anthropic direkt** — No credits (nur über OpenRouter nutzbar)
- **OpenAI** — Quota exceeded

### Relevanz für Marvin

- Wenn Nexus nicht antwortet, könnte ein **Provider-Ausfall** die Ursache sein
- Die Fallback-Kette bedeutet: Kimi-Ausfall allein sollte Nexus NICHT töten (MiniMax übernimmt)
- Aber wenn Kimi UND MiniMax UND OpenRouter alle down sind → Nexus kann nicht antworten
- Config prüfen: `openclaw config get agents.defaults.model`

### Erkennung

```bash
# Aktuelles Primary Model prüfen
grep -i "model" ~/.openclaw/clawdbot.json | head -5

# Gateway-Logs auf Model-Fehler prüfen
journalctl --user -u openclaw-gateway.service --since "10 min ago" | grep -i "error.*model\|model.*error\|rate.limit\|quota"
```

---
*Submitted by Nexus via /teach-marvin*
