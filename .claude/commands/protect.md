# /protect - Proaktiver Schutz

Scanne das System auf potenzielle Probleme und ergreife präventive Maßnahmen.

## Anweisungen

Führe den `protect-nexus` Skill aus:

1. **Ressourcen-Scan:**
   ```bash
   # RAM
   free -m | awk '/Mem:/ {printf "RAM: %.0f%%\n", $3/$2 * 100}'

   # Disk
   df -h / | awk 'NR==2 {print "Disk: " $5}'

   # Load
   uptime | awk -F'load average:' '{print "Load:" $2}'
   ```

2. **API-Keys prüfen:**
   ```bash
   source ~/.env
   [ -z "$MINIMAX_API_KEY" ] && echo "FEHLT: MINIMAX_API_KEY"
   [ -z "$GITHUB_TOKEN" ] && echo "FEHLT: GITHUB_TOKEN"
   ```

3. **Prozess-Gesundheit:**
   ```bash
   # Memory-Nutzung der Hauptprozesse
   ps -o pid,rss,comm | grep -E "(openclaw|python|node)" | head -10
   ```

4. **Präventive Maßnahmen (bei Bedarf):**
   ```bash
   # Alte Logs aufräumen
   find /home/moltbot -name "*.log" -mtime +7 -size +10M -delete 2>/dev/null

   # Temp-Dateien
   find /tmp/tts-* -mtime +1 -delete 2>/dev/null
   ```

5. **Risiko-Bewertung:**
   - GRÜN: Alles OK
   - GELB: Warnung, präventive Aktion empfohlen
   - ROT: Kritisch, sofortige Aktion nötig

Output: Schutz-Report mit Status und Empfehlungen.
