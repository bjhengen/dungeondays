import 'enums.dart';
import 'stats.dart';

class Item {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final ItemRarity rarity;
  final int value; // in silver
  final bool identified;
  final bool cursed;
  final Stats? statModifiers;
  final Map<String, dynamic>? specialEffects;
  final int stackSize;
  
  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.rarity = ItemRarity.common,
    this.value = 0,
    this.identified = true,
    this.cursed = false,
    this.statModifiers,
    this.specialEffects,
    this.stackSize = 1,
  });

  String get displayName => identified ? name : 'Unknown ${type.name}';
  
  bool get isWeapon => type == ItemType.weapon;
  bool get isArmor => type == ItemType.armor;
  bool get isConsumable => type == ItemType.potion || type == ItemType.scroll || type == ItemType.food;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.index,
    'rarity': rarity.index,
    'value': value,
    'identified': identified,
    'cursed': cursed,
    'statModifiers': statModifiers?.toJson(),
    'specialEffects': specialEffects,
    'stackSize': stackSize,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: ItemType.values[json['type']],
    rarity: ItemRarity.values[json['rarity'] ?? 0],
    value: json['value'] ?? 0,
    identified: json['identified'] ?? true,
    cursed: json['cursed'] ?? false,
    statModifiers: json['statModifiers'] != null ? Stats.fromJson(json['statModifiers']) : null,
    specialEffects: json['specialEffects'],
    stackSize: json['stackSize'] ?? 1,
  );
}