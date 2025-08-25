import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/town.dart';
import '../models/npc.dart';
import '../models/enums.dart';
import '../models/world.dart';
import '../widgets/ascii_display.dart';
import '../widgets/player_stats_bar.dart';
import 'shop_screen.dart';
import 'guild_screen.dart';
import 'inventory_screen.dart';
import 'combat_screen.dart';
import 'upgrade_points_screen.dart';
import '../services/npc_movement_service.dart';

class TownViewScreen extends StatefulWidget {
  final Player player;
  final TownLayout townLayout;
  final GameTime gameTime;
  final Function(Player) onPlayerUpdate;
  final VoidCallback onExitTown;

  const TownViewScreen({
    super.key,
    required this.player,
    required this.townLayout,
    required this.gameTime,
    required this.onPlayerUpdate,
    required this.onExitTown,
  });

  @override
  State<TownViewScreen> createState() => _TownViewScreenState();
}

class _TownViewScreenState extends State<TownViewScreen> {
  late int _playerX;
  late int _playerY;
  
  Map<String, Color> get _townColorMap {
    if (widget.gameTime.isDaylight) {
      return {
        '#': Colors.grey.shade800,           // walls
        '.': Colors.brown.shade600,          // roads
        ' ': Colors.green.shade700,          // grass
        'I': Colors.blue.shade700,           // inn
        'B': Colors.yellow.shade700,         // bank
        'S': Colors.red.shade700,            // smithy
        'A': Colors.purple.shade700,         // alchemist
        'M': Colors.orange.shade700,         // market/merchant
        'G': Colors.cyan.shade700,           // guild
        'W': Colors.red.shade700,            // warriors guild
        'T': Colors.black54,                 // thieves guild
        'C': Colors.indigo.shade700,         // temple/clerics
        'P': Colors.blue.shade600,           // paladins
        'H': Colors.brown.shade600,          // house
        'o': Colors.amber.shade700,          // shop
        'D': Colors.orange.shade700,         // tavern
        'L': Colors.brown.shade600,          // stable
        'E': Colors.green.shade600,          // entrance
        'f': Colors.green.shade800,          // friendly NPC
        'n': Colors.blue.shade700,           // neutral NPC
        'h': Colors.red.shade800,            // hostile NPC
      };
    } else {
      return {
        '#': Colors.grey,           // walls
        '.': Colors.brown,          // roads
        ' ': Colors.green,          // grass
        'I': Colors.blue,           // inn
        'B': Colors.yellow,         // bank
        'S': Colors.red,            // smithy
        'A': Colors.purple,         // alchemist
        'M': Colors.orange,         // market/merchant
        'G': Colors.cyan,           // guild
        'W': Colors.redAccent,      // warriors guild
        'T': Colors.black54,        // thieves guild
        'C': Colors.white,          // temple/clerics
        'P': Colors.lightBlue,      // paladins
        'H': Colors.brown,          // house
        'o': Colors.amber,          // shop
        'D': Colors.deepOrange,     // tavern
        'L': Colors.brown,          // stable
        'E': Colors.green,          // entrance
        'f': Colors.green,          // friendly NPC
        'n': Colors.lightBlue,      // neutral NPC
        'h': Colors.red,            // hostile NPC
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _playerX = widget.townLayout.entranceX;
    _playerY = widget.townLayout.entranceY;
  }

  void _handleMovement(String direction) {
    int newX = _playerX;
    int newY = _playerY;
    
    switch (direction) {
      case 'up': newY--; break;
      case 'down': newY++; break;
      case 'left': newX--; break;
      case 'right': newX++; break;
      case 'up-left': newX--; newY--; break;
      case 'up-right': newX++; newY--; break;
      case 'down-left': newX--; newY++; break;
      case 'down-right': newX++; newY++; break;
    }
    
    // Check boundaries and walls
    if (newX >= 0 && newX < widget.townLayout.width && 
        newY >= 0 && newY < widget.townLayout.height &&
        widget.townLayout.grid[newY][newX] != '#') {
      
      setState(() {
        _playerX = newX;
        _playerY = newY;
      });
      
      _checkBuildingEntry(newX, newY);
      _checkExit(newX, newY);
      _processTurn();
    }
  }

  void _checkBuildingEntry(int x, int y) {
    final building = widget.townLayout.getBuildingAt(x, y);
    final npc = widget.townLayout.getNPCAt(x, y);
    
    if (building != null) {
      _showBuildingDialog(building);
    } else if (npc != null) {
      _showNPCDialog(npc);
    }
  }

  void _checkExit(int x, int y) {
    if (x == widget.townLayout.entranceX && y == widget.townLayout.entranceY) {
      _showExitDialog();
    }
  }

  void _processTurn() {
    // Advance game time (turns are handled at world level, but we can trigger NPC movement)
    NPCMovementService.processTurn(widget.gameTime, [widget.townLayout], widget.player);
    
    // Refresh the UI to show any NPC movements
    setState(() {});
  }

  void _showBuildingDialog(Building building) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            building.name,
            style: const TextStyle(color: Colors.amber),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                building.description,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              ..._getBuildingActions(building),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Leave', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getBuildingActions(Building building) {
    final actions = <Widget>[];
    
    switch (building.type) {
      case BuildingType.inn:
        actions.add(_buildActionButton('Rest (10 silver)', () {
          Navigator.of(context).pop();
          _restAtInn();
        }));
        actions.add(_buildActionButton('Eat Meal (3 silver)', () {
          Navigator.of(context).pop();
          _eatAtInn();
        }));
        actions.add(_buildActionButton('Buy Drinks (2 silver)', () {
          Navigator.of(context).pop();
          _drinkAtInn();
        }));
        break;
        
      case BuildingType.bank:
        actions.add(_buildActionButton('Banking Services', () {
          Navigator.of(context).pop();
          _showBankingDialog();
        }));
        break;
        
      case BuildingType.smithy:
      case BuildingType.alchemist:
      case BuildingType.shop:
      case BuildingType.market:
        actions.add(_buildActionButton('Browse Wares', () {
          Navigator.of(context).pop();
          _openShop(building);
        }));
        break;
        
      case BuildingType.guild:
      case BuildingType.temple:
        actions.add(_buildActionButton('Guild Services', () {
          Navigator.of(context).pop();
          _openGuild(building);
        }));
        break;
        
      case BuildingType.tavern:
        actions.add(_buildActionButton('Order Food & Drink', () {
          Navigator.of(context).pop();
          _showTavernDialog(building);
        }));
        break;
        
      default:
        actions.add(_buildActionButton('Look Around', () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nothing of interest here.')),
          );
        }));
    }
    
    return actions;
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  void _restAtInn() {
    if (widget.player.canAfford(10)) {
      widget.player.spendMoney(10);
      widget.player.currentHp = widget.player.maxHp;
      widget.player.currentMana = widget.player.maxMana;
      widget.player.hunger = widget.player.maxHunger;
      
      // Advance time to morning if sleeping at night
      if (!widget.gameTime.isDaylight) {
        // Advance to 8 AM
        widget.gameTime.advanceToMorning();
      }
      
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.gameTime.isDaylight 
              ? 'You rest at the inn and feel completely refreshed!'
              : 'You sleep through the night and wake up refreshed at dawn!'
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have enough money to rest here.')),
      );
    }
  }

  void _eatAtInn() {
    if (widget.player.canAfford(3)) {
      widget.player.spendMoney(3);
      widget.player.hunger = (widget.player.hunger + 30).clamp(0, widget.player.maxHunger);
      widget.player.currentHp = (widget.player.currentHp + 10).clamp(0, widget.player.maxHp);
      
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You enjoy a hearty meal at the inn!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have enough money for a meal.')),
      );
    }
  }

  void _drinkAtInn() {
    if (widget.player.canAfford(2)) {
      widget.player.spendMoney(2);
      widget.player.hunger = (widget.player.hunger + 10).clamp(0, widget.player.maxHunger);
      widget.player.currentMana = (widget.player.currentMana + 15).clamp(0, widget.player.maxMana);
      
      widget.onPlayerUpdate(widget.player);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You enjoy some refreshing drinks!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have enough money for drinks.')),
      );
    }
  }

  void _showBankingDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banking services coming soon!')),
    );
  }

  void _openShop(Building building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopScreen(
          player: widget.player,
          building: building,
          onPlayerUpdate: widget.onPlayerUpdate,
        ),
      ),
    );
  }

  void _openGuild(Building building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuildScreen(
          player: widget.player,
          building: building,
          onPlayerUpdate: widget.onPlayerUpdate,
        ),
      ),
    );
  }

  void _showTavernDialog(Building building) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${building.name} services coming soon!')),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Leave ${widget.townLayout.name}?',
            style: const TextStyle(color: Colors.amber),
          ),
          content: const Text(
            'Do you want to return to the world map?',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onExitTown();
              },
              child: const Text('Leave Town', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  String _getGuildDisplayName(GuildType guild) {
    switch (guild) {
      case GuildType.thieves: return 'Thieves Guild';
      case GuildType.blacksmiths: return 'Blacksmith Guild';
      case GuildType.mages: return 'Mages Guild';
      case GuildType.warriors: return 'Warriors Guild';
      case GuildType.paladins: return 'Paladin Order';
      case GuildType.clerics: return 'Temple';
      case GuildType.merchants: return 'Merchant Guild';
      case GuildType.alchemists: return 'Alchemist Guild';
    }
  }

  void _showInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryScreen(
          player: widget.player,
          onPlayerUpdate: (updatedPlayer) {
            setState(() {});
            widget.onPlayerUpdate(updatedPlayer);
          },
        ),
      ),
    );
  }

  void _showNPCDialog(NPC npc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            npc.name,
            style: TextStyle(
              color: _getNPCColor(npc.disposition),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                npc.description,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                '"${npc.dialogue}"',
                style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              if (npc.isAlive) ..._getNPCActions(npc),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Leave', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Color _getNPCColor(NPCDisposition disposition) {
    switch (disposition) {
      case NPCDisposition.friendly: return Colors.green;
      case NPCDisposition.neutral: return Colors.blue;
      case NPCDisposition.hostile: return Colors.red;
    }
  }

  List<Widget> _getNPCActions(NPC npc) {
    final actions = <Widget>[];
    
    switch (npc.disposition) {
      case NPCDisposition.friendly:
        actions.add(_buildActionButton('Talk', () {
          Navigator.of(context).pop();
          _talkToNPC(npc);
        }));
        break;
        
      case NPCDisposition.neutral:
        actions.add(_buildActionButton('Approach', () {
          Navigator.of(context).pop();
          _approachNPC(npc);
        }));
        break;
        
      case NPCDisposition.hostile:
        actions.add(_buildActionButton('Attack', () {
          Navigator.of(context).pop();
          _attackNPC(npc);
        }));
        actions.add(_buildActionButton('Try to Talk', () {
          Navigator.of(context).pop();
          _tryTalkToHostile(npc);
        }));
        break;
    }
    
    return actions;
  }

  void _talkToNPC(NPC npc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have a friendly chat with ${npc.name}.')),
    );
  }

  void _approachNPC(NPC npc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${npc.name} eyes you warily but doesn\'t seem threatening.')),
    );
  }

  void _attackNPC(NPC npc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CombatScreen(
          player: widget.player,
          enemy: npc,
          onCombatEnd: (updatedPlayer, enemyDefeated) {
            setState(() {});
            widget.onPlayerUpdate(updatedPlayer);
            Navigator.pop(context);
            
            if (enemyDefeated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You have defeated ${npc.name}!')),
              );
              // Mark NPC as dead using the movement service
              NPCMovementService.markNPCDead(npc, widget.gameTime);
              // Clear NPC from town grid
              widget.townLayout.grid[npc.townY][npc.townX] = ' ';
            }
          },
        ),
      ),
    );
  }

  void _tryTalkToHostile(NPC npc) {
    // Random chance of success based on charisma
    final success = Random().nextDouble() < (widget.player.currentStats.charisma / 50.0);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${npc.name} reluctantly agrees to talk instead of fight.')),
      );
      // Note: In a full implementation, you'd create a new NPC instance
      // For now, just show success message
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${npc.name} is not interested in talking! Combat begins!')),
      );
      _attackNPC(npc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Player stats bar
            PlayerStatsBar(player: widget.player),
            
            // Town header
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.townLayout.name,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _showInventory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Inventory',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.player.upgradePoints > 0)
                        ElevatedButton(
                          onPressed: _showUpgradePoints,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Upgrade (${widget.player.upgradePoints})',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _showLegend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Legend',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: widget.onExitTown,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Exit Town',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Town map
            Expanded(
              child: InteractiveViewer(
                constrained: false,
                child: Center(
                  child: ASCIIDisplay(
                    grid: widget.townLayout.grid,
                    playerX: _playerX,
                    playerY: _playerY,
                    visibilityRange: widget.gameTime.isDaylight ? 100 : 20, // Full visibility in daylight
                    colorMap: _townColorMap,
                    cellSize: 20.0, // Bigger cells for town view
                    backgroundColor: widget.gameTime.isDaylight ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            
            // Movement controls
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('↖', 'up-left'),
                      _buildDirectionButton('↑', 'up'),
                      _buildDirectionButton('↗', 'up-right'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('←', 'left'),
                      const SizedBox(width: 60),
                      _buildDirectionButton('→', 'right'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('↙', 'down-left'),
                      _buildDirectionButton('↓', 'down'),
                      _buildDirectionButton('↘', 'down-right'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String label, String direction) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleMovement(direction),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade800,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Town Legend',
            style: TextStyle(color: Colors.amber, fontFamily: 'monospace'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLegendItem('@', 'You (Player)', Colors.red),
                const SizedBox(height: 8),
                _buildLegendSection('Buildings:', [
                  ('I', 'Inn', Colors.blue.shade700),
                  ('B', 'Bank', Colors.yellow.shade700),
                  ('S', 'Smithy', Colors.red.shade700),
                  ('A', 'Alchemist', Colors.purple.shade700),
                  ('M', 'Market/Merchant', Colors.orange.shade700),
                  ('G', 'Guild', Colors.cyan.shade700),
                  ('C', 'Temple/Clerics', Colors.indigo.shade700),
                  ('T', 'Thieves Guild', Colors.black54),
                  ('P', 'Paladins', Colors.blue.shade600),
                  ('o', 'Shop', Colors.amber.shade700),
                  ('D', 'Tavern', Colors.orange.shade700),
                  ('H', 'House', Colors.brown.shade600),
                  ('L', 'Stable', Colors.brown.shade600),
                  ('E', 'Town Entrance', Colors.green.shade600),
                ]),
                const SizedBox(height: 8),
                _buildLegendSection('NPCs:', [
                  ('f', 'Friendly NPC', Colors.green.shade800),
                  ('n', 'Neutral NPC', Colors.blue.shade700),
                  ('h', 'Hostile NPC', Colors.red.shade800),
                ]),
                const SizedBox(height: 8),
                _buildLegendSection('Terrain:', [
                  ('#', 'Wall', Colors.grey.shade800),
                  ('.', 'Road', Colors.brown.shade600),
                  (' ', 'Grass/Open Area', Colors.green.shade700),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendSection(String title, List<(String, String, Color)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => _buildLegendItem(item.$1, item.$2, item.$3)),
      ],
    );
  }

  Widget _buildLegendItem(String symbol, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradePoints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpgradePointsScreen(
          player: widget.player,
          onPlayerUpdate: widget.onPlayerUpdate,
        ),
      ),
    ).then((_) => setState(() {}));
  }
}