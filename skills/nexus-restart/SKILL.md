---
name: nexus-restart
description: |
  Startet Nexus-Komponenten (Clawdbot Gateway, Agent Zero) neu.
  Nur bei bestätigtem Ausfall oder auf Anfrage.
license: MIT
compatibility: marvin
metadata:
  marvin-category: watchdog
  user-invocable: true
  slash-command: /restart
  model: default
  proactive: false
---

# Nexus Restart

Startet ausgefallene Nexus-Komponenten kontrolliert neu.

## When to Use

- Prozess ist abgestürzt (nicht mehr erreichbar)
- Nach einem erkannten Fehler
- Auf explizite Anfrage (`/restart`)
- NICHT automatisch ohne Bestätigung

## Komponenten

| Komponente | Verzeichnis | Start-Befehl |
|------------|-------------|--------------|
| Clawdbot Gateway | `/home/moltbot/projects/clawdbot` | `pnpm clawdbot gateway --port 18789` |
| Agent Zero | `/home/moltbot/QuissMe` | `python run_ui.py` |

## Process

### Step 1: Status prüfen

Erst prüfen ob wirklich down:
```bash
# Clawdbot
pgrep -f "gateway" && curl -s http://localhost:18789/health

# Agent Zero
pgrep -f "run_ui.py" && curl -s http://localhost:5000/health
```

### Step 2: Bestätigung einholen

**WICHTIG:** Immer erst fragen:

```
Nexus-Komponente [NAME] scheint nicht zu laufen.
Soll ich sie neustarten?

Befehle die ausgeführt werden:
1. [Cleanup-Befehl]
2. [Start-Befehl]

Fortfahren? (ja/nein)
```

### Step 3: Cleanup

Alte Prozesse aufräumen:
```bash
# Zombie-Prozesse beenden (sanft)
pkill -f "gateway" 2>/dev/null || true
pkill -f "run_ui.py" 2>/dev/null || true

# Ports freigeben (falls nötig)
fuser -k 18789/tcp 2>/dev/null || true
fuser -k 5000/tcp 2>/dev/null || true

# Kurz warten
sleep 2
```

### Step 4: Neustart

```bash
# Clawdbot Gateway
cd /home/moltbot/projects/clawdbot
nohup pnpm clawdbot gateway --port 18789 > /home/moltbot/clawdbot.log 2>&1 &

# Agent Zero
cd /home/moltbot/QuissMe
nohup python run_ui.py > /home/moltbot/agent-zero.log 2>&1 &
```

### Step 5: Verifizieren

Nach 10 Sekunden prüfen:
```bash
sleep 10

# Prozess läuft?
pgrep -f "gateway" && echo "Gateway: OK"
pgrep -f "run_ui.py" && echo "Agent Zero: OK"

# Port erreichbar?
curl -s http://localhost:18789/health && echo "Gateway Health: OK"
curl -s http://localhost:5000/health && echo "Agent Zero Health: OK"
```

### Step 6: Dokumentieren

In `memory/ERRORS.md` eintragen:
```markdown
### [DATUM] Nexus Restart: [KOMPONENTE]

**Grund:** [Warum war Restart nötig]
**Aktion:** Neustart durchgeführt
**Ergebnis:** [Erfolgreich/Fehlgeschlagen]
**Notizen:** [Weitere Beobachtungen]
```

## Output Format

```
## Nexus Restart

**Komponente:** [Name]
**Grund:** [Warum]
**Status:** [Erfolgreich/Fehlgeschlagen]

### Durchgeführte Schritte
1. [Schritt] - [Ergebnis]
2. [Schritt] - [Ergebnis]

### Aktueller Status
| Komponente | PID | Port | Health |
|------------|-----|------|--------|
| ... | ... | ... | ... |

### Nächste Schritte
- [Falls nötig]
```

## Sicherheitsregeln

1. **Nie ohne Grund** - Nur bei bestätigtem Problem
2. **Immer fragen** - Keine automatischen Restarts
3. **Dokumentieren** - Jeden Restart in ERRORS.md loggen
4. **Verifizieren** - Nach Restart prüfen ob es läuft
5. **Eskalieren** - Bei wiederholten Ausfällen: Reflect-Skill

---

*Skill created: 2026-02-04*
