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

*Letzte Aktualisierung: 2026-02-04*
