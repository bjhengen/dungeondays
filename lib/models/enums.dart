enum Race { human, elf, darkElf, dwarf, gnome }

enum CharacterClass { thief, wizard, cleric, warrior, paladin }

enum CharacterAlignment { 
  lawfulGood, neutralGood, chaoticGood,
  lawfulNeutral, trueNeutral, chaoticNeutral,
  lawfulEvil, neutralEvil, chaoticEvil
}

enum SpellSchool {
  evocation, enchantment, necromancy, divination, 
  illusion, conjuration, alchemy, elemental
}

enum ItemType {
  weapon, armor, shield, potion, scroll, 
  ring, amulet, food, misc, container
}

enum ItemRarity {
  common, uncommon, rare, epic, legendary
}

enum GuildType {
  thieves, blacksmiths, mages, warriors, 
  paladins, clerics, merchants, alchemists
}

enum Weather { clear, rain, snow }

enum Season { spring, summer, fall, winter }

enum NPCDisposition { friendly, neutral, hostile }

enum QuestType { delivery, kill, rescue, gather, exploration }

enum BuildingType { 
  inn, shop, guild, house, temple, smithy, 
  alchemist, bank, market, tavern, stable
}