# How to Test Custom AI Name Feature

## 🧪 Testing Steps

### **Step 1: Clear Previous Data**
To ensure a fresh test, clear the app data:

**Option A: Uninstall and Reinstall**
```bash
flutter clean
flutter run
```

**Option B: Clear SharedPreferences (if you have access to device)**
- Go to device Settings → Apps → AI Assistant → Storage → Clear Data

---

### **Step 2: Run the App with Debug Logs**
```bash
flutter run
```

Watch the console output for debug messages:
- `✅ DEBUG: Saved custom AI name: [YourName]`
- `🔍 DEBUG: Loaded AI name from SharedPreferences: [YourName]`

---

### **Step 3: Complete Onboarding**

1. **Select Gender:**
   - Choose Male or Female
   - Click Continue

2. **Enter Custom Name:**
   - Type your custom name (e.g., "Maya", "Alex", "Sam")
   - Make sure it's 2-20 characters, letters only
   - Click Continue

3. **Check Console Output:**
   Look for these debug messages:
   ```
   ✅ DEBUG: Saved custom AI name: Maya
   ✅ DEBUG: Verification - Reading back: Maya
   ```

4. **Check Home Screen:**
   - Should show: "Maya AI" (or whatever name you entered)
   - NOT "Radhika" or "Arjun"

---

### **Step 4: Verify Throughout App**

Navigate through the app and verify your custom name appears:

| Screen | Location | Expected |
|--------|----------|----------|
| Home | Title | "[Your Name] AI" |
| Chat | Header | "Chat with [Your Name]" |
| Call | Title | "[Your Name] AI" |
| Call | End Dialog | "...with [Your Name]?" |
| Shop | Happiness Bar | "[Your Name]'s Happiness" |
| Shop | Requests | "[Your Name] wants:" |
| Shop | Empty Inventory | "Buy gifts for [Your Name]" |
| Shop | Gifted Label | "✓ Gifted to [Your Name]" |
| Shop | Reaction Dialog | "[Your Name]'s Reaction" |

---

## 🐛 Troubleshooting

### **Problem: Still showing "Arjun" or "Radhika"**

**Cause 1: Old cached data**
```bash
# Solution: Clear app data
flutter clean
flutter run
```

**Cause 2: SharedPreferences not cleared**
- Uninstall the app completely
- Reinstall using `flutter run`

**Cause 3: Hot reload issue**
- Stop the app completely (Ctrl+C)
- Run again: `flutter run`
- Don't use hot reload during onboarding

---

### **Problem: Name not saving**

**Check console for errors:**
```
✅ DEBUG: Saved custom AI name: [Name]
✅ DEBUG: Verification - Reading back: [Name]
```

If you don't see these messages:
1. Check if name validation is passing
2. Ensure name is 2-20 characters
3. Ensure name contains only letters and spaces

---

### **Problem: Name loads as null**

**Check console on app start:**
```
🔍 DEBUG: Loaded AI name from SharedPreferences: [Name]
🔍 DEBUG: AI gender: [Gender]
```

If it shows `null` or default name:
1. Onboarding might not have completed
2. SharedPreferences might not have saved
3. Try completing onboarding again

---

## 📝 Debug Checklist

Run through this checklist:

- [ ] App is completely uninstalled before testing
- [ ] `flutter clean` executed
- [ ] `flutter run` executed (not hot reload)
- [ ] Gender selected during onboarding
- [ ] Custom name entered (2-20 characters, letters only)
- [ ] Continue button clicked
- [ ] Console shows: `✅ DEBUG: Saved custom AI name: [Name]`
- [ ] Console shows: `🔍 DEBUG: Loaded AI name from SharedPreferences: [Name]`
- [ ] Home screen shows custom name
- [ ] Chat header shows custom name
- [ ] Shop shows custom name

---

## 🔍 Manual Verification Commands

### **Check what's saved in SharedPreferences:**

Add this temporary debug code to `main.dart` in the `_checkOnboardingStatus()` method:

```dart
Future<void> _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  
  // DEBUG: Print all saved values
  print('🔍 DEBUG - All SharedPreferences:');
  print('  - has_completed_onboarding: ${prefs.getBool('has_completed_onboarding')}');
  print('  - ai_gender: ${prefs.getString('ai_gender')}');
  print('  - ai_custom_name: ${prefs.getString('ai_custom_name')}');
  print('  - user_gender: ${prefs.getString('user_gender')}');
  
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
  // ... rest of code
}
```

This will show you exactly what's saved.

---

## ✅ Expected Console Output

When everything works correctly, you should see:

```
🔍 DEBUG: Loaded AI name from SharedPreferences: Maya
🔍 DEBUG: AI gender: female
✅ DEBUG: Saved custom AI name: Maya
✅ DEBUG: Verification - Reading back: Maya
🔍 DEBUG - All SharedPreferences:
  - has_completed_onboarding: true
  - ai_gender: female
  - ai_custom_name: Maya
  - user_gender: female
```

---

## 🚀 Quick Test Script

Run this complete test:

```bash
# 1. Clean everything
flutter clean

# 2. Run app
flutter run

# 3. In the app:
#    - Select gender: Female
#    - Enter name: Maya
#    - Click Continue

# 4. Check console output for debug messages

# 5. Navigate through app and verify "Maya" appears everywhere
```

---

## 📞 If Still Not Working

If after following all steps above, you still see "Arjun" or "Radhika":

1. **Share console output** - Copy all debug messages
2. **Share screenshot** - Show what name appears on home screen
3. **Confirm steps** - Which gender did you select? What name did you enter?

The debug logs will help identify exactly where the issue is occurring.
