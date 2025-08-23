# Dungeon Days

A magic-focused ASCII roguelike game built with Flutter for mobile platforms (Android/iOS).

## 🎯 Project Overview

Dungeon Days is inspired by classic ASCII roguelikes like Moria, RAR, and RARII. The game emphasizes magical gameplay with deep character progression, settlement exploration, and strategic turn-based combat.

## ✨ Current Features

### Core Gameplay
- **Turn-based ASCII gameplay** with color-coded symbols
- **Character creation** with 5 races, 5 classes, and 9 alignments  
- **Level progression** (1-75) with upgrade point allocation
- **Day/night cycle** with weather and seasonal effects

### Settlement System
- **Detailed town exploration** with buildings and NPCs
- **Guild system** with class-specific services and training
- **Shop system** for equipment, potions, food, and spell scrolls
- **Inn services** including sleep, meals, and drinks
- **Banking system** for money management

### Combat & Magic
- **Turn-based combat** with dice-based damage system
- **Critical hits and brilliant defense** mechanics
- **Spell system foundation** with 15+ spells across 8 schools
- **Magic scrolls** available for purchase and use
- **Experience and loot rewards** for victories

### Character Progression  
- **Equipment system** with stat modifiers
- **Inventory management** with consumable items
- **Spell schools**: Evocation, Enchantment, Necromancy, Divination, Illusion, Conjuration, Alchemy, Elemental
- **Upgrade points** for stat customization

## 🎮 How to Play

### Development Setup
```bash
# Ensure Flutter is installed and PATH is configured
flutter --version

# Run on iOS Simulator
flutter run -d [iOS_DEVICE_ID]

# Run on Chrome (Web)
flutter run -d chrome --web-port 3002
```

### Controls
- **Movement**: Use directional arrow buttons to move around
- **Interactions**: Tap NPCs, buildings, and items to interact
- **Combat**: Choose Attack, Defend, or Flee during battles
- **Inventory**: Access via the Inventory button in towns
- **Sleep**: Rest at inns to restore health/mana and advance time

### Character Classes
- **Warrior**: Strong melee fighter with heavy armor
- **Thief**: Agile character with stealth and lockpicking (planned)
- **Wizard**: Master of arcane magic and spells
- **Cleric**: Divine magic user with healing abilities
- **Paladin**: Holy warrior combining combat and divine magic

## 🗂️ Project Structure

```
lib/
├── models/          # Data models (Player, World, NPC, Spell, etc.)
├── screens/         # UI screens (Game, Combat, Town, Inventory, etc.)
├── widgets/         # Reusable UI components (ASCII display, stats bar)
├── services/        # Game logic (World generation, Town generation)
└── utils/           # Utilities (Item generation, Save/Load)
```

## 🚧 Development Status

**Current Version**: Alpha - Core systems implemented

### ✅ Completed Systems
- Character creation and progression
- World generation and town layouts
- Turn-based combat with loot rewards
- NPC interaction and dialogue
- Shop and guild systems
- Time progression and weather
- Save/load functionality
- Equipment and inventory systems
- Spell system foundation

### 🔄 In Progress
- Spell casting mechanics and UI
- Class-specific skills and abilities
- Guild-based spell learning

### 📋 Planned Features
- Quest system and storylines
- Dungeon generation and exploration
- NPC companion system
- Base building and property ownership
- Transportation systems
- Endgame content and advanced progression

## 🛠️ Technical Details

- **Framework**: Flutter 3.35.1
- **Platform**: Cross-platform (iOS, Android, Web)
- **Rendering**: Custom ASCII display with Canvas painting
- **Architecture**: Model-View pattern with service layers
- **Persistence**: SharedPreferences for save/load system

## 📖 Game Design

### Magic Schools
1. **Evocation**: Direct damage and energy manipulation
2. **Enchantment**: Mind control and status effects  
3. **Necromancy**: Death magic and life drain
4. **Divination**: Detection and identification spells
5. **Illusion**: Invisibility and deception magic
6. **Conjuration**: Summoning and teleportation
7. **Alchemy**: Transmutation and material magic
8. **Elemental**: Fire, ice, and elemental forces

### Alignment System
Characters have both ethical (Good/Neutral/Evil) and moral (Lawful/Neutral/Chaotic) alignments that affect NPC interactions, available guilds, and story options.

## 📄 Documentation

See `PROJECT_STATUS.txt` for detailed development progress and technical notes.

## 🎯 Vision

The goal is to create a deep, engaging mobile roguelike that captures the magic and complexity of classic ASCII games while being accessible on modern mobile devices. The focus on magic systems and strategic combat aims to provide rich gameplay for roguelike enthusiasts.

---

*Dungeon Days - Where magic meets adventure in the depths of ASCII dungeons.*