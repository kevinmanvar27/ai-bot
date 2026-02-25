# Shop Feature Documentation

## Overview

The **Shop Feature** allows users to buy virtual gifts for Radhika AI. Radhika can request items during conversations, and users can purchase and gift them to her. She will react emotionally based on whether you got the right item and color!

---

## Features

### 1. **Virtual Shop**
- Browse items across multiple categories:
  - **Clothing**: Dresses, jackets, shoes
  - **Accessories**: Handbags, sunglasses, watches, rings
  - **Food & Treats**: Cakes, coffee, ice cream
  - **Gifts**: Flowers, perfume, teddy bears

### 2. **Currency System**
- Users start with **1000 coins**
- Items range from 30 to 500 coins
- Coins are displayed in the top-right corner of the shop

### 3. **Gift Requests**
- Radhika randomly requests items during conversations (every ~7 messages)
- She may specify a preferred color
- Active requests are shown in a banner at the top of the shop

### 4. **Happiness System**
- Radhika has a happiness meter (0-100)
- Starts at 50 happiness
- Giving gifts increases happiness:
  - **Correct color**: +20 happiness
  - **Wrong color**: +5 happiness (with drama!)
- Happiness affects Radhika's mood and reactions

### 5. **Color Variants**
- Most items have multiple color options
- Users choose the color when purchasing
- Radhika reacts differently based on color match

### 6. **Inventory System**
- View all purchased items
- Track gifted vs. ungifted items
- See Radhika's reactions to past gifts

---

## User Flow

### Purchasing Items

1. **Open Shop**
   - Click the shopping bag icon (🛍️) in the top-right of the AI call screen
   
2. **Browse Items**
   - Use tabs to filter by category (All, Clothing, Accessories, Food, Gifts)
   - View item details: name, description, price, emoji
   
3. **Buy Item**
   - Click on an item card
   - Select a color variant (if available)
   - Click "Buy Now"
   - Item is added to your inventory

### Gifting Items

1. **Open Inventory**
   - Click "My Inventory" button (bottom-right of shop)
   
2. **Select Item**
   - View all purchased items
   - Ungifted items show a "Gift 💝" button
   
3. **Gift to Radhika**
   - Click "Gift 💝" button
   - Radhika reacts immediately with a message
   - Her happiness level updates
   - Reaction is saved to the item

### Radhika's Requests

1. **During Conversation**
   - Radhika randomly requests items while chatting
   - Example: "I've been looking at this Summer Dress in Pink... Would you get it for me? 🥺"
   
2. **Request Tracking**
   - Requests appear in the shop's banner
   - Shows item name and preferred color
   
3. **Fulfilling Requests**
   - Purchase the requested item
   - Gift it to Radhika
   - She'll be extra happy if you got the right color!

---

## Radhika's Reactions

### Happy Reactions (Correct Gift/Color)
- "OMG! Thank you so much! I love it! 😍💕"
- "This is perfect! You're the best! 🥰"
- "Aww, you remembered! I'm so happy! 💖"
- **Happiness Gain**: +20 points

### Drama Reactions (Wrong Color)
- "Hmm... I wanted it in Red, not Blue... 😕"
- "Oh... it's nice but... I prefer Pink color... 🥺"
- "You got Black? But I said White... 😔"
- **Happiness Gain**: +5 points

---

## Technical Implementation

### File Structure

```
lib/
├── models/
│   └── shop_item_model.dart        # ShopItem, PurchasedItem, GiftRequest models
├── providers/
│   ├── shop_provider.dart          # Shop state management
│   └── ai_assistant_provider.dart  # Updated with gift request logic
├── screens/
│   └── shop_screen.dart            # Main shop UI
└── utils/
    └── dummy_shop_data.dart        # Static shop data and reactions
```

### Key Classes

#### **ShopItem**
```dart
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String emoji;
  final List<String> colors;
}
```

#### **PurchasedItem**
```dart
class PurchasedItem {
  final String id;
  final ShopItem item;
  final String selectedColor;
  final DateTime purchaseDate;
  bool isGifted;
  String? radhikaReaction;
}
```

#### **GiftRequest**
```dart
class GiftRequest {
  final String id;
  final ShopItem requestedItem;
  final String? preferredColor;
  final String requestMessage;
  final DateTime requestDate;
  bool isFulfilled;
}
```

### State Management

#### **ShopProvider**
Manages:
- User's coin balance
- Inventory of purchased items
- Active gift requests
- Happiness level

Key Methods:
- `purchaseItem(item, color)` - Buy an item
- `giftItemToRadhika(purchasedItem)` - Give gift and get reaction
- `addGiftRequest(request)` - Add new request from Radhika
- `canAfford(price)` - Check if user has enough coins

#### **AIAssistantProvider** (Updated)
New functionality:
- `sendTextMessage()` now accepts `onGiftRequest` callback
- Automatically triggers gift requests every ~7 messages
- `addReactionMessage()` adds Radhika's gift reactions to chat

---

## Integration Points

### 1. **Chat Integration**
```dart
aiProvider.sendTextMessage(
  text,
  onGiftRequest: (request) {
    shopProvider.addGiftRequest(request);
  },
);
```

### 2. **Navigation**
- Shop accessible via shopping bag icon in AI call screen
- Returns to call screen after purchases

### 3. **Multi-Provider Setup**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AIAssistantProvider()),
    ChangeNotifierProvider(create: (_) => ShopProvider()),
  ],
  child: MaterialApp(...),
)
```

---

## Customization Guide

### Adding New Items

Edit `lib/utils/dummy_shop_data.dart`:

```dart
ShopItem(
  id: 'your_item_id',
  name: 'Item Name',
  description: 'Item description',
  price: 100,
  category: 'clothing', // or 'accessories', 'food', 'gifts'
  imageUrl: '',
  emoji: '👗', // Choose an emoji
  colors: ['Red', 'Blue', 'Green'], // Available colors
),
```

### Adjusting Request Frequency

Edit `lib/utils/dummy_shop_data.dart`:

```dart
static bool shouldMakeRequest(int messageCount) {
  // Change the number to adjust frequency
  return messageCount % 7 == 0 && messageCount > 0;
  // Lower number = more frequent requests
}
```

### Modifying Starting Coins

Edit `lib/providers/shop_provider.dart`:

```dart
int _userCoins = 1000; // Change this value
```

### Adding New Reactions

Edit `lib/utils/dummy_shop_data.dart`:

Add to `getReactionToGift()` method:

```dart
final happyReactions = [
  "Your new reaction here! 😊",
  // ... existing reactions
];
```

---

## UI Components

### Shop Screen Layout

```
┌─────────────────────────────────┐
│  Gift Shop        💰 1000       │ ← Header with coins
├─────────────────────────────────┤
│ All | Clothing | Accessories... │ ← Category tabs
├─────────────────────────────────┤
│  Radhika's Happiness: 😊 60/100 │ ← Happiness meter
├─────────────────────────────────┤
│  💝 Radhika wants:              │ ← Active requests
│  • Summer Dress (Pink)          │
├─────────────────────────────────┤
│  ┌─────┐  ┌─────┐              │
│  │ 👗  │  │ 🧥  │              │ ← Item grid
│  │Dress│  │Jacket│             │
│  │💰150│  │💰300│              │
│  └─────┘  └─────┘              │
└─────────────────────────────────┘
         [My Inventory] ← FAB
```

### Inventory Sheet

```
┌─────────────────────────────────┐
│         My Inventory            │
├─────────────────────────────────┤
│  👗 Summer Dress                │
│  Color: Pink                    │
│  [Gift 💝]                      │ ← Ungifted
├─────────────────────────────────┤
│  🧥 Leather Jacket              │
│  Color: Black                   │
│  ✓ Gifted to Radhika            │ ← Gifted
│  "OMG! Thank you so much! 😍"   │
└─────────────────────────────────┘
```

---

## Testing Scenarios

### Scenario 1: Happy Path
1. Start app with 1000 coins
2. Chat with Radhika until she requests an item
3. Go to shop and purchase the exact item and color
4. Open inventory and gift it
5. **Expected**: Happy reaction, +20 happiness

### Scenario 2: Wrong Color Drama
1. Radhika requests "Summer Dress in Pink"
2. Purchase "Summer Dress in Blue"
3. Gift it to her
4. **Expected**: Drama reaction, +5 happiness

### Scenario 3: Spontaneous Gift
1. Purchase any item without a request
2. Gift it to Radhika
3. **Expected**: Happy reaction (no color preference)

### Scenario 4: Insufficient Funds
1. Spend coins until balance < item price
2. Try to purchase expensive item
3. **Expected**: "Not enough coins!" error

---

## Future Enhancements

### Planned Features
- [ ] Daily coin rewards
- [ ] Mini-games to earn coins
- [ ] Item rarity system (common, rare, legendary)
- [ ] Radhika's wardrobe (see her wearing gifted items)
- [ ] Achievement system
- [ ] Gift wrapping options
- [ ] Special occasion items (birthday, holidays)
- [ ] Item bundles and discounts

### API Integration Ready
The shop system is designed to easily integrate with a backend:

1. **Replace static data** with API calls in `dummy_shop_data.dart`
2. **Sync purchases** to user account
3. **Real-time coin balance** from server
4. **Cloud-saved inventory**
5. **Dynamic item catalog** from database

---

## Troubleshooting

### Issue: Radhika not making requests
- **Solution**: Keep chatting! Requests happen every ~7 messages

### Issue: Can't afford items
- **Solution**: Use `shopProvider.addCoins(500)` for testing
- Or adjust starting coins in `shop_provider.dart`

### Issue: Inventory not showing
- **Solution**: Make sure you've purchased items first

### Issue: Gift button not appearing
- **Solution**: Check if item is already gifted (shows ✓)

---

## Code Examples

### Manually Trigger Gift Request (Testing)

```dart
final shopProvider = Provider.of<ShopProvider>(context, listen: false);
final item = DummyShopData.getRandomRequestItem();
final request = GiftRequest(
  id: DateTime.now().toString(),
  requestedItem: item,
  preferredColor: item.colors.first,
  requestMessage: "Please get this for me!",
  requestDate: DateTime.now(),
);
shopProvider.addGiftRequest(request);
```

### Add Test Coins

```dart
final shopProvider = Provider.of<ShopProvider>(context, listen: false);
shopProvider.addCoins(500); // Add 500 coins
```

### Check Happiness Level

```dart
final shopProvider = Provider.of<ShopProvider>(context, listen: false);
print('Happiness: ${shopProvider.happinessLevel}');
print('Status: ${shopProvider.happinessStatus}');
```

---

## Summary

The shop feature adds a gamification layer to the AI assistant, making interactions more engaging and fun. Users can:

✅ Browse and purchase virtual gifts  
✅ Respond to Radhika's requests  
✅ Manage their inventory  
✅ Track Radhika's happiness  
✅ Experience emotional reactions  

The system is fully functional with dummy data and ready for future API integration!
