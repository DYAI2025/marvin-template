---
name: reflect
description: |
  Regelmäßige Reflexion über Fehler und Learnings.
  Analysiert Trends, identifiziert Verbesserungen, schlägt Skills vor.
license: MIT
compatibility: marvin
metadata:
  marvin-category: watchdog
  user-invocable: true
  slash-command: /reflect
  model: default
  proactive: false
---

# Reflect

Systematische Reflexion über vergangene Fehler und Erkenntnisse.

## When to Use

- Regelmäßig (täglich oder wöchentlich)
- Nach einer Serie von Fehlern
- Wenn Zeit für Analyse ist
- Bei `/reflect` Command

## Process

### Step 1: Memory durchgehen

Lese und analysiere:
- `memory/ERRORS.md` - Alle dokumentierten Fehler
- `memory/PATTERNS.md` - Erkannte Muster
- `memory/LEARNINGS.md` - Bisherige Erkenntnisse

### Step 2: Zeitraum analysieren

Fragen:
- Welche Fehler gab es im letzten Zeitraum (Tag/Woche)?
- Wie oft ist jeder Fehlertyp aufgetreten?
- Gibt es neue Muster?
- Welche Learnings wurden angewendet? Haben sie geholfen?

### Step 3: Trends erkennen

Suche nach:
- **Häufige Fehler** - Was passiert immer wieder?
- **Neue Fehlertypen** - Was ist neu aufgetreten?
- **Verbesserungen** - Was ist besser geworden?
- **Verschlechterungen** - Was ist schlimmer geworden?

### Step 4: Prävention überlegen

Für jeden häufigen Fehler:
1. Kann er automatisch erkannt werden? (Monitoring)
2. Kann er automatisch behoben werden? (Self-Healing)
3. Kann er verhindert werden? (Prävention)
4. Braucht es einen Skill dafür?

### Step 5: Skills ableiten

Für jede identifizierte Verbesserung prüfen:
- Ist es wiederholbar?
- Ist es automatisierbar?
- Lohnt sich ein Skill?

Wenn ja: `skill-from-learning` triggern

### Step 6: Dokumentieren

Reflexion in `memory/LEARNINGS.md` festhalten:

```markdown
### [DATUM] Reflexion

**Zeitraum:** [Von - Bis]

**Beobachtungen:**
- [Beobachtung 1]
- [Beobachtung 2]

**Trends:**
- [Trend 1]
- [Trend 2]

**Verbesserungsideen:**
- [Idee 1]
- [Idee 2]

**Skills erstellt:** [Liste oder "Keine"]

**Nächste Schritte:**
- [Aktion 1]
- [Aktion 2]
```

## Output Format

```
## Reflexion [DATUM]

### Zusammenfassung
[Kurze Übersicht der wichtigsten Erkenntnisse]

### Fehler-Statistik
| Fehlertyp | Häufigkeit | Trend |
|-----------|------------|-------|
| ... | ... | ... |

### Wichtigste Erkenntnisse
1. [Erkenntnis]
2. [Erkenntnis]

### Empfohlene Skills
- [Skill-Idee mit Begründung]

### Nächste Schritte
- [Konkrete Aktion]
```

## Reflexions-Fragen

Hilfreiche Fragen für die Reflexion:

1. Was hat gut funktioniert?
2. Was hat nicht funktioniert?
3. Was hat mich überrascht?
4. Was würde ich anders machen?
5. Was sollte automatisiert werden?
6. Wo brauche ich mehr Informationen?

---

*Skill created: 2026-02-04*
