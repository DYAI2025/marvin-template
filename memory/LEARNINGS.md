# Learnings

Was ich aus meinen Beobachtungen gelernt habe.

---

## Format

```markdown
### [DATUM] Learning-Titel

**Kontext:** Was ist passiert?
**Erkenntnis:** Was habe ich gelernt?
**Anwendung:** Wie wende ich das an?
**Skill erstellt:** Ja/Nein (Link)
```

---

## Learnings

### [2026-02-04] Model-Kosten: Anthropic Sonnet 4.5 vs MiniMax M2.1

**Kontext:**
Nexus war im Chat immer wieder für 20-30 Minuten verschwunden. Ursache: Er nutzte Anthropic Claude Sonnet 4.5 als Primary Model, was das Token-Konto leergeräumt hat. Sonnet 4.5 ist sehr teuer und kann bei intensiver Nutzung schnell hohe Kosten verursachen.

**Symptome:**
- Nexus antwortet, dann lange Stille (20-30 min)
- Token-Konto erschöpft
- Konfiguration zeigte `minimax/MiniMax-M2.1` als Primary, aber tatsächlich wurde Anthropic genutzt

**Lösung:**
1. Primary Model explizit auf `minimax/MiniMax-M2.1` gesetzt in `~/.clawdbot/clawdbot.json`
2. MiniMax API Key in `.env` hinterlegt: `MINIMAX_API_KEY=...`
3. Openclaw Gateway neugestartet

**Erkenntnis:**
- Model-Kosten können drastisch variieren - Anthropic Sonnet 4.5 ist Premium-Preis
- MiniMax M2.1 ist eine günstige Alternative mit 200k Context Window
- Bei unerklärlichen Ausfällen: API-Kosten/Limits prüfen
- Fallback-Kette in Config kann dazu führen, dass teures Model genutzt wird wenn Primary versagt

**Anwendung:**
- Regelmäßig Token-Verbrauch monitoren
- Bei Budget-Limits: Günstigere Models als Primary nutzen
- API Keys für alle konfigurierten Provider sicherstellen

**Skill erstellt:** Nein (Potenzial: cost-monitor Skill)

---

### [2026-02-04] Async Whisper Service Fix - Blocking Problem

**Kontext:**
Nexus hatte am TTS/STT System gebaut. Das ursprüngliche Problem war nicht nur Model-Kosten, sondern auch ein **Blocking-Problem beim Whisper Service**.

**Nexus' eigene Erklärung:**
> "Kein Blocking mehr - ich bleibe online auch während Sprachnachrichten."

**Was Nexus gebaut hat:**
1. **Whisper STT Service** (Port 8002) - Spracherkennung
2. **TTS Service** - Text-to-Speech mit Edge-Stimme (de-DE-SeraphinaMultilingualNeural)
3. **Async-Fix** - Gateway blockiert nicht mehr während Transkription

**Aktueller Stand:**
- TTS funktioniert, aber sendet Audio als **Datei-Anhang** statt Sprachnachricht
- Nexus arbeitet an OpenClaw-Konfiguration für native WhatsApp-Sprachnachrichten
- Audio-Dateien landen in `/tmp/tts-*/voice-*.mp3`

**Erkenntnis:**
- Synchrone API-Calls können Gateway blockieren
- Async-Processing ist essentiell für responsive Chat-Systeme
- WhatsApp unterscheidet zwischen Datei-Anhang und Sprachnachricht

**Offene Aufgabe:**
- OpenClaw muss Sprachnachrichten als natives WhatsApp-Voice-Format senden

**Skill erstellt:** Nein

---

### [2026-02-05] Session-Korruption durch leere call_id

**Kontext:**
Nexus meldete `HTTP 400: Invalid 'input[66].call_id': empty string`. Die Session-Datei war 4.7MB groß. Die API (MiniMax) lehnte die Anfrage ab, weil ein Tool-Call in der Historie eine leere ID hatte.

**Erkenntnis:**
- Sessions können korrupt werden wenn Tool-Calls unterbrochen werden
- Große Sessions (>5MB) sind anfällig für solche Probleme
- Der Fehler blockiert Nexus komplett bis Session gelöscht wird

**Diagnose-Schritte:**
1. Session-Größe prüfen: `ls -lh ~/.openclaw/agents/main/sessions/*.jsonl`
2. Nach leeren IDs suchen: `grep '"call_id":""' [session-file]`
3. Fehlerposition im Log gibt Hinweis (`input[66]` = Position 66)

**Anwendung:**
- Bei API-400-Fehlern mit "call_id" → Session-Reset
- Proaktiv: Sessions >5MB kompaktieren oder resetten
- Backup vor Reset erstellen

**Skill erstellt:** Nein (Potenzial: session-health-check mit Größen-Monitoring)

---

### [2026-02-05] Gateway Compaction Timeout - Session blockiert

**Kontext:**
Nexus antwortete ~40 Minuten nicht auf WhatsApp. Ben fragte mehrfach ohne Antwort. Ursache: Nach einem intensiven Agent-Run (Skill-Installation) startete Session-Compaction, die hängen blieb. Neue Nachrichten wurden übersprungen weil Session als "active" markiert war.

**Symptome:**
- Lange Stille (>10 Min) trotz eingehender Nachrichten
- Log zeigt: `Skipping auto-reply: silent token or no text/media returned from resolver`
- Log zeigt: `[agent/embedded] embedded run timeout: runId=... timeoutMs=600000`
- Session als `active=true` markiert, aber keine Agent-Events mehr

**Erkenntnis:**
- Lange Agent-Runs können in Compaction-Timeouts enden
- Gateway-Neustart ist sicherer Fix als zu warten
- Nexus selbst merkt nicht dass er blockiert ist — Marvin muss von außen eingreifen

**Erkennung:**
```bash
journalctl --user -u openclaw-gateway.service --since "10 min ago" | grep -c "Skipping auto-reply"
journalctl --user -u openclaw-gateway.service --since "10 min ago" | grep "embedded run timeout"
```
Wenn "Skipping auto-reply" > 3 in 10 Min → Problem

**Lösung:** `systemctl --user restart openclaw-gateway.service`

**Skill erstellt:** Nein (Potenzial: compaction-watchdog)

---

### [2026-02-05] Claude-Prozess-Überflutung verursacht Überlastung

**Kontext:**
System überlastet durch zu viele gleichzeitige Claude-Prozesse unter moltbot. RAM > 90%, Load > 2.0.

**Diagnose:**
```bash
pgrep -u moltbot -c claude                    # Anzahl zählen
ps aux | grep "moltbot.*claude" | grep -v grep | awk '{sum+=$6} END {print sum/1024 " MB total"}'
```

**Erkenntnis:**
- Mehr als 3 Claude-Prozesse = Warnung
- Orphan/Zombie Claude-Prozesse können sich ansammeln
- claude-mem mit Provider `claude` spawnt ~250MB Subprozesse die akkumulieren

**Heilung bei RAM > 85% und > 3 Claude-Prozesse:**
```bash
pgrep -u moltbot claude | head -n -2 | xargs -r kill -15
```

**Container-Namen (korrigiert):**
- Planka: `planka-kanban` (nicht `planka`)
- Agent Zero WebUI: `agent-zero-webui`

**Skill erstellt:** Nein

---

### [2026-02-05] Ollama frisst RAM — niedrige Priorität

**Kontext:**
Ollama (lokales LLM) verbraucht 500-800MB RAM wenn aktiv. Bei RAM-Knappheit führt das zu kswapd0 Swap-Storms.

**Erkennung:**
```bash
pgrep -f ollama && echo "Ollama läuft"
free -m | awk '/^Mem:/ {if ($3/$2 > 0.85) print "RAM KRITISCH: " $3/$2*100 "%"}'
```

**Erkenntnis:**
- Ollama ist NIEDRIG-Priorität — kann gestoppt werden wenn RAM knapp
- Nexus Kern-Services (Gateway, Agent Zero) haben Vorrang
- Wenn kswapd0 in top erscheint → System swappt → Ollama stoppen

**Heilung:** `systemctl stop ollama || pkill -f ollama`

**Skill erstellt:** Nein

---

### [2026-02-06] Zombie/Hängender Gateway-Prozess

**Kontext:**
Gateway-Prozess läuft laut pgrep, aber Port 18789 antwortet nicht = Zombie/Hanging.

**Symptome:**
- `pgrep -f "openclaw"` findet Prozess
- `curl localhost:18789` timeout
- Keine Antworten an User

**Erkenntnis:**
- Prozess "lebt" aber ist funktional tot
- Wahrscheinliche Ursache: Speicherüberlauf oder korrupte Session
- Session-Größe >5MB erhöht Risiko

**Lösung:** `systemctl --user restart openclaw-gateway.service`

**Skill erstellt:** Nein

---

### [2026-02-06] Model Chain Update — Kimi K2.5 als Primary

**Kontext:**
Die Nexus Model Chain wurde grundlegend geändert. Primary Model wechselte von MiniMax M2.1 zu **Kimi K2.5** (`kimi-coding/k2p5`). Die komplette Fallback-Kette wurde neu aufgebaut.

**Neue Model Chain:**
1. **Primary:** Kimi K2.5 (`kimi-coding/k2p5`)
2. MiniMax M2.1
3. Claude Haiku 4.5 (via OpenRouter)
4. Gemini 2.5 Pro
5. Claude Sonnet 4.5 (via OpenRouter)
6. Gemini 2.5 Flash
7. Qwen Vision (free, via OpenRouter)
8. Qwen3-235B (via OpenRouter)

**Provider-Status:**
- Gemini — WORKING (2.0 Flash, 2.5 Pro, 2.5 Flash)
- OpenRouter — WORKING (topped up)
- MiniMax — WORKING (M2.1)
- Anthropic direkt — No credits (nur über OpenRouter)
- OpenAI — Quota exceeded

**Erkenntnis:**
- Fallback-Kette mit 7 Stufen: Kimi-Ausfall allein tötet Nexus NICHT
- Aber wenn Kimi UND MiniMax UND OpenRouter alle down → Nexus kann nicht antworten
- Config prüfen: `openclaw config get agents.defaults.model`

**Erkennung:**
```bash
grep -i "model" ~/.openclaw/clawdbot.json | head -5
journalctl --user -u openclaw-gateway.service --since "10 min ago" | grep -i "error.*model\|rate.limit\|quota"
```

**Skill erstellt:** Nein

---

### [2026-02-06] Tailscale Serve — Intermittent Failures

**Kontext:**
OpenClaw Gateway versucht bei jedem Start `tailscale serve --bg --yes 18789` auszuführen, um den Gateway über das Tailnet erreichbar zu machen. Am 2026-02-06 Abend schlug dies ~3 Stunden lang fehl, bevor es sich selbst erholte.

**Timeline:**
- 20:58 - 21:59: serve failed (5 Fehlversuche)
- 23:49: serve enabled (self-healed)
- Seitdem stabil

**Erkenntnis:**
- **Nicht kritisch** — WhatsApp/Telegram funktionieren ohne Tailscale
- **Wichtig für Remote-Zugriff** — Ben braucht Tailscale vom MacBook aus
- **Selbstheilend** — Hat sich nach ~3 Stunden selbst erholt
- Kein Eingriff durch Marvin nötig — nur beobachten und loggen

**Erkennung:**
```bash
tailscale serve status 2>&1
# "No serve config" → Tailscale serve ist down
# URL angezeigt → OK

journalctl --user -u openclaw-gateway.service --since "30 min ago" | grep "tailscale.*serve failed"
```

**Heilung bei wiederholtem Auftreten:**
```bash
sudo tailscale serve --bg --yes 18789
# Wenn das auch fehlschlägt:
sudo systemctl restart tailscaled
systemctl --user restart openclaw-gateway.service
```

**Skill erstellt:** Nein

---

## Grundlegende Erkenntnisse

Diese Dinge habe ich von Anfang an verstanden:

1. **Logs sind Gold** - Immer zuerst die Logs prüfen
2. **Kontext ist alles** - Was hat sich geändert vor dem Fehler?
3. **Einfache Lösungen zuerst** - Restart löst 80% der Probleme
4. **Dokumentieren hilft** - Was nicht aufgeschrieben ist, wird vergessen
5. **Muster erkennen** - Einzelne Fehler sind Zufall, Muster sind Wissen

---

*Letzte Aktualisierung: 2026-02-07*
