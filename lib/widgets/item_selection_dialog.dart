import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/enums.dart';

class ItemSelectionDialog extends StatelessWidget {
  final List<Item> items;
  final String title;
  final String emptyMessage;
  final Function(Item) onItemSelected;

  const ItemSelectionDialog({
    super.key,
    required this.items,
    required this.title,
    required this.emptyMessage,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontFamily: 'monospace',
          ),
        ),
        content: Text(
          emptyMessage,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.amber,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      );
    }

    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.amber.shade300),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  
                  return Card(
                    color: Colors.black87,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getItemIcon(item.type),
                        color: _getRarityColor(item.rarity),
                      ),
                      title: Text(
                        item.displayName,
                        style: TextStyle(
                          color: _getRarityColor(item.rarity),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: item.identified ? Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ) : Text(
                        'Unidentified ${item.type.name}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      onTap: () {
                        onItemSelected(item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.weapon:
        return Icons.sports_martial_arts;
      case ItemType.armor:
        return Icons.shield;
      case ItemType.shield:
        return Icons.security;
      case ItemType.potion:
        return Icons.local_drink;
      case ItemType.scroll:
        return Icons.description;
      case ItemType.food:
        return Icons.restaurant;
      case ItemType.misc:
        return Icons.category;
      case ItemType.ring:
        return Icons.circle;
      case ItemType.amulet:
        return Icons.diamond;
      case ItemType.container:
        return Icons.inventory;
      case ItemType.bow:
        return Icons.sports_martial_arts;
      case ItemType.arrows:
        return Icons.sports_martial_arts;
    }
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.white;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }
}