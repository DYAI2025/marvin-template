# System-Gesundheit

Was bedeutet "gesund" für Nexus?

---

## Gesundheits-Checks

### OpenClaw Gateway (systemd user service)

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Service aktiv | `systemctl --user is-active openclaw-gateway.service` | active | inactive/failed |
| Port offen | `curl -s --max-time 3 localhost:18789` | Response | Timeout |
| Prozess läuft | `pgrep -f "openclaw-gateway"` | PID zurück | Leer |

**Zombie-Erkennung (Prozess da, Port tot):**
```bash
pgrep -f "openclaw" && ! curl -s --max-time 2 localhost:18789 > /dev/null && echo "GATEWAY HÄNGT!"
```

**Compaction-Timeout-Erkennung:**
```bash
journalctl --user -u openclaw-gateway.service --since "10 min ago" | grep -c "Skipping auto-reply"
# Wenn > 3 → Gateway hängt in Compaction
```

**Selbstheilung:**
```bash
systemctl --user restart openclaw-gateway.service
```

---

### Whisper STT Service

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -f "uvicorn.*8002"` | PID | Leer |
| Health-Endpoint | `curl -s localhost:8002/health` | 200 OK | Timeout/Error |

**Selbstheilung:**
```bash
cd /home/moltbot/whisper-service
source /home/moltbot/tts-venv/bin/activate
pkill -f "uvicorn.*8002"
nohup uvicorn api:app --host 0.0.0.0 --port 8002 --workers 1 > logs.txt 2>&1 &
```

---

### TTS Server

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -f "tts_server.py"` | PID | Leer |

**Selbstheilung:**
```bash
cd /home/moltbot/tts-server
source /home/moltbot/tts-venv/bin/activate
pkill -f "tts_server.py"
nohup python tts_server.py > logs.txt 2>&1 &
```

---

### Agent Zero (Docker)

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Container läuft | `docker ps \| grep agent-zero` | Up | Nicht gefunden |
| Port erreichbar | `curl -s localhost:50080 > /dev/null && echo UP` | UP | Timeout |

**Container-Details:**
- **Name:** agent-zero
- **Image:** agent0ai/agent-zero
- **Port:** 127.0.0.1:50080 → 80/tcp (intern)
- **Data Mount:** /opt/agent-zero-data → /a0
- **Source Code:** /home/moltbot/QuissMe

**Selbstheilung:**
```bash
docker restart agent-zero
# Verifizieren nach 5 Sek:
sleep 5 && curl -s localhost:50080 > /dev/null && echo "Agent Zero: UP" || echo "FEHLER"
```

---

### Coach / Perr00bot (Nanobot)

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -u moltbot -f "nanobot gateway"` | PID | Leer |
| Telegram-Session aktuell | `find ~/.nanobot/sessions/telegram_*.jsonl -mmin -30` | Datei gefunden | Nichts |

**Config:** `~/.nanobot/config.json`
**Model:** `gemini/gemini-2.0-flash`
**Telegram Chat ID:** 8177545205

**Selbstheilung:**
```bash
pkill -f "nanobot gateway" 2>/dev/null
sleep 2
cd /home/moltbot && nanobot gateway --verbose --port 18791 &
# Verifizieren nach 10 Sek:
sleep 10 && pgrep -u moltbot -f "nanobot gateway" && echo "PERR00BOT GEHEILT"
```

**Session zu groß?**
```bash
cp ~/.nanobot/sessions/telegram_8177545205.jsonl \
   ~/.nanobot/sessions/telegram_8177545205.jsonl.backup.$(date +%Y%m%d_%H%M%S)
tail -100 ~/.nanobot/sessions/telegram_8177545205.jsonl > /tmp/session-trimmed.jsonl
mv /tmp/session-trimmed.jsonl ~/.nanobot/sessions/telegram_8177545205.jsonl
```

---

### Claude Code

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -f "^claude$"` | PID(s) | Leer |
| MCP Server (Memory) | `pgrep -f "mcp-server.cjs"` | PID | Leer |

**Wichtig:** Claude Code ist Marvins "großer Bruder" - wenn er läuft, kann er Marvin steuern.

**Warnung: Claude-Prozess-Überflutung**
- Mehr als 3 Claude-Prozesse = Warnung
- `CLAUDE_MEM_PROVIDER` muss `gemini` sein, NICHT `claude` (sonst ~250MB Orphan-Prozesse)

**Prozess-Cleanup bei Überflutung (RAM > 85%):**
```bash
pgrep -u moltbot -c claude  # Anzahl prüfen
pgrep -u moltbot claude | head -n -2 | xargs -r kill -15  # Älteste killen
```

---

### Planka (Projekt-Management)

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Container läuft | `docker ps \| grep planka` | Up | Nicht gefunden |
| Port erreichbar | `curl -s localhost:18790 > /dev/null && echo UP` | UP | Timeout |
| PostgreSQL | `docker ps \| grep postgres` | Up | Nicht gefunden |

**Selbstheilung:**
```bash
cd ~/planka && docker-compose restart
```

---

### Ollama (Lokales LLM)

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -f ollama` | PID | Leer |
| Port offen | `curl -s localhost:11434` | Response | Timeout |

**Priorität: NIEDRIG** — Kann gestoppt werden wenn RAM knapp.

**RAM-Verbrauch:** 500-800MB wenn aktiv.

**Stoppen bei RAM > 85%:**
```bash
systemctl stop ollama || pkill -f ollama
```

---

## Ressourcen-Grenzen

| Ressource | Warnung | Kritisch | Aktion |
|-----------|---------|----------|--------|
| RAM | > 80% | > 95% | Ollama stoppen, Claude-Prozesse cleanup |
| Disk | > 80% | > 95% | Logs aufräumen |
| CPU | > 90% (5min) | > 95% (5min) | Lastverursacher finden |

**Check-Befehle:**
```bash
# RAM
free -m | awk '/Mem:/ {print $3/$2 * 100}'

# Disk
df -h / | awk 'NR==2 {print $5}' | tr -d '%'

# CPU (Load Average)
uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $1}'
```

**RAM-Triage-Reihenfolge (bei Knappheit):**
1. Ollama stoppen (niedrigste Prio, 500-800MB)
2. Orphan Claude-Prozesse killen
3. Agent Zero neustarten (gibt temporär RAM frei)
4. Gateway neustarten (letzter Ausweg)

---

## API-Gesundheit

| Provider | Status | Models |
|----------|--------|--------|
| Kimi | Primary | K2.5 |
| MiniMax | Working | M2.1 |
| Gemini | Working | 2.0 Flash, 2.5 Pro, 2.5 Flash |
| OpenRouter | Working (topped up) | Claude Haiku/Sonnet via OR |
| Anthropic direct | No credits | - |
| OpenAI | Quota exceeded | - |

**Symptome bei API-Problemen:**
- Lange Antwortzeiten
- Timeouts
- "Rate limit" Fehler
- Leere Antworten

---

## Symptom → Diagnose

| Symptom | Wahrscheinliche Ursache | Check |
|---------|------------------------|-------|
| Nexus antwortet nicht | Gateway down oder Zombie | `systemctl --user status openclaw-gateway.service` |
| Lange Stille (10-40 min) | Compaction-Timeout | Logs: "Skipping auto-reply" |
| Lange Stille (20-30 min) | API-Tokens leer | Provider-Logs prüfen |
| Voice wird nicht erkannt | Whisper down | `curl localhost:8002/health` |
| Kein Audio zurück | TTS down | `pgrep tts_server` |
| Agent Zero reagiert nicht | Docker Container | `docker ps \| grep agent-zero` |
| Planka nicht erreichbar | Container down | `docker ps \| grep planka` |
| System sehr langsam | RAM voll, zu viele Prozesse | `free -m`, `pgrep -c claude` |
| kswapd0 in top | RAM voll, Swap-Storm | Ollama stoppen, Claude cleanup |
| Coach antwortet nicht | Nanobot down | `pgrep -f "nanobot gateway"` |

---

*Dieses Dokument wird durch Learnings erweitert.*
*Letzte Aktualisierung: 2026-02-07*
