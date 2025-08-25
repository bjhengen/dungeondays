import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/npc.dart';
import '../models/enums.dart';
import '../models/item.dart';
import '../models/spell.dart';
import '../utils/item_generator.dart';
import '../services/spell_service.dart';
import '../widgets/item_selection_dialog.dart';
import 'spellbook_screen.dart';

class CombatScreen extends StatefulWidget {
  final Player player;
  final NPC enemy;
  final Function(Player updatedPlayer, bool enemyDefeated) onCombatEnd;

  const CombatScreen({
    super.key,
    required this.player,
    required this.enemy,
    required this.onCombatEnd,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  final Random _random = Random();
  final List<String> _combatLog = [];
  final ScrollController _scrollController = ScrollController();
  bool _playerTurn = true;
  bool _combatEnded = false;

  @override
  void initState() {
    super.initState();
    _addToLog('Combat begins between ${widget.player.name} and ${widget.enemy.name}!');
    _addToLog('${widget.player.name}: ${widget.player.currentHp}/${widget.player.maxHp} HP');
    _addToLog('${widget.enemy.name}: ${widget.enemy.currentHp}/${widget.enemy.maxHp} HP');
  }

  void _addToLog(String message) {
    setState(() {
      _combatLog.add(message);
    });
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _playerAttack() {
    if (_combatEnded || !_playerTurn) return;

    // Roll dice for attack damage (2d6 + attack power for more variance)
    final attackRoll = (1 + _random.nextInt(6)) + (1 + _random.nextInt(6));
    final baseAttack = widget.player.attackPower;
    final totalAttack = baseAttack + attackRoll;
    
    // Roll dice for enemy defense (1d6 + defense)
    final defenseRoll = 1 + _random.nextInt(6);
    final baseDefense = widget.enemy.defense;
    final totalDefense = baseDefense + defenseRoll;
    
    final damage = (totalAttack - totalDefense).clamp(1, totalAttack);
    
    // Check for critical hit (double 6s) or brilliant defense (double 6s)
    String attackMsg = '${widget.player.name} rolls ${attackRoll} + ${baseAttack} = ${totalAttack} attack!';
    String defenseMsg = '${widget.enemy.name} rolls ${defenseRoll} + ${baseDefense} = ${totalDefense} defense!';
    String damageMsg = '${widget.player.name} deals $damage damage!';
    
    if (attackRoll >= 11) {
      attackMsg += ' CRITICAL HIT!';
      damageMsg = '${widget.player.name} deals $damage damage! CRITICAL!';
    }
    if (defenseRoll >= 6 && totalDefense >= totalAttack) {
      defenseMsg += ' BRILLIANT DEFENSE!';
    }

    widget.enemy.takeDamage(damage);
    _addToLog(attackMsg);
    _addToLog(defenseMsg);
    _addToLog(damageMsg);

    if (widget.enemy.currentHp <= 0) {
      _addToLog('${widget.enemy.name} has been defeated!');
      _endCombat(playerWon: true);
    } else {
      _addToLog('${widget.enemy.name}: ${widget.enemy.currentHp}/${widget.enemy.maxHp} HP');
      _playerTurn = false;
      _enemyTurn();
    }
  }

  void _playerDefend() {
    if (_combatEnded || !_playerTurn) return;

    _addToLog('${widget.player.name} takes a defensive stance!');
    _playerTurn = false;
    _enemyTurn();
  }

  void _playerFlee() {
    if (_combatEnded) return;

    final fleeChance = 0.5 + (widget.player.currentStats.dexterity / 100.0);
    
    if (_random.nextDouble() < fleeChance) {
      _addToLog('${widget.player.name} successfully flees from combat!');
      _endCombat(playerWon: false);
    } else {
      _addToLog('${widget.player.name} failed to escape!');
      _playerTurn = false;
      _enemyTurn();
    }
  }

  void _enemyTurn() {
    if (_combatEnded) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _combatEnded) return;

      // Roll dice for enemy attack damage (2d6 + attack power for more variance)
      final attackRoll = (1 + _random.nextInt(6)) + (1 + _random.nextInt(6));
      final baseAttack = widget.enemy.attackPower;
      final totalAttack = baseAttack + attackRoll;
      
      // Roll dice for player defense (1d6 + defense)
      final defenseRoll = 1 + _random.nextInt(6);
      final baseDefense = widget.player.defense;
      final totalDefense = baseDefense + defenseRoll;
      
      final damage = (totalAttack - totalDefense).clamp(1, totalAttack);
      
      // Check for critical hit (double 6s) or brilliant defense (double 6s)
      String attackMsg = '${widget.enemy.name} rolls ${attackRoll} + ${baseAttack} = ${totalAttack} attack!';
      String defenseMsg = '${widget.player.name} rolls ${defenseRoll} + ${baseDefense} = ${totalDefense} defense!';
      String damageMsg = '${widget.enemy.name} deals $damage damage!';
      
      if (attackRoll >= 11) {
        attackMsg += ' CRITICAL HIT!';
        damageMsg = '${widget.enemy.name} deals $damage damage! CRITICAL!';
      }
      if (defenseRoll >= 6 && totalDefense >= totalAttack) {
        defenseMsg += ' BRILLIANT DEFENSE!';
      }

      widget.player.takeDamage(damage);
      _addToLog(attackMsg);
      _addToLog(defenseMsg);
      _addToLog(damageMsg);

      if (widget.player.currentHp <= 0) {
        _addToLog('${widget.player.name} has been defeated!');
        _endCombat(playerWon: false);
      } else {
        _addToLog('${widget.player.name}: ${widget.player.currentHp}/${widget.player.maxHp} HP');
        setState(() {
          _playerTurn = true;
        });
      }
    });
  }

  void _endCombat({required bool playerWon}) {
    setState(() {
      _combatEnded = true;
    });

    if (playerWon) {
      // Grant experience
      final expGain = 10 + (widget.enemy.level * 5);
      widget.player.experience += expGain;
      _addToLog('You gained $expGain experience!');
      
      // Grant money reward
      final moneyReward = _random.nextInt(10) + (widget.enemy.level * 3) + 5;
      widget.player.addMoney(moneyReward);
      _addToLog('You found $moneyReward silver coins!');
      
      // Check for item drop
      final itemDropChance = 0.3 + (widget.enemy.level * 0.05); // 30% base + 5% per level
      if (_random.nextDouble() < itemDropChance) {
        final droppedItem = ItemGenerator.generateRandomItem(
          _getRandomItemType(),
          rarity: _getRandomItemRarity(),
          isShopItem: false,
        );
        
        if (widget.player.addToInventory(droppedItem)) {
          _addToLog('${widget.enemy.name} dropped: ${droppedItem.name}!');
        } else {
          _addToLog('${widget.enemy.name} dropped an item, but your inventory is full!');
        }
      }
      
      // Check for level up
      if (widget.player.experience >= widget.player.experienceToNext) {
        _levelUp();
      }
    }

    // Auto-exit after a delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onCombatEnd(widget.player, playerWon);
      }
    });
  }

  void _levelUp() {
    widget.player.level++;
    widget.player.experience -= widget.player.experienceToNext;
    widget.player.experienceToNext = widget.player.level * 100;
    widget.player.upgradePoints += 5;
    
    // Increase base HP and MP
    widget.player.maxHp += 10;
    widget.player.maxMana += 5;
    widget.player.currentHp = widget.player.maxHp; // Full heal on level up
    widget.player.currentMana = widget.player.maxMana;
    
    _addToLog('LEVEL UP! You are now level ${widget.player.level}!');
    _addToLog('You gained 5 upgrade points and restored to full health!');
  }
  
  ItemType _getRandomItemType() {
    final itemTypes = [ItemType.weapon, ItemType.armor, ItemType.shield, ItemType.potion];
    return itemTypes[_random.nextInt(itemTypes.length)];
  }
  
  ItemRarity _getRandomItemRarity() {
    final rarityRoll = _random.nextDouble();
    if (rarityRoll < 0.6) return ItemRarity.common;        // 60%
    if (rarityRoll < 0.85) return ItemRarity.uncommon;     // 25%
    if (rarityRoll < 0.95) return ItemRarity.rare;        // 10%
    if (rarityRoll < 0.99) return ItemRarity.epic;        // 4%
    return ItemRarity.legendary;                           // 1%
  }

  bool _hasUsableCombatSpells() {
    return widget.player.knownSpells.any((spellId) {
      final spell = SpellBook.getSpellById(spellId);
      return spell != null && 
             spell.canCastInCombat && 
             widget.player.currentMana >= spell.manaCost;
    });
  }

  void _openSpellbook() async {
    final spell = await Navigator.of(context).push<Spell>(
      MaterialPageRoute(
        builder: (context) => SpellbookScreen(
          player: widget.player,
          castingContext: 'combat',
          onSpellCast: (spell) => Navigator.of(context).pop(spell),
        ),
      ),
    );

    if (spell != null && mounted) {
      _castSpell(spell);
    }
  }

  void _castSpell(Spell spell) {
    if (!_playerTurn || _combatEnded) return;
    
    final spellEffect = SpellService.castCombatSpell(spell, widget.player, target: widget.enemy);
    
    _addToLog(spellEffect.message);
    
    if (spellEffect.success) {
      // Handle damage
      if (spellEffect.damage != null) {
        _addToLog('${widget.enemy.name} takes ${spellEffect.damage} damage!');
        if (widget.enemy.currentHp <= 0) {
          _addToLog('${widget.enemy.name} is defeated!');
          _endCombat(playerWon: true);
          return;
        }
      }
      
      // Handle healing
      if (spellEffect.healing != null) {
        _addToLog('You are healed for ${spellEffect.healing} HP!');
      }
      
      // Handle buffs
      if (spellEffect.buffs != null) {
        _addToLog('You feel empowered by the spell\'s effects!');
        // TODO: Apply buffs to player temporarily
      }
    }
    
    // End player turn
    setState(() {
      _playerTurn = false;
    });
    
    // Start enemy turn after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_combatEnded) {
        _enemyTurn();
      }
    });
  }

  bool _hasUsableItems() {
    return widget.player.inventory.any((item) => 
      item.type == ItemType.potion || 
      item.type == ItemType.scroll
    );
  }

  void _useItem() async {
    final usableItems = widget.player.inventory
        .where((item) => item.type == ItemType.potion || item.type == ItemType.scroll)
        .toList();

    if (usableItems.isEmpty) return;

    final selectedItem = await showDialog<Item>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ItemSelectionDialog(
        items: usableItems,
        title: 'Use Item in Combat',
        emptyMessage: 'No usable items found.',
        onItemSelected: (item) => Navigator.of(context).pop(item),
      ),
    );

    if (selectedItem != null && mounted && !_combatEnded) {
      _consumeItem(selectedItem);
    }
  }

  void _consumeItem(Item item) {
    if (!_playerTurn || _combatEnded) return;

    String effectMessage = '';
    bool itemUsed = false;

    switch (item.type) {
      case ItemType.potion:
        effectMessage = _usePotionEffect(item);
        itemUsed = true;
        break;
      case ItemType.scroll:
        effectMessage = _useScrollEffect(item);
        itemUsed = true;
        break;
      default:
        effectMessage = '${item.displayName} cannot be used in combat.';
    }

    if (itemUsed) {
      // Remove item from inventory
      widget.player.removeFromInventory(item);
      
      // Add combat log message
      _addToLog('You use ${item.displayName}!');
      _addToLog(effectMessage);

      // Update UI to show damage effects
      setState(() {});

      // Check if enemy is defeated after damage effects
      if (widget.enemy.currentHp <= 0) {
        _addToLog('${widget.enemy.name} is defeated!');
        _endCombat(playerWon: true);
        return;
      }

      // End player turn
      setState(() {
        _playerTurn = false;
      });

      // Start enemy turn after delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_combatEnded) {
          _enemyTurn();
        }
      });
    } else {
      _addToLog(effectMessage);
    }
  }

  String _usePotionEffect(Item potion) {
    switch (potion.id) {
      case 'healing_potion_minor':
        final healAmount = 30;
        final oldHp = widget.player.currentHp;
        widget.player.currentHp = (widget.player.currentHp + healAmount).clamp(0, widget.player.maxHp);
        final actualHealing = widget.player.currentHp - oldHp;
        return 'You heal for $actualHealing HP!';
        
      case 'healing_potion_major':
        final healAmount = 60;
        final oldHp = widget.player.currentHp;
        widget.player.currentHp = (widget.player.currentHp + healAmount).clamp(0, widget.player.maxHp);
        final actualHealing = widget.player.currentHp - oldHp;
        return 'You heal for $actualHealing HP!';
        
      case 'mana_potion':
        final manaAmount = 40;
        final oldMana = widget.player.currentMana;
        widget.player.currentMana = (widget.player.currentMana + manaAmount).clamp(0, widget.player.maxMana);
        final actualMana = widget.player.currentMana - oldMana;
        return 'You restore $actualMana mana!';
        
      case 'strength_potion':
        return 'You feel stronger! (+3 STR for this battle)';
        // TODO: Implement temporary buffs
        
      default:
        return 'The potion has a mysterious effect...';
    }
  }

  String _useScrollEffect(Item scroll) {
    // Try to get spell ID from special effects first, then fall back to name parsing
    String spellId = '';
    
    if (scroll.specialEffects != null && scroll.specialEffects!['spell_id'] != null) {
      spellId = scroll.specialEffects!['spell_id'];
    } else {
      // Fall back to name parsing for older items
      if (scroll.name.contains('Magic Missile')) {
        spellId = 'magic_missile';
      } else if (scroll.name.contains('Fireball')) {
        spellId = 'fireball';
      } else if (scroll.name.contains('Cure Wounds')) {
        spellId = 'cure_wounds';
      } else if (scroll.name.contains('Ice Shard')) {
        spellId = 'ice_shard';
      } else if (scroll.name.contains('Bless')) {
        spellId = 'bless';
      } else if (scroll.name.contains('Identify')) {
        spellId = 'identify';
      } else if (scroll.name.contains('Light')) {
        spellId = 'light';
      }
    }

    final spell = SpellBook.getSpellById(spellId);
    if (spell == null) {
      return 'The scroll crumbles to dust with no effect. (Could not identify spell: $spellId from scroll: ${scroll.name})';
    }

    // Handle special spells that need different treatment
    if (spellId == 'identify') {
      return _handleIdentifyInCombat();
    } else if (spellId == 'light') {
      // Light is an exploration spell but can be used in combat
      final spellEffect = SpellService.castExplorationSpell(spell, widget.player);
      return spellEffect.message;
    }
    
    // Use scroll as if casting the spell, but no mana cost
    final spellEffect = SpellService.castCombatSpell(spell, widget.player, target: widget.enemy);
    
    if (spellEffect.success && spellEffect.damage != null) {
      // Log additional damage information for debugging
      return '${spellEffect.message} [Enemy HP: ${widget.enemy.currentHp}/${widget.enemy.maxHp}]';
    }
    
    return spellEffect.message;
  }

  String _handleIdentifyInCombat() {
    // Find unidentified items
    final unidentifiedItems = widget.player.inventory
        .where((item) => !item.identified)
        .toList();
    
    if (unidentifiedItems.isEmpty) {
      return 'You have no unidentified items to examine.';
    }
    
    // Show selection dialog for item to identify
    Future.delayed(Duration.zero, () async {
      final selectedItem = await showDialog<Item>(
        context: context,
        barrierDismissible: true,
        builder: (context) => ItemSelectionDialog(
          items: unidentifiedItems,
          title: 'Identify Which Item?',
          emptyMessage: 'No unidentified items found.',
          onItemSelected: (item) => Navigator.of(context).pop(item),
        ),
      );
      
      if (selectedItem != null && mounted) {
        final identifiedItem = _createIdentifiedItem(selectedItem);
        _replaceItemInInventory(selectedItem, identifiedItem);
        
        _addToLog('You identify the ${selectedItem.name}! Its magical properties are now revealed.');
        setState(() {}); // Refresh UI to show identified item
      }
    });
    
    return 'Choose an item to identify...';
  }
  
  Item _createIdentifiedItem(Item originalItem) {
    return Item(
      id: originalItem.id,
      name: originalItem.name,
      description: originalItem.description,
      type: originalItem.type,
      rarity: originalItem.rarity,
      value: originalItem.value,
      identified: true,
      statModifiers: originalItem.statModifiers,
      specialEffects: originalItem.specialEffects,
      stackSize: originalItem.stackSize,
    );
  }
  
  void _replaceItemInInventory(Item originalItem, Item newItem) {
    final itemIndex = widget.player.inventory.indexOf(originalItem);
    if (itemIndex >= 0) {
      widget.player.inventory[itemIndex] = newItem;
      
      // If the item was equipped, update equipment
      for (final slot in widget.player.equipment.keys) {
        if (widget.player.equipment[slot] == originalItem) {
          widget.player.equipment[slot] = newItem;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Combat: ${widget.player.name} vs ${widget.enemy.name}'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Combat status
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.player.name,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'HP: ${widget.player.currentHp}/${widget.player.maxHp}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'MP: ${widget.player.currentMana}/${widget.player.maxMana}',
                        style: TextStyle(
                          color: Colors.deepPurple.shade300,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'ATK: ${widget.player.attackPower} | DEF: ${widget.player.defense}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.enemy.name,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'HP: ${widget.enemy.currentHp}/${widget.enemy.maxHp}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'ATK: ${widget.enemy.attackPower} | DEF: ${widget.enemy.defense}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Combat log
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _combatLog.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _combatLog[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Combat actions
          if (!_combatEnded) Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_playerTurn)
                  const Text(
                    'Your Turn',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  )
                else
                  const Text(
                    'Enemy Turn...',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                const SizedBox(height: 12),
                if (_playerTurn) Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _playerAttack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Attack', style: TextStyle(fontFamily: 'monospace')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _playerDefend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Defend', style: TextStyle(fontFamily: 'monospace')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasUsableCombatSpells() ? _openSpellbook : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cast Spell', style: TextStyle(fontFamily: 'monospace')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasUsableItems() ? _useItem : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Use Item', style: TextStyle(fontFamily: 'monospace')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _playerFlee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Flee', style: TextStyle(fontFamily: 'monospace')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}