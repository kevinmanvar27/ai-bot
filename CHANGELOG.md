# 📝 Changelog

All notable changes to the Radhika AI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-24

### 🎯 Name Selection Feature

#### ✨ Added
- **AI Name Selection Screen**
  - New onboarding step after gender selection
  - 8 predefined names per gender (Female: Radhika, Priya, Ananya, Ishita, Meera, Kavya, Diya, Aisha)
  - 8 predefined names per gender (Male: Arjun, Rohan, Aditya, Karan, Vihaan, Aryan, Reyansh, Aarav)
  - Beautiful 2-column grid layout with selection animations
  - Purple gradient on selected name cards
  - Confirmation banner showing selected name
  - Back button to return to gender selection

- **Personalization**
  - Custom AI name persists throughout the app
  - AI name appears in home screen title
  - AI name used in welcome messages
  - AI name used in all conversations
  - AI name stored in SharedPreferences

#### 🔄 Changed
- Gender selection now navigates to name selection (not directly to home)
- Onboarding completion flag moved to name selection screen
- AI provider loads custom name from SharedPreferences
- Updated onboarding flow: Gender → Name → Home

#### 📁 New Files
- `lib/screens/name_selection_screen.dart` - Name selection UI (338 lines)
- `NAME_SELECTION_FEATURE.md` - Technical documentation (370 lines)
- `NAME_SELECTION_VISUAL_GUIDE.md` - User guide with visuals (407 lines)

#### 🔧 Modified Files
- `lib/screens/gender_selection_screen.dart` - Updated navigation flow
- `lib/main.dart` - Added name selection route with arguments
- `lib/providers/ai_assistant_provider.dart` - Load custom AI name

---

## [1.1.0] - 2026-02-23

### 🎁 Shop Feature Release

#### ✨ Added
- **Virtual Gift Shop**
  - Complete shop screen with category tabs
  - 13 items across 4 categories (Clothing, Accessories, Food, Gifts)
  - Item cards with emoji, name, description, and price
  - Color variant selection for each item
  - Coin-based currency system (starting with 1000 coins)
  - Purchase confirmation dialogs

- **Gift Request System**
  - Radhika randomly requests items during conversations (~every 7 messages)
  - Preferred color specification in requests
  - Active requests banner in shop screen
  - Request tracking and fulfillment system

- **Happiness System**
  - Happiness meter (0-100) displayed in shop
  - Visual happiness status (Very Happy, Happy, Neutral, Sad, Very Sad)
  - Happiness increases based on gifts
  - Different happiness gains for correct/wrong colors

- **Inventory Management**
  - User inventory with purchased items
  - Gifted vs. ungifted item tracking
  - Gift history with Radhika's reactions
  - Color information for each purchase

- **Emotional Reactions**
  - Happy reactions for correct gifts/colors (+20 happiness)
  - Drama reactions for wrong colors (+5 happiness)
  - Multiple reaction variations for variety
  - Reactions displayed in chat and saved to items

- **Shop Integration**
  - Shopping bag icon in AI call screen
  - Seamless navigation between chat and shop
  - Multi-provider setup (AIAssistantProvider + ShopProvider)
  - Gift reactions added to chat messages

#### 📝 New Files
- `lib/models/shop_item_model.dart` - Shop item, purchase, and request models
- `lib/providers/shop_provider.dart` - Shop state management
- `lib/screens/shop_screen.dart` - Complete shop UI
- `lib/utils/dummy_shop_data.dart` - Static shop data and reactions
- `SHOP_FEATURE.md` - Comprehensive shop documentation

#### 🔄 Modified
- `lib/main.dart` - Added MultiProvider with ShopProvider
- `lib/providers/ai_assistant_provider.dart` - Added gift request logic
- `lib/screens/ai_call_screen.dart` - Added shop navigation button
- `README.md` - Updated with shop feature information

#### 🎨 UI Improvements
- Happiness meter with gradient progress bar
- Active requests banner with pink accent
- Inventory modal bottom sheet
- Gift reaction dialog with emoji
- Category-based tab navigation
- Glassmorphism effects in shop UI

---

## [1.0.0] - 2024-02-23

### 🎉 Initial Release

#### ✨ Added
- **Complete UI/UX Implementation**
  - Dark modern theme with glassmorphism effects
  - Video-call style layout
  - Premium AI assistant design
  - Futuristic yet clean interface

- **Home Screen**
  - Beautiful landing page with gradient background
  - Feature highlights with icons
  - Animated start button with glow effect
  - Version information display

- **AI Call Screen**
  - Full-screen video call style layout
  - Top navigation bar (back, title, settings)
  - Large circular 3D avatar in center
  - Status text display (Listening, Thinking, Speaking)
  - Animated sound waves during speech
  - Bottom control panel with glassmorphism

- **3D Avatar Widget**
  - Animated gradient borders
  - Breathing animation (subtle scale effect)
  - Blinking animation (periodic, random timing)
  - Glowing effect with pulse animation
  - Emotion-based color changes
  - Smooth transitions between states

- **Control Panel**
  - Large circular mic button (center)
  - Camera toggle button
  - Chat button (opens bottom sheet)
  - End call button (red, with confirmation)
  - Glassmorphism background with blur
  - Active state indicators

- **Chat Interface**
  - Sliding bottom sheet (70% screen height)
  - Message bubbles (user on right, AI on left)
  - Avatar icons for each message type
  - Timestamp for each message
  - Auto-scroll to latest message
  - Text input field with send button
  - Gradient send button with glow effect

- **Animations**
  - Breathing animation on avatar (3s cycle)
  - Random blinking (every 3-6 seconds)
  - Glow pulse animation (2s cycle)
  - Sound wave animation (5 bars, sine wave)
  - Smooth state transitions
  - Button press feedback

- **State Management**
  - Provider pattern implementation
  - Four AI states: Idle, Listening, Thinking, Speaking
  - Three emotions: Neutral (purple), Happy (pink), Thinking (blue)
  - Mic active/inactive state
  - Camera on/off state
  - Message history management

- **Dummy AI Service**
  - 10 pre-defined responses
  - Random response selection
  - Simulated voice recognition
  - Random emotion generation
  - Realistic timing delays

- **Voice Interaction Flow**
  - Tap mic → Listening (2s)
  - Voice captured → Thinking (2s)
  - Response ready → Speaking (3s)
  - Complete → Return to Idle
  - Visual feedback at each stage

- **Chat Functionality**
  - Send text messages
  - Receive AI responses (1.5s delay)
  - Message history persistence (session-based)
  - Smooth scrolling
  - Message timestamps

- **Models**
  - MessageModel with id, text, isUser, timestamp
  - JSON serialization support
  - Immutable data structure

- **Architecture**
  - Clean separation of concerns
  - MVVM pattern
  - Service layer for AI logic
  - Reusable widget components
  - Scalable folder structure

#### 📚 Documentation
- Comprehensive README.md
- ARCHITECTURE.md with detailed structure
- QUICKSTART.md for easy setup
- API_INTEGRATION.md for production APIs
- Inline code comments
- TODO markers for future API integration

#### 🎨 Design System
- Consistent color palette
- Google Fonts (Poppins, Inter)
- Reusable component library
- Responsive layouts
- Dark theme throughout

#### 🔧 Configuration
- pubspec.yaml with all dependencies
- Asset folder structure
- Environment ready for API keys
- Clean project structure

#### 📦 Dependencies
- `provider: ^6.1.1` - State management
- `google_fonts: ^6.1.0` - Typography
- `flutter_animate: ^4.3.0` - Animation utilities
- `intl: ^0.18.1` - Date formatting
- `sliding_up_panel: ^2.0.0+1` - Chat sheet

#### ✅ Features Ready for Production
- All UI components production-ready
- Smooth animations and transitions
- Error handling structure in place
- Scalable architecture
- Clean code with comments
- Ready for API integration

### 🎯 Future Enhancements (Planned)

#### [2.0.0] - Planned
- Real API integration (OpenAI, Google, Azure)
- Voice recognition (Speech-to-Text)
- Text-to-speech output
- User authentication
- Conversation history persistence
- Settings screen
- Multiple AI personalities
- Custom avatar selection

#### [2.1.0] - Planned
- Multi-language support
- Advanced emotion detection
- Context-aware responses
- Conversation analytics
- Export chat history
- Dark/Light theme toggle

#### [3.0.0] - Planned
- Smart home integration
- Calendar and reminder integration
- Weather and news updates
- Voice commands
- Offline mode
- Cloud sync

### 🐛 Known Issues
- None (initial release)

### 🔒 Security
- No sensitive data stored
- Ready for secure API key management
- Environment variable support prepared

### 📱 Platform Support
- ✅ Android (tested)
- ✅ iOS (tested)
- ⚠️ Web (needs testing)
- ⚠️ Desktop (experimental)

### 🧪 Testing
- Manual testing completed
- Unit test structure ready
- Widget test structure ready
- Integration test structure ready

---

## Version History

### [1.0.0] - 2024-02-23
- Initial production-ready release
- Complete UI/UX implementation
- Dummy AI service with static responses
- Full animation system
- Chat functionality
- State management with Provider

---

## How to Update

### From Source
```bash
git pull origin main
flutter pub get
flutter run
```

### Check for Updates
```bash
git fetch
git log HEAD..origin/main --oneline
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

---

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Email: support@radhika-ai.com
- Documentation: See README.md and other docs

---

**Last Updated**: February 23, 2024
**Current Version**: 1.0.0
**Status**: Production Ready ✅
