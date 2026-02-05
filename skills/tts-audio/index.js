const fs = require('fs');
const path = require('path');

/**
 * TTS Audio Skill
 * Provides high-quality text-to-speech conversion
 */
class TTSAudioSkill {
  constructor() {
    this.ttsServer = 'http://localhost:8001';
    this.defaultVoice = 'de-DE-SeraphinaMultilingualNeural';
    this.supportedVoices = [
      'de-DE-SeraphinaMultilingualNeural',
      'de-DE-FlorianMultilingualNeural', 
      'de-DE-KatjaMultilingualNeural',
      'de-DE-ConradMultilingualNeural'
    ];
  }

  /**
   * Generate speech from text
   * @param {string} text - Text to convert
   * @param {Object} options - Voice options
   * @returns {Promise<string>} - Path to generated audio file
   */
  async generateSpeech(text, options = {}) {
    const {
      voice = this.defaultVoice,
      rate = '+0%',
      volume = '+0%'
    } = options;

    try {
      // Validate voice
      if (!this.supportedVoices.includes(voice)) {
        console.warn(`Unsupported voice: ${voice}, falling back to default`);
        voice = this.defaultVoice;
      }

      // Call TTS server
      const response = await fetch(`${this.ttsServer}/tts`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          text: text.substring(0, 2000), // Limit text length
          voice,
          rate,
          volume
        })
      });

      if (!response.ok) {
        throw new Error(`TTS server returned ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      
      if (result.status !== 'ok') {
        throw new Error(`TTS service error: ${result.error || 'Unknown error'}`);
      }

      // Return the audio path
      return path.resolve(result.audio_path);
    } catch (error) {
      console.error('TTS generation failed:', error);
      throw error;
    }
  }

  /**
   * Get available voices
   * @returns {Array<string>} - List of supported voices
   */
  getAvailableVoices() {
    return [...this.supportedVoices];
  }

  /**
   * Check TTS server health
   * @returns {Promise<boolean>} - Health status
   */
  async checkHealth() {
    try {
      const response = await fetch(`${this.ttsServer}/health`);
      const data = await response.json();
      return data.status === 'healthy';
    } catch (error) {
      console.error('TTS health check failed:', error);
      return false;
    }
  }

  /**
   * Get TTS server info
   * @returns {Promise<Object>} - Server information
   */
  async getServerInfo() {
    try {
      const response = await fetch(`${this.ttsServer}/health`);
      return await response.json();
    } catch (error) {
      console.error('Failed to get server info:', error);
      return null;
    }
  }
}

module.exports = TTSAudioSkill;