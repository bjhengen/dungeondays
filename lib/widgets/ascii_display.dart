import 'package:flutter/material.dart';

class ASCIIDisplay extends StatelessWidget {
  final List<List<String>> grid;
  final int playerX;
  final int playerY;
  final int visibilityRange;
  final double cellSize;
  final Map<String, Color> colorMap;
  final Color backgroundColor;
  
  const ASCIIDisplay({
    super.key,
    required this.grid,
    required this.playerX,
    required this.playerY,
    this.visibilityRange = 4,
    this.cellSize = 16.0,
    this.colorMap = const {},
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: CustomPaint(
        painter: ASCIIPainter(
          grid: grid,
          playerX: playerX,
          playerY: playerY,
          visibilityRange: visibilityRange,
          cellSize: cellSize,
          colorMap: colorMap,
          backgroundColor: backgroundColor,
        ),
        size: Size(
          grid[0].length * cellSize,
          grid.length * cellSize,
        ),
      ),
    );
  }
}

class ASCIIPainter extends CustomPainter {
  final List<List<String>> grid;
  final int playerX;
  final int playerY;
  final int visibilityRange;
  final double cellSize;
  final Map<String, Color> colorMap;
  final Color backgroundColor;

  ASCIIPainter({
    required this.grid,
    required this.playerX,
    required this.playerY,
    required this.visibilityRange,
    required this.cellSize,
    required this.colorMap,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        final char = grid[y][x];
        final distance = (playerX - x).abs() + (playerY - y).abs();
        
        // Only draw visible characters
        if (distance <= visibilityRange) {
          Color textColor = colorMap[char] ?? Colors.white;
          
          // Dim characters at edge of visibility
          if (distance == visibilityRange) {
            textColor = textColor.withValues(alpha: 0.6);
          }
          
          textPainter.text = TextSpan(
            text: char,
            style: TextStyle(
              color: textColor,
              fontSize: cellSize * 0.8,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          );
          
          textPainter.layout();
          
          final offset = Offset(
            x * cellSize + (cellSize - textPainter.width) / 2,
            y * cellSize + (cellSize - textPainter.height) / 2,
          );
          
          textPainter.paint(canvas, offset);
        }
      }
    }
    
    // Draw player character with background-appropriate color
    final playerColor = backgroundColor == Colors.white ? Colors.red : Colors.yellow;
    textPainter.text = TextSpan(
      text: '@',
      style: TextStyle(
        color: playerColor,
        fontSize: cellSize * 0.8,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
    
    textPainter.layout();
    
    final playerOffset = Offset(
      playerX * cellSize + (cellSize - textPainter.width) / 2,
      playerY * cellSize + (cellSize - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, playerOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GameUI extends StatelessWidget {
  final String playerName;
  final int level;
  final int hp;
  final int maxHp;
  final int mana;
  final int maxMana;
  final int hunger;
  final int maxHunger;
  final String timeString;
  final String dateString;
  final String weather;
  final String location;
  final int silverCoins;
  final int goldCoins;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onInventoryPressed;
  final VoidCallback? onMapPressed;
  final VoidCallback? onSpellbookPressed;
  
  const GameUI({
    super.key,
    required this.playerName,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.mana,
    required this.maxMana,
    required this.hunger,
    required this.maxHunger,
    required this.timeString,
    required this.dateString,
    required this.weather,
    required this.location,
    required this.silverCoins,
    required this.goldCoins,
    this.onMenuPressed,
    this.onInventoryPressed,
    this.onMapPressed,
    this.onSpellbookPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Add extra bottom padding on mobile to avoid navigation conflicts
    final bottomPadding = MediaQuery.of(context).padding.bottom + 8.0;
    
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$playerName (Lvl $level)',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '$timeString, $dateString',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildStatBar('HP', hp, maxHp, Colors.red),
          _buildStatBar('MP', mana, maxMana, Colors.blue),
          _buildHungerBar(hunger, maxHunger),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location: $location',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                'Weather: $weather',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Money: ${goldCoins}g ${silverCoins}s',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUIButton('Menu', onMenuPressed),
                    const SizedBox(width: 4),
                    _buildUIButton('Inv', onInventoryPressed),
                    const SizedBox(width: 4),
                    _buildUIButton('Spells', onSpellbookPressed),
                    const SizedBox(width: 4),
                    _buildUIButton('Map', onMapPressed),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int current, int max, Color color) {
    final percentage = max > 0 ? current / max : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: percentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '$current/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHungerBar(int hunger, int maxHunger) {
    final percentage = maxHunger > 0 ? hunger / maxHunger : 0.0;
    
    // Determine hunger status and colors
    Color barColor;
    Color textColor;
    String warning = '';
    
    if (percentage <= 0.1) { // 10% or less - critical
      barColor = Colors.red.shade700;
      textColor = Colors.red;
      warning = ' ⚠ STARVING!';
    } else if (percentage <= 0.3) { // 30% or less - very hungry
      barColor = Colors.orange.shade700;
      textColor = Colors.orange;
      warning = ' ⚠ Very Hungry';
    } else if (percentage <= 0.5) { // 50% or less - hungry
      barColor = Colors.yellow.shade700;
      textColor = Colors.yellow;
      warning = ' Hungry';
    } else {
      barColor = Colors.green;
      textColor = Colors.white70;
      warning = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              'Hunger',
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: percentage <= 0.3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: percentage <= 0.3 ? textColor : Colors.white24),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: percentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '$hunger/$maxHunger',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: percentage <= 0.3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUIButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: 36,
      height: 20,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade800,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}