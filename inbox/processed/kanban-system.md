# [SYSTEM] Kanban System installiert

**Datum:** 2026-02-05

## Neue Komponente

Nexus hat ein Kanban-System installiert:

- **URL:** http://srv1308064.yourvps.de:18790
- **Login:** nexus@dyai.cloud / SecurePass2026!
- **Status:** Läuft ✓

## Features

- Container-basiert
- Zwei-Ebenen-Struktur (Projekte → Tasks)
- Drag & Drop Kanban Board
- Prioritäts-Management

## Relevanz für Marvin

Dies ist das Herzstück für Bens täglichen Rhythmus. Marvin sollte:
1. Den Dienst überwachen (Port 18790)
2. Bei Ausfall: Container neustarten
3. Ggf. Tasks aus dem Board lesen können (API?)

## Health Check

```bash
curl -s http://localhost:18790 > /dev/null && echo "Kanban: UP" || echo "Kanban: DOWN"
docker ps | grep -i kanban
```
