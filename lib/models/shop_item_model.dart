/// Shop item model for purchasable gifts
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price; // In coins/points
  final String category; // 'clothing', 'accessories', 'food', 'gifts'
  final String imageUrl; // For now, we'll use emoji/icons
  final String emoji;
  final List<String> colors; // Available color variants
  
  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.emoji,
    this.colors = const [],
  });
}

/// User's purchased item with color choice
class PurchasedItem {
  final String id;
  final ShopItem item;
  final String selectedColor;
  final DateTime purchaseDate;
  bool isGifted; // Whether given to AI
  String? aiReaction; // AI's reaction to the gift
  
  PurchasedItem({
    required this.id,
    required this.item,
    required this.selectedColor,
    required this.purchaseDate,
    this.isGifted = false,
    this.aiReaction,
  });
}

/// AI's gift request
class GiftRequest {
  final String id;
  final ShopItem requestedItem;
  final String? preferredColor;
  final String requestMessage; // What she said when requesting
  final DateTime requestDate;
  bool isFulfilled;
  
  GiftRequest({
    required this.id,
    required this.requestedItem,
    this.preferredColor,
    required this.requestMessage,
    required this.requestDate,
    this.isFulfilled = false,
  });
}
