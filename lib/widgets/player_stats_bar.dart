import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerStatsBar extends StatelessWidget {
  final Player player;
  
  const PlayerStatsBar({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        children: [
          // Health
          Flexible(child: _buildStatGroup('HP', '${player.currentHp}/${player.maxHp}', Colors.red)),
          const SizedBox(width: 8),
          
          // Mana
          Flexible(child: _buildStatGroup('MP', '${player.currentMana}/${player.maxMana}', Colors.blue)),
          const SizedBox(width: 8),
          
          // Hunger
          Flexible(child: _buildStatGroup('H', '${player.hunger}', Colors.orange)),
          const SizedBox(width: 8),
          
          // Money
          Flexible(child: _buildStatGroup('\$', '${player.goldCoins}g${player.silverCoins}s', Colors.yellow)),
          
          const Spacer(),
          
          // Level and XP
          Flexible(child: _buildStatGroup('L', '${player.level}', Colors.green)),
          const SizedBox(width: 4),
          Flexible(child: _buildStatGroup('XP', '${player.experience}/${player.experienceToNext}', Colors.cyan)),
        ],
      ),
    );
  }
  
  Widget _buildStatGroup(String label, String value, Color color) {
    return Flexible(
      child: Text(
        '$label:$value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}