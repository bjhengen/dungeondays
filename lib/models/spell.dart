import 'enums.dart';

class Spell {
  final String id;
  final String name;
  final String description;
  final SpellSchool school;
  final int level; // 1-9
  final int manaCost;
  final String castTime; // 'instant', 'combat', 'exploration'
  final String target; // 'self', 'enemy', 'ally', 'area'
  final Map<String, dynamic> effects;
  final int? duration; // in turns, null for instant
  
  const Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.school,
    required this.level,
    required this.manaCost,
    required this.castTime,
    required this.target,
    required this.effects,
    this.duration,
  });

  bool get canCastInCombat => castTime == 'instant' || castTime == 'combat';
  bool get canCastInExploration => castTime == 'instant' || castTime == 'exploration';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'school': school.index,
    'level': level,
    'manaCost': manaCost,
    'castTime': castTime,
    'target': target,
    'effects': effects,
    'duration': duration,
  };

  factory Spell.fromJson(Map<String, dynamic> json) => Spell(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    school: SpellSchool.values[json['school']],
    level: json['level'],
    manaCost: json['manaCost'],
    castTime: json['castTime'],
    target: json['target'],
    effects: Map<String, dynamic>.from(json['effects']),
    duration: json['duration'],
  );
}

class SpellBook {
  static const List<Spell> allSpells = [
    // Evocation Spells
    Spell(
      id: 'magic_missile',
      name: 'Magic Missile',
      description: 'Launches a bolt of magical energy at an enemy.',
      school: SpellSchool.evocation,
      level: 1,
      manaCost: 5,
      castTime: 'combat',
      target: 'enemy',
      effects: {'damage': 15, 'type': 'magic'},
    ),
    Spell(
      id: 'fireball',
      name: 'Fireball',
      description: 'A devastating ball of fire that damages all enemies.',
      school: SpellSchool.evocation,
      level: 3,
      manaCost: 15,
      castTime: 'combat',
      target: 'area',
      effects: {'damage': 25, 'type': 'fire'},
    ),
    Spell(
      id: 'light',
      name: 'Light',
      description: 'Creates a magical light that improves visibility.',
      school: SpellSchool.evocation,
      level: 1,
      manaCost: 3,
      castTime: 'exploration',
      target: 'self',
      effects: {'vision_bonus': 2},
      duration: 20,
    ),

    // Enchantment Spells
    Spell(
      id: 'charm_person',
      name: 'Charm Person',
      description: 'Makes a hostile NPC friendly temporarily.',
      school: SpellSchool.enchantment,
      level: 1,
      manaCost: 8,
      castTime: 'exploration',
      target: 'enemy',
      effects: {'charm': true},
      duration: 10,
    ),
    Spell(
      id: 'bless',
      name: 'Bless',
      description: 'Improves combat effectiveness.',
      school: SpellSchool.enchantment,
      level: 1,
      manaCost: 6,
      castTime: 'combat',
      target: 'self',
      effects: {'attack_bonus': 3, 'defense_bonus': 2},
      duration: 15,
    ),

    // Necromancy Spells
    Spell(
      id: 'drain_life',
      name: 'Drain Life',
      description: 'Steals health from an enemy.',
      school: SpellSchool.necromancy,
      level: 2,
      manaCost: 10,
      castTime: 'combat',
      target: 'enemy',
      effects: {'damage': 12, 'heal_self': 12, 'type': 'necrotic'},
    ),

    // Divination Spells
    Spell(
      id: 'detect_magic',
      name: 'Detect Magic',
      description: 'Reveals magical auras and hidden properties.',
      school: SpellSchool.divination,
      level: 1,
      manaCost: 4,
      castTime: 'exploration',
      target: 'self',
      effects: {'detect_magic': true},
      duration: 30,
    ),
    Spell(
      id: 'identify',
      name: 'Identify',
      description: 'Reveals the properties of a magical item.',
      school: SpellSchool.divination,
      level: 1,
      manaCost: 8,
      castTime: 'exploration',
      target: 'self',
      effects: {'identify_item': true},
    ),

    // Conjuration Spells
    Spell(
      id: 'cure_wounds',
      name: 'Cure Wounds',
      description: 'Heals wounds with divine magic.',
      school: SpellSchool.conjuration,
      level: 1,
      manaCost: 6,
      castTime: 'instant',
      target: 'self',
      effects: {'heal': 20},
    ),
    Spell(
      id: 'teleport',
      name: 'Teleport',
      description: 'Instantly travel to a known location.',
      school: SpellSchool.conjuration,
      level: 5,
      manaCost: 25,
      castTime: 'exploration',
      target: 'self',
      effects: {'teleport': true},
    ),

    // Illusion Spells
    Spell(
      id: 'invisibility',
      name: 'Invisibility',
      description: 'Become invisible to enemies.',
      school: SpellSchool.illusion,
      level: 2,
      manaCost: 12,
      castTime: 'exploration',
      target: 'self',
      effects: {'invisible': true},
      duration: 10,
    ),

    // Alchemy Spells
    Spell(
      id: 'transmute',
      name: 'Transmute',
      description: 'Transform base materials into more valuable ones.',
      school: SpellSchool.alchemy,
      level: 3,
      manaCost: 15,
      castTime: 'exploration',
      target: 'self',
      effects: {'transmute': true},
    ),

    // Elemental Spells
    Spell(
      id: 'ice_shard',
      name: 'Ice Shard',
      description: 'Launches a piercing shard of ice.',
      school: SpellSchool.elemental,
      level: 2,
      manaCost: 8,
      castTime: 'combat',
      target: 'enemy',
      effects: {'damage': 18, 'type': 'cold'},
    ),
  ];

  static List<Spell> getSpellsForSchool(SpellSchool school) {
    return allSpells.where((spell) => spell.school == school).toList();
  }

  static List<Spell> getSpellsForLevel(int level) {
    return allSpells.where((spell) => spell.level <= level).toList();
  }

  static Spell? getSpellById(String id) {
    try {
      return allSpells.firstWhere((spell) => spell.id == id);
    } catch (e) {
      return null;
    }
  }
}