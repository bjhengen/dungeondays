import 'package:flutter/material.dart';
import 'character_creation_screen.dart';
import 'load_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DUNGEON DAYS',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'A Magic-Focused ASCII Roguelike',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              context,
              'New Game',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CharacterCreationScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              'Load Game',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoadGameScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              'Exit',
              () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade800,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}