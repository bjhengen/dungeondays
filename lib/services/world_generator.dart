import 'dart:math';
import '../models/world.dart';
import '../models/npc.dart';
import '../models/town.dart';
import '../models/enums.dart';
import 'town_generator.dart';

class WorldGenerator {
  static const int WORLD_SIZE = 50;
  final Random _random;
  
  WorldGenerator(int seed) : _random = Random(seed);
  
  GameWorld generateWorld(String worldId, int seed) {
    final gameTime = GameTime();
    
    // Generate locations
    final locations = <String, Location>{};
    final npcs = <String, NPC>{};
    final guilds = <String, Guild>{};
    
    _generateLocations(locations, npcs, guilds);
    
    // Generate town layouts
    final townLayouts = <String, TownLayout>{};
    _generateTownLayouts(locations, townLayouts);
    
    return GameWorld(
      id: worldId,
      seed: seed,
      locations: locations,
      npcs: npcs,
      guilds: guilds,
      townLayouts: townLayouts,
      gameTime: gameTime,
    );
  }
  
  void _generateLocations(Map<String, Location> locations, Map<String, NPC> npcs, Map<String, Guild> guilds) {
    // Generate capital city
    locations['capital'] = Location(
      id: 'capital',
      name: 'Goldenhaven',
      description: 'The grand capital city, center of commerce and power.',
      type: 'capital',
      worldX: WORLD_SIZE ~/ 2,
      worldY: WORLD_SIZE ~/ 2,
      availableGuilds: GuildType.values,
      hasBank: true,
      hasInn: true,
    );
    
    // Generate starting village (always created)
    locations['starting_village'] = Location(
      id: 'starting_village',
      name: 'Meadowbrook',
      description: 'A peaceful starting village with basic amenities.',
      type: 'village',
      worldX: 8,
      worldY: 8,
      availableGuilds: [GuildType.merchants, GuildType.blacksmiths],
      hasBank: false,
      hasInn: true,
    );
    
    // Generate major cities
    _generateMajorCities(locations);
    
    // Generate towns
    _generateTowns(locations);
    
    // Generate villages
    _generateVillages(locations);
    
    // Generate dungeons and special locations
    _generateDungeons(locations);
    
    // Generate NPCs for each location
    for (final location in locations.values) {
      _generateNPCsForLocation(location, npcs);
    }
    
    // Initialize guild data
    _initializeGuilds(guilds);
  }
  
  void _generateMajorCities(Map<String, Location> locations) {
    final cityNames = ['Ironforge', 'Silverport', 'Mystic Vale', 'Stormwind'];
    
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90.0 + 45.0) * (3.14159 / 180.0); // 45, 135, 225, 315 degrees
      final distance = WORLD_SIZE * 0.3;
      final centerX = WORLD_SIZE ~/ 2;
      final centerY = WORLD_SIZE ~/ 2;
      
      final x = centerX + (cos(angle) * distance).round();
      final y = centerY + (sin(angle) * distance).round();
      
      locations['city_$i'] = Location(
        id: 'city_$i',
        name: cityNames[i],
        description: 'A major commercial city with extensive trade networks.',
        type: 'city',
        worldX: x.clamp(5, WORLD_SIZE - 5),
        worldY: y.clamp(5, WORLD_SIZE - 5),
        availableGuilds: _getRandomGuilds(6, 8),
        hasBank: true,
        hasInn: true,
      );
    }
  }
  
  void _generateTowns(Map<String, Location> locations) {
    final townNames = [
      'Millhaven', 'Riverside', 'Oakenheart', 'Pinegrove', 
      'Stonefield', 'Brightwater', 'Thornwick', 'Goldleaf'
    ];
    
    for (int i = 0; i < 8; i++) {
      int x, y;
      int attempts = 0;
      
      do {
        x = 10 + _random.nextInt(WORLD_SIZE - 20);
        y = 10 + _random.nextInt(WORLD_SIZE - 20);
        attempts++;
      } while (_isTooCloseToExisting(x, y, locations.values) && attempts < 20);
      
      locations['town_$i'] = Location(
        id: 'town_$i',
        name: townNames[i % townNames.length],
        description: 'A bustling town with shops and services.',
        type: 'town',
        worldX: x,
        worldY: y,
        availableGuilds: _getRandomGuilds(3, 5),
        hasBank: _random.nextBool(),
        hasInn: true,
      );
    }
  }
  
  void _generateVillages(Map<String, Location> locations) {
    final villageNames = [
      'Peasant\'s Rest', 'Quiet Valley', 'Green Hills', 'Meadowbrook',
      'Willowdale', 'Fernwood', 'Cloverfield', 'Rosehip', 'Bramblewood',
      'Dewdrop', 'Sunnydale', 'Moonrise', 'Starfall', 'Mistwood'
    ];
    
    for (int i = 0; i < 12; i++) {
      int x, y;
      int attempts = 0;
      
      do {
        x = 5 + _random.nextInt(WORLD_SIZE - 10);
        y = 5 + _random.nextInt(WORLD_SIZE - 10);
        attempts++;
      } while (_isTooCloseToExisting(x, y, locations.values) && attempts < 20);
      
      locations['village_$i'] = Location(
        id: 'village_$i',
        name: villageNames[i % villageNames.length],
        description: 'A small village with basic amenities.',
        type: 'village',
        worldX: x,
        worldY: y,
        availableGuilds: _getRandomGuilds(1, 3),
        hasBank: false,
        hasInn: _random.nextDouble() < 0.7,
      );
    }
  }
  
  void _generateDungeons(Map<String, Location> locations) {
    final dungeonNames = [
      'Ancient Crypts', 'Shadowmere Caverns', 'Dragon\'s Lair', 'Forgotten Temple',
      'Crystal Mines', 'Goblin Warrens', 'Haunted Ruins', 'Deep Tunnels'
    ];
    
    for (int i = 0; i < 6; i++) {
      int x, y;
      int attempts = 0;
      
      do {
        x = 3 + _random.nextInt(WORLD_SIZE - 6);
        y = 3 + _random.nextInt(WORLD_SIZE - 6);
        attempts++;
      } while (_isTooCloseToExisting(x, y, locations.values, minDistance: 3) && attempts < 20);
      
      locations['dungeon_$i'] = Location(
        id: 'dungeon_$i',
        name: dungeonNames[i % dungeonNames.length],
        description: 'A dangerous dungeon filled with monsters and treasure.',
        type: 'dungeon',
        worldX: x,
        worldY: y,
        availableGuilds: [],
        hasBank: false,
        hasInn: false,
      );
    }
  }
  
  bool _isTooCloseToExisting(int x, int y, Iterable<Location> locations, {int minDistance = 5}) {
    for (final location in locations) {
      final distance = sqrt(pow(x - location.worldX, 2) + pow(y - location.worldY, 2));
      if (distance < minDistance) return true;
    }
    return false;
  }
  
  List<GuildType> _getRandomGuilds(int min, int max) {
    final count = min + _random.nextInt(max - min + 1);
    final availableGuilds = List<GuildType>.from(GuildType.values);
    availableGuilds.shuffle(_random);
    return availableGuilds.take(count).toList();
  }
  
  void _generateNPCsForLocation(Location location, Map<String, NPC> npcs) {
    int npcCount;
    switch (location.type) {
      case 'capital': npcCount = 15 + _random.nextInt(10); break;
      case 'city': npcCount = 8 + _random.nextInt(7); break;
      case 'town': npcCount = 4 + _random.nextInt(4); break;
      case 'village': npcCount = 2 + _random.nextInt(3); break;
      case 'dungeon': npcCount = 0; break;
      default: npcCount = 1;
    }
    
    final names = [
      'Alden', 'Beatrice', 'Cedric', 'Diana', 'Edmund', 'Fiona', 'Garrett', 'Helen',
      'Ivan', 'Jasmine', 'Kane', 'Luna', 'Marcus', 'Nora', 'Oscar', 'Petra',
      'Quinn', 'Rosa', 'Samuel', 'Tara', 'Ulric', 'Vera', 'Walter', 'Xara', 'Yuki', 'Zara'
    ];
    
    for (int i = 0; i < npcCount; i++) {
      final npcId = '${location.id}_npc_$i';
      final name = names[_random.nextInt(names.length)];
      
      GuildType? guildAffiliation;
      if (location.availableGuilds.isNotEmpty && _random.nextDouble() < 0.4) {
        guildAffiliation = location.availableGuilds[_random.nextInt(location.availableGuilds.length)];
      }
      
      npcs[npcId] = NPC(
        id: npcId,
        name: name,
        description: _generateNPCDescription(),
        disposition: _random.nextDouble() < 0.1 ? NPCDisposition.hostile : 
                    _random.nextDouble() < 0.3 ? NPCDisposition.neutral : NPCDisposition.friendly,
        dialogue: _generateNPCDialogue(),
        guildAffiliation: guildAffiliation,
        level: 1 + _random.nextInt(20),
        canBeCompanion: _random.nextDouble() < 0.1 && location.type != 'dungeon',
        currentLocation: location.id,
        worldX: location.worldX,
        worldY: location.worldY,
      );
    }
  }
  
  String _generateNPCDescription() {
    final descriptions = [
      'A friendly local merchant.',
      'A weathered traveler.',
      'A skilled craftsperson.',
      'A mysterious hooded figure.',
      'A cheerful innkeeper.',
      'A gruff blacksmith.',
      'A wise elder.',
      'A young apprentice.',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }
  
  String _generateNPCDialogue() {
    final dialogues = [
      'Welcome, traveler!',
      'The roads have been dangerous lately...',
      'Looking for work? Check with the local guild.',
      'Strange things have been happening in these parts.',
      'The weather has been quite unusual.',
      'Trade has been good this season.',
      'Have you heard the latest news?',
      'Be careful in the wilderness.',
    ];
    return dialogues[_random.nextInt(dialogues.length)];
  }
  
  void _initializeGuilds(Map<String, Guild> guilds) {
    final guildData = {
      GuildType.thieves: Guild(
        type: GuildType.thieves,
        name: 'Shadow Brotherhood',
        description: 'A secretive organization of rogues and spies.',
        services: ['Lockpicking Training', 'Stealth Lessons', 'Information Broker'],
      ),
      GuildType.mages: Guild(
        type: GuildType.mages,
        name: 'Circle of Arcane Arts',
        description: 'A prestigious academy for magical learning.',
        services: ['Spell Research', 'Enchantment Services', 'Magical Item Identification'],
      ),
      GuildType.warriors: Guild(
        type: GuildType.warriors,
        name: 'Order of the Steel Fist',
        description: 'A martial organization dedicated to combat excellence.',
        services: ['Combat Training', 'Weapon Mastery', 'Tactical Planning'],
      ),
      GuildType.clerics: Guild(
        type: GuildType.clerics,
        name: 'Temple of Divine Light',
        description: 'A holy order devoted to healing and protection.',
        services: ['Healing Services', 'Blessing Rituals', 'Undead Turning Training'],
      ),
      GuildType.paladins: Guild(
        type: GuildType.paladins,
        name: 'Knights of the Sacred Oath',
        description: 'Holy warriors bound by sacred vows.',
        services: ['Divine Magic Training', 'Oath Ceremonies', 'Monster Hunting'],
      ),
      GuildType.blacksmiths: Guild(
        type: GuildType.blacksmiths,
        name: 'Forgemasters Union',
        description: 'Master craftsmen specializing in metalwork.',
        services: ['Weapon Crafting', 'Armor Repair', 'Metal Enchantment'],
      ),
      GuildType.merchants: Guild(
        type: GuildType.merchants,
        name: 'Golden Scale Trading Company',
        description: 'Wealthy traders controlling major trade routes.',
        services: ['Bulk Trading', 'Transport Services', 'Market Information'],
      ),
      GuildType.alchemists: Guild(
        type: GuildType.alchemists,
        name: 'Society of Transmutation',
        description: 'Masters of potion-making and material transformation.',
        services: ['Potion Brewing', 'Material Transmutation', 'Chemical Analysis'],
      ),
    };
    
    for (final entry in guildData.entries) {
      guilds[entry.key.name] = entry.value;
    }
  }
  
  void _generateTownLayouts(Map<String, Location> locations, Map<String, TownLayout> townLayouts) {
    final townGenerator = TownGenerator(_random.nextInt(1000000));
    
    for (final location in locations.values) {
      // Only generate layouts for settlements (not dungeons or wilderness)
      if (['village', 'town', 'city', 'capital'].contains(location.type)) {
        townLayouts[location.id] = townGenerator.generateTownLayout(location);
      }
    }
  }
  
  List<List<String>> generateWorldGrid() {
    final grid = List.generate(WORLD_SIZE, (y) => 
      List.generate(WORLD_SIZE, (x) => '.')
    );
    
    // Add terrain features
    _addTerrain(grid);
    
    return grid;
  }
  
  void _addTerrain(List<List<String>> grid) {
    // Add water features
    _addRivers(grid);
    _addLakes(grid);
    
    // Add forests
    _addForests(grid);
    
    // Add mountains
    _addMountains(grid);
    
    // Add borders (walls around the edge)
    for (int i = 0; i < WORLD_SIZE; i++) {
      grid[0][i] = '#';
      grid[WORLD_SIZE - 1][i] = '#';
      grid[i][0] = '#';
      grid[i][WORLD_SIZE - 1] = '#';
    }
  }
  
  void _addRivers(List<List<String>> grid) {
    // Add a few rivers
    for (int r = 0; r < 2; r++) {
      int x = 5 + _random.nextInt(WORLD_SIZE - 10);
      int y = 1;
      
      while (y < WORLD_SIZE - 1) {
        grid[y][x] = '~';
        
        // River meanders
        final direction = _random.nextInt(3) - 1; // -1, 0, or 1
        x = (x + direction).clamp(1, WORLD_SIZE - 2);
        y++;
        
        // Sometimes branch
        if (_random.nextDouble() < 0.1 && y < WORLD_SIZE - 5) {
          int branchX = x + (_random.nextBool() ? 1 : -1);
          for (int by = y; by < y + 3 && by < WORLD_SIZE - 1; by++) {
            if (branchX >= 1 && branchX < WORLD_SIZE - 1) {
              grid[by][branchX] = '~';
            }
          }
        }
      }
    }
  }
  
  void _addLakes(List<List<String>> grid) {
    for (int l = 0; l < 3; l++) {
      final centerX = 5 + _random.nextInt(WORLD_SIZE - 10);
      final centerY = 5 + _random.nextInt(WORLD_SIZE - 10);
      final radius = 2 + _random.nextInt(3);
      
      for (int y = centerY - radius; y <= centerY + radius; y++) {
        for (int x = centerX - radius; x <= centerX + radius; x++) {
          if (x >= 1 && x < WORLD_SIZE - 1 && y >= 1 && y < WORLD_SIZE - 1) {
            final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
            if (distance <= radius) {
              grid[y][x] = '~';
            }
          }
        }
      }
    }
  }
  
  void _addForests(List<List<String>> grid) {
    // Add scattered forest areas
    for (int f = 0; f < 8; f++) {
      final centerX = 3 + _random.nextInt(WORLD_SIZE - 6);
      final centerY = 3 + _random.nextInt(WORLD_SIZE - 6);
      final radius = 3 + _random.nextInt(4);
      
      for (int y = centerY - radius; y <= centerY + radius; y++) {
        for (int x = centerX - radius; x <= centerX + radius; x++) {
          if (x >= 1 && x < WORLD_SIZE - 1 && y >= 1 && y < WORLD_SIZE - 1) {
            final distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
            if (distance <= radius && _random.nextDouble() < 0.7) {
              if (grid[y][x] == '.') { // Don't overwrite water
                grid[y][x] = '^';
              }
            }
          }
        }
      }
    }
  }
  
  void _addMountains(List<List<String>> grid) {
    // Add mountain ranges
    for (int m = 0; m < 3; m++) {
      final startX = 2 + _random.nextInt(WORLD_SIZE - 4);
      final startY = 2 + _random.nextInt(WORLD_SIZE - 4);
      final length = 5 + _random.nextInt(10);
      
      int x = startX;
      int y = startY;
      
      for (int i = 0; i < length && x >= 1 && x < WORLD_SIZE - 1 && y >= 1 && y < WORLD_SIZE - 1; i++) {
        if (grid[y][x] == '.') { // Don't overwrite water or forests
          grid[y][x] = 'M';
        }
        
        // Random walk for mountain range
        final direction = _random.nextInt(4);
        switch (direction) {
          case 0: x++; break;
          case 1: x--; break;
          case 2: y++; break;
          case 3: y--; break;
        }
      }
    }
  }
}