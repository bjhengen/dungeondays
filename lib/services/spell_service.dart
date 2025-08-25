import 'dart:math';
import '../models/player.dart';
import '../models/npc.dart';
import '../models/spell.dart';
import '../models/item.dart';
import '../models/enums.dart';

class SpellEffect {
  final String message;
  final bool success;
  final int? damage;
  final int? healing;
  final Map<String, dynamic>? buffs;
  final Map<String, dynamic>? debuffs;

  const SpellEffect({
    required this.message,
    required this.success,
    this.damage,
    this.healing,
    this.buffs,
    this.debuffs,
  });
}

class SpellService {
  static final Random _random = Random();

  /// Cast a spell in exploration context
  static SpellEffect castExplorationSpell(Spell spell, Player player, {NPC? target, Item? targetItem}) {
    switch (spell.id) {
      case 'light':
        return _castLight(spell, player);
      case 'cure_wounds':
        return _castCureWounds(spell, player);
      case 'detect_magic':
        return _castDetectMagic(spell, player);
      case 'identify':
        return _castIdentify(spell, player, targetItem: targetItem);
      case 'charm_person':
        return target != null ? _castCharmPerson(spell, player, target) : 
               SpellEffect(message: 'No target selected for Charm Person.', success: false);
      case 'invisibility':
        return _castInvisibility(spell, player);
      case 'teleport':
        return _castTeleport(spell, player);
      case 'transmute':
        return _castTransmute(spell, player);
      default:
        return SpellEffect(
          message: '${spell.name} cannot be cast during exploration.',
          success: false,
        );
    }
  }

  /// Cast a spell in combat context
  static SpellEffect castCombatSpell(Spell spell, Player player, {NPC? target}) {
    switch (spell.id) {
      case 'magic_missile':
        return target != null ? _castMagicMissile(spell, player, target) :
               SpellEffect(message: 'No target selected for Magic Missile.', success: false);
      case 'fireball':
        return target != null ? _castFireball(spell, player, target) :
               SpellEffect(message: 'No target selected for Fireball.', success: false);
      case 'ice_shard':
        return target != null ? _castIceShard(spell, player, target) :
               SpellEffect(message: 'No target selected for Ice Shard.', success: false);
      case 'drain_life':
        return target != null ? _castDrainLife(spell, player, target) :
               SpellEffect(message: 'No target selected for Drain Life.', success: false);
      case 'bless':
        return _castBless(spell, player);
      case 'cure_wounds':
        return _castCureWounds(spell, player);
      default:
        return SpellEffect(
          message: '${spell.name} cannot be cast during combat.',
          success: false,
        );
    }
  }

  // EXPLORATION SPELLS

  static SpellEffect _castLight(Spell spell, Player player) {
    // Add light effect to player for 300 seconds (5 minutes)
    player.addActiveEffect('light', 300);
    
    return SpellEffect(
      message: 'A magical light illuminates your surroundings, improving your vision!',
      success: true,
      buffs: {'vision_bonus': 3},
    );
  }

  static SpellEffect _castDetectMagic(Spell spell, Player player) {
    return SpellEffect(
      message: 'Your eyes glow with magical sight, revealing magical auras around you.',
      success: true,
      buffs: {'detect_magic': true},
    );
  }

  static SpellEffect _castIdentify(Spell spell, Player player, {Item? targetItem}) {
    // If no target item provided, return special effect to trigger item selection
    if (targetItem == null) {
      return SpellEffect(
        message: 'SELECT_ITEM_TO_IDENTIFY',
        success: false,
      );
    }

    // Identify the selected item
    if (!targetItem.identified) {
      // Create identified version of the item
      final identifiedItem = Item(
        id: targetItem.id,
        name: targetItem.name,
        description: targetItem.description,
        type: targetItem.type,
        rarity: targetItem.rarity,
        value: targetItem.value,
        identified: true, // Mark as identified
        statModifiers: targetItem.statModifiers,
        specialEffects: targetItem.specialEffects,
        stackSize: targetItem.stackSize,
      );
      
      // Replace the item in player's inventory
      final itemIndex = player.inventory.indexOf(targetItem);
      if (itemIndex >= 0) {
        player.inventory[itemIndex] = identifiedItem;
        
        // If the item was equipped, update equipment
        for (final slot in player.equipment.keys) {
          if (player.equipment[slot] == targetItem) {
            player.equipment[slot] = identifiedItem;
            break;
          }
        }
      }
      
      return SpellEffect(
        message: 'You identify the ${targetItem.name}! Its magical properties are now revealed.',
        success: true,
      );
    } else {
      return SpellEffect(
        message: 'This item is already identified.',
        success: false,
      );
    }
  }

  static SpellEffect _castCharmPerson(Spell spell, Player player, NPC target) {
    // For now, just show a message as NPC disposition might be immutable
    final charmChance = 0.7; // 70% base chance
    if (_random.nextDouble() < charmChance) {
      return SpellEffect(
        message: '${target.name} looks at you with suddenly friendly eyes.',
        success: true,
      );
    } else {
      return SpellEffect(
        message: '${target.name} resists your charm attempt.',
        success: false,
      );
    }
  }

  static SpellEffect _castInvisibility(Spell spell, Player player) {
    return SpellEffect(
      message: 'You fade from view, becoming invisible to enemies.',
      success: true,
      buffs: {'invisible': true, 'duration': spell.duration},
    );
  }

  static SpellEffect _castTeleport(Spell spell, Player player) {
    // For now, just a message - would need integration with world system
    return SpellEffect(
      message: 'Teleportation magic swirls around you, but you need to select a destination.',
      success: true,
    );
  }

  static SpellEffect _castTransmute(Spell spell, Player player) {
    // Find base materials that can be transmuted
    final transmutableItems = player.inventory
        .where((item) => item.type == ItemType.misc && item.value < 10)
        .toList();
    
    if (transmutableItems.isEmpty) {
      return SpellEffect(
        message: 'You have no base materials suitable for transmutation.',
        success: false,
      );
    }

    final item = transmutableItems.first;
    final valueIncrease = 5 + _random.nextInt(10);
    
    // For now, just give the player money directly as items are immutable
    player.silverCoins += valueIncrease;
    
    return SpellEffect(
      message: 'You transmute the ${item.displayName}, gaining $valueIncrease silver!',
      success: true,
    );
  }

  // COMBAT SPELLS

  static SpellEffect _castMagicMissile(Spell spell, Player player, NPC target) {
    final damage = spell.effects['damage'] as int;
    final actualDamage = _calculateSpellDamage(damage, player);
    
    target.currentHp = (target.currentHp - actualDamage).clamp(0, target.maxHp);
    
    return SpellEffect(
      message: 'A glowing missile strikes ${target.name} for $actualDamage magical damage!',
      success: true,
      damage: actualDamage,
    );
  }

  static SpellEffect _castFireball(Spell spell, Player player, NPC target) {
    final damage = spell.effects['damage'] as int;
    final actualDamage = _calculateSpellDamage(damage, player);
    
    target.currentHp = (target.currentHp - actualDamage).clamp(0, target.maxHp);
    
    return SpellEffect(
      message: 'A massive fireball engulfs ${target.name} for $actualDamage fire damage!',
      success: true,
      damage: actualDamage,
    );
  }

  static SpellEffect _castIceShard(Spell spell, Player player, NPC target) {
    final damage = spell.effects['damage'] as int;
    final actualDamage = _calculateSpellDamage(damage, player);
    final oldHp = target.currentHp;
    
    target.currentHp = (target.currentHp - actualDamage).clamp(0, target.maxHp);
    
    return SpellEffect(
      message: 'A piercing ice shard hits ${target.name} for $actualDamage cold damage! [HP: $oldHp → ${target.currentHp}]',
      success: true,
      damage: actualDamage,
    );
  }

  static SpellEffect _castDrainLife(Spell spell, Player player, NPC target) {
    final damage = spell.effects['damage'] as int;
    final healAmount = spell.effects['heal_self'] as int;
    
    final actualDamage = _calculateSpellDamage(damage, player);
    final actualHealing = (healAmount * 0.8).round(); // Slightly reduce healing
    
    target.currentHp = (target.currentHp - actualDamage).clamp(0, target.maxHp);
    player.currentHp = (player.currentHp + actualHealing).clamp(0, player.maxHp);
    
    return SpellEffect(
      message: 'Dark energy drains ${target.name} for $actualDamage damage and heals you for $actualHealing HP!',
      success: true,
      damage: actualDamage,
      healing: actualHealing,
    );
  }

  static SpellEffect _castBless(Spell spell, Player player) {
    final attackBonus = spell.effects['attack_bonus'] as int;
    final defenseBonus = spell.effects['defense_bonus'] as int;
    
    return SpellEffect(
      message: 'Divine power flows through you, enhancing your combat abilities!',
      success: true,
      buffs: {
        'attack_bonus': attackBonus,
        'defense_bonus': defenseBonus,
        'duration': spell.duration,
      },
    );
  }

  // HEALING SPELLS

  static SpellEffect _castCureWounds(Spell spell, Player player) {
    final healAmount = spell.effects['heal'] as int;
    final actualHealing = _calculateHealingAmount(healAmount, player);
    
    final oldHp = player.currentHp;
    player.currentHp = (player.currentHp + actualHealing).clamp(0, player.maxHp);
    final actualHealingDone = player.currentHp - oldHp;
    
    if (actualHealingDone == 0) {
      return SpellEffect(
        message: 'You are already at full health.',
        success: false,
      );
    }
    
    return SpellEffect(
      message: 'Healing energy flows through you, restoring $actualHealingDone HP!',
      success: true,
      healing: actualHealingDone,
    );
  }

  // UTILITY METHODS

  static int _calculateSpellDamage(int baseDamage, Player player) {
    // Add some variance and scale with intelligence
    final intModifier = (player.currentStats.intelligence - 10) ~/ 2;
    final variance = -2 + _random.nextInt(5); // -2 to +2
    return (baseDamage + intModifier + variance).clamp(1, baseDamage * 2);
  }

  static int _calculateHealingAmount(int baseHealing, Player player) {
    // Add some variance and scale with wisdom for clerics
    final wisModifier = (player.currentStats.wisdom - 10) ~/ 2;
    final variance = -2 + _random.nextInt(5); // -2 to +2
    return (baseHealing + wisModifier + variance).clamp(1, baseHealing * 2);
  }

  /// Check if a spell can be learned by a player based on their class and level
  static bool canLearnSpell(Spell spell, Player player) {
    // Basic level requirement
    if (player.level < spell.level) return false;
    
    // Class-specific restrictions
    switch (player.characterClass) {
      case CharacterClass.warrior:
        // Warriors can only learn basic combat and utility spells
        return spell.level <= 2 && (
          spell.school == SpellSchool.evocation || 
          spell.school == SpellSchool.conjuration
        );
      case CharacterClass.wizard:
        // Wizards can learn all arcane spells
        return spell.school != SpellSchool.conjuration; // No divine magic
      case CharacterClass.cleric:
        // Clerics focus on divine and healing magic
        return spell.school == SpellSchool.conjuration ||
               spell.school == SpellSchool.divination ||
               spell.school == SpellSchool.enchantment;
      case CharacterClass.paladin:
        // Paladins get limited divine and combat magic
        return spell.level <= 4 && (
          spell.school == SpellSchool.conjuration ||
          spell.school == SpellSchool.evocation ||
          spell.school == SpellSchool.enchantment
        );
      case CharacterClass.thief:
        // Thieves get utility and illusion magic
        return spell.level <= 3 && (
          spell.school == SpellSchool.illusion ||
          spell.school == SpellSchool.divination ||
          spell.school == SpellSchool.alchemy
        );
    }
  }

  /// Get the cost to learn a spell at a guild
  static int getSpellLearningCost(Spell spell) {
    return spell.level * spell.level * 50; // Quadratic cost scaling
  }
}