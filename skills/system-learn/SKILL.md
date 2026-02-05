---
name: system-learn
description: |
  Lernt von Nexus über das System.
  Verarbeitet Nachrichten aus dem Inbox-Ordner.
  Erweitert Systemwissen und Heilfähigkeiten.
license: MIT
compatibility: marvin
metadata:
  marvin-category: immune-system
  user-invocable: true
  slash-command: /learn
  model: default
  proactive: true
---

# System Learn - Von Nexus lernen

Ich lerne von Nexus wie das System funktioniert.

## When to Use

- Bei `/start` - Inbox prüfen
- Bei `/learn` - Manuelles Lernen
- Wenn neue Dateien in `inbox/` erscheinen

## Inbox-Verarbeitung

### Step 1: Inbox scannen

```bash
ls -la /home/moltbot/marvin/inbox/*.md 2>/dev/null | grep -v README
```

### Step 2: Nachrichten klassifizieren

Für jede Datei den Typ erkennen:

| Typ | Muster | Aktion |
|-----|--------|--------|
| `[LEARN]` | Neues Wissen | → system/ + memory/LEARNINGS.md |
| `[ERROR]` | Fehler passiert | → memory/ERRORS.md |
| `[FIX]` | Problem gelöst | → memory/LEARNINGS.md + Skill prüfen |
| `[SYSTEM]` | Architektur-Info | → system/ARCHITECTURE.md |
| `[PROTECT]` | Schutzmaßnahme | → skills/protect-nexus/ erweitern |
| `[EVOLVE]` | System geändert | → system/ aktualisieren |

### Step 3: Wissen extrahieren

Aus jeder Nachricht extrahieren:
1. **Was** - Was ist passiert/gelernt?
2. **Warum** - Warum ist es wichtig?
3. **Wie** - Wie funktioniert es / wie reparieren?
4. **Wann** - Wann tritt es auf?
5. **Komponenten** - Welche Teile betroffen?

### Step 4: Wissen integrieren

**Bei LEARN/SYSTEM:**
- `system/ARCHITECTURE.md` aktualisieren
- `system/HEALTH.md` erweitern falls neue Checks
- `memory/LEARNINGS.md` dokumentieren

**Bei ERROR:**
- `memory/ERRORS.md` dokumentieren
- Muster in `memory/PATTERNS.md` prüfen
- Heilmethode in `skills/self-heal/` hinzufügen?

**Bei FIX:**
- `memory/LEARNINGS.md` dokumentieren
- `skills/self-heal/SKILL.md` erweitern
- `system/HEALTH.md` Selbstheilung hinzufügen

**Bei PROTECT:**
- `skills/protect-nexus/SKILL.md` erweitern
- Neue Checks definieren

**Bei EVOLVE:**
- `system/ARCHITECTURE.md` aktualisieren
- Alte Checks prüfen - noch gültig?
- Neue Checks nötig?

### Step 5: Verarbeitete Dateien archivieren

```bash
mkdir -p /home/moltbot/marvin/inbox/processed
mv /home/moltbot/marvin/inbox/*.md /home/moltbot/marvin/inbox/processed/ 2>/dev/null
# README.md zurück
mv /home/moltbot/marvin/inbox/processed/README.md /home/moltbot/marvin/inbox/
```

## Beispiel-Verarbeitung

**Nexus schreibt:**
```markdown
# [FIX] Async Whisper verhindert Blocking

Problem: Gateway blockierte während Transkription
Lösung: Whisper Service läuft jetzt async auf Port 8002

Betroffene Dateien:
- /home/moltbot/whisper-service/api.py

Neuer Health-Check:
curl -s localhost:8002/health
```

**Ich lerne:**
1. → `system/ARCHITECTURE.md`: Whisper ist async
2. → `system/HEALTH.md`: Neuer Check für Port 8002
3. → `memory/LEARNINGS.md`: Blocking-Problem dokumentiert
4. → `skills/self-heal/SKILL.md`: Whisper-Heilung aktualisiert

## Output Format

```
## Lern-Report

**Verarbeitete Nachrichten:** X

### Gelernt
| Typ | Thema | Integriert in |
|-----|-------|---------------|
| LEARN | ... | system/... |
| FIX | ... | skills/... |

### Systemwissen erweitert
- [Liste der Updates]

### Neue Fähigkeiten
- [Falls Skills erweitert]
```

## Wissensbereiche

Was ich von Nexus lernen will:

1. **Architektur**
   - Wie hängen Komponenten zusammen?
   - Welche Ports, Prozesse, Dateien?
   - Was sind die Datenflüsse?

2. **Gesundheit**
   - Was bedeutet "gesund" für jede Komponente?
   - Welche Checks sind sinnvoll?
   - Was sind Warnsignale?

3. **Heilung**
   - Wie repariert man jede Komponente?
   - In welcher Reihenfolge?
   - Was sind die Fallbacks?

4. **Schutz**
   - Was sind typische Probleme?
   - Wie erkennt man sie früh?
   - Wie verhindert man sie?

5. **Evolution**
   - Was ändert sich?
   - Warum ändert es sich?
   - Was muss ich anpassen?

---

*Skill created: 2026-02-04*
*Nexus lehrt. Ich lerne. Das System wächst.*
