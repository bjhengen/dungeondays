import 'package:flutter/material.dart';
import 'dart:math';
import '../models/enums.dart';
import '../models/stats.dart';
import '../models/player.dart';
import '../utils/item_generator.dart';
import 'game_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  Race _selectedRace = Race.human;
  CharacterClass _selectedClass = CharacterClass.warrior;
  CharacterAlignment _selectedAlignment = CharacterAlignment.neutralGood;
  String _selectedGender = 'Male';
  Stats _baseStats = Stats();
  
  final Map<Race, Map<String, int>> _racialBonuses = {
    Race.human: {'strength': 0, 'intelligence': 0, 'wisdom': 0, 'dexterity': 0, 'constitution': 0, 'charisma': 1, 'alertness': 0},
    Race.elf: {'strength': -1, 'intelligence': 1, 'wisdom': 1, 'dexterity': 1, 'constitution': -1, 'charisma': 0, 'alertness': 1},
    Race.darkElf: {'strength': 0, 'intelligence': 1, 'wisdom': 0, 'dexterity': 2, 'constitution': -1, 'charisma': 1, 'alertness': 0},
    Race.dwarf: {'strength': 2, 'intelligence': 0, 'wisdom': 1, 'dexterity': -1, 'constitution': 2, 'charisma': -1, 'alertness': 0},
    Race.gnome: {'strength': -2, 'intelligence': 2, 'wisdom': 1, 'dexterity': 1, 'constitution': -1, 'charisma': 1, 'alertness': 0},
  };
  
  final Map<CharacterClass, Map<String, int>> _classBonuses = {
    CharacterClass.warrior: {'strength': 2, 'intelligence': 0, 'wisdom': 0, 'dexterity': 1, 'constitution': 2, 'charisma': 0, 'alertness': 1},
    CharacterClass.thief: {'strength': 0, 'intelligence': 1, 'wisdom': 0, 'dexterity': 3, 'constitution': 0, 'charisma': 1, 'alertness': 2},
    CharacterClass.wizard: {'strength': -1, 'intelligence': 3, 'wisdom': 2, 'dexterity': 0, 'constitution': -1, 'charisma': 0, 'alertness': 0},
    CharacterClass.cleric: {'strength': 1, 'intelligence': 1, 'wisdom': 3, 'dexterity': 0, 'constitution': 1, 'charisma': 1, 'alertness': 0},
    CharacterClass.paladin: {'strength': 2, 'intelligence': 0, 'wisdom': 2, 'dexterity': 0, 'constitution': 1, 'charisma': 2, 'alertness': 0},
  };

  @override
  void initState() {
    super.initState();
    _generateStats();
  }

  void _generateStats() {
    final random = Random();
    _baseStats = Stats(
      strength: 8 + random.nextInt(8), // 8-15
      intelligence: 8 + random.nextInt(8),
      wisdom: 8 + random.nextInt(8),
      dexterity: 8 + random.nextInt(8),
      constitution: 8 + random.nextInt(8),
      charisma: 8 + random.nextInt(8),
      alertness: 8 + random.nextInt(8),
    );
    setState(() {});
  }

  Stats _calculateFinalStats() {
    final racialBonus = _racialBonuses[_selectedRace]!;
    final classBonus = _classBonuses[_selectedClass]!;
    
    return Stats(
      strength: _baseStats.strength + racialBonus['strength']! + classBonus['strength']!,
      intelligence: _baseStats.intelligence + racialBonus['intelligence']! + classBonus['intelligence']!,
      wisdom: _baseStats.wisdom + racialBonus['wisdom']! + classBonus['wisdom']!,
      dexterity: _baseStats.dexterity + racialBonus['dexterity']! + classBonus['dexterity']!,
      constitution: _baseStats.constitution + racialBonus['constitution']! + classBonus['constitution']!,
      charisma: _baseStats.charisma + racialBonus['charisma']! + classBonus['charisma']!,
      alertness: _baseStats.alertness + racialBonus['alertness']! + classBonus['alertness']!,
    );
  }

  void _createCharacter() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a character name')),
      );
      return;
    }

    final finalStats = _calculateFinalStats();
    final player = Player(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      race: _selectedRace,
      characterClass: _selectedClass,
      alignment: _selectedAlignment,
      baseStats: finalStats,
      maxHp: 80 + (finalStats.constitution * 2),
      maxMana: 30 + (finalStats.intelligence * 3),
    );
    
    player.currentHp = player.maxHp;
    player.currentMana = player.maxMana;
    
    // Give starting equipment
    final startingWeapon = ItemGenerator.generateStartingWeapon(_selectedClass);
    final startingArmor = ItemGenerator.generateStartingArmor(_selectedClass);
    final startingSupplies = ItemGenerator.generateStartingSupplies();
    
    player.equipment['weapon'] = startingWeapon;
    player.equipment['armor'] = startingArmor;
    
    for (final item in startingSupplies) {
      player.addToInventory(item);
    }

    // Give starting spells based on class
    _giveStartingSpells(player);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(player: player),
      ),
    );
  }

  void _giveStartingSpells(Player player) {
    switch (player.characterClass) {
      case CharacterClass.wizard:
        player.knownSpells.addAll([
          'magic_missile',
          'light',
          'detect_magic',
        ]);
        player.spellSchoolLevels[SpellSchool.evocation] = 1;
        player.spellSchoolLevels[SpellSchool.divination] = 1;
        break;
      case CharacterClass.cleric:
        player.knownSpells.addAll([
          'cure_wounds',
          'bless',
        ]);
        player.spellSchoolLevels[SpellSchool.conjuration] = 1;
        player.spellSchoolLevels[SpellSchool.enchantment] = 1;
        break;
      case CharacterClass.paladin:
        player.knownSpells.addAll([
          'cure_wounds',
        ]);
        player.spellSchoolLevels[SpellSchool.conjuration] = 1;
        break;
      case CharacterClass.warrior:
        // Warriors get no starting spells
        break;
      case CharacterClass.thief:
        player.knownSpells.addAll([
          'light',
        ]);
        player.spellSchoolLevels[SpellSchool.evocation] = 1;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalStats = _calculateFinalStats();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create Character'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 20),
            _buildGenderSelector(),
            const SizedBox(height: 20),
            _buildRaceSelector(),
            const SizedBox(height: 20),
            _buildClassSelector(),
            const SizedBox(height: 20),
            _buildAlignmentSelector(),
            const SizedBox(height: 20),
            _buildStatsDisplay(finalStats),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _generateStats,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Reroll Stats'),
                ),
                ElevatedButton(
                  onPressed: _createCharacter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Character'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Character Name:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(),
            hintText: 'Enter character name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female'].map((gender) => 
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value!),
                    fillColor: MaterialStateProperty.all(Colors.amber),
                  ),
                  Text(gender, style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                ],
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildRaceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Race:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          children: Race.values.map((race) => 
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<Race>(
                    value: race,
                    groupValue: _selectedRace,
                    onChanged: (value) => setState(() => _selectedRace = value!),
                    fillColor: MaterialStateProperty.all(Colors.amber),
                  ),
                  Text(_raceDisplayName(race), style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                ],
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          children: CharacterClass.values.map((charClass) => 
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<CharacterClass>(
                    value: charClass,
                    groupValue: _selectedClass,
                    onChanged: (value) => setState(() => _selectedClass = value!),
                    fillColor: MaterialStateProperty.all(Colors.amber),
                  ),
                  Text(_classDisplayName(charClass), style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                ],
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildAlignmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alignment:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<CharacterAlignment>(
          value: _selectedAlignment,
          onChanged: (value) => setState(() => _selectedAlignment = value!),
          items: CharacterAlignment.values.map((alignment) => 
            DropdownMenuItem(
              value: alignment,
              child: Text(_alignmentDisplayName(alignment), style: const TextStyle(fontFamily: 'monospace')),
            ),
          ).toList(),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          dropdownColor: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildStatsDisplay(Stats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Final Stats:', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              _buildStatRow('Strength', _baseStats.strength, stats.strength),
              _buildStatRow('Intelligence', _baseStats.intelligence, stats.intelligence),
              _buildStatRow('Wisdom', _baseStats.wisdom, stats.wisdom),
              _buildStatRow('Dexterity', _baseStats.dexterity, stats.dexterity),
              _buildStatRow('Constitution', _baseStats.constitution, stats.constitution),
              _buildStatRow('Charisma', _baseStats.charisma, stats.charisma),
              _buildStatRow('Alertness', _baseStats.alertness, stats.alertness),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int base, int finalValue) {
    final modifier = finalValue - base;
    final modifierText = modifier > 0 ? ' (+$modifier)' : modifier < 0 ? ' ($modifier)' : '';
    final modifierColor = modifier > 0 ? Colors.green : modifier < 0 ? Colors.red : Colors.white70;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
          Row(
            children: [
              Text('$finalValue', style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              Text(modifierText, style: TextStyle(color: modifierColor, fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  String _raceDisplayName(Race race) {
    switch (race) {
      case Race.darkElf: return 'Dark Elf';
      default: return race.name[0].toUpperCase() + race.name.substring(1);
    }
  }

  String _classDisplayName(CharacterClass charClass) {
    return charClass.name[0].toUpperCase() + charClass.name.substring(1);
  }

  String _alignmentDisplayName(CharacterAlignment alignment) {
    switch (alignment) {
      case CharacterAlignment.lawfulGood: return 'Lawful Good';
      case CharacterAlignment.neutralGood: return 'Neutral Good';
      case CharacterAlignment.chaoticGood: return 'Chaotic Good';
      case CharacterAlignment.lawfulNeutral: return 'Lawful Neutral';
      case CharacterAlignment.trueNeutral: return 'True Neutral';
      case CharacterAlignment.chaoticNeutral: return 'Chaotic Neutral';
      case CharacterAlignment.lawfulEvil: return 'Lawful Evil';
      case CharacterAlignment.neutralEvil: return 'Neutral Evil';
      case CharacterAlignment.chaoticEvil: return 'Chaotic Evil';
    }
  }
}