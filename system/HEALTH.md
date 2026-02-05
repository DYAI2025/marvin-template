# System-Gesundheit

Was bedeutet "gesund" für Nexus?

---

## Gesundheits-Checks

### OpenClaw Gateway

| Check | Befehl | Gesund | Krank |
|-------|--------|--------|-------|
| Prozess läuft | `pgrep -f "openclaw-gateway"` | PID zurück | Leer |
| Port offen | `lsof -i :18789` | LISTEN | Nichts |
| Screen aktiv | `screen -ls \| grep openclaw` | Detached | Nicht gefunden |

**Selbstheilung:**
```bash
screen -S openclaw -X quit 2>/dev/null
source ~/.env
screen -dmS openclaw openclaw gateway --verbose
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
| Redis läuft | `docker ps \| grep redis` | Up | Nicht gefunden |

**Selbstheilung:**
```bash
docker restart agent-zero-webui
docker restart quissme-redis
```

---

## Ressourcen-Grenzen

| Ressource | Warnung | Kritisch | Aktion |
|-----------|---------|----------|--------|
| RAM | > 80% | > 95% | Prozesse neustarten |
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

---

## API-Gesundheit

| API | Check | Gesund |
|-----|-------|--------|
| MiniMax | Token-Balance > 0 | Antworten kommen |
| Anthropic | Token-Balance > 0 | Antworten kommen |
| OpenAI (Whisper) | API Key gültig | Transkription funktioniert |

**Symptome bei API-Problemen:**
- Lange Antwortzeiten
- Timeouts
- "Rate limit" Fehler
- Leere Antworten

---

## Symptom → Diagnose

| Symptom | Wahrscheinliche Ursache | Check |
|---------|------------------------|-------|
| Nexus antwortet nicht | Gateway down | `pgrep openclaw` |
| Lange Stille (20-30min) | API-Tokens leer | Logs prüfen |
| Voice wird nicht erkannt | Whisper down | `curl localhost:8002/health` |
| Kein Audio zurück | TTS down | `pgrep tts_server` |
| Agent Zero reagiert nicht | Docker Container | `docker ps` |

---

*Dieses Dokument wird durch Learnings erweitert.*
