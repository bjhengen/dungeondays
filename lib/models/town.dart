import 'enums.dart';
import 'npc.dart';

class Building {
  final String id;
  final String name;
  final String description;
  final BuildingType type;
  final int townX;
  final int townY;
  final String symbol;
  final List<String> npcIds;
  final Map<String, dynamic> services;
  final GuildType? guildType;
  
  Building({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.townX,
    required this.townY,
    required this.symbol,
    this.npcIds = const [],
    this.services = const {},
    this.guildType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.index,
    'townX': townX,
    'townY': townY,
    'symbol': symbol,
    'npcIds': npcIds,
    'services': services,
    'guildType': guildType?.index,
  };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: BuildingType.values[json['type']],
    townX: json['townX'],
    townY: json['townY'],
    symbol: json['symbol'],
    npcIds: List<String>.from(json['npcIds'] ?? []),
    services: Map<String, dynamic>.from(json['services'] ?? {}),
    guildType: json['guildType'] != null ? GuildType.values[json['guildType']] : null,
  );
}

class TownLayout {
  final String locationId;
  final String name;
  final int width;
  final int height;
  final List<List<String>> grid;
  final Map<String, Building> buildings;
  final Map<String, NPC> npcs;
  final int entranceX;
  final int entranceY;
  
  TownLayout({
    required this.locationId,
    required this.name,
    required this.width,
    required this.height,
    required this.grid,
    required this.buildings,
    this.npcs = const {},
    required this.entranceX,
    required this.entranceY,
  });

  Building? getBuildingAt(int x, int y) {
    try {
      return buildings.values.firstWhere(
        (building) => building.townX == x && building.townY == y,
      );
    } catch (e) {
      return null;
    }
  }

  bool hasBuildingAt(int x, int y) {
    return getBuildingAt(x, y) != null;
  }
  
  NPC? getNPCAt(int x, int y) {
    try {
      return npcs.values.firstWhere(
        (npc) => npc.townX == x && npc.townY == y,
      );
    } catch (e) {
      return null;
    }
  }
  
  bool hasNPCAt(int x, int y) {
    return getNPCAt(x, y) != null;
  }

  Map<String, dynamic> toJson() => {
    'locationId': locationId,
    'name': name,
    'width': width,
    'height': height,
    'grid': grid,
    'buildings': buildings.map((k, v) => MapEntry(k, v.toJson())),
    'npcs': npcs.map((k, v) => MapEntry(k, v.toJson())),
    'entranceX': entranceX,
    'entranceY': entranceY,
  };

  factory TownLayout.fromJson(Map<String, dynamic> json) => TownLayout(
    locationId: json['locationId'],
    name: json['name'],
    width: json['width'],
    height: json['height'],
    grid: (json['grid'] as List).map((row) => List<String>.from(row)).toList(),
    buildings: (json['buildings'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, Building.fromJson(v))),
    npcs: (json['npcs'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, NPC.fromJson(v))),
    entranceX: json['entranceX'],
    entranceY: json['entranceY'],
  );
}