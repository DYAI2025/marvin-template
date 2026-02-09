# Erkannte Fehlermuster

Hier sammle ich wiederkehrende Muster, die auf bestimmte Problemtypen hinweisen.

---

## Format

```markdown
### Muster: [Name]

**Symptome:**
- Symptom 1
- Symptom 2

**Typische Ursache:** Was steckt dahinter?

**Früherkennung:** Worauf achten?

**Prävention:** Was tun?

**Zugehörige Fehler:** Links zu ERRORS.md
```

---

## Bekannte Muster

### Muster: Memory Leak

**Symptome:**
- Prozess wird langsamer über Zeit
- RAM-Nutzung steigt kontinuierlich
- Eventual crash mit OOM

**Typische Ursache:** Nicht freigegebene Ressourcen, wachsende Caches

**Früherkennung:** RAM-Nutzung beobachten, Trend erkennen

**Prävention:** Regelmäßige Restarts, Memory-Limits setzen

---

### Muster: Port bereits belegt

**Symptome:**
- "Address already in use" Fehler
- Prozess startet nicht

**Typische Ursache:** Vorheriger Prozess nicht sauber beendet, Zombie-Prozess

**Früherkennung:** Port-Check vor Start

**Prävention:** Cleanup-Script, PID-Tracking

---

### Muster: Abhängigkeit nicht erreichbar

**Symptome:**
- Connection timeout/refused
- API-Fehler

**Typische Ursache:** Externer Service down, Netzwerkproblem, Rate Limit

**Früherkennung:** Health-Checks, Ping-Tests

**Prävention:** Retry-Logik, Fallbacks

---

### Muster: Compaction-Timeout nach langem Agent-Run

**Symptome:**
- Nexus antwortet lange nicht (>10 Min)
- Log: "Skipping auto-reply" wiederholt
- Log: "embedded run timeout" nach 600s
- Session als "active" markiert, keine Agent-Events

**Typische Ursache:** Intensive Agent-Runs (Skill-Installationen, große Aufgaben) enden in Session-Compaction die hängen bleibt

**Früherkennung:** "Skipping auto-reply" > 3 in 10 Min

**Prävention:** Regelmäßiges `/compact`, Sessions <5MB halten

---

### Muster: Claude-Prozess-Akkumulation

**Symptome:**
- RAM > 85%, Load > 2.0
- Mehrere `claude` Prozesse unter moltbot (>3)
- System wird langsam, Swap-Aktivität

**Typische Ursache:** Orphan Claude-Prozesse (z.B. claude-mem mit Provider `claude`), parallele Sessions

**Früherkennung:** `pgrep -u moltbot -c claude` > 3

**Prävention:** `CLAUDE_MEM_PROVIDER=gemini`, regelmäßiges Prozess-Cleanup

---

### Muster: Zombie-Gateway (Prozess da, Port tot)

**Symptome:**
- pgrep findet Gateway-Prozess
- Port 18789 antwortet nicht (curl timeout)
- Keine Antworten an User

**Typische Ursache:** Speicherüberlauf, korrupte Session, OOM

**Früherkennung:** Health-Check: Prozess + Port zusammen prüfen

**Prävention:** Session-Größe <5MB, RAM-Monitoring

---

### Muster: Tailscale Serve Intermittent Failure

**Symptome:**
- Gateway-Logs: `tailscale serve failed`
- `tailscale serve status` zeigt "No serve config"
- Remote-Zugriff via Tailnet nicht möglich

**Typische Ursache:** Tailscale-Daemon temporäres Problem, Netzwerk-/DNS-Issue

**Früherkennung:** `tailscale serve status` prüfen, Gateway-Logs auf "serve failed"

**Prävention:** Nicht vermeidbar (externer Service). Self-healing — niedrige Priorität.

---

### Muster: Provider-Kaskaden-Ausfall

**Symptome:**
- Nexus antwortet nicht trotz laufendem Gateway
- Keine API-Fehler im Log (Fallback greift still)
- Oder: Alle Provider geben Fehler zurück

**Typische Ursache:** Primary Provider down, Fallbacks ebenfalls erschöpft (Rate Limits, Quota, Credits)

**Früherkennung:** Log-Muster: `rate.limit`, `quota`, `error.*model`, leere Antworten

**Prävention:** Fallback-Kette mit verschiedenen Providern (aktuell: Kimi → MiniMax → OpenRouter → Gemini). Provider-Status regelmäßig prüfen.

---

### Muster: Claude-Dispatch für Diagnostik

**Symptome:**
- Service crashed und Ursache unklar
- Wiederholte Fehler im gleichen Service
- Service-Guard hat bereits 3x neugestartet (Loop-Limit erreicht)

**Typische Ursache:** Komplexe Fehler, die über einfachen Restart hinausgehen

**Lösung:** `claude -p` spawnen für tiefere Diagnostik:
```bash
# RAM prüfen (braucht ~450MB)
FREE_MB=$(free -m | awk 'NR==2{print $7}')
if [ "$FREE_MB" -gt 500 ]; then
  claude -p "Diagnostiziere warum $SERVICE crashed. Prüfe Logs, Config, Dependencies." \
    --dangerously-skip-permissions --add-dir /home/moltbot > /tmp/diag-$SERVICE.md 2>&1 &
fi
```

**Regel:** Nur spawnen wenn RAM >500MB frei UND keine andere claude -p Instanz läuft.

**Früherkennung:** Service-Guard erreicht 3x Restart-Limit für denselben Service

**Prävention:** Diagnostik-Report lesen und Root-Cause fixen statt nur neustarten

---

### Muster: LLM Dispatch Principle (<5s Regel)

**Kontext:** Nicht jede Aufgabe braucht dieselbe LLM-Qualität.

**Regel:**
- Braucht User Antwort in <5s? → Günstige API (MiniMax M2.1, Gemini Flash)
- Kein Zeitdruck? → `claude -p` über Max-Abo (kostenlos, Opus/Sonnet-Qualität)

**Anwendung für Marvin:**
- Health-Checks und einfache Restarts: kein LLM nötig (Shell-Skripte)
- Komplexe Diagnostik nach Crashes: `claude -p` spawnen
- Nie claude -p für Echtzeit-Chat verwenden

---

*Letzte Aktualisierung: 2026-02-09*
