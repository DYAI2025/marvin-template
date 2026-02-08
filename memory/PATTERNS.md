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

*Letzte Aktualisierung: 2026-02-07*
