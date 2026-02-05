const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * WhatsApp Audio Skill
 * Enables Nexus to send proper WhatsApp voice messages
 */
class WhatsAppAudioSkill {
  constructor() {
    this.ttsServer = 'http://localhost:8001';
    this.supportedVoices = [
      'de-DE-SeraphinaMultilingualNeural',
      'de-DE-FlorianMultilingualNeural', 
      'de-DE-KatjaMultilingualNeural',
      'de-DE-ConradMultilingualNeural'
    ];
  }

  /**
   * Send a voice message via WhatsApp
   * @param {string} recipient - WhatsApp number or group ID
   * @param {string} text - Text to convert to speech
   * @param {Object} options - Voice options
   * @returns {Promise<string>} - Path to generated audio file
   */
  async sendVoiceMessage(recipient, text, options = {}) {
    try {
      // Generate speech
      const audioPath = await this.generateSpeech(text, options);
      
      // Check if OpenClaw supports sending as voice message
      // For now, we'll log the intent - actual implementation would depend on OpenClaw's API
      console.log(`Generated voice message for ${recipient}: ${audioPath}`);
      
      // Return path for OpenClaw to handle
      return audioPath;
    } catch (error) {
      console.error('Failed to send voice message:', error);
      throw error;
    }
  }

  /**
   * Generate speech from text using TTS server
   * @param {string} text - Text to convert
   * @param {Object} options - Voice options
   * @returns {Promise<string>} - Path to generated audio file
   */
  async generateSpeech(text, options = {}) {
    const {
      voice = 'de-DE-SeraphinaMultilingualNeural',
      rate = '+0%',
      volume = '+0%'
    } = options;

    try {
      // Call TTS server
      const response = await fetch(`${this.ttsServer}/tts`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          text,
          voice,
          rate,
          volume
        })
      });

      if (!response.ok) {
        throw new Error(`TTS server returned ${response.status}`);
      }

      const result = await response.json();
      
      // Return the audio path
      return path.join(process.cwd(), result.audio_path);
    } catch (error) {
      console.error('TTS generation failed:', error);
      throw error;
    }
  }

  /**
   * Check if TTS server is healthy
   * @returns {Promise<boolean>} - Health status
   */
  async checkHealth() {
    try {
      const response = await fetch(`${this.ttsServer}/health`);
      return response.ok;
    } catch (error) {
      return false;
    }
  }
}

module.exports = WhatsAppAudioSkill;