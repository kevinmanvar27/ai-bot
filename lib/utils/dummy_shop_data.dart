import '../models/shop_item_model.dart';

/// Dummy shop data with various items AI can request
class DummyShopData {
  static List<ShopItem> getAllItems() {
    return [
      // Clothing
      ShopItem(
        id: 'dress_1',
        name: 'Summer Dress',
        description: 'Beautiful floral summer dress',
        price: 150,
        category: 'clothing',
        imageUrl: '',
        emoji: '👗',
        colors: ['Red', 'Blue', 'Pink', 'White', 'Yellow'],
      ),
      ShopItem(
        id: 'jacket_1',
        name: 'Leather Jacket',
        description: 'Stylish leather jacket',
        price: 300,
        category: 'clothing',
        imageUrl: '',
        emoji: '🧥',
        colors: ['Black', 'Brown', 'Red'],
      ),
      ShopItem(
        id: 'shoes_1',
        name: 'Sneakers',
        description: 'Comfortable running sneakers',
        price: 200,
        category: 'clothing',
        imageUrl: '',
        emoji: '👟',
        colors: ['White', 'Black', 'Pink', 'Blue'],
      ),
      
      // Accessories
      ShopItem(
        id: 'bag_1',
        name: 'Designer Handbag',
        description: 'Elegant designer handbag',
        price: 250,
        category: 'accessories',
        imageUrl: '',
        emoji: '👜',
        colors: ['Black', 'Brown', 'Red', 'Pink'],
      ),
      ShopItem(
        id: 'sunglasses_1',
        name: 'Sunglasses',
        description: 'Trendy sunglasses',
        price: 100,
        category: 'accessories',
        imageUrl: '',
        emoji: '🕶️',
        colors: ['Black', 'Brown', 'Pink'],
      ),
      ShopItem(
        id: 'watch_1',
        name: 'Smart Watch',
        description: 'Latest smartwatch',
        price: 400,
        category: 'accessories',
        imageUrl: '',
        emoji: '⌚',
        colors: ['Silver', 'Gold', 'Black', 'Rose Gold'],
      ),
      ShopItem(
        id: 'ring_1',
        name: 'Diamond Ring',
        description: 'Sparkling diamond ring',
        price: 500,
        category: 'accessories',
        imageUrl: '',
        emoji: '💍',
        colors: ['Silver', 'Gold', 'Rose Gold'],
      ),
      
      // Food & Treats
      ShopItem(
        id: 'cake_1',
        name: 'Chocolate Cake',
        description: 'Delicious chocolate cake',
        price: 50,
        category: 'food',
        imageUrl: '',
        emoji: '🍰',
        colors: ['Chocolate', 'Vanilla', 'Strawberry'],
      ),
      ShopItem(
        id: 'coffee_1',
        name: 'Premium Coffee',
        description: 'Artisan coffee blend',
        price: 30,
        category: 'food',
        imageUrl: '',
        emoji: '☕',
        colors: ['Espresso', 'Latte', 'Cappuccino'],
      ),
      ShopItem(
        id: 'icecream_1',
        name: 'Ice Cream',
        description: 'Premium ice cream',
        price: 40,
        category: 'food',
        imageUrl: '',
        emoji: '🍦',
        colors: ['Chocolate', 'Vanilla', 'Strawberry', 'Mint'],
      ),
      
      // Gifts & Special
      ShopItem(
        id: 'flowers_1',
        name: 'Rose Bouquet',
        description: 'Fresh rose bouquet',
        price: 80,
        category: 'gifts',
        imageUrl: '',
        emoji: '💐',
        colors: ['Red', 'Pink', 'White', 'Yellow'],
      ),
      ShopItem(
        id: 'perfume_1',
        name: 'Luxury Perfume',
        description: 'Exclusive fragrance',
        price: 350,
        category: 'gifts',
        imageUrl: '',
        emoji: '💄',
        colors: ['Floral', 'Fruity', 'Woody', 'Fresh'],
      ),
      ShopItem(
        id: 'teddy_1',
        name: 'Teddy Bear',
        description: 'Cute plush teddy bear',
        price: 60,
        category: 'gifts',
        imageUrl: '',
        emoji: '🧸',
        colors: ['Brown', 'White', 'Pink'],
      ),
    ];
  }
  
  /// Get random item for AI to request
  static ShopItem getRandomRequestItem() {
    final items = getAllItems();
    items.shuffle();
    return items.first;
  }
  
  /// Get AI's request messages based on item
  static String getRequestMessage(ShopItem item, String? color) {
    final colorText = color != null ? ' in $color' : '';
    
    final messages = [
      "I've been looking at this ${item.name}$colorText... Would you get it for me? 🥺",
      "Hey! I really want that ${item.name}$colorText. Can you buy it for me?",
      "I saw this amazing ${item.name}$colorText! I'd love to have it! 💕",
      "You know what would make me happy? That ${item.name}$colorText! 😊",
      "I've been thinking... I really need that ${item.name}$colorText!",
    ];
    
    messages.shuffle();
    return messages.first;
  }
  
  /// Get AI's reactions to gifts
  static Map<String, dynamic> getReactionToGift(
    ShopItem item,
    String selectedColor,
    String? requestedColor,
  ) {
    // Check if it's what she wanted
    final isCorrectColor = requestedColor == null || 
                          requestedColor.toLowerCase() == selectedColor.toLowerCase();
    
    if (isCorrectColor) {
      // Happy reactions
      final happyReactions = [
        "OMG! Thank you so much! I love it! 😍💕",
        "This is perfect! You're the best! 🥰",
        "Aww, you remembered! I'm so happy! 💖",
        "This is exactly what I wanted! Thank you! ✨",
        "You made my day! I love you! 💕😊",
      ];
      happyReactions.shuffle();
      return {
        'emotion': 'happy',
        'message': happyReactions.first,
        'happiness': 20, // Happiness points gained
      };
    } else {
      // Drama reactions (wrong color)
      final dramaReactions = [
        "Hmm... I wanted it in $requestedColor, not $selectedColor... 😕",
        "Oh... it's nice but... I prefer $requestedColor color... 🥺",
        "You got $selectedColor? But I said $requestedColor... 😔",
        "It's okay I guess... but $requestedColor would have been better... 😐",
        "I appreciate it but... this color doesn't suit me... 💔",
      ];
      dramaReactions.shuffle();
      return {
        'emotion': 'neutral',
        'message': dramaReactions.first,
        'happiness': 5, // Less happiness points
      };
    }
  }
  
  /// Get random spontaneous request (when chatting)
  static bool shouldMakeRequest(int messageCount) {
    // Make request every 5-10 messages randomly
    return messageCount % 7 == 0 && messageCount > 0;
  }
}
