# /learn - Von Nexus lernen

Verarbeite Nachrichten aus dem Inbox-Ordner und integriere neues Wissen.

## Anweisungen

Führe den `system-learn` Skill aus:

1. **Inbox scannen:**
   ```bash
   ls -la /home/moltbot/marvin/inbox/*.md 2>/dev/null | grep -v README
   ```

2. **Für jede Nachricht:**
   - Typ erkennen: `[LEARN]`, `[ERROR]`, `[FIX]`, `[SYSTEM]`, `[PROTECT]`, `[EVOLVE]`
   - Wissen extrahieren
   - In passende Dateien integrieren:
     - LEARN/SYSTEM → `system/ARCHITECTURE.md`
     - ERROR → `memory/ERRORS.md`
     - FIX → `memory/LEARNINGS.md` + `skills/self-heal/`
     - PROTECT → `skills/protect-nexus/`
     - EVOLVE → `system/` aktualisieren

3. **Verarbeitete Dateien archivieren:**
   ```bash
   mkdir -p /home/moltbot/marvin/inbox/processed
   # Dateien verschieben (README behalten)
   ```

4. **Report erstellen:**
   - Was wurde gelernt?
   - Welche Dateien aktualisiert?
   - Neue Fähigkeiten?

Output: Lern-Report mit integrierten Erkenntnissen.
