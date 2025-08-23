import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/town.dart';
import '../models/enums.dart';

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

  void _identifyItems() {
    widget.player.spendMoney(10);
    int identifiedCount = 0;
    
    for (final item in widget.player.inventory) {
      if (!item.identified) {
        // In a full implementation, you'd set item.identified = true
        identifiedCount++;
      }
    }
    
    widget.onPlayerUpdate(widget.player);
    _showServiceResult(identifiedCount > 0 
        ? 'Identified $identifiedCount items!' 
        : 'No unidentified items found.');
  }

  void _learnSpells() {
    widget.player.spendMoney(30);
    widget.player.knownSpells.add('Magic Missile'); // Example spell
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('You\'ve learned a new spell!');
  }

  void _enchantItems() {
    widget.player.spendMoney(75);
    widget.onPlayerUpdate(widget.player);
    _showServiceResult('Your equipment glows with magical energy!');
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