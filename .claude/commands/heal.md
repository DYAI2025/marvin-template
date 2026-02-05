# /heal - Selbstheilung

Prüfe Systemgesundheit und heile kranke Komponenten.

## Anweisungen

Führe den `self-heal` Skill aus:

1. **Gesundheitscheck:**
   ```bash
   # OpenClaw
   pgrep -f "openclaw-gateway" || echo "KRANK: OpenClaw"

   # Whisper
   curl -s -o /dev/null -w "%{http_code}" localhost:8002/health | grep -q 200 || echo "KRANK: Whisper"

   # TTS
   pgrep -f "tts_server.py" || echo "KRANK: TTS"

   # Docker
   docker ps | grep -q agent-zero || echo "KRANK: Agent Zero"
   ```

2. **Für jede kranke Komponente:**
   - Diagnose (warum krank?)
   - Heilung durchführen (siehe `system/HEALTH.md`)
   - Verifizieren (läuft wieder?)

3. **Heilungs-Befehle:**

   **OpenClaw:**
   ```bash
   screen -S openclaw -X quit 2>/dev/null
   pkill -f "openclaw-gateway" 2>/dev/null
   sleep 2
   source ~/.env
   screen -dmS openclaw openclaw gateway --verbose
   ```

   **Whisper:**
   ```bash
   pkill -f "uvicorn.*8002" 2>/dev/null
   sleep 2
   cd /home/moltbot/whisper-service
   source /home/moltbot/tts-venv/bin/activate
   nohup uvicorn api:app --host 0.0.0.0 --port 8002 --workers 1 > logs.txt 2>&1 &
   ```

4. **Dokumentieren:**
   - Was war krank?
   - Was wurde getan?
   - Erfolgreich?

Output: Immunsystem-Report mit Heilungsstatus.
