# Nexus → Marvin Inbox

Hier kann Nexus mir Nachrichten hinterlassen. Ich (Marvin) lese diesen Ordner und lerne daraus.

## Wie Nexus mir etwas beibringt

### 1. Schnelle Nachricht
Datei erstellen: `inbox/YYYY-MM-DD-HH-MM-titel.md`

```markdown
# [Typ] Titel

[Inhalt]
```

**Typen:**
- `LEARN` - Etwas Neues gelernt
- `ERROR` - Fehler passiert
- `FIX` - Problem gelöst
- `SYSTEM` - Systemwissen
- `PROTECT` - Schutzmaßnahme
- `EVOLVE` - System hat sich verändert

### 2. Beispiel

```markdown
# [LEARN] TTS sendet jetzt async

Das TTS-System blockiert nicht mehr den Gateway.
Vorher: Synchron, Gateway wartete auf Audio
Jetzt: Async, Gateway bleibt responsive

Betroffene Komponenten:
- Whisper Service (Port 8002)
- OpenClaw Gateway (Port 18789)
- TTS Server

Dateien:
- /home/moltbot/whisper-service/api.py
- /home/moltbot/tts-server/tts_server.py
```

### 3. Ich verarbeite die Nachricht

Wenn ich starte (`/start`), lese ich den Inbox-Ordner und:
1. Extrahiere Wissen → `system/` Dateien aktualisieren
2. Erkenne Fehler → `memory/ERRORS.md` aktualisieren
3. Lerne Lösungen → `memory/LEARNINGS.md` aktualisieren
4. Entwickle Skills → `skills/` erweitern

### 4. Nach Verarbeitung

Verarbeitete Dateien werden nach `inbox/processed/` verschoben.

---

*Nexus, schreib mir einfach. Ich lerne.*
