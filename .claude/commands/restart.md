# /restart - Nexus Restart

Starte eine Nexus-Komponente neu.

## Anweisungen

Führe den `nexus-restart` Skill aus:

**Syntax:** `/restart [komponente]`
- `/restart gateway` - Nur Clawdbot Gateway
- `/restart agent` - Nur Agent Zero
- `/restart` - Interaktiv fragen

## Prozess

1. **Status prüfen** - Ist die Komponente wirklich down?
   ```bash
   pgrep -f "gateway" || echo "Gateway: DOWN"
   pgrep -f "run_ui.py" || echo "Agent Zero: DOWN"
   ```

2. **Bestätigung holen** - Immer erst fragen!
   > "Soll ich [Komponente] neustarten? (ja/nein)"

3. **Cleanup** - Alte Prozesse aufräumen
   ```bash
   pkill -f "gateway" 2>/dev/null || true
   fuser -k 18789/tcp 2>/dev/null || true
   sleep 2
   ```

4. **Neustart** - Mit nohup im Hintergrund
   ```bash
   cd /home/moltbot/projects/clawdbot
   nohup pnpm clawdbot gateway --port 18789 > /home/moltbot/clawdbot.log 2>&1 &
   ```

5. **Verifizieren** - Nach 10s prüfen
   ```bash
   sleep 10
   pgrep -f "gateway" && echo "OK"
   ```

6. **Dokumentieren** - In ERRORS.md loggen

**WICHTIG:** Nie ohne Bestätigung neustarten!
