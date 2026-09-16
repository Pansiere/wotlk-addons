local addon = RaidComp

addon.SPELLIDS = {
    -- Physical
    ["+Attack Power"] = {
        47436, -- Battle Shout (Warrior)
        48932, -- Blessing of Might (Paladin)
      },
    ["+10% AP"] = {
        53138, -- Abomination's Might (Blood DK)
        19506, -- Trueshot Aura (Marksmanship Hunter)
        30809, -- Unleashed Rage (Enhancement Shaman)
      },
    ["+Agi & Str"] = {
        57623, -- Horn of Winter (DK)
        58643, -- Strength of Earth Totem (Shaman)
      },
    ["+5% Melee Crit"] = {
        17007, -- Leader of the Pack (Feral Druid)
        29801, -- Rampage (Fury Warrior)
      },
    ["+20% Melee Haste"] = {
        55610, -- Improved Icy Talons (DK)
        8512, -- Windfury Totem (Shaman)
      },
    ["-20% Armor"] = {
        55754, -- Acid Spit (Hunter Exotic Pet)
        8647, -- Expose Armor (Rogue)
        7386, -- Sunder Armor (Warrior)
      },
    ["-5% Armor"] = {
        50511, -- Curse of Weakness (Warlock)
        770, -- Faerie Fire (Druid)
        56631, -- Sting (Hunter pet)
      },
    ["+4% Phys. Dam."] = {
        29859, -- Blood Frenzy (Arms Warrior)
        58413, -- Savage Combat (Combat Rogue)
      },
    ["+Bleed Damage"] = {
        33917, -- Mangle (Feral Druid)
        46855, -- Trauma (Arms Warrior)
		57393, -- Stampede (Hunter pet)
      },
      
    -- Magical
    ["+Spell Power"] = {
        47240, -- Demonic Pact (Demonolgy Warlock)
        58656, -- Flametongue Totem (Shaman)
        57722, -- Totem of Wrath (Elemental Shaman)
      },
    ["+5% Crit (buff)"] = {
        51470, -- Elemental Oath (Elemental Shaman)
        24907, -- Moonkin Form (Balance Druid)
      },
    ["+5% Spell Haste"] = {
        3738, -- Wrath of Air totem (Shaman)
      },
    ["+Intellect"] = {
        42995, -- Arcane Intellect (Mage)
        57567, -- Fel Intelligence (Warlock Felhunter)
      },
    ["+Spirit"] = {
        48073, -- Divine Spirit (Priest)
        57567, -- Fel Intelligence (Warlock Felhunter)
      },
    ["+Mana Regen"] = {
        48936, -- Blessing of Wisdom (Paladin)
        58774, -- Mana Spring Totem (Shaman)
      },
    ["+13% Spell Dam."] = {
        47865, -- Curse of the Elements (Warlock)
        48511, -- Earth and Moon (Balance Druid)
        51161, -- Ebon Plaguebringer (Unholy DK)
      },
    ["+5% Crit (debuff)"] = {
        12873, -- Improved Scorch (Fire Mage)
        28593, -- Winter's Chill (Frost Mage)
        17803, -- Improved Shadow Bolt (Warlock)
      },
    ["+3% Spell Hit"] = {
        33602, -- Improved Faerie Fire
        33193, -- Misery
      },
    ["+30% Disease Dam."] = {
        49632, -- Crypt Fever (Unholy DK)
      },

    -- Survival
    ["+Health"] = {
        47982, -- Blood Pact (Warlock Imp)
        47440, -- Commanding Shout (Warrior)
      },
    ["+Stamina"] = {
        48161, -- Power Word: Fortitude (Priest)
      },
    ["+6% Healing"] = {
        20140, -- Improved Devotion Aura (Protection Paladin)
        33891, -- Tree of Life (Restoration Druid)
      },
    ["+Armor Aura"] = {
        48942, -- Devotion Aura (Paladin)
      },
    ["+Armor Totem"] = {
        58753, -- Stoneskin Totem (Shaman)
      },
    ["+25% Armor Proc"] = {
        16240, -- Ancestral Healing (Resto Shaman)
        15363, -- Inspiration (Holy/Disc Priest)
      },
    ["-3% Dam. Taken"] = {
        20911, -- Blessing of Sanctuary (Protection Paladin)
        57472, -- Renewed Hope (Discipline Priest)
      },
    ["Healthstone"] = {
        58887, -- Ritual of Souls (Warlock)
      },
    ["-3% Hit Taken"] = {
        48468, -- Insect Swarm (Balance Druid)
        3043, -- Scorpid Sting (Hunter)
      },
    ["-Attack Power"] = {
        50511, -- Curse of Weakness (Warlock)
        48560, -- Demoralizing Roar (Feral Druid)
        47437, -- Demoralizing Shout (Warrior)
        26016, -- Vindication (Paladin)
        55487, -- Demoralizing Screech (Hunter pet)
      },
    ["-Attack Speed"] = {
        49909, -- Icy Touch (DK)
        48467, -- Hurricane (Balance Druid)
        48485, -- Infected Wounds (Feral Druid)
        53696, -- Judgements of the Just (Protection Paladin)
        49231, -- Earth Shock (Enhancement Shaman)
        47502, -- Thunder Clap (Warrior)
      },

    -- Multi Purpose
    ["Heroism/Bloodlust"] = {
        2825, -- Bloodlust (Shaman)
      },
    ["+All Stats"] = {
        48469, -- Mark of the Wild (Druid)
      },      
    ["+10% All Stats"] = {
        20217, -- Blessing of Kings
      },
    ["+3% Damage"] = {
        34460, -- Ferocious Inspiration (Beast Mastery Hunter)
        31869, -- Sanctified Retribution (Retribution Paladin)
        31583, -- Arcane Empowerment (Arcane Mage)
      },
    ["+3% Haste"] = {
        48396, -- Improved Moonkin Form (Balance Druid)
        53648, -- Swift Retribution (Retribution Paladin)
      },
    ["Power Restore"] = {
        48545, -- Revitalize (Restoration Druid)
        47537, -- Rapture (Discipline Priest)
      },
    ["+3% Crit"] = {
        20337, -- Heart of the Crusader (Most Paladins)
        58410, -- Master Poisoner (Assassination Rogue)
        57722, -- Totem of Wrath (Elemental Shaman)
      },

    -- Situational
    ["Frost Res."] = {
        48945, -- Frost Resistance Aura (Paladin)
        58745, -- Frost Resistance Totem (Shaman)
      },
    ["Fire Res."] = {
        48947, -- Fire Resistance Aura (Paladin)
        58739, -- Fire Resistance Totem (Shaman)
      },
    ["Nature Res."] = {
        58749, -- Nature Resistance Totem (Shaman)
        49071, -- Aspect of the Wild (Hunter)
      },
    ["Shadow Res."] = {
        48943, -- Shadow Resistance Aura (Paladin)
        48170, -- Shadow Protection (Priest)
      },
    ["-Healing Received"] = {
        49050, -- Aimed Shot (Marksmanship Hunter)
        46911, -- Furious Attacks (Fury Warrior)
        47486, -- Mortal Strike (Arms Warrior)
        57978, -- Wound Poison (Rogue)
        12571, -- Permafrost (Frost Mage)
        15316, -- Improved Mind Blast (Shadow Priest)
      },
    ["-Cast Speed"] = {
        11719, -- Curse of Tongues (Warlock)
        58611, -- Lava Breath (Hunter Exotic Pet)
        5761, -- Mind-Numbing Poison (Rogue)
        31589, -- Slow (Mage)
      },
    
    -- Count
    ["Replenishment"] = {
        53292, -- Hunting Party (Survival Hunter)
        31878, -- Judgements of the Wise (Retribution Paladin)
        48160, -- Vampiric Touch (Shadow Priest)
        54118, -- Improved Soul Leech (Destro Lock)
        44561, -- Enduring Winter (Frost Mage)
      },
    ["Remove Magic"] = {
        988, -- Dispel Magic (Priest)
        4987, -- Cleanse (Paladin)
      },
    ["Remove Poison"] = {
        2893, -- Abolish Poison (Druid)
        526, -- Cure Toxins (Shaman)
        4987, -- Cleanse (Paladin)
      },
    ["Remove Curse"] = {
        51886, -- Cleanse Spirit (Restoration Shaman)
        2782, -- Remove Curse (Druid)
        475, -- Remove Curse (Mage)
      },
    ["Remove Disease"] = {
        552, -- Abolish Disease (Priest)
        526, -- Cure Toxins (Shaman)
        4987, -- Cleanse (Paladin)
      },
    ["Reduce Damage"] = {
        6940, -- Hand of Sacrifice (Paladin)
        64205, -- Divine Sacrifice (Paladin)
        33206, -- Pain Suppression (Priest)
        47788, -- Guardian Spirit (Priest)
        51052, -- Anti-Magic Zone (Death Knight)
      },
    ["Interrupt"] = {
        47528, -- Mind Freeze (Death Knight)
        2139, -- Counterspell (Mage)
        1766, -- Kick (Rogue)
        57994, -- Wind Shock (Shaman)
        6552, -- Pummel (Warrior)
        72, -- Shield Bash (Protection Warrior)
      },
    ["Purge"] = {
        8012, -- Purge (Shaman)
        988, -- Dispel Magic (Priest)
        19801, -- Tranquilizing Shot (Hunter)
        30449, -- Spellsteal (Mage)
        47488, -- Shield Slam (Warrior)
      },
    ["Remove Enrage"] = {
        19801, -- Tranquilizing Shot (Hunter)
        57982, -- Anesthetic Poison (Rogue)
      },
    ["Remove Protection"] = {
        32375, -- Mass Dispel (Priest)
        64382, -- Shattering Throw (Warrior)
      },
      
    -- Crowd Control
    ["CC - Humanoid"] = {
        14311, -- Freezing Trap (Hunter)
        12826, -- Polymorph (Mage)
        20066, -- Repentance (Paladin)
        51724, -- Sap (Rogue)
        51514, -- Hex (Shaman)
      },
    ["CC - Beast"] = {
        18658, -- Hibernate (Druid)
        14311, -- Freezing Trap (Hunter)
        12826, -- Polymorph (Mage)
        51724, -- Sap (Rogue)
        51514, -- Hex (Shaman)
      },
    ["CC - Dragonkin"] = {
        18658, -- Hibernate (Druid)
        14311, -- Freezing Trap (Hunter)
        12826, -- Polymorph (Mage)
        20066, -- Repentance (Paladin)
        51724, -- Sap (Rogue)
      },
    ["CC - Giant"] = {
        14311, -- Freezing Trap (Hunter)
        20066, -- Repentance (Paladin)
      },
    ["CC - Elemental"] = {
        14311, -- Freezing Trap (Hunter)
        18647, -- Banish (Warlock)
      },
    ["CC - Demon"] = {
        14311, -- Freezing Trap (Hunter)
        20066, -- Repentance (Paladin)
        51724, -- Sap (Rogue)
        18647, -- Banish (Warlock)
      },
    ["CC - Undead"] = {
        14311, -- Freezing Trap (Hunter)
        20066, -- Repentance (Paladin)
        10955, -- Shackle Undead (Priest)
      },
      
    -- Composition
    ["Tanks"] = {
        "DEATHKNIGHT TANK", -- DK Tank spec
        "DRUID TANK",       -- Druid Tank spec
        "PALADIN TANK",     -- Paladin Tank spec
        "WARRIOR TANK",     -- Warrior Tank spec
      },
    ["Melee DPS"] = {
        "DEATHKNIGHT MELEE", -- DK Melee DPS spec
        "DRUID MELEE",       -- Druid Melee DPS spec
        "PALADIN MELEE",     -- Paladin Melee DPS spec
        "ROGUE MELEE",       -- Rogue Melee DPS spec
        "SHAMAN MELEE",      -- Shaman Melee DPS spec
        "WARRIOR MELEE",     -- Warrior Melee DPS spec
      },
    ["Ranged DPS"] = {
        "DRUID RANGED",   -- Druid Ranged DPS spec
        "HUNTER RANGED",  -- Hunter Ranged DPS spec
        "MAGE RANGED",    -- Mage Ranged DPS spec
        "PRIEST RANGED",  -- Priest Ranged DPS spec
        "SHAMAN RANGED",  -- Shaman Ranged DPS spec
        "WARLOCK RANGED", -- Warlock Ranged DPS spec
      },
    ["Healers"] = {
        "DRUID HEALER",   -- Druid Healer spec
        "PALADIN HEALER", -- Paladin Healer spec
        "PRIEST HEALER",  -- Priest Healer spec
        "SHAMAN HEALER",  -- Shaman Healer spec
      },
  }

addon.ISPETABILITY = {
    [55754] = true, -- Acid Spit (Hunter Exotic Pet)
    [56631] = true, -- Sting (Hunter Pet)
    [58611] = true, -- Lava Breath (Hunter Exotic Pet)
    [55487] = true, -- Demoralizing Screech (Hunter Pet)
	[57393] = true, -- Stampede (Hunter Exotic Pet)
    
    [57567] = true, -- Fel Intelligence (Warlock Felhunter)
    [47982] = true, -- Blood Pact (Warlock Imp)
  }
  
addon.PETABILITIES = {
    -- Hunter
    {   spellId = 55754, -- Acid Spit
        petType = "pet_worm",
        engClass = "HUNTER",
      },
    {   spellId = 56631, -- Sting
        petType = "pet_wasp",
        engClass = "HUNTER",
      },
    {   spellId = 58611, -- Lava Breath
        petType = "pet_corehound",
        engClass = "HUNTER",
      },
    {   spellId = 55487, -- Demoralizing Screech
        petType = "pet_carrionbird",
        engClass = "HUNTER",
      },
	{   spellId = 57393, -- Stampede
		petType = "pet_rhino",
		engClass = "HUNTER",
	  },

    -- Warlock
    {   spellId = 47982, -- Blood Pact
        petType = "pet_imp",
        engClass = "WARLOCK",
      },
    {   spellId = 57567, -- Fel Intelligence
        petType = "pet_felhunter",
        engClass = "WARLOCK",
      },
  }

addon.SPELLCLASS = {
    -- Physical
    ["+Attack Power"] = {
        [47436] = "WARRIOR", -- Battle Shout (Warrior)
        [12861] = "WARRIOR", -- (Commanding Presence) Battle Shout (Fury Warrior)
        [48932] = "PALADIN", -- Blessing of Might (Paladin)
        [20045] = "PALADIN", -- (Improved) Blessing of Might (Retribution Paladin)
      },
    ["+10% AP"] = {
        [53138] = "DEATHKNIGHT", -- Abomination's Might (Blood DK)
        [19506] = "HUNTER",      -- Trueshot Aura (Marksmanship Hunter)
        [30809] = "SHAMAN",      -- Unleashed Rage (Enhancement Shaman)
      },
    ["+Agi & Str"] = {
        [57623] = "DEATHKNIGHT", -- Horn of Winter (DK)
        [58643] = "SHAMAN",      -- Strength of Earth Totem (Shaman)
        [52456] = "SHAMAN",      -- (Enhancing Totems) Strength of Earth Totem (Enhancement Shaman)
      },
    ["+5% Melee Crit"] = {
        [17007] = "DRUID",   -- Leader of the Pack (Feral Druid)
        [29801] = "WARRIOR", -- Rampage (Fury Warrior)
      },
    ["+20% Melee Haste"] = {
        [55610] = "DEATHKNIGHT", -- Improved Icy Talons (DK)
        [8512] = "SHAMAN",       -- Windfury Totem (Shaman)
        [29193] = "SHAMAN",      -- (Improved) Windfury Totem (Enhancement Shaman)
      },
    ["-20% Armor"] = {
        [55754] = "HUNTER", -- Acid Spit (Hunter Exotic Pet)
        [8647] = "ROGUE",   -- Expose Armor (Rogue)
        [7386] = "WARRIOR", -- Sunder Armor (Warrior)
      },
    ["-5% Armor"] = {
        [50511] = "WARLOCK", -- Curse of Weakness (Warlock)
        [770] = "DRUID",     -- Faerie Fire (Druid)
        [56631] = "HUNTER",  -- Sting (Hunter Pet)
      },
    ["+4% Phys. Dam."] = {
        [29859] = "WARRIOR", -- Blood Frenzy (Arms Warrior)
        [58413] = "ROGUE",   -- Savage Combat (Combat Rogue)
      },
    ["+Bleed Damage"] = {
        [33917] = "DRUID",   -- Mangle (Feral Druid)
        [46855] = "WARRIOR", -- Trauma (Arms Warrior)
		[57393] = "HUNTER",  -- Stampede (Hunter Exotic Pet)
      },

      
    -- Magical
    ["+Spell Power"] = {
        [47240] = "WARLOCK", -- Demonic Pact (Demonolgy Warlock)
        [58656] = "SHAMAN",  -- Flametongue Totem (Shaman)
        [52456] = "SHAMAN",  -- (Enhancing Totems) Flametongue Totem
        [57722] = "SHAMAN",  -- Totem of Wrath (Elemental Shaman)
      },
    ["+5% Crit (buff)"] = {
        [51470] = "SHAMAN", -- Elemental Oath (Elemental Shaman)
        [24907] = "DRUID",  -- Moonkin Form (Balance Druid)
      },
    ["+5% Spell Haste"] = {
        [3738] = "SHAMAN", -- Wrath of Air totem (Shaman)
      },
    ["+Intellect"] = {
        [42995] = "MAGE",    -- Arcane Intellect (Mage)
        [57567] = "WARLOCK", -- Fel Intelligence (Warlock Felhunter)
        [54038] = "WARLOCK", -- (Improved Felhunter) Fel Intelligence
      },
    ["+Spirit"] = {
        [48073] = "PRIEST",  -- Divine Spirit (Discipline Priest)
        [57567] = "WARLOCK", -- Fel Intelligence (Warlock Felhunter)
        [54038] = "WARLOCK", -- (Improved Felhunter) Fel Intelligence
      },
    ["+Mana Regen"] = {
        [48936] = "PALADIN", -- Blessing of Wisdom (Paladin)
        [20245] = "PALADIN", -- (Improved) Blessing of Wisdom
        [58774] = "SHAMAN",  -- Mana Spring Totem (Shaman)
        [16206] = "SHAMAN",  -- Restorative Totems (Shaman)
      },
    ["+13% Spell Dam."] = {
        [47865] = "WARLOCK",     -- Curse of the Elements (Warlock)
        [48511] = "DRUID",       -- Earth and Moon (Balance Druid)
        [51161] = "DEATHKNIGHT", -- Ebon Plaguebringer (Unholy DK)
      },
    ["+5% Crit (debuff)"] = {
        [12873] = "MAGE",    -- Improved Scorch
        [28593] = "MAGE",    -- Winter's Chill
        [17803] = "WARLOCK", -- Improved Shadow Bolt (Warlock)
      },
    ["+3% Spell Hit"] = {
        [33602] = "DRUID",  -- Improved Faerie Fire
        [33193] = "PRIEST", -- Misery
      },
    ["+30% Disease Dam."] = {
        [49632] = "DEATHKNIGHT", -- Crypt Fever
      },

    
    -- Survival
    ["+Health"] = {
        [47982] = "WARLOCK", -- Blood Pact (Warlock Imp)
        [18696] = "WARLOCK", -- (Improved Imp) Blood Pact
        [47440] = "WARRIOR", -- Commanding Shout (Warrior)
        [12861] = "WARRIOR", -- (Commanding Presence) Commanding Shout (Fury Warrior)
      },
    ["+Stamina"] = {
        [48161] = "PRIEST", -- Power Word: Fortitude (Priest)
        [14767] = "PRIEST", -- (Improved) Power Word: Fortitude
      },
    ["+6% Healing"] = {
        [20140] = "PALADIN", -- Improved Devotion Aura (Protection Paladin)
        [33891] = "DRUID",   -- Tree of Life (Restoration Druid)
      },
    ["+Armor Aura"] = {
        [48942] = "PALADIN", -- Devotion Aura (Paladin)
        [20140] = "PALADIN", -- (Improved) Devotion Aura
      },
    ["+Armor Totem"] = {
        [58753] = "SHAMAN", -- Stoneskin Totem (Shaman)
        [16293] = "SHAMAN", -- (Guardian Totems) Stoneskin Totem
      },
    ["+25% Armor Proc"] = {
        [16240] = "SHAMAN", -- Ancestral Healing (Resto Shaman)
        [15363] = "PRIEST", -- Inspiration (Holy/Disc Priest)
      },
    ["Healthstone"] = {
        [58887] = "WARLOCK", -- Ritual of Souls (Warlock)
        [18693] = "WARLOCK", -- Improved Healthstone (Warlock)
      },
    ["-3% Dam. Taken"] = {
        [20911] = "PALADIN", -- Blessing of Sanctuary (Protection Paladin)
        [57472] = "PRIEST",  -- Renewed Hope (Discipline Priest)
      },
    ["-3% Hit Taken"] = {
        [48468] = "DRUID", -- Insect Swarm (Balance Druid)
        [3043] = "HUNTER", -- Scorpid Sting (Hunter)
      },
    ["-Attack Power"] = {
        [50511] = "WARLOCK", -- Curse of Weakness (Warlock)
        [18180] = "WARLOCK", -- Improved Curse of Weakness (Warlock)
        [48560] = "DRUID",   -- Demoralizing Roar (Feral Druid)
        [16862] = "DRUID",   -- Feral Aggression (Feral Druid)
        [47437] = "WARRIOR", -- Demoralizing Shout (Warrior)
        [12879] = "WARRIOR", -- Improved Demoralizing Shout (Warrior)
        [26016] = "PALADIN", -- Vindication (Paladin)
        [55487] = "HUNTER",  -- Demoralizing Screech (Hunter pet)
      },
    ["-Attack Speed"] = {
        [49909] = "DEATHKNIGHT", -- Icy Touch (DK)
        [51456] = "DEATHKNIGHT", -- Improved Icy Touch (DK)
        [48467] = "DRUID",       -- Hurricane (Balance Druid)
        [48485] = "DRUID",       -- Infected Wounds (Feral Druid)
        [53696] = "PALADIN",     -- Judgements of the Just (Protection Paladin)
        [49231] = "SHAMAN",      -- Earth Shock (Enhancement Shaman)
        [51524] = "SHAMAN",      -- Earthen Power (Enhancement Shaman)
        [47502] = "WARRIOR",     -- Thunder Clap (Warrior)
        [12666] = "WARRIOR",     -- Improved Thunder Clap (Protection Warrior)
      },
    
    -- Multi Purpose
    ["Heroism/Bloodlust"] = {
        [2825] = "SHAMAN", -- Bloodlust (Shaman)
      },
    ["+All Stats"] = {
        [48469] = "DRUID", -- Mark of the Wild (Druid)
        [17051] = "DRUID", -- (Improved) Mark of the Wild
      },      
    ["+10% All Stats"] = {
        [20217] = "PALADIN", -- Blessing of Kings
      },
    ["+3% Damage"] = {
        [34460] = "HUNTER",  -- Ferocious Inspiration (Beast Mastery Hunter)
        [31869] = "PALADIN", -- Sanctified Retribution (Retribution Paladin)
        [31583] = "MAGE",    -- Arcane Empowerment (Arcane Mage)
      },
    ["+3% Haste"] = {
        [48396] = "DRUID",   -- Improved Moonkin Form (Balance Druid)
        [53648] = "PALADIN", -- Swift Retribution (Retribution Paladin)
      },
    ["+3% Crit"] = {
        [20337] = "PALADIN", -- Heart of the Crusader (Most Paladins)
        [58410] = "ROGUE",   -- Master Poisoner (Assassination Rogue)
        [57722] = "SHAMAN",  -- Totem of Wrath (Elemental Shaman)
      },
    
    -- Situational
    ["Frost Res."] = {
        [48945] = "PALADIN", -- Frost Resistance Aura (Paladin)
        [58745] = "SHAMAN",  -- Frost Resistance Totem (Shaman)
      },
    ["Fire Res."] = {
        [48947] = "PALADIN", -- Fire Resistance Aura (Paladin)
        [58739] = "SHAMAN",  -- Fire Resistance Totem (Shaman)
      },
    ["Nature Res."] = {
        [58749] = "SHAMAN", -- Nature Resistance Totem (Shaman)
        [49071] = "HUNTER", -- Aspect of the Wild (Hunter)
      },
    ["Shadow Res."] = {
        [48943] = "PALADIN", -- Shadow Resistance Aura (Paladin)
        [48170] = "PRIEST",  -- Shadow Protection (Priest)
      },
    ["-Healing Received"] = {
        [49050] = "HUNTER",  -- Aimed Shot (?? Hunter)
        [46911] = "WARRIOR", -- Furious Attacks (Fury Warrior)
        [47486] = "WARRIOR", -- Mortal Strike (Arms Warrior)
        [57978] = "ROGUE",   -- Wound Poison (Rogue)
        [12571] = "MAGE",    -- Permafrost (Frost Mage)
        [15316] = "PRIEST",  -- Improved Mind Blast (Shadow Priest)
      },
    ["-Cast Speed"] = {
        [11719] = "WARLOCK", -- Curse of Tongues (Warlock)
        [58611] = "HUNTER",  -- Lava Breath (Hunter Exotic Pet)
        [5761] = "ROGUE",    -- Mind-Numbing Poison (Rogue)
        [31589] = "MAGE",    -- Slow (Mage)
      },
    
    -- Count
    ["Replenishment"] = {
        [53292] = "HUNTER",  -- Hunting Party (Survival Hunter)
        [31878] = "PALADIN", -- Judgement of the Wise (Retribution Paladin)
        [48160] = "PRIEST",  -- Vampiric Touch (Shadow Priest)
        [54118] = "WARLOCK", -- Improved Soul Leech (Destro Lock)
        [44561] = "MAGE",    -- Enduring Winter (Frost Mage)
      },
    ["Remove Magic"] = {
        [988] = "PRIEST",   -- Dispel Magic (Priest)
        [4987] = "PALADIN", -- Cleanse (Paladin)
      },
    ["Remove Poison"] = {
        [2893] = "DRUID",   -- Abolish Poison (Druid)
        [526] = "SHAMAN",   -- Cure Toxins (Shaman)
        [4987] = "PALADIN", -- Cleanse (Paladin)
      },
    ["Remove Curse"] = {
        [51886] = "SHAMAN", -- Cleanse Spirit (Restoration Shaman)
        [2782] = "DRUID",   -- Remove Curse (Druid)
        [475] = "MAGE",     -- Remove Curse (Mage)
      },
    ["Remove Disease"] = {
        [552] = "PRIEST",   -- Abolish Disease (Priest)
        [526] = "SHAMAN",   -- Cure Toxins (Shaman)
        [4987] = "PALADIN", -- Cleanse (Paladin)
      },
    ["Reduce Damage"] = {
        [6940] = "PALADIN",      -- Hand of Sacrifice (Paladin)
        [64205] = "PALADIN",     -- Divine Sacrifice (Paladin)
        [33206] = "PRIEST",      -- Pain Suppression (Priest)
        [47788] = "PRIEST",      -- Guardian Spirit (Priest)
        [51052] = "DEATHKNIGHT", -- Anti-Magic Zone (Death Knight)
      },
    ["Power Restore"] = {
        [48545] = "DRUID",  -- Revitalize (Restoration Druid)
        [47537] = "PRIEST", -- Rapture (Discipline Priest)
      },
    ["Interrupt"] = {
        [47528] = "DEATHKNIGHT", -- Mind Freeze (Death Knight)
        [2139] = "MAGE",         -- Counterspell (Mage)
        [1766] = "ROGUE",        -- Kick (Rogue)
        [57994] = "SHAMAN",      -- Wind Shear (Shaman)
        [6552] = "WARRIOR",      -- Pummel (Warrior)
        [72] = "WARRIOR",        -- Shield Bash (Protection Warrior)
      },
    ["Purge"] = {
        [8012] = "SHAMAN",   -- Purge (Shaman)
        [988] = "PRIEST",    -- Dispel Magic (Priest)
        [19801] = "HUNTER",  -- Tranquilizing Shot (Hunter)
        [30449] = "MAGE",    -- Spellsteal (Mage)
        [47488] = "WARRIOR", -- Shield Slam (Warrior)
      },
    ["Remove Enrage"] = {
        [19801] = "HUNTER", -- Tranquilizing Shot (Hunter)
        [57982] = "ROGUE",  -- Anesthetic Poison (Rogue)
      },
    ["Remove Protection"] = {
        [32375] = "PRIEST",  -- Mass Dispel (Priest)
        [64382] = "WARRIOR", -- Shattering Throw (Warrior)
      },

    -- Crowd Control
    ["CC - Humanoid"] = {
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [12826] = "MAGE",    -- Polymorph (Mage)
        [20066] = "PALADIN", -- Repentance (Paladin)
        [51724] = "ROGUE",   -- Sap (Rogue)
        [51514] = "SHAMAN",  -- Hex (Shaman)
      },
    ["CC - Beast"] = {
        [18658] = "DRUID",  -- Hibernate (Druid)
        [14311] = "HUNTER", -- Freezing Trap (Hunter)
        [12826] = "MAGE",   -- Polymorph (Mage)
        [51724] = "ROGUE",  -- Sap (Rogue)
        [51514] = "SHAMAN", -- Hex (Shaman)
      },
    ["CC - Dragonkin"] = {
        [18658] = "DRUID",   -- Hibernate (Druid)
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [12826] = "MAGE",    -- Polymorph (Mage)
        [20066] = "PALADIN", -- Repentance (Paladin)
        [51724] = "ROGUE",   -- Sap (Rogue)
      },
    ["CC - Giant"] = {
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [20066] = "PALADIN", -- Repentance (Paladin)
      },
    ["CC - Elemental"] = {
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [18647] = "WARLOCK", -- Banish (Warlock)
      },
    ["CC - Demon"] = {
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [20066] = "PALADIN", -- Repentance (Paladin)
        [51724] = "ROGUE",   -- Sap (Rogue)
        [18647] = "WARLOCK", -- Banish (Warlock)
      },
    ["CC - Undead"] = {
        [14311] = "HUNTER",  -- Freezing Trap (Hunter)
        [20066] = "PALADIN", -- Repentance (Paladin)
        [10955] = "PRIEST",  -- Shackle Undead (Priest)
      },
    
    -- Spec types
    ["Tanks"] = {
        ["DEATHKNIGHT TANK"] = "DEATHKNIGHT", -- DK Tank spec
        ["DRUID TANK"] = "DRUID",             -- Druid Tank spec
        ["PALADIN TANK"] = "PALADIN",         -- Paladin Tank spec
        ["WARRIOR TANK"] = "WARRIOR",         -- Warrior Tank spec
      },
    ["Melee DPS"] = {
        ["DEATHKNIGHT MELEE"] = "DEATHKNIGHT", -- DK Melee DPS spec
        ["DRUID MELEE"] = "DRUID",             -- Druid Melee DPS spec
        ["PALADIN MELEE"] = "PALADIN",         -- Paladin Melee DPS spec
        ["ROGUE MELEE"] = "ROGUE",             -- Rogue Melee DPS spec
        ["SHAMAN MELEE"] = "SHAMAN",           -- Shaman Melee DPS spec
        ["WARRIOR MELEE"] = "WARRIOR",         -- Warrior Melee DPS spec
      },
    ["Ranged DPS"] = {
        ["DRUID RANGED"] = "DRUID",     -- Druid Ranged DPS spec
        ["HUNTER RANGED"] = "HUNTER",   -- Hunter Ranged DPS spec
        ["MAGE RANGED"] = "MAGE",       -- Mage Ranged DPS spec
        ["PRIEST RANGED"] = "PRIEST",   -- Priest Ranged DPS spec
        ["SHAMAN RANGED"] = "SHAMAN",   -- Shaman Ranged DPS spec
        ["WARLOCK RANGED"] = "WARLOCK", -- Warlock Ranged DPS spec
      },
    ["Healers"] = {
        ["DRUID HEALER"] = "DRUID",     -- Druid Healer spec
        ["PALADIN HEALER"] = "PALADIN", -- Paladin Healer spec
        ["PRIEST HEALER"] = "PRIEST",   -- Priest Healer spec
        ["SHAMAN HEALER"] = "SHAMAN",   -- Shaman Healer spec
      },
  }


--[[
Some buff in a category is considered superior to another buff in the same category,
  if it grants more of a stat, a higher increase, etc.
If buff A and a buff B give the same boost, they are considered equal. If buff A is
  is more easily applied or applied to more targets, it is still considered equal to buff B.
"1" is the best buff in the category, higher numbers are inferior buffs.
--]]
addon.SPELLRANK = {
    -- Physical
    ["+Attack Power"] = {
        [47436] = 2, -- Battle Shout (Warrior)
        [12861] = 1, -- (Commanding Presence) Battle Shout (Fury Warrior)
        [48932] = 2, -- Blessing of Might (Paladin)
        [20045] = 1, -- (Improved) Blessing of Might (Retribution Paladin)
      },
    ["+10% AP"] = {
        [53138] = 1, -- Abomination's Might (Blood DK)
        [19506] = 1, -- Trueshot Aura (Marksmanship Hunter)
        [30809] = 1, -- Unleashed Rage (Enhancement Shaman)
      },
    ["+Agi & Str"] = {
        [57623] = 2, -- Horn of Winter (DK)
        [58643] = 2, -- Strength of Earth Totem (Shaman)
        [52456] = 1, -- (Enhancing Totems) Strength of Earth Totem (Enhancement Shaman)
      },
    ["+5% Melee Crit"] = {
        [17007] = 1, -- Leader of the Pack (Feral Druid)
        [29801] = 1, -- Rampage (Fury Warrior)
      },
    ["+20% Melee Haste"] = {
        [55610] = 1, -- Improved Icy Talons (DK)
        [8512] = 2, -- Windfury Totem (Shaman)
        [29193] = 1, -- (Improved) Windfury Totem (Enhancement Shaman)
      },
    ["-20% Armor"] = {
        [55754] = 1, -- Acid Spit (Hunter Exotic Pet)
        [8647] = 1, -- Expose Armor (Rogue)
        [7386] = 1, -- Sunder Armor (Warrior)
      },
    ["-5% Armor"] = {
        [50511] = 1, -- Curse of Weakness (Warlock)
        [770] = 1, -- Faerie Fire (Druid)
        [56631] = 1, -- Sting (Hunter Pet)
      },
    ["+4% Phys. Dam."] = {
        [29859] = 1, -- Blood Frenzy (Arms Warrior)
        [58413] = 1, -- Savage Combat (Combat Rogue)
      },
    ["+Bleed Damage"] = {
        [33917] = 1, -- Mangle (Feral Druid)
        [46855] = 1, -- Trauma (Arms Warrior)
		[57393] = 2, -- Stampede (Hunter Exotic Pet)
      },
      

    -- Magical
    ["+Spell Power"] = {
        [47240] = 1, -- Demonic Pact (Demonolgy Warlock)
        [58656] = 3, -- Flametongue Totem (Shaman)
        [52456] = 2, -- (Enhancing Totems) Flametongue Totem
        [57722] = 1, -- Totem of Wrath (Elemental Shaman)
      },
    ["+5% Crit (buff)"] = {
        [51470] = 1, -- Elemental Oath (Elemental Shaman)
        [24907] = 1, -- Moonkin Form (Balance Druid)
      },
    ["+5% Spell Haste"] = {
        [3738] = 1, -- Wrath of Air Totem (Shaman)
      },
    ["+Intellect"] = {
        [42995] = 1, -- Arcane Intellect (Mage)
        [57567] = 3, -- Fel Intelligence (Warlock Felhunter)
        [54038] = 2, -- (Improved Felhunter) Fel Intelligence
      },
    ["+Spirit"] = {
        [48073] = 1, -- Divine Spirit (Discipline Priest)
        [57567] = 3, -- Fel Intelligence (Warlock Felhunter)
        [54038] = 2, -- (Improved Felhunter) Fel Intelligence
      },
    ["+Mana Regen"] = {
        [48936] = 2, -- Blessing of Wisdom (Paladin)
        [20245] = 1, -- (Improved) Blessing of Wisdom
        [58774] = 2, -- Mana Spring Totem (Shaman)
        [16206] = 1, -- Restorative Totems (Shaman)
      },
    ["+13% Spell Dam."] = {
        [47865] = 1, -- Curse of the Elements (Warlock)
        [48511] = 1, -- Earth and Moon (Balance Druid)
        [51161] = 1, -- Ebon Plaguebringer (Unholy DK)
      },
    ["+5% Crit (debuff)"] = {
        [12873] = 1, -- Improved Scorch (Fire Mage)
        [28593] = 1, -- Winter's Chill (Frost Mage)
        [17803] = 1, -- Improved Shadow Bolt (Warlock)
      },
    ["+3% Spell Hit"] = {
        [33602] = 1, -- Improved Faerie Fire (Balance Druid)
        [33193] = 1, -- Misery (Shadow Priest)
      },
    ["+30% Disease Dam."] = {
        [49632] = 1, -- Crypt Fever (Unholy DK)
      },
    
    
    -- Survival
    ["+Health"] = {
        [47982] = 4, -- Blood Pact (Warlock Imp)
        [18696] = 3, -- (Improved Imp) Blood Pact
        [47440] = 2, -- Commanding Shout (Warrior)
        [12861] = 1, -- (Commanding Presence) Commanding Shout (Fury Warrior)
      },
    ["+Stamina"] = {
        [48161] = 2, -- Power Word: Fortitude (Priest)
        [14767] = 1, -- (Improved) Power Word: Fortitude
      },
    ["+6% Healing"] = {
        [20140] = 1, -- Improved Devotion Aura (?? Paladin)
        [33891] = 1, -- Tree of Life (Restoration Druid)
      },
    ["+Armor Aura"] = {
        [48942] = 2, -- Devotion Aura (Paladin)
        [20140] = 1, -- (Improved) Devotion Aura
      },
    ["+Armor Totem"] = {
        [58753] = 2, -- Stoneskin Totem (Shaman)
        [16293] = 1, -- (Guardian Totems) Stoneskin Totem
      },
    ["+25% Armor Proc"] = {
        [16240] = 1, -- Ancestral Healing (Resto Shaman)
        [15363] = 1, -- Inspiration (Holy/Disc Priest)
      },
    ["Healthstone"] = {
        [58887] = 2, -- Ritual of Souls (Warlock)
        [18693] = 1, -- Improved Healthstone (Warlock)
      },
    ["-3% Dam. Taken"] = {
        [20911] = 1, -- Blessing of Sanctuary (Protection Paladin)
        [57472] = 1, -- Renewed Hope (Discipline Priest)
      },
    ["-3% Hit Taken"] = {
        [48468] = 1, -- Insect Swarm (Balance Druid)
        [3043] = 1, -- Scorpid Sting (Hunter)
      },
    ["-Attack Power"] = {
        [50511] = 2, -- Curse of Weakness (Warlock)
        [18180] = 1, -- Improved Curse of Weakness
        [48560] = 3, -- Demoralizing Roar (Feral Druid)
        [16862] = 1, -- (Feral Aggression) Demoralizing Roar
        [47437] = 3, -- Demoralizing Shout (Warrior)
        [12879] = 1, -- (Improved) Demoralizing Shout
        [26016] = 1, -- Vindication (Paladin)
        [55487] = 1, -- Demoralizing Screech (Hunter pet)
      },
    ["-Attack Speed"] = {
        [49909] = 2, -- Icy Touch (DK)
        [51456] = 1, -- (Improved) Icy Touch (Frost/Tank DK)
        [48467] = 1, -- Hurricane (Balance Druid)
        [48485] = 1, -- Infected Wounds (Feral Druid)
        [53696] = 1, -- Judgements of the Just (Protection Paladin)
        [49231] = 2, -- Earth Shock (Enhancement Shaman)
        [51524] = 1, -- Earthen Power (Enhancement Shaman)
        [47502] = 2, -- Thunder Clap (Warrior)
        [12666] = 1, -- (Improved) Thunder Clap (Protection Warrior)
      },

   
    -- Multi Purpose
    ["Heroism/Bloodlust"] = {
        [2825] = 1, -- Bloodlust (Shaman)
      },
    ["+All Stats"] = {
        [48469] = 2, -- Mark of the Wild (Druid)
        [17051] = 1, -- (Improved) Mark of the Wild
      },      
    ["+10% All Stats"] = {
        [20217] = 1, -- Blessing of Kings
      },
    ["+3% Damage"] = {
        [34460] = 1, -- Ferocious Inspiration (Beast Mastery Hunter)
        [31869] = 1, -- Sanctified Retribution (Retribution Paladin)
        [31583] = 1, -- Arcane Empowerment (Arcane Mage)
      },
    ["+3% Haste"] = {
        [48396] = 1, -- Improved Moonkin Form (Balance Druid)
        [53648] = 1, -- Swift Retribution (Retribution Paladin)
      },
    ["+3% Crit"] = {
        [20337] = 1, -- Heart of the Crusader (Most Paladins)
        [58410] = 1, -- Master Poisoner (Assassination Rogue)
        [57722] = 1, -- Totem of Wrath (Elemental Shaman)
      },
   
    -- Count
    -- Not Applicable
    
    -- Resistances
    ["Frost Res."] = {
        [48945] = 1, -- Frost Resistance Aura (Paladin)
        [58745] = 1, -- Frost Resistance Totem (Shaman)
      },
    ["Fire Res."] = {
        [48947] = 1, -- Fire Resistance Aura (Paladin)
        [58739] = 1, -- Fire Resistance Totem (Shaman)
      },
    ["Nature Res."] = {
        [58749] = 1, -- Nature Resistance Totem (Shaman)
        [49071] = 1, -- Aspect of the Wild (Hunter)
      },
    ["Shadow Res."] = {
        [48943] = 1, -- Shadow Resistance Aura (Paladin)
        [48170] = 1, -- Shadow Protection (Priest)
      },
    ["-Healing Received"] = {
        [49050] = 1, -- Aimed Shot (?? Hunter)
        [46911] = 1, -- Furious Attacks (Fury Warrior)
        [47486] = 1, -- Mortal Strike (Arms Warrior)
        [57978] = 1, -- Wound Poison (Rogue)
        [12571] = 2, -- Permafrost (Frost Mage)
        [15316] = 2, -- Improved Mind Blast (Shadow Priest)
      },
    ["-Cast Speed"] = {
        [11719] = 1, -- Curse of Tongues (Warlock)
        [58611] = 2, -- Lava Breath (Hunter Exotic Pet)
        [5761] = 1, -- Mind-Numbing Poison (Rogue)
        [31589] = 1, -- Slow (Mage)
      },  
  }
