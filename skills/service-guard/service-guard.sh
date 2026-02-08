#!/bin/bash
# Service Guard - Deterministischer Health-Check für alle Nexus Services
# Teil von Marvin's Immunsystem
# Läuft alle 5 Minuten via Cron — KEIN LLM nötig
#
# Überwacht:
#   - Perr00bot (nanobot gateway) — kein systemd
#   - Whisper STT (uvicorn :8002) — screen, kein auto-restart
#   - TTS Server (tts_server.py) — systemd, aber als Fallback
#   - Nexus Dashboard (node server.cjs :3003) — kein systemd

MARVIN_LOG="/home/moltbot/marvin/sessions/service-guard.log"
INTERVENTIONS="/home/moltbot/marvin/memory/INTERVENTIONS.md"
MAX_RESTARTS_PER_HOUR=3
RESTART_COUNTER_FILE="/tmp/marvin-service-restarts"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MARVIN_LOG"
}

# Restart-Loop-Schutz (gemeinsam für alle Services)
count_recent_restarts() {
    local counter_file="$1"
    if [ ! -f "$counter_file" ]; then
        echo 0
        return
    fi
    local cutoff=$(date -d '1 hour ago' +%s 2>/dev/null || date -v-1H +%s 2>/dev/null)
    local count=0
    local tmpfile=$(mktemp)
    while read -r ts; do
        if [ "$ts" -ge "$cutoff" ] 2>/dev/null; then
            echo "$ts" >> "$tmpfile"
            count=$((count + 1))
        fi
    done < "$counter_file"
    mv "$tmpfile" "$counter_file"
    echo "$count"
}

record_restart() {
    local counter_file="$1"
    date +%s >> "$counter_file"
}

can_restart() {
    local counter_file="$1"
    local restarts=$(count_recent_restarts "$counter_file")
    if [ "$restarts" -ge "$MAX_RESTARTS_PER_HOUR" ]; then
        log "⛔ Restart-Limit für $2 erreicht ($restarts/$MAX_RESTARTS_PER_HOUR pro Stunde)"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════
# SERVICE DEFINITIONS
# ═══════════════════════════════════════════════════

check_perr00bot() {
    pgrep -u moltbot -f "nanobot gateway" > /dev/null 2>&1
}

heal_perr00bot() {
    pkill -9 -f "nanobot gateway" 2>/dev/null
    sleep 2
    cd /home/moltbot
    nohup /home/moltbot/.venv/bin/nanobot gateway --port 18791 --verbose > /tmp/perr00bot-gateway.log 2>&1 &
    sleep 5
    check_perr00bot
}

check_whisper() {
    curl -s --max-time 3 localhost:8002/health > /dev/null 2>&1
}

heal_whisper() {
    pkill -f "uvicorn.*8002" 2>/dev/null
    sleep 2
    cd /home/moltbot/whisper-service
    nohup /home/moltbot/.venv/bin/uvicorn api:app --host 127.0.0.1 --port 8002 --workers 1 > /tmp/whisper-stt.log 2>&1 &
    sleep 4
    check_whisper
}

check_tts() {
    pgrep -f "tts_server.py" > /dev/null 2>&1
}

heal_tts() {
    # TTS hat systemd — versuche erst systemd restart
    systemctl restart tts-server.service 2>/dev/null
    sleep 3
    if check_tts; then
        return 0
    fi
    # Fallback: manuell starten
    cd /home/moltbot/tts-server
    source /home/moltbot/tts-venv/bin/activate 2>/dev/null
    nohup python3 tts_server.py > /tmp/tts-server.log 2>&1 &
    sleep 3
    check_tts
}

check_dashboard() {
    curl -s --max-time 3 localhost:3003 > /dev/null 2>&1
}

heal_dashboard() {
    pkill -f "node server.cjs" 2>/dev/null
    sleep 1
    cd /home/moltbot/nexus-status
    nohup node server.cjs > /tmp/nexus-dashboard.log 2>&1 &
    sleep 3
    check_dashboard
}

# ═══════════════════════════════════════════════════
# MAIN LOOP
# ═══════════════════════════════════════════════════

guard_service() {
    local name="$1"
    local check_fn="$2"
    local heal_fn="$3"
    local counter="/tmp/marvin-restart-${name}"

    if $check_fn; then
        return 0  # Healthy
    fi

    log "⚠️ ERKANNT: $name ist DOWN!"

    if ! can_restart "$counter" "$name"; then
        return 1
    fi

    log "🔧 HEILUNG: $name neustarten..."
    if $heal_fn; then
        local detail=""
        [ "$name" = "perr00bot" ] && detail=" (PID $(pgrep -u moltbot -f 'nanobot gateway' 2>/dev/null))"
        log "✅ $name geheilt${detail}"
        record_restart "$counter"
        echo "- [$(date '+%Y-%m-%d %H:%M')] Auto-Heal: $name war down → neugestartet" >> "$INTERVENTIONS"
        return 0
    else
        log "❌ $name konnte nicht gestartet werden"
        return 1
    fi
}

main() {
    local any_down=0

    guard_service "perr00bot" check_perr00bot heal_perr00bot || any_down=1
    guard_service "whisper-stt" check_whisper heal_whisper || any_down=1
    guard_service "tts-server" check_tts heal_tts || any_down=1
    guard_service "nexus-dashboard" check_dashboard heal_dashboard || any_down=1

    # Status-Log nur alle 30 Min wenn alles OK
    if [ "$any_down" -eq 0 ]; then
        local minute=$(date +%M)
        if [ "$((minute % 30))" -lt 5 ]; then
            log "✅ Alle Services gesund (perr00bot, whisper, tts, dashboard)"
        fi
    fi
}

main "$@"
