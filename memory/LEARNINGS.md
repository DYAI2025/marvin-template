# Learnings

Was ich aus meinen Beobachtungen gelernt habe.

---

## Format

```markdown
### [DATUM] Learning-Titel

**Kontext:** Was ist passiert?
**Erkenntnis:** Was habe ich gelernt?
**Anwendung:** Wie wende ich das an?
**Skill erstellt:** Ja/Nein (Link)
```

---

## Learnings

### [2026-02-04] Model-Kosten: Anthropic Sonnet 4.5 vs MiniMax M2.1

**Kontext:**
Nexus war im Chat immer wieder für 20-30 Minuten verschwunden. Ursache: Er nutzte Anthropic Claude Sonnet 4.5 als Primary Model, was das Token-Konto leergeräumt hat. Sonnet 4.5 ist sehr teuer und kann bei intensiver Nutzung schnell hohe Kosten verursachen.

**Symptome:**
- Nexus antwortet, dann lange Stille (20-30 min)
- Token-Konto erschöpft
- Konfiguration zeigte `minimax/MiniMax-M2.1` als Primary, aber tatsächlich wurde Anthropic genutzt

**Lösung:**
1. Primary Model explizit auf `minimax/MiniMax-M2.1` gesetzt in `~/.clawdbot/clawdbot.json`
2. MiniMax API Key in `.env` hinterlegt: `MINIMAX_API_KEY=...`
3. Openclaw Gateway neugestartet

**Erkenntnis:**
- Model-Kosten können drastisch variieren - Anthropic Sonnet 4.5 ist Premium-Preis
- MiniMax M2.1 ist eine günstige Alternative mit 200k Context Window
- Bei unerklärlichen Ausfällen: API-Kosten/Limits prüfen
- Fallback-Kette in Config kann dazu führen, dass teures Model genutzt wird wenn Primary versagt

**Anwendung:**
- Regelmäßig Token-Verbrauch monitoren
- Bei Budget-Limits: Günstigere Models als Primary nutzen
- API Keys für alle konfigurierten Provider sicherstellen

**Skill erstellt:** Nein (Potenzial: cost-monitor Skill)

---

### [2026-02-04] Async Whisper Service Fix - Blocking Problem

**Kontext:**
Nexus hatte am TTS/STT System gebaut. Das ursprüngliche Problem war nicht nur Model-Kosten, sondern auch ein **Blocking-Problem beim Whisper Service**.

**Nexus' eigene Erklärung:**
> "Kein Blocking mehr - ich bleibe online auch während Sprachnachrichten."

**Was Nexus gebaut hat:**
1. **Whisper STT Service** (Port 8002) - Spracherkennung
2. **TTS Service** - Text-to-Speech mit Edge-Stimme (de-DE-SeraphinaMultilingualNeural)
3. **Async-Fix** - Gateway blockiert nicht mehr während Transkription

**Aktueller Stand:**
- TTS funktioniert, aber sendet Audio als **Datei-Anhang** statt Sprachnachricht
- Nexus arbeitet an OpenClaw-Konfiguration für native WhatsApp-Sprachnachrichten
- Audio-Dateien landen in `/tmp/tts-*/voice-*.mp3`

**Erkenntnis:**
- Synchrone API-Calls können Gateway blockieren
- Async-Processing ist essentiell für responsive Chat-Systeme
- WhatsApp unterscheidet zwischen Datei-Anhang und Sprachnachricht

**Offene Aufgabe:**
- OpenClaw muss Sprachnachrichten als natives WhatsApp-Voice-Format senden

**Skill erstellt:** Nein

---

## Grundlegende Erkenntnisse

Diese Dinge habe ich von Anfang an verstanden:

1. **Logs sind Gold** - Immer zuerst die Logs prüfen
2. **Kontext ist alles** - Was hat sich geändert vor dem Fehler?
3. **Einfache Lösungen zuerst** - Restart löst 80% der Probleme
4. **Dokumentieren hilft** - Was nicht aufgeschrieben ist, wird vergessen
5. **Muster erkennen** - Einzelne Fehler sind Zufall, Muster sind Wissen

---

*Letzte Aktualisierung: 2026-02-04*
