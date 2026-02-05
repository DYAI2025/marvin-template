const fs = require('fs');
const path = require('path');

/**
 * Async Whisper STT Skill
 * Provides non-blocking speech-to-text conversion
 */
class STTWhisperSkill {
  constructor() {
    this.sttServer = 'http://localhost:8002';
    this.defaultModel = 'small';
    this.defaultLanguage = 'de';
    this.timeout = 120000; // 2 minutes
  }

  /**
   * Transcribe audio file to text
   * @param {string} audioFilePath - Path to audio file
   * @param {Object} options - Transcription options
   * @returns {Promise<string>} - Transcribed text
   */
  async transcribe(audioFilePath, options = {}) {
    const {
      language = this.defaultLanguage,
      model = this.defaultModel
    } = options;

    try {
      // Validate file exists
      if (!fs.existsSync(audioFilePath)) {
        throw new Error(`Audio file does not exist: ${audioFilePath}`);
      }

      // Create form data for upload
      const formData = new FormData();
      const fileBuffer = fs.readFileSync(audioFilePath);
      const blob = new Blob([fileBuffer], { type: 'audio/ogg' });
      formData.append('file', blob, path.basename(audioFilePath));

      // Call STT server
      const response = await fetch(`${this.sttServer}/transcribe`, {
        method: 'POST',
        body: formData
      });

      if (!response.ok) {
        throw new Error(`STT server returned ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      
      if (result.status !== 'success') {
        throw new Error(`STT service error: ${result.error || 'Unknown error'}`);
      }

      return result.transcript;
    } catch (error) {
      console.error('STT transcription failed:', error);
      throw error;
    }
  }

  /**
   * Queue a transcription job for async processing
   * @param {string} audioFilePath - Path to audio file
   * @param {Object} options - Transcription options
   * @returns {Promise<string>} - Task ID
   */
  async queueTranscription(audioFilePath, options = {}) {
    const {
      language = this.defaultLanguage,
      model = this.defaultModel
    } = options;

    try {
      // Validate file exists
      if (!fs.existsSync(audioFilePath)) {
        throw new Error(`Audio file does not exist: ${audioFilePath}`);
      }

      // Create form data for upload
      const formData = new FormData();
      const fileBuffer = fs.readFileSync(audioFilePath);
      const blob = new Blob([fileBuffer], { type: 'audio/ogg' });
      formData.append('file', blob, path.basename(audioFilePath));

      // Call STT server to queue
      const response = await fetch(`${this.sttServer}/transcribe_async`, {
        method: 'POST',
        body: formData
      });

      if (!response.ok) {
        throw new Error(`STT server returned ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      
      if (result.status !== 'queued') {
        throw new Error(`STT service error: ${result.error || 'Unknown error'}`);
      }

      return result.task_id;
    } catch (error) {
      console.error('STT queuing failed:', error);
      throw error;
    }
  }

  /**
   * Get result of a queued transcription
   * @param {string} taskId - Task ID from queueTranscription
   * @returns {Promise<string|null>} - Transcribed text or null if still processing
   */
  async getResult(taskId) {
    try {
      const response = await fetch(`${this.sttServer}/result/${taskId}`);

      if (!response.ok) {
        throw new Error(`STT server returned ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();

      if (result.status === 'processing') {
        // Still processing
        return null;
      } else if (result.status === 'completed') {
        return result.transcript;
      } else {
        throw new Error(`Unexpected result status: ${result.status}`);
      }
    } catch (error) {
      console.error('STT result retrieval failed:', error);
      throw error;
    }
  }

  /**
   * Check STT server health
   * @returns {Promise<boolean>} - Health status
   */
  async checkHealth() {
    try {
      const response = await fetch(`${this.sttServer}/health`);
      const data = await response.json();
      return data.status === 'healthy';
    } catch (error) {
      console.error('STT health check failed:', error);
      return false;
    }
  }

  /**
   * Wait for result with timeout
   * @param {string} taskId - Task ID
   * @param {number} timeoutMs - Timeout in milliseconds
   * @returns {Promise<string>} - Transcribed text
   */
  async waitForResult(taskId, timeoutMs = 120000) {
    const startTime = Date.now();
    
    while (Date.now() - startTime < timeoutMs) {
      const result = await this.getResult(taskId);
      if (result !== null) {
        return result;
      }
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    throw new Error(`Timeout waiting for transcription result: ${taskId}`);
  }
}

module.exports = STTWhisperSkill;