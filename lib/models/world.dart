import 'enums.dart';
import 'npc.dart';
import 'town.dart';

class GameTime {
  int day;
  int hour; // 0-23
  int minute; // 0-59, increments of 10
  Season season;
  Weather weather;
  int weatherDuration; // in turns remaining
  
  GameTime({
    this.day = 1,
    this.hour = 8,
    this.minute = 0,
    this.season = Season.spring,
    this.weather = Weather.clear,
    this.weatherDuration = 0,
  });

  bool get isDaylight => hour >= 6 && hour < 20; // 6 AM to 8 PM
  bool get isNight => !isDaylight;
  
  int get visibilityRange {
    if (isDaylight) return 5; // Extra square of visibility during day
    if (weather == Weather.rain || weather == Weather.snow) return 1;
    return 1; // Night visibility reduced to player +1
  }
  
  void advanceTurn() {
    minute += 10;
    if (minute >= 60) {
      minute = 0;
      hour++;
      if (hour >= 24) {
        hour = 0;
        day++;
        _checkSeasonChange();
      }
    }
    
    if (weatherDuration > 0) {
      weatherDuration--;
      if (weatherDuration == 0) {
        weather = Weather.clear;
      }
    }
  }
  
  void _checkSeasonChange() {
    // Simple season change every 90 days
    int seasonDay = (day - 1) % 360;
    if (seasonDay < 90) season = Season.spring;
    else if (seasonDay < 180) season = Season.summer;
    else if (seasonDay < 270) season = Season.fall;
    else season = Season.winter;
  }
  
  String get timeString => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  String get dateString => 'Day $day, ${season.name.toUpperCase()}';
  
  void advanceToMorning() {
    if (isNight) {
      day++;
      hour = 8;
      minute = 0;
    }
  }
  
  Map<String, dynamic> toJson() => {
    'day': day,
    'hour': hour,
    'minute': minute,
    'season': season.index,
    'weather': weather.index,
    'weatherDuration': weatherDuration,
  };

  factory GameTime.fromJson(Map<String, dynamic> json) => GameTime(
    day: json['day'] ?? 1,
    hour: json['hour'] ?? 8,
    minute: json['minute'] ?? 0,
    season: Season.values[json['season'] ?? 0],
    weather: Weather.values[json['weather'] ?? 0],
    weatherDuration: json['weatherDuration'] ?? 0,
  );
}

class Location {
  final String id;
  final String name;
  final String description;
  final String type; // village, town, city, capital, dungeon, wilderness
  final int worldX;
  final int worldY;
  final List<String> npcIds;
  final List<GuildType> availableGuilds;
  final Map<String, dynamic> services;
  final List<String> shopIds;
  final bool hasBank;
  final bool hasInn;
  final Map<String, String> mapNotes;
  
  Location({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.worldX,
    required this.worldY,
    this.npcIds = const [],
    this.availableGuilds = const [],
    this.services = const {},
    this.shopIds = const [],
    this.hasBank = false,
    this.hasInn = false,
    this.mapNotes = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type,
    'worldX': worldX,
    'worldY': worldY,
    'npcIds': npcIds,
    'availableGuilds': availableGuilds.map((g) => g.index).toList(),
    'services': services,
    'shopIds': shopIds,
    'hasBank': hasBank,
    'hasInn': hasInn,
    'mapNotes': mapNotes,
  };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: json['type'],
    worldX: json['worldX'],
    worldY: json['worldY'],
    npcIds: List<String>.from(json['npcIds'] ?? []),
    availableGuilds: (json['availableGuilds'] as List? ?? [])
        .map((i) => GuildType.values[i])
        .toList(),
    services: Map<String, dynamic>.from(json['services'] ?? {}),
    shopIds: List<String>.from(json['shopIds'] ?? []),
    hasBank: json['hasBank'] ?? false,
    hasInn: json['hasInn'] ?? false,
    mapNotes: Map<String, String>.from(json['mapNotes'] ?? {}),
  );
}

class GameWorld {
  final String id;
  final int seed;
  final Map<String, Location> locations;
  final Map<String, NPC> npcs;
  final Map<String, Guild> guilds;
  final Map<String, TownLayout> townLayouts;
  final GameTime gameTime;
  final Map<String, dynamic> globalFlags;
  
  GameWorld({
    required this.id,
    required this.seed,
    this.locations = const {},
    this.npcs = const {},
    this.guilds = const {},
    this.townLayouts = const {},
    required this.gameTime,
    this.globalFlags = const {},
  });

  Location? getLocation(String id) => locations[id];
  NPC? getNPC(String id) => npcs[id];
  Guild? getGuild(GuildType type) => guilds[type.name];
  TownLayout? getTownLayout(String locationId) => townLayouts[locationId];
  
  List<Location> getLocationsByType(String type) =>
      locations.values.where((loc) => loc.type == type).toList();
      
  List<NPC> getNPCsAtLocation(String locationId) =>
      npcs.values.where((npc) => npc.currentLocation == locationId).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'seed': seed,
    'locations': locations.map((k, v) => MapEntry(k, v.toJson())),
    'npcs': npcs.map((k, v) => MapEntry(k, v.toJson())),
    'guilds': guilds.map((k, v) => MapEntry(k, v.toJson())),
    'townLayouts': townLayouts.map((k, v) => MapEntry(k, v.toJson())),
    'gameTime': gameTime.toJson(),
    'globalFlags': globalFlags,
  };

  factory GameWorld.fromJson(Map<String, dynamic> json) => GameWorld(
    id: json['id'],
    seed: json['seed'],
    locations: (json['locations'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, Location.fromJson(v))),
    npcs: (json['npcs'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, NPC.fromJson(v))),
    guilds: (json['guilds'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, Guild.fromJson(v))),
    townLayouts: (json['townLayouts'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, TownLayout.fromJson(v))),
    gameTime: GameTime.fromJson(json['gameTime']),
    globalFlags: Map<String, dynamic>.from(json['globalFlags'] ?? {}),
  );
}