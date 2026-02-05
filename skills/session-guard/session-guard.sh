#!/bin/bash
# Session Guard - Automatische Erkennung und Heilung von Session-Problemen
# Teil von Marvin's Immunsystem

LOG_DIR="/tmp/openclaw"
SESSION_DIR="$HOME/.openclaw/agents/main/sessions"
MARVIN_LOG="/home/moltbot/marvin/sessions/session-guard.log"
MAX_SESSION_SIZE_MB=5

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MARVIN_LOG"
}

# 1. Prüfe auf call_id Fehler in den Logs
check_call_id_error() {
    local today=$(date '+%Y-%m-%d')
    local log_file="$LOG_DIR/openclaw-$today.log"

    if [ -f "$log_file" ]; then
        if grep -q "call_id.*empty string" "$log_file" 2>/dev/null; then
            return 0  # Fehler gefunden
        fi
    fi
    return 1  # Kein Fehler
}

# 2. Prüfe Session-Größe
check_session_size() {
    local large_sessions=$(find "$SESSION_DIR" -name "*.jsonl" -size +${MAX_SESSION_SIZE_MB}M 2>/dev/null)
    if [ -n "$large_sessions" ]; then
        echo "$large_sessions"
        return 0  # Große Sessions gefunden
    fi
    return 1
}

# 3. Automatische Heilung
heal_session() {
    local session_file="$1"
    local backup_name="${session_file}.backup.$(date +%Y%m%d-%H%M%S)"

    log "🔧 HEILUNG: Session-Reset für $session_file"

    # Backup erstellen
    if mv "$session_file" "$backup_name" 2>/dev/null; then
        log "✅ Session gesichert: $backup_name"
        log "✅ Nexus startet mit frischer Session"
        return 0
    else
        log "❌ Konnte Session nicht sichern"
        return 1
    fi
}

# 4. Hauptlogik
main() {
    log "=== Session Guard Check ==="

    # Check 1: call_id Fehler
    if check_call_id_error; then
        log "⚠️ ERKANNT: call_id empty string Fehler in Logs"

        # Finde die aktive Session und heile sie
        for session in "$SESSION_DIR"/*.jsonl; do
            if [ -f "$session" ]; then
                heal_session "$session"
            fi
        done

        log "📝 Dokumentiere in Marvin's Memory..."
        echo "- [$(date '+%Y-%m-%d %H:%M')] Auto-Heal: call_id error → Session reset" >> /home/moltbot/marvin/memory/INTERVENTIONS.md

        exit 0
    fi

    # Check 2: Große Sessions (präventiv)
    large_sessions=$(check_session_size)
    if [ -n "$large_sessions" ]; then
        log "⚠️ WARNUNG: Große Session(s) gefunden (>${MAX_SESSION_SIZE_MB}MB):"
        echo "$large_sessions" | while read session; do
            size=$(du -h "$session" | cut -f1)
            log "  - $session ($size)"
        done
        log "💡 Empfehlung: /compact oder /reset in WhatsApp senden"
        # Keine automatische Heilung bei Größe allein - nur Warnung
    else
        log "✅ Alle Sessions in normalem Größenbereich"
    fi

    log "=== Check abgeschlossen ==="
}

# Ausführen
main "$@"
