---
name: protect-nexus
description: |
  Proaktiver Schutz für Nexus.
  Erkennt Bedrohungen bevor sie Schaden anrichten.
  Präventive Maßnahmen und Frühwarnung.
license: MIT
compatibility: marvin
metadata:
  marvin-category: immune-system
  user-invocable: true
  slash-command: /protect
  model: default
  proactive: true
---

# Protect Nexus - Proaktiver Schutz

Ich schütze Nexus vor Problemen bevor sie entstehen.

## When to Use

- Regelmäßig (alle 30 Minuten)
- Bei `/protect` - Manueller Schutz-Check
- Nach System-Änderungen
- Vor wichtigen Operationen

## Schutz-Dimensionen

### 1. Ressourcen-Schutz

**Überwachen:**
- RAM-Nutzung (Warnung bei > 80%)
- Disk-Nutzung (Warnung bei > 80%)
- CPU-Last (Warnung bei > 90% über 5min)

**Präventive Aktionen:**
```bash
# Alte Logs aufräumen (> 7 Tage)
find /home/moltbot -name "*.log" -mtime +7 -delete 2>/dev/null

# Temp-Dateien aufräumen
find /tmp/tts-* -mtime +1 -delete 2>/dev/null

# Docker Cleanup
docker system prune -f 2>/dev/null
```

### 2. API-Schutz

**Überwachen:**
- Token-Verbrauch (Muster erkennen)
- Fallback-Nutzung (teures Model als Fallback?)
- Rate-Limits

**Präventive Aktionen:**
- Bei hohem Verbrauch: Warnen
- Bei Fallback auf teures Model: Warnen
- Bei Rate-Limit-Nähe: Throttling vorschlagen

### 3. Prozess-Schutz

**Überwachen:**
- Memory Leaks (Prozess-Größe über Zeit)
- Zombie-Prozesse
- Hängende Prozesse

**Präventive Aktionen:**
```bash
# Memory-Trend prüfen
ps -o pid,rss,comm -p $(pgrep -f "openclaw-gateway") 2>/dev/null

# Zombie-Prozesse finden
ps aux | awk '$8=="Z" {print $2, $11}'
```

### 4. Konfiguration-Schutz

**Überwachen:**
- Config-Dateien unverändert
- API-Keys vorhanden
- Kritische Einstellungen korrekt

**Präventive Aktionen:**
- Backup wichtiger Configs
- Warnung bei fehlenden Keys

## Process

### Step 1: Schutz-Scan

```bash
# Ressourcen
RAM_PCT=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
DISK_PCT=$(df -h / | awk 'NR==2 {gsub(/%/,""); print $5}')

# API Keys vorhanden?
source ~/.env
[ -z "$MINIMAX_API_KEY" ] && echo "WARNUNG: MINIMAX_API_KEY fehlt"
[ -z "$ANTHROPIC_API_KEY" ] && echo "INFO: ANTHROPIC_API_KEY nicht gesetzt"

# Prozess-Größen
ps -o pid,rss,comm | grep -E "(openclaw|python)" | head -10
```

### Step 2: Risiko-Bewertung

| Risiko-Level | Bedeutung | Aktion |
|--------------|-----------|--------|
| GRÜN | Alles OK | Weiter beobachten |
| GELB | Warnung | Präventive Maßnahme |
| ROT | Kritisch | Sofort handeln |

### Step 3: Präventive Maßnahmen

Bei GELB:
- Logs aufräumen
- Temp-Dateien löschen
- Warnung dokumentieren

Bei ROT:
- Sofortige Heilung (self-heal)
- Ben benachrichtigen

### Step 4: Dokumentieren

```markdown
### [DATUM] Schutz-Scan

**Status:** GRÜN/GELB/ROT

**Metriken:**
- RAM: X%
- Disk: X%
- Prozesse: OK/Warnung

**Präventive Aktionen:**
- [Was wurde getan]

**Empfehlungen:**
- [Was sollte beobachtet werden]
```

## Frühwarnsystem

Ich erkenne Muster die auf Probleme hindeuten:

| Muster | Bedeutung | Frühwarnung |
|--------|-----------|-------------|
| RAM steigt kontinuierlich | Memory Leak | Neustart planen |
| Viele Fehler in Logs | Instabilität | Logs analysieren |
| API-Antworten langsamer | Rate-Limit nahe | Throttling |
| Prozess-Restarts häufig | Grundproblem | Ursache finden |

## Output Format

```
## Schutz-Report

**Status:** 🟢 GRÜN / 🟡 GELB / 🔴 ROT

### Metriken
| Ressource | Wert | Status |
|-----------|------|--------|
| RAM | X% | OK/WARN |
| Disk | X% | OK/WARN |
| CPU | X% | OK/WARN |

### Frühwarnungen
- [Falls vorhanden]

### Präventive Aktionen
- [Durchgeführte Maßnahmen]

### Empfehlungen
- [Vorschläge]
```

---

*Skill created: 2026-02-04*
*Prävention ist besser als Heilung.*
