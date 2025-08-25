import 'dart:math';
import '../models/npc.dart';
import '../models/town.dart';
import '../models/world.dart';
import '../models/player.dart';
import '../models/enums.dart';

class NPCMovementService {
  static final Random _random = Random();
  
  /// Process all NPC actions for a turn
  static void processTurn(GameTime gameTime, List<TownLayout> townLayouts, Player player) {
    for (final townLayout in townLayouts) {
      _processTownNPCs(gameTime, townLayout, player);
      _checkForRespawns(gameTime, townLayout);
    }
  }
  
  /// Process NPC movement and behavior within a town
  static void _processTownNPCs(GameTime gameTime, TownLayout townLayout, Player player) {
    final npcsToUpdate = townLayout.npcs.values.where((npc) => npc.isAlive).toList();
    
    for (final npc in npcsToUpdate) {
      npc.turnsSinceLastMove++;
      
      // Check if it's time for this NPC to move
      if (npc.turnsSinceLastMove >= npc.movementTimer) {
        _moveNPC(npc, townLayout, player);
        npc.turnsSinceLastMove = 0;
        // Reset movement timer with some randomness (1-3 turns)
        npc.movementTimer = 1 + _random.nextInt(3);
      }
    }
  }
  
  /// Move an NPC randomly or toward/away from player
  static void _moveNPC(NPC npc, TownLayout townLayout, Player player) {
    // Get current player position in this town (if player is in this town)
    final playerInThisTown = player.currentLocation == townLayout.name;
    
    List<(int, int)> possibleMoves = [];
    final directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1),
    ];
    
    // Find valid movement positions
    for (final (dx, dy) in directions) {
      final newX = npc.townX + dx;
      final newY = npc.townY + dy;
      
      if (_isValidPosition(newX, newY, townLayout)) {
        possibleMoves.add((newX, newY));
      }
    }
    
    if (possibleMoves.isEmpty) return; // Can't move
    
    (int, int) chosenMove;
    
    if (playerInThisTown) {
      // NPC behavior based on disposition when player is nearby
      switch (npc.disposition) {
        case NPCDisposition.friendly:
          // 30% chance to move toward player, 70% random
          if (_random.nextDouble() < 0.3) {
            chosenMove = _chooseMoveTowardTarget(possibleMoves, npc, player.worldX, player.worldY);
          } else {
            chosenMove = possibleMoves[_random.nextInt(possibleMoves.length)];
          }
          break;
          
        case NPCDisposition.hostile:
          // 50% chance to move toward player, 50% random aggressive movement
          if (_random.nextDouble() < 0.5) {
            chosenMove = _chooseMoveTowardTarget(possibleMoves, npc, player.worldX, player.worldY);
          } else {
            chosenMove = possibleMoves[_random.nextInt(possibleMoves.length)];
          }
          break;
          
        case NPCDisposition.neutral:
        default:
          // Random movement
          chosenMove = possibleMoves[_random.nextInt(possibleMoves.length)];
          break;
      }
    } else {
      // Player not in town, move randomly or patrol
      if (_random.nextDouble() < 0.2) {
        // 20% chance to move back toward original position
        chosenMove = _chooseMoveTowardTarget(possibleMoves, npc, npc.originalTownX, npc.originalTownY);
      } else {
        // 80% random movement
        chosenMove = possibleMoves[_random.nextInt(possibleMoves.length)];
      }
    }
    
    // Update NPC position
    final oldX = npc.townX;
    final oldY = npc.townY;
    npc.townX = chosenMove.$1;
    npc.townY = chosenMove.$2;
    
    // Update the town grid
    if (townLayout.grid[oldY][oldX] == _getNPCSymbol(npc)) {
      townLayout.grid[oldY][oldX] = ' '; // Clear old position
    }
    
    // Only place NPC symbol if there's no building at the new position
    if (townLayout.grid[chosenMove.$2][chosenMove.$1] == ' ') {
      townLayout.grid[chosenMove.$2][chosenMove.$1] = _getNPCSymbol(npc);
    }
  }
  
  /// Choose move that gets closer to a target position
  static (int, int) _chooseMoveTowardTarget(List<(int, int)> possibleMoves, NPC npc, int targetX, int targetY) {
    (int, int) bestMove = possibleMoves.first;
    double bestDistance = double.infinity;
    
    for (final move in possibleMoves) {
      final distance = sqrt(pow(move.$1 - targetX, 2) + pow(move.$2 - targetY, 2));
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMove = move;
      }
    }
    
    return bestMove;
  }
  
  /// Check if a position is valid for NPC movement
  static bool _isValidPosition(int x, int y, TownLayout townLayout) {
    // Check boundaries
    if (x < 0 || x >= townLayout.width || y < 0 || y >= townLayout.height) {
      return false;
    }
    
    // Check for walls
    if (townLayout.grid[y][x] == '#') {
      return false;
    }
    
    // Check for other NPCs (don't stack NPCs)
    if (townLayout.hasNPCAt(x, y)) {
      return false;
    }
    
    // Allow movement onto roads, grass, and building entrances
    return true;
  }
  
  /// Check for NPCs that should respawn
  static void _checkForRespawns(GameTime gameTime, TownLayout townLayout) {
    final deadNPCs = townLayout.npcs.values.where((npc) => !npc.isAlive).toList();
    
    for (final npc in deadNPCs) {
      final daysSinceDeath = gameTime.day - npc.lastDeathDay;
      
      if (daysSinceDeath >= 1) { // Respawn after 1 day (24 hours)
        _respawnNPC(npc, townLayout);
      }
    }
  }
  
  /// Respawn a dead NPC
  static void _respawnNPC(NPC npc, TownLayout townLayout) {
    // Restore HP and mana
    npc.currentHp = npc.maxHp;
    npc.currentMana = npc.maxMana;
    
    // Reset position to original location (or find nearby open spot)
    int respawnX = npc.originalTownX;
    int respawnY = npc.originalTownY;
    
    // If original position is occupied, find nearby open spot
    if (!_isValidPosition(respawnX, respawnY, townLayout)) {
      final nearbyPositions = _findNearbyOpenPositions(respawnX, respawnY, townLayout);
      if (nearbyPositions.isNotEmpty) {
        final chosen = nearbyPositions[_random.nextInt(nearbyPositions.length)];
        respawnX = chosen.$1;
        respawnY = chosen.$2;
      }
    }
    
    npc.townX = respawnX;
    npc.townY = respawnY;
    npc.turnsSinceLastMove = 0;
    npc.movementTimer = 1 + _random.nextInt(3);
    
    // Place NPC back on the grid
    if (townLayout.grid[respawnY][respawnX] == ' ') {
      townLayout.grid[respawnY][respawnX] = _getNPCSymbol(npc);
    }
  }
  
  /// Find open positions near a given location
  static List<(int, int)> _findNearbyOpenPositions(int centerX, int centerY, TownLayout townLayout) {
    final openPositions = <(int, int)>[];
    
    // Search in expanding radius
    for (int radius = 1; radius <= 3; radius++) {
      for (int dx = -radius; dx <= radius; dx++) {
        for (int dy = -radius; dy <= radius; dy++) {
          if (dx.abs() != radius && dy.abs() != radius) continue; // Only check perimeter
          
          final x = centerX + dx;
          final y = centerY + dy;
          
          if (_isValidPosition(x, y, townLayout)) {
            openPositions.add((x, y));
          }
        }
      }
      
      if (openPositions.isNotEmpty) break; // Found positions at this radius
    }
    
    return openPositions;
  }
  
  /// Get the appropriate symbol for an NPC based on disposition
  static String _getNPCSymbol(NPC npc) {
    switch (npc.disposition) {
      case NPCDisposition.friendly:
        return 'f';
      case NPCDisposition.neutral:
        return 'n';
      case NPCDisposition.hostile:
        return 'h';
    }
  }
  
  /// Mark NPC as dead and record death day
  static void markNPCDead(NPC npc, GameTime gameTime) {
    npc.currentHp = 0;
    npc.lastDeathDay = gameTime.day;
  }
}