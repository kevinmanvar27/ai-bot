# Gender Selection Feature

## Overview
The app now asks new users for their gender during onboarding. Based on the user's selection:
- **Male user** → AI will be **Female** (named "Radhika")
- **Female user** → AI will be **Male** (named "Arjun")

## Implementation Details

### 1. **Gender Selection Screen** (`lib/screens/gender_selection_screen.dart`)
- Beautiful onboarding screen with two gender options (Male/Female)
- Visual feedback showing which AI gender will be assigned
- Saves user preferences using SharedPreferences
- Marks onboarding as complete

### 2. **Updated AI Provider** (`lib/providers/ai_assistant_provider.dart`)
- Added `_aiGender` and `_aiName` properties
- Loads gender configuration from SharedPreferences on initialization
- Dynamically sets AI name:
  - Female AI: "Radhika"
  - Male AI: "Arjun"
- Updates welcome message and status text with dynamic AI name

### 3. **Updated Main App** (`lib/main.dart`)
- Added `InitialScreen` that checks onboarding status
- Routes:
  - `/gender-selection` - Gender selection screen for new users
  - `/home` - Main home screen for returning users
- Home screen now displays dynamic AI name based on user's selection

### 4. **Dependencies**
- Added `shared_preferences: ^2.2.2` for persistent storage

## User Flow

### First-Time User:
1. App launches → Shows loading screen
2. Checks if user has completed onboarding
3. No onboarding found → Navigates to Gender Selection Screen
4. User selects their gender
5. App saves:
   - User's gender
   - AI's gender (opposite of user's)
   - Onboarding completion flag
6. Navigates to Home Screen with personalized AI

### Returning User:
1. App launches → Shows loading screen
2. Checks if user has completed onboarding
3. Onboarding found → Directly navigates to Home Screen
4. AI name and gender loaded from saved preferences

## Data Storage
Using SharedPreferences to store:
- `user_gender`: 'male' or 'female'
- `ai_gender`: 'female' or 'male' (opposite of user)
- `has_completed_onboarding`: true/false
- `ai_name`: 'Radhika' or 'Arjun' (derived from ai_gender)

## Future Enhancements
- Add more AI personality options
- Allow users to change AI gender in settings
- Add voice customization based on gender
- Support for non-binary options
- Custom AI name selection
