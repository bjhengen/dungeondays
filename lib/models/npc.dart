import 'enums.dart';
import 'item.dart';
import 'stats.dart';

class NPC {
  final String id;
  final String name;
  final String description;
  final NPCDisposition disposition;
  final String dialogue;
  final List<String> questIds;
  final List<Item> shopInventory;
  final Map<String, dynamic> services;
  final GuildType? guildAffiliation;
  final int level;
  final bool canBeCompanion;
  final String? companionRequirements;
  
  // Combat stats
  final Stats baseStats;
  int currentHp;
  int maxHp;
  int currentMana;
  int maxMana;
  final Map<String, Item?> equipment;
  
  // Town position
  int townX;
  int townY;
  
  int worldX;
  int worldY;
  String currentLocation;
  
  // Movement and respawning data
  int lastDeathDay;
  int originalTownX;
  int originalTownY;
  int turnsSinceLastMove;
  int movementTimer; // Random 1-3 turn movement interval
  
  NPC({
    required this.id,
    required this.name,
    required this.description,
    this.disposition = NPCDisposition.neutral,
    this.dialogue = '',
    this.questIds = const [],
    this.shopInventory = const [],
    this.services = const {},
    this.guildAffiliation,
    this.level = 1,
    this.canBeCompanion = false,
    this.companionRequirements,
    Stats? baseStats,
    int? maxHp,
    int? maxMana,
    this.townX = 0,
    this.townY = 0,
    this.worldX = 0,
    this.worldY = 0,
    this.currentLocation = '',
    this.lastDeathDay = 0,
    int? originalTownX,
    int? originalTownY,
    this.turnsSinceLastMove = 0,
    int? movementTimer,
  }) : 
    baseStats = baseStats ?? Stats(strength: 10 + level, constitution: 10 + level, intelligence: 10 + level),
    maxHp = maxHp ?? (50 + (level * 10)),
    currentHp = maxHp ?? (50 + (level * 10)),
    maxMana = maxMana ?? (25 + (level * 5)),
    currentMana = maxMana ?? (25 + (level * 5)),
    originalTownX = originalTownX ?? townX,
    originalTownY = originalTownY ?? townY,
    movementTimer = movementTimer ?? (1 + (level % 3)), // 1-3 turns based on level
    equipment = {
      'weapon': null,
      'armor': null,
      'shield': null,
    };

  bool get isShopkeeper => shopInventory.isNotEmpty;
  bool get hasQuests => questIds.isNotEmpty;
  bool get providesServices => services.isNotEmpty;
  bool get isHostile => disposition == NPCDisposition.hostile;
  bool get isAlive => currentHp > 0;
  
  Stats get currentStats {
    Stats stats = baseStats.copy();
    // Add equipment bonuses
    for (final item in equipment.values) {
      if (item != null && item.statModifiers != null) {
        stats = stats.add(item.statModifiers!);
      }
    }
    return stats;
  }
  
  int get attackPower {
    final weapon = equipment['weapon'];
    final baseAttack = currentStats.strength;
    final weaponDamage = weapon?.statModifiers?.strength ?? 0;
    return baseAttack + weaponDamage;
  }
  
  int get defense {
    final armor = equipment['armor'];
    final shield = equipment['shield'];
    final baseDef = currentStats.constitution;
    final armorDef = armor?.statModifiers?.constitution ?? 0;
    final shieldDef = shield?.statModifiers?.constitution ?? 0;
    return baseDef + armorDef + shieldDef;
  }
  
  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, maxHp);
  }
  
  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'disposition': disposition.index,
    'dialogue': dialogue,
    'questIds': questIds,
    'shopInventory': shopInventory.map((item) => item.toJson()).toList(),
    'services': services,
    'guildAffiliation': guildAffiliation?.index,
    'level': level,
    'canBeCompanion': canBeCompanion,
    'companionRequirements': companionRequirements,
    'baseStats': baseStats.toJson(),
    'currentHp': currentHp,
    'maxHp': maxHp,
    'currentMana': currentMana,
    'maxMana': maxMana,
    'equipment': equipment.map((key, value) => MapEntry(key, value?.toJson())),
    'townX': townX,
    'townY': townY,
    'worldX': worldX,
    'worldY': worldY,
    'currentLocation': currentLocation,
    'lastDeathDay': lastDeathDay,
    'originalTownX': originalTownX,
    'originalTownY': originalTownY,
    'turnsSinceLastMove': turnsSinceLastMove,
    'movementTimer': movementTimer,
  };

  factory NPC.fromJson(Map<String, dynamic> json) {
    final npc = NPC(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      disposition: NPCDisposition.values[json['disposition'] ?? 1],
      dialogue: json['dialogue'] ?? '',
      questIds: List<String>.from(json['questIds'] ?? []),
      shopInventory: (json['shopInventory'] as List? ?? [])
          .map((item) => Item.fromJson(item))
          .toList(),
      services: Map<String, dynamic>.from(json['services'] ?? {}),
      guildAffiliation: json['guildAffiliation'] != null 
          ? GuildType.values[json['guildAffiliation']] 
          : null,
      level: json['level'] ?? 1,
      canBeCompanion: json['canBeCompanion'] ?? false,
      companionRequirements: json['companionRequirements'],
      baseStats: json['baseStats'] != null ? Stats.fromJson(json['baseStats']) : null,
      maxHp: json['maxHp'],
      maxMana: json['maxMana'],
      townX: json['townX'] ?? 0,
      townY: json['townY'] ?? 0,
      worldX: json['worldX'] ?? 0,
      worldY: json['worldY'] ?? 0,
      currentLocation: json['currentLocation'] ?? '',
      lastDeathDay: json['lastDeathDay'] ?? 0,
      originalTownX: json['originalTownX'],
      originalTownY: json['originalTownY'],
      turnsSinceLastMove: json['turnsSinceLastMove'] ?? 0,
      movementTimer: json['movementTimer'],
    );
    
    // Restore current HP/MP
    if (json['currentHp'] != null) npc.currentHp = json['currentHp'];
    if (json['currentMana'] != null) npc.currentMana = json['currentMana'];
    
    // Restore equipment
    if (json['equipment'] != null) {
      final equipmentData = json['equipment'] as Map<String, dynamic>;
      for (final entry in equipmentData.entries) {
        if (entry.value != null) {
          npc.equipment[entry.key] = Item.fromJson(entry.value);
        }
      }
    }
    
    return npc;
  }
}

class Guild {
  final GuildType type;
  final String name;
  final String description;
  final List<String> availableQuests;
  final Map<String, int> requiredReputation;
  final List<String> services;
  final List<Item> shopItems;
  
  Guild({
    required this.type,
    required this.name,
    required this.description,
    this.availableQuests = const [],
    this.requiredReputation = const {},
    this.services = const [],
    this.shopItems = const [],
  });

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'name': name,
    'description': description,
    'availableQuests': availableQuests,
    'requiredReputation': requiredReputation,
    'services': services,
    'shopItems': shopItems.map((item) => item.toJson()).toList(),
  };

  factory Guild.fromJson(Map<String, dynamic> json) => Guild(
    type: GuildType.values[json['type']],
    name: json['name'],
    description: json['description'],
    availableQuests: List<String>.from(json['availableQuests'] ?? []),
    requiredReputation: Map<String, int>.from(json['requiredReputation'] ?? {}),
    services: List<String>.from(json['services'] ?? []),
    shopItems: (json['shopItems'] as List? ?? [])
        .map((item) => Item.fromJson(item))
        .toList(),
  );
}