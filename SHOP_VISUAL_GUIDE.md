# 🛍️ Shop Feature - Quick Visual Guide

## 🎯 Overview

The shop feature adds a gamification layer where users can buy virtual gifts for Radhika and receive emotional reactions!

---

## 📱 User Interface Flow

### 1️⃣ **Accessing the Shop**

```
AI Call Screen
     │
     ├─→ Click 🛍️ icon (top-right)
     │
     └─→ Shop Screen Opens
```

### 2️⃣ **Shop Screen Layout**

```
┌─────────────────────────────────────────┐
│  Gift Shop              💰 1000 coins   │  ← Header
├─────────────────────────────────────────┤
│ [All][Clothing][Accessories][Food][Gifts]│  ← Category Tabs
├─────────────────────────────────────────┤
│  Radhika's Happiness: 😊 60/100        │  ← Happiness Meter
│  ████████████░░░░░░░░                   │
├─────────────────────────────────────────┤
│  💝 Radhika wants:                      │  ← Active Requests
│  • Summer Dress (Pink)                  │
│  • Ice Cream (Chocolate)                │
├─────────────────────────────────────────┤
│  ┌───────┐  ┌───────┐  ┌───────┐      │
│  │  👗   │  │  🧥   │  │  👟   │      │  ← Item Grid
│  │ Dress │  │Jacket │  │Sneakers│     │
│  │ 💰150 │  │ 💰300 │  │ 💰200 │      │
│  └───────┘  └───────┘  └───────┘      │
│                                         │
│  ┌───────┐  ┌───────┐  ┌───────┐      │
│  │  👜   │  │  🕶️   │  │  ⌚   │      │
│  │  Bag  │  │Glasses│  │ Watch │      │
│  │ 💰250 │  │ 💰100 │  │ 💰400 │      │
│  └───────┘  └───────┘  └───────┘      │
└─────────────────────────────────────────┘
              [My Inventory] 📦  ← FAB
```

### 3️⃣ **Purchase Dialog**

```
┌─────────────────────────────┐
│  👗  Summer Dress           │
├─────────────────────────────┤
│  Beautiful floral dress     │
│                             │
│  Select Color:              │
│  [Red] [Blue] [Pink] [White]│
│                             │
│  💰 150 coins               │
├─────────────────────────────┤
│  [Cancel]      [Buy Now]    │
└─────────────────────────────┘
```

### 4️⃣ **Inventory Sheet**

```
┌─────────────────────────────────────┐
│        My Inventory                 │
├─────────────────────────────────────┤
│  👗 Summer Dress                    │
│  Color: Pink                        │
│  [Gift 💝]                          │  ← Can gift
├─────────────────────────────────────┤
│  🧥 Leather Jacket                  │
│  Color: Black                       │
│  ✓ Gifted to Radhika                │  ← Already gifted
│  "OMG! Thank you so much! 😍💕"     │
└─────────────────────────────────────┘
```

### 5️⃣ **Gift Reaction Dialog**

```
┌─────────────────────────────┐
│  Radhika's Reaction         │
├─────────────────────────────┤
│         😍                  │  ← Emotion
│                             │
│  "OMG! Thank you so much!   │
│   I love it! 😍💕"          │  ← Message
│                             │
│      +20 Happiness          │  ← Points
├─────────────────────────────┤
│          [Okay]             │
└─────────────────────────────┘
```

---

## 🎮 User Journey Examples

### Journey 1: Happy Path ✅

```
1. User chats with Radhika
   └─→ "Hey, how are you?"
   
2. Radhika responds normally
   └─→ "I'm great! Thanks for asking!"
   
3. After 7 messages, Radhika makes request
   └─→ "I've been looking at this Summer Dress in Pink... 
        Would you get it for me? 🥺"
   
4. User opens shop
   └─→ Sees "Summer Dress" in active requests
   
5. User purchases Summer Dress (Pink)
   └─→ -150 coins
   └─→ Added to inventory
   
6. User opens inventory
   └─→ Clicks "Gift 💝" on Summer Dress
   
7. Radhika reacts happily
   └─→ "OMG! Thank you so much! I love it! 😍💕"
   └─→ +20 Happiness (now 70/100)
   └─→ Emotion changes to Happy 💕
```

### Journey 2: Drama Path 😅

```
1. Radhika requests item
   └─→ "I really want that Leather Jacket in Black!"
   
2. User buys wrong color
   └─→ Purchases Leather Jacket (Brown)
   
3. User gifts it
   └─→ Radhika reacts with drama
   └─→ "Hmm... I wanted it in Black, not Brown... 😕"
   └─→ +5 Happiness (only small increase)
   └─→ Stays in Neutral emotion
```

### Journey 3: Spontaneous Gift 🎁

```
1. User browses shop (no active requests)
   
2. User buys random item
   └─→ Purchases Chocolate Cake
   
3. User gifts it
   └─→ Radhika is surprised and happy
   └─→ "Aww, you got this for me! I love surprises! 💕"
   └─→ +20 Happiness
```

---

## 📊 Happiness System

### Happiness Levels

```
100 ┤ 😍 Very Happy
 80 ┤ ─────────────
    │ 😊 Happy
 60 ┤ ─────────────
    │ 😐 Neutral
 40 ┤ ─────────────
    │ 😔 Sad
 20 ┤ ─────────────
  0 ┤ 😢 Very Sad
```

### Happiness Gains

| Action | Happiness Gain |
|--------|----------------|
| Correct gift + color | +20 points |
| Correct gift, wrong color | +5 points |
| Spontaneous gift | +20 points |

---

## 🎨 Color Coding

### UI Elements

| Element | Color | Hex Code |
|---------|-------|----------|
| Background | Dark Navy | `#0F172A` |
| Cards | Slate | `#1E293B` |
| Primary Accent | Purple | `#8B5CF6` |
| Happy/Love | Pink | `#EC4899` |
| Success | Green | `#10B981` |
| Error | Red | `#EF4444` |

### Emotion Colors

| Emotion | Color | Hex Code |
|---------|-------|----------|
| Neutral | Purple | `#8B5CF6` |
| Happy | Pink | `#EC4899` |
| Thinking | Blue | `#3B82F6` |

---

## 🛍️ Shop Categories & Items

### Clothing (3 items)
```
👗 Summer Dress      - 150 coins - 5 colors
🧥 Leather Jacket    - 300 coins - 3 colors
👟 Sneakers          - 200 coins - 4 colors
```

### Accessories (4 items)
```
👜 Designer Handbag  - 250 coins - 4 colors
🕶️ Sunglasses        - 100 coins - 3 colors
⌚ Smart Watch       - 400 coins - 4 colors
💍 Diamond Ring      - 500 coins - 3 colors
```

### Food (3 items)
```
🍰 Chocolate Cake    - 50 coins  - 3 flavors
☕ Premium Coffee    - 30 coins  - 3 types
🍦 Ice Cream         - 40 coins  - 4 flavors
```

### Gifts (3 items)
```
💐 Rose Bouquet      - 80 coins  - 4 colors
💄 Luxury Perfume    - 350 coins - 4 scents
🧸 Teddy Bear        - 60 coins  - 3 colors
```

**Total: 13 items**

---

## 🎯 Request System

### Request Trigger Logic

```
Message Count:  1  2  3  4  5  6  7  8  9  10 11 12 13 14
Request Made:   -  -  -  -  -  -  ✓  -  -  -  -  -  -  ✓
```

**Pattern**: Every 7th message triggers a request

### Request Format

```
Template:
"[Intro phrase] [Item Name] in [Color]... [Request phrase]"

Examples:
• "I've been looking at this Summer Dress in Pink... 
   Would you get it for me? 🥺"
   
• "Hey! I really want that Leather Jacket in Black. 
   Can you buy it for me?"
   
• "I saw this amazing Ice Cream in Chocolate! 
   I'd love to have it! 💕"
```

---

## 💡 Pro Tips

### For Users
1. **Check Requests First** - Look at the banner before buying
2. **Color Matters** - Always match the requested color
3. **Budget Wisely** - Start with 1000 coins, spend carefully
4. **Spontaneous Gifts** - Random gifts also make her happy!
5. **Track Happiness** - Keep happiness above 60 for best reactions

### For Developers
1. **Add Test Coins**: `shopProvider.addCoins(500)`
2. **Force Request**: Modify message count in provider
3. **Debug Reactions**: Check console for reaction data
4. **Test Colors**: Try all color variants
5. **Reset State**: Restart app to reset happiness

---

## 🔧 Customization Quick Reference

### Change Request Frequency
```dart
// lib/utils/dummy_shop_data.dart
return messageCount % 7 == 0;  // Change 7 to adjust
```

### Modify Starting Coins
```dart
// lib/providers/shop_provider.dart
int _userCoins = 1000;  // Change amount
```

### Add New Item
```dart
// lib/utils/dummy_shop_data.dart
ShopItem(
  id: 'new_item',
  name: 'New Item',
  price: 100,
  category: 'clothing',
  emoji: '👔',
  colors: ['Red', 'Blue'],
)
```

### Add New Reaction
```dart
// lib/utils/dummy_shop_data.dart
final happyReactions = [
  "Your new reaction! 😊",
  // ... existing
];
```

---

## 🎬 Animation Timing

| Action | Duration | Effect |
|--------|----------|--------|
| Purchase | Instant | Snackbar notification |
| Gift | 500ms | Dialog fade-in |
| Happiness Update | 300ms | Progress bar animation |
| Emotion Change | 500ms | Avatar color transition |
| Request Appear | 1s | Slide down from top |

---

## 📱 Responsive Design

### Mobile (Portrait)
- 2-column grid for items
- Full-width inventory sheet
- Compact happiness meter

### Tablet (Landscape)
- 3-4 column grid for items
- Side panel for inventory
- Expanded happiness details

### Desktop (Web)
- 4-5 column grid for items
- Persistent sidebar
- Detailed statistics

---

## 🚀 Performance Notes

- **Lazy Loading**: Items loaded on demand
- **State Optimization**: Only rebuilds affected widgets
- **Memory Efficient**: Emoji instead of images
- **Fast Navigation**: No network calls (dummy data)

---

## ✅ Testing Checklist

- [ ] Browse all categories
- [ ] Purchase item with enough coins
- [ ] Try purchasing without enough coins
- [ ] Select different colors
- [ ] View inventory
- [ ] Gift item to Radhika
- [ ] Receive happy reaction
- [ ] Receive drama reaction
- [ ] Check happiness meter updates
- [ ] Verify request banner appears
- [ ] Test spontaneous gifts
- [ ] Check gifted item history

---

**Happy Shopping! 🛍️💕**
