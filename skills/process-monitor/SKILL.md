---
name: process-monitor
description: |
  Überwacht Nexus-Prozesse (Clawdbot Gateway, Agent Zero) und meldet Status.
  Erkennt Ausfälle und ungewöhnliches Verhalten.
license: MIT
compatibility: marvin
metadata:
  marvin-category: watchdog
  user-invocable: true
  slash-command: /check
  model: default
  proactive: true
---

# Process Monitor

Überwacht alle relevanten Nexus-Prozesse und meldet ihren Status.

## When to Use

- Bei `/start` - automatisch
- Bei `/check` - manuell
- Regelmäßig im Hintergrund
- Wenn ein Problem vermutet wird

## Zu überwachende Prozesse

| Prozess | Pattern | Port |
|---------|---------|------|
| Clawdbot Gateway | `node.*gateway` oder `pnpm.*gateway` | 18789 |
| Agent Zero | `python.*run_ui.py` | 5000 |

## Process

### Step 1: Prozesse prüfen

```bash
# Clawdbot Gateway
pgrep -f "gateway" || echo "NOT RUNNING"
lsof -i :18789 2>/dev/null || echo "Port 18789 not in use"

# Agent Zero
pgrep -f "run_ui.py" || echo "NOT RUNNING"
lsof -i :5000 2>/dev/null || echo "Port 5000 not in use"
```

### Step 2: Ressourcen prüfen

```bash
# Memory und CPU der Prozesse
ps aux | grep -E "(gateway|run_ui.py)" | grep -v grep

# System-Ressourcen
free -h
df -h /home/moltbot
```

### Step 3: Logs prüfen

```bash
# Letzte Fehler in Clawdbot-Log
tail -50 /home/moltbot/clawdbot.log 2>/dev/null | grep -i "error\|fail\|exception"

# Systemd Journal (falls vorhanden)
journalctl -u clawdbot --since "1 hour ago" 2>/dev/null | tail -20
```

### Step 4: Status zusammenfassen

Ausgabe im Format:

```
## Nexus Status

| Prozess | Status | PID | Memory | Uptime |
|---------|--------|-----|--------|--------|
| Clawdbot Gateway | OK/DOWN | ... | ... | ... |
| Agent Zero | OK/DOWN | ... | ... | ... |

### Warnungen
- [Falls vorhanden]

### Letzte Fehler
- [Falls gefunden]
```

## Output Format

Status-Report mit:
- Prozess-Status (OK/DOWN)
- Ressourcen-Nutzung
- Letzte Fehler (falls vorhanden)
- Empfohlene Aktionen

## Automatische Aktionen

Bei erkanntem Ausfall:
1. In ERRORS.md dokumentieren
2. Restart vorschlagen (nicht automatisch ausführen)
3. Bei wiederkehrendem Muster: reflect-Skill triggern

---

*Skill created: 2026-02-04*
