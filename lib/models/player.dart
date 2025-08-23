import 'enums.dart';
import 'stats.dart';
import 'item.dart';

class Player {
  String name;
  String gender;
  Race race;
  CharacterClass characterClass;
  CharacterAlignment alignment;
  int level;
  int experience;
  int experienceToNext;
  int upgradePoints;
  
  Stats baseStats;
  Stats currentStats;
  
  int currentHp;
  int maxHp;
  int currentMana;
  int maxMana;
  
  int hunger;
  int maxHunger;
  
  int silverCoins;
  int goldCoins;
  
  Map<String, Item?> equipment;
  List<Item> inventory;
  int maxInventorySlots;
  
  Map<GuildType, int> guildReputation;
  Map<String, int> locationReputation;
  
  List<String> knownSpells;
  Map<SpellSchool, int> spellSchoolLevels;
  
  Map<String, int> skills;
  
  // Current location and world position
  String currentLocation;
  int worldX;
  int worldY;
  
  Player({
    required this.name,
    required this.gender,
    required this.race,
    required this.characterClass,
    required this.alignment,
    this.level = 1,
    this.experience = 0,
    this.experienceToNext = 100,
    this.upgradePoints = 0,
    required this.baseStats,
    this.currentHp = 100,
    this.maxHp = 100,
    this.currentMana = 50,
    this.maxMana = 50,
    this.hunger = 100,
    this.maxHunger = 100,
    this.silverCoins = 50,
    this.goldCoins = 0,
    this.maxInventorySlots = 20,
    this.currentLocation = 'Starting Village',
    this.worldX = 0,
    this.worldY = 0,
  }) : 
    currentStats = baseStats.copy(),
    equipment = {
      'weapon': null,
      'armor': null,
      'shield': null,
      'helmet': null,
      'boots': null,
      'gloves': null,
      'ring1': null,
      'ring2': null,
      'amulet': null,
    },
    inventory = [],
    guildReputation = {for (var guild in GuildType.values) guild: 0},
    locationReputation = {},
    knownSpells = [],
    spellSchoolLevels = {for (var school in SpellSchool.values) school: 0},
    skills = {
      'crafting': 0,
      'enchantment': 0,
      'lockpicking': 0,
      'stealth': 0,
      'trading': 0,
    };

  bool get isGood => alignment == CharacterAlignment.lawfulGood || 
                     alignment == CharacterAlignment.neutralGood || 
                     alignment == CharacterAlignment.chaoticGood;
  
  bool get isEvil => alignment == CharacterAlignment.lawfulEvil || 
                     alignment == CharacterAlignment.neutralEvil || 
                     alignment == CharacterAlignment.chaoticEvil;
  
  bool get isChaotic => alignment == CharacterAlignment.chaoticGood || 
                        alignment == CharacterAlignment.chaoticNeutral || 
                        alignment == CharacterAlignment.chaoticEvil;

  int get totalMoney => silverCoins + (goldCoins * 100);
  
  bool canAfford(int silverCost) => totalMoney >= silverCost;
  
  void spendMoney(int silverCost) {
    if (!canAfford(silverCost)) return;
    
    if (silverCoins >= silverCost) {
      silverCoins -= silverCost;
    } else {
      int remaining = silverCost - silverCoins;
      silverCoins = 0;
      int goldNeeded = (remaining / 100).ceil();
      goldCoins -= goldNeeded;
      silverCoins = (goldNeeded * 100) - remaining;
    }
  }
  
  void addMoney(int silverAmount) {
    silverCoins += silverAmount;
    while (silverCoins >= 100) {
      silverCoins -= 100;
      goldCoins++;
    }
  }
  
  bool addToInventory(Item item) {
    if (inventory.length >= maxInventorySlots) return false;
    inventory.add(item);
    return true;
  }
  
  bool removeFromInventory(Item item) {
    return inventory.remove(item);
  }
  
  void recalculateStats() {
    // Start with base stats
    currentStats = baseStats.copy();
    
    // Add equipment bonuses
    for (final item in equipment.values) {
      if (item != null && item.statModifiers != null) {
        currentStats = currentStats.add(item.statModifiers!);
      }
    }
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
    'name': name,
    'gender': gender,
    'race': race.index,
    'characterClass': characterClass.index,
    'alignment': alignment.index,
    'level': level,
    'experience': experience,
    'experienceToNext': experienceToNext,
    'upgradePoints': upgradePoints,
    'baseStats': baseStats.toJson(),
    'currentStats': currentStats.toJson(),
    'currentHp': currentHp,
    'maxHp': maxHp,
    'currentMana': currentMana,
    'maxMana': maxMana,
    'hunger': hunger,
    'maxHunger': maxHunger,
    'silverCoins': silverCoins,
    'goldCoins': goldCoins,
    'equipment': equipment.map((k, v) => MapEntry(k, v?.toJson())),
    'inventory': inventory.map((item) => item.toJson()).toList(),
    'maxInventorySlots': maxInventorySlots,
    'guildReputation': guildReputation.map((k, v) => MapEntry(k.index, v)),
    'locationReputation': locationReputation,
    'knownSpells': knownSpells,
    'spellSchoolLevels': spellSchoolLevels.map((k, v) => MapEntry(k.index, v)),
    'skills': skills,
    'currentLocation': currentLocation,
    'worldX': worldX,
    'worldY': worldY,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    var player = Player(
      name: json['name'],
      gender: json['gender'],
      race: Race.values[json['race']],
      characterClass: CharacterClass.values[json['characterClass']],
      alignment: CharacterAlignment.values[json['alignment']],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      experienceToNext: json['experienceToNext'] ?? 100,
      upgradePoints: json['upgradePoints'] ?? 0,
      baseStats: Stats.fromJson(json['baseStats']),
      currentHp: json['currentHp'] ?? 100,
      maxHp: json['maxHp'] ?? 100,
      currentMana: json['currentMana'] ?? 50,
      maxMana: json['maxMana'] ?? 50,
      hunger: json['hunger'] ?? 100,
      maxHunger: json['maxHunger'] ?? 100,
      silverCoins: json['silverCoins'] ?? 50,
      goldCoins: json['goldCoins'] ?? 0,
      maxInventorySlots: json['maxInventorySlots'] ?? 20,
      currentLocation: json['currentLocation'] ?? 'Starting Village',
      worldX: json['worldX'] ?? 0,
      worldY: json['worldY'] ?? 0,
    );
    
    player.currentStats = Stats.fromJson(json['currentStats']);
    
    if (json['equipment'] != null) {
      json['equipment'].forEach((key, value) {
        player.equipment[key] = value != null ? Item.fromJson(value) : null;
      });
    }
    
    if (json['inventory'] != null) {
      player.inventory = (json['inventory'] as List)
          .map((item) => Item.fromJson(item))
          .toList();
    }
    
    if (json['guildReputation'] != null) {
      player.guildReputation = (json['guildReputation'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(GuildType.values[int.parse(k)], v));
    }
    
    player.locationReputation = Map<String, int>.from(json['locationReputation'] ?? {});
    player.knownSpells = List<String>.from(json['knownSpells'] ?? []);
    
    if (json['spellSchoolLevels'] != null) {
      player.spellSchoolLevels = (json['spellSchoolLevels'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(SpellSchool.values[int.parse(k)], v));
    }
    
    player.skills = Map<String, int>.from(json['skills'] ?? {});
    
    return player;
  }
}