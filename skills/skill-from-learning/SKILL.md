---
name: skill-from-learning
description: |
  Erzeugt neue Skills aus dokumentierten Learnings.
  Transformiert Wissen in automatisierte Fähigkeiten.
license: MIT
compatibility: marvin
metadata:
  marvin-category: meta
  user-invocable: false
  slash-command: null
  model: default
  proactive: true
---

# Skill from Learning

Erzeugt automatisierte Skills aus dokumentierten Erkenntnissen.

## When to Use

- Wenn ein Learning automatisierbar ist
- Wenn ein Fehler mehrfach aufgetreten ist
- Nach einer Reflexion mit Skill-Empfehlung
- Wenn eine manuelle Aufgabe wiederholt ausgeführt wird

## Kriterien für Skill-Erstellung

Ein Skill sollte erstellt werden wenn:

1. **Wiederholbar** - Die Aufgabe kommt regelmäßig vor
2. **Definiert** - Die Schritte sind klar
3. **Automatisierbar** - Kann mit Commands/Scripts erledigt werden
4. **Nützlich** - Spart Zeit oder verhindert Fehler

## Process

### Step 1: Learning analysieren

Aus dem Learning extrahieren:
- Was ist das Problem?
- Was ist die Lösung?
- Welche Schritte sind nötig?
- Wann soll es ausgelöst werden?

### Step 2: Skill designen

Festlegen:
- **name**: Kurz, beschreibend, kebab-case
- **Trigger**: Wann wird der Skill aktiv?
- **Input**: Was braucht der Skill?
- **Output**: Was liefert der Skill?
- **Schritte**: Wie funktioniert er?

### Step 3: Skill erstellen

Verzeichnis anlegen:
```bash
mkdir -p skills/{skill-name}
```

SKILL.md erstellen mit:
```markdown
---
name: {skill-name}
description: |
  {Beschreibung basierend auf dem Learning}
license: MIT
compatibility: marvin
metadata:
  marvin-category: watchdog
  user-invocable: {true|false}
  slash-command: {/command oder null}
  model: default
  proactive: {true|false}
---

# {Skill-Titel}

{Beschreibung}

## Entstehung

Dieser Skill entstand aus folgendem Learning:
- **Datum:** {Datum des Learnings}
- **Learning:** {Link zu LEARNINGS.md}
- **Fehler:** {Link zu ERRORS.md falls relevant}

## When to Use

- {Trigger 1}
- {Trigger 2}

## Process

### Step 1: {Schritt}
{Beschreibung}

### Step 2: {Schritt}
{Beschreibung}

## Output Format

{Erwartete Ausgabe}

---

*Skill created: {HEUTE}*
*Based on learning from: {LEARNING-DATUM}*
```

### Step 4: Dokumentieren

In `memory/LEARNINGS.md` aktualisieren:
- Skill-Link hinzufügen
- Status: "Skill erstellt"

### Step 5: Bestätigen

Melden:
```
Neuer Skill erstellt: **{skill-name}**
- Location: `skills/{skill-name}/SKILL.md`
- Basiert auf: {Learning-Referenz}
- Trigger: {Wie wird er ausgelöst}

Der Skill ist einsatzbereit.
```

## Output Format

```
## Skill erstellt

**Name:** {skill-name}
**Basiert auf:** {Learning}
**Location:** skills/{skill-name}/SKILL.md

### Funktion
{Was der Skill tut}

### Trigger
{Wann er aktiv wird}

Der Skill wurde in LEARNINGS.md verlinkt.
```

## Beispiele

### Beispiel: Port-Cleanup Skill

Learning: "Port 18789 war belegt weil alter Prozess nicht beendet wurde"

Skill:
- **name:** port-cleanup
- **Trigger:** Vor Gateway-Start
- **Aktion:** Prüfe ob Port belegt, beende Zombie-Prozess
- **Output:** Port ist frei oder Warnung

---

*Skill created: 2026-02-04*
