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
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
                    ▼                     ▼                     ▼
         ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
         │  MESSAGING       │  │  INTELLIGENCE    │  │  VOICE           │
         │  (OpenClaw)      │  │  (Agent Zero)    │  │  (TTS/STT)       │
         └──────────────────┘  └──────────────────┘  └──────────────────┘
                  │                     │                     │
         ┌────────┴────────┐           │            ┌────────┴────────┐
         │                 │           │            │                 │
    ┌─────────┐      ┌─────────┐  ┌─────────┐  ┌─────────┐      ┌─────────┐
    │WhatsApp │      │Telegram │  │ Docker  │  │  TTS    │      │ Whisper │
    │ Channel │      │ Channel │  │Container│  │ Server  │      │  STT    │
    └─────────┘      └─────────┘  └─────────┘  └─────────┘      └─────────┘
```

---

## Komponenten-Matrix

| Komponente | Port | Prozess | Funktion | Abhängigkeiten |
|------------|------|---------|----------|----------------|
| OpenClaw Gateway | 18789 | `openclaw-gateway` | Messaging-Hub | WhatsApp, Telegram, TTS |
| Agent Zero | 80 | Docker `run_ui.py` | Autonomer Agent | Redis, LLM APIs |
| TTS Server | - | `tts_server.py` | Text-to-Speech | Edge TTS API |
| Whisper STT | 8002 | `uvicorn api:app` | Speech-to-Text | Whisper Model |
| Redis | 6379 | Docker `redis:alpine` | Cache/Queue | - |

---

## Datenflüsse

### 1. Eingehende Nachricht (Text)
```
User (WhatsApp/Telegram)
    → OpenClaw Gateway (18789)
    → LLM API (MiniMax/Anthropic)
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
    → Agent Zero (Docker:80)
    → monologue() Loop
    → Tools ausführen
    → Ergebnis zurück
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
   - agent-zero-webui Container ✓
   - Redis Container ✓

---

## Konfigurationsdateien

| Datei | Steuert |
|-------|---------|
| `~/.clawdbot/clawdbot.json` | OpenClaw: Models, Channels, TTS |
| `/home/moltbot/.env` | API Keys, Tokens |
| Docker Compose | Agent Zero, Redis |

---

## Netzwerk-Ports

| Port | Service | Zugriff |
|------|---------|---------|
| 18789 | OpenClaw Gateway | localhost |
| 8002 | Whisper STT | localhost |
| 80 | Agent Zero (Docker) | localhost |
| 8000 | Agent Zero UI | extern |
| 6379 | Redis | Docker intern |

---

*Letzte Aktualisierung: 2026-02-04*
*Quelle: Watchdog-Analyse + Nexus-Feedback*
