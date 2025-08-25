import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/town.dart';
import '../models/enums.dart';
import '../models/spell.dart';
import '../models/item.dart';
import '../models/stats.dart';
import '../services/spell_service.dart';
import '../widgets/item_selection_dialog.dart';

class GuildScreen extends StatefulWidget {
  final Player player;
  final Building building;
  final Function(Player) onPlayerUpdate;

  const GuildScreen({
    super.key,
    required this.player,
    required this.building,
    required this.onPlayerUpdate,
  });

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  @override
  Widget build(BuildContext context) {
    final guildType = widget.building.guildType;
    final guildName = _getGuildDisplayName(guildType);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(guildName),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guild info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guildName,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGuildDescription(guildType),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reputation: ${widget.player.guildReputation[guildType] ?? 0}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Services
            const Text(
              'Available Services:',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            
            ..._buildGuildServices(guildType),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGuildServices(GuildType? guildType) {
    if (guildType == null) return [];
    
    final services = <Widget>[];
    
    switch (guildType) {
      case GuildType.blacksmiths:
        services.addAll([
          _buildServiceTile(
            'Repair Equipment',
            'Restore your gear to full durability',
            15,
            () => _repairEquipment(),
          ),
          _buildServiceTile(
            'Upgrade Weapon',
            'Enhance your weapon\'s power',
            50,
            () => _upgradeWeapon(),
          ),
          _buildServiceTile(
            'Learn Smithing',
            'Improve your crafting skills',
            25,
            () => _learnSkill('smithing'),
          ),
        ]);
        break;
        
      case GuildType.mages:
        services.addAll([
          _buildServiceTile(
            'Identify Items',
            'Reveal the properties of unknown items',
            10,
            () => _identifyItems(),
          ),
          _buildServiceTile(
            'Learn Spells',
            'Study new magical incantations',
            30,
            () => _learnSpells(),
          ),
          _buildServiceTile(
            'Enchant Items',
            'Add magical properties to equipment',
            75,
            () => _enchantItems(),
          ),
        ]);
        break;
        
      case GuildType.thieves:
        services.addAll([
          _buildServiceTile(
            'Fence Goods',
            'Sell items at better prices',
            5,
            () => _fenceGoods(),
          ),
          _buildServiceTile(
            'Learn Stealth',
            'Improve your sneaking abilities',
            20,
            () => _learnSkill('stealth'),
          ),
          _buildServiceTile(
            'Lockpicking Training',
            'Master the art of opening locks',
            35,
            () => _learnSkill('lockpicking'),
          ),
        ]);
        break;
        
      case GuildType.clerics:
        services.addAll([
          _buildServiceTile(
            'Heal Wounds',
            'Restore health and cure ailments',
            8,
            () => _healWounds(),
          ),
          _buildServiceTile(
            'Bless Equipment',
            'Grant divine protection to your gear',
            25,
            () => _blessEquipment(),
          ),
          _buildServiceTile(
            'Remove Curse',
            'Cleanse cursed items and effects',
            40,
            () => _removeCurse(),
          ),
        ]);
        break;
        
      case GuildType.warriors:
        services.addAll([
          _buildServiceTile(
            'Combat Training',
            'Improve your fighting prowess',
            20,
            () => _combatTraining(),
          ),
          _buildServiceTile(
            'Weapon Mastery',
            'Specialize in weapon types',
            45,
            () => _weaponMastery(),
          ),
        ]);
        break;
        
      case GuildType.paladins:
        services.addAll([
          _buildServiceTile(
            'Holy Training',
            'Learn divine combat techniques',
            30,
            () => _holyTraining(),
          ),
          _buildServiceTile(
            'Consecrate Weapon',
            'Imbue weapon with holy power',
            60,
            () => _consecrateWeapon(),
          ),
        ]);
        break;
        
      default:
        services.add(
          _buildServiceTile(
            'Training',
            'Basic guild training',
            15,
            () => _basicTraining(),
          ),
        );
    }
    
    return services;
  }

  Widget _buildServiceTile(String title, String description, int cost, VoidCallback onPressed) {
    final canAfford = widget.player.canAfford(cost);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: canAfford ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? Colors.amber.shade800 : Colors.grey.shade800,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Text(
                  '${cost}s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: canAfford ? Colors.black : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _repairEquipment() {
    widget.player.spendMoney(15);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your equipment has been fully repaired!');
  }

  void _upgradeWeapon() {
    final weapon = widget.player.equipment['weapon'];
    if (weapon != null) {
      widget.player.spendMoney(50);
      // In a full implementation, you'd modify weapon stats
      widget.onPlayerUpdate(widget.player);
      _showServiceResult('Your ${weapon.name} has been upgraded!');
    } else {
      _showServiceResult('You need to equip a weapon first.');
    }
  }

  void _learnSkill(String skillName) {
    widget.player.spendMoney(skillName == 'smithing' ? 25 : skillName == 'stealth' ? 20 : 35);
    widget.player.skills[skillName] = (widget.player.skills[skillName] ?? 0) + 1;
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your $skillName skill has improved!');
  }

  void _identifyItems() async {
    final unidentifiedItems = widget.player.inventory
        .where((item) => !item.identified)
        .toList();
    
    if (unidentifiedItems.isEmpty) {
      _showServiceResult('No unidentified items found.');
      return;
    }

    final selectedItem = await showDialog<Item>(
      context: context,
      builder: (context) => ItemSelectionDialog(
        items: unidentifiedItems,
        title: 'Select Item to Identify',
        emptyMessage: 'No unidentified items found.',
        onItemSelected: (item) => Navigator.of(context).pop(item),
      ),
    );

    if (selectedItem != null) {
      widget.player.spendMoney(10);
      
      // Create identified version of the item
      final identifiedItem = Item(
        id: selectedItem.id,
        name: selectedItem.name,
        description: selectedItem.description,
        type: selectedItem.type,
        rarity: selectedItem.rarity,
        value: selectedItem.value,
        identified: true, // Mark as identified
        statModifiers: selectedItem.statModifiers,
        specialEffects: selectedItem.specialEffects,
        stackSize: selectedItem.stackSize,
      );
      
      // Replace the item in player's inventory
      final itemIndex = widget.player.inventory.indexOf(selectedItem);
      if (itemIndex >= 0) {
        widget.player.inventory[itemIndex] = identifiedItem;
        
        // If the item was equipped, update equipment
        for (final slot in widget.player.equipment.keys) {
          if (widget.player.equipment[slot] == selectedItem) {
            widget.player.equipment[slot] = identifiedItem;
            break;
          }
        }
      }
      
      widget.onPlayerUpdate(widget.player);
      
      // Show identification results for the identified item
      _showIdentificationResults(identifiedItem);
    }
  }

  void _showIdentificationResults(Item item) {
    String itemDetails = 'Item: ${item.displayName}\n';
    itemDetails += 'Type: ${item.type.name.toUpperCase()}\n';
    itemDetails += 'Rarity: ${item.rarity.name.toUpperCase()}\n';
    itemDetails += 'Value: ${item.value} silver\n';
    
    if (item.statModifiers != null) {
      final stats = item.statModifiers!;
      itemDetails += '\nStat Bonuses:\n';
      if (stats.strength > 0) itemDetails += '+${stats.strength} Strength\n';
      if (stats.dexterity > 0) itemDetails += '+${stats.dexterity} Dexterity\n';
      if (stats.intelligence > 0) itemDetails += '+${stats.intelligence} Intelligence\n';
      if (stats.wisdom > 0) itemDetails += '+${stats.wisdom} Wisdom\n';
      if (stats.constitution > 0) itemDetails += '+${stats.constitution} Constitution\n';
      if (stats.charisma > 0) itemDetails += '+${stats.charisma} Charisma\n';
    }
    
    if (item.specialEffects != null && item.specialEffects!.isNotEmpty) {
      itemDetails += '\nSpecial Properties:\n';
      item.specialEffects!.forEach((key, value) {
        itemDetails += '$key: $value\n';
      });
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Item Identified!',
          style: TextStyle(
            color: _getRarityColor(item.rarity),
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          itemDetails,
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
      ),
    );
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

  void _learnSpells() async {
    final availableSpells = _getAvailableSpellsForLearning();
    
    if (availableSpells.isEmpty) {
      _showServiceResult('You have already learned all spells available to your class and level.');
      return;
    }

    final selectedSpell = await showDialog<Spell>(
      context: context,
      builder: (context) => _buildSpellLearningDialog(availableSpells),
    );

    if (selectedSpell != null) {
      final cost = SpellService.getSpellLearningCost(selectedSpell);
      if (widget.player.totalMoney >= cost) {
        widget.player.spendMoney(cost);
        widget.player.knownSpells.add(selectedSpell.id);
        
        // Increase spell school level
        final currentLevel = widget.player.spellSchoolLevels[selectedSpell.school] ?? 0;
        widget.player.spellSchoolLevels[selectedSpell.school] = currentLevel + 1;
        
        widget.onPlayerUpdate(widget.player);
        _showServiceResult('You\'ve learned ${selectedSpell.name}!');
      } else {
        _showServiceResult('You don\'t have enough money to learn that spell. Cost: ${cost} silver');
      }
    }
  }

  List<Spell> _getAvailableSpellsForLearning() {
    return SpellBook.allSpells.where((spell) {
      // Not already known
      if (widget.player.knownSpells.contains(spell.id)) return false;
      
      // Can be learned by this class
      if (!SpellService.canLearnSpell(spell, widget.player)) return false;
      
      // Available at mage guild (all spells for now, could be restricted)
      return true;
    }).toList()..sort((a, b) => a.level.compareTo(b.level));
  }

  Widget _buildSpellLearningDialog(List<Spell> spells) {
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
                color: Colors.deepPurple.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.deepPurple.shade300),
                  const SizedBox(width: 8),
                  const Text(
                    'Learn Spells',
                    style: TextStyle(
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
                itemCount: spells.length,
                itemBuilder: (context, index) {
                  final spell = spells[index];
                  final cost = SpellService.getSpellLearningCost(spell);
                  final canAfford = widget.player.totalMoney >= cost;
                  
                  return Card(
                    color: Colors.black87,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getSchoolIcon(spell.school),
                        color: _getSchoolColor(spell.school),
                      ),
                      title: Text(
                        spell.name,
                        style: TextStyle(
                          color: canAfford ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spell.description,
                            style: TextStyle(
                              color: canAfford ? Colors.white70 : Colors.grey.shade600,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Level ${spell.level} • ${spell.manaCost} MP',
                                style: TextStyle(
                                  color: _getSchoolColor(spell.school),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cost: ${cost}s',
                                style: TextStyle(
                                  color: canAfford ? Colors.amber : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: canAfford ? () => Navigator.of(context).pop(spell) : null,
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

  IconData _getSchoolIcon(SpellSchool school) {
    switch (school) {
      case SpellSchool.evocation:
        return Icons.flash_on;
      case SpellSchool.enchantment:
        return Icons.psychology;
      case SpellSchool.necromancy:
        return Icons.dark_mode;
      case SpellSchool.divination:
        return Icons.visibility;
      case SpellSchool.illusion:
        return Icons.blur_on;
      case SpellSchool.conjuration:
        return Icons.healing;
      case SpellSchool.alchemy:
        return Icons.science;
      case SpellSchool.elemental:
        return Icons.ac_unit;
    }
  }

  Color _getSchoolColor(SpellSchool school) {
    switch (school) {
      case SpellSchool.evocation:
        return Colors.orange;
      case SpellSchool.enchantment:
        return Colors.pink;
      case SpellSchool.necromancy:
        return Colors.purple.shade900;
      case SpellSchool.divination:
        return Colors.lightBlue;
      case SpellSchool.illusion:
        return Colors.indigo;
      case SpellSchool.conjuration:
        return Colors.green;
      case SpellSchool.alchemy:
        return Colors.amber;
      case SpellSchool.elemental:
        return Colors.cyan;
    }
  }

  void _enchantItems() async {
    // Check if player has enchantable items
    final enchantableItems = widget.player.inventory
        .where((item) => item.type == ItemType.weapon || 
                       item.type == ItemType.armor || 
                       item.type == ItemType.shield)
        .toList();
        
    if (enchantableItems.isEmpty) {
      _showServiceResult('You have no equipment that can be enchanted.');
      return;
    }
    
    // Let player select an item to enchant
    final selectedItem = await showDialog<Item>(
      context: context,
      builder: (context) => ItemSelectionDialog(
        items: enchantableItems,
        title: 'Select Item to Enchant',
        emptyMessage: 'No enchantable equipment found.',
        onItemSelected: (item) => Navigator.of(context).pop(item),
      ),
    );
    
    if (selectedItem != null) {
      if (!widget.player.canAfford(75)) {
        _showServiceResult('You need 75 gold to enchant an item.');
        return;
      }
      
      widget.player.spendMoney(75);
      _performEnchantment(selectedItem);
      widget.onPlayerUpdate(widget.player);
    }
  }

  void _performEnchantment(Item item) {
    final random = Random();
    
    // Generate a random enchantment based on item type
    Stats? bonusStats;
    String enchantmentName;
    String enchantmentDescription;
    
    switch (item.type) {
      case ItemType.weapon:
        // Weapon enchantments: damage, accuracy, special effects
        final enchantments = [
          ('Sharpness', Stats(strength: 3 + random.nextInt(5)), 'increases damage'),
          ('Lightning', Stats(strength: 2, dexterity: 2), 'crackles with electricity'),
          ('Frost', Stats(strength: 2, intelligence: 2), 'is covered in frost'),
          ('Vampiric', Stats(strength: 1, constitution: 3), 'drains life from enemies'),
        ];
        final chosen = enchantments[random.nextInt(enchantments.length)];
        enchantmentName = chosen.$1;
        bonusStats = chosen.$2;
        enchantmentDescription = chosen.$3;
        break;
        
      case ItemType.armor:
        // Armor enchantments: defense, resistance, utility
        final enchantments = [
          ('Protection', Stats(constitution: 3 + random.nextInt(5)), 'provides enhanced protection'),
          ('Resistance', Stats(constitution: 2, wisdom: 2), 'resists magical damage'),
          ('Agility', Stats(constitution: 2, dexterity: 2), 'enhances mobility'),
          ('Fortitude', Stats(constitution: 3, strength: 1), 'bolsters endurance'),
        ];
        final chosen = enchantments[random.nextInt(enchantments.length)];
        enchantmentName = chosen.$1;
        bonusStats = chosen.$2;
        enchantmentDescription = chosen.$3;
        break;
        
      case ItemType.shield:
        // Shield enchantments: defense, blocking, reflection
        final enchantments = [
          ('Warding', Stats(constitution: 4), 'deflects attacks'),
          ('Reflection', Stats(constitution: 2, intelligence: 2), 'reflects magical attacks'),
          ('Steadfast', Stats(constitution: 3, wisdom: 1), 'provides unwavering defense'),
        ];
        final chosen = enchantments[random.nextInt(enchantments.length)];
        enchantmentName = chosen.$1;
        bonusStats = chosen.$2;
        enchantmentDescription = chosen.$3;
        break;
        
      default:
        bonusStats = Stats(strength: 1, constitution: 1);
        enchantmentName = 'Minor';
        enchantmentDescription = 'glows faintly';
    }
    
    // Create enhanced item
    final enhancedStats = item.statModifiers != null 
        ? item.statModifiers!.add(bonusStats) 
        : bonusStats;
    
    final enhancedItem = Item(
      id: '${item.id}_enchanted_${random.nextInt(1000)}',
      name: '$enchantmentName ${item.name}',
      description: '${item.description} This item $enchantmentDescription.',
      type: item.type,
      rarity: item.rarity == ItemRarity.legendary ? ItemRarity.legendary : ItemRarity.values[item.rarity.index + 1], // Increase rarity
      value: item.value + 50 + (random.nextInt(50)), // Increase value
      identified: true, // Enchanted items are always identified
      statModifiers: enhancedStats,
      specialEffects: item.specialEffects,
      stackSize: item.stackSize,
    );
    
    // Replace the item in player's inventory
    final itemIndex = widget.player.inventory.indexOf(item);
    if (itemIndex >= 0) {
      widget.player.inventory[itemIndex] = enhancedItem;
      
      // If the item was equipped, update equipment
      for (final slot in widget.player.equipment.keys) {
        if (widget.player.equipment[slot] == item) {
          widget.player.equipment[slot] = enhancedItem;
          break;
        }
      }
    }
    
    _showServiceResult('Your ${item.displayName} has been successfully enchanted with $enchantmentName! It now ${enchantmentDescription}.');
  }

  void _fenceGoods() {
    widget.player.spendMoney(5);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('The guild will buy your goods at better prices.');
  }

  void _healWounds() {
    widget.player.spendMoney(8);
    widget.player.currentHp = widget.player.maxHp;
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your wounds have been completely healed!');
  }

  void _blessEquipment() {
    widget.player.spendMoney(25);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your equipment has been blessed with divine protection!');
  }

  void _removeCurse() {
    widget.player.spendMoney(40);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Any curses affecting you have been lifted!');
  }

  void _combatTraining() {
    widget.player.spendMoney(20);
    widget.player.baseStats.strength += 1;
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your combat prowess has improved! (+1 Strength)');
  }

  void _weaponMastery() {
    widget.player.spendMoney(45);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('You\'ve mastered advanced weapon techniques!');
  }

  void _holyTraining() {
    widget.player.spendMoney(30);
    widget.player.baseStats.wisdom += 1;
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your divine connection strengthens! (+1 Wisdom)');
  }

  void _consecrateWeapon() {
    final weapon = widget.player.equipment['weapon'];
    if (weapon != null) {
      widget.player.spendMoney(60);
      widget.onPlayerUpdate(widget.player);
      _showServiceResult('Your ${weapon.name} radiates holy power!');
    } else {
      _showServiceResult('You need to equip a weapon first.');
    }
  }

  void _basicTraining() {
    widget.player.spendMoney(15);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('You\'ve completed basic guild training!');
  }

  void _showServiceResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getGuildDisplayName(GuildType? guild) {
    if (guild == null) return 'Unknown Guild';
    
    switch (guild) {
      case GuildType.thieves: return 'Thieves Guild';
      case GuildType.blacksmiths: return 'Blacksmith Guild';
      case GuildType.mages: return 'Mages Guild';
      case GuildType.warriors: return 'Warriors Guild';
      case GuildType.paladins: return 'Paladin Order';
      case GuildType.clerics: return 'Temple of Healing';
      case GuildType.merchants: return 'Merchant Guild';
      case GuildType.alchemists: return 'Alchemist Guild';
    }
  }

  String _getGuildDescription(GuildType? guild) {
    if (guild == null) return 'A mysterious organization.';
    
    switch (guild) {
      case GuildType.thieves:
        return 'A secretive organization of rogues, spies, and information brokers.';
      case GuildType.blacksmiths:
        return 'Master craftsmen who forge weapons and armor of exceptional quality.';
      case GuildType.mages:
        return 'Scholars of the arcane arts, keepers of magical knowledge.';
      case GuildType.warriors:
        return 'Disciplined fighters dedicated to the mastery of combat.';
      case GuildType.paladins:
        return 'Holy warriors sworn to protect the innocent and fight evil.';
      case GuildType.clerics:
        return 'Servants of divine powers, healers and spiritual guides.';
      case GuildType.merchants:
        return 'Traders and businesspeople who control commerce and trade routes.';
      case GuildType.alchemists:
        return 'Students of transformation, brewing potions and transmuting materials.';
    }
  }
}