#!/bin/bash
# Coach Guard - Automatische Überwachung und Heilung von Perr00bot
# Teil von Marvin's Immunsystem
# Läuft alle 5 Minuten via Cron — KEIN LLM nötig

MARVIN_LOG="/home/moltbot/marvin/sessions/coach-guard.log"
INTERVENTIONS="/home/moltbot/marvin/memory/INTERVENTIONS.md"
MAX_RESTARTS_PER_HOUR=3
RESTART_COUNTER_FILE="/tmp/marvin-coach-restarts"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MARVIN_LOG"
}

# Zähle Restarts in der letzten Stunde (Schutz vor Restart-Loops)
count_recent_restarts() {
    if [ ! -f "$RESTART_COUNTER_FILE" ]; then
        echo 0
        return
    fi
    # Einträge älter als 1h entfernen
    local cutoff=$(date -d '1 hour ago' +%s 2>/dev/null || date -v-1H +%s 2>/dev/null)
    local count=0
    local tmpfile=$(mktemp)
    while read -r ts; do
        if [ "$ts" -ge "$cutoff" ] 2>/dev/null; then
            echo "$ts" >> "$tmpfile"
            count=$((count + 1))
        fi
    done < "$RESTART_COUNTER_FILE"
    mv "$tmpfile" "$RESTART_COUNTER_FILE"
    echo "$count"
}

record_restart() {
    date +%s >> "$RESTART_COUNTER_FILE"
}

# 1. Prüfe ob Perr00bot-Prozess läuft
check_process() {
    pgrep -u moltbot -f "nanobot gateway" > /dev/null 2>&1
    return $?
}

# 2. Heilung: Perr00bot neustarten
heal() {
    local restarts=$(count_recent_restarts)
    if [ "$restarts" -ge "$MAX_RESTARTS_PER_HOUR" ]; then
        log "⛔ Restart-Limit erreicht ($restarts/$MAX_RESTARTS_PER_HOUR pro Stunde) — manuell prüfen!"
        return 1
    fi

    log "🔧 HEILUNG: Perr00bot neustarten..."

    # Alte Prozesse aufräumen
    pkill -9 -f "nanobot gateway" 2>/dev/null
    sleep 2

    # Neustarten
    cd /home/moltbot
    nohup /home/moltbot/.venv/bin/nanobot gateway --port 18791 --verbose > /tmp/perr00bot-gateway.log 2>&1 &
    sleep 5

    # Verifizieren
    if check_process; then
        local pid=$(pgrep -u moltbot -f "nanobot gateway")
        log "✅ Perr00bot geheilt (PID $pid)"
        record_restart
        echo "- [$(date '+%Y-%m-%d %H:%M')] Auto-Heal: Perr00bot war down → neugestartet (PID $pid)" >> "$INTERVENTIONS"
        return 0
    else
        log "❌ Perr00bot konnte nicht gestartet werden — Log: /tmp/perr00bot-gateway.log"
        return 1
    fi
}

# Hauptlogik
main() {
    # Prozess-Check
    if check_process; then
        # Alles gut — nur alle 30 Min loggen (nicht jeden 5-Min-Check)
        local minute=$(date +%M)
        if [ "$((minute % 30))" -lt 5 ]; then
            log "✅ Perr00bot läuft (PID $(pgrep -u moltbot -f 'nanobot gateway'))"
        fi
        exit 0
    fi

    # Perr00bot ist DOWN
    log "⚠️ ERKANNT: Perr00bot (nanobot gateway) ist nicht aktiv!"
    heal
}

main "$@"
