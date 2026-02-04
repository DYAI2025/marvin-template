---
name: error-learner
description: |
  Analysiert Fehler, dokumentiert sie und extrahiert Learnings.
  Erkennt Muster und schlägt Skills vor.
license: MIT
compatibility: marvin
metadata:
  marvin-category: watchdog
  user-invocable: false
  slash-command: null
  model: default
  proactive: true
---

# Error Learner

Analysiert Fehler systematisch und lernt daraus.

## When to Use

- Automatisch wenn ein Fehler erkannt wird
- Nach einem Prozess-Ausfall
- Wenn ungewöhnliches Verhalten beobachtet wird
- Bei manueller Analyse von Logs

## Process

### Step 1: Fehler erfassen

Sammle alle relevanten Informationen:
- Timestamp
- Betroffener Prozess
- Fehlermeldung (exakt)
- Kontext (was lief vorher)
- Logs (relevante Zeilen)

### Step 2: Analyse

Fragen beantworten:
1. **Was** ist passiert? (Symptom)
2. **Wann** ist es passiert? (Zeitpunkt, Auslöser)
3. **Warum** ist es passiert? (Ursache)
4. **Wie oft** ist das schon passiert? (Häufigkeit)
5. **Gibt es ein Muster?** (Vergleich mit PATTERNS.md)

### Step 3: Dokumentieren

In `memory/ERRORS.md` eintragen:

```markdown
### [DATUM] [Kurzbeschreibung]

**Symptom:** [Was war zu sehen?]

**Kontext:**
- Zeitpunkt: [Wann]
- Prozess: [Welcher]
- Vorher: [Was lief vorher]

**Fehlermeldung:**
```
[Exakte Fehlermeldung]
```

**Ursache:** [Warum ist es passiert]

**Lösung:** [Was hat geholfen]

**Vermeidung:** [Wie kann man es verhindern]

**Ähnliche Fehler:** [Links zu verwandten Einträgen]
```

### Step 4: Muster prüfen

In `memory/PATTERNS.md` prüfen:
- Passt der Fehler zu einem bekannten Muster?
- Wenn ja: Muster-Eintrag aktualisieren (Häufigkeit, neue Infos)
- Wenn nein: Neues Muster? (mindestens 2 ähnliche Fehler)

### Step 5: Learning ableiten

In `memory/LEARNINGS.md` eintragen wenn:
- Neue Erkenntnis gewonnen
- Präventive Maßnahme identifiziert
- Skill-Idee entstanden

### Step 6: Skill vorschlagen

Wenn aus dem Learning ein Skill abgeleitet werden kann:
- Skill-Idee dokumentieren
- `skill-from-learning` Skill triggern

## Output Format

```
## Fehler-Analyse

**Fehler:** [Kurzbeschreibung]
**Dokumentiert in:** memory/ERRORS.md

### Erkenntnisse
- [Learning 1]
- [Learning 2]

### Muster
- [Passt zu Muster X / Neues Muster erkannt / Kein Muster]

### Empfehlung
- [Nächste Schritte]
- [Skill-Vorschlag falls relevant]
```

---

*Skill created: 2026-02-04*
