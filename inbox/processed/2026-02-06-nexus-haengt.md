# [ERROR] Nexus Gateway hängt - Zombie-Prozess

## Problem erkannt: 2026-02-06 00:15

Nexus Gateway Prozess läuft, aber Port 18789 antwortet nicht = **Zombie/Hanging**

## Symptome
- `pgrep nanobot` findet Prozess ✅
- `curl localhost:18789` timeout ❌
- Screen-Session fehlt oder disconnected

## Diagnose
```bash
# Prozess da aber Port tot?
pgrep -f "nanobot gateway" && ! curl -s --max-time 2 localhost:18789/health && echo "NEXUS HÄNGT!"
```

## Heilung
```bash
# 1. Zombie-Prozess killen
pkill -9 -f "nanobot gateway"

# 2. Warten
sleep 2

# 3. Neu starten in Screen
cd /home/moltbot && screen -dmS coach /home/moltbot/.venv/bin/nanobot gateway --verbose

# 4. Verifizieren (nach 5 Sek)
sleep 5 && curl -s --max-time 3 localhost:18789/health && echo "Nexus GEHEILT!"
```

## Prävention
- Session-Größe monitoren (>5MB = Gefahr)
- RAM-Nutzung überwachen
- Bei Swap-Aktivität: Nexus präventiv neustarten

## Root Cause
Wahrscheinlich: Speicherüberlauf oder korrupte Session
