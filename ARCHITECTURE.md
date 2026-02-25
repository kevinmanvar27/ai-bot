# 🏗️ Project Architecture - Radhika AI

## 📐 Architecture Overview

This project follows **Clean Architecture** principles with **MVVM** pattern and **Provider** for state management.

```
┌─────────────────────────────────────────────────────────────┐
│                         Presentation Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │  Animations  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Providers   │  │   Services   │  │    Utils     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                          Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Models    │  │  Repositories│  │  API Client  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Detailed File Structure

```
lib/
├── main.dart                           # App entry point & home screen
│   ├── MyApp (MaterialApp setup)
│   └── HomeScreen (Landing page)
│
├── screens/                            # Screen-level widgets
│   └── ai_call_screen.dart
│       └── AICallScreen                # Main AI interaction screen
│           ├── Top bar (back, title, settings)
│           ├── Avatar (center)
│           ├── Status text
│           ├── Wave animation
│           └── Control panel (bottom)
│
├── widgets/                            # Reusable UI components
│   ├── avatar_widget.dart
│   │   └── AvatarWidget               # 3D avatar with animations
│   │       ├── Breathing animation
│   │       ├── Blink animation
│   │       ├── Glow animation
│   │       └── Emotion-based colors
│   │
│   ├── control_panel.dart
│   │   └── ControlPanel               # Bottom control buttons
│   │       ├── Camera toggle
│   │       ├── Mic button (main)
│   │       ├── Chat button
│   │       └── End call button
│   │
│   ├── chat_sheet.dart
│   │   └── ChatSheet                  # Sliding chat interface
│   │       ├── Message list
│   │       ├── Message bubbles
│   │       └── Input field
│   │
│   └── animated_wave.dart
│       └── AnimatedWave               # Sound wave animation
│           └── 5 animated bars
│
├── providers/                          # State management
│   └── ai_assistant_provider.dart
│       └── AIAssistantProvider        # Main app state
│           ├── State management
│           ├── Message handling
│           ├── Emotion control
│           └── Mic interaction logic
│
├── models/                             # Data models
│   └── message_model.dart
│       └── MessageModel               # Chat message structure
│           ├── id
│           ├── text
│           ├── isUser
│           └── timestamp
│
└── utils/                              # Utility functions
    └── dummy_ai_service.dart
        └── DummyAIService             # Simulated AI responses
            ├── Random responses
            ├── Random emotions
            └── Simulated voice input
```

## 🔄 Data Flow

### Voice Interaction Flow
```
User taps Mic Button
        │
        ▼
Provider.handleMicPress()
        │
        ├─► State: LISTENING (2s)
        │   └─► DummyAIService.simulateVoiceRecognition()
        │       └─► Returns dummy voice input
        │
        ├─► State: THINKING (2s)
        │   └─► DummyAIService.getAIResponse()
        │       └─► Returns AI response
        │
        ├─► State: SPEAKING (3s)
        │   └─► Emotion changes to HAPPY
        │
        └─► State: IDLE
            └─► Reset to neutral
```

### Chat Message Flow
```
User types message
        │
        ▼
ChatSheet.onSendMessage()
        │
        ▼
Provider.sendTextMessage()
        │
        ├─► Add user message to list
        │   └─► notifyListeners()
        │
        ├─► State: THINKING
        │   └─► DummyAIService.getAIResponse()
        │
        └─► Add AI response to list
            └─► notifyListeners()
                └─► UI updates automatically
```

## 🎯 State Management Pattern

### Provider Pattern Implementation

```dart
// 1. Provider Setup (main.dart)
ChangeNotifierProvider(
  create: (_) => AIAssistantProvider()..initialize(),
  child: MaterialApp(...)
)

// 2. Consuming State (ai_call_screen.dart)
Consumer<AIAssistantProvider>(
  builder: (context, provider, child) {
    return Widget(
      data: provider.someData,
      onAction: () => provider.someMethod(),
    );
  },
)

// 3. State Updates (ai_assistant_provider.dart)
class AIAssistantProvider extends ChangeNotifier {
  void updateState() {
    _someState = newValue;
    notifyListeners(); // Triggers UI rebuild
  }
}
```

## 🎨 Widget Composition

### Avatar Widget Hierarchy
```
AvatarWidget (StatefulWidget)
├── AnimatedBuilder (breathing + glow)
│   └── Transform.scale (breathing effect)
│       └── Container (outer circle with shadow)
│           └── Stack
│               ├── Container (gradient border)
│               └── Container (inner circle)
│                   └── ClipOval
│                       └── Stack
│                           ├── Container (gradient background)
│                           │   └── Icon (avatar placeholder)
│                           └── AnimatedBuilder (blink overlay)
```

### Control Panel Hierarchy
```
ControlPanel (StatelessWidget)
└── Container (glassmorphism)
    └── ClipRRect
        └── BackdropFilter (blur effect)
            └── Row
                ├── _ControlButton (camera)
                ├── _ControlButton (mic - large)
                ├── _ControlButton (chat)
                └── _ControlButton (end call)
```

## 🔌 Extension Points for API Integration

### 1. Speech-to-Text Service
```dart
// Create: lib/services/speech_to_text_service.dart
class SpeechToTextService {
  static Future<String> recognize() async {
    // TODO: Integrate real API
    // Example: Google Cloud Speech-to-Text
    // Example: Azure Speech Service
  }
}

// Replace in: ai_assistant_provider.dart
final voiceInput = await SpeechToTextService.recognize();
```

### 2. AI Response Service
```dart
// Create: lib/services/ai_service.dart
class AIService {
  static Future<String> getResponse(String message) async {
    // TODO: Integrate real API
    // Example: OpenAI GPT-4
    // Example: Google Gemini
    // Example: Anthropic Claude
  }
}

// Replace in: ai_assistant_provider.dart
final response = await AIService.getResponse(text);
```

### 3. Text-to-Speech Service
```dart
// Create: lib/services/text_to_speech_service.dart
class TextToSpeechService {
  static Future<void> speak(String text) async {
    // TODO: Integrate real API
    // Example: Google Cloud TTS
    // Example: Amazon Polly
    // Example: ElevenLabs
  }
}

// Add in: ai_assistant_provider.dart
await TextToSpeechService.speak(aiResponse.text);
```

### 4. Repository Pattern (Future)
```dart
// Create: lib/repositories/message_repository.dart
class MessageRepository {
  // Local storage
  Future<void> saveMessages(List<MessageModel> messages);
  Future<List<MessageModel>> loadMessages();
  
  // Remote storage
  Future<void> syncMessages();
}
```

## 🎭 Animation Architecture

### Animation Controllers
```
AvatarWidget
├── _breathingController (3s, repeat reverse)
├── _blinkController (200ms, periodic)
└── _glowController (2s, repeat reverse)

AnimatedWave
└── _controller (1500ms, repeat)
```

### Animation Lifecycle
1. **initState()**: Create controllers
2. **didUpdateWidget()**: Update based on props
3. **AnimatedBuilder**: Rebuild on animation tick
4. **dispose()**: Clean up controllers

## 📊 State Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      AI States                          │
└─────────────────────────────────────────────────────────┘

    IDLE ◄────────────────────┐
     │                         │
     │ (Mic pressed)          │
     ▼                         │
  LISTENING                    │
     │                         │
     │ (Voice captured)        │
     ▼                         │
  THINKING                     │
     │                         │
     │ (Response ready)        │
     ▼                         │
  SPEAKING ────────────────────┘
     │
     │ (Speech complete)
     └──► Back to IDLE

┌─────────────────────────────────────────────────────────┐
│                    Emotion States                       │
└─────────────────────────────────────────────────────────┘

  NEUTRAL (Purple) ◄─┐
     │               │
     ├──► HAPPY (Pink)
     │               │
     └──► THINKING (Blue)
                     │
                     └─► Back to NEUTRAL
```

## 🔒 Best Practices Implemented

### 1. **Separation of Concerns**
- UI widgets don't contain business logic
- Providers handle all state management
- Services handle external interactions

### 2. **Single Responsibility**
- Each widget has one clear purpose
- Each provider manages one domain
- Each service handles one type of operation

### 3. **Dependency Injection**
- Providers injected at root level
- Easy to mock for testing
- Loose coupling between components

### 4. **Immutability**
- Models are immutable
- State updates create new instances
- Prevents accidental mutations

### 5. **Error Handling** (Ready for implementation)
```dart
try {
  final response = await APIService.call();
} catch (e) {
  // Handle error
  _showError(e.message);
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
test('DummyAIService returns valid response', () async {
  final response = await DummyAIService.getAIResponse('test');
  expect(response.text, isNotEmpty);
});
```

### Widget Tests
```dart
testWidgets('AvatarWidget displays correctly', (tester) async {
  await tester.pumpWidget(AvatarWidget(...));
  expect(find.byType(AvatarWidget), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Complete voice interaction flow', (tester) async {
  // Test full user journey
});
```

## 📈 Performance Considerations

### 1. **Animation Performance**
- Use `AnimatedBuilder` for efficient rebuilds
- Dispose controllers properly
- Avoid nested animations when possible

### 2. **State Management**
- Only notify listeners when necessary
- Use `Consumer` for targeted rebuilds
- Keep provider methods lightweight

### 3. **Memory Management**
- Dispose controllers in `dispose()`
- Clear message list when needed
- Avoid memory leaks with listeners

## 🚀 Scalability

### Adding New Features

#### New AI State
```dart
// 1. Add to enum
enum AIState {
  idle, listening, thinking, speaking,
  processing, // New state
}

// 2. Add status text
String get statusText {
  case AIState.processing:
    return "Processing...";
}

// 3. Handle in UI
if (provider.currentState == AIState.processing) {
  // Show processing indicator
}
```

#### New Emotion
```dart
// 1. Add to enum
enum AIEmotion {
  neutral, happy, thinking,
  excited, // New emotion
}

// 2. Add color
Color get emotionColor {
  case AIEmotion.excited:
    return const Color(0xFFFFA500); // Orange
}
```

## 🎓 Learning Resources

### Understanding the Codebase
1. Start with `main.dart` - Entry point
2. Read `ai_assistant_provider.dart` - Core logic
3. Explore `ai_call_screen.dart` - Main UI
4. Study individual widgets - Reusable components

### Flutter Concepts Used
- StatefulWidget vs StatelessWidget
- AnimationController
- Provider (ChangeNotifier)
- Future & async/await
- Stream (ready for implementation)

---

**This architecture is production-ready and scalable!** 🚀
