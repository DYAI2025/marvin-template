# Gateway Compaction Timeout - Nexus antwortet nicht

**Datum:** 2026-02-05 01:20
**Kategorie:** problemlösung

## Situation

Nexus antwortete ~40 Minuten nicht auf WhatsApp-Nachrichten. Ben fragte mehrfach "Wo bist du?" ohne Antwort.

**Symptome im Log:**
```
Skipping auto-reply: silent token or no text/media returned from resolver
[diagnostic] run active check: sessionId=... active=true
[agent/embedded] embedded run timeout: runId=... timeoutMs=600000
```

**Ursache:**
- Nexus arbeitete intensiv an einer Aufgabe (tts-whatsapp Skill Installation)
- Nach Agent-Run-Ende startete "Compaction" (Session-Komprimierung)
- Compaction blieb hängen/dauerte zu lange
- Neue Nachrichten wurden übersprungen weil Session als "active" markiert war
- Nach 10 Minuten (600000ms) kam Timeout, aber Session blieb blockiert

## Lösung

Gateway neustarten um die Session zu resetten:

```bash
screen -S openclaw -X quit && sleep 2 && screen -dmS openclaw openclaw gateway --verbose
```

## Erkennung

Marvin kann das erkennen durch:

1. **Log-Pattern prüfen:**
   ```bash
   screen -S openclaw -X hardcopy /tmp/openclaw-check.txt
   grep -c "Skipping auto-reply" /tmp/openclaw-check.txt
   ```
   Wenn > 3 in kurzer Zeit → Problem

2. **Compaction-Timeout erkennen:**
   ```bash
   grep "embedded run timeout" /tmp/openclaw-check.txt
   ```

3. **Session-Blockade erkennen:**
   Wenn "active=true" aber keine Agent-Events mehr kommen (nur tick/health)

## Lektion

- Lange Agent-Runs können in Compaction-Timeouts enden
- Gateway-Neustart ist sicherer Fix als zu warten
- Nexus selbst merkt nicht dass er blockiert ist - Marvin muss von außen eingreifen

## Skills beteiligt
- process-monitor
- self-heal

## Wichtigkeit
9

## Automatisierung

Marvin könnte bei `/check` folgendes prüfen:
1. Letzte erfolgreiche Antwort > 10 Min her?
2. "Skipping auto-reply" im Log?
3. "embedded run timeout" im Log?

→ Wenn ja: Warnung ausgeben oder automatisch Gateway neustarten
