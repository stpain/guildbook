--[[

]]

local addonName, addon = ...;

local Tradeskills = addon.Tradeskills;

addon.playerContainers = {};

local talentBackgroundToSpec = {
    ["DeathKnightBlood"] = "Blood",
    ["DeathKnightFrost"] = "Frost",
    ["DeathKnightUnholy"] = "Unholy",
    ["DruidBalance"] = "Balance",
    ["DruidFeralCombat"] = "Bear",
    ["DruidRestoration"] = "Restoration",
    ["HunterBeastMastery"] = "BeastMaster",
    ["HunterMarksmanship"] = "IMarksmanship",
    ["HunterSurvival"] = "Survival",
    ["MageArcane"] = "Arcane",
    ["MageFire"] = "Fire",
    ["MageFrost"] = "Frost",
    ["PaladinCombat"] = "Retribution",
    ["PaladinHoly"] = "Holy",
    ["PaladinProtection"] = "Protection",
    ["PriestDiscipline"] = "Discipline",
    ["PriestHoly"] = "Holy",
    ["PriestShadow"] = "Shadow",
    ["RogueAssassination"] = "Assassination",
    ["RogueCombat"] = "Combat",
    ["RogueSubtlety"] = "Subtlety",
    ["ShamanElementalCombat"] = "Elemental",
    ["ShamanEnhancement"] = "Enhancement",
    ["ShamanRestoration"] = "Restoration",
    ["WarlockCurses"] = "Affliction",
    ["WarlockDestruction"] = "Destruction",
    ["WarlockSummoning"] = "Demonology",
    ["WarriorArms"] = "Arms",
    ["WarriorFury"] = "Fury",
    ["WarriorProtection"] = "Protection",
}


local glyphsData = {
    {
		type = "Major",
		name = "Glyph of Mass Dispel",
		requiredLevel = 70,
		class = "PRIEST",
		level = 75,
		itemId = 42404,
	}, -- [1]
	{
		type = "Major",
		name = "Glyph of Vigor",
		requiredLevel = 70,
		class = "ROGUE",
		level = 75,
		itemId = 42971,
	}, -- [2]
	{
		type = "Major",
		name = "Glyph of Frostfire",
		requiredLevel = 75,
		class = "MAGE",
		level = 75,
		itemId = 44684,
	}, -- [3]
	{
		type = "Major",
		name = "Glyph of Fire Elemental Totem",
		requiredLevel = 68,
		class = "SHAMAN",
		level = 73,
		itemId = 41529,
	}, -- [4]
	{
		type = "Major",
		name = "Glyph of Invisibility",
		requiredLevel = 68,
		class = "MAGE",
		level = 73,
		itemId = 42748,
	}, -- [5]
	{
		type = "Major",
		name = "Glyph of Snake Trap",
		requiredLevel = 68,
		class = "HUNTER",
		level = 73,
		itemId = 42913,
	}, -- [6]
	{
		type = "Major",
		name = "Glyph of Lifebloom",
		requiredLevel = 64,
		class = "DRUID",
		level = 71,
		itemId = 40915,
	}, -- [7]
	{
		type = "Major",
		name = "Glyph of Lava",
		requiredLevel = 66,
		class = "SHAMAN",
		level = 71,
		itemId = 41524,
	}, -- [8]
	{
		type = "Major",
		name = "Glyph of Ice Lance",
		requiredLevel = 66,
		class = "MAGE",
		level = 71,
		itemId = 42745,
	}, -- [9]
	{
		type = "Major",
		name = "Glyph of Avenging Wrath",
		requiredLevel = 70,
		class = "PALADIN",
		level = 70,
		itemId = 41107,
	}, -- [10]
	{
		type = "Minor",
		name = "Glyph of Curse of Exhaustion",
		requiredLevel = 70,
		class = "WARLOCK",
		level = 70,
		itemId = 43392,
	}, -- [11]
	{
		type = "Major",
		name = "Glyph of Intervene",
		requiredLevel = 70,
		class = "WARRIOR",
		level = 70,
		itemId = 43419,
	}, -- [12]
	{
		type = "Minor",
		name = "Glyph of Blast Wave",
		requiredLevel = 70,
		class = "MAGE",
		level = 70,
		itemId = 44920,
	}, -- [13]
	{
		type = "Minor",
		name = "Glyph of Typhoon",
		requiredLevel = 70,
		class = "DRUID",
		level = 70,
		itemId = 44922,
	}, -- [14]
	{
		type = "Minor",
		name = "Glyph of Thunderstorm",
		requiredLevel = 70,
		class = "SHAMAN",
		level = 70,
		itemId = 44923,
	}, -- [15]
	{
		type = "Major",
		name = "Glyph of Focus",
		requiredLevel = 70,
		class = "DRUID",
		level = 70,
		itemId = 44928,
	}, -- [16]
	{
		type = "Major",
		name = "Glyph of Deadly Throw",
		requiredLevel = 64,
		class = "ROGUE",
		level = 69,
		itemId = 42959,
	}, -- [17]
	{
		type = "Minor",
		name = "Glyph of Souls",
		requiredLevel = 68,
		class = "WARLOCK",
		level = 68,
		itemId = 43394,
	}, -- [18]
	{
		type = "Minor",
		name = "Glyph of Command",
		requiredLevel = 68,
		class = "WARRIOR",
		level = 68,
		itemId = 49084,
	}, -- [19]
	{
		type = "Major",
		name = "Glyph of Shadow Word: Death",
		requiredLevel = 62,
		class = "PRIEST",
		level = 67,
		itemId = 42414,
	}, -- [20]
	{
		type = "Major",
		name = "Glyph of Molten Armor",
		requiredLevel = 62,
		class = "MAGE",
		level = 67,
		itemId = 42751,
	}, -- [21]
	{
		type = "Major",
		name = "Glyph of Steady Shot",
		requiredLevel = 62,
		class = "HUNTER",
		level = 67,
		itemId = 42914,
	}, -- [22]
	{
		type = "Minor",
		name = "Glyph of Shadowfiend",
		requiredLevel = 66,
		class = "PRIEST",
		level = 66,
		itemId = 43374,
	}, -- [23]
	{
		type = "Major",
		name = "Glyph of Starfall",
		requiredLevel = 60,
		class = "DRUID",
		level = 65,
		itemId = 40921,
	}, -- [24]
	{
		type = "Major",
		name = "Glyph of Arcane Blast",
		requiredLevel = 64,
		class = "MAGE",
		level = 64,
		itemId = 44955,
	}, -- [25]
	{
		type = "Minor",
		name = "Glyph of Enduring Victory",
		requiredLevel = 62,
		class = "WARRIOR",
		level = 62,
		itemId = 43400,
	}, -- [26]
	{
		type = "Major",
		name = "Glyph of Mangle",
		requiredLevel = 50,
		class = "DRUID",
		level = 55,
		itemId = 40900,
	}, -- [27]
	{
		type = "Major",
		name = [[Glyph of Avenger's Shield]],
		requiredLevel = 50,
		class = "PALADIN",
		level = 55,
		itemId = 41101,
	}, -- [28]
	{
		type = "Major",
		name = "Glyph of Elemental Mastery",
		requiredLevel = 50,
		class = "SHAMAN",
		level = 55,
		itemId = 41552,
	}, -- [29]
	{
		type = "Major",
		name = "Glyph of Circle of Healing",
		requiredLevel = 50,
		class = "PRIEST",
		level = 55,
		itemId = 42396,
	}, -- [30]
	{
		type = "Major",
		name = "Glyph of Felguard",
		requiredLevel = 50,
		class = "WARLOCK",
		level = 55,
		itemId = 42459,
	}, -- [31]
	{
		type = "Major",
		name = "Glyph of Unstable Affliction",
		requiredLevel = 50,
		class = "WARLOCK",
		level = 55,
		itemId = 42472,
	}, -- [32]
	{
		type = "Major",
		name = "Glyph of Water Elemental",
		requiredLevel = 50,
		class = "MAGE",
		level = 55,
		itemId = 42754,
	}, -- [33]
	{
		type = "Major",
		name = "Glyph of Anti-Magic Shell",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43533,
	}, -- [34]
	{
		type = "Major",
		name = "Glyph of Heart Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43534,
	}, -- [35]
	{
		type = "Minor",
		name = "Glyph of Blood Tap",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43535,
	}, -- [36]
	{
		type = "Major",
		name = "Glyph of Bone Shield",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43536,
	}, -- [37]
	{
		type = "Major",
		name = "Glyph of Chains of Ice",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43537,
	}, -- [38]
	{
		type = "Major",
		name = "Glyph of Dark Command",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43538,
	}, -- [39]
	{
		type = "Minor",
		name = [[Glyph of Death's Embrace]],
		requiredLevel = "55",
		class = "DEATH KNIGHT",
		level = "55",
        itemId = 43539,
	}, -- [40]
	{
		type = "Major",
		name = "Glyph of Death Grip",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43541,
	}, -- [41]
	{
		type = "Major",
		name = "Glyph of Death and Decay",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43542,
	}, -- [42]
	{
		type = "Major",
		name = "Glyph of Frost Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43543,
	}, -- [43]
	{
		type = "Minor",
		name = "Glyph of Horn of Winter",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43544,
	}, -- [44]
	{
		type = "Major",
		name = "Glyph of Icebound Fortitude",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43545,
	}, -- [45]
	{
		type = "Major",
		name = "Glyph of Icy Touch",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43546,
	}, -- [46]
	{
		type = "Major",
		name = "Glyph of Obliterate",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43547,
	}, -- [47]
	{
		type = "Major",
		name = "Glyph of Plague Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43548,
	}, -- [48]
	{
		type = "Major",
		name = "Glyph of the Ghoul",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43549,
	}, -- [49]
	{
		type = "Major",
		name = "Glyph of Rune Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43550,
	}, -- [50]
	{
		type = "Major",
		name = "Glyph of Scourge Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43551,
	}, -- [51]
	{
		type = "Major",
		name = "Glyph of Strangulate",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43552,
	}, -- [52]
	{
		type = "Major",
		name = "Glyph of Unbreakable Armor",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43553,
	}, -- [53]
	{
		type = "Major",
		name = "Glyph of Vampiric Blood",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43554,
	}, -- [54]
	{
		type = "Minor",
		name = "Glyph of Corpse Explosion",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43671,
	}, -- [55]
	{
		type = "Minor",
		name = "Glyph of Pestilence",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43672,
	}, -- [56]
	{
		type = "Minor",
		name = "Glyph of Raise Dead",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 44432,
	}, -- [57]
	{
		type = "Major",
		name = "Glyph of Rune Tap",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43825,
	}, -- [58]
	{
		type = "Major",
		name = "Glyph of Blood Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43826,
	}, -- [59]
	{
		type = "Major",
		name = "Glyph of Death Strike",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 43827,
	}, -- [60]
	{
		type = "Major",
		name = "Glyph of Holy Wrath",
		requiredLevel = 50,
		class = "PALADIN",
		level = 55,
		itemId = 43867,
	}, -- [61]
	{
		type = "Major",
		name = "Glyph of Seal of Righteousness",
		requiredLevel = 50,
		class = "PALADIN",
		level = 55,
		itemId = 43868,
	}, -- [62]
	{
		type = "Major",
		name = "Glyph of Seal of Vengeance",
		requiredLevel = 50,
		class = "PALADIN",
		level = 55,
		itemId = 43869,
	}, -- [63]
	{
		type = "Major",
		name = "Glyph of Raise Dead",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 55,
		itemId = 44432,
	}, -- [64]
	{
		type = "Major",
		name = "Glyph of Eternal Water",
		requiredLevel = 50,
		class = "MAGE",
		level = 55,
		itemId = 50045,
	}, -- [65]
	{
		type = "Major",
		name = "Glyph of Devastate",
		requiredLevel = 50,
		class = "WARRIOR",
		level = 50,
		itemId = 43415,
	}, -- [66]
	{
		type = "Major",
		name = "Glyph of Hammer of Wrath",
		requiredLevel = 44,
		class = "PALADIN",
		level = 49,
		itemId = 41097,
	}, -- [67]
	{
		type = "Major",
		name = "Glyph of Death Coil",
		requiredLevel = 42,
		class = "WARLOCK",
		level = 47,
		itemId = 42457,
	}, -- [68]
	{
		type = "Major",
		name = "Glyph of Swiftmend",
		requiredLevel = 40,
		class = "DRUID",
		level = 45,
		itemId = 40906,
	}, -- [69]
	{
		type = "Major",
		name = "Glyph of Innervate",
		requiredLevel = 40,
		class = "DRUID",
		level = 45,
		itemId = 40908,
	}, -- [70]
	{
		type = "Major",
		name = "Glyph of Hurricane",
		requiredLevel = 40,
		class = "DRUID",
		level = 45,
		itemId = 40920,
	}, -- [71]
	{
		type = "Major",
		name = "Glyph of Chain Heal",
		requiredLevel = 40,
		class = "SHAMAN",
		level = 45,
		itemId = 41517,
	}, -- [72]
	{
		type = "Major",
		name = "Glyph of Mana Tide Totem",
		requiredLevel = 40,
		class = "SHAMAN",
		level = 45,
		itemId = 41538,
	}, -- [73]
	{
		type = "Major",
		name = "Glyph of Stormstrike",
		requiredLevel = 40,
		class = "SHAMAN",
		level = 45,
		itemId = 41539,
	}, -- [74]
	{
		type = "Major",
		name = "Glyph of Lightwell",
		requiredLevel = 40,
		class = "PRIEST",
		level = 45,
		itemId = 42403,
	}, -- [75]
	{
		type = "Major",
		name = "Glyph of Conflagrate",
		requiredLevel = 40,
		class = "WARLOCK",
		level = 45,
		itemId = 42454,
	}, -- [76]
	{
		type = "Major",
		name = "Glyph of Howl of Terror",
		requiredLevel = 40,
		class = "WARLOCK",
		level = 45,
		itemId = 42463,
	}, -- [77]
	{
		type = "Major",
		name = "Glyph of Arcane Power",
		requiredLevel = 40,
		class = "MAGE",
		level = 45,
		itemId = 42736,
	}, -- [78]
	{
		type = "Major",
		name = "Glyph of Bestial Wrath",
		requiredLevel = 40,
		class = "HUNTER",
		level = 45,
		itemId = 42902,
	}, -- [79]
	{
		type = "Major",
		name = "Glyph of Trueshot Aura",
		requiredLevel = 40,
		class = "HUNTER",
		level = 45,
		itemId = 42915,
	}, -- [80]
	{
		type = "Major",
		name = "Glyph of Volley",
		requiredLevel = 40,
		class = "HUNTER",
		level = 45,
		itemId = 42916,
	}, -- [81]
	{
		type = "Major",
		name = "Glyph of Wyvern Sting",
		requiredLevel = 40,
		class = "HUNTER",
		level = 45,
		itemId = 42917,
	}, -- [82]
	{
		type = "Major",
		name = "Glyph of Adrenaline Rush",
		requiredLevel = 40,
		class = "ROGUE",
		level = 45,
		itemId = 42954,
	}, -- [83]
	{
		type = "Major",
		name = "Glyph of Berserk",
		requiredLevel = 60,
		class = "DRUID",
		level = 45,
		itemId = 45601,
	}, -- [84]
	{
		type = "Major",
		name = "Glyph of Wild Growth",
		requiredLevel = 60,
		class = "DRUID",
		level = 45,
		itemId = 45602,
	}, -- [85]
	{
		type = "Major",
		name = "Glyph of Nourish",
		requiredLevel = 80,
		class = "DRUID",
		level = 45,
		itemId = 45603,
	}, -- [86]
	{
		type = "Major",
		name = "Glyph of Savage Roar",
		requiredLevel = 75,
		class = "DRUID",
		level = 45,
		itemId = 45604,
	}, -- [87]
	{
		type = "Major",
		name = "Glyph of Monsoon",
		requiredLevel = 50,
		class = "DRUID",
		level = 45,
		itemId = 45622,
	}, -- [88]
	{
		type = "Major",
		name = "Glyph of Barkskin",
		requiredLevel = 44,
		class = "DRUID",
		level = 45,
		itemId = 45623,
	}, -- [89]
	{
		type = "Major",
		name = "Glyph of Chimera Shot",
		requiredLevel = 60,
		class = "HUNTER",
		level = 45,
		itemId = 45625,
	}, -- [90]
	{
		type = "Major",
		name = "Glyph of Explosive Shot",
		requiredLevel = 60,
		class = "HUNTER",
		level = 45,
		itemId = 45731,
	}, -- [91]
	{
		type = "Major",
		name = "Glyph of Kill Shot",
		requiredLevel = 71,
		class = "HUNTER",
		level = 45,
		itemId = 45732,
	}, -- [92]
	{
		type = "Major",
		name = "Glyph of Explosive Trap",
		requiredLevel = 34,
		class = "HUNTER",
		level = 45,
		itemId = 45733,
	}, -- [93]
	{
		type = "Major",
		name = "Glyph of Scatter Shot",
		requiredLevel = 20,
		class = "HUNTER",
		level = 45,
		itemId = 45734,
	}, -- [94]
	{
		type = "Major",
		name = "Glyph of Raptor Strike",
		requiredLevel = 15,
		class = "HUNTER",
		level = 45,
		itemId = 45735,
	}, -- [95]
	{
		type = "Major",
		name = "Glyph of Deep Freeze",
		requiredLevel = 60,
		class = "MAGE",
		level = 45,
		itemId = 45736,
	}, -- [96]
	{
		type = "Major",
		name = "Glyph of Envenom",
		requiredLevel = 62,
		class = "ROGUE",
		level = 45,
		itemId = 45908,
	}, -- [97]
	{
		type = "Major",
		name = "Glyph of Seal of Wisdom",
		requiredLevel = 38,
		class = "PALADIN",
		level = 43,
		itemId = 41109,
	}, -- [98]
	{
		type = "Major",
		name = "Glyph of Frenzied Regeneration",
		requiredLevel = 36,
		class = "DRUID",
		level = 41,
		itemId = 40896,
	}, -- [99]
	{
		type = "Minor",
		name = "Glyph of the Pack",
		requiredLevel = 40,
		class = "HUNTER",
		level = 40,
		itemId = 43355,
	}, -- [100]
	{
		type = "Minor",
		name = "Glyph of Safe Fall",
		requiredLevel = 40,
		class = "ROGUE",
		level = 40,
		itemId = 43378,
	}, -- [101]
	{
		type = "Major",
		name = "Glyph of Bloodthirst",
		requiredLevel = 40,
		class = "WARRIOR",
		level = 40,
		itemId = 43412,
	}, -- [102]
	{
		type = "Major",
		name = "Glyph of Mortal Strike",
		requiredLevel = 40,
		class = "WARRIOR",
		level = 40,
		itemId = 43421,
	}, -- [103]
	{
		type = "Major",
		name = "Glyph of Blocking",
		requiredLevel = 40,
		class = "WARRIOR",
		level = 40,
		itemId = 43425,
	}, -- [104]
	{
		type = "Major",
		name = "Glyph of Mage Armor",
		requiredLevel = 34,
		class = "MAGE",
		level = 39,
		itemId = 42749,
	}, -- [105]
	{
		type = "Major",
		name = "Glyph of Chain Lightning",
		requiredLevel = 32,
		class = "SHAMAN",
		level = 37,
		itemId = 41518,
	}, -- [106]
	{
		type = "Major",
		name = "Glyph of Whirlwind",
		requiredLevel = 36,
		class = "WARRIOR",
		level = 36,
		itemId = 43432,
	}, -- [107]
	{
		type = "Major",
		name = "Glyph of Cleansing",
		requiredLevel = 35,
		class = "PALADIN",
		level = 35,
		itemId = 41104,
	}, -- [108]
	{
		type = "Major",
		name = "Glyph of Seal of Light",
		requiredLevel = 30,
		class = "PALADIN",
		level = 35,
		itemId = 41110,
	}, -- [109]
	{
		type = "Major",
		name = "Glyph of Earthliving Weapon",
		requiredLevel = 30,
		class = "SHAMAN",
		level = 35,
		itemId = 41527,
	}, -- [110]
	{
		type = "Major",
		name = "Glyph of Windfury Weapon",
		requiredLevel = 30,
		class = "SHAMAN",
		level = 35,
		itemId = 41542,
	}, -- [111]
	{
		type = "Major",
		name = "Glyph of Mind Control",
		requiredLevel = 30,
		class = "PRIEST",
		level = 35,
		itemId = 42405,
	}, -- [112]
	{
		type = "Major",
		name = "Glyph of Prayer of Healing",
		requiredLevel = 30,
		class = "PRIEST",
		level = 35,
		itemId = 42409,
	}, -- [113]
	{
		type = "Major",
		name = "Glyph of Spirit of Redemption",
		requiredLevel = 30,
		class = "PRIEST",
		level = 35,
		itemId = 42417,
	}, -- [114]
	{
		type = "Major",
		name = "Glyph of Felhunter",
		requiredLevel = 30,
		class = "WARLOCK",
		level = 35,
		itemId = 42460,
	}, -- [115]
	{
		type = "Major",
		name = "Glyph of Siphon Life",
		requiredLevel = 30,
		class = "WARLOCK",
		level = 35,
		itemId = 42469,
	}, -- [116]
	{
		type = "Major",
		name = "Glyph of Ice Block",
		requiredLevel = 30,
		class = "MAGE",
		level = 35,
		itemId = 42744,
	}, -- [117]
	{
		type = "Major",
		name = "Glyph of Mana Gem",
		requiredLevel = 30,
		class = "MAGE",
		level = 35,
		itemId = 42750,
	}, -- [118]
	{
		type = "Major",
		name = "Glyph of the Beast",
		requiredLevel = 30,
		class = "HUNTER",
		level = 35,
		itemId = 42899,
	}, -- [119]
	{
		type = "Major",
		name = "Glyph of Blade Flurry",
		requiredLevel = 30,
		class = "ROGUE",
		level = 35,
		itemId = 42957,
	}, -- [120]
	{
		type = "Major",
		name = "Glyph of Hemorrhage",
		requiredLevel = 30,
		class = "ROGUE",
		level = 35,
		itemId = 42967,
	}, -- [121]
	{
		type = "Major",
		name = "Glyph of Preparation",
		requiredLevel = 30,
		class = "ROGUE",
		level = 35,
		itemId = 42968,
	}, -- [122]
	{
		type = "Minor",
		name = "Glyph of Feign Death",
		requiredLevel = 30,
		class = "HUNTER",
		level = 35,
		itemId = 43351,
	}, -- [123]
	{
		type = "Minor",
		name = "Glyph of Levitate",
		requiredLevel = 34,
		class = "PRIEST",
		level = 34,
		itemId = 43370,
	}, -- [124]
	{
		type = "Major",
		name = "Glyph of Incinerate",
		requiredLevel = 28,
		class = "WARLOCK",
		level = 33,
		itemId = 42453,
	}, -- [125]
	{
		type = "Major",
		name = "Glyph of Frost Trap",
		requiredLevel = 28,
		class = "HUNTER",
		level = 33,
		itemId = 42906,
	}, -- [126]
	{
		type = "Minor",
		name = "Glyph of Challenging Roar",
		requiredLevel = 28,
		class = "DRUID",
		level = 33,
		itemId = 43334,
	}, -- [127]
	{
		type = "Major",
		name = "Glyph of Succubus",
		requiredLevel = 26,
		class = "WARLOCK",
		level = 31,
		itemId = 42471,
	}, -- [128]
	{
		type = "Major",
		name = "Glyph of Rapid Fire",
		requiredLevel = 26,
		class = "HUNTER",
		level = 31,
		itemId = 42911,
	}, -- [129]
	{
		type = "Minor",
		name = "Glyph of the Wise",
		requiredLevel = 15,
		class = "PALADIN",
		level = 30,
		itemId = 43369,
	}, -- [130]
	{
		type = "Minor",
		name = "Glyph of Shadow Protection",
		requiredLevel = 30,
		class = "PRIEST",
		level = 30,
		itemId = 43372,
	}, -- [131]
	{
		type = "Minor",
		name = "Glyph of Astral Recall",
		requiredLevel = 30,
		class = "SHAMAN",
		level = 30,
		itemId = 43381,
	}, -- [132]
	{
		type = "Minor",
		name = "Glyph of Renewed Life",
		requiredLevel = 30,
		class = "SHAMAN",
		level = 30,
		itemId = 43385,
	}, -- [133]
	{
		type = "Minor",
		name = "Glyph of Enslave Demon",
		requiredLevel = 30,
		class = "WARLOCK",
		level = 30,
		itemId = 43393,
	}, -- [134]
	{
		type = "Major",
		name = "Glyph of Sweeping Strikes",
		requiredLevel = 30,
		class = "WARRIOR",
		level = 30,
		itemId = 43428,
	}, -- [135]
	{
		type = "Major",
		name = "Glyph of Turn Evil",
		requiredLevel = 24,
		class = "PALADIN",
		level = 29,
		itemId = 41102,
	}, -- [136]
	{
		type = "Major",
		name = "Glyph of Rake",
		requiredLevel = 24,
		class = "DRUID",
		level = 28,
		itemId = 40903,
	}, -- [137]
	{
		type = "Minor",
		name = "Glyph of Water Walking",
		requiredLevel = 28,
		class = "SHAMAN",
		level = 28,
		itemId = 43388,
	}, -- [138]
	{
		type = "Major",
		name = "Glyph of Shred",
		requiredLevel = 22,
		class = "DRUID",
		level = 26,
		itemId = 40901,
	}, -- [139]
	{
		type = "Major",
		name = "Glyph of Rip",
		requiredLevel = 20,
		class = "DRUID",
		level = 25,
		itemId = 40902,
	}, -- [140]
	{
		type = "Major",
		name = "Glyph of Rebirth",
		requiredLevel = 20,
		class = "DRUID",
		level = 25,
		itemId = 40909,
	}, -- [141]
	{
		type = "Major",
		name = "Glyph of Starfire",
		requiredLevel = 20,
		class = "DRUID",
		level = 25,
		itemId = 40916,
	}, -- [142]
	{
		type = "Major",
		name = "Glyph of Insect Swarm",
		requiredLevel = 20,
		class = "DRUID",
		level = 25,
		itemId = 40919,
	}, -- [143]
	{
		type = "Major",
		name = "Glyph of Seal of Command",
		requiredLevel = 20,
		class = "PALADIN",
		level = 25,
		itemId = 41094,
	}, -- [144]
	{
		type = "Major",
		name = "Glyph of Crusader Strike",
		requiredLevel = 20,
		class = "PALADIN",
		level = 25,
		itemId = 41098,
	}, -- [145]
	{
		type = "Major",
		name = "Glyph of Consecration",
		requiredLevel = 20,
		class = "PALADIN",
		level = 25,
		itemId = 41099,
	}, -- [146]
	{
		type = "Major",
		name = "Glyph of Exorcism",
		requiredLevel = 20,
		class = "PALADIN",
		level = 25,
		itemId = 41103,
	}, -- [147]
	{
		type = "Major",
		name = "Glyph of Flash of Light",
		requiredLevel = 20,
		class = "PALADIN",
		level = 25,
		itemId = 41105,
	}, -- [148]
	{
		type = "Major",
		name = "Glyph of Healing Stream Totem",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 25,
		itemId = 41533,
	}, -- [149]
	{
		type = "Major",
		name = "Glyph of Lesser Healing Wave",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 25,
		itemId = 41535,
	}, -- [150]
	{
		type = "Major",
		name = "Glyph of Water Mastery",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 25,
		itemId = 41541,
	}, -- [151]
	{
		type = "Major",
		name = "Glyph of Frost Shock",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 25,
		itemId = 41547,
	}, -- [152]
	{
		type = "Major",
		name = "Glyph of Fear Ward",
		requiredLevel = 20,
		class = "PRIEST",
		level = 25,
		itemId = 42399,
	}, -- [153]
	{
		type = "Major",
		name = "Glyph of Flash Heal",
		requiredLevel = 20,
		class = "PRIEST",
		level = 25,
		itemId = 42400,
	}, -- [154]
	{
		type = "Major",
		name = "Glyph of Holy Nova",
		requiredLevel = 20,
		class = "PRIEST",
		level = 25,
		itemId = 42401,
	}, -- [155]
	{
		type = "Major",
		name = "Glyph of Shadow",
		requiredLevel = 20,
		class = "PRIEST",
		level = 25,
		itemId = 42407,
	}, -- [156]
	{
		type = "Major",
		name = "Glyph of Scourge Imprisonment",
		requiredLevel = 20,
		class = "PRIEST",
		level = 25,
		itemId = 42412,
	}, -- [157]
	{
		type = "Major",
		name = "Glyph of Shadowburn",
		requiredLevel = 20,
		class = "WARLOCK",
		level = 25,
		itemId = 42468,
	}, -- [158]
	{
		type = "Major",
		name = "Glyph of Blink",
		requiredLevel = 20,
		class = "MAGE",
		level = 25,
		itemId = 42737,
	}, -- [159]
	{
		type = "Major",
		name = "Glyph of Evocation",
		requiredLevel = 20,
		class = "MAGE",
		level = 25,
		itemId = 42738,
	}, -- [160]
	{
		type = "Major",
		name = "Glyph of Icy Veins",
		requiredLevel = 20,
		class = "MAGE",
		level = 25,
		itemId = 42746,
	}, -- [161]
	{
		type = "Major",
		name = "Glyph of Scorch",
		requiredLevel = 20,
		class = "MAGE",
		level = 25,
		itemId = 42747,
	}, -- [162]
	{
		type = "Major",
		name = "Glyph of Aimed Shot",
		requiredLevel = 20,
		class = "HUNTER",
		level = 25,
		itemId = 42897,
	}, -- [163]
	{
		type = "Major",
		name = "Glyph of Deterrence",
		requiredLevel = 20,
		class = "HUNTER",
		level = 25,
		itemId = 42903,
	}, -- [164]
	{
		type = "Major",
		name = "Glyph of Disengage",
		requiredLevel = 20,
		class = "HUNTER",
		level = 25,
		itemId = 42904,
	}, -- [165]
	{
		type = "Major",
		name = "Glyph of Freezing Trap",
		requiredLevel = 20,
		class = "HUNTER",
		level = 25,
		itemId = 42905,
	}, -- [166]
	{
		type = "Major",
		name = "Glyph of Crippling Poison",
		requiredLevel = 20,
		class = "ROGUE",
		level = 25,
		itemId = 42958,
	}, -- [167]
	{
		type = "Major",
		name = "Glyph of Ghostly Strike",
		requiredLevel = 20,
		class = "ROGUE",
		level = 25,
		itemId = 42965,
	}, -- [168]
	{
		type = "Major",
		name = "Glyph of Rupture",
		requiredLevel = 20,
		class = "ROGUE",
		level = 25,
		itemId = 42969,
	}, -- [169]
	{
		type = "Minor",
		name = "Glyph of Unburdened Rebirth",
		requiredLevel = 20,
		class = "DRUID",
		level = 25,
		itemId = 43331,
	}, -- [170]
	{
		type = "Major",
		name = "Glyph of Execution",
		requiredLevel = 24,
		class = "WARRIOR",
		level = 24,
		itemId = 43416,
	}, -- [171]
	{
		type = "Major",
		name = "Glyph of Dispel Magic",
		requiredLevel = 18,
		class = "PRIEST",
		level = 23,
		itemId = 42397,
	}, -- [172]
	{
		type = "Major",
		name = "Glyph of Searing Pain",
		requiredLevel = 18,
		class = "WARLOCK",
		level = 23,
		itemId = 42466,
	}, -- [173]
	{
		type = "Major",
		name = "Glyph of Soulstone",
		requiredLevel = 18,
		class = "WARLOCK",
		level = 23,
		itemId = 42470,
	}, -- [174]
	{
		type = "Major",
		name = "Glyph of Remove Curse",
		requiredLevel = 18,
		class = "MAGE",
		level = 23,
		itemId = 42753,
	}, -- [175]
	{
		type = "Major",
		name = "Glyph of Multi-Shot",
		requiredLevel = 18,
		class = "HUNTER",
		level = 23,
		itemId = 42910,
	}, -- [176]
	{
		type = "Major",
		name = "Glyph of Ambush",
		requiredLevel = 18,
		class = "ROGUE",
		level = 23,
		itemId = 42955,
	}, -- [177]
	{
		type = "Minor",
		name = "Glyph of Water Breathing",
		requiredLevel = 22,
		class = "SHAMAN",
		level = 22,
		itemId = 43344,
	}, -- [178]
	{
		type = "Minor",
		name = "Glyph of Frost Ward",
		requiredLevel = 22,
		class = "MAGE",
		level = 22,
		itemId = 43360,
	}, -- [179]
	{
		type = "Minor",
		name = "Glyph of Distract",
		requiredLevel = 22,
		class = "ROGUE",
		level = 22,
		itemId = 43376,
	}, -- [180]
	{
		type = "Minor",
		name = "Glyph of Vanish",
		requiredLevel = 22,
		class = "ROGUE",
		level = 22,
		itemId = 43380,
	}, -- [181]
	{
		type = "Minor",
		name = "Glyph of Kilrogg",
		requiredLevel = 22,
		class = "WARLOCK",
		level = 22,
		itemId = 43391,
	}, -- [182]
	{
		type = "Major",
		name = "Glyph of Immolation Trap",
		requiredLevel = 16,
		class = "HUNTER",
		level = 21,
		itemId = 42908,
	}, -- [183]
	{
		type = "Major",
		name = "Glyph of Feint",
		requiredLevel = 16,
		class = "ROGUE",
		level = 21,
		itemId = 42963,
	}, -- [184]
	{
		type = "Minor",
		name = "Glyph of Aquatic Form",
		requiredLevel = 16,
		class = "DRUID",
		level = 21,
		itemId = 43316,
	}, -- [185]
	{
		type = "Minor",
		name = "Glyph of Dash",
		requiredLevel = 16,
		class = "DRUID",
		level = 21,
		itemId = 43674,
	}, -- [186]
	{
		type = "Major",
		name = "Glyph of Mind Flay",
		requiredLevel = 20,
		class = "PRIEST",
		level = 20,
		itemId = 42415,
	}, -- [187]
	{
		type = "Major",
		name = "Glyph of Aspect of the Viper",
		requiredLevel = 20,
		class = "HUNTER",
		level = 20,
		itemId = 42901,
	}, -- [188]
	{
		type = "Minor",
		name = "Glyph of Fire Ward",
		requiredLevel = 20,
		class = "MAGE",
		level = 20,
		itemId = 43357,
	}, -- [189]
	{
		type = "Minor",
		name = "Glyph of Blessing of Kings",
		requiredLevel = 20,
		class = "PALADIN",
		level = 20,
		itemId = 43365,
	}, -- [190]
	{
		type = "Minor",
		name = "Glyph of Sense Undead",
		requiredLevel = 20,
		class = "PALADIN",
		level = 20,
		itemId = 43368,
	}, -- [191]
	{
		type = "Minor",
		name = "Glyph of Shackle Undead",
		requiredLevel = 20,
		class = "PRIEST",
		level = 20,
		itemId = 43373,
	}, -- [192]
	{
		type = "Minor",
		name = "Deprecated Glyph of the Black Wolf",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 20,
		itemId = 43384,
	}, -- [193]
	{
		type = "Minor",
		name = "Glyph of Water Shield",
		requiredLevel = 20,
		class = "SHAMAN",
		level = 20,
		itemId = 43386,
	}, -- [194]
	{
		type = "Major",
		name = "Glyph of Cleaving",
		requiredLevel = 20,
		class = "WARRIOR",
		level = 20,
		itemId = 43414,
	}, -- [195]
	{
		type = "Major",
		name = "Glyph of Last Stand",
		requiredLevel = 20,
		class = "WARRIOR",
		level = 20,
		itemId = 43426,
	}, -- [196]
	{
		type = "Major",
		name = "Glyph of Survival Instincts",
		requiredLevel = 20,
		class = "DRUID",
		level = 20,
		itemId = 46372,
	}, -- [197]
	{
		type = "Major",
		name = "Glyph of Claw",
		requiredLevel = 20,
		class = "DRUID",
		level = 20,
		itemId = 48720,
	}, -- [198]
	{
		type = "Major",
		name = "Glyph of Righteous Defense",
		requiredLevel = 15,
		class = "PALADIN",
		level = 19,
		itemId = 41100,
	}, -- [199]
	{
		type = "Major",
		name = "Glyph of Psychic Scream",
		requiredLevel = 15,
		class = "PRIEST",
		level = 19,
		itemId = 42410,
	}, -- [200]
	{
		type = "Major",
		name = "Glyph of Arcane Explosion",
		requiredLevel = 15,
		class = "MAGE",
		level = 19,
		itemId = 42734,
	}, -- [201]
	{
		type = "Major",
		name = "Glyph of Expose Armor",
		requiredLevel = 15,
		class = "ROGUE",
		level = 19,
		itemId = 42962,
	}, -- [202]
	{
		type = "Major",
		name = "Glyph of Garrote",
		requiredLevel = 15,
		class = "ROGUE",
		level = 19,
		itemId = 42964,
	}, -- [203]
	{
		type = "Major",
		name = "Glyph of Regrowth",
		requiredLevel = 15,
		class = "DRUID",
		level = 18,
		itemId = 40912,
	}, -- [204]
	{
		type = "Major",
		name = "Glyph of Spiritual Attunement",
		requiredLevel = 18,
		class = "PALADIN",
		level = 18,
		itemId = 41096,
	}, -- [205]
	{
		type = "Major",
		name = "Glyph of Fire Nova",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 18,
		itemId = 41530,
	}, -- [206]
	{
		type = "Major",
		name = "Glyph of Inner Fire",
		requiredLevel = 15,
		class = "PRIEST",
		level = 17,
		itemId = 42402,
	}, -- [207]
	{
		type = "Major",
		name = "Glyph of Health Funnel",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 17,
		itemId = 42461,
	}, -- [208]
	{
		type = "Minor",
		name = "Glyph of Pick Lock",
		requiredLevel = 16,
		class = "ROGUE",
		level = 16,
		itemId = 43377,
	}, -- [209]
	{
		type = "Minor",
		name = "Glyph of Mocking Blow",
		requiredLevel = 16,
		class = "WARRIOR",
		level = 16,
		itemId = 43398,
	}, -- [210]
	{
		type = "Major",
		name = "Glyph of Barbaric Insults",
		requiredLevel = 16,
		class = "WARRIOR",
		level = 16,
		itemId = 43420,
	}, -- [211]
	{
		type = "Minor",
		name = "Glyph of Ghost Wolf",
		requiredLevel = 16,
		class = "SHAMAN",
		level = 16,
		itemId = 43725,
	}, -- [212]
	{
		type = "Major",
		name = "Glyph of Growl",
		requiredLevel = 15,
		class = "DRUID",
		level = 15,
		itemId = 40899,
	}, -- [213]
	{
		type = "Major",
		name = "Glyph of Moonfire",
		requiredLevel = 15,
		class = "DRUID",
		level = 15,
		itemId = 40923,
	}, -- [214]
	{
		type = "Major",
		name = "Glyph of Divinity",
		requiredLevel = 15,
		class = "PALADIN",
		level = 15,
		itemId = 41108,
	}, -- [215]
	{
		type = "Major",
		name = "Glyph of Flame Shock",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 15,
		itemId = 41531,
	}, -- [216]
	{
		type = "Major",
		name = "Glyph of Flametongue Weapon",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 15,
		itemId = 41532,
	}, -- [217]
	{
		type = "Major",
		name = "Glyph of Lava Lash",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 15,
		itemId = 41540,
	}, -- [218]
	{
		type = "Major",
		name = "Glyph of Shadow Word: Pain",
		requiredLevel = 15,
		class = "PRIEST",
		level = 15,
		itemId = 42406,
	}, -- [219]
	{
		type = "Major",
		name = "Glyph of Corruption",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 15,
		itemId = 42455,
	}, -- [220]
	{
		type = "Major",
		name = "Glyph of Healthstone",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 15,
		itemId = 42462,
	}, -- [221]
	{
		type = "Major",
		name = "Glyph of Voidwalker",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 15,
		itemId = 42473,
	}, -- [222]
	{
		type = "Major",
		name = "Glyph of Frost Nova",
		requiredLevel = 15,
		class = "MAGE",
		level = 15,
		itemId = 42741,
	}, -- [223]
	{
		type = "Major",
		name = "Glyph of Ice Armor",
		requiredLevel = 15,
		class = "MAGE",
		level = 15,
		itemId = 42743,
	}, -- [224]
	{
		type = "Major",
		name = "Glyph of the Hawk",
		requiredLevel = 15,
		class = "HUNTER",
		level = 15,
		itemId = 42909,
	}, -- [225]
	{
		type = "Major",
		name = "Glyph of Sap",
		requiredLevel = 15,
		class = "ROGUE",
		level = 15,
		itemId = 42970,
	}, -- [226]
	{
		type = "Major",
		name = "Glyph of Slice and Dice",
		requiredLevel = 15,
		class = "ROGUE",
		level = 15,
		itemId = 42973,
	}, -- [227]
	{
		type = "Major",
		name = "Glyph of Sprint",
		requiredLevel = 15,
		class = "ROGUE",
		level = 15,
		itemId = 42974,
	}, -- [228]
	{
		type = "Minor",
		name = "Glyph of Revive Pet",
		requiredLevel = 15,
		class = "HUNTER",
		level = 15,
		itemId = 43338,
	}, -- [229]
	{
		type = "Major",
		name = "Glyph of Victory Rush",
		requiredLevel = 15,
		class = "WARRIOR",
		level = 15,
		itemId = 43431,
	}, -- [230]
	{
		type = "Major",
		name = "Glyph of Quick Decay",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 15,
		itemId = 50077,
	}, -- [231]
	{
		type = "Minor",
		name = "Glyph of Possessed Strength",
		requiredLevel = 15,
		class = "HUNTER",
		level = 14,
		itemId = 43354,
	}, -- [232]
	{
		type = "Minor",
		name = "Glyph of Scare Beast",
		requiredLevel = 15,
		class = "HUNTER",
		level = 14,
		itemId = 43356,
	}, -- [233]
	{
		type = "Minor",
		name = "Glyph of Blessing of Wisdom",
		requiredLevel = 15,
		class = "PALADIN",
		level = 14,
		itemId = 43366,
	}, -- [234]
	{
		type = "Major",
		name = "Glyph of Revenge",
		requiredLevel = 15,
		class = "WARRIOR",
		level = 14,
		itemId = 43424,
	}, -- [235]
	{
		type = "Major",
		name = "Glyph of Hammer of Justice",
		requiredLevel = 15,
		class = "PALADIN",
		level = 13,
		itemId = 41095,
	}, -- [236]
	{
		type = "Major",
		name = "Glyph of Lightning Shield",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 13,
		itemId = 41537,
	}, -- [237]
	{
		type = "Major",
		name = "Glyph of Fade",
		requiredLevel = 15,
		class = "PRIEST",
		level = 13,
		itemId = 42398,
	}, -- [238]
	{
		type = "Major",
		name = "Glyph of Renew",
		requiredLevel = 15,
		class = "PRIEST",
		level = 13,
		itemId = 42411,
	}, -- [239]
	{
		type = "Major",
		name = "Glyph of Curse of Agony",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 13,
		itemId = 42456,
	}, -- [240]
	{
		type = "Major",
		name = "Glyph of Fear",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 13,
		itemId = 42458,
	}, -- [241]
	{
		type = "Major",
		name = "Glyph of Arcane Missiles",
		requiredLevel = 15,
		class = "MAGE",
		level = 13,
		itemId = 42735,
	}, -- [242]
	{
		type = "Major",
		name = "Glyph of Polymorph",
		requiredLevel = 15,
		class = "MAGE",
		level = 13,
		itemId = 42752,
	}, -- [243]
	{
		type = "Major",
		name = "Glyph of Evasion",
		requiredLevel = 15,
		class = "ROGUE",
		level = 13,
		itemId = 42960,
	}, -- [244]
	{
		type = "Minor",
		name = "Glyph of Mend Pet",
		requiredLevel = 15,
		class = "HUNTER",
		level = 12,
		itemId = 43350,
	}, -- [245]
	{
		type = "Minor",
		name = "Glyph of Slow Fall",
		requiredLevel = 15,
		class = "MAGE",
		level = 12,
		itemId = 43364,
	}, -- [246]
	{
		type = "Major",
		name = "Glyph of Living Bomb",
		requiredLevel = 60,
		class = "MAGE",
		level = 45,
		itemId = 45737,
	}, -- [247]
	{
		type = "Major",
		name = "Glyph of Arcane Barrage",
		requiredLevel = 60,
		class = "MAGE",
		level = 45,
		itemId = 45738,
	}, -- [248]
	{
		type = "Major",
		name = "Glyph of Mirror Image",
		requiredLevel = 80,
		class = "MAGE",
		level = 45,
		itemId = 45739,
	}, -- [249]
	{
		type = "Major",
		name = "Glyph of Ice Barrier",
		requiredLevel = 46,
		class = "MAGE",
		level = 45,
		itemId = 45740,
	}, -- [250]
	{
		type = "Major",
		name = "Glyph of Beacon of Light",
		requiredLevel = 60,
		class = "PALADIN",
		level = 45,
		itemId = 45741,
	}, -- [251]
	{
		type = "Major",
		name = "Glyph of Hammer of the Righteous",
		requiredLevel = 60,
		class = "PALADIN",
		level = 45,
		itemId = 45742,
	}, -- [252]
	{
		type = "Major",
		name = "Glyph of Divine Storm",
		requiredLevel = 60,
		class = "PALADIN",
		level = 45,
		itemId = 45743,
	}, -- [253]
	{
		type = "Major",
		name = "Glyph of Shield of Righteousness",
		requiredLevel = 75,
		class = "PALADIN",
		level = 45,
		itemId = 45744,
	}, -- [254]
	{
		type = "Major",
		name = "Glyph of Divine Plea",
		requiredLevel = 71,
		class = "PALADIN",
		level = 45,
		itemId = 45745,
	}, -- [255]
	{
		type = "Major",
		name = "Glyph of Holy Shock",
		requiredLevel = 40,
		class = "PALADIN",
		level = 45,
		itemId = 45746,
	}, -- [256]
	{
		type = "Major",
		name = "Glyph of Salvation",
		requiredLevel = 26,
		class = "PALADIN",
		level = 45,
		itemId = 45747,
	}, -- [257]
	{
		type = "Major",
		name = "Glyph of Dispersion",
		requiredLevel = 60,
		class = "PRIEST",
		level = 45,
		itemId = 45753,
	}, -- [258]
	{
		type = "Major",
		name = "Glyph of Guardian Spirit",
		requiredLevel = 60,
		class = "PRIEST",
		level = 45,
		itemId = 45755,
	}, -- [259]
	{
		type = "Major",
		name = "Glyph of Penance",
		requiredLevel = 60,
		class = "PRIEST",
		level = 45,
		itemId = 45756,
	}, -- [260]
	{
		type = "Major",
		name = "Glyph of Mind Sear",
		requiredLevel = 75,
		class = "PRIEST",
		level = 45,
		itemId = 45757,
	}, -- [261]
	{
		type = "Major",
		name = "Glyph of Hymn of Hope",
		requiredLevel = 60,
		class = "PRIEST",
		level = 45,
		itemId = 45758,
	}, -- [262]
	{
		type = "Major",
		name = "Glyph of Pain Suppression",
		requiredLevel = 50,
		class = "PRIEST",
		level = 45,
		itemId = 45760,
	}, -- [263]
	{
		type = "Major",
		name = "Glyph of Hunger for Blood",
		requiredLevel = 60,
		class = "ROGUE",
		level = 45,
		itemId = 45761,
	}, -- [264]
	{
		type = "Major",
		name = "Glyph of Killing Spree",
		requiredLevel = 60,
		class = "ROGUE",
		level = 45,
		itemId = 45762,
	}, -- [265]
	{
		type = "Major",
		name = "Glyph of Shadow Dance",
		requiredLevel = 60,
		class = "ROGUE",
		level = 45,
		itemId = 45764,
	}, -- [266]
	{
		type = "Major",
		name = "Glyph of Fan of Knives",
		requiredLevel = 80,
		class = "ROGUE",
		level = 45,
		itemId = 45766,
	}, -- [267]
	{
		type = "Major",
		name = "Glyph of Tricks of the Trade",
		requiredLevel = 75,
		class = "ROGUE",
		level = 45,
		itemId = 45767,
	}, -- [268]
	{
		type = "Major",
		name = "Glyph of Mutilate",
		requiredLevel = 50,
		class = "ROGUE",
		level = 45,
		itemId = 45768,
	}, -- [269]
	{
		type = "Major",
		name = "Glyph of Cloak of Shadows",
		requiredLevel = 66,
		class = "ROGUE",
		level = 45,
		itemId = 45769,
	}, -- [270]
	{
		type = "Major",
		name = "Glyph of Thunder",
		requiredLevel = 60,
		class = "SHAMAN",
		level = 45,
		itemId = 45770,
	}, -- [271]
	{
		type = "Major",
		name = "Glyph of Feral Spirit",
		requiredLevel = 60,
		class = "SHAMAN",
		level = 45,
		itemId = 45771,
	}, -- [272]
	{
		type = "Major",
		name = "Glyph of Riptide",
		requiredLevel = 60,
		class = "SHAMAN",
		level = 45,
		itemId = 45772,
	}, -- [273]
	{
		type = "Major",
		name = "Glyph of Earth Shield",
		requiredLevel = 50,
		class = "SHAMAN",
		level = 45,
		itemId = 45775,
	}, -- [274]
	{
		type = "Major",
		name = "Glyph of Totem of Wrath",
		requiredLevel = 50,
		class = "SHAMAN",
		level = 45,
		itemId = 45776,
	}, -- [275]
	{
		type = "Major",
		name = "Glyph of Hex",
		requiredLevel = 80,
		class = "SHAMAN",
		level = 45,
		itemId = 45777,
	}, -- [276]
	{
		type = "Major",
		name = "Glyph of Stoneclaw Totem",
		requiredLevel = 15,
		class = "SHAMAN",
		level = 45,
		itemId = 45778,
	}, -- [277]
	{
		type = "Major",
		name = "Glyph of Haunt",
		requiredLevel = 60,
		class = "WARLOCK",
		level = 45,
		itemId = 45779,
	}, -- [278]
	{
		type = "Major",
		name = "Glyph of Metamorphosis",
		requiredLevel = 60,
		class = "WARLOCK",
		level = 45,
		itemId = 45780,
	}, -- [279]
	{
		type = "Major",
		name = "Glyph of Chaos Bolt",
		requiredLevel = 60,
		class = "WARLOCK",
		level = 45,
		itemId = 45781,
	}, -- [280]
	{
		type = "Major",
		name = "Glyph of Demonic Circle",
		requiredLevel = 80,
		class = "WARLOCK",
		level = 45,
		itemId = 45782,
	}, -- [281]
	{
		type = "Major",
		name = "Glyph of Shadowflame",
		requiredLevel = 75,
		class = "WARLOCK",
		level = 45,
		itemId = 45783,
	}, -- [282]
	{
		type = "Major",
		name = "Glyph of Life Tap",
		requiredLevel = 15,
		class = "WARLOCK",
		level = 45,
		itemId = 45785,
	}, -- [283]
	{
		type = "Major",
		name = "Glyph of Soul Link",
		requiredLevel = 20,
		class = "WARLOCK",
		level = 45,
		itemId = 45789,
	}, -- [284]
	{
		type = "Major",
		name = "Glyph of Bladestorm",
		requiredLevel = 60,
		class = "WARRIOR",
		level = 45,
		itemId = 45790,
	}, -- [285]
	{
		type = "Major",
		name = "Glyph of Shockwave",
		requiredLevel = 60,
		class = "WARRIOR",
		level = 45,
		itemId = 45792,
	}, -- [286]
	{
		type = "Major",
		name = "Glyph of Vigilance",
		requiredLevel = 40,
		class = "WARRIOR",
		level = 45,
		itemId = 45793,
	}, -- [287]
	{
		type = "Major",
		name = "Glyph of Enraged Regeneration",
		requiredLevel = 75,
		class = "WARRIOR",
		level = 45,
		itemId = 45794,
	}, -- [288]
	{
		type = "Major",
		name = "Glyph of Spell Reflection",
		requiredLevel = 64,
		class = "WARRIOR",
		level = 45,
		itemId = 45795,
	}, -- [289]
	{
		type = "Major",
		name = "Glyph of Shield Wall",
		requiredLevel = 28,
		class = "WARRIOR",
		level = 45,
		itemId = 45797,
	}, -- [290]
	{
		type = "Major",
		name = "Glyph of Dancing Rune Weapon",
		requiredLevel = 60,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45799,
	}, -- [291]
	{
		type = "Major",
		name = "Glyph of Hungering Cold",
		requiredLevel = 60,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45800,
	}, -- [292]
	{
		type = "Major",
		name = "Glyph of Unholy Blight",
		requiredLevel = 60,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45803,
	}, -- [293]
	{
		type = "Major",
		name = "Glyph of Dark Death",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45804,
	}, -- [294]
	{
		type = "Major",
		name = "Glyph of Disease",
		requiredLevel = 55,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45805,
	}, -- [295]
	{
		type = "Major",
		name = "Glyph of Howling Blast",
		requiredLevel = 60,
		class = "DEATH KNIGHT",
		level = 45,
		itemId = 45806,
	}, -- [296]
}


local statIDs = {
	[1] = 'Strength',
	[2] = 'Agility',
	[3] = 'Stamina',
	[4] = 'Intellect',
	[5] = 'Spirit',
}

local spellSchools = {
	[2] = 'Holy',
	[3] = 'Fire',
	[4] = 'Nature',
	[5] = 'Frost',
	[6] = 'Shadow',
	[7] = 'Arcane',
}


local wrathCraftData = {
	[171] = { --alchemy
		44322,
		46376,
		46377,
		44323,
		44324,
		46379,
		46378,
		40211,
		40212,
		33448,
		40077,
		33447,
		40093,
		40070,
		44332,
		40076,
		40073,
		39666,
		44330,
		40081,
		40109,
		44331,
		40217,
		40078,
		44939,
		40068,
		40079,
		40087,
		44329,
		44328,
		40097,
		40215,
		40214,
		44327,
		40072,
		44325,
		40213,
		40216,
		39671,
		40067,
		45621,
		41163,
		47499,
		40195,
		35625,
		43570,
		41334,
		36860,
		36922,
		41266,
		35627,
		36919,
		35624,
		35622,
		35623,
		43569,
		36931,
		36928,
		44958,
		36934,
		36925,
	},
	[164] = { --blacksmith
		41257,
		41611,
		41386,
		45085,
		41387,
		41384,
		41383,
		41976,
		42508,
		41355,
		41745,
		43586,
		44936,
		41392,
		42500,
		41353,
		43587,
		47572,
		49906,
		41345,
		41188,
		40673,
		45559,
		41347,
		41357,
		40675,
		42435,
		43588,
		41391,
		47591,
		39087,
		41245,
		42728,
		43860,
		41974,
		47590,
		49903,
		41186,
		49904,
		41394,
		45551,
		41113,
		41351,
		41181,
		41388,
		40949,
		41117,
		45550,
		40955,
		41187,
		45560,
47570,
47571,
49907,
40670,
41346,
41354,
45552,
45561,
39084,
40672,
41241,
41348,
40668,
41184,
41975,
42443,
47593,
40674,
41189,
41243,
41344,
40950,
40951,
40957,
42727,
47589,
49902,
39088,
40671,
40952,
41129,
41356,
43853,
39085,
40956,
40958,
41185,
42723,
42725,
42726,
42729,
40669,
41116,
41126,
41127,
41182,
41239,
41350,
41352,
43864,
47592,
49905,
39083,
40943,
41128,
41190,
43871,
47573,
47575,
40942,
40953,
40954,
40959,
41240,
42730,
43854,
47594,
39086,
41114,
41242,
42724,
43870,
47574,
41183,
41349,
43865,
	},
	[333] = { --enchanting

	},
	[202] = { --enginer

	},
	[773] = { --inscription

	},
	[755] = { --jewelcraft

	},
	[165] = { --lw

	},
	[197] = { --tailor

	},
	[186] = { --mining

	},
	[129] = { --firstaid

	},
	[185] = { --cooking
	34747,
	43015,
	43000,
	34753,
	39520,
	43491,
	34767,
	43492,
	34752,
	43478,
	42999,
	45932,
	44953,
	43005,
	43268,
	43480,
	43490,
	34751,
	42994,
	34755,
	42996,
	34769,
	34754,
	43004,
	42998,
	34768,
	42997,
	34757,
	34766,
	34748,
	34759,
	34763,
	44838,
	42995,
	34749,
	34758,
	34762,
	34765,
	44836,
	34760,
	43488,
	34750,
	34756,
	42993,
	34764,
	46691,
	42942,
	43001,
	34761,
	44837,
	44839,
44840,
	}
}




Mixin(addon, CallbackRegistryMixin)
addon:GenerateCallbackEvents({
    "OnDatabaseInitialised",

	"Character_OnPlayerCharacterDataReset",

	"OnCommsMessage",

    "OnCharacterChanged",

    "RosterListviewItem_OnMouseDown",
    
    "OnGuildRosterUpdate",
	"OnGuildRosterScanned",

    "OnAddonLoaded",
    "OnPlayerEnteringWorld",

    "OnPlayerBagsUpdated",
    "OnPlayerTradeskillRecipesScanned",
    "OnPlayerTalentSpecChanged",
    "OnPlayerEquipmentChanged",
	"OnPlayerStatsChanged",

    "OnGuildChanged",

    "OnChatMessageGuild",

    "TradeskillListviewItem_OnMouseDown",
	"TradeskillListviewItem_OnAddToWorkOrder",
	"TradeskillListviewItem_RemoveFromWorkOrder",
	"TradeskillCrafter_SendWorkOrder",


});
CallbackRegistryMixin.OnLoad(addon);





function addon:GetLocaleGlyphNames()

	if not glyphLocales then
		glyphLocales = {}
	end
	if not glyphLocales[GetLocale()] then
		glyphLocales[GetLocale()] = {}
	end

	for k, glyph in ipairs(glyphsData) do
		local item = Item:CreateFromItemID(glyph.itemId)
		if not item:IsItemEmpty() then
			item:ContinueOnItemLoad(function()
				local name = item:GetItemName()
				glyphLocales[GetLocale()][name] = glyph.itemId;
			end)
		end
	end

end



function addon:GetLocaleTradeskillInfo()

	if not tradeskillLinkLocales then
		tradeskillLinkLocales = {}
	end
	if not tradeskillLinkLocales[GetLocale()] then
		tradeskillLinkLocales[GetLocale()] = {}
	end

	for k, _item in ipairs(addon.tradeskillItems) do
		
		local item = Item:CreateFromItemID(_item.itemID)
		if not item:IsItemEmpty() then
			item:ContinueOnItemLoad(function()
				local name = item:GetItemName()
				local link = item:GetItemLink()

				tradeskillLinkLocales[GetLocale()][_item.itemID] = {
					name = name,
					link = link,
				}
			end)
		end
	end
end




function addon:scanAtlasData()

    local LCI = LibStub:GetLibrary("LibCraftInfo-1.0");

    craftData = {
        classic = {},
        tbc = {},
        wrath = {},
    };

    local classicItemsToQuery = {};
    local tbcItemsToQuery = {};

    for prof, data in pairs(addon.craftDataClassic) do
        if prof == "Enchanting" then
            for k, itemData in ipairs(data.items) do
                for x, info in pairs(itemData) do
                    if type(info) == "table" then
                        for y, items in ipairs(info) do
                            table.insert(classicItemsToQuery, {
                                recipeID = items[2],
                                prof = prof,
                                itemID = items[2],
                            })
                        end
                    end
                end
            end
        else
            for k, itemData in ipairs(data.items) do
                for x, info in pairs(itemData) do
                    if type(info) == "table" then
                        for y, items in ipairs(info) do
                            table.insert(classicItemsToQuery, {
                                recipeID = items[2],
                                prof = prof,
                                itemID = LCI:GetCraftResultItem(items[2])
                            })
                        end
                    end
                end
            end
        end
    end

    for prof, data in pairs(addon.craftDataTBC) do
        if prof == "EnchantingBC" then
            for k, itemData in ipairs(data.items) do
                for x, info in pairs(itemData) do
                    if type(info) == "table" then
                        for y, items in ipairs(info) do
                            table.insert(tbcItemsToQuery, {
                                recipeID = items[2],
                                prof = prof,
                                itemID = items[2],
                            })
                        end
                    end
                end
            end
        else
            for k, itemData in ipairs(data.items) do
                for x, info in pairs(itemData) do
                    if type(info) == "table" then
                        for y, items in ipairs(info) do
                            table.insert(tbcItemsToQuery, {
                                recipeID = items[2],
                                prof = prof,
                                itemID = LCI:GetCraftResultItem(items[2])
                            })
                        end
                    end
                end
            end
        end
    end


    -- extra, will require itemID from wowhead
    table.insert(tbcItemsToQuery, {
        recipeID = 351770,
        prof = "Leatherworking",
        itemID = 185849,
    })
    table.insert(tbcItemsToQuery, {
        recipeID = 351771,
        prof = "Leatherworking",
        itemID = 185848,
    })
    table.insert(tbcItemsToQuery, {
        recipeID = 351766,
        prof = "Leatherworking",
        itemID = 185852,
    })
    table.insert(tbcItemsToQuery, {
        recipeID = 351768,
        prof = "Leatherworking",
        itemID = 185851,
    })

    local stagger = 0.1;

    local i = 0
    C_Timer.NewTicker(stagger, function()
        i = i + 1;
        local item = classicItemsToQuery[i];
        if item and type(item.itemID) == "number" then

            if item.prof == "Enchanting" or item.prof == "EnchantingBC" then
                
                local spell = Spell:CreateFromSpellID(item.itemID)
                if spell:IsSpellEmpty() then
                    
                else
                    spell:ContinueOnSpellLoad(function()
                        local name = spell:GetSpellName()
                        local icon = 134327;
                        local rarity = 1;
                        local link = string.format("%s:%s", "spell", spell:GetSpellID())

                        local atlasInfo = addon.recipesListFromAtlas[item.recipeID]

                        local reagents = {};
                        if atlasInfo then
                            local reagentsIDs = atlasInfo[6];
                            local reagentsCount = atlasInfo[7];
    
                            for k, v in ipairs(reagentsIDs) do
                                reagents[v] = reagentsCount[k];
                            end 
                        end

                        local recipe = {
                            recipeID = item.recipeID,
                            itemID = item.itemID,
                            quality = rarity,
                            link = link,
                            icon = icon,
                            name = name,
                            tradeskill = item.prof,
                            reagents = reagents,
                            class = -1,
                            subClass = -1,
                            equipLocation = "",
                        }
                        table.insert(craftData.classic, recipe)
    
                        print(string.format("got %s of %s - %s", i, #classicItemsToQuery, link))
                        
                    end)
                end



            else
                local itemM = Item:CreateFromItemID(item.itemID)
                if itemM:IsItemEmpty() then
                    
                else
    
                    itemM:ContinueOnItemLoad(function()
                        local link = itemM:GetItemLink()
                        local rarity = itemM:GetItemQuality()
                        local name = itemM:GetItemName()
                        local icon = itemM:GetItemIcon()
    
                        local itemID, itemType, itemSubType, itemEquipLoc, _, classID, subclassID = GetItemInfoInstant(link)
    
                        local atlasInfo = addon.recipesListFromAtlas[item.recipeID]
    
                        local reagents = {};
                        if atlasInfo then
                            local reagentsIDs = atlasInfo[6];
                            local reagentsCount = atlasInfo[7];
    
                            for k, v in ipairs(reagentsIDs) do
                                reagents[v] = reagentsCount[k];
                            end 
                        end
    
                        local recipe = {
                            recipeID = item.recipeID,
                            itemID = item.itemID,
                            quality = rarity,
                            link = link,
                            icon = icon,
                            name = name,
                            tradeskill = item.prof,
                            reagents = reagents,
                            class = classID,
                            subClass = subclassID,
                            equipLocation = itemEquipLoc,
                        }
                        table.insert(craftData.classic, recipe)
    
                        print(string.format("got %s of %s - %s", i, #classicItemsToQuery, link))
                    end)
    
                end

            end

            
        end
    end, #classicItemsToQuery)

    C_Timer.After((#classicItemsToQuery * stagger) + 1.0, function()

        print("starting tbc item requests >>>>>>>>>>>>>>>")

        local i = 0;
        C_Timer.NewTicker(stagger, function()
            i = i + 1;
            local item = tbcItemsToQuery[i];
            if item and type(item.itemID) == "number" then

                if item.prof == "Enchanting" or item.prof == "EnchantingBC" then

                    local spell = Spell:CreateFromSpellID(item.itemID)
                    if spell:IsSpellEmpty() then
                        
                    else
                        spell:ContinueOnSpellLoad(function()
                            local name = spell:GetSpellName()
                            local icon = 134327;
                            local rarity = 1;
                            local link = string.format("%s:%s", "spell", spell:GetSpellID())

                            local atlasInfo = addon.recipesListFromAtlas[item.recipeID]
    
                            local reagents = {};
                            if atlasInfo then
                                local reagentsIDs = atlasInfo[6];
                                local reagentsCount = atlasInfo[7];
        
                                for k, v in ipairs(reagentsIDs) do
                                    reagents[v] = reagentsCount[k];
                                end 
                            end

                            local recipe = {
                                recipeID = item.recipeID,
                                itemID = item.itemID,
                                quality = rarity,
                                link = link,
                                icon = icon,
                                name = name,
                                tradeskill = item.prof,
                                reagents = reagents,
                                class = -1,
                                subClass = -1,
                                equipLocation = "",
                            }
                            table.insert(craftData.tbc, recipe)
        
                            print(string.format("got %s of %s - %s", i, #tbcItemsToQuery, link))

                        end)
                    end

                    
                else
                    local itemM = Item:CreateFromItemID(item.itemID)
                    if itemM:IsItemEmpty() then
                        
                    else
        
                        itemM:ContinueOnItemLoad(function()
                            local link = itemM:GetItemLink()
                            local rarity = itemM:GetItemQuality()
                            local name = itemM:GetItemName()
                            local icon = itemM:GetItemIcon()
        
                            local itemID, itemType, itemSubType, itemEquipLoc, _, classID, subclassID = GetItemInfoInstant(link)
    
                            local atlasInfo = addon.recipesListFromAtlas[item.recipeID]
    
                            local reagents = {};
                            if atlasInfo then
                                local reagentsIDs = atlasInfo[6];
                                local reagentsCount = atlasInfo[7];
        
                                for k, v in ipairs(reagentsIDs) do
                                    reagents[v] = reagentsCount[k];
                                end 
                            end
        
                            local recipe = {
                                recipeID = item.recipeID,
                                itemID = item.itemID,
                                quality = rarity,
                                link = link,
                                icon = icon,
                                name = name,
                                tradeskill = item.prof,
                                reagents = reagents,
                                class = classID,
                                subClass = subclassID,
                                equipLocation = itemEquipLoc,
                            }
                            table.insert(craftData.tbc, recipe)
        
                            print(string.format("got %s of %s - %s", i, #tbcItemsToQuery, link))
                        end)
        
                    end

                end
    
                
            end
        end, #tbcItemsToQuery)
    end)


end




function addon:FormatNumberForCharacterStats(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.2f", num)
        return tonumber(trimmed)
    else
        return 1.0;
    end
end
































function addon:ScanPlayerTalents(...)
    local newSpec, previousSpec = ...;

	if type(newSpec) ~= "number" then
		newSpec = GetActiveTalentGroup()
	end
	if type(newSpec) ~= "number" then
		newSpec = 1
	end

    local tabs, talents = {}, {}
    for tabIndex = 1, GetNumTalentTabs() do
        local _, texture, pointsSpent, fileName = GetTalentTabInfo(tabIndex)
        local engSpec = talentBackgroundToSpec[fileName]
        table.insert(tabs, {
            points = pointsSpent, 
            spec = engSpec,
            texture = fileName,
        });
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local name, iconTexture, row, column, rank, maxRank, isExceptional, available = GetTalentInfo(tabIndex, talentIndex)
            table.insert(talents, {
                Tab = tabIndex,
                Row = row,
                Col = column,
                Rank = rank,
                MxRnk = maxRank,
                Icon = iconTexture,
                Index = talentIndex,
                Link = GetTalentLink(tabIndex, talentIndex),
            });
        end
    end

    local glyphs = {}
    for i = 1, 6 do
        local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i);
        --local name, glyphType, isKnown, icon, glyphId, glyphLink, spec, specMatches, excluded = GetGlyphInfo(i)
        -- DevTools_Dump({GetGlyphSocketInfo(i)})
        if enabled and glyphSpellID then
            -- local link = GetGlyphLink(i);-- Retrieves the Glyph's link ("" if no glyph in Socket);
            -- if link ~= "" then
            --     glyphs[i] = {
            --         link = link,
            --         icon = icon
            --     }
            -- else
            --     glyphs[i] = {
            --         link = false,
            --         icon = false
            --     }
            -- end
            -- print("glyph", i)
            -- print(link)
            -- DevTools_Dump({GetItemInfoInstant(link)})


			--[[
				THIS REQUIRES THAT THE GLYPH DATA HAS AT LEAST THE NAMES TRANSLATED SO THE CLIENTS CAN COMPARE AND FIND PROPERLY
			]]
            local name = GetSpellInfo(glyphSpellID)
            if name then
                for k, v in ipairs(glyphsData) do
                    if v.name == name then
                        table.insert(glyphs, {
							socket = i,
							glyphType = v.type,
							itemID = v.itemId,
						})
                    end
                end
            end
        end
    end

    if newSpec == 1 then
        self:TriggerEvent("OnPlayerTalentSpecChanged", "primary", talents, glyphs)
    elseif newSpec == 2 then
        self:TriggerEvent("OnPlayerTalentSpecChanged", "secondary", talents, glyphs)
    end

end


function addon:GetCharacterStats(setID)

	local equipmentSetName = "";
	local sets = C_EquipmentSet.GetEquipmentSetIDs();
    for k, v in ipairs(sets) do
        local name, iconFileID, _setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(v)
		if _setID == setID then
			equipmentSetName = name;
		end
    end

    local stats = {};

    ---go through getting each stat value
    local numSkills = GetNumSkillLines();
    local skillIndex = 0;
    local currentHeader = nil;

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i));
        local isHeader = select(2, GetSkillLineInfo(i));

        if isHeader ~= nil and isHeader then
            currentHeader = skillName;
        else
            if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                skillIndex = i;
                break;
            end
        end
    end

    local baseDef, modDef;
    if (skillIndex > 0) then
        baseDef = select(4, GetSkillLineInfo(skillIndex));
        modDef = select(6, GetSkillLineInfo(skillIndex));
    else
        baseDef, modDef = UnitDefense('player')
    end

    local posBuff = 0;
    local negBuff = 0;
    if ( modDef > 0 ) then
        posBuff = modDef;
    elseif ( modDef < 0 ) then
        negBuff = modDef;
    end
    stats.Defence = {
        Base = self:FormatNumberForCharacterStats(baseDef),
        Mod = self:FormatNumberForCharacterStats(modDef),
    }

    local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
    stats.Armor = self:FormatNumberForCharacterStats(baseArmor)
    stats.Block = self:FormatNumberForCharacterStats(GetBlockChance());
    stats.Parry = self:FormatNumberForCharacterStats(GetParryChance());
    stats.ShieldBlock = self:FormatNumberForCharacterStats(GetShieldBlock());
    stats.Dodge = self:FormatNumberForCharacterStats(GetDodgeChance());

    --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
    stats.Expertise = self:FormatNumberForCharacterStats(GetExpertise()); --will display mainhand expertise but it stores offhand expertise as well, need to find a way to access it
    --local base, casting = GetManaRegen();

    --to work with all versions we have to adjust the values we get
    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        stats.SpellHit = self:FormatNumberForCharacterStats(GetSpellHitModifier());
        stats.MeleeHit = self:FormatNumberForCharacterStats(GetHitModifier());
        stats.RangedHit = self:FormatNumberForCharacterStats(GetHitModifier());
        
    elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
        stats.SpellHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
        stats.MeleeHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
        stats.RangedHit = self:FormatNumberForCharacterStats(GetCombatRatingBonus(CR_HIT_RANGED));

    else
    
    end

    stats.RangedCrit = self:FormatNumberForCharacterStats(GetRangedCritChance());
    stats.MeleeCrit = self:FormatNumberForCharacterStats(GetCritChance());

    stats.Haste = self:FormatNumberForCharacterStats(GetHaste());
    local base, casting = GetManaRegen()
    stats.ManaRegen = base and self:FormatNumberForCharacterStats(base) or 0;
    stats.ManaRegenCasting = casting and self:FormatNumberForCharacterStats(casting) or 0;

    local minCrit = 100
    for id, school in pairs(spellSchools) do
        if GetSpellCritChance(id) < minCrit then
            minCrit = GetSpellCritChance(id)
        end
        stats['SpellDmg'..school] = self:FormatNumberForCharacterStats(GetSpellBonusDamage(id));
        stats['SpellCrit'..school] = self:FormatNumberForCharacterStats(GetSpellCritChance(id));
    end
    stats.SpellCrit = self:FormatNumberForCharacterStats(minCrit)

    stats.HealingBonus = self:FormatNumberForCharacterStats(GetSpellBonusHealing());

    local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local mlow = (lowDmg + posBuff + negBuff) * percentmod
    local mhigh = (hiDmg + posBuff + negBuff) * percentmod
    local olow = (offlowDmg + posBuff + negBuff) * percentmod
    local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
    if mainSpeed < 1 then mainSpeed = 1 end
    if mlow < 1 then mlow = 1 end
    if mhigh < 1 then mhigh = 1 end
    if olow < 1 then olow = 1 end
    if ohigh < 1 then ohigh = 1 end

    if offSpeed then
        if offSpeed < 1 then 
            offSpeed = 1
        end
        stats.MeleeDmgOH = self:FormatNumberForCharacterStats((olow + ohigh) / 2.0)
        stats.MeleeDpsOH = self:FormatNumberForCharacterStats(((olow + ohigh) / 2.0) / offSpeed)
    else
        --offSpeed = 1
        stats.MeleeDmgOH = self:FormatNumberForCharacterStats(0)
        stats.MeleeDpsOH = self:FormatNumberForCharacterStats(0)
    end
    stats.MeleeDmgMH = self:FormatNumberForCharacterStats((mlow + mhigh) / 2.0)
    stats.MeleeDpsMH = self:FormatNumberForCharacterStats(((mlow + mhigh) / 2.0) / mainSpeed)

    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    local low = (lowDmg + posBuff + negBuff) * percent
    local high = (hiDmg + posBuff + negBuff) * percent
    if speed < 1 then speed = 1 end
    if low < 1 then low = 1 end
    if high < 1 then high = 1 end
    local dmg = (low + high) / 2.0
    stats.RangedDmg = self:FormatNumberForCharacterStats(dmg)
    stats.RangedDps = self:FormatNumberForCharacterStats(dmg/speed)

    local base, posBuff, negBuff = UnitAttackPower('player')
    stats.AttackPower = self:FormatNumberForCharacterStats(base + posBuff + negBuff)

    for k, stat in pairs(statIDs) do
        local a, b, c, d = UnitStat("player", k);
        stats[stat] = self:FormatNumberForCharacterStats(b)
    end

	ViragDevTool:AddData(stats, "Guildbook_CharStats_"..equipmentSetName)

	addon:TriggerEvent("OnPlayerStatsChanged", equipmentSetName, stats)
end



function addon:ScanPlayerEquipment()
    local sets = C_EquipmentSet.GetEquipmentSetIDs();

    local equipment = {};

    for k, v in ipairs(sets) do
        
        local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(v)

        local setItemIDs = C_EquipmentSet.GetItemIDs(setID)

        equipment[name] = setItemIDs;
    end

    self:TriggerEvent("OnPlayerEquipmentChanged", equipment)
end


function addon:ScanPlayerCharacter()

	self:ScanPlayerEquipment()
	self:ScanPlayerTalents({})
	
end



function addon:ADDON_LOADED(...)

    if ... == addonName then

        self.e:UnregisterEvent("ADDON_LOADED");

        addon.Database:Init()
		addon.Comms:Init()

	end

	self:RegisterCallback("Character_OnPlayerCharacterDataReset", self.ScanPlayerCharacter, self)

end


function addon:PLAYER_ENTERING_WORLD()
    --self:scanAtlasData()
    self:TriggerEvent("OnPlayerEnteringWorld")

	self:ScanPlayerCharacter()


	--set up some hooks
	PlayerTalentFrame:HookScript("OnHide", function()
		self:ScanPlayerTalents({})
	end)

	hooksecurefunc(C_EquipmentSet, "CreateEquipmentSet", function()
		self:ScanPlayerEquipment()
	end)
	hooksecurefunc(C_EquipmentSet, "DeleteEquipmentSet", function()
		self:ScanPlayerEquipment()
	end)
end


function addon:CHAT_MSG_GUILD(...)
    self:TriggerEvent("OnChatMessageGuild", ...)
end


function addon:BAG_UPDATE_DELAYED()
    self:TriggerEvent("OnPlayerBagsUpdated")
end


function addon:GUILD_ROSTER_UPDATE()
    self:TriggerEvent("OnGuildRosterUpdate")
end

function addon:TRADE_SKILL_UPDATE(...)

    if not TradeSkillLinkButton:IsVisible() then
        return
    end
    local englishProf = nil;

    local localeProf, currentLevel, maxLevel = GetTradeSkillLine();

    --if no prof name/level were returned lets try to get it from the ui 
    if type(localeProf) ~= "string" then

        --we need this fontstring to exist before trying
        if TradeSkillFrameTitleText then
            localeProf = TradeSkillFrameTitleText:GetText()
        end
        
        --now try to get the current/max levels
        local rankText = TradeSkillRankFrameSkillRank and TradeSkillRankFrameSkillRank:GetText() or nil;
        if rankText and rankText:find("/") then
            local currentLevel, maxLevel = strsplit("/", rankText)
            if type(currentLevel) == "string" then
                currentLevel = tonumber(currentLevel)
            end
            if type(maxLevel) == "string" then
                maxLevel = tonumber(maxLevel)
            end
            addon.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("found prof level [%s] from UI text", currentLevel))
        end
    end

    --check everything is all good
    if type(localeProf) == "string" and type(currentLevel) == "number" and type(maxLevel) == "number" then

        englishProf = Tradeskills:GetEnglishNameFromTradeskillName(localeProf)
        if englishProf == false then
            addon.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", "englishProf not known")
            return;
        end

    else
        addon.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("variables not correct type > %s %s %s", localeProf, currentLevel, maxLevel))
        return;
    end

    if englishProf == nil then
        addon.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", "engLishProf is nil", localeProf)
        return;
    end

    addon.DEBUG("characterMixin", "Character:ScanTradeskillRecipes", string.format("found [%s] with current level [%s] scanning for recipes", englishProf, currentLevel))

    local tradeskillRecipes = {}
    local numTradeskills = GetNumTradeSkills()
    for i = 1, numTradeskills do
        local name, _type, _, _, _ = GetTradeSkillInfo(i)
        if name and (_type == "optimal" or _type == "medium" or _type == "easy" or _type == "trivial") then -- this was a fix thanks to Sigma regarding their addon showing all recipes
            local link = GetTradeSkillItemLink(i)
            if link then
                --print(name, link)
                local itemID = GetItemInfoInstant(link)
                if itemID then
                    table.insert(tradeskillRecipes, itemID)
                    --local reagents = {}
                    -- local numReagents = GetTradeSkillNumReagents(i);
                    -- if numReagents > 0 then
                    --     for j = 1, numReagents do
                    --         local _, _, reagentCount, _ = GetTradeSkillReagentInfo(i, j)
                    --         local reagentLink = GetTradeSkillReagentItemLink(i, j)
                    --         local reagentID = GetItemInfoInstant(reagentLink)
                    --         if reagentID and reagentCount then
                    --             tradeskillRecipes[itemID][reagentID] = reagentCount
                    --         end
                    --     end
                    -- end
                end
            end
        end
    end
    --ViragDevTool:AddData(tradeskillRecipes, "Guildbook_tradeskillRecipes")

	local tradeskillID = Tradeskills:GetTradeskillIDFromEnglishName(englishProf)
    self:TriggerEvent("OnPlayerTradeskillRecipesScanned", tradeskillID, currentLevel, tradeskillRecipes)
end


function addon:ACTIVE_TALENT_GROUP_CHANGED(...)
	self:ScanPlayerTalents(...)
end


function addon:EQUIPMENT_SETS_CHANGED()
	self:ScanPlayerEquipment()
end


function addon:EQUIPMENT_SWAP_FINISHED(...)
	local _, setID = ...;
	C_Timer.After(1.0, function()
		self:GetCharacterStats(setID)
	end)
end


addon.e = CreateFrame("Frame");
addon.e:RegisterEvent("ADDON_LOADED");
addon.e:RegisterEvent("PLAYER_ENTERING_WORLD");
addon.e:RegisterEvent("TRADE_SKILL_UPDATE")
addon.e:RegisterEvent("CRAFT_UPDATE")
addon.e:RegisterEvent("SKILL_LINES_CHANGED")
addon.e:RegisterEvent("CHARACTER_POINTS_CHANGED")
addon.e:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
addon.e:RegisterEvent("CHAT_MSG_SKILL")
addon.e:RegisterEvent("PLAYER_LEVEL_UP")
addon.e:RegisterEvent("GUILD_ROSTER_UPDATE")
addon.e:RegisterEvent("CHAT_MSG_SYSTEM")
addon.e:RegisterEvent("CHAT_MSG_GUILD")
addon.e:RegisterEvent("CHAT_MSG_WHISPER")
addon.e:RegisterEvent('BANKFRAME_OPENED')
addon.e:RegisterEvent('BANKFRAME_CLOSED')
addon.e:RegisterEvent('BAG_UPDATE_DELAYED')
addon.e:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
addon.e:RegisterEvent('EQUIPMENT_SETS_CHANGED')
addon.e:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
addon.e:RegisterEvent('EQUIPMENT_SETS_CHANGED')
addon.e:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
addon.e:SetScript("OnEvent", function(self, event, ...)
    if addon[event] then
        addon[event](addon, ...)
    end
end)