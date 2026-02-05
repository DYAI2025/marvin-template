# WhatsApp Audio Skill

## Purpose
Enables Nexus to send proper WhatsApp voice messages instead of audio file attachments.

## Functionality
- Converts text to speech using TTS
- Sends audio as native WhatsApp voice message
- Handles audio format conversion for WhatsApp compatibility
- Provides fallback to text if voice fails

## Dependencies
- Edge-TTS server (Port 8001)
- OpenClaw WhatsApp gateway
- Audio conversion tools (ffmpeg)

## Usage
```javascript
// Basic usage
await whatsappAudioSkill.sendVoiceMessage(recipient, text);

// Advanced usage
await whatsappAudioSkill.sendVoiceMessage(recipient, text, {
  voice: 'de-DE-SeraphinaMultilingualNeural',
  speed: 1.0,
  volume: 1.0
});
```

## Recovery Actions
- If voice message fails, falls back to text message
- If TTS server unavailable, notifies Marvin for system intervention
- Logs failures for system learning

## Integration with Marvin
- Logs all voice interactions for Marvin's learning
- Reports failures to Marvin for system healing
- Shares performance metrics with Marvin