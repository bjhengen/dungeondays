import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/world.dart';
import '../models/enums.dart';
import '../models/spell.dart';
import '../models/item.dart';
import '../models/town.dart';
import '../widgets/ascii_display.dart';
import '../widgets/player_stats_bar.dart';
import '../services/save_service.dart';
import '../services/world_generator.dart';
import '../services/spell_service.dart';
import '../widgets/item_selection_dialog.dart';
import '../services/npc_movement_service.dart';
import 'town_view_screen.dart';
import 'inventory_screen.dart';
import 'spellbook_screen.dart';

class GameScreen extends StatefulWidget {
  final Player player;
  final GameWorld? world;

  const GameScreen({super.key, required this.player, this.world});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Player _player;
  late GameWorld _world;
  late GameTime _gameTime;
  
  // Simple test world grid
  List<List<String>> _worldGrid = [];
  int _playerX = 10;
  int _playerY = 10;
  
  Map<String, Color> get _colorMap {
    if (_gameTime.isDaylight) {
      return {
        '#': Colors.grey.shade800,        // walls/borders
        '.': Colors.brown.shade600,       // ground/floor
        '~': Colors.blue.shade700,        // water
        '^': Colors.green.shade700,       // forests
        'M': Colors.grey.shade700,        // mountains
        'C': Colors.orange.shade700,      // capital city
        'T': Colors.orange.shade600,      // major cities
        't': Colors.amber.shade700,       // towns
        'v': Colors.green.shade600,       // villages
        'D': Colors.red.shade700,         // dungeons
        '+': Colors.amber.shade700,       // doors
      };
    } else {
      return {
        '#': Colors.grey,           // walls/borders
        '.': Colors.brown,          // ground/floor
        '~': Colors.blue,           // water
        '^': Colors.green,          // forests
        'M': Colors.grey,           // mountains
        'C': Colors.yellow,         // capital city
        'T': Colors.orange,         // major cities
        't': Colors.amber,          // towns
        'v': Colors.lightGreen,     // villages
        'D': Colors.red,            // dungeons
        '+': Colors.amber,          // doors
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _initializeWorld();
  }

  void _initializeWorld() {
    if (widget.world != null) {
      _world = widget.world!;
      _gameTime = _world.gameTime;
      _playerX = _player.worldX;
      _playerY = _player.worldY;
    } else {
      final seed = DateTime.now().millisecondsSinceEpoch;
      final generator = WorldGenerator(seed);
      _world = generator.generateWorld('world_1', seed);
      _gameTime = _world.gameTime;
      
      // Set starting position in the starting village
      final startingVillage = _world.locations['starting_village'];
      if (startingVillage != null) {
        _playerX = startingVillage.worldX;
        _playerY = startingVillage.worldY;
        _player.worldX = _playerX;
        _player.worldY = _playerY;
        _player.currentLocation = startingVillage.name;
        
        // Auto-enter the starting village after a brief delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _enterTown(startingVillage);
            }
          });
        });
      }
    }
    
    // Generate the world grid
    final generator = WorldGenerator(_world.seed);
    _worldGrid = generator.generateWorldGrid();
    
    // Add location markers to the grid
    for (final location in _world.locations.values) {
      if (location.worldX >= 0 && location.worldX < _worldGrid[0].length &&
          location.worldY >= 0 && location.worldY < _worldGrid.length) {
        switch (location.type) {
          case 'capital':
            _worldGrid[location.worldY][location.worldX] = 'C';
            break;
          case 'city':
            _worldGrid[location.worldY][location.worldX] = 'T';
            break;
          case 'town':
            _worldGrid[location.worldY][location.worldX] = 't';
            break;
          case 'village':
            _worldGrid[location.worldY][location.worldX] = 'v';
            break;
          case 'dungeon':
            _worldGrid[location.worldY][location.worldX] = 'D';
            break;
        }
      }
    }
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
    if (newX >= 0 && newX < _worldGrid[0].length && 
        newY >= 0 && newY < _worldGrid.length &&
        _worldGrid[newY][newX] != '#') {
      setState(() {
        _playerX = newX;
        _playerY = newY;
        _player.worldX = newX;
        _player.worldY = newY;
      });
      
      // Check if player entered a settlement
      _checkLocationEntry(newX, newY);
      
      _advanceTurn();
    }
  }

  void _checkLocationEntry(int x, int y) {
    // Find location at current position
    try {
      final location = _world.locations.values.firstWhere(
        (loc) => loc.worldX == x && loc.worldY == y,
      );
      
      if (location.name != _player.currentLocation) {
        _player.currentLocation = location.name;
        _enterTown(location);
      }
    } catch (e) {
      // Player is not on a location, just in wilderness
      if (_player.currentLocation != 'Wilderness') {
        _player.currentLocation = 'Wilderness';
      }
    }
  }

  void _enterTown(Location location) {
    final townLayout = _world.getTownLayout(location.id);
    if (townLayout != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TownViewScreen(
            player: _player,
            townLayout: townLayout,
            gameTime: _gameTime,
            onPlayerUpdate: (updatedPlayer) {
              setState(() {
                _player = updatedPlayer;
              });
            },
            onExitTown: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      // Fallback to old dialog system if no town layout
      _showLocationDialog(location);
    }
  }

  void _showLocationDialog(Location location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Welcome to ${location.name}',
            style: const TextStyle(color: Colors.amber),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.description,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              if (location.hasInn) 
                _buildLocationOption('Visit Inn', () {
                  Navigator.of(context).pop();
                  _visitInn(location);
                }),
              if (location.hasBank) 
                _buildLocationOption('Visit Bank', () {
                  Navigator.of(context).pop();
                  _visitBank(location);
                }),
              if (location.availableGuilds.isNotEmpty)
                _buildLocationOption('Visit Guilds', () {
                  Navigator.of(context).pop();
                  _visitGuilds(location);
                }),
              _buildLocationOption('Explore Town', () {
                Navigator.of(context).pop();
                _exploreTown(location);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationOption(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  void _visitInn(Location location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('The Cozy Inn', style: TextStyle(color: Colors.amber)),
          content: const Text(
            'Welcome to our humble inn! We offer rooms and meals.',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restAtInn();
              },
              child: const Text('Rest (10 silver)', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Leave', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _visitBank(Location location) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banking system coming soon!')),
    );
  }

  void _visitGuilds(Location location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Available Guilds', style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: location.availableGuilds.map((guild) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _visitGuild(guild);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      _getGuildDisplayName(guild),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _visitGuild(GuildType guildType) {
    final guildName = _getGuildDisplayName(guildType);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(guildName, style: const TextStyle(color: Colors.amber)),
          content: Text(
            'Welcome to the $guildName! Services and quests coming soon.',
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
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

  void _exploreTown(Location location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You explore ${location.name}. Nothing of interest right now.')),
    );
  }

  void _restAtInn() {
    if (_player.canAfford(10)) {
      _player.spendMoney(10);
      _player.currentHp = _player.maxHp;
      _player.currentMana = _player.maxMana;
      _player.hunger = _player.maxHunger;
      
      // Advance 8 hours
      for (int i = 0; i < 48; i++) { // 48 turns = 8 hours
        _gameTime.advanceTurn();
      }
      
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You rest at the inn and feel refreshed!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have enough money to rest here.')),
      );
    }
  }

  String _getGuildDisplayName(GuildType guild) {
    switch (guild) {
      case GuildType.thieves: return 'Thieves Guild';
      case GuildType.blacksmiths: return 'Blacksmith Shop';
      case GuildType.mages: return 'Mages Guild';
      case GuildType.warriors: return 'Warriors Guild';
      case GuildType.paladins: return 'Paladin Order';
      case GuildType.clerics: return 'Temple';
      case GuildType.merchants: return 'Merchant Hall';
      case GuildType.alchemists: return 'Alchemist Shop';
    }
  }

  void _advanceTurn() {
    _gameTime.advanceTurn();
    
    // Process NPC movement and respawning for all towns
    final townLayouts = _world.locations.values
        .map((location) => _world.getTownLayout(location.id))
        .where((layout) => layout != null)
        .cast<TownLayout>()
        .toList();
    
    NPCMovementService.processTurn(_gameTime, townLayouts, _player);
    
    // Reduce hunger slightly each turn
    if (_player.hunger > 0) {
      _player.hunger = (_player.hunger - 1).clamp(0, _player.maxHunger);
    } else {
      // When hunger is 0, start damaging health
      _player.currentHp = (_player.currentHp - 2).clamp(0, _player.maxHp);
      if (_player.currentHp == 0) {
        _showDeathDialog();
        return;
      }
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            PlayerStatsBar(player: _player),
            GameUI(
              playerName: _player.name,
              level: _player.level,
              hp: _player.currentHp,
              maxHp: _player.maxHp,
              mana: _player.currentMana,
              maxMana: _player.maxMana,
              hunger: _player.hunger,
              maxHunger: _player.maxHunger,
              timeString: _gameTime.timeString,
              dateString: _gameTime.dateString,
              weather: _gameTime.weather.name,
              location: _player.currentLocation,
              silverCoins: _player.silverCoins,
              goldCoins: _player.goldCoins,
              onMenuPressed: _showGameMenu,
              onInventoryPressed: _showInventory,
              onSpellbookPressed: _showSpellbook,
              onMapPressed: _showMap,
            ),
            Expanded(
              child: InteractiveViewer(
                constrained: false,
                child: Center(
                  child: ASCIIDisplay(
                    grid: _worldGrid,
                    playerX: _playerX,
                    playerY: _playerY,
                    visibilityRange: _gameTime.getVisibilityRange(visionBonus: _player.visionBonus),
                    colorMap: _colorMap,
                    backgroundColor: _gameTime.isDaylight ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Rest', _rest),
              _buildActionButton('Search', _search),
              _buildActionButton('Wait', _wait),
            ],
          ),
        ],
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

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  void _rest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Rest', style: TextStyle(color: Colors.amber)),
          content: const Text(
            'How long would you like to rest?',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performRest(1);
              },
              child: const Text('1 Hour', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performRest(8);
              },
              child: const Text('8 Hours', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _performRest(int hours) {
    // Advance time
    for (int i = 0; i < hours * 6; i++) { // 6 turns per hour
      _gameTime.advanceTurn();
    }
    
    // Restore HP and MP
    _player.currentHp = (_player.currentHp + (hours * 10)).clamp(0, _player.maxHp);
    _player.currentMana = (_player.currentMana + (hours * 15)).clamp(0, _player.maxMana);
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rested for $hours hour${hours > 1 ? 's' : ''}')),
    );
  }

  void _search() {
    _advanceTurn();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You search the area but find nothing of interest.')),
    );
  }

  void _wait() {
    _advanceTurn();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You wait for a moment.')),
    );
  }

  void _showGameMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Game Menu', style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuOption('Save Game', () {
                Navigator.of(context).pop();
                _showSaveDialog();
              }),
              _buildMenuOption('Return to Main Menu', () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSaveDialog() async {
    final slotInfo = await SaveService.getSaveSlotInfo();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Save Game', style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose save slot:',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              for (int i = 1; i <= 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saveGame(i);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        foregroundColor: Colors.black,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Slot $i',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              slotInfo[i] ?? 'Empty',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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

  Future<void> _saveGame(int slotNumber) async {
    final success = await SaveService.saveGame(_player, _world, slotNumber);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'Game saved to slot $slotNumber'
              : 'Failed to save game',
          ),
        ),
      );
    }
  }

  void _showInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryScreen(
          player: _player,
          onPlayerUpdate: (updatedPlayer) {
            setState(() {
              _player = updatedPlayer;
            });
          },
        ),
      ),
    );
  }

  void _showSpellbook() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellbookScreen(
          player: _player,
          castingContext: 'exploration',
          onSpellCast: (spell) => _castExplorationSpell(spell),
          onPlayerUpdate: (updatedPlayer) {
            setState(() {
              _player = updatedPlayer;
            });
          },
        ),
      ),
    );
  }

  void _castExplorationSpell(Spell spell, {Item? targetItem}) async {
    final spellEffect = SpellService.castExplorationSpell(spell, _player, targetItem: targetItem);
    
    // Special handling for identify spell
    if (spellEffect.message == 'SELECT_ITEM_TO_IDENTIFY') {
      final unidentifiedItems = _player.inventory
          .where((item) => !item.identified)
          .toList();
      
      if (unidentifiedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'You have no unidentified items to examine.',
              style: TextStyle(fontFamily: 'monospace'),
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
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
        // Cast identify again with the selected item
        _castExplorationSpell(spell, targetItem: selectedItem);
      }
      return;
    }
    
    // Show spell effect message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          spellEffect.message,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: spellEffect.success ? Colors.deepPurple.shade800 : Colors.red.shade800,
        duration: const Duration(seconds: 3),
      ),
    );
    
    if (spellEffect.success) {
      // Handle healing
      if (spellEffect.healing != null) {
        setState(() {
          // Player already updated in spell service
        });
      }
      
      // Handle buffs (would need proper buff system)
      if (spellEffect.buffs != null) {
        // For now, just show the message
        // TODO: Implement temporary buff system
      }
      
      // Advance time for exploration spells (advance by 3 turns = 30 minutes)
      for (int i = 0; i < 3; i++) {
        _gameTime.advanceTurn();
      }
      setState(() {
        // Refresh UI after spell casting
      });
    }
  }

  void _showMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map system not implemented yet')),
    );
  }

  Widget _buildMenuOption(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeathDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Death',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You have died from starvation. Your adventure ends here.',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Main Menu', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }
}