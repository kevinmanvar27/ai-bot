import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';

/// ElevenLabs AI Voice Service for high-quality, natural voice synthesis
/// API Documentation: https://elevenlabs.io/docs/api-reference
/// Get FREE API key: https://elevenlabs.io/
class ElevenLabsService {
  static bool _isInitialized = false;
  static String? _apiKey;
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // API Configuration
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Voice IDs (ElevenLabs FREE Pre-made Voices - Work with FREE plan)
  // These voices are available in FREE tier via API
  static const Map<String, String> _voiceIds = {
    // Female voices (FREE - Pre-made voices)
    'female_english': 'EXAVITQu4vr4xnSDxMaL', // Sarah - Soft, warm, natural
    'female_hindi': 'EXAVITQu4vr4xnSDxMaL', // Sarah - Multilingual
    'female_gujarati': 'EXAVITQu4vr4xnSDxMaL', // Sarah - Multilingual
    
    // Male voices (FREE - Pre-made voices)
    'male_english': 'TxGEqnHWrfWFTfGW9XjX', // Josh - Deep, confident, natural
    'male_hindi': 'TxGEqnHWrfWFTfGW9XjX', // Josh - Multilingual
    'male_gujarati': 'TxGEqnHWrfWFTfGW9XjX', // Josh - Multilingual
    
    // Alternative FREE voices (you can test these)
    'female_alt1': 'pFZP5JQG7iQjIQuC4Bku', // Lily - Expressive
    'female_alt2': 'jBpfuIE2acCO8z3wKNLl', // Gigi - Young, energetic
    'male_alt1': 'onwK4e9ZLuTAKqWW03F9', // Daniel - Warm, deep
    'male_alt2': 'pqHfZKP75CvOlQylNhV4', // Bill - Friendly
  };
  
  static String _currentVoiceId = _voiceIds['female_english']!;
  static String _currentGender = 'female';
  
  /// Check if ElevenLabs is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Initialize ElevenLabs with API key
  static Future<void> initialize({String gender = 'female'}) async {
    print('🚀 Starting ElevenLabs initialization...');
    try {
      await dotenv.load(fileName: ".env");
      
      _apiKey = dotenv.env['ELEVENLABS_API_KEY'];
      
      print('🔍 DEBUG: ElevenLabs API Key loaded: ${_apiKey?.substring(0, 15)}...');
      
      if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'your_elevenlabs_api_key_here') {
        print('⚠️ WARNING: ElevenLabs API key not configured.');
        _isInitialized = false;
        return;
      }
      
      _currentGender = gender;
      _currentVoiceId = _voiceIds['${gender}_english']!;
      
      print('✅ ElevenLabs initialized successfully!');
      print('🎤 Voice: ${gender == 'female' ? 'Sarah (Natural Female - FREE)' : 'Josh (Natural Male - FREE)'}');
      print('🎵 Model: Turbo v2.5 (Most Natural & Expressive)');
      _isInitialized = true;
      
    } catch (e) {
      print('❌ ElevenLabs initialization failed: $e');
      _isInitialized = false;
    }
  }
  
  /// Detect language from text
  static String _detectLanguage(String text) {
    // Gujarati detection (Native script)
    if (RegExp(r'[\u0A80-\u0AFF]').hasMatch(text)) {
      return 'gujarati';
    }
    
    // Hindi detection (Devanagari script)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return 'hindi';
    }
    
    // Romanized Gujarati keywords
    final lowerText = text.toLowerCase();
    if (lowerText.contains('kem cho') || lowerText.contains('maja') || 
        lowerText.contains('tamari') || lowerText.contains('chhe')) {
      return 'gujarati';
    }
    
    // Romanized Hindi keywords
    if (lowerText.contains('kaise') || lowerText.contains('kya') || 
        lowerText.contains('tumhara') || lowerText.contains('hai')) {
      return 'hindi';
    }
    
    return 'english';
  }
  
  /// Speak text using ElevenLabs AI voice
  /// Returns true if successful, false otherwise
  static Future<bool> speak(String text) async {
    if (!_isInitialized) {
      print('❌ ElevenLabs not initialized');
      return false;
    }
    
    try {
      print('📤 Sending to ElevenLabs: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      
      // Detect language and select appropriate voice
      final language = _detectLanguage(text);
      final voiceKey = '${_currentGender}_$language';
      final voiceId = _voiceIds[voiceKey] ?? _currentVoiceId;
      
      print('🌐 Detected language: $language');
      print('🎤 Using voice: $voiceKey');
      
      // Prepare API request
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': _apiKey!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_turbo_v2_5', // Latest model - MOST NATURAL
          'voice_settings': {
            'stability': 0.45, // Lower = more expressive, human-like variation
            'similarity_boost': 0.75, // Good voice consistency
            'style': 0.85, // Maximum emotional expression & naturalness
            'use_speaker_boost': true, // Enhanced clarity & depth
          },
          // Optional: Add pronunciation dictionary for better Indian language support
          'pronunciation_dictionary_locators': [],
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ ElevenLabs audio received (${response.bodyBytes.length} bytes)');
        
        // Configure audio player for best quality
        await _audioPlayer.setVolume(1.0); // Maximum volume
        await _audioPlayer.setPlaybackRate(1.0); // Normal speed (natural)
        
        // Play audio with high quality
        await _audioPlayer.stop(); // Stop any previous audio
        await _audioPlayer.play(
          BytesSource(response.bodyBytes),
          mode: PlayerMode.mediaPlayer, // Best quality mode
        );
        
        print('🔊 Playing ultra-natural ElevenLabs voice...');
        
        // Wait for audio to complete playing
        await _waitForCompletion();
        
        print('✅ ElevenLabs playback completed');
        return true;
        
      } else {
        print('❌ ElevenLabs API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error with ElevenLabs: $e');
      return false;
    }
  }
  
  /// Stop speaking
  static Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      print('🔇 Stopped ElevenLabs playback');
    } catch (e) {
      print('❌ Error stopping ElevenLabs: $e');
    }
  }
  
  /// Wait for audio playback to complete
  static Future<void> _waitForCompletion() async {
    // Listen to player state changes
    await for (final state in _audioPlayer.onPlayerStateChanged) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        print('🎵 Audio playback finished');
        break;
      }
    }
  }
  
  /// Set voice gender
  static void setGender(String gender) {
    _currentGender = gender;
    _currentVoiceId = _voiceIds['${gender}_english']!;
    print('🎤 Voice gender changed to: $gender');
  }
  
  /// Set specific voice (for custom selection)
  static void setVoice(String voiceKey) {
    if (_voiceIds.containsKey(voiceKey)) {
      _currentVoiceId = _voiceIds[voiceKey]!;
      print('🎤 Voice changed to: $voiceKey');
    } else {
      print('⚠️ Voice $voiceKey not found');
    }
  }
  
  /// Get available voices list
  static Map<String, String> getAvailableVoices() {
    return _voiceIds;
  }
  
  /// Get current voice info
  static String getCurrentVoice() {
    return 'Gender: $_currentGender, Voice ID: $_currentVoiceId';
  }
  
  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      print('🔇 ElevenLabs service disposed');
    } catch (e) {
      print('❌ Error disposing ElevenLabs: $e');
    }
  }
}
