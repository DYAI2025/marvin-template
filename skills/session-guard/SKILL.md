# Session Guard

Automatische Erkennung und Heilung von Session-Problemen.

## Was es macht

1. **Erkennt** `call_id empty string` Fehler in OpenClaw-Logs
2. **Heilt automatisch** durch Session-Backup und Reset
3. **Warnt** bei großen Sessions (>5MB) bevor sie korrupt werden
4. **Dokumentiert** alle Interventionen

## Automatische Ausführung

Läuft alle 5 Minuten via Cron:
```
*/5 * * * * /home/moltbot/marvin/skills/session-guard/session-guard.sh
```

## Manuelle Ausführung

```bash
/home/moltbot/marvin/skills/session-guard/session-guard.sh
```

## Logs

- Skill-Log: `/home/moltbot/marvin/sessions/session-guard.log`
- Interventionen: `/home/moltbot/marvin/memory/INTERVENTIONS.md`

## Erkannte Muster

| Muster | Aktion |
|--------|--------|
| `call_id.*empty string` in Logs | Auto-Reset Session |
| Session >5MB | Warnung (kein Auto-Reset) |

## Heilungsprozess

1. Fehler in Log erkannt
2. Session-Datei wird gesichert (`.backup.TIMESTAMP`)
3. Original wird entfernt
4. Nexus startet automatisch neue Session
5. Intervention wird dokumentiert

---

*Teil von Marvin's Immunsystem*
