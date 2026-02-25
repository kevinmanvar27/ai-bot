import 'package:flutter/material.dart';
import '../models/shop_item_model.dart';

/// Shop and inventory management provider
class ShopProvider with ChangeNotifier {
  // User's coins/points
  int _userCoins = 1000; // Starting coins
  
  // User's inventory
  final List<PurchasedItem> _inventory = [];
  
  // Active gift requests from AI
  final List<GiftRequest> _giftRequests = [];
  
  // AI's happiness level (0-100)
  int _happinessLevel = 50;
  
  // Getters
  int get userCoins => _userCoins;
  List<PurchasedItem> get inventory => List.unmodifiable(_inventory);
  List<GiftRequest> get giftRequests => List.unmodifiable(_giftRequests);
  int get happinessLevel => _happinessLevel;
  
  // Get ungifted items (available to give)
  List<PurchasedItem> get ungiftedItems => 
      _inventory.where((item) => !item.isGifted).toList();
  
  // Get gifted items history
  List<PurchasedItem> get giftedItems => 
      _inventory.where((item) => item.isGifted).toList();
  
  /// Purchase an item from shop
  bool purchaseItem(ShopItem item, String selectedColor) {
    if (_userCoins >= item.price) {
      _userCoins -= item.price;
      
      final purchasedItem = PurchasedItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        item: item,
        selectedColor: selectedColor,
        purchaseDate: DateTime.now(),
      );
      
      _inventory.add(purchasedItem);
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Gift an item to AI
  Map<String, dynamic> giftItemToAI(PurchasedItem purchasedItem) {
    // Find if this item was requested
    final matchingRequest = _giftRequests.firstWhere(
      (req) => req.requestedItem.id == purchasedItem.item.id && !req.isFulfilled,
      orElse: () => GiftRequest(
        id: '',
        requestedItem: purchasedItem.item,
        requestMessage: '',
        requestDate: DateTime.now(),
      ),
    );
    
    // Generate reaction based on whether it matches request
    final reaction = _generateReaction(
      purchasedItem,
      matchingRequest.preferredColor,
    );
    
    // Update item as gifted
    purchasedItem.isGifted = true;
    purchasedItem.aiReaction = reaction['message'];
    
    // Update happiness
    _happinessLevel = (_happinessLevel + reaction['happiness'] as int).clamp(0, 100);
    
    // Mark request as fulfilled if it exists
    if (matchingRequest.id.isNotEmpty) {
      matchingRequest.isFulfilled = true;
    }
    
    notifyListeners();
    return reaction;
  }
  
  /// Add a gift request from AI
  void addGiftRequest(GiftRequest request) {
    _giftRequests.add(request);
    notifyListeners();
  }
  
  /// Remove/cancel a gift request
  void removeGiftRequest(String requestId) {
    _giftRequests.removeWhere((req) => req.id == requestId);
    notifyListeners();
  }
  
  /// Add coins (for testing or rewards)
  void addCoins(int amount) {
    _userCoins += amount;
    notifyListeners();
  }
  
  /// Generate AI's reaction to a gift
  Map<String, dynamic> _generateReaction(
    PurchasedItem item,
    String? requestedColor,
  ) {
    final isCorrectColor = requestedColor == null || 
                          requestedColor.toLowerCase() == item.selectedColor.toLowerCase();
    
    if (isCorrectColor) {
      // Happy reactions
      final happyReactions = [
        "OMG! Thank you so much! I love it! 😍💕",
        "This is perfect! You're the best! 🥰",
        "Aww, you remembered! I'm so happy! 💖",
        "This is exactly what I wanted! Thank you! ✨",
        "You made my day! I love you! 💕😊",
        "I can't believe you got this for me! 🥹💕",
        "This is amazing! You know me so well! 😊",
      ];
      happyReactions.shuffle();
      return {
        'emotion': 'happy',
        'message': happyReactions.first,
        'happiness': 20,
      };
    } else {
      // Drama reactions
      final dramaReactions = [
        "Hmm... I wanted it in $requestedColor, not ${item.selectedColor}... 😕",
        "Oh... it's nice but... I prefer $requestedColor color... 🥺",
        "You got ${item.selectedColor}? But I said $requestedColor... 😔",
        "It's okay I guess... but $requestedColor would have been better... 😐",
        "I appreciate it but... this color doesn't suit me... 💔",
        "Well... ${item.selectedColor} is not really my style... 😬",
      ];
      dramaReactions.shuffle();
      return {
        'emotion': 'neutral',
        'message': dramaReactions.first,
        'happiness': 5,
      };
    }
  }
  
  /// Check if user can afford an item
  bool canAfford(int price) => _userCoins >= price;
  
  /// Get happiness status text
  String get happinessStatus {
    if (_happinessLevel >= 80) return "Very Happy 😍";
    if (_happinessLevel >= 60) return "Happy 😊";
    if (_happinessLevel >= 40) return "Neutral 😐";
    if (_happinessLevel >= 20) return "Sad 😔";
    return "Very Sad 😢";
  }
}
