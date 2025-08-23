import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/world.dart';

class GameSave {
  final Player player;
  final GameWorld world;
  final DateTime saveDate;
  final int slotNumber;

  GameSave({
    required this.player,
    required this.world,
    required this.saveDate,
    required this.slotNumber,
  });

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'world': world.toJson(),
    'saveDate': saveDate.toIso8601String(),
    'slotNumber': slotNumber,
  };

  factory GameSave.fromJson(Map<String, dynamic> json) => GameSave(
    player: Player.fromJson(json['player']),
    world: GameWorld.fromJson(json['world']),
    saveDate: DateTime.parse(json['saveDate']),
    slotNumber: json['slotNumber'],
  );
}

class SaveService {
  static const String _saveKeyPrefix = 'dungeon_days_save_';
  
  static Future<bool> saveGame(Player player, GameWorld world, int slotNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final save = GameSave(
        player: player,
        world: world,
        saveDate: DateTime.now(),
        slotNumber: slotNumber,
      );
      
      final saveJson = json.encode(save.toJson());
      return await prefs.setString('${_saveKeyPrefix}$slotNumber', saveJson);
    } catch (e) {
      return false;
    }
  }
  
  static Future<GameSave?> loadGame(int slotNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveJson = prefs.getString('${_saveKeyPrefix}$slotNumber');
      
      if (saveJson == null) return null;
      
      final saveData = json.decode(saveJson);
      return GameSave.fromJson(saveData);
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> deleteGame(int slotNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('${_saveKeyPrefix}$slotNumber');
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<GameSave?>> getAllSaves() async {
    List<GameSave?> saves = [];
    
    for (int i = 1; i <= 3; i++) {
      saves.add(await loadGame(i));
    }
    
    return saves;
  }
  
  static Future<Map<int, String>> getSaveSlotInfo() async {
    final Map<int, String> slotInfo = {};
    
    for (int i = 1; i <= 3; i++) {
      final save = await loadGame(i);
      if (save != null) {
        slotInfo[i] = '${save.player.name} - Lvl ${save.player.level}\n'
                      '${save.player.currentLocation}\n'
                      '${_formatDate(save.saveDate)}';
      } else {
        slotInfo[i] = 'Empty';
      }
    }
    
    return slotInfo;
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}