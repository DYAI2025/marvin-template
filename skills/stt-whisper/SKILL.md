# Async Whisper STT Skill

## Purpose
Provides non-blocking speech-to-text conversion for voice messages.

## Functionality
- Processes audio files asynchronously using Whisper
- Prevents blocking during transcription
- Runs on dedicated service (Port 8002)
- Handles multiple concurrent transcription requests

## Dependencies
- Async Whisper STT service (Port 8002)
- Whisper models (small, medium, large)
- Audio processing tools

## Usage
```javascript
// Basic usage
const transcript = await sttWhisperSkill.transcribe(audioFilePath);

// Async usage
const taskId = await sttWhisperSkill.queueTranscription(audioFilePath);
const transcript = await sttWhisperSkill.getResult(taskId);

// Advanced usage with language
const transcript = await sttWhisperSkill.transcribe(audioFilePath, {
  language: 'de',
  model: 'small'
});
```

## Configuration
- Server: http://localhost:8002
- Default model: small
- Default language: de (German)
- Timeout: 120 seconds
- Max file size: 50MB

## Recovery Actions
- If transcription fails, reports error to Marvin
- If service unavailable, queues requests for retry
- Falls back to synchronous processing if async unavailable
- Monitors service health and restarts if needed

## Integration with Marvin
- Reports transcription success/failure rates
- Logs processing times for optimization
- Alerts Marvin of service issues
- Shares queue status for system awareness