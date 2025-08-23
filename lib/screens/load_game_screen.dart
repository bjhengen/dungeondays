import 'package:flutter/material.dart';
import '../services/save_service.dart';
import 'game_screen.dart';

class LoadGameScreen extends StatefulWidget {
  const LoadGameScreen({super.key});

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  Map<int, String> _slotInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlotInfo();
  }

  Future<void> _loadSlotInfo() async {
    final slotInfo = await SaveService.getSaveSlotInfo();
    setState(() {
      _slotInfo = slotInfo;
      _isLoading = false;
    });
  }

  Future<void> _loadGame(int slotNumber) async {
    final save = await SaveService.loadGame(slotNumber);
    if (save != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            player: save.player,
            world: save.world,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load game')),
      );
    }
  }

  Future<void> _deleteGame(int slotNumber) async {
    final success = await SaveService.deleteGame(slotNumber);
    if (success) {
      _loadSlotInfo(); // Refresh the display
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Load Game'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Save Slots',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),
                for (int i = 1; i <= 3; i++) _buildSaveSlot(context, i),
              ],
            ),
          ),
    );
  }

  Widget _buildSaveSlot(BuildContext context, int slotNumber) {
    final info = _slotInfo[slotNumber] ?? 'Empty';
    final isEmpty = info == 'Empty';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 300,
        height: 100,
        child: ElevatedButton(
          onPressed: isEmpty ? null : () => _loadGame(slotNumber),
          onLongPress: isEmpty ? null : () => _showDeleteDialog(slotNumber),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEmpty ? Colors.grey.shade800 : Colors.grey.shade700,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isEmpty ? Colors.grey : Colors.amber),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Slot $slotNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isEmpty ? Colors.grey.shade400 : Colors.white70,
                    fontFamily: 'monospace',
                  ),
                ),
                if (!isEmpty) 
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Long press to delete',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int slotNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Delete Save', style: TextStyle(color: Colors.amber)),
          content: Text(
            'Are you sure you want to delete save slot $slotNumber?',
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGame(slotNumber);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}