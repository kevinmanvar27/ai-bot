import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item_model.dart';
import '../providers/shop_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../utils/dummy_shop_data.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ShopItem> _allItems = DummyShopData.getAllItems();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<ShopItem> _getItemsByCategory(String category) {
    if (category == 'all') return _allItems;
    return _allItems.where((item) => item.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Gift Shop',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Coins display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text(
                  '💰',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${shopProvider.userCoins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8B5CF6),
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Clothing'),
            Tab(text: 'Accessories'),
            Tab(text: 'Food'),
            Tab(text: 'Gifts'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Happiness meter
          _buildHappinessMeter(shopProvider),
          
          // Active requests banner
          if (shopProvider.giftRequests.any((req) => !req.isFulfilled))
            _buildRequestsBanner(shopProvider, context),
          
          // Shop items
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopGrid(_getItemsByCategory('all')),
                _buildShopGrid(_getItemsByCategory('clothing')),
                _buildShopGrid(_getItemsByCategory('accessories')),
                _buildShopGrid(_getItemsByCategory('food')),
                _buildShopGrid(_getItemsByCategory('gifts')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInventory(context),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.inventory),
        label: const Text('My Inventory'),
      ),
    );
  }
  
  Widget _buildHappinessMeter(ShopProvider provider) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.2),
              const Color(0xFFEC4899).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${aiProvider.aiName}'s Happiness",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                provider.happinessStatus,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.happinessLevel / 100,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                provider.happinessLevel >= 60
                    ? const Color(0xFFEC4899)
                    : const Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.happinessLevel}/100',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    )
    );
  }
  
  Widget _buildRequestsBanner(ShopProvider provider, BuildContext context) {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    final activeRequests = provider.giftRequests
        .where((req) => !req.isFulfilled)
        .toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '${aiProvider.aiName} wants:',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activeRequests.take(2).map((request) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '• ${request.requestedItem.name}${request.preferredColor != null ? " (${request.preferredColor})" : ""}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildShopGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildShopItemCard(items[index]);
      },
    );
  }
  
  Widget _buildShopItemCard(ShopItem item) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final canAfford = shopProvider.canAfford(item.price);
    
    return GestureDetector(
      onTap: () => _showPurchaseDialog(item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canAfford
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item emoji/image
            Expanded(
              child: Center(
                child: Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
            
            // Item details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: TextStyle(
                              color: canAfford
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.shopping_cart,
                        color: canAfford
                            ? const Color(0xFF8B5CF6)
                            : Colors.white30,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPurchaseDialog(ShopItem item) {
    String? selectedColor = item.colors.isNotEmpty ? item.colors.first : null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              
              // Color selection
              if (item.colors.isNotEmpty) ...[
                const Text(
                  'Select Color:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: item.colors.map((color) {
                    final isSelected = selectedColor == color;
                    return ChoiceChip(
                      label: Text(color),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedColor = color);
                      },
                      selectedColor: const Color(0xFF8B5CF6),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Price
              Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '${item.price} coins',
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final shopProvider = Provider.of<ShopProvider>(
                  context,
                  listen: false,
                );
                
                if (shopProvider.purchaseItem(item, selectedColor ?? 'Default')) {
                  Navigator.pop(context);
                  _showSuccessSnackbar('Purchased ${item.name}!');
                } else {
                  _showErrorSnackbar('Not enough coins!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Buy Now'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showInventory(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'My Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Inventory list
            Expanded(
              child: shopProvider.inventory.isEmpty
                  ? Consumer<AIAssistantProvider>(
                      builder: (context, aiProvider, child) => Center(
                        child: Text(
                          'No items yet!\nBuy gifts for ${aiProvider.aiName} 💝',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shopProvider.inventory.length,
                      itemBuilder: (context, index) {
                        final purchasedItem = shopProvider.inventory[index];
                        return _buildInventoryItem(purchasedItem);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInventoryItem(PurchasedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isGifted
              ? Colors.white10
              : const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Item emoji
          Text(item.item.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Color: ${item.selectedColor}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                if (item.isGifted) ...[
                  const SizedBox(height: 4),
                  Consumer<AIAssistantProvider>(
                    builder: (context, aiProvider, child) => Text(
                      '✓ Gifted to ${aiProvider.aiName}',
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (item.aiReaction != null)
                    Text(
                      item.aiReaction!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            ),
          ),
          
          // Gift button
          if (!item.isGifted)
            ElevatedButton(
              onPressed: () => _giftToAI(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Gift 💝'),
            ),
        ],
      ),
    );
  }
  
  void _giftToAI(PurchasedItem item) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    final reaction = shopProvider.giftItemToAI(item);
    
    // Add reaction to AI chat/conversation
    aiProvider.addReactionMessage(reaction['message']);
    
    // Show reaction dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "${aiProvider.aiName}'s Reaction",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reaction['emotion'] == 'happy' ? '😍' : '😐',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              reaction['message'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '+${reaction['happiness']} Happiness',
              style: TextStyle(
                color: reaction['emotion'] == 'happy'
                    ? const Color(0xFFEC4899)
                    : Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Okay',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
    
    Navigator.pop(context); // Close inventory
  }
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
