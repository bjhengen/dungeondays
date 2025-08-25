import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../models/enums.dart';

class InventoryScreen extends StatefulWidget {
  final Player player;
  final Function(Player) onPlayerUpdate;

  const InventoryScreen({
    super.key,
    required this.player,
    required this.onPlayerUpdate,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _showEquipment = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Header with player info and tabs
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.player.name} (Level ${widget.player.level})',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Load: ${widget.player.inventory.length}/${widget.player.maxInventorySlots}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showEquipment = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showEquipment ? Colors.amber.shade800 : Colors.grey,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Equipment', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showEquipment = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showEquipment ? Colors.grey : Colors.amber.shade800,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Items', style: TextStyle(fontFamily: 'monospace')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _showEquipment ? _buildEquipmentView() : _buildInventoryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Character stats
          _buildStatsCard(),
          const SizedBox(height: 16),
          
          // Equipment slots
          _buildEquipmentGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = widget.player.currentStats;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Character Stats',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('STR', stats.strength),
                    _buildStatRow('INT', stats.intelligence),
                    _buildStatRow('WIS', stats.wisdom),
                    _buildStatRow('DEX', stats.dexterity),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('CON', stats.constitution),
                    _buildStatRow('CHA', stats.charisma),
                    _buildStatRow('ALERT', stats.alertness),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.amber),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVitalRow('HP', widget.player.currentHp, widget.player.maxHp, Colors.red),
                    _buildVitalRow('MP', widget.player.currentMana, widget.player.maxMana, Colors.blue),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVitalRow('Hunger', widget.player.hunger, widget.player.maxHunger, Colors.orange),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalRow(String label, int current, int max, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          Text(
            '$current/$max',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid() {
    return Column(
      children: [
        const Text(
          'Equipment',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        
        // Equipment layout (2x3 grid + weapon/shield/bow)
        Row(
          children: [
            // Left side
            Expanded(
              child: Column(
                children: [
                  _buildEquipmentSlot('helmet', 'Head', Icons.shield),
                  const SizedBox(height: 8),
                  _buildEquipmentSlot('armor', 'Chest', Icons.security),
                  const SizedBox(height: 8),
                  _buildEquipmentSlot('gloves', 'Hands', Icons.front_hand),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Center (weapon/shield)
            Column(
              children: [
                _buildEquipmentSlot('weapon', 'Weapon', Icons.radio_button_unchecked, isLarge: true),
                const SizedBox(height: 8),
                _buildEquipmentSlot('shield', 'Shield', Icons.shield, isLarge: true),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Right side (ranged + accessories)
            Expanded(
              child: Column(
                children: [
                  _buildEquipmentSlot('bow', 'Bow', Icons.sports_martial_arts),
                  const SizedBox(height: 8),
                  _buildEquipmentSlot('arrows', 'Arrows', Icons.arrow_forward),
                  const SizedBox(height: 8),
                  _buildEquipmentSlot('amulet', 'Neck', Icons.circle),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Ring slots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEquipmentSlot('ring1', 'Ring 1', Icons.circle_outlined),
            const SizedBox(width: 16),
            _buildEquipmentSlot('ring2', 'Ring 2', Icons.circle_outlined),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Boots at bottom
        _buildEquipmentSlot('boots', 'Feet', Icons.directions_walk),
      ],
    );
  }

  Widget _buildEquipmentSlot(String slotName, String label, IconData icon, {bool isLarge = false}) {
    final item = widget.player.equipment[slotName];
    final size = isLarge ? 80.0 : 60.0;
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => item != null ? _showEquipmentOptions(slotName, item) : _showEquipOptions(slotName),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: item != null ? Colors.amber.shade800.withValues(alpha: 0.3) : Colors.grey.shade800,
              border: Border.all(
                color: item != null ? _getRarityColor(item.rarity) : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getItemIcon(item.type),
                      color: _getRarityColor(item.rarity),
                      size: isLarge ? 32 : 24,
                    ),
                    if (isLarge)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.displayName.length > 10 ? '${item.displayName.substring(0, 10)}...' : item.displayName,
                          style: TextStyle(
                            color: _getRarityColor(item.rarity),
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                )
              : Icon(
                  icon,
                  color: Colors.grey,
                  size: isLarge ? 32 : 24,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.player.inventory.length,
      itemBuilder: (context, index) {
        final item = widget.player.inventory[index];
        return _buildInventoryTile(item);
      },
    );
  }

  Widget _buildInventoryTile(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: _getRarityColor(item.rarity)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          _getItemIcon(item.type),
          color: _getRarityColor(item.rarity),
          size: 32,
        ),
        title: Text(
          item.displayName,
          style: TextStyle(
            color: _getRarityColor(item.rarity),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          item.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isWeapon || item.isArmor || item.type == ItemType.ring || item.type == ItemType.amulet || item.type == ItemType.bow || item.type == ItemType.arrows)
              ElevatedButton(
                onPressed: () => _equipItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text('Equip', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ),
            if (item.isConsumable)
              ElevatedButton(
                onPressed: () => _useItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text('Use', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  void _equipItem(Item item) {
    String? slotName;
    
    switch (item.type) {
      case ItemType.weapon:
        slotName = 'weapon';
        break;
      case ItemType.armor:
        slotName = 'armor';
        break;
      case ItemType.shield:
        slotName = 'shield';
        break;
      case ItemType.bow:
        slotName = 'bow';
        break;
      case ItemType.arrows:
        slotName = 'arrows';
        break;
      case ItemType.ring:
        // Try ring1 first, then ring2
        if (widget.player.equipment['ring1'] == null) {
          slotName = 'ring1';
        } else if (widget.player.equipment['ring2'] == null) {
          slotName = 'ring2';
        } else {
          slotName = 'ring1'; // Replace ring1 if both are occupied
        }
        break;
      case ItemType.amulet:
        slotName = 'amulet';
        break;
      default:
        break;
    }
    
    if (slotName != null) {
      // Unequip current item if any
      final currentItem = widget.player.equipment[slotName];
      if (currentItem != null) {
        widget.player.addToInventory(currentItem);
      }
      
      // Equip new item
      widget.player.equipment[slotName] = item;
      widget.player.removeFromInventory(item);
      widget.player.recalculateStats();
      
      setState(() {});
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipped ${item.displayName}')),
      );
    }
  }

  void _useItem(Item item) {
    if (item.specialEffects != null) {
      final effects = item.specialEffects!;
      
      // Apply item effects
      if (effects.containsKey('heal')) {
        widget.player.currentHp = (widget.player.currentHp + (effects['heal'] as int))
            .clamp(0, widget.player.maxHp);
      }
      if (effects.containsKey('restore')) {
        widget.player.currentMana = (widget.player.currentMana + (effects['restore'] as int))
            .clamp(0, widget.player.maxMana);
      }
      if (effects.containsKey('hunger')) {
        widget.player.hunger = (widget.player.hunger + (effects['hunger'] as int))
            .clamp(0, widget.player.maxHunger);
      }
      if (effects.containsKey('health')) {
        widget.player.currentHp = (widget.player.currentHp + (effects['health'] as int))
            .clamp(0, widget.player.maxHp);
      }
      if (effects.containsKey('mana')) {
        widget.player.currentMana = (widget.player.currentMana + (effects['mana'] as int))
            .clamp(0, widget.player.maxMana);
      }
      
      // Remove item from inventory
      widget.player.removeFromInventory(item);
      
      setState(() {});
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Used ${item.displayName}')),
      );
    }
  }

  void _showEquipmentOptions(String slotName, Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(item.displayName, style: TextStyle(color: _getRarityColor(item.rarity))),
          content: Text(item.description, style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unequipItem(slotName, item);
              },
              child: const Text('Unequip', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showEquipOptions(String slotName) {
    final availableItems = widget.player.inventory.where((item) {
      switch (slotName) {
        case 'weapon': return item.type == ItemType.weapon;
        case 'armor': return item.type == ItemType.armor;
        case 'shield': return item.type == ItemType.shield;
        case 'bow': return item.type == ItemType.bow;
        case 'arrows': return item.type == ItemType.arrows;
        case 'ring1':
        case 'ring2': 
          return item.type == ItemType.ring;
        case 'amulet': return item.type == ItemType.amulet;
        default: return false;
      }
    }).toList();
    
    if (availableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No suitable items to equip')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Equip ${slotName}', style: const TextStyle(color: Colors.amber)),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: availableItems.length,
              itemBuilder: (context, index) {
                final item = availableItems[index];
                return ListTile(
                  leading: Icon(_getItemIcon(item.type), color: _getRarityColor(item.rarity)),
                  title: Text(item.displayName, style: TextStyle(color: _getRarityColor(item.rarity), fontFamily: 'monospace')),
                  subtitle: Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _equipItem(item);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _unequipItem(String slotName, Item item) {
    if (widget.player.addToInventory(item)) {
      widget.player.equipment[slotName] = null;
      widget.player.recalculateStats();
      setState(() {});
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unequipped ${item.displayName}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory is full!')),
      );
    }
  }

  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(item.displayName, style: TextStyle(color: _getRarityColor(item.rarity))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description, style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
              const SizedBox(height: 8),
              Text('Type: ${item.type.name}', style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
              Text('Rarity: ${item.rarity.name}', style: TextStyle(color: _getRarityColor(item.rarity), fontFamily: 'monospace')),
              Text('Value: ${item.value} silver', style: const TextStyle(color: Colors.yellow, fontFamily: 'monospace')),
              if (item.statModifiers != null && item.identified)
                Text('Effects: ${_getStatModifiersText(item)}', style: const TextStyle(color: Colors.green, fontFamily: 'monospace')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
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

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.weapon: return Icons.radio_button_unchecked;
      case ItemType.armor: return Icons.security;
      case ItemType.shield: return Icons.shield;
      case ItemType.bow: return Icons.sports_martial_arts;
      case ItemType.arrows: return Icons.arrow_forward;
      case ItemType.potion: return Icons.local_drink;
      case ItemType.food: return Icons.restaurant;
      case ItemType.ring: return Icons.circle_outlined;
      case ItemType.amulet: return Icons.circle;
      default: return Icons.inventory;
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
}