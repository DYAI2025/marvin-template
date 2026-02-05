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
- Nexus hatte am TTS gebaut
- Whisper STT Service lief parallel (Port 8002)
- Verdacht: Ressourcen-Blockierung durch Transkription

**Ursache:** Token-Konto leer. Anthropic Sonnet 4.5 wurde genutzt (teuer) statt MiniMax M2.1 (günstig).

**Lösung:**
1. Model auf `minimax/MiniMax-M2.1` gesetzt
2. `MINIMAX_API_KEY` in `.env` hinzugefügt
3. Openclaw Gateway neugestartet

**Vermeidung:**
- API-Kosten regelmäßig prüfen
- Günstigere Models als Primary verwenden
- API Keys für alle Provider hinterlegen

**Skill:** Keiner (Vorschlag: cost-monitor)

---

*Letzte Aktualisierung: 2026-02-04*
