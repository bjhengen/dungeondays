import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/npc.dart';
import '../models/enums.dart';
import '../models/item.dart';
import '../utils/item_generator.dart';

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
                if (_playerTurn) Row(
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
          ),
        ],
      ),
    );
  }
}