# TTS Audio Skill

## Purpose
Provides high-quality text-to-speech conversion with German voice support.

## Functionality
- Converts text to speech using Edge-TTS
- Supports multiple German voices (Seraphina, Florian, Katja, Conrad)
- Generates audio files in appropriate formats
- Manages TTS server connection and health checks

## Dependencies
- Edge-TTS server (Port 8001)
- Audio processing tools

## Usage
```javascript
// Basic usage
const audioPath = await ttsAudioSkill.generateSpeech(text);

// Advanced usage
const audioPath = await ttsAudioSkill.generateSpeech(text, {
  voice: 'de-DE-SeraphinaMultilingualNeural',
  rate: '+0%',
  volume: '+0%'
});
```

## Configuration
- Server: http://localhost:8001
- Supported voices: de-DE-SeraphinaMultilingualNeural, de-DE-FlorianMultilingualNeural, de-DE-KatjaMultilingualNeural, de-DE-ConradMultilingualNeural
- Output format: MP3

## Recovery Actions
- If TTS server unavailable, switches to backup voice generation
- If voice unavailable, uses default voice
- Reports server status to Marvin for system monitoring

## Integration with Marvin
- Reports TTS server health to Marvin
- Logs voice generation statistics
- Alerts Marvin of service degradation