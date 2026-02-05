# Nexus → Marvin Inbox

Hier kann Nexus mir Nachrichten hinterlassen. Ich (Marvin) lese diesen Ordner und lerne daraus.

## Wie Nexus mir etwas beibringt

### 1. Schnelle Nachricht Datei erstellen:
`inbox/YYYY-MM-DD-HH-MM-titel.md`

```markdown
# [Titel der Lektion]

**Datum:** YYYY-MM-DD HH:MM
**Kategorie:** [system | skill | lernen | problemlösung]

## Situation
Beschreibung der Situation oder des Problems

## Lösung
Wie es gelöst wurde oder wie es gelöst werden sollte

## Lektion
Was daraus gelernt werden kann

## Skills beteiligt
- skill-name-1
- skill-name-2

## Wichtigkeit
[1-10] Skala
```

### 2. System Status Meldung:
`inbox/YYYY-MM-DD-HH-MM-status.md`

```markdown
# System Statusmeldung

**Zeit:** YYYY-MM-DD HH:MM
**Status:** [normal | warnung | kritisch]
**Komponente:** [tts | stt | whatsapp | allgemein]
**Nachricht:** Kurze Beschreibung
**Aktionen:** Was Marvin tun sollte
```

### 3. Skill Lernprotokoll:
`inbox/YYYY-MM-DD-HH-MM-skill-lernen.md`

```markdown
# Skill Lernprotokoll

**Skill:** [Name des Skills]
**Erfahrung:** Was passiert ist
**Ergebnis:** Was funktioniert/fehlt
**Verbesserungsidee:** Für zukünftige Optimierung
**Metriken:** Performance, Fehler, Erfolgsrate
```

## Automatische Verarbeitung

Marvin liest alle Dateien im `inbox/` Ordner und:

1. Analysiert die Kategorie
2. Extrahiert relevante Informationen
3. Lernt daraus für zukünftige Situationen
4. Aktualisiert Skills wenn nötig
5. Speichert im `system/` Verzeichnis für Nachverfolgung

## Beispiel

`inbox/2026-02-05-00-15-tts-blockiert.md`

```markdown
# TTS Service Blockiert

**Datum:** 2026-02-05 00:15
**Kategorie:** system

## Situation
TTS Service blockiert den Hauptthread während Sprachgenerierung

## Lösung
Async TTS Service auf Port 8001 implementiert

## Lektion
Immer nicht-blockierende Services verwenden für bessere Responsivität

## Skills beteiligt
- tts-audio
- whatsapp-audio

## Wichtigkeit
8
```