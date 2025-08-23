class Stats {
  int strength;
  int intelligence;
  int wisdom;
  int dexterity;
  int constitution;
  int charisma;
  int alertness;

  Stats({
    this.strength = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.charisma = 10,
    this.alertness = 10,
  });

  Map<String, dynamic> toJson() => {
    'strength': strength,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'dexterity': dexterity,
    'constitution': constitution,
    'charisma': charisma,
    'alertness': alertness,
  };

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    strength: json['strength'] ?? 10,
    intelligence: json['intelligence'] ?? 10,
    wisdom: json['wisdom'] ?? 10,
    dexterity: json['dexterity'] ?? 10,
    constitution: json['constitution'] ?? 10,
    charisma: json['charisma'] ?? 10,
    alertness: json['alertness'] ?? 10,
  );

  Stats copy() => Stats(
    strength: strength,
    intelligence: intelligence,
    wisdom: wisdom,
    dexterity: dexterity,
    constitution: constitution,
    charisma: charisma,
    alertness: alertness,
  );

  Stats add(Stats other) => Stats(
    strength: strength + other.strength,
    intelligence: intelligence + other.intelligence,
    wisdom: wisdom + other.wisdom,
    dexterity: dexterity + other.dexterity,
    constitution: constitution + other.constitution,
    charisma: charisma + other.charisma,
    alertness: alertness + other.alertness,
  );
}