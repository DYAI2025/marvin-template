# [ERROR] Tailscale Serve Intermittent Failures

## Summary

Die OpenClaw Gateway versucht bei jedem Start, sich über Tailscale Serve erreichbar zu machen (`tailscale serve --bg --yes 18789`). Am 2026-02-06 Abend schlug dies wiederholt fehl (~3 Stunden lang), bevor es sich selbst erholte. Tailscale Serve ist nicht kritisch für den normalen Betrieb (WhatsApp/Telegram funktionieren ohne), aber es blockiert den Zugriff über das Tailnet (z.B. von Bens MacBook).

## Details

### Symptome

- Gateway-Logs zeigen: `[tailscale] serve failed: Command failed: /usr/bin/tailscale serve --bg --yes 18789`
- Wiederholte Fehler bei jedem Gateway-Start/-Restart
- `tailscale serve status` zeigt "No serve config" während der Ausfallzeit

### Timeline (2026-02-06)

| Zeit | Status |
|------|--------|
| 20:58 | serve failed |
| 21:01 | serve failed |
| 21:58 | serve failed |
| 21:59 | serve failed (2x) |
| 23:49 | **serve enabled** (self-healed) |
| 23:55+ | serve enabled (stabil seitdem) |

### Aktueller Status (2026-02-07)

Tailscale serve funktioniert wieder:
- URL: `https://srv1308064-1.tail80e718.ts.net/`
- Proxy: `http://127.0.0.1:18789`
- Tailscale-Knoten `srv1308064-1` ist online

### Mögliche Ursachen

- Tailscale-Daemon hatte temporäres Problem (nicht im Login-State)
- Netzwerk-/DNS-Problem zum Tailscale Coordination Server
- Sudo-Berechtigung für `tailscale serve` war temporär blockiert
- Tailscale wurde möglicherweise neugestartet/aktualisiert im Hintergrund

### Relevanz für Marvin

- **Nicht kritisch** — Gateway funktioniert ohne Tailscale (WhatsApp/Telegram nutzen direkte Verbindungen)
- **Wichtig für Remote-Zugriff** — Wenn Ben vom MacBook auf Nexus zugreifen will, braucht er Tailscale
- **Selbstheilend** — Hat sich nach ~3 Stunden selbst erholt
- **Kein Eingriff nötig** — Nur beobachten und loggen

### Erkennung

```bash
# Tailscale serve status prüfen
tailscale serve status 2>&1

# Wenn "No serve config" → Tailscale serve ist down
# Wenn URL angezeigt wird → OK

# In Gateway-Logs nach Fehlern suchen
journalctl --user -u openclaw-gateway.service --since "30 min ago" | grep "tailscale.*serve failed"

# Tailscale Daemon-Status
tailscale status | head -5
```

### Empfehlung

- Bei wiederholtem Auftreten: `sudo tailscale serve --bg --yes 18789` manuell ausführen
- Wenn das auch fehlschlägt: `sudo systemctl restart tailscaled` und danach Gateway neustarten
- Nicht eskalieren — ist low-priority, Nexus-Kernfunktionen sind nicht betroffen

---
*Submitted by Nexus via /teach-marvin*
