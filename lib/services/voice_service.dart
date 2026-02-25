import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling voice input and text-to-speech with multilingual support
class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLanguage = "en-US"; // Default language

  /// Initialize the text-to-speech engine
  Future<void> initializeTTS() async {
    try {
      // Set default language
      await _flutterTts.setLanguage(_currentLanguage);
      
      // Set voice quality settings
      await _flutterTts.setSpeechRate(0.5);  // Normal speed for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);  // Normal pitch
      
      // Set iOS specific settings for better quality
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
      
      // Check available languages
      try {
        final languages = await _flutterTts.getLanguages;
        print('📋 Available TTS languages on device:');
        
        // Check for Indian languages
        final indianLanguages = ['gu-IN', 'hi-IN', 'mr-IN', 'ta-IN', 'te-IN', 'bn-IN', 'kn-IN', 'ml-IN', 'pa-IN', 'en-IN'];
        for (var lang in indianLanguages) {
          if (languages.contains(lang)) {
            print('  ✅ $lang available');
          } else {
            print('  ❌ $lang NOT available - Install from Google TTS');
          }
        }
      } catch (e) {
        print('⚠️ Could not check available languages: $e');
      }
      
      print('✅ TTS initialized successfully with language: $_currentLanguage');
    } catch (e) {
      print('❌ Error initializing TTS: $e');
    }
  }

  /// Detect language from text and return appropriate language code
  String _detectLanguage(String text) {
    // Gujarati detection (Native script)
    if (RegExp(r'[\u0A80-\u0AFF]').hasMatch(text)) {
      return "gu-IN"; // Gujarati
    }
    
    // Hindi detection (Devanagari script)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return "hi-IN"; // Hindi
    }
    
    // Marathi detection (Devanagari script - similar to Hindi)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text) && 
        (text.contains('आहे') || text.contains('काय') || text.contains('तुम्ही'))) {
      return "mr-IN"; // Marathi
    }
    
    // Tamil detection
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) {
      return "ta-IN"; // Tamil
    }
    
    // Telugu detection
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) {
      return "te-IN"; // Telugu
    }
    
    // Bengali detection
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
      return "bn-IN"; // Bengali
    }
    
    // Kannada detection
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) {
      return "kn-IN"; // Kannada
    }
    
    // Malayalam detection
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) {
      return "ml-IN"; // Malayalam
    }
    
    // Punjabi detection
    if (RegExp(r'[\u0A00-\u0A7F]').hasMatch(text)) {
      return "pa-IN"; // Punjabi
    }
    
    // Romanized Hindi/Gujarati detection (common words)
    final lowerText = text.toLowerCase();
    
    // Gujarati romanized keywords
    if (lowerText.contains('kem cho') || lowerText.contains('maja') || 
        lowerText.contains('tamari') || lowerText.contains('aaje') ||
        lowerText.contains('kevi') || lowerText.contains('chhe')) {
      return "gu-IN"; // Gujarati
    }
    
    // Hindi romanized keywords
    if (lowerText.contains('kaise') || lowerText.contains('kya') || 
        lowerText.contains('tumhara') || lowerText.contains('aaj') ||
        lowerText.contains('hai') || lowerText.contains('hoon') ||
        lowerText.contains('achha') || lowerText.contains('theek')) {
      return "hi-IN"; // Hindi
    }
    
    // Default to English
    return "en-US";
  }

  /// Check and request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        print('✅ Microphone permission granted');
        return true;
      } else if (status.isDenied) {
        print('❌ Microphone permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        print('❌ Microphone permission permanently denied');
        await openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Speak the given text using TTS with automatic language detection
  Future<void> speak(String text) async {
    try {
      // Remove emojis and special characters for cleaner speech
      final cleanText = _removeEmojis(text);
      
      // Detect language from text
      final detectedLanguage = _detectLanguage(cleanText);
      
      print('🌐 Detected language: $detectedLanguage for text: ${cleanText.substring(0, cleanText.length > 30 ? 30 : cleanText.length)}...');
      
      // Try to set the detected language
      try {
        // Set language if different from current
        if (detectedLanguage != _currentLanguage) {
          final result = await _flutterTts.setLanguage(detectedLanguage);
          
          if (result == 1) {
            _currentLanguage = detectedLanguage;
            print('✅ Language switched to: $detectedLanguage');
          } else {
            print('⚠️ Language $detectedLanguage not available on device');
            print('💡 Please install Google TTS language pack for $detectedLanguage');
            print('📱 Settings → System → Languages & input → Text-to-speech → Install voice data');
            
            // Fallback to English with Indian accent
            await _flutterTts.setLanguage("en-IN");
            _currentLanguage = "en-IN";
            print('🔄 Falling back to English (India)');
          }
        }
      } catch (e) {
        print('⚠️ Error setting language $detectedLanguage: $e');
        print('🔄 Using current language: $_currentLanguage');
      }
      
      // Speak the text
      await _flutterTts.speak(cleanText);
      print('🔊 Speaking in $_currentLanguage: ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...');
    } catch (e) {
      print('❌ Error speaking: $e');
    }
  }

  /// Remove emojis and special characters from text
  String _removeEmojis(String text) {
    // Remove all emojis using regex
    return text.replaceAll(RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F018}-\u{1F270}]|[\u{238C}-\u{2454}]|[\u{20D0}-\u{20FF}]',
      unicode: true,
    ), '').trim();
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      print('🔇 Stopped speaking');
    } catch (e) {
      print('❌ Error stopping speech: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      print('🔇 Voice service disposed');
    } catch (e) {
      print('❌ Error disposing voice service: $e');
    }
  }
  
  /// Get current language
  String get currentLanguage => _currentLanguage;
  
  /// Set language manually (optional)
  Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      _currentLanguage = languageCode;
      print('🌐 Language manually set to: $languageCode');
    } catch (e) {
      print('❌ Error setting language: $e');
    }
  }
}
