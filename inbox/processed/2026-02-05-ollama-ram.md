# [LEARN] Ollama frisst RAM

## Problem
Ollama (lokales LLM) verbraucht 500-800MB RAM wenn aktiv.
Bei RAM-Knappheit führt das zu kswapd0 Swap-Storms.

## Erkennung
```bash
# Ollama Prozess prüfen
pgrep -f ollama && echo "Ollama läuft"

# RAM Check
free -m | awk '/^Mem:/ {if ($3/$2 > 0.85) print "RAM KRITISCH: " $3/$2*100 "%"}'
```

## Heilung bei RAM > 85%
```bash
# Ollama stoppen (nicht kritisch für Nexus)
systemctl stop ollama || pkill -f ollama
```

## Priorität
- Ollama ist NIEDRIG-Priorität
- Kann gestoppt werden wenn RAM knapp
- Nexus Kern-Services haben Vorrang

## Zusammenhang
Wenn kswapd0 in top erscheint → System swappt → RAM voll → Ollama stoppen
