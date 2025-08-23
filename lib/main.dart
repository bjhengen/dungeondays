import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

void main() {
  runApp(const DungeonDaysApp());
}

class DungeonDaysApp extends StatelessWidget {
  const DungeonDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon Days',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'monospace', fontSize: 14),
          bodyMedium: TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}