import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/spell.dart';
import '../models/enums.dart';

class SpellbookScreen extends StatefulWidget {
  final Player player;
  final Function(Spell spell)? onSpellCast;
  final String castingContext; // 'exploration', 'combat', or 'inventory'
  final Function(Player)? onPlayerUpdate;

  const SpellbookScreen({
    super.key,
    required this.player,
    this.onSpellCast,
    required this.castingContext,
    this.onPlayerUpdate,
  });

  @override
  State<SpellbookScreen> createState() => _SpellbookScreenState();
}

class _SpellbookScreenState extends State<SpellbookScreen> {
  SpellSchool? _selectedSchool;
  
  @override
  Widget build(BuildContext context) {
    final knownSpells = _getKnownSpells();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Spellbook (${widget.castingContext})'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mana display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade900,
                border: Border.all(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.deepPurple.shade300),
                  const SizedBox(width: 8),
                  Text(
                    'Mana: ${widget.player.currentMana}/${widget.player.maxMana}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // School filter
            if (knownSpells.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by School:',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedSchool == null,
                          onSelected: (selected) => setState(() => _selectedSchool = null),
                          backgroundColor: Colors.black,
                          selectedColor: Colors.deepPurple.shade800,
                          labelStyle: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        ),
                        ...SpellSchool.values.map((school) => FilterChip(
                          label: Text(_getSchoolName(school)),
                          selected: _selectedSchool == school,
                          onSelected: (selected) => setState(() => _selectedSchool = selected ? school : null),
                          backgroundColor: Colors.black,
                          selectedColor: Colors.deepPurple.shade800,
                          labelStyle: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Spells list
            Expanded(
              child: knownSpells.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          'No spells learned yet',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 18,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visit a Mage Guild to learn spells',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _getFilteredSpells(knownSpells).length,
                    itemBuilder: (context, index) {
                      final spell = _getFilteredSpells(knownSpells)[index];
                      final canCast = _canCastSpell(spell);
                      
                      return Card(
                        color: Colors.black87,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            _getSchoolIcon(spell.school),
                            color: _getSchoolColor(spell.school),
                          ),
                          title: Text(
                            spell.name,
                            style: TextStyle(
                              color: canCast ? Colors.white : Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spell.description,
                                style: TextStyle(
                                  color: canCast ? Colors.white70 : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Level ${spell.level} • ${spell.manaCost} MP',
                                    style: TextStyle(
                                      color: _getSchoolColor(spell.school),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getSchoolColor(spell.school).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getSchoolName(spell.school),
                                      style: TextStyle(
                                        color: _getSchoolColor(spell.school),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: widget.onSpellCast != null
                              ? ElevatedButton(
                                  onPressed: canCast ? () => _castSpell(spell) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canCast ? Colors.deepPurple.shade700 : Colors.grey.shade800,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(60, 32),
                                  ),
                                  child: const Text('Cast', style: TextStyle(fontFamily: 'monospace')),
                                )
                              : null,
                          onTap: widget.onSpellCast == null ? null : (canCast ? () => _castSpell(spell) : null),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<Spell> _getKnownSpells() {
    return widget.player.knownSpells
        .map((spellId) => SpellBook.getSpellById(spellId))
        .where((spell) => spell != null)
        .cast<Spell>()
        .toList();
  }

  List<Spell> _getFilteredSpells(List<Spell> spells) {
    if (_selectedSchool == null) return spells;
    return spells.where((spell) => spell.school == _selectedSchool).toList();
  }

  bool _canCastSpell(Spell spell) {
    if (widget.player.currentMana < spell.manaCost) return false;
    
    switch (widget.castingContext) {
      case 'combat':
        return spell.canCastInCombat;
      case 'exploration':
        return spell.canCastInExploration;
      case 'inventory':
        return true; // Can view all spells in inventory mode
      default:
        return false;
    }
  }

  void _castSpell(Spell spell) {
    if (!_canCastSpell(spell)) return;
    
    // Deduct mana
    widget.player.currentMana -= spell.manaCost;
    
    // Call the spell cast callback
    widget.onSpellCast?.call(spell);
    
    // Update player if callback provided
    widget.onPlayerUpdate?.call(widget.player);
    
    // For inventory mode or if no callback provided, just refresh the UI
    // For combat and exploration, stay in spellbook after casting
    setState(() {}); // Refresh to show updated mana
  }

  String _getSchoolName(SpellSchool school) {
    return school.toString().split('.').last.capitalize();
  }

  IconData _getSchoolIcon(SpellSchool school) {
    switch (school) {
      case SpellSchool.evocation:
        return Icons.flash_on;
      case SpellSchool.enchantment:
        return Icons.psychology;
      case SpellSchool.necromancy:
        return Icons.dark_mode;
      case SpellSchool.divination:
        return Icons.visibility;
      case SpellSchool.illusion:
        return Icons.blur_on;
      case SpellSchool.conjuration:
        return Icons.healing;
      case SpellSchool.alchemy:
        return Icons.science;
      case SpellSchool.elemental:
        return Icons.ac_unit;
    }
  }

  Color _getSchoolColor(SpellSchool school) {
    switch (school) {
      case SpellSchool.evocation:
        return Colors.orange;
      case SpellSchool.enchantment:
        return Colors.pink;
      case SpellSchool.necromancy:
        return Colors.purple.shade900;
      case SpellSchool.divination:
        return Colors.lightBlue;
      case SpellSchool.illusion:
        return Colors.indigo;
      case SpellSchool.conjuration:
        return Colors.green;
      case SpellSchool.alchemy:
        return Colors.amber;
      case SpellSchool.elemental:
        return Colors.cyan;
    }
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}