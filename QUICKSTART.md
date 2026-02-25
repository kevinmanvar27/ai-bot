# 🚀 Quick Start Guide - Radhika AI

## ⚡ 5-Minute Setup

### Step 1: Verify Flutter Installation
```bash
flutter doctor
```
Make sure you have Flutter 3.0+ installed.

### Step 2: Get Dependencies
```bash
cd ai_assistant
flutter pub get
```

### Step 3: Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 🎮 How to Use the App

### Home Screen
1. Launch the app
2. You'll see the Radhika AI landing page
3. Tap **"Start Conversation"** button

### AI Call Screen

#### Voice Interaction
1. Tap the **large purple mic button** in the center
2. Watch the status change:
   - "Listening..." (2 seconds)
   - "Thinking..." (2 seconds)
   - "Speaking..." (3 seconds)
3. See the animated sound waves during speaking
4. Avatar color changes based on emotion

#### Chat Interaction
1. Tap the **chat bubble icon** at the bottom
2. Type your message in the text field
3. Tap the **send button** (purple gradient)
4. AI responds after 1.5 seconds
5. Scroll through chat history

#### Other Controls
- **Camera icon**: Toggle camera on/off (visual feedback)
- **Red phone icon**: End session (confirmation dialog)
- **Settings icon**: Coming soon notification

## 🎨 Understanding the UI

### Avatar States
- **Purple glow**: Neutral/Idle state
- **Pink glow**: Happy emotion
- **Blue glow**: Thinking state

### Status Indicators
- **"Hi! I'm Radhika"**: Idle state
- **"Listening..."**: Capturing voice input
- **"Thinking..."**: Processing your request
- **"Speaking..."**: AI is responding

### Animations
- **Breathing**: Subtle scale animation (always active)
- **Blinking**: Random blinks every 3-6 seconds
- **Glow pulse**: Continuous glow animation
- **Sound waves**: Active during speaking state

## 📱 Testing Different Scenarios

### Test Voice Interaction
1. Press mic button
2. Wait for full cycle (7 seconds total)
3. New message appears in chat
4. Try multiple times to see different responses

### Test Chat
1. Open chat sheet
2. Send: "Hello"
3. Wait for AI response
4. Send: "Tell me more"
5. See different random responses

### Test Emotions
- Send multiple messages
- Watch avatar color change
- Each response may have different emotion

## 🔧 Customization Guide

### Change Colors

**In `lib/providers/ai_assistant_provider.dart`:**
```dart
Color get emotionColor {
  switch (_currentEmotion) {
    case AIEmotion.neutral:
      return const Color(0xFFYOURCOLOR); // Change here
    // ... other emotions
  }
}
```

### Add More Dummy Responses

**In `lib/utils/dummy_ai_service.dart`:**
```dart
static final List<String> _dummyResponses = [
  "Your new response here",
  "Another response",
  // Add as many as you want
];
```

### Adjust Animation Speed

**In `lib/widgets/avatar_widget.dart`:**
```dart
_breathingController = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 3), // Change duration
)..repeat(reverse: true);
```

### Change Timing Delays

**In `lib/providers/ai_assistant_provider.dart`:**
```dart
// Listening duration
await Future.delayed(const Duration(seconds: 2)); // Modify here

// Thinking duration
await Future.delayed(const Duration(seconds: 2)); // Modify here

// Speaking duration
await Future.delayed(const Duration(seconds: 3)); // Modify here
```

## 🐛 Troubleshooting

### Issue: Packages not found
```bash
flutter clean
flutter pub get
```

### Issue: Build errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Issue: Hot reload not working
- Press `R` in terminal for hot reload
- Press `Shift + R` for hot restart
- Or restart the app completely

### Issue: Fonts not loading
- Make sure internet is connected (Google Fonts downloads on first use)
- Fonts are cached after first download

### Issue: Animations laggy
- Test on physical device (emulators can be slow)
- Close other apps to free up resources

## 📝 Code Structure Overview

### Main Entry Point
`lib/main.dart` - App initialization and home screen

### Screens
`lib/screens/ai_call_screen.dart` - Main AI interaction screen

### Widgets (Reusable Components)
- `avatar_widget.dart` - Animated 3D avatar
- `control_panel.dart` - Bottom controls
- `chat_sheet.dart` - Chat interface
- `animated_wave.dart` - Sound wave animation

### State Management
`lib/providers/ai_assistant_provider.dart` - All app state and logic

### Data Models
`lib/models/message_model.dart` - Message structure

### Services
`lib/utils/dummy_ai_service.dart` - Simulated AI responses

## 🔌 Next Steps: API Integration

### 1. Add API Service File
Create `lib/services/api_service.dart`:
```dart
class APIService {
  static const String baseUrl = 'YOUR_API_URL';
  
  static Future<String> getAIResponse(String message) async {
    // Your API call here
  }
}
```

### 2. Replace Dummy Service
In `lib/providers/ai_assistant_provider.dart`:
```dart
// Replace this:
final aiResponse = await DummyAIService.getAIResponse(text);

// With this:
final aiResponse = await APIService.getAIResponse(text);
```

### 3. Add API Keys
Create `lib/config/api_keys.dart`:
```dart
class APIKeys {
  static const String openAI = 'YOUR_KEY';
  static const String speechToText = 'YOUR_KEY';
}
```

## 🎯 Performance Tips

1. **Use Release Mode for Testing**
   ```bash
   flutter run --release
   ```

2. **Profile Performance**
   ```bash
   flutter run --profile
   ```

3. **Analyze Code**
   ```bash
   flutter analyze
   ```

## 📚 Learn More

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Google Fonts](https://pub.dev/packages/google_fonts)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)

## 💡 Tips & Tricks

1. **Hot Reload**: Press `r` in terminal after code changes
2. **Hot Restart**: Press `R` for full restart
3. **DevTools**: Press `d` to open Flutter DevTools
4. **Quit**: Press `q` to stop the app

## 🎉 You're Ready!

Your Radhika AI app is now running! Explore all features and start customizing.

For questions or issues, check the main README.md or open an issue on GitHub.

---

**Happy Coding! 🚀**
