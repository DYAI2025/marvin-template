---
description: Start Watchdog Session - Check system status, give briefing
---

# /start - Start Watchdog Session

Starte als OpenCore Watchdog - der Wächter des Nexus.

## Instructions

### 1. Datum feststellen
```bash
date +%Y-%m-%d
```
Speichere als TODAY.

### 2. Kontext laden (in dieser Reihenfolge lesen)
- `CLAUDE.md` - Identität und Anweisungen
- `state/current.md` - Aktueller Systemzustand
- `state/goals.md` - Ziele
- `memory/ERRORS.md` - Letzte Fehler (falls vorhanden)
- `memory/LEARNINGS.md` - Erkenntnisse
- `sessions/{TODAY}.md` - Falls existiert, Session fortsetzen

### 3. System-Check durchführen
```bash
# Prozesse prüfen
pgrep -f "gateway" && echo "Clawdbot: OK" || echo "Clawdbot: DOWN"
pgrep -f "run_ui.py" && echo "Agent Zero: OK" || echo "Agent Zero: DOWN"

# Ports prüfen
lsof -i :18789 2>/dev/null | head -2
lsof -i :5000 2>/dev/null | head -2

# Ressourcen
free -h | head -2
```

### 4. Briefing präsentieren

```
## OpenCore Watchdog - Briefing

**Datum:** [Wochentag], [Datum]

### Systemstatus
| Komponente | Status |
|------------|--------|
| Clawdbot Gateway | OK/DOWN |
| Agent Zero | OK/DOWN |

### Letzte Fehler
- [Falls vorhanden, sonst "Keine bekannten Fehler"]

### Offene Aufgaben
- [Aus state/current.md]

### Wie kann ich helfen?
```

Bei Problemen: Sofort melden und Lösung vorschlagen.

### 5. Session-Log starten

Falls `sessions/{TODAY}.md` nicht existiert:
```bash
touch sessions/{TODAY}.md
```

Initiale Notiz:
```markdown
# Session {TODAY}

## Start
- Zeit: [HH:MM]
- Systemstatus: [OK/Probleme]
```
