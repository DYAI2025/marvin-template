# /check - Process Monitor

Prüfe den Status aller Nexus-Prozesse.

## Anweisungen

Führe den `process-monitor` Skill aus:

1. **Prozesse prüfen:**
   ```bash
   # Clawdbot Gateway
   pgrep -f "gateway" || echo "Clawdbot: NOT RUNNING"
   lsof -i :18789 2>/dev/null | head -3

   # Agent Zero
   pgrep -f "run_ui.py" || echo "Agent Zero: NOT RUNNING"
   lsof -i :5000 2>/dev/null | head -3
   ```

2. **Ressourcen prüfen:**
   ```bash
   ps aux | grep -E "(gateway|run_ui.py)" | grep -v grep
   free -h | head -2
   ```

3. **Logs scannen:**
   ```bash
   tail -30 /home/moltbot/clawdbot.log 2>/dev/null | grep -i "error\|fail\|exception" | tail -5
   ```

4. **Status-Report erstellen:**
   - Tabelle mit Prozess-Status
   - Warnungen falls Probleme gefunden
   - Empfohlene Aktionen

Bei Ausfall: Frage ob Restart gewünscht ist.
