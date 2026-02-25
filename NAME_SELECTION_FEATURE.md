# AI Name Selection Feature

## Overview
After selecting their gender, users can now choose a custom name for their AI assistant from a curated list of 8 names per gender.

## User Flow

### 1. Gender Selection
- User selects their gender (Male/Female)
- System determines AI gender (opposite of user's gender)
- Gender preferences saved to SharedPreferences
- User navigates to Name Selection screen

### 2. Name Selection
- User sees 8 predefined names based on AI gender
- Names displayed in a 2-column grid layout
- Visual feedback on selection (purple gradient)
- Confirmation message shows selected name
- Name saved to SharedPreferences
- Onboarding marked as complete
- User navigates to Home screen

## Available Names

### Female AI Names (for Male users)
1. **Radhika** (Default)
2. Priya
3. Ananya
4. Ishita
5. Meera
6. Kavya
7. Diya
8. Aisha

### Male AI Names (for Female users)
1. **Arjun** (Default)
2. Rohan
3. Aditya
4. Karan
5. Vihaan
6. Aryan
7. Reyansh
8. Aarav

## Technical Implementation

### New Files Created

#### 1. `lib/screens/name_selection_screen.dart` (338 lines)
**Purpose:** Allows users to select AI assistant's name from predefined list

**Key Features:**
- Receives `userGender` and `aiGender` as route arguments
- Displays 8 names in 2-column grid layout
- Animated selection feedback with purple gradient
- Back button to return to gender selection
- Saves selected name to SharedPreferences
- Marks onboarding as complete

**Key Components:**
- `NameSelectionScreen` - Main stateful widget
- `_NameCard` - Reusable name selection card widget

**State Management:**
```dart
String? _selectedName;  // Currently selected name
bool _isLoading;        // Loading state during save
```

**Methods:**
- `_availableNames` - Returns list of names based on AI gender
- `_saveNameAndContinue()` - Saves name and navigates to home

### Modified Files

#### 2. `lib/screens/gender_selection_screen.dart`
**Changes:**
- Removed onboarding completion flag from gender selection
- Updated navigation to go to name selection instead of home
- Passes `userGender` and `aiGender` as route arguments

**Before:**
```dart
await prefs.setBool('has_completed_onboarding', true);
Navigator.of(context).pushReplacementNamed('/home');
```

**After:**
```dart
Navigator.of(context).pushReplacementNamed(
  '/name-selection',
  arguments: {
    'userGender': _selectedGender!,
    'aiGender': aiGender,
  },
);
```

#### 3. `lib/main.dart`
**Changes:**
- Added import for `name_selection_screen.dart`
- Added `onGenerateRoute` to handle name selection route with arguments

**New Route Handler:**
```dart
onGenerateRoute: (settings) {
  if (settings.name == '/name-selection') {
    final args = settings.arguments as Map<String, String>;
    return MaterialPageRoute(
      builder: (context) => NameSelectionScreen(
        userGender: args['userGender']!,
        aiGender: args['aiGender']!,
      ),
    );
  }
  return null;
},
```

#### 4. `lib/providers/ai_assistant_provider.dart`
**Changes:**
- Updated `initialize()` method to load custom name from SharedPreferences
- Falls back to default name based on gender if no custom name is set

**Before:**
```dart
_aiName = _aiGender == 'female' ? 'Radhika' : 'Arjun';
```

**After:**
```dart
_aiName = prefs.getString('ai_name') ?? (_aiGender == 'female' ? 'Radhika' : 'Arjun');
```

## Data Persistence

### SharedPreferences Keys
| Key | Type | Description | Set By |
|-----|------|-------------|--------|
| `user_gender` | String | User's selected gender | Gender Selection Screen |
| `ai_gender` | String | AI's assigned gender | Gender Selection Screen |
| `ai_name` | String | AI's custom name | Name Selection Screen |
| `has_completed_onboarding` | bool | Onboarding completion flag | Name Selection Screen |

## UI/UX Design

### Name Selection Screen Layout
```
┌─────────────────────────────────┐
│  ← Back                         │
│                                 │
│         [AI Icon]               │
│                                 │
│      Choose a Name              │
│  What would you like to call    │
│    your female AI assistant?    │
│                                 │
│  ┌──────────┐  ┌──────────┐   │
│  │ Radhika  │  │  Priya   │   │
│  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐   │
│  │ Ananya   │  │ Ishita   │   │
│  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐   │
│  │  Meera   │  │  Kavya   │   │
│  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐   │
│  │   Diya   │  │  Aisha   │   │
│  └──────────┘  └──────────┘   │
│                                 │
│  ℹ️ Your AI assistant will be   │
│     called "Radhika"            │
│                                 │
│     [Continue Button]           │
└─────────────────────────────────┘
```

### Visual Design
- **Background:** Dark gradient (0xFF0F172A → 0xFF1E293B)
- **Selected Card:** Purple gradient (0xFF8B5CF6 → 0xFF6366F1)
- **Unselected Card:** Dark slate (0xFF1E293B)
- **Accent Color:** Purple (0xFF8B5CF6)
- **Typography:** Google Fonts (Poppins for headings, Inter for body)

### Animations
- Card selection: 200ms animated container transition
- Gradient and shadow appear on selection
- Info banner slides in when name is selected

## Complete Onboarding Flow

```
App Launch
    ↓
Check Onboarding Status
    ↓
┌───────────────────────────────┐
│ Has Completed Onboarding?     │
└───────────────────────────────┘
    ↓                    ↓
   NO                   YES
    ↓                    ↓
Gender Selection    Home Screen
    ↓
Save Gender
    ↓
Name Selection
    ↓
Save Name + Complete Onboarding
    ↓
Home Screen
```

## Testing Checklist

### Functional Testing
- [ ] Gender selection navigates to name selection
- [ ] Correct names displayed based on AI gender
- [ ] Name selection updates UI with gradient
- [ ] Info banner shows selected name
- [ ] Continue button disabled when no selection
- [ ] Back button returns to gender selection
- [ ] Name saved to SharedPreferences
- [ ] Onboarding flag set correctly
- [ ] Home screen displays custom AI name
- [ ] AI messages use custom name

### Edge Cases
- [ ] Rapid tapping on name cards
- [ ] Back button during save operation
- [ ] App restart after name selection
- [ ] Missing SharedPreferences data
- [ ] Invalid route arguments

### UI/UX Testing
- [ ] All names visible without scrolling
- [ ] Cards properly sized on different screens
- [ ] Selection animation smooth
- [ ] Text readable on all backgrounds
- [ ] Button states clear (enabled/disabled)
- [ ] Loading indicator appears during save

## Future Enhancements

### Possible Additions
1. **Custom Name Input**
   - Add text field for users to enter their own name
   - Validate input (length, characters)
   - Option to choose from list or enter custom

2. **Name Categories**
   - Traditional names
   - Modern names
   - International names
   - Nickname options

3. **Name Previews**
   - Show example phrases with selected name
   - Voice preview of AI saying the name
   - Personality hints for each name

4. **Avatar Selection**
   - Choose AI appearance alongside name
   - Different styles/themes per name
   - Customizable color schemes

5. **Name Change Feature**
   - Allow users to change name later
   - Settings screen option
   - Confirmation dialog

## Code Examples

### Getting AI Name in Any Screen
```dart
// Using Provider
final aiProvider = Provider.of<AIAssistantProvider>(context);
final aiName = aiProvider.aiName;

// Display
Text('Chat with $aiName');
```

### Checking Onboarding Status
```dart
final prefs = await SharedPreferences.getInstance();
final hasCompleted = prefs.getBool('has_completed_onboarding') ?? false;
final aiName = prefs.getString('ai_name') ?? 'Radhika';
```

### Adding New Names
```dart
// In name_selection_screen.dart
List<String> get _availableNames {
  if (widget.aiGender == 'female') {
    return [
      'Radhika',
      'Priya',
      'Ananya',
      'Ishita',
      'Meera',
      'Kavya',
      'Diya',
      'Aisha',
      // Add new names here
    ];
  } else {
    return [
      'Arjun',
      'Rohan',
      'Aditya',
      'Karan',
      'Vihaan',
      'Aryan',
      'Reyansh',
      'Aarav',
      // Add new names here
    ];
  }
}
```

## Troubleshooting

### Issue: Name not persisting after restart
**Solution:** Check SharedPreferences initialization in AI provider

### Issue: Wrong names displayed
**Solution:** Verify `aiGender` is correctly passed from gender selection

### Issue: Navigation error
**Solution:** Ensure route arguments are properly cast in `onGenerateRoute`

### Issue: Name not showing in chat
**Solution:** Verify AI provider's `initialize()` method is called

## Performance Considerations

- Name list is computed on-demand (getter)
- SharedPreferences accessed only during save/load
- Minimal state management (only selected name)
- Efficient grid layout with fixed aspect ratio
- No heavy animations or computations

## Accessibility

- Large tap targets (cards are 2.5 aspect ratio)
- Clear visual feedback on selection
- Readable text sizes (18sp for names)
- High contrast colors
- Back button for navigation flexibility

---

## Summary

The name selection feature provides users with a personalized onboarding experience by allowing them to choose their AI assistant's name from a curated list. The implementation is clean, efficient, and follows Flutter best practices with proper state management and data persistence.

**Key Benefits:**
✅ Personalized user experience
✅ Simple, intuitive UI
✅ Proper data persistence
✅ Seamless integration with existing flow
✅ Easily extensible for future features

**Files Modified:** 4
**New Files:** 1
**Total Lines Added:** ~350
**Dependencies:** None (uses existing packages)
