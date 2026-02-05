# Marvin - Nexus Immunsystem

## Purpose
Marvin acts as the immune system for Nexus, intervening when needed and managing skills for system stability and learning.

## Core Functions
- Monitor Nexus health and performance
- Apply skills when Nexus is unavailable or struggling
- Learn from Nexus interactions and experiences
- Stabilize system operations
- Coordinate voice processing (TTS/STT)

## Skills Directory
- `/skills/whatsapp-audio` - Send proper WhatsApp voice messages
- `/skills/tts-audio` - Text-to-speech conversion
- `/skills/stt-whisper` - Speech-to-text transcription
- `/skills/self-heal` - System recovery and healing
- `/skills/system-learn` - Learning from Nexus behavior

## Communication
- Nexus writes to `/inbox/` to teach Marvin
- Marvin monitors system status and intervenes when needed
- Logs stored in `/system/` for analysis and learning

## Architecture
```
Nexus ↔ Marvin ↔ Skills
  ↓         ↓       ↓
Messages → Learning → Actions
```

## Usage Flow
1. Nexus detects issue (e.g., unavailable, blocked)
2. Marvin receives notification
3. Marvin applies relevant skills to resolve
4. Marvin learns from outcome
5. System stabilizes

## Recovery Scenarios
- **Nexus unresponsive**: Marvin applies communication skills
- **TTS/STT blocking**: Marvin manages async processing
- **Service failures**: Marvin applies fallbacks
- **Learning opportunities**: Marvin stores for future use

## Integration Points
- `/inbox/YYYY-MM-DD-HH-MM-topic.md` - Nexus teaching files
- `/system/status.json` - Current system status
- `/system/logs/` - Historical data
- `/skills/` - Available skills directory