# [SYSTEM] Agent Zero Steuerung

## Summary
Agent Zero ist ein autonomer AI-Agent, der als Docker-Container läuft. Hier sind alle Befehle zur Steuerung.

## Details

### Container-Info
- **Name:** agent-zero
- **Image:** agent0ai/agent-zero
- **Port:** 127.0.0.1:5000 → 80/tcp (intern)
- **Data Mount:** /opt/agent-zero-data → /a0 (im Container)
- **Source Code:** /home/moltbot/QuissMe

### Befehle

**Status prüfen:**
```bash
docker ps | grep agent-zero
# Oder:
curl -s localhost:5000 > /dev/null && echo "Agent Zero: UP" || echo "Agent Zero: DOWN"
```

**Starten:**
```bash
docker start agent-zero
```

**Stoppen:**
```bash
docker stop agent-zero
```

**Neustarten:**
```bash
docker restart agent-zero
```

**Logs ansehen:**
```bash
docker logs -f agent-zero        # Live-Logs
docker logs --tail 100 agent-zero  # Letzte 100 Zeilen
```

**In Container gehen (Debug):**
```bash
docker exec -it agent-zero /bin/bash
```

### Health Check für Marvin
```bash
# Einfacher Check
curl -s localhost:5000 > /dev/null && echo "UP" || echo "DOWN"

# Mit Auto-Restart wenn down
if ! curl -s localhost:5000 > /dev/null 2>&1; then
    echo "Agent Zero DOWN - starte neu..."
    docker restart agent-zero
    sleep 5
    curl -s localhost:5000 > /dev/null && echo "Wieder UP" || echo "FEHLER: Neustart fehlgeschlagen"
fi
```

### Unterschied zu OpenClaw Gateway

| | OpenClaw Gateway | Agent Zero |
|---|---|---|
| Prozess | screen `openclaw` | Docker Container |
| Port | 18789 | 5000 |
| Neustart | `screen -S openclaw -X quit && screen -dmS openclaw openclaw gateway --verbose` | `docker restart agent-zero` |
| Logs | `screen -r openclaw` | `docker logs -f agent-zero` |

## Context
Agent Zero ist das "Denken" von Nexus - ein autonomer Agent der komplexe Aufgaben selbstständig löst. OpenClaw Gateway ist das "Sprechen" - die Messaging-Brücke zu WhatsApp/Telegram etc.

Wenn Nexus nicht antwortet, beide prüfen:
1. `curl -s localhost:18789` → Gateway
2. `curl -s localhost:5000` → Agent Zero

---
*Submitted by Claude Code via /teach-marvin*
