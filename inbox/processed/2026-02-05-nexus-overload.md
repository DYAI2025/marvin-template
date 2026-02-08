# [LEARN] Nexus Überlastung erkennen und heilen

## Problem erkannt: 2026-02-05 23:36

Das System ist überlastet durch zu viele Claude-Prozesse.

## Symptome
- RAM > 90%
- Load > 2.0
- Mehrere `claude` Prozesse unter moltbot

## Diagnose-Befehle
```bash
# Claude-Prozesse zählen
pgrep -u moltbot -c claude

# RAM-Verbrauch pro Claude-Prozess
ps aux | grep "moltbot.*claude" | grep -v grep | awk '{sum+=$6} END {print sum/1024 " MB total"}'

# Zombie/Orphan Claude-Prozesse finden (älter als 2h)
ps -eo pid,user,etime,cmd | grep "moltbot.*claude" | grep -v grep
```

## Heilungs-Aktion
Wenn mehr als 3 Claude-Prozesse laufen und RAM > 85%:

```bash
# Älteste Claude-Prozesse killen (behalte die 2 neuesten)
pgrep -u moltbot claude | head -n -2 | xargs -r kill -15

# Warten und prüfen
sleep 5
free -h
```

## Container-Namen korrigiert
- Planka heißt `planka-kanban` (nicht `planka`)
- Agent Zero WebUI: `agent-zero-webui`

## Präventiv
- Warnung wenn > 3 Claude-Prozesse
- Warnung wenn RAM > 80%
- Automatisches Cleanup von Prozessen > 4 Stunden alt
