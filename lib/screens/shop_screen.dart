import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../models/town.dart';
import '../models/enums.dart';
import '../models/stats.dart';
import '../utils/item_generator.dart';

class ShopScreen extends StatefulWidget {
  final Player player;
  final Building building;
  final Function(Player) onPlayerUpdate;

  const ShopScreen({
    super.key,
    required this.player,
    required this.building,
    required this.onPlayerUpdate,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Item> _shopInventory = [];
  bool _showPlayerInventory = false;

  @override
  void initState() {
    super.initState();
    _generateShopInventory();
  }

  void _generateShopInventory() {
    // Generate shop inventory based on building type
    GuildType? shopType;
    int itemCount = 6;
    
    switch (widget.building.type) {
      case BuildingType.smithy:
        shopType = GuildType.blacksmiths;
        itemCount = 8;
        break;
      case BuildingType.alchemist:
        shopType = GuildType.alchemists;
        itemCount = 10;
        break;
      case BuildingType.market:
        shopType = GuildType.merchants;
        itemCount = 12;
        break;
      case BuildingType.shop:
        shopType = GuildType.merchants;
        itemCount = 6;
        break;
      default:
        shopType = GuildType.merchants;
    }
    
    if (shopType != null) {
      _shopInventory = ItemGenerator.generateShopInventory(shopType, itemCount);
    }
  }

  void _buyItem(Item item) {
    if (widget.player.canAfford(item.value)) {
      if (widget.player.addToInventory(item)) {
        widget.player.spendMoney(item.value);
        setState(() {
          _shopInventory.remove(item);
        });
        widget.onPlayerUpdate(widget.player);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchased ${item.displayName} for ${item.value} silver')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your inventory is full!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have enough money!')),
      );
    }
  }

  void _sellItem(Item item) {
    final sellPrice = (item.value * 0.6).round(); // Sell for 60% of value
    widget.player.addMoney(sellPrice);
    widget.player.removeFromInventory(item);
    
    setState(() {
      // Add to shop inventory with some randomness
      if (_shopInventory.length < 15) {
        _shopInventory.add(item);
      }
    });
    
    widget.onPlayerUpdate(widget.player);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sold ${item.displayName} for $sellPrice silver')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.building.name),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_showPlayerInventory ? Icons.store : Icons.inventory),
            onPressed: () {
              setState(() {
                _showPlayerInventory = !_showPlayerInventory;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with money and tab indicators
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Money: ${widget.player.goldCoins}g ${widget.player.silverCoins}s',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Inventory: ${widget.player.inventory.length}/${widget.player.maxInventorySlots}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showPlayerInventory = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showPlayerInventory ? Colors.grey : Colors.amber.shade800,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Shop Items', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showPlayerInventory = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showPlayerInventory ? Colors.amber.shade800 : Colors.grey,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Your Items', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Item list
          Expanded(
            child: _showPlayerInventory ? _buildPlayerInventory() : _buildShopInventory(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInventory() {
    if (_shopInventory.isEmpty) {
      return const Center(
        child: Text(
          'No items available',
          style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
        ),
      );
    }

    return ListView.builder(
      itemCount: _shopInventory.length,
      itemBuilder: (context, index) {
        final item = _shopInventory[index];
        return _buildItemTile(
          item: item,
          price: item.value,
          action: 'BUY',
          onPressed: () => _buyItem(item),
          canAfford: widget.player.canAfford(item.value),
        );
      },
    );
  }

  Widget _buildPlayerInventory() {
    if (widget.player.inventory.isEmpty) {
      return const Center(
        child: Text(
          'Your inventory is empty',
          style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.player.inventory.length,
      itemBuilder: (context, index) {
        final item = widget.player.inventory[index];
        final sellPrice = (item.value * 0.6).round();
        return _buildItemTile(
          item: item,
          price: sellPrice,
          action: 'SELL',
          onPressed: () => _sellItem(item),
          canAfford: true, // Can always sell
        );
      },
    );
  }

  Widget _buildItemTile({
    required Item item,
    required int price,
    required String action,
    required VoidCallback onPressed,
    required bool canAfford,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: _getRarityColor(item.rarity)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          item.displayName,
          style: TextStyle(
            color: _getRarityColor(item.rarity),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            if (item.statModifiers != null)
              Text(
                _getStatModifiersText(item),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            if (action == 'BUY' && _isEquipment(item))
              _buildStatComparison(item),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${price}s',
                    style: TextStyle(
                      color: canAfford ? Colors.yellow : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 20,
                    child: ElevatedButton(
                      onPressed: canAfford ? onPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action == 'BUY' ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(40, 20),
                      ),
                      child: Text(
                        action,
                        style: const TextStyle(fontSize: 8, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common: return Colors.white;
      case ItemRarity.uncommon: return Colors.green;
      case ItemRarity.rare: return Colors.blue;
      case ItemRarity.epic: return Colors.purple;
      case ItemRarity.legendary: return Colors.orange;
    }
  }

  String _getStatModifiersText(Item item) {
    final stats = item.statModifiers!;
    final modifiers = <String>[];
    
    if (stats.strength > 0) modifiers.add('+${stats.strength} STR');
    if (stats.intelligence > 0) modifiers.add('+${stats.intelligence} INT');
    if (stats.wisdom > 0) modifiers.add('+${stats.wisdom} WIS');
    if (stats.dexterity > 0) modifiers.add('+${stats.dexterity} DEX');
    if (stats.constitution > 0) modifiers.add('+${stats.constitution} CON');
    if (stats.charisma > 0) modifiers.add('+${stats.charisma} CHA');
    if (stats.alertness > 0) modifiers.add('+${stats.alertness} ALERT');
    
    return modifiers.join(', ');
  }

  bool _isEquipment(Item item) {
    return item.type == ItemType.weapon || 
           item.type == ItemType.armor || 
           item.type == ItemType.shield;
  }

  Widget _buildStatComparison(Item item) {
    final currentItem = _getCurrentlyEquippedItem(item);
    if (currentItem == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          'No ${item.type.name} equipped',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 10,
            fontStyle: FontStyle.italic,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    final comparison = _getStatComparison(currentItem, item);
    if (comparison.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          'Similar to current ${item.type.name}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        comparison,
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Item? _getCurrentlyEquippedItem(Item shopItem) {
    switch (shopItem.type) {
      case ItemType.weapon:
        return widget.player.equipment['weapon'];
      case ItemType.armor:
        return widget.player.equipment['armor'];
      case ItemType.shield:
        return widget.player.equipment['shield'];
      default:
        return null;
    }
  }

  String _getStatComparison(Item current, Item shop) {
    if (current.statModifiers == null && shop.statModifiers == null) {
      return '';
    }

    final currentStats = current.statModifiers ?? Stats();
    final shopStats = shop.statModifiers ?? Stats();
    
    final differences = <String>[];

    final strDiff = shopStats.strength - currentStats.strength;
    final intDiff = shopStats.intelligence - currentStats.intelligence;
    final wisDiff = shopStats.wisdom - currentStats.wisdom;
    final dexDiff = shopStats.dexterity - currentStats.dexterity;
    final conDiff = shopStats.constitution - currentStats.constitution;
    final chaDiff = shopStats.charisma - currentStats.charisma;
    final alertDiff = shopStats.alertness - currentStats.alertness;

    void addDifference(String stat, int diff) {
      if (diff > 0) {
        differences.add('+$diff $stat');
      } else if (diff < 0) {
        differences.add('$diff $stat');
      }
    }

    addDifference('STR', strDiff);
    addDifference('INT', intDiff);
    addDifference('WIS', wisDiff);
    addDifference('DEX', dexDiff);
    addDifference('CON', conDiff);
    addDifference('CHA', chaDiff);
    addDifference('ALERT', alertDiff);

    if (differences.isEmpty) {
      return '';
    }

    return 'vs current: ${differences.join(', ')}';
  }
}