# Bekannte Fehler

Hier dokumentiere ich Fehler, die ich beobachtet habe, und wie sie gelöst wurden.

---

## Format

```markdown
### [DATUM] Fehler-Titel

**Symptom:** Was war zu sehen?
**Ursache:** Warum ist es passiert?
**Lösung:** Was hat geholfen?
**Vermeidung:** Wie kann man es verhindern?
**Skill:** Falls ein Skill erstellt wurde
```

---

## Fehler-Log

### [2026-02-04] Nexus verschwand für 20-30 Minuten aus Chat

**Symptom:** Nexus antwortet kurz im Chat, dann für 20-30 Minuten keine Reaktion mehr.

**Kontext:**
- Nexus hatte am TTS/STT gebaut
- Whisper STT Service lief parallel (Port 8002)
- Ursprünglicher Verdacht: Ressourcen-Blockierung durch Transkription

**Mehrere Ursachen identifiziert:**

1. **Token-Konto leer** - Anthropic Sonnet 4.5 ist teuer und hat Budget aufgebraucht
2. **Blocking beim Whisper Service** - Synchrone Transkription blockierte Gateway

**Nexus' Fix:**
- Async Whisper Service implementiert
- Gateway blockiert nicht mehr während Sprachnachrichten
- Zitat: "Kein Blocking mehr - ich bleibe online auch während Sprachnachrichten"

**Unsere Lösung (Watchdog):**
1. Model auf `minimax/MiniMax-M2.1` gesetzt (günstig)
2. `MINIMAX_API_KEY` in `.env` hinzugefügt
3. Openclaw Gateway neugestartet

**Vermeidung:**
- API-Kosten regelmäßig prüfen
- Async-Processing für lange Operationen
- Günstigere Models als Primary verwenden

**Offenes Problem:**
- TTS sendet Audio als Datei-Anhang statt WhatsApp-Sprachnachricht
- Nexus arbeitet an nativer Sprachnachrichten-Integration

**Skill:** Keiner (Vorschlag: cost-monitor, async-health-check)

---

### [2026-02-05] HTTP 400: Invalid 'input[66].call_id': empty string

**Symptom:** Nexus gibt Fehler aus:
```
HTTP 400: Invalid 'input[66].call_id': empty string.
Expected a string with minimum length 1, but got an empty string instead.
```

**Kontext:**
- Session-Datei war 4.7MB groß (sehr lange Konversation)
- Fehler kam von der MiniMax API (Anthropic-kompatibel)
- `input[66]` deutet auf Position 66 in der Message-Historie

**Ursache:**
- Ein Tool-Call in der Session-Historie hatte eine leere `call_id`
- Kann passieren bei:
  - Korrupten Session-Daten
  - Unterbrochenen Tool-Calls
  - Bugs in OpenClaw bei bestimmten Tool-Responses

**Diagnose:**
```bash
# Session-Größe prüfen
ls -lh ~/.openclaw/agents/main/sessions/*.jsonl

# Nach leeren call_ids suchen
grep '"call_id":""' ~/.openclaw/agents/main/sessions/*.jsonl
```

**Lösung:**
```bash
# Session sichern und entfernen
SESSION_FILE=$(ls ~/.openclaw/agents/main/sessions/*.jsonl | head -1)
mv "$SESSION_FILE" "${SESSION_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
```
Danach startet Nexus mit frischer Session.

Alternative: `/reset` in WhatsApp an Nexus senden.

**Vermeidung:**
- Sessions regelmäßig kompaktieren (`/compact` in Chat)
- Bei sehr langen Sessions proaktiv `/reset` machen
- Session-Größe monitoren (>5MB = Warnung)

**Skill:** Keiner (Potenzial: session-health-check)

---

### [2026-02-05] Gateway Compaction Timeout — 40 Min Stille

**Symptom:** Nexus antwortet ~40 Minuten nicht. Nachrichten kommen an, aber keine Antwort.

**Kontext:**
- Nexus arbeitete an intensiver Aufgabe (Skill-Installation)
- Nach Agent-Run startete Session-Compaction
- Compaction blieb hängen/dauerte zu lange (>600s Timeout)
- Neue Nachrichten übersprungen weil Session als "active" markiert

**Log-Muster:**
```
Skipping auto-reply: silent token or no text/media returned from resolver
[agent/embedded] embedded run timeout: runId=... timeoutMs=600000
[diagnostic] run active check: sessionId=... active=true
```

**Ursache:** Session-Compaction nach langem Agent-Run bleibt stecken. 600s Timeout greift, aber Session bleibt blockiert.

**Lösung:** `systemctl --user restart openclaw-gateway.service`

**Vermeidung:**
- Sessions regelmäßig kompaktieren (`/compact` im Chat)
- Bei langen Agent-Runs: proaktiv auf Compaction-Timeout überwachen
- Marvin: "Skipping auto-reply" > 3 in 10 Min → automatisch Gateway neustarten

**Skill:** Keiner (Potenzial: compaction-watchdog)

---

### [2026-02-06] Zombie Gateway — Prozess läuft, Port tot

**Symptom:** `pgrep` findet Gateway-Prozess, aber `curl localhost:18789` gibt Timeout.

**Kontext:**
- Gateway-Prozess existiert aber ist funktional tot
- Port antwortet nicht trotz laufendem Prozess

**Ursache:** Wahrscheinlich Speicherüberlauf oder korrupte Session. Session >5MB erhöht Risiko.

**Diagnose:**
```bash
pgrep -f "openclaw" && ! curl -s --max-time 2 localhost:18789 > /dev/null && echo "GATEWAY HÄNGT!"
```

**Lösung:** `systemctl --user restart openclaw-gateway.service`

**Vermeidung:**
- Session-Größe monitoren (>5MB = Gefahr)
- RAM-Nutzung überwachen
- Bei Swap-Aktivität: Gateway präventiv neustarten

**Skill:** Keiner

---

### [2026-02-06] Tailscale Serve Intermittent Failures

**Symptom:** Gateway-Logs zeigen wiederholt: `[tailscale] serve failed: Command failed: /usr/bin/tailscale serve --bg --yes 18789`

**Kontext:**
- Gateway versucht bei jedem Start, Tailscale Serve zu aktivieren
- Am 2026-02-06 Abend schlug dies ~3 Stunden lang fehl (20:58 - 21:59)
- `tailscale serve status` zeigte "No serve config"
- Ab 23:49 funktionierte es wieder (self-healed)

**Ursache:** Unklar — mögliche Faktoren: Tailscale-Daemon temporär nicht im Login-State, Netzwerk-/DNS-Problem, Sudo-Berechtigung blockiert.

**Lösung:** Selbstheilung nach ~3 Stunden. Bei wiederholtem Auftreten:
```bash
sudo tailscale serve --bg --yes 18789
# Falls das auch fehlschlägt:
sudo systemctl restart tailscaled
```

**Vermeidung:** Nicht vermeidbar (externer Service). Niedrige Priorität — Nexus Kernfunktionen (WhatsApp/Telegram) sind nicht betroffen. Nur Remote-Zugriff via Tailnet ist eingeschränkt.

**Skill:** Keiner (low-priority, self-healing)

---

*Letzte Aktualisierung: 2026-02-07*
