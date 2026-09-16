local addon = RaidComp

addon.IDUNKNOWN = 5
addon.IDHYBRID = 4
addon.IDFAKE = 6

addon.TEXHYBRID = "INV_Misc_Gem_Variety_02"
addon.TEXFAKE = "Spell_Nature_MirrorImage"
addon.TEXUNKNOWN = "INV_Misc_QuestionMark"

addon.POINTSFAKE = "--/--/--"
addon.POINTSUNKNOWN = "??/??/??"


-- Form "tabIndex:talentIndex"
addon.TALENTLOC = {
    ["DEATHKNIGHT"] = {
        [53138] = "1:17",             -- Abomination's Might
        [51456] = "2:1",              -- Improved Icy Touch
        [55610] = "2:16",             -- Improved Icy Talons
        ["DEATHKNIGHT TANK"] = "3:3", -- Anticipation
        [51052] = "3:22",             -- Anti-Magic Zone
        [49632] = "3:25",             -- Crypt Fever
        [51161] = "3:28",             -- Ebon Plaguebringer
      },
    ["DRUID"] = {
        [48468] = "1:13",        -- Insect Swarm
        [24907] = "1:18",        -- Moonkin Form
        [48396] = "1:19",        -- Improved Moonkin Form
        [33602] = "1:20",        -- Improved Faerie Fire
        [48511] = "1:27",        -- Earth and Moon
        [16862] = "2:2",         -- Feral Aggression (Demo Roar)
        ["DRUID TANK"] = "2:16", -- Natural Reaction
        [48560] = "2:16",        -- Natural Reaction (Although Demoralizing Roar is a base class ability, only Druid Tanks will use it so we base it on the same talent)
        [17007] = "2:19",        -- Leader of the Pack
        [48485] = "2:24",        -- Infected Wounds
        [33917] = "2:26",        -- Mangle
        [17051] = "3:1",         -- Improved Mark of the Wild
        [48545] = "3:22",        -- Revitalize
        [33891] = "3:23",        -- Tree of Life
      },
    ["HUNTER"] = {
        [34460] = "1:17", -- Ferocious Inspiration
        [49050] = "2:9",  -- Aimed Shot
        [19506] = "2:19", -- Trueshot Aura
        [53292] = "3:27", -- Hunting Party (Replenishment)
      },
    ["MAGE"] = {
        [31583] = "1:21", -- Arcane Empowerment
        [31589] = "1:26", -- Slow
        [12873] = "2:11", -- Improved Scorch
        [12571] = "3:7",  -- Permafrost
        [28593] = "3:18", -- Winter's Chill
        [44561] = "3:26", -- Enduring Winter (Replenishment) Frost Mage)
      },
    ["PALADIN"] = {
        [20245] = "1:10", -- Improved Blessing of Wisdom
        [64205] = "2:6",  -- Divine Sacrifice
        [20140] = "2:11", -- Improved Devotion Aura
        [20911] = "2:12", -- Blessing of Sanctuary (extra Blessing)
        [53696] = "2:25", -- Judgements of the Just
        [20337] = "3:4",  -- Heart of the Crusader
        [20045] = "3:5",  -- Improved Blessing of Might
        [26016] = "3:6",  -- Vindication
        [31869] = "3:14", -- Sanctified Retribution (Retribution Aura)
        [20066] = "3:18", -- Repentance
        [31878] = "3:19", -- Judgements of the Wise (Replenishment)
        [53648] = "3:22", -- Swift Retribution (Retribution Aura)
      },
    ["PRIEST"] = {
        [14767] = "1:5",  -- Improved Power Word: Fortitude
        [57472] = "1:21", -- Renewed Hope (Discipline Priest)
        [47537] = "1:22", -- Rapture
        [33206] = "1:25", -- Pain Suppression
        [15363] = "2:8",  -- Inspiration
        [47788] = "2:27", -- Guardian Spirit
        [15316] = "3:8",  -- Improved Mind Blast
        [33193] = "3:22", -- Misery
        [48160] = "3:24", -- Vampiric Touch (Replenishment)
      },
    ["ROGUE"] = {
        [58410] = "1:23", -- Master Poisoner
        [58413] = "2:26", -- Savage Combat
      },
    ["SHAMAN"] = {
        [51470] = "1:19", -- Elemental Oath
        [57722] = "1:22", -- Totem of Wrath
        [52456] = "2:1",  -- Enhancing Totems (Strength of Earth Totem)
        [16293] = "2:4",  -- Guardian Totems (Stoneskin Totem)
        [29193] = "2:13", -- Improved Windfury Totem
        [30809] = "2:16", -- Unleashed Rage
        [51524] = "2:27", -- Earthen Power (Earth Shock)
        [16240] = "3:9",  -- Ancestral Healing
        [16206] = "3:10", -- Restorative Totems (Mana Spring Totem)
        [16190] = "3:17", -- Mana Tide Totem
        [51886] = "3:18", -- Cleanse Spirit (decurse)
      },
    ["WARLOCK"] = {
        [18180] = "1:4",  -- Improved Curse of Weakness
        [54038] = "1:17", -- Improved Felhunter
        [18693] = "2:1",  -- Improved Healthstone
        [18696] = "2:2",  -- Improved Imp
        [47240] = "2:26", -- Demonic Pact
        [17803] = "3:1",  -- Improved Shadow Bolt
        [54118] = "3:21", -- Improved Soul Leech (Replenishment)
      },
    ["WARRIOR"] = {
        [46855] = "1:19", -- Trauma
        [47486] = "1:21", -- Mortal Strike
        [29859] = "1:29", -- Blood Frenzy
        [12879] = "2:4",  -- Improved Demoralizing Shout
        [12861] = "2:9",  -- Commanding Presence
        [46911] = "2:21", -- Furious Attacks
        [29801] = "2:24", -- Rampage
        [12666] = "3:3",  -- Improved Thunder Clap
      },
  }
  
addon.ICONPREFIX = "Interface\\Icons\\"

-- This array converts (locale insentively) talent-calculator textures to a number to identify talent-trees by
addon.TALENTTREES = {
    ["DEATHKNIGHT"] = {
        ["Spell_DeathKnight_BloodPresence"] = 1,
        ["Spell_DeathKnight_FrostPresence"] = 2,
        ["Spell_DeathKnight_UnholyPresence"] = 3,
      },
    ["DRUID"] = {
        ["Spell_Nature_Lightning"] = 1,
        ["Ability_Physical_Taunt"] = 2,
        ["Spell_Nature_HealingTouch"] = 3,
      },
    ["HUNTER"] = {
        ["Ability_Hunter_BeastTaming"] = 1,
        ["Ability_Marksmanship"] = 2,
        ["Ability_Hunter_SwiftStrike"] = 3,
      },
    ["MAGE"] = {
        ["Spell_Nature_WispSplode"] = 1,
        ["Spell_Fire_Fire"] = 2,
        ["Spell_Frost_FreezingBreath"] = 3,
      },
    ["PALADIN"] = {
        ["Spell_Holy_HolyBolt"] = 1,
        ["Spell_Holy_DevotionAura"] = 2,
        ["Spell_Holy_AuraOfLight"] = 3,
      },
    ["PRIEST"] = {
        ["Spell_Holy_AuraOfLight"] = 1,
        ["Spell_Holy_LayOnHands"] = 2,
        ["Spell_Shadow_Possession"] = 3,
      },
    ["ROGUE"] = {
        ["Ability_Rogue_Garrote"] = 1,
        ["INV_Weapon_ShortBlade_14"] = 2,
        ["Ability_Ambush"] = 3,
      },
    ["SHAMAN"] = {
        ["Spell_Fire_Volcano"] = 1,
        ["Spell_Nature_UnyeildingStamina"] = 2,
        ["Spell_Nature_HealingWaveGreater"] = 3,
      },
    ["WARLOCK"] = {
        ["Spell_Shadow_UnsummonBuilding"] = 1,
        ["Spell_Shadow_CurseOfTounges"] = 2,
        ["Spell_Fire_Incinerate"] = 3,
      },
    ["WARRIOR"] = {
        ["INV_Sword_27"] = 1,
        ["Ability_Warrior_BattleShout"] = 2,
        ["INV_Shield_06"] = 3,
      },
  }

-- The textures 'used' by the talent-calculator are outdated.
-- The textures below are used to represent various talent-trees
-- THESE ARE CURRENTLY NOT USED
--[[
addon.TALENTTREEICONS = {
    ["DEATHKNIGHT"] = {
        "Spell_DeathKnight_BloodPresence",
        "Spell_DeathKnight_FrostPresence",
        "Spell_DeathKnight_UnholyPresence",
      },
    ["DRUID"] = {
        "Spell_Nature_StarFall",
        "Ability_Racial_BearForm",
        "Spell_Nature_HealingTouch",
      },
    ["HUNTER"] = {
        "Ability_Hunter_BeastTaming",
        "Ability_Marksmanship",
        "Ability_Hunter_SwiftStrike",
      },
    ["MAGE"] = {
        "Spell_Holy_MagicalSentry",
        "Spell_Fire_FlameBolt",
        "Spell_Frost_FrostBolt02",
      },
    ["PALADIN"] = {
        "Spell_Holy_HolyBolt",
        "Spell_Holy_DevotionAura",
        "Spell_Holy_AuraOfLight",
      },
    ["PRIEST"] = {
        "Spell_Holy_WordFortitude",
        "Spell_Holy_HolyBolt",
        "Spell_Shadow_ShadowWordPain",
      },
    ["ROGUE"] = {
        "Ability_Rogue_Eviscerate",
        "Ability_Backstab",
        "Ability_Stealth",
      },
    ["SHAMAN"] = {
        "Spell_Nature_Lightning",
        "Spell_Nature_LightningShield",
        "Spell_Nature_MagicImmunity",
      },
    ["WARLOCK"] = {
        "Spell_Shadow_DeathCoil",
        "Spell_Shadow_Metamorphosis",
        "Spell_Shadow_RainOfFire",
      },
    ["WARRIOR"] = {
        "Ability_Rogue_Eviscerate",
        "Ability_Warrior_InnerRage",
        "Ability_Warrior_DefensiveStance",
      },
  }
--]]
