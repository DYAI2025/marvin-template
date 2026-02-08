# Nexus System-Architektur

Wie alles zusammenhängt.

---

## Überblick

```
                         ┌─────────────────────────────────────┐
                         │           NEXUS (OpenCore)          │
                         │      Persönlicher AI-Assistent      │
                         └─────────────────────────────────────┘
                                          │
          ┌──────────────┬────────────────┼────────────────┬──────────────┐
          │              │                │                │              │
          ▼              ▼                ▼                ▼              ▼
 ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
 │  MESSAGING   │ │ INTELLIGENCE │ │    VOICE     │ │   COACHING   │ │   KANBAN     │
 │  (OpenClaw)  │ │ (Agent Zero) │ │  (TTS/STT)  │ │  (Nanobot)   │ │(Vercel+Redis)│
 └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
        │                │                │                │              │
   ┌────┴────┐      ┌─────────┐    ┌─────┴─────┐     ┌─────────┐   ┌─────────┐
   │WhatsApp │      │ Docker  │    │  Whisper  │     │Telegram │   │ Upstash │
   │Telegram │      │Container│    │  TTS Srv  │     │ Channel │   │  Redis  │
   └─────────┘      └─────────┘    └───────────┘     └─────────┘   └─────────┘
```

---

## Komponenten-Matrix

| Komponente | Port | Prozess | Funktion | Abhängigkeiten |
|------------|------|---------|----------|----------------|
| OpenClaw Gateway | 18789 | systemd `openclaw-gateway.service` | Messaging-Hub | WhatsApp, Telegram, TTS, LLM APIs |
| Agent Zero | 50080 (→80 intern) | Docker `agent-zero` | Autonomer Agent | LLM APIs |
| TTS Server | - | systemd `tts-server` | Text-to-Speech | Edge TTS API |
| Whisper STT | 8002 | systemd `whisper-stt` | Speech-to-Text | Whisper Model |
| Planka | 18790 | Docker compose | Projekt-Management | PostgreSQL |
| Coach (Perr00bot) | 18791 | nanobot process | Telegram Agile Coach | Gemini API |
| Kanban API | extern | Vercel serverless | Task-Board | Upstash Redis |
| Nexus Dashboard | 3003 | node `server.cjs` | Service-Übersicht | - |
| Ollama | 11434 | systemd `ollama` | Lokales LLM (niedrige Prio) | RAM (500-800MB) |

---

## Datenflüsse

### 1. Eingehende Nachricht (Text)
```
User (WhatsApp/Telegram)
    → OpenClaw Gateway (18789)
    → LLM API (Kimi K2.5 / MiniMax M2.1 / Gemini / etc.)
    → Antwort generieren
    → [Optional: TTS]
    → Zurück an User
```

### 2. Eingehende Sprachnachricht
```
User (Voice)
    → OpenClaw Gateway
    → Whisper STT (8002) [ASYNC]
    → Text extrahiert
    → LLM verarbeitet
    → TTS generiert Audio
    → Zurück als Sprachnachricht
```

### 3. Agent Zero Aufgabe
```
Trigger (User oder System)
    → Agent Zero (Docker:50080 → intern :80)
    → monologue() Loop
    → Tools ausführen
    → Ergebnis zurück
```

### 4. Coach (Perr00bot)
```
Ben (Telegram)
    → Nanobot Gateway (18791)
    → Gemini 2.0 Flash
    → Kanban API (Vercel + Upstash Redis)
    → Coaching-Antwort zurück
```

---

## Kritische Pfade

### Was muss laufen damit Nexus antwortet?

1. **Minimal (Text-only):**
   - OpenClaw Gateway ✓
   - LLM API erreichbar ✓
   - API Key gültig ✓

2. **Mit Voice:**
   - Alles von Minimal +
   - Whisper STT (async) ✓
   - TTS Server ✓

3. **Mit Agent Zero:**
   - Docker läuft ✓
   - agent-zero Container ✓

---

## Konfigurationsdateien

| Datei | Steuert |
|-------|---------|
| `~/.openclaw/clawdbot.json` | OpenClaw: Models, Channels, TTS |
| `/home/moltbot/.env` | API Keys, Tokens |
| `~/.nanobot/config.json` | Coach/Perr00bot: Model, Telegram, Kanban |
| Docker Compose | Agent Zero, Planka |

---

## Netzwerk-Ports

| Port | Service | Zugriff |
|------|---------|---------|
| 3003 | Nexus Dashboard | localhost |
| 8002 | Whisper STT | localhost |
| 11434 | Ollama | localhost |
| 18789 | OpenClaw Gateway | localhost |
| 18790 | Planka | extern |
| 18791 | Coach Gateway (Nanobot) | localhost |
| 50080 | Agent Zero (Docker) | localhost |

---

## Steuerungsbefehle

### OpenClaw Gateway (systemd user service)
```bash
# Status
systemctl --user status openclaw-gateway.service
curl -s localhost:18789 > /dev/null && echo "UP" || echo "DOWN"

# Neustart
systemctl --user restart openclaw-gateway.service

# Logs
journalctl --user -u openclaw-gateway.service -f
journalctl --user -u openclaw-gateway.service --since "10 min ago"
```

### Agent Zero (Docker)
```bash
# Status
docker ps | grep agent-zero
curl -s localhost:50080 > /dev/null && echo "UP" || echo "DOWN"

# Starten/Stoppen/Neustarten
docker start agent-zero
docker stop agent-zero
docker restart agent-zero

# Logs
docker logs -f agent-zero
docker logs --tail 100 agent-zero

# Debug (in Container)
docker exec -it agent-zero /bin/bash
```

### Coach / Perr00bot (Nanobot)
```bash
# Status
pgrep -u moltbot -f "nanobot gateway" && echo "UP" || echo "DOWN"

# Neustart
pkill -f "nanobot gateway" 2>/dev/null; sleep 2
cd /home/moltbot && nanobot gateway --verbose --port 18791 &

# Config
cat ~/.nanobot/config.json
```

### Health Check (alle)
```bash
curl -s localhost:18789 > /dev/null && echo "Gateway: UP" || echo "Gateway: DOWN"
curl -s localhost:50080 > /dev/null && echo "Agent Zero: UP" || echo "Agent Zero: DOWN"
curl -s localhost:8002/health > /dev/null && echo "Whisper: UP" || echo "Whisper: DOWN"
curl -s localhost:18790 > /dev/null && echo "Planka: UP" || echo "Planka: DOWN"
curl -s localhost:3003 > /dev/null && echo "Dashboard: UP" || echo "Dashboard: DOWN"
```

---

## LLM Model Chain (Stand 2026-02-06)

**Primary:** Kimi K2.5 (`kimi-coding/k2p5`)
**Fallbacks:** MiniMax M2.1 → Claude Haiku 4.5 (OR) → Gemini 2.5 Pro → Claude Sonnet 4.5 (OR) → Gemini 2.5 Flash → Qwen (free)

**Working Providers:** Gemini, OpenRouter (topped up), MiniMax
**Broken:** OpenAI (quota exceeded), Anthropic direct (no credits — use via OpenRouter)

---

## Tailscale (Remote-Zugriff)

Gateway registriert sich bei Start über Tailscale Serve für Remote-Zugriff:
- **URL:** `https://srv1308064-1.tail80e718.ts.net/`
- **Proxy:** `http://127.0.0.1:18789`
- **Befehl:** `tailscale serve --bg --yes 18789` (benötigt sudo)

**Priorität: NIEDRIG** — WhatsApp/Telegram funktionieren ohne Tailscale. Nur für Remote-Zugriff (z.B. Bens MacBook) relevant.

**Bekanntes Problem:** Intermittent failures (Feb 2026-02-06, ~3h Ausfall, self-healed). Siehe ERRORS.md.

```bash
# Status prüfen
tailscale serve status
tailscale status | head -5

# Manuell aktivieren
sudo tailscale serve --bg --yes 18789

# Daemon neustarten
sudo systemctl restart tailscaled
```

---

*Letzte Aktualisierung: 2026-02-07*
*Quelle: Inbox-Verarbeitung + Watchdog-Analyse + Claude Code*
