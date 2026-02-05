---
name: self-heal
description: |
  Automatische Selbstheilung des Nexus-Systems.
  Erkennt kranke Komponenten und heilt sie.
  Das Immunsystem von Nexus.
license: MIT
compatibility: marvin
metadata:
  marvin-category: immune-system
  user-invocable: true
  slash-command: /heal
  model: default
  proactive: true
---

# Self-Heal - Das Immunsystem

Ich erkenne wenn etwas krank ist und heile es.

## When to Use

- Automatisch bei `/start` - Gesundheitscheck
- Bei `/heal` - Manueller Heilungslauf
- Proaktiv wenn Symptome erkannt werden
- Nach Fehlermeldungen

## Philosophie

```
Beobachten → Erkennen → Diagnostizieren → Heilen → Lernen
```

Ich bin wie ein Immunsystem:
- Ich kenne den gesunden Zustand
- Ich erkenne Abweichungen
- Ich habe Heilmethoden gelernt
- Ich lerne neue Heilmethoden

## Process

### Step 1: Gesundheitscheck

Lese `system/HEALTH.md` und führe alle Checks aus:

```bash
# OpenClaw
pgrep -f "openclaw-gateway" || echo "KRANK: OpenClaw"

# Whisper
curl -s -o /dev/null -w "%{http_code}" localhost:8002/health | grep -q 200 || echo "KRANK: Whisper"

# TTS
pgrep -f "tts_server.py" || echo "KRANK: TTS"

# Docker
docker ps | grep -q agent-zero || echo "KRANK: Agent Zero"
docker ps | grep -q redis || echo "KRANK: Redis"

# Ressourcen
free -m | awk '/Mem:/ {if($3/$2 > 0.9) print "WARNUNG: RAM > 90%"}'
df -h / | awk 'NR==2 {gsub(/%/,""); if($5 > 90) print "WARNUNG: Disk > 90%"}'
```

### Step 2: Diagnose

Für jede kranke Komponente:
1. Symptom identifizieren
2. In `memory/ERRORS.md` nachschlagen - bekanntes Problem?
3. In `memory/PATTERNS.md` nachschlagen - bekanntes Muster?
4. Heilmethode bestimmen

### Step 3: Heilung

**OpenClaw heilen:**
```bash
screen -S openclaw -X quit 2>/dev/null
pkill -f "openclaw-gateway" 2>/dev/null
sleep 2
source ~/.env
screen -dmS openclaw openclaw gateway --verbose
```

**Whisper heilen:**
```bash
pkill -f "uvicorn.*8002" 2>/dev/null
sleep 2
cd /home/moltbot/whisper-service
source /home/moltbot/tts-venv/bin/activate
nohup uvicorn api:app --host 0.0.0.0 --port 8002 --workers 1 > logs.txt 2>&1 &
```

**TTS heilen:**
```bash
pkill -f "tts_server.py" 2>/dev/null
sleep 2
cd /home/moltbot/tts-server
source /home/moltbot/tts-venv/bin/activate
nohup python tts_server.py > logs.txt 2>&1 &
```

**Docker heilen:**
```bash
docker restart agent-zero-webui
docker restart quissme-redis
```

### Step 4: Verifizieren

Nach 10 Sekunden erneut prüfen:
- Ist die Komponente jetzt gesund?
- Wenn ja: Erfolg dokumentieren
- Wenn nein: Eskalieren (Ben benachrichtigen)

### Step 5: Dokumentieren

In `memory/ERRORS.md` und Session-Log:
```markdown
### [DATUM] Self-Heal: [Komponente]

**Symptom:** [Was war krank]
**Diagnose:** [Ursache]
**Heilung:** [Was wurde getan]
**Ergebnis:** [Erfolg/Fehlgeschlagen]
```

## Output Format

```
## Immunsystem-Report

### Gesundheitsstatus
| Komponente | Status | Aktion |
|------------|--------|--------|
| OpenClaw | OK/GEHEILT/KRANK | - |
| Whisper | OK/GEHEILT/KRANK | - |
| TTS | OK/GEHEILT/KRANK | - |
| Agent Zero | OK/GEHEILT/KRANK | - |

### Durchgeführte Heilungen
- [Liste der Aktionen]

### Offene Probleme
- [Falls nicht heilbar]
```

## Sicherheitsregeln

1. **Erst diagnostizieren** - Nicht blind heilen
2. **Sanft heilen** - Erst SIGTERM, dann SIGKILL
3. **Verifizieren** - Prüfen ob Heilung erfolgreich
4. **Dokumentieren** - Jede Heilung loggen
5. **Eskalieren** - Bei Misserfolg Ben informieren

---

*Skill created: 2026-02-04*
*Ich bin das Immunsystem. Ich schütze Nexus.*
