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

*Letzte Aktualisierung: 2026-02-05*
