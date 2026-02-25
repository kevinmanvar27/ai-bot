# 🏗️ Technical Architecture - Voice Call System

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                          │
│  (ai_call_screen.dart + ai_assistant_provider.dart)        │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              Platform Channel Bridge                         │
│     MethodChannel: "com.rektech.ai_assistant/speech"       │
└───────┬─────────────────────────────────────────────────────┘
        │
        ├─────────────────┬─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐  ┌──────────────┐  ┌─────────────┐
│ Native Android│  │  Gemini AI   │  │ Flutter TTS │
│ SpeechRecognizer│  │   Service    │  │   Service   │
└───────────────┘  └──────────────┘  └─────────────┘
```

---

## Component Breakdown

### 1. Native Android Layer (`MainActivity.java`)

**Location:** `android/app/src/main/java/com/rektech/ai_assistant/MainActivity.java`

**Purpose:** Background speech recognition without dialog popup

**Key Components:**

```java
private SpeechRecognizer speechRecognizer;
private Intent recognizerIntent;
private MethodChannel speechChannel;
```

**Method Channel Setup:**
```java
speechChannel = new MethodChannel(
    flutterEngine.getDartExecutor().getBinaryMessenger(),
    "com.rektech.ai_assistant/speech"
);
```

**Methods Exposed to Flutter:**

1. **`startListening`**
   - Checks microphone permission
   - Initializes SpeechRecognizer
   - Configures RecognizerIntent with:
     - `LANGUAGE_MODEL_FREE_FORM`
     - `PARTIAL_RESULTS = true`
     - `MAX_RESULTS = 1`
     - Language: English (en-US)
   - Starts recognition in background (no UI)

2. **`stopListening`**
   - Stops active recognition
   - Cleans up resources

3. **`checkPermission`**
   - Verifies RECORD_AUDIO permission
   - Returns boolean to Flutter

4. **`requestPermission`**
   - Requests microphone permission
   - Returns result to Flutter

**Recognition Callbacks:**

```java
onPartialResults(Bundle partialResults)
    ↓
Captures intermediate text
    ↓
Sends to Flutter via "onSpeechPartial"

onResults(Bundle results)
    ↓
Gets final recognized text
    ↓
Sends to Flutter via "onSpeechResult"

onError(int error)
    ↓
Handles errors gracefully
    ↓
Sends error to Flutter via "onSpeechError"
```

**Timeout Mechanism:**
- 10-second timer starts with recognition
- Auto-stops if no final result
- Uses partial results as fallback

---

### 2. Flutter Provider Layer (`ai_assistant_provider.dart`)

**Location:** `lib/providers/ai_assistant_provider.dart`

**Purpose:** State management and voice flow orchestration

**State Machine:**

```dart
enum AssistantState {
  idle,      // Ready for input
  listening, // Capturing speech
  thinking,  // Processing with AI
  speaking   // Playing TTS response
}
```

**Platform Channel Communication:**

```dart
static const platform = MethodChannel('com.rektech.ai_assistant/speech');

// Outgoing calls to native
await platform.invokeMethod('startListening');
await platform.invokeMethod('stopListening');

// Incoming events from native
platform.setMethodCallHandler((call) async {
  switch (call.method) {
    case 'onSpeechResult':
      _handleSpeechResult(call.arguments);
    case 'onSpeechPartial':
      _handlePartialResult(call.arguments);
    case 'onSpeechError':
      _handleSpeechError(call.arguments);
  }
});
```

**Voice Flow Method:**

```dart
Future<void> handleMicPress() async {
  // 1. Start Listening
  state = AssistantState.listening;
  await platform.invokeMethod('startListening');
  
  // 2. Wait for speech result (handled by callback)
  
  // 3. Process with AI
  state = AssistantState.thinking;
  String response = await _geminiService.sendMessage(userText);
  
  // 4. Speak response
  state = AssistantState.speaking;
  await _voiceService.speak(response);
  
  // 5. Return to idle
  state = AssistantState.idle;
}
```

---

### 3. Gemini AI Service (`gemini_ai_service.dart`)

**Location:** `lib/services/gemini_ai_service.dart`

**Purpose:** Natural language processing with voice optimization

**Voice-Specific Prompt:**

```dart
final voiceSystemPrompt = '''
You are Vuby, a friendly AI assistant in a voice call.

VOICE CONVERSATION RULES:
- Keep responses SHORT (1-2 sentences maximum)
- Be casual and conversational like talking to a friend
- NO EMOJIS - they sound weird when spoken
- Use simple, everyday language
- Show personality but stay concise
- Respond naturally like a human would speak

Remember: This is a VOICE conversation, not text chat!
''';
```

**AI Configuration:**

```dart
final model = GenerativeModel(
  model: 'gemini-2.0-flash-exp',
  apiKey: _apiKey,
  generationConfig: GenerationConfig(
    temperature: 1.2,        // More creative/natural
    maxOutputTokens: 150,    // Short responses
    topP: 0.95,              // Diverse vocabulary
    topK: 40,                // Balanced variety
  ),
);
```

**Emoji Removal:**

```dart
String _cleanResponseForVoice(String response) {
  // Remove all Unicode emojis
  response = response.replaceAll(
    RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true),
    ''
  );
  
  // Remove common emoji patterns
  response = response.replaceAll(RegExp(r'[😀-🙏🌀-🗿🚀-🛿]'), '');
  
  // Clean up extra spaces
  response = response.replaceAll(RegExp(r'\s+'), ' ').trim();
  
  return response;
}
```

---

### 4. Voice Service (`voice_service.dart`)

**Location:** `lib/services/voice_service.dart`

**Purpose:** Text-to-speech output

**TTS Configuration:**

```dart
final FlutterTts flutterTts = FlutterTts();

await flutterTts.setLanguage("en-US");
await flutterTts.setSpeechRate(0.5);    // Moderate speed
await flutterTts.setVolume(1.0);        // Full volume
await flutterTts.setPitch(1.0);         // Normal pitch

// iOS-specific settings
if (Platform.isIOS) {
  await flutterTts.setSharedInstance(true);
  await flutterTts.setIosAudioCategory(
    IosTextToSpeechAudioCategory.playback,
    [IosTextToSpeechAudioCategoryOptions.allowBluetooth]
  );
}
```

**Speak Method:**

```dart
Future<void> speak(String text) async {
  // Clean text before speaking
  String cleanText = _removeEmojis(text);
  
  // Speak with await for completion
  await flutterTts.speak(cleanText);
  
  // Wait for completion callback
  flutterTts.setCompletionHandler(() {
    _onComplete?.call();
  });
}
```

---

## Data Flow Diagram

### Complete Voice Interaction Flow:

```
1. USER TAPS MIC
   ↓
2. FLUTTER: handleMicPress() called
   ↓
3. FLUTTER → NATIVE: platform.invokeMethod('startListening')
   ↓
4. NATIVE: SpeechRecognizer.startListening()
   ↓
5. USER SPEAKS
   ↓
6. NATIVE: onPartialResults() → "onSpeechPartial" → FLUTTER
   (Real-time feedback)
   ↓
7. NATIVE: onResults() → "onSpeechResult" → FLUTTER
   ↓
8. FLUTTER: _handleSpeechResult(text)
   ↓
9. FLUTTER: state = thinking
   ↓
10. FLUTTER → GEMINI API: sendMessage(text)
    ↓
11. GEMINI: Process with voice-optimized prompt
    ↓
12. GEMINI → FLUTTER: Return short response
    ↓
13. FLUTTER: _cleanResponseForVoice() removes emojis
    ↓
14. FLUTTER: state = speaking
    ↓
15. FLUTTER → TTS: voiceService.speak(cleanResponse)
    ↓
16. TTS: Speaks the response
    ↓
17. TTS: onComplete callback
    ↓
18. FLUTTER: state = idle
    ↓
19. READY FOR NEXT INTERACTION
```

---

## Error Handling

### Native Layer Errors:

```java
onError(int error) {
  String errorMessage;
  switch (error) {
    case SpeechRecognizer.ERROR_NO_MATCH:
      errorMessage = "No speech detected";
      break;
    case SpeechRecognizer.ERROR_NETWORK:
      errorMessage = "Network error";
      break;
    case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS:
      errorMessage = "Microphone permission required";
      break;
    default:
      errorMessage = "Recognition error: " + error;
  }
  
  // Send to Flutter
  speechChannel.invokeMethod("onSpeechError", errorMessage);
}
```

### Flutter Layer Handling:

```dart
void _handleSpeechError(String error) {
  print('Speech error: $error');
  
  // Show user-friendly message
  if (error.contains("permission")) {
    _showPermissionDialog();
  } else if (error.contains("No speech")) {
    _showMessage("Please speak louder");
  }
  
  // Reset to idle
  state = AssistantState.idle;
  notifyListeners();
}
```

---

## Performance Optimizations

### 1. **Lazy Initialization**
```dart
// Only initialize when needed
Future<void> _initializeServices() async {
  if (!_initialized) {
    await _voiceService.initialize();
    await _geminiService.initialize();
    _initialized = true;
  }
}
```

### 2. **Resource Cleanup**
```dart
@override
void dispose() {
  speechRecognizer?.destroy();
  flutterTts.stop();
  super.dispose();
}
```

### 3. **Debouncing**
```dart
Timer? _debounceTimer;

void _onPartialResult(String text) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    // Update UI with partial text
    notifyListeners();
  });
}
```

### 4. **Caching**
```dart
// Cache Gemini model instance
static GenerativeModel? _cachedModel;

GenerativeModel _getModel() {
  _cachedModel ??= GenerativeModel(...);
  return _cachedModel!;
}
```

---

## Security Considerations

### 1. **API Key Protection**
```dart
// Store in environment variables (not in code)
const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

// Or use flutter_dotenv
await dotenv.load(fileName: ".env");
final apiKey = dotenv.env['GEMINI_API_KEY'];
```

### 2. **Permission Handling**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

```dart
// Runtime permission check
if (!await platform.invokeMethod('checkPermission')) {
  await platform.invokeMethod('requestPermission');
}
```

### 3. **Rate Limiting**
```dart
// Prevent API abuse
DateTime? _lastRequest;
const minRequestInterval = Duration(seconds: 2);

Future<String> sendMessage(String text) async {
  if (_lastRequest != null) {
    final elapsed = DateTime.now().difference(_lastRequest!);
    if (elapsed < minRequestInterval) {
      await Future.delayed(minRequestInterval - elapsed);
    }
  }
  
  _lastRequest = DateTime.now();
  return await _sendToGemini(text);
}
```

---

## Testing Strategy

### Unit Tests:
```dart
test('Voice service removes emojis', () {
  final service = VoiceService();
  final input = 'Hello 😊 World 🌍!';
  final output = service.cleanText(input);
  expect(output, 'Hello  World !');
});
```

### Integration Tests:
```dart
testWidgets('Voice call flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap mic button
  await tester.tap(find.byIcon(Icons.mic));
  await tester.pump();
  
  // Verify listening state
  expect(find.text('Listening...'), findsOneWidget);
});
```

### Manual Testing Checklist:
- [ ] Mic button triggers listening
- [ ] No dialog popup appears
- [ ] Partial results show in real-time
- [ ] Final text sent to Gemini
- [ ] Response is short and natural
- [ ] No emojis in spoken output
- [ ] TTS completes successfully
- [ ] State returns to idle

---

## Dependencies

```yaml
dependencies:
  flutter_tts: ^4.2.5           # Text-to-speech
  google_generative_ai: ^0.4.6  # Gemini AI
  provider: ^6.1.2              # State management
  
dev_dependencies:
  flutter_test:
  mockito: ^5.4.4               # Mocking for tests
```

---

## Build Configuration

### Android (`build.gradle`):
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### Permissions (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

---

## Future Enhancements

1. **Wake Word Detection** - "Hey Vuby"
2. **Conversation Context** - Remember previous exchanges
3. **Multi-language** - Hindi, Gujarati support
4. **Offline Mode** - Local speech recognition
5. **Voice Cloning** - Custom TTS voices
6. **Emotion Detection** - Analyze tone
7. **Background Mode** - Continue conversation when app minimized

---

## Troubleshooting

### Issue: SpeechRecognizer returns empty results
**Solution:** Use partial results as fallback with 10-second timeout

### Issue: TTS sounds robotic
**Solution:** Adjust speech rate (0.4-0.6), use Google TTS engine

### Issue: Gemini responses too long
**Solution:** Reduce maxOutputTokens, enforce in system prompt

### Issue: Permission denied
**Solution:** Check AndroidManifest.xml, request at runtime

---

## References

- [Android SpeechRecognizer Docs](https://developer.android.com/reference/android/speech/SpeechRecognizer)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter TTS Package](https://pub.dev/packages/flutter_tts)

---

**Last Updated:** February 25, 2026  
**Version:** 1.0  
**Status:** Production Ready ✅
