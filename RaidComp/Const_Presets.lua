local addon = RaidComp

addon.PRESETS = {
    
    ["DEATHKNIGHT"] = {
        {   presetName = "Blood DPS",
            specId = 1,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_BloodPresence",
            icon1 = "Interface\\Icons\\Ability_MeleeDamage",
            keyTalents = {
                [53138] = true, -- Abomination's Might
              },
          },
        {   presetName = "Blood Tank",
            specId = 1,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_BloodPresence",
            icon1 = "Interface\\Icons\\Ability_Defend",
            keyTalents = {
                [53138] = true, -- Abomination's Might
                [51456] = true, -- Improved Icy Touch
                ["DEATHKNIGHT TANK"] = true, -- DK Tank spec
              },
          },
        {   presetName = "Frost DPS",
            specId = 2,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_FrostPresence",
            icon1 = "Interface\\Icons\\Ability_MeleeDamage",
            keyTalents = {
                [53138] = true, -- Abomination's Might
                [51456] = true, -- Improved Icy Touch
                [55610] = true, -- Improved Icy Talons
              },
          },
        {   presetName = "Frost Tank",
            specId = 2,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_FrostPresence",
            icon1 = "Interface\\Icons\\Ability_Defend",
            keyTalents = {
                [53138] = true, -- Abomination's Might
                [51456] = true, -- Improved Icy Touch
                ["DEATHKNIGHT TANK"] = true, -- DK Tank spec
              },
          },
        {   presetName = "Unholy DPS",
            specId = 3,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_UnholyPresence",
            icon1 = "Interface\\Icons\\Ability_MeleeDamage",
            keyTalents = {
                [49632] = true, -- Crypt Fever
                [51161] = true, -- Ebon Plaguebringer
              },
          },
        {   presetName = "Unholy Tank",
            specId = 3,
            icon2 = "Interface\\Icons\\Spell_DeathKnight_UnholyPresence",
            icon1 = "Interface\\Icons\\Ability_Defend",
            keyTalents = {
                [51456] = true, -- Improved Icy Touch
                [49632] = true, -- Crypt Fever
                [51161] = true, -- Ebon Plaguebringer
                [51052] = true, -- Anti-Magic Zone
                ["DEATHKNIGHT TANK"] = true, -- DK Tank spec
              },
          },
        
      },

    ["DRUID"] = {
        {   presetName = "Balance",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Nature_StarFall",
            icon2 = "",
            keyTalents = {
                [48468] = true, -- Insect Swarm
                [24907] = true, -- Moonkin Form
                [48396] = true, -- Improved Moonkin Form
                [33602] = true, -- Improved Faerie Fire
                [48511] = true, -- Earth and Moon
                [17051] = true, -- Improved Mark of the Wild
              },
          },
        {   presetName = "Feral DPS",
            specId = 2,
            icon2 = "Interface\\Icons\\Ability_Racial_BearForm",
            icon1 = "Interface\\Icons\\Ability_MeleeDamage",
            keyTalents = {
                [16862] = true, -- Feral Aggression (Demo Roar)
                [17007] = true, -- Leader of the Pack
                [33917] = true, -- Mangle
                [17051] = true, -- Improved Mark of the Wild
              },
          },
        {   presetName = "Feral Tank",
            specId = 2,
            icon2 = "Interface\\Icons\\Ability_Racial_BearForm",
            icon1 = "Interface\\Icons\\Ability_Defend",
            keyTalents = {
                [16862] = true, -- Feral Aggression (Demo Roar)
                [17007] = true, -- Leader of the Pack
                [48485] = true, -- Infected Wounds
                [33917] = true, -- Mangle
                [17051] = true, -- Improved Mark of the Wild
                ["DRUID TANK"] = true, -- Druid Tank spec
                [48560] = true, -- Demoralizing Roar
              },
          },
        {   presetName = "Restoration",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Nature_HealingTouch",
            icon2 = "",
            keyTalents = {
                [17051] = true, -- Improved Mark of the Wild
                [33891] = true, -- Tree of Life
              },
          },
      },
      
    ["HUNTER"] = {
        {   presetName = "Beast Mastery",
            specId = 1,
            icon1 = "Interface\\Icons\\Ability_Hunter_BeastTaming",
            icon2 = "",
            keyTalents = {
                [34460] = true, -- Ferocious Inspiration
              },
          },
        {   presetName = "Marksmanship",
            specId = 2,
            icon1 = "Interface\\Icons\\Ability_Marksmanship",
            icon2 = "",
            keyTalents = {
                [49050] = true, -- Aimed Shot
                [19506] = true, -- Trueshot Aura
              },
          },
        {   presetName = "Survival",
            specId = 3,
            icon1 = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
            icon2 = "",
            keyTalents = {
                [53292] = true, -- Hunting Party (Replenishment)
              },
          },
      },
      
    ["MAGE"] = {
        {   presetName = "Arcane",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Holy_MagicalSentry",
            icon2 = "",
            keyTalents = {
                [31583] = true, -- Arcane Empowerment
                [31589] = true, -- Slow
              },
          },
        {   presetName = "Fire",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Fire_FlameBolt",
            icon2 = "",
            keyTalents = {
                [12873] = true, -- Improved Scorch
              },
          },
        {   presetName = "Frost",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Frost_FrostBolt02",
            icon2 = "",
            keyTalents = {
                [12571] = true, -- Permafrost
                [28593] = true, -- Winter's Chill
                [44561] = true, -- Enduring Winter (Replenishment) Frost Mage
              },
          },
      },
      
    ["PALADIN"] = {
        {   presetName = "Holy",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Holy_HolyBolt",
            icon2 = "",
            keyTalents = {
                [20245] = true, -- Improved Blessing of Wisdom
                [20337] = true, -- Heart of the Crusader
              },
          },
        {   presetName = "Protection",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Holy_DevotionAura",
            icon2 = "",
            keyTalents = {
                [20140] = true, -- Improved Devotion Aura
                [20911] = true, -- Blessing of Sanctuary (extra Blessing)
                [53696] = true, -- Judgements of the Just
                [20337] = true, -- Heart of the Crusader
              },
          },
        {   presetName = "Retribution",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            icon2 = "",
            keyTalents = {
                [20337] = true, -- Heart of the Crusader
                [20045] = true, -- Improved Blessing of Might
                [31869] = true, -- Sanctified Retribution (Retribution Aura)
                [31878] = true, -- Judgement of the Wise (Replenishment)
                [53648] = true, -- Swift Retribution (Retribution Aura)
              },
          },
      },
      
    ["PRIEST"] = {
        {   presetName = "Discipline",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Holy_WordFortitude",
            icon2 = "",
            keyTalents = {
                [14767] = true, -- Improved Power Word: Fortitude
                [57472] = true, -- Renewed Hope (Discipline Priest)
                [15363] = true, -- Inspiration
                [33206] = true, -- Pain Suppression
              },
          },
        {   presetName = "Holy",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Holy_HolyBolt",
            icon2 = "",
            keyTalents = {
                [14767] = true, -- Improved Power Word: Fortitude
                [15363] = true, -- Inspiration
                [47788] = true, -- Guardian Spirit
              },
          },
        {   presetName = "Shadow",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            icon2 = "",
            keyTalents = {
                [14767] = true, -- Improved Power Word: Fortitude
                [15316] = true, -- Improved Mind Blast
                [33193] = true, -- Misery
                [48160] = true, -- Vampiric Touch (Replenishment)
              },
          },
      },
      
    ["ROGUE"] = {
        {   presetName = "Assassination",
            specId = 1,
            icon1 = "Interface\\Icons\\Ability_Rogue_Eviscerate",
            icon2 = "",
            keyTalents = {
                [58410] = true, -- Master Poisoner
              },
          },
        {   presetName = "Combat",
            specId = 2,
            icon1 = "Interface\\Icons\\Ability_Backstab",
            icon2 = "",
            keyTalents = {
                [58413] = true, -- Savage Combat
              },
          },
        {   presetName = "Subtlety",
            specId = 3,
            icon1 = "Interface\\Icons\\Ability_Stealth",
            icon2 = "",
            keyTalents = {
              },
          },
      },
      
    ["SHAMAN"] = {
        {   presetName = "Elemental",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Nature_Lightning",
            icon2 = "",
            keyTalents = {
                [51470] = true, -- Elemental Oath
                [57722] = true, -- Totem of Wrath
              },
          },    
        {   presetName = "Enhancement",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Nature_LightningShield",
            icon2 = "",
            keyTalents = {
                [52456] = true, -- Enhancing Totems (Strength of Earth Totem)
                [29193] = true, -- Improved Windfury Totem
                [30809] = true, -- Unleashed Rage
              },
          },    
        {   presetName = "Restoration",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Nature_MagicImmunity",
            icon2 = "",
            keyTalents = {
                [16240] = true, -- Ancestral Healing
                [16206] = true, -- Restorative Totems (Mana Spring Totem)
                [16190] = true, -- Mana Tide Totem
                [51886] = true, -- Cleanse Spirit (decurse)
              },
          },    
      },
      
    ["WARLOCK"] = {
        {   presetName = "Affliction",
            specId = 1,
            icon1 = "Interface\\Icons\\Spell_Shadow_DeathCoil",
            icon2 = "",
            keyTalents = {
                [18180] = true, -- Improved Curse of Weakness
                [54038] = true, -- Improved Felhunter
                [17803] = true, -- Improved Shadow Bolt
              },
          },    
        {   presetName = "Demonology",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
            icon2 = "",
            keyTalents = {
                [47240] = true, -- Demonic Pact
                [17803] = true, -- Improved Shadow Bolt
              },
          },    
        {   presetName = "Demo-Destro",
            specId = 2,
            icon1 = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
            icon2 = "Interface\\Icons\\Spell_Shadow_RainOfFire",
            keyTalents = {
              },
          },    
        {   presetName = "Destruction",
            specId = 3,
            icon1 = "Interface\\Icons\\Spell_Shadow_RainOfFire",
            icon2 = "",
            keyTalents = {
                [54118] = true, -- Improved Soul Leech (Replenishment, Destro Lock)
              },
          },    
      },
      
    ["WARRIOR"] = {
        {   presetName = "Arms",
            specId = 1,
            icon1 = "Interface\\Icons\\Ability_Rogue_Eviscerate",
            icon2 = "",
            keyTalents = {
                [46855] = true, -- Trauma
                [47486] = true, -- Mortal Strike
                [29859] = true, -- Blood Frenzy
                [12879] = true, -- Improved Demoralizing Shout
                [12861] = true, -- Commanding Presence
              },
          },    
        {   presetName = "Fury",
            specId = 2,
            icon1 = "Interface\\Icons\\Ability_Warrior_InnerRage",
            icon2 = "",
            keyTalents = {
                [12879] = true, -- Improved Demoralizing Shout
                [12861] = true, -- Commanding Presence
                [46911] = true, -- Furious Attacks
                [29801] = true, -- Rampage
              },
          },    
        {   presetName = "Protection",
            specId = 3,
            icon1 = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
            icon2 = "",
            keyTalents = {
                [12666] = true, -- Improved Thunder Clap
              },
          },    
      },
  }
