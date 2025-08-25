import 'dart:math';
import '../models/item.dart';
import '../models/enums.dart';
import '../models/stats.dart';

class ItemGenerator {
  static const List<String> _weaponNames = [
    'Iron Sword', 'Steel Dagger', 'Oak Staff', 'War Hammer', 'Silver Blade',
    'Enchanted Wand', 'Battle Axe', 'Longbow', 'Mace', 'Rapier'
  ];
  
  static const List<String> _armorNames = [
    'Leather Armor', 'Chain Mail', 'Cloth Robes', 'Plate Armor', 'Studded Leather',
    'Wizard Robes', 'Scale Mail', 'Padded Armor', 'Ring Mail', 'Splint Armor'
  ];
  
  static const List<String> _potionNames = [
    'Health Potion', 'Mana Potion', 'Strength Potion', 'Speed Potion', 'Healing Elixir',
    'Magic Restore', 'Antidote', 'Stamina Brew', 'Intelligence Tonic', 'Lucky Charm'
  ];

  static const List<String> _foodNames = [
    'Fresh Bread', 'Aged Cheese', 'Dried Meat', 'Red Apple', 'Honey Cake',
    'Trail Rations', 'Roasted Chicken', 'Grilled Fish', 'Vegetable Stew', 'Fine Wine',
    'Sweet Rolls', 'Smoked Sausage', 'Berry Pie', 'Corn Bread', 'Butter',
    'Pickled Vegetables', 'Ale', 'Cider', 'Milk', 'Eggs'
  ];

  static const List<String> _bowNames = [
    'Short Bow', 'Long Bow', 'Composite Bow', 'Elven Bow', 'War Bow',
    'Hunter\'s Bow', 'Yew Bow', 'Recurve Bow', 'Crossbow', 'Heavy Crossbow'
  ];

  static const List<String> _arrowNames = [
    'Iron Arrows', 'Steel Arrows', 'Broadhead Arrows', 'Bodkin Arrows', 
    'Silver Arrows', 'Enchanted Arrows', 'Fire Arrows', 'Barbed Arrows'
  ];

  static Item generateStartingWeapon(CharacterClass characterClass) {
    String weaponName;
    int damage = 5;
    
    switch (characterClass) {
      case CharacterClass.warrior:
        weaponName = 'Iron Sword';
        damage = 8;
        break;
      case CharacterClass.thief:
        weaponName = 'Steel Dagger';
        damage = 6;
        break;
      case CharacterClass.wizard:
        weaponName = 'Oak Staff';
        damage = 4;
        break;
      case CharacterClass.cleric:
        weaponName = 'War Hammer';
        damage = 7;
        break;
      case CharacterClass.paladin:
        weaponName = 'Silver Blade';
        damage = 8;
        break;
    }
    
    return Item(
      id: 'starting_weapon_${characterClass.name}',
      name: weaponName,
      description: 'A basic $weaponName suitable for a starting adventurer.',
      type: ItemType.weapon,
      rarity: ItemRarity.common,
      value: 25,
      identified: true,
      statModifiers: Stats(strength: damage),
    );
  }
  
  static Item generateStartingArmor(CharacterClass characterClass) {
    String armorName;
    int defense = 2;
    
    switch (characterClass) {
      case CharacterClass.warrior:
        armorName = 'Chain Mail';
        defense = 4;
        break;
      case CharacterClass.thief:
        armorName = 'Leather Armor';
        defense = 2;
        break;
      case CharacterClass.wizard:
        armorName = 'Cloth Robes';
        defense = 1;
        break;
      case CharacterClass.cleric:
        armorName = 'Scale Mail';
        defense = 3;
        break;
      case CharacterClass.paladin:
        armorName = 'Plate Armor';
        defense = 5;
        break;
    }
    
    return Item(
      id: 'starting_armor_${characterClass.name}',
      name: armorName,
      description: 'Basic $armorName for protection.',
      type: ItemType.armor,
      rarity: ItemRarity.common,
      value: 30,
      identified: true,
      statModifiers: Stats(constitution: defense),
    );
  }
  
  static List<Item> generateStartingSupplies() {
    return [
      Item(
        id: 'bread_1',
        name: 'Bread',
        description: 'Fresh baked bread. Restores hunger.',
        type: ItemType.food,
        value: 2,
        stackSize: 5,
        specialEffects: {'hunger': 15},
      ),
      Item(
        id: 'health_potion_1',
        name: 'Health Potion',
        description: 'A small red potion that restores health.',
        type: ItemType.potion,
        rarity: ItemRarity.common,
        value: 15,
        stackSize: 3,
        specialEffects: {'heal': 25, 'type': 'health'},
      ),
    ];
  }
  
  static Item generateRandomItem(ItemType type, {ItemRarity? rarity, bool isShopItem = false}) {
    final random = Random();
    rarity ??= ItemRarity.values[random.nextInt(ItemRarity.values.length)];
    
    String name;
    String description;
    int baseValue = 10;
    Stats? modifiers;
    Map<String, dynamic>? specialEffects;
    
    switch (type) {
      case ItemType.weapon:
        name = _weaponNames[random.nextInt(_weaponNames.length)];
        final baseBonus = 2 + (rarity.index * 2);
        final variance = random.nextInt(3) - 1; // -1 to +1 variance
        
        // Different weapon types have different stat focuses
        Stats weaponStats;
        String statDescription;
        
        if (name.contains('Sword') || name.contains('Blade') || name.contains('Axe')) {
          // Strength-focused weapons
          weaponStats = Stats(
            strength: baseBonus + variance + 2,
            dexterity: (baseBonus ~/ 2) + variance,
          );
          statDescription = 'STR+${weaponStats.strength}, DEX+${weaponStats.dexterity}';
        } else if (name.contains('Dagger') || name.contains('Rapier')) {
          // Dexterity-focused weapons  
          weaponStats = Stats(
            strength: (baseBonus ~/ 2) + variance,
            dexterity: baseBonus + variance + 2,
          );
          statDescription = 'STR+${weaponStats.strength}, DEX+${weaponStats.dexterity}';
        } else if (name.contains('Staff') || name.contains('Wand')) {
          // Intelligence-focused weapons
          weaponStats = Stats(
            strength: baseBonus + variance,
            intelligence: baseBonus + variance + 2,
            wisdom: (baseBonus ~/ 2) + variance,
          );
          statDescription = 'STR+${weaponStats.strength}, INT+${weaponStats.intelligence}, WIS+${weaponStats.wisdom}';
        } else if (name.contains('Hammer') || name.contains('Mace')) {
          // Strength and constitution focused
          weaponStats = Stats(
            strength: baseBonus + variance + 1,
            constitution: baseBonus + variance + 1,
          );
          statDescription = 'STR+${weaponStats.strength}, CON+${weaponStats.constitution}';
        } else {
          // Balanced weapons
          weaponStats = Stats(
            strength: baseBonus + variance + 1,
            dexterity: baseBonus + variance,
            constitution: (baseBonus ~/ 2) + variance,
          );
          statDescription = 'STR+${weaponStats.strength}, DEX+${weaponStats.dexterity}, CON+${weaponStats.constitution}';
        }
        
        modifiers = weaponStats;
        final totalStats = weaponStats.strength + weaponStats.dexterity + weaponStats.constitution + weaponStats.intelligence + weaponStats.wisdom + weaponStats.charisma + weaponStats.alertness - 70; // Subtract baseline values
        baseValue = 20 + (rarity.index * 15) + (totalStats * 2);
        
        description = isShopItem 
            ? 'A $name of ${rarity.name} quality. $statDescription'
            : 'A weapon that may have magical properties.';
        break;
        
      case ItemType.armor:
        name = _armorNames[random.nextInt(_armorNames.length)];
        final baseBonus = 2 + (rarity.index * 2);
        final variance = random.nextInt(3) - 1; // -1 to +1 variance
        
        // Different armor types have different stat focuses
        Stats armorStats;
        String statDescription;
        
        if (name.contains('Plate') || name.contains('Chain')) {
          // Heavy armor - high defense, dexterity penalty
          armorStats = Stats(
            constitution: baseBonus + variance + 3,
            strength: (baseBonus ~/ 2) + variance + 1,
            dexterity: 10 + variance - 1, // Slight dexterity penalty
          );
          statDescription = 'CON+${armorStats.constitution - 10}, STR+${armorStats.strength - 10}, DEX${armorStats.dexterity - 10}';
        } else if (name.contains('Leather') || name.contains('Studded')) {
          // Light armor - balanced defense and mobility
          armorStats = Stats(
            constitution: baseBonus + variance + 1,
            dexterity: baseBonus + variance + 1,
          );
          statDescription = 'CON+${armorStats.constitution - 10}, DEX+${armorStats.dexterity - 10}';
        } else if (name.contains('Robes') || name.contains('Cloth')) {
          // Mage armor - magical bonuses
          armorStats = Stats(
            constitution: baseBonus + variance,
            intelligence: baseBonus + variance + 2,
            wisdom: (baseBonus ~/ 2) + variance + 1,
          );
          statDescription = 'CON+${armorStats.constitution - 10}, INT+${armorStats.intelligence - 10}, WIS+${armorStats.wisdom - 10}';
        } else {
          // Medium armor - balanced
          armorStats = Stats(
            constitution: baseBonus + variance + 2,
            dexterity: (baseBonus ~/ 2) + variance,
            strength: (baseBonus ~/ 2) + variance,
          );
          statDescription = 'CON+${armorStats.constitution - 10}, DEX+${armorStats.dexterity - 10}, STR+${armorStats.strength - 10}';
        }
        
        modifiers = armorStats;
        final totalStats = armorStats.strength + armorStats.dexterity + armorStats.constitution + armorStats.intelligence + armorStats.wisdom + armorStats.charisma + armorStats.alertness - 70;
        baseValue = 25 + (rarity.index * 20) + (totalStats * 2);
        
        description = isShopItem 
            ? 'Protective $name of ${rarity.name} quality. $statDescription'
            : 'Armor that may have protective enchantments.';
        break;
        
      case ItemType.potion:
        name = _potionNames[random.nextInt(_potionNames.length)];
        baseValue = 10 + (rarity.index * 5);
        
        // Define potion effects
        specialEffects = _generatePotionEffects(name);
        
        description = isShopItem 
            ? _generatePotionDescription(name, specialEffects)
            : 'A potion with mysterious properties.';
        break;
        
      case ItemType.food:
        name = _foodNames[random.nextInt(_foodNames.length)];
        baseValue = 1 + (rarity.index * 2);
        specialEffects = _generateFoodEffects(name);
        
        description = _generateFoodDescription(name, specialEffects);
        break;
        
      case ItemType.scroll:
        // Generate spell scrolls
        final spellNames = [
          'Magic Missile Scroll', 'Cure Wounds Scroll', 'Light Scroll', 
          'Identify Scroll', 'Bless Scroll', 'Ice Shard Scroll'
        ];
        name = spellNames[random.nextInt(spellNames.length)];
        baseValue = 25 + (rarity.index * 15);
        
        final spellId = name.toLowerCase().replaceAll(' scroll', '').replaceAll(' ', '_');
        specialEffects = {
          'spell_id': spellId,
          'single_use': true,
          'type': 'spell_scroll'
        };
        
        if (isShopItem) {
          description = 'A magical scroll containing the $name spell. Single use.';
        } else {
          description = 'A scroll covered in mystical runes.';
        }
        break;
        
      case ItemType.bow:
        name = _bowNames[random.nextInt(_bowNames.length)];
        final bonus = 2 + rarity.index; // Bows get slightly higher range bonus
        modifiers = Stats(dexterity: bonus);
        baseValue = 30 + (rarity.index * 20);
        
        description = isShopItem 
            ? 'A $name of ${rarity.name} quality. Range bonus: +$bonus'
            : 'A ranged weapon that may have magical properties.';
        break;
        
      case ItemType.arrows:
        name = _arrowNames[random.nextInt(_arrowNames.length)];
        final bonus = 1 + rarity.index;
        modifiers = Stats(strength: bonus); // Arrows add damage
        baseValue = 5 + (rarity.index * 5);
        
        description = isShopItem 
            ? '$name of ${rarity.name} quality. Damage bonus: +$bonus'
            : 'Arrows that may have magical properties.';
        break;
        
      default:
        name = 'Miscellaneous Item';
        description = 'A useful item of uncertain origin.';
    }
    
    // For shop items, most are identified. For found items, higher rarity = less likely to be identified
    bool identified;
    if (isShopItem) {
      // 90% of shop items are identified, 10% are "exotic" mysterious items
      identified = random.nextDouble() < 0.9;
    } else {
      // Found items: common = always identified, higher rarity = less likely
      identified = rarity == ItemRarity.common || random.nextDouble() < (1.0 - (rarity.index * 0.2));
    }
    
    return Item(
      id: '${type.name}_${random.nextInt(10000)}',
      name: name,
      description: description,
      type: type,
      rarity: rarity,
      value: baseValue,
      identified: identified,
      statModifiers: modifiers,
      specialEffects: specialEffects,
    );
  }
  
  static Map<String, dynamic> _generatePotionEffects(String name) {
    switch (name) {
      case 'Health Potion':
        return {'heal': 25, 'type': 'health'};
      case 'Mana Potion':
        return {'restore': 20, 'type': 'mana'};
      case 'Strength Potion':
        return {'boost': 3, 'stat': 'strength', 'duration': 10};
      case 'Speed Potion':
        return {'boost': 2, 'stat': 'dexterity', 'duration': 8};
      case 'Healing Elixir':
        return {'heal': 40, 'type': 'health'};
      case 'Magic Restore':
        return {'restore': 35, 'type': 'mana'};
      case 'Intelligence Tonic':
        return {'boost': 2, 'stat': 'intelligence', 'duration': 12};
      default:
        return {'heal': 15, 'type': 'health'};
    }
  }
  
  static Map<String, dynamic> _generateFoodEffects(String name) {
    switch (name) {
      case 'Fresh Bread':
      case 'Bread':
        return {'hunger': 15};
      case 'Aged Cheese':
      case 'Cheese':
        return {'hunger': 20, 'health': 5};
      case 'Dried Meat':
        return {'hunger': 25, 'strength_temp': 1};
      case 'Red Apple':
      case 'Apple':
        return {'hunger': 10, 'health': 3};
      case 'Honey Cake':
        return {'hunger': 30, 'mana': 10};
      case 'Trail Rations':
        return {'hunger': 40};
      case 'Roasted Chicken':
        return {'hunger': 35, 'health': 8};
      case 'Grilled Fish':
      case 'Fish Steak':
        return {'hunger': 30, 'wisdom_temp': 1};
      case 'Vegetable Stew':
        return {'hunger': 35, 'health': 10};
      case 'Fine Wine':
      case 'Wine':
        return {'hunger': 5, 'mana': 15, 'charisma_temp': 2};
      case 'Sweet Rolls':
        return {'hunger': 25, 'mana': 5};
      case 'Smoked Sausage':
        return {'hunger': 30, 'health': 5};
      case 'Berry Pie':
        return {'hunger': 25, 'health': 8};
      case 'Corn Bread':
        return {'hunger': 20};
      case 'Butter':
        return {'hunger': 10, 'health': 2};
      case 'Pickled Vegetables':
        return {'hunger': 15, 'health': 5};
      case 'Ale':
        return {'hunger': 8, 'strength_temp': 1};
      case 'Cider':
        return {'hunger': 12, 'dexterity_temp': 1};
      case 'Milk':
        return {'hunger': 15, 'health': 3};
      case 'Eggs':
        return {'hunger': 18, 'health': 4};
      default:
        return {'hunger': 15};
    }
  }
  
  static String _generatePotionDescription(String name, Map<String, dynamic>? effects) {
    if (effects == null) return 'A magical potion.';
    
    final desc = StringBuffer('A magical potion that ');
    
    if (effects.containsKey('heal')) {
      desc.write('restores ${effects['heal']} health');
    } else if (effects.containsKey('restore')) {
      desc.write('restores ${effects['restore']} mana');
    } else if (effects.containsKey('boost')) {
      desc.write('temporarily increases ${effects['stat']} by ${effects['boost']}');
    } else {
      desc.write('has mysterious effects');
    }
    
    desc.write('.');
    return desc.toString();
  }
  
  static String _generateFoodDescription(String name, Map<String, dynamic>? effects) {
    if (effects == null) return 'Nourishing food.';
    
    final desc = StringBuffer();
    final hunger = effects['hunger'] ?? 0;
    
    desc.write('Restores $hunger hunger');
    
    if (effects.containsKey('health')) {
      desc.write(' and ${effects['health']} health');
    }
    if (effects.containsKey('mana')) {
      desc.write(' and ${effects['mana']} mana');
    }
    
    desc.write('.');
    return desc.toString();
  }
  
  static List<Item> generateShopInventory(GuildType guildType, int itemCount) {
    final random = Random();
    final items = <Item>[];
    
    switch (guildType) {
      case GuildType.blacksmiths:
        for (int i = 0; i < itemCount; i++) {
          final itemTypes = [ItemType.weapon, ItemType.armor, ItemType.bow, ItemType.arrows];
          items.add(generateRandomItem(itemTypes[random.nextInt(itemTypes.length)], isShopItem: true));
        }
        break;
      case GuildType.alchemists:
        for (int i = 0; i < itemCount; i++) {
          final types = [ItemType.potion, ItemType.scroll];
          items.add(generateRandomItem(types[random.nextInt(types.length)], isShopItem: true));
        }
        break;
      case GuildType.merchants:
        for (int i = 0; i < itemCount; i++) {
          final types = [ItemType.food, ItemType.potion, ItemType.scroll];
          items.add(generateRandomItem(types[random.nextInt(types.length)], isShopItem: true));
        }
        break;
      default:
        // General shop
        for (int i = 0; i < itemCount; i++) {
          final types = [ItemType.weapon, ItemType.armor, ItemType.food, ItemType.potion];
          items.add(generateRandomItem(types[random.nextInt(types.length)], isShopItem: true));
        }
    }
    
    return items;
  }
}