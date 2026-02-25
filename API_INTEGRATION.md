# 🔌 API Integration Guide

This guide will help you integrate real APIs into Radhika AI to replace the dummy/static data.

## 📋 Table of Contents
1. [Speech-to-Text Integration](#speech-to-text)
2. [AI Response Integration](#ai-response)
3. [Text-to-Speech Integration](#text-to-speech)
4. [Authentication](#authentication)
5. [Error Handling](#error-handling)

---

## 🎤 Speech-to-Text Integration

### Option 1: Google Cloud Speech-to-Text

#### Step 1: Setup
```bash
flutter pub add speech_to_text
```

#### Step 2: Create Service
Create `lib/services/speech_to_text_service.dart`:
```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  
  static Future<bool> initialize() async {
    return await _speech.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }
  
  static Future<String> listen() async {
    String recognizedText = '';
    
    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
    
    // Wait for listening to complete
    await Future.delayed(const Duration(seconds: 6));
    
    return recognizedText;
  }
  
  static void stop() {
    _speech.stop();
  }
}
```

#### Step 3: Update Provider
In `lib/providers/ai_assistant_provider.dart`:
```dart
// Replace this line:
final voiceInput = await DummyAIService.simulateVoiceRecognition();

// With:
final voiceInput = await SpeechToTextService.listen();
```

### Option 2: Azure Speech Service

#### Step 1: Add Dependencies
```yaml
dependencies:
  azure_speech_recognition_null_safety: ^1.0.0
```

#### Step 2: Create Service
```dart
import 'package:azure_speech_recognition_null_safety/azure_speech_recognition_null_safety.dart';

class AzureSpeechService {
  static final AzureSpeechRecognition _speech = AzureSpeechRecognition();
  
  static Future<void> initialize() async {
    await _speech.initialize(
      subscriptionKey: 'YOUR_AZURE_KEY',
      region: 'YOUR_REGION',
      lang: 'en-US',
    );
  }
  
  static Future<String> recognize() async {
    final result = await _speech.recognizeOnce();
    return result?.recognizedText ?? '';
  }
}
```

---

## 🤖 AI Response Integration

### Option 1: OpenAI GPT-4

#### Step 1: Add Dependencies
```bash
flutter pub add http
flutter pub add dart_openai
```

#### Step 2: Create Service
Create `lib/services/openai_service.dart`:
```dart
import 'package:dart_openai/dart_openai.dart';
import '../models/message_model.dart';

class OpenAIService {
  static void initialize() {
    OpenAI.apiKey = 'YOUR_OPENAI_API_KEY';
  }
  
  static Future<MessageModel> getResponse(
    String userMessage,
    List<MessageModel> conversationHistory,
  ) async {
    try {
      // Build conversation context
      final messages = conversationHistory.map((msg) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: msg.isUser 
              ? OpenAIChatMessageRole.user 
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.text)
          ],
        );
      }).toList();
      
      // Add current message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage)
          ],
        ),
      );
      
      // Get response
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4',
        messages: messages,
        temperature: 0.7,
        maxTokens: 150,
      );
      
      final aiText = response.choices.first.message.content?.first.text ?? 
                     'Sorry, I could not generate a response.';
      
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('OpenAI Error: $e');
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }
}
```

#### Step 3: Update Provider
In `lib/providers/ai_assistant_provider.dart`:
```dart
// Initialize in constructor or init method
OpenAIService.initialize();

// Replace this:
final aiResponse = await DummyAIService.getAIResponse(text);

// With:
final aiResponse = await OpenAIService.getResponse(text, _messages);
```

### Option 2: Google Gemini

#### Step 1: Add Dependencies
```bash
flutter pub add google_generative_ai
```

#### Step 2: Create Service
Create `lib/services/gemini_service.dart`:
```dart
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message_model.dart';

class GeminiService {
  static late GenerativeModel _model;
  
  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'YOUR_GEMINI_API_KEY',
    );
  }
  
  static Future<MessageModel> getResponse(String userMessage) async {
    try {
      final content = [Content.text(userMessage)];
      final response = await _model.generateContent(content);
      
      final aiText = response.text ?? 'No response generated.';
      
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Gemini Error: $e');
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }
}
```

### Option 3: Anthropic Claude

#### Step 1: Create Service
Create `lib/services/claude_service.dart`:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message_model.dart';

class ClaudeService {
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  
  static Future<MessageModel> getResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-opus-20240229',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['content'][0]['text'];
        
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: aiText,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Claude Error: $e');
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }
}
```

---

## 🔊 Text-to-Speech Integration

### Option 1: Flutter TTS

#### Step 1: Add Dependencies
```bash
flutter pub add flutter_tts
```

#### Step 2: Create Service
Create `lib/services/tts_service.dart`:
```dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    _isInitialized = true;
  }
  
  static Future<void> speak(String text) async {
    await initialize();
    await _tts.speak(text);
  }
  
  static Future<void> stop() async {
    await _tts.stop();
  }
  
  static Future<bool> isSpeaking() async {
    final status = await _tts.awaitSpeakCompletion(true);
    return status;
  }
}
```

#### Step 3: Update Provider
In `lib/providers/ai_assistant_provider.dart`:
```dart
// After getting AI response, add:
await TTSService.speak(aiResponse.text);

// In speaking state:
_currentState = AIState.speaking;
notifyListeners();

// Speak the response
await TTSService.speak(aiResponse.text);

// Then return to idle
_currentState = AIState.idle;
```

### Option 2: Google Cloud TTS

#### Step 1: Add Dependencies
```bash
flutter pub add http
```

#### Step 2: Create Service
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class GoogleTTSService {
  static const String _apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
  static final AudioPlayer _player = AudioPlayer();
  
  static Future<void> speak(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'text': text},
          'voice': {
            'languageCode': 'en-US',
            'name': 'en-US-Neural2-F', // Female voice
            'ssmlGender': 'FEMALE',
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'pitch': 0,
            'speakingRate': 1.0,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['audioContent'];
        
        // Play audio
        final bytes = base64Decode(audioContent);
        await _player.play(BytesSource(bytes));
      }
    } catch (e) {
      print('TTS Error: $e');
    }
  }
}
```

---

## 🔐 Authentication

### Setup User Authentication

#### Step 1: Add Firebase
```bash
flutter pub add firebase_core
flutter pub add firebase_auth
```

#### Step 2: Create Auth Service
Create `lib/services/auth_service.dart`:
```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static User? get currentUser => _auth.currentUser;
  
  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Auth Error: $e');
      return null;
    }
  }
  
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

## ⚠️ Error Handling

### Create Error Handler
Create `lib/utils/error_handler.dart`:
```dart
import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('unauthorized')) {
      return 'Authentication error. Please log in again.';
    }
    return 'An unexpected error occurred.';
  }
}
```

### Update Provider with Error Handling
```dart
Future<void> sendTextMessage(String text) async {
  try {
    // Add user message
    _messages.add(MessageModel(...));
    notifyListeners();
    
    // Get AI response
    final aiResponse = await OpenAIService.getResponse(text, _messages);
    _messages.add(aiResponse);
    notifyListeners();
    
  } catch (e) {
    // Handle error
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Sorry, I encountered an error: ${ErrorHandler.getErrorMessage(e)}',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
```

---

## 🔑 Environment Variables

### Create Config File
Create `lib/config/api_config.dart`:
```dart
class APIConfig {
  // OpenAI
  static const String openAIKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_DEFAULT_KEY',
  );
  
  // Google Cloud
  static const String googleCloudKey = String.fromEnvironment(
    'GOOGLE_CLOUD_KEY',
    defaultValue: 'YOUR_DEFAULT_KEY',
  );
  
  // Azure
  static const String azureKey = String.fromEnvironment(
    'AZURE_KEY',
    defaultValue: 'YOUR_DEFAULT_KEY',
  );
  
  static const String azureRegion = 'eastus';
}
```

### Use in Services
```dart
class OpenAIService {
  static void initialize() {
    OpenAI.apiKey = APIConfig.openAIKey;
  }
}
```

### Run with Environment Variables
```bash
flutter run --dart-define=OPENAI_API_KEY=your_actual_key
```

---

## 📊 Rate Limiting

### Create Rate Limiter
Create `lib/utils/rate_limiter.dart`:
```dart
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final List<DateTime> _requests = [];
  
  RateLimiter({
    required this.maxRequests,
    required this.timeWindow,
  });
  
  bool canMakeRequest() {
    final now = DateTime.now();
    
    // Remove old requests
    _requests.removeWhere(
      (time) => now.difference(time) > timeWindow,
    );
    
    if (_requests.length < maxRequests) {
      _requests.add(now);
      return true;
    }
    
    return false;
  }
  
  Duration timeUntilNextRequest() {
    if (_requests.isEmpty) return Duration.zero;
    
    final oldestRequest = _requests.first;
    final timePassed = DateTime.now().difference(oldestRequest);
    final timeRemaining = timeWindow - timePassed;
    
    return timeRemaining.isNegative ? Duration.zero : timeRemaining;
  }
}
```

### Use in Service
```dart
class OpenAIService {
  static final _rateLimiter = RateLimiter(
    maxRequests: 10,
    timeWindow: const Duration(minutes: 1),
  );
  
  static Future<MessageModel> getResponse(String message) async {
    if (!_rateLimiter.canMakeRequest()) {
      final waitTime = _rateLimiter.timeUntilNextRequest();
      throw Exception('Rate limit exceeded. Try again in ${waitTime.inSeconds}s');
    }
    
    // Make API call
    // ...
  }
}
```

---

## ✅ Testing API Integration

### Create Test File
Create `test/services/openai_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/services/openai_service.dart';

void main() {
  group('OpenAI Service Tests', () {
    setUpAll(() {
      OpenAIService.initialize();
    });
    
    test('Should return valid response', () async {
      final response = await OpenAIService.getResponse(
        'Hello',
        [],
      );
      
      expect(response.text, isNotEmpty);
      expect(response.isUser, false);
    });
    
    test('Should handle errors gracefully', () async {
      // Test with invalid input
      final response = await OpenAIService.getResponse(
        '',
        [],
      );
      
      expect(response.text, contains('error'));
    });
  });
}
```

---

## 🚀 Deployment Checklist

- [ ] Remove all hardcoded API keys
- [ ] Use environment variables
- [ ] Implement proper error handling
- [ ] Add rate limiting
- [ ] Test all API integrations
- [ ] Add loading indicators
- [ ] Implement retry logic
- [ ] Add offline mode
- [ ] Test on real devices
- [ ] Monitor API usage and costs

---

## 📚 Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text)
- [Azure Cognitive Services](https://azure.microsoft.com/en-us/services/cognitive-services/)
- [Flutter TTS Package](https://pub.dev/packages/flutter_tts)

---

**Your app is now ready for production with real AI! 🎉**
