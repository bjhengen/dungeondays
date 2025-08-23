import 'dart:math';
import '../models/town.dart';
import '../models/enums.dart';
import '../models/world.dart';
import '../models/npc.dart';
import '../utils/item_generator.dart';

class TownGenerator {
  final Random _random;
  
  TownGenerator(int seed) : _random = Random(seed);
  
  TownLayout generateTownLayout(Location location) {
    int width, height;
    
    // Size based on settlement type
    switch (location.type) {
      case 'village':
        width = 15;
        height = 15;
        break;
      case 'town':
        width = 20;
        height = 20;
        break;
      case 'city':
        width = 25;
        height = 25;
        break;
      case 'capital':
        width = 30;
        height = 30;
        break;
      default:
        width = 15;
        height = 15;
    }
    
    // Create base grid with roads and grass
    final grid = _generateBaseGrid(width, height);
    
    // Generate buildings
    final buildings = <String, Building>{};
    _placeMandatoryBuildings(grid, buildings, location, width, height);
    _placeOptionalBuildings(grid, buildings, location, width, height);
    
    // Generate NPCs
    final npcs = <String, NPC>{};
    _generateTownNPCs(npcs, location, width, height);
    
    // Add building symbols to grid
    for (final building in buildings.values) {
      grid[building.townY][building.townX] = building.symbol;
    }
    
    // Add NPC symbols to grid
    for (final npc in npcs.values) {
      // Only place if there's no building at that position
      if (grid[npc.townY][npc.townX] == ' ' || grid[npc.townY][npc.townX] == '.') {
        grid[npc.townY][npc.townX] = _getNPCSymbol(npc);
      }
    }
    
    // Set entrance at bottom center
    final entranceX = width ~/ 2;
    final entranceY = height - 2;
    grid[entranceY][entranceX] = 'E';
    
    return TownLayout(
      locationId: location.id,
      name: location.name,
      width: width,
      height: height,
      grid: grid,
      buildings: buildings,
      npcs: npcs,
      entranceX: entranceX,
      entranceY: entranceY,
    );
  }
  
  List<List<String>> _generateBaseGrid(int width, int height) {
    final grid = List.generate(height, (y) => 
      List.generate(width, (x) {
        // Borders
        if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
          return '#';
        }
        
        // Main road (horizontal through middle)
        if (y == height ~/ 2) {
          return '.';
        }
        
        // Cross road (vertical through middle)
        if (x == width ~/ 2) {
          return '.';
        }
        
        // Side roads
        if (y == height ~/ 4 || y == 3 * height ~/ 4) {
          return '.';
        }
        if (x == width ~/ 4 || x == 3 * width ~/ 4) {
          return '.';
        }
        
        // Grass/open space
        return ' ';
      })
    );
    
    return grid;
  }
  
  void _placeMandatoryBuildings(
    List<List<String>> grid, 
    Map<String, Building> buildings, 
    Location location, 
    int width, 
    int height
  ) {
    // Always place inn if location has one
    if (location.hasInn) {
      final innPos = _findBuildingSpot(grid, width, height);
      buildings['inn'] = Building(
        id: 'inn_${location.id}',
        name: 'The Cozy Inn',
        description: 'A warm and welcoming inn for weary travelers.',
        type: BuildingType.inn,
        townX: innPos.$1,
        townY: innPos.$2,
        symbol: 'I',
        services: {'rest': 10, 'food': true},
      );
    }
    
    // Always place bank if location has one
    if (location.hasBank) {
      final bankPos = _findBuildingSpot(grid, width, height);
      buildings['bank'] = Building(
        id: 'bank_${location.id}',
        name: 'First National Bank',
        description: 'A secure place for your money.',
        type: BuildingType.bank,
        townX: bankPos.$1,
        townY: bankPos.$2,
        symbol: 'B',
        services: {'deposit': true, 'withdraw': true, 'loan': true},
      );
    }
    
    // Place guild buildings
    for (final guildType in location.availableGuilds) {
      final guildPos = _findBuildingSpot(grid, width, height);
      final guildInfo = _getGuildBuildingInfo(guildType);
      
      buildings['guild_${guildType.name}'] = Building(
        id: 'guild_${guildType.name}_${location.id}',
        name: guildInfo.$1,
        description: guildInfo.$2,
        type: guildInfo.$3,
        townX: guildPos.$1,
        townY: guildPos.$2,
        symbol: guildInfo.$4,
        guildType: guildType,
        services: _getGuildServices(guildType),
      );
    }
    
    // Ensure every settlement has healing available
    bool hasHealing = location.availableGuilds.contains(GuildType.clerics);
    if (!hasHealing) {
      final templePos = _findBuildingSpot(grid, width, height);
      buildings['temple'] = Building(
        id: 'temple_${location.id}',
        name: 'Local Temple',
        description: 'A small temple providing healing services.',
        type: BuildingType.temple,
        townX: templePos.$1,
        townY: templePos.$2,
        symbol: 'C',
        guildType: GuildType.clerics,
        services: {'heal': true, 'bless': true},
      );
    }
  }
  
  void _placeOptionalBuildings(
    List<List<String>> grid, 
    Map<String, Building> buildings, 
    Location location, 
    int width, 
    int height
  ) {
    int buildingCount;
    switch (location.type) {
      case 'village': buildingCount = 2 + _random.nextInt(3); break;
      case 'town': buildingCount = 4 + _random.nextInt(4); break;
      case 'city': buildingCount = 6 + _random.nextInt(6); break;
      case 'capital': buildingCount = 10 + _random.nextInt(8); break;
      default: buildingCount = 2;
    }
    
    final buildingTypes = [
      BuildingType.house, BuildingType.shop, BuildingType.tavern,
      BuildingType.market, BuildingType.stable, BuildingType.temple
    ];
    
    for (int i = 0; i < buildingCount; i++) {
      final pos = _findBuildingSpot(grid, width, height);
      if (pos.$1 == -1) break; // No more space
      
      final buildingType = buildingTypes[_random.nextInt(buildingTypes.length)];
      final buildingInfo = _getBuildingInfo(buildingType);
      
      buildings['building_$i'] = Building(
        id: 'building_${i}_${location.id}',
        name: buildingInfo.$1,
        description: buildingInfo.$2,
        type: buildingType,
        townX: pos.$1,
        townY: pos.$2,
        symbol: buildingInfo.$3,
        services: _getBuildingServices(buildingType),
      );
    }
  }
  
  (int, int) _findBuildingSpot(List<List<String>> grid, int width, int height) {
    final attempts = 100;
    for (int i = 0; i < attempts; i++) {
      final x = 2 + _random.nextInt(width - 4);
      final y = 2 + _random.nextInt(height - 4);
      
      // Check if spot is empty (grass)
      if (grid[y][x] == ' ') {
        // Check if adjacent to a road
        bool adjacentToRoad = false;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx;
            final ny = y + dy;
            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
              if (grid[ny][nx] == '.') {
                adjacentToRoad = true;
                break;
              }
            }
          }
          if (adjacentToRoad) break;
        }
        
        if (adjacentToRoad) {
          return (x, y);
        }
      }
    }
    return (-1, -1); // No suitable spot found
  }
  
  (String, String, BuildingType, String) _getGuildBuildingInfo(GuildType guildType) {
    switch (guildType) {
      case GuildType.blacksmiths:
        return ('Blacksmith Shop', 'A forge where weapons and armor are crafted.', BuildingType.smithy, 'S');
      case GuildType.alchemists:
        return ('Alchemist Shop', 'A shop filled with bubbling potions and reagents.', BuildingType.alchemist, 'A');
      case GuildType.merchants:
        return ('Merchant Hall', 'A trading post for goods from far and wide.', BuildingType.market, 'M');
      case GuildType.mages:
        return ('Mage Guild', 'A tower where magic is studied and taught.', BuildingType.guild, 'G');
      case GuildType.warriors:
        return ('Warriors Guild', 'A training ground for fighters and soldiers.', BuildingType.guild, 'W');
      case GuildType.thieves:
        return ('Thieves Den', 'A shadowy establishment for rogues and spies.', BuildingType.guild, 'T');
      case GuildType.clerics:
        return ('Temple', 'A holy place of worship and healing.', BuildingType.temple, 'C');
      case GuildType.paladins:
        return ('Paladin Hall', 'A sacred hall for holy warriors.', BuildingType.guild, 'P');
    }
  }
  
  (String, String, String) _getBuildingInfo(BuildingType buildingType) {
    switch (buildingType) {
      case BuildingType.house:
        return ('Residence', 'A simple dwelling.', 'H');
      case BuildingType.shop:
        return ('General Store', 'A shop selling various goods.', 'o');
      case BuildingType.tavern:
        return ('The Drunken Dragon', 'A lively tavern with food and drink.', 'D');
      case BuildingType.market:
        return ('Market Square', 'A bustling marketplace.', 'M');
      case BuildingType.stable:
        return ('Stables', 'Where horses and mounts are kept.', 'L');
      case BuildingType.temple:
        return ('Temple', 'A place of worship.', 'C');
      default:
        return ('Building', 'A mysterious building.', '?');
    }
  }
  
  Map<String, dynamic> _getGuildServices(GuildType guildType) {
    switch (guildType) {
      case GuildType.blacksmiths:
        return {'shop': true, 'repair': true, 'craft': true};
      case GuildType.alchemists:
        return {'shop': true, 'brew': true, 'identify': true};
      case GuildType.merchants:
        return {'shop': true, 'trade': true, 'transport': true};
      default:
        return {'quests': true, 'training': true};
    }
  }
  
  Map<String, dynamic> _getBuildingServices(BuildingType buildingType) {
    switch (buildingType) {
      case BuildingType.shop:
        return {'shop': true, 'buy': true, 'sell': true};
      case BuildingType.tavern:
        return {'food': true, 'drink': true, 'rumors': true};
      case BuildingType.stable:
        return {'horses': true, 'storage': true};
      default:
        return {};
    }
  }
  
  void _generateTownNPCs(Map<String, NPC> npcs, Location location, int width, int height) {
    int npcCount;
    switch (location.type) {
      case 'village': npcCount = 3 + _random.nextInt(3); break;
      case 'town': npcCount = 5 + _random.nextInt(5); break;
      case 'city': npcCount = 8 + _random.nextInt(7); break;
      case 'capital': npcCount = 12 + _random.nextInt(8); break;
      default: npcCount = 3;
    }
    
    final npcNames = [
      'Gareth the Merchant', 'Sister Mary', 'Old Tom', 'Captain Blake', 'Thief Magnus',
      'Elena the Wise', 'Drunk Joe', 'Blacksmith John', 'Noble Lady Catherine', 'Rogue Jack',
      'Priest Benedict', 'Warrior Sarah', 'Beggar Pete', 'Scholar Vincent', 'Bandit Chief Rex'
    ];
    
    for (int i = 0; i < npcCount; i++) {
      // Find a suitable spot for the NPC
      final pos = _findNPCSpot(width, height);
      if (pos.$1 == -1) break; // No more space
      
      // Create NPC with varied dispositions
      double dispositionRoll = _random.nextDouble();
      NPCDisposition disposition;
      if (dispositionRoll < 0.15) {
        disposition = NPCDisposition.hostile; // 15% hostile
      } else if (dispositionRoll < 0.35) {
        disposition = NPCDisposition.neutral; // 20% neutral
      } else {
        disposition = NPCDisposition.friendly; // 65% friendly
      }
      
      final name = npcNames[_random.nextInt(npcNames.length)];
      final level = 1 + _random.nextInt(5);
      
      final npc = NPC(
        id: 'npc_${location.id}_$i',
        name: name,
        description: _getNPCDescription(disposition, name),
        disposition: disposition,
        dialogue: _getNPCDialogue(disposition),
        level: level,
        townX: pos.$1,
        townY: pos.$2,
        currentLocation: location.name,
      );
      
      // Equip NPCs based on their disposition and level
      _equipNPC(npc);
      
      npcs[npc.id] = npc;
    }
  }
  
  (int, int) _findNPCSpot(int width, int height) {
    final attempts = 50;
    for (int i = 0; i < attempts; i++) {
      final x = 2 + _random.nextInt(width - 4);
      final y = 2 + _random.nextInt(height - 4);
      
      // NPCs can be placed on roads or grass
      return (x, y);
    }
    return (-1, -1); // No suitable spot found
  }
  
  String _getNPCSymbol(NPC npc) {
    switch (npc.disposition) {
      case NPCDisposition.friendly: return 'f';
      case NPCDisposition.neutral: return 'n';
      case NPCDisposition.hostile: return 'h';
    }
  }
  
  String _getNPCDescription(NPCDisposition disposition, String name) {
    switch (disposition) {
      case NPCDisposition.friendly:
        return '$name greets you warmly with a friendly smile.';
      case NPCDisposition.neutral:
        return '$name watches you with cautious interest.';
      case NPCDisposition.hostile:
        return '$name glares at you with obvious menace.';
    }
  }
  
  String _getNPCDialogue(NPCDisposition disposition) {
    switch (disposition) {
      case NPCDisposition.friendly:
        final greetings = [
          'Welcome, traveler! How can I help you?',
          'Good day to you! Beautiful weather we\'re having.',
          'Greetings! You look like you could use some rest.',
          'Hello there! Safe travels on your journey.',
        ];
        return greetings[_random.nextInt(greetings.length)];
      case NPCDisposition.neutral:
        final greetings = [
          'You\'re not from around here, are you?',
          'What brings you to our town?',
          'Stranger...',
          'Mind your own business.',
        ];
        return greetings[_random.nextInt(greetings.length)];
      case NPCDisposition.hostile:
        final greetings = [
          'Get out of my sight!',
          'You don\'t belong here, outsider!',
          'Looking for trouble?',
          'I don\'t like your face.',
        ];
        return greetings[_random.nextInt(greetings.length)];
    }
  }
  
  void _equipNPC(NPC npc) {
    // Give hostile NPCs basic weapons
    if (npc.disposition == NPCDisposition.hostile) {
      npc.equipment['weapon'] = ItemGenerator.generateRandomItem(
        ItemType.weapon,
        rarity: ItemRarity.common,
        isShopItem: false,
      );
      
      if (_random.nextBool()) {
        npc.equipment['armor'] = ItemGenerator.generateRandomItem(
          ItemType.armor,
          rarity: ItemRarity.common,
          isShopItem: false,
        );
      }
    }
    
    // Give some neutral NPCs basic equipment
    if (npc.disposition == NPCDisposition.neutral && _random.nextDouble() < 0.3) {
      npc.equipment['weapon'] = ItemGenerator.generateRandomItem(
        ItemType.weapon,
        rarity: ItemRarity.common,
        isShopItem: false,
      );
    }
  }
}