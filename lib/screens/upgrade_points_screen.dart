import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/stats.dart';

class UpgradePointsScreen extends StatefulWidget {
  final Player player;
  final Function(Player) onPlayerUpdate;

  const UpgradePointsScreen({
    super.key,
    required this.player,
    required this.onPlayerUpdate,
  });

  @override
  State<UpgradePointsScreen> createState() => _UpgradePointsScreenState();
}

class _UpgradePointsScreenState extends State<UpgradePointsScreen> {
  late int _availablePoints;
  late Stats _pendingUpgrades;

  @override
  void initState() {
    super.initState();
    _availablePoints = widget.player.upgradePoints;
    _pendingUpgrades = Stats(
      strength: 0,
      dexterity: 0,
      constitution: 0,
      intelligence: 0,
      wisdom: 0,
      charisma: 0,
    );
  }

  void _increaseStat(String statName) {
    if (_availablePoints <= 0) return;
    
    setState(() {
      _availablePoints--;
      switch (statName) {
        case 'strength':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength + 1,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'dexterity':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity + 1,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'constitution':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution + 1,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'intelligence':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence + 1,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'wisdom':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom + 1,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'charisma':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma + 1,
          );
          break;
      }
    });
  }

  void _decreaseStat(String statName) {
    int currentPending = 0;
    switch (statName) {
      case 'strength': currentPending = _pendingUpgrades.strength; break;
      case 'dexterity': currentPending = _pendingUpgrades.dexterity; break;
      case 'constitution': currentPending = _pendingUpgrades.constitution; break;
      case 'intelligence': currentPending = _pendingUpgrades.intelligence; break;
      case 'wisdom': currentPending = _pendingUpgrades.wisdom; break;
      case 'charisma': currentPending = _pendingUpgrades.charisma; break;
    }
    
    if (currentPending <= 0) return;
    
    setState(() {
      _availablePoints++;
      switch (statName) {
        case 'strength':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength - 1,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'dexterity':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity - 1,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'constitution':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution - 1,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'intelligence':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence - 1,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'wisdom':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom - 1,
            charisma: _pendingUpgrades.charisma,
          );
          break;
        case 'charisma':
          _pendingUpgrades = Stats(
            strength: _pendingUpgrades.strength,
            dexterity: _pendingUpgrades.dexterity,
            constitution: _pendingUpgrades.constitution,
            intelligence: _pendingUpgrades.intelligence,
            wisdom: _pendingUpgrades.wisdom,
            charisma: _pendingUpgrades.charisma - 1,
          );
          break;
      }
    });
  }

  void _applyUpgrades() {
    widget.player.baseStats = widget.player.baseStats.add(_pendingUpgrades);
    widget.player.upgradePoints = _availablePoints;
    widget.player.recalculateStats();
    widget.onPlayerUpdate(widget.player);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _availablePoints = widget.player.upgradePoints;
      _pendingUpgrades = Stats(
        strength: 0,
        dexterity: 0,
        constitution: 0,
        intelligence: 0,
        wisdom: 0,
        charisma: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Upgrade Points'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Points: $_availablePoints',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView(
                children: [
                  _buildStatRow('Strength', 'strength', widget.player.baseStats.strength),
                  _buildStatRow('Dexterity', 'dexterity', widget.player.baseStats.dexterity),
                  _buildStatRow('Constitution', 'constitution', widget.player.baseStats.constitution),
                  _buildStatRow('Intelligence', 'intelligence', widget.player.baseStats.intelligence),
                  _buildStatRow('Wisdom', 'wisdom', widget.player.baseStats.wisdom),
                  _buildStatRow('Charisma', 'charisma', widget.player.baseStats.charisma),
                ],
              ),
            ),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyUpgrades,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Apply Changes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Save for Later',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String statName, String statKey, int baseValue) {
    int pendingValue = 0;
    switch (statKey) {
      case 'strength': pendingValue = _pendingUpgrades.strength; break;
      case 'dexterity': pendingValue = _pendingUpgrades.dexterity; break;
      case 'constitution': pendingValue = _pendingUpgrades.constitution; break;
      case 'intelligence': pendingValue = _pendingUpgrades.intelligence; break;
      case 'wisdom': pendingValue = _pendingUpgrades.wisdom; break;
      case 'charisma': pendingValue = _pendingUpgrades.charisma; break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              statName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          Text(
            '$baseValue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          
          if (pendingValue > 0) ...[
            const Text(
              ' + ',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            Text(
              '$pendingValue',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const Text(
              ' = ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '${baseValue + pendingValue}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
          
          const Spacer(),
          
          IconButton(
            onPressed: pendingValue > 0 ? () => _decreaseStat(statKey) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.red,
            iconSize: 24,
          ),
          
          IconButton(
            onPressed: _availablePoints > 0 ? () => _increaseStat(statKey) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.green,
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}