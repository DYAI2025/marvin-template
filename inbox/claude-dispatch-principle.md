# [LEARN] LLM Dispatch Principle — Die <5 Sekunden Regel

## Kernregel

Braucht der User eine Antwort in <5 Sekunden?
- **Ja** → Günstige API (MiniMax M2.1, Gemini Flash) über Gateway
- **Nein** → `claude -p` über Max-Abo (kostenlos, Opus/Sonnet-Qualität)

## Was bedeutet das für dich (Marvin)?

Du kannst jetzt bei komplexen Problemen `claude -p` spawnen statt nur neu zu starten:

```bash
# Beispiel: Whisper crashed zum 3. Mal
FREE_MB=$(free -m | awk 'NR==2{print $7}')
CLAUDE_RUNNING=$(pgrep -c -f "claude -p" 2>/dev/null || echo 0)

if [ "$FREE_MB" -gt 500 ] && [ "$CLAUDE_RUNNING" -eq 0 ]; then
  claude -p "Diagnostiziere warum Whisper STT wiederholt crashed. Prüfe Logs in whisper-service/, RAM-Usage, Python-Dependencies." \
    --dangerously-skip-permissions --add-dir /home/moltbot > /tmp/diag-whisper.md 2>&1 &
  echo "Claude-Diagnostik gestartet, Report in /tmp/diag-whisper.md"
fi
```

## Zwei Claude-Modelle verfügbar

- `claude -p "..."` → Opus 4.6 (Standard) — für Code, komplexe Diagnostik
- `claude -p "..." --model claude-sonnet-4-5-20250929` → Sonnet 4.5 — schneller, für Analyse/Reports

## Sicherheitsregeln

1. **RAM prüfen** vor Spawn (braucht ~450MB)
2. **Max 1** claude -p Prozess gleichzeitig auf diesem VPS
3. **Nur bei echtem Bedarf** — einfache Restarts brauchen kein LLM
4. Output immer nach `/tmp/` schreiben
