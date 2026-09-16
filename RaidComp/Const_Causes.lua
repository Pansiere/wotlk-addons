local addon = RaidComp

addon.FULL = 12
local FULL = addon.FULL
addon.HALF = 6
local HALF = addon.HALF
addon.THIRD = 4
local THIRD = addon.THIRD
addon.QUARTER = 3
local QUARTER = addon.QUARTER
addon.SIXTH = 2
local SIXTH = addon.SIXTH
addon.TWELFTH = 2
local TWELFTH = addon.TWELFTH

addon.CAUSESPEC = {
    ["DRUID1"] = { -- Balance
        [770] = FULL, -- Faerie Fire
        [2782] = FULL, -- Remove Curse
        [2893] = FULL, -- Abolish Poison
        [18658] = FULL, -- Hibernate
        [48467] = TWELFTH, -- Hurricane  -- Set to TWELFTH so that it should always show as MAYBE, since Druids will not use this on single targets
        ["DRUID RANGED"] = FULL, -- Druid Ranged DPS spec
      },
    ["DRUID2"] = { -- Feral Combat
        [770] = FULL, -- Faerie Fire
        ["DRUID MELEE"] = FULL, -- Druid Melee DPS spec
      },
    ["DRUID3"] = { -- Restoration
        [2782] = FULL, -- Remove Curse
        [2893] = FULL, -- Abolish Poison
        [18658] = FULL, -- Hibernate
        ["DRUID HEALER"] = FULL, -- Druid Healer spec
      },
    ["PALADIN1"] = { -- Holy
        ["PALADIN HEALER"] = FULL, -- Paladin Healer spec
      },
    ["PALADIN2"] = { -- Protection
        ["PALADIN MELEE"] = FULL, -- Paladin Melee DPS spec
        ["PALADIN TANK"] = FULL, -- Paladin Tank spec
      },      
    ["PALADIN3"] = { -- Retribution
        ["PALADIN MELEE"] = FULL, -- Paladin Melee DPS spec
      },      
    ["PRIEST1"] = { -- Discipline
        ["PRIEST HEALER"] = FULL, -- Priest Healer spec
      },
    ["PRIEST2"] = { -- Holy
        ["PRIEST HEALER"] = FULL, -- Priest Healer spec
      },      
    ["PRIEST3"] = { -- Shadow
        ["PRIEST RANGED"] = FULL, -- Priest Ranged DPS spec
      },      
    ["SHAMAN1"] = { -- Elemental
        [57994] = FULL, -- Wind Shear (Shaman)
        ["SHAMAN RANGED"] = FULL, -- Shaman Ranged DPS spec
      },
    ["SHAMAN2"] = { -- Enhancement
        [49231] = FULL, -- Earth Shock (Shaman)
        [57994] = FULL, -- Wind Shear (Shaman)
        ["SHAMAN MELEE"] = FULL, -- Shaman Melee DPS spec
      },      
    ["SHAMAN3"] = { -- Restoration
        ["SHAMAN HEALER"] = FULL, -- Shaman Healer spec
      },      
    ["WARRIOR2"] = { -- Fury
        [6552] = FULL, -- Pummel
      },
    ["WARRIOR3"] = { -- Protection
        [47488] = FULL, -- Shield Slam
        [72] = FULL, -- Shield Bash
        ["WARRIOR TANK"] = FULL, -- Warrior Tank spec
      },
  }

addon.CAUSECLASS = {
    ["DEATHKNIGHT"] = {
        [57623] = FULL, -- Horn of Winter
        [49909] = FULL, -- Icy Touch
        [47528] = FULL, -- Mind Freeze
        ["DEATHKNIGHT MELEE"] = FULL, -- DK Melee DPS spec
      },
    ["DRUID"] = {
        [48469] = FULL, -- Mark of the Wild
--        [48477] = FULL, -- Rebirth    -- Not considered (yet)
      },
    ["HUNTER"] = {
        [3043] = FULL, -- Scorpid Sting
        [19801] = FULL, -- Tranquilizing Shot
        [49071] = TWELFTH, -- Aspect of the Wild   -- set to TWELFTH so that it should always show as MAYBE, since Hunters will not use this unless asked
        [14311] = FULL, -- Freezing Trap
        ["HUNTER RANGED"] = FULL, -- Hunter Ranged DPS spec
      },
    ["MAGE"] = {
        [42995] = FULL, -- Arcane Intellect
        [30449] = FULL, -- Spellsteal
        [475] = FULL, -- Remove Curse
        [2139] = FULL, -- Counterspell
        [12826] = FULL, -- Polymorph
        ["MAGE RANGED"] = FULL, -- Mage Ranged DPS spec
      },
    ["PALADIN"] = {
        [48942] = HALF, -- Devotion Aura   -- split with Retribution Aura
        [20217] = HALF, -- Blessing of Kings
        [48932] = HALF, -- Blessing of Might   -- Though 2 Paladins are technically not enough to cast BoM, BoW and BoK on 1 raid member, they are sufficient to buff BoM/BoK and BoW/BoK combos
        [48936] = HALF, -- Blessing of Wisdom
--        [20271] = HALF, -- Judgement of Light   -- These are not considered (yet) by the calculation
--        [53408] = HALF, -- Judgement of Wisdom
        [4987] = FULL, -- Cleanse
        [6940] = FULL, -- Hand of Sacrifice
        [48945] = QUARTER, -- Frost Resistance Aura    -- \
        [48947] = QUARTER, -- Fire Resistance Aura     -- "QUARTER" implies it requires a 4th paladin to make a 'green check', assuming only 1 resistance aura is required at the same time
        [48943] = QUARTER, -- Shadow Resistance Aura   -- /
      },
    ["PRIEST"] = {
        [48161] = FULL, -- Power Word: Fortitude
        [48073] = FULL, -- Divine Spirit
        [988] = FULL, -- Dispel Magic
        [552] = FULL, -- Abolish Disease
        [48170] = FULL, -- Shadow Protection
        [10955] = FULL, -- Shackle Undead
        [32375] = FULL, -- Mass Dispel
      },
    ["ROGUE"] = {
        [8647] = FULL, -- Expose Armor
        [5761] = FULL, -- Mind-Numbing Poison
        [57978] = FULL, -- Wound Poison
        [57982] = FULL, -- Anesthetic Poison
        [1766] = FULL, -- Kick
        [51724] = FULL, -- Sap
        ["ROGUE MELEE"] = FULL, -- Rogue Melee DPS spec
      },
    ["SHAMAN"] = {
        [58643] = HALF, -- Strength of Earth   -- 'normal' totems don't share check with the resistance totems, for simplicity reasons
        [58753] = HALF, -- Stoneskin Totem
        [2825] = FULL, -- Bloodlust/Heroism
        [8512] = HALF, -- Windfury Totem
        [3738] = HALF, -- Wrath of Air
        [58656] = FULL, -- Flametongue Totem
        [58774] = FULL, -- Mana Spring Totem   -- Cleansing totems are considered to be situational
        [8012] = FULL, -- Purge
        [526] = FULL, -- Cure Toxins
        [58745] = THIRD, -- Frost Resistance Totem     -- \
        [58739] = THIRD, -- Fire Resistance Totem      -- "THIRD" implies it requires a 3rd shaman to light them up
        [58749] = THIRD, -- Nature Resistance Totem    -- /
        [51514] = FULL, -- Hex
      },
    ["WARLOCK"] = {
        [50511] = TWELFTH, -- Curse of Weakness     -- set to TWELFTH so that it should always show as MAYBE, since Warlocks will not use this unless asked
        [11719] = TWELFTH, -- Curse of Tongues      -- /
        [47865] = HALF, -- Curse of the Elements    -- set to HALF as one Warlock cannot provide both this and CoW/CoT
--        [47884] = FULL, -- Soulstone     -- Not considered (yet)
        [18647] = FULL, -- Banish
        [58887] = FULL, -- Ritual of Souls
        ["WARLOCK RANGED"] = FULL, -- Warlock Ranged DPS spec
      },
    ["WARRIOR"] = {
        [47436] = HALF, -- Battle Shout
        [47440] = HALF, -- Commanding Shout
        [7386] = FULL, -- Sunder Armor
        [47437] = FULL, -- Demoralizing Shout
        [47502] = FULL, -- Thunder Clap
        [64382] = FULL, -- Shattering Throw
        ["WARRIOR MELEE"] = FULL, -- Warrior Melee DPS spec
      },
  }

-- The data below differentiates between talents that improve other abilities (IMPROVES) and talents that grant abilities (ABSOLUTE)
-- This is not used in any way (yet) in the calculation

-- These talents improve all paladin auras (and therefore listed as ABSOLUTE):
--   Sanctified Retribution
--   Swift Retribution

-- Improved Devotion aura is relevant to 2 categories
--   +Armor (here it increases Devotion Aura)
--   +6% Healing (here it is absolute)
-- Because the calculation doesn't make a difference between IMPROVES and ABSOLUTE (yet), it is listed as ABSOLUTE

addon.IMPROVES = 12
local IMPROVES = addon.IMPROVES
addon.ABSOLUTE = 12
local ABSOLUTE = addon.ABSOLUTE

addon.CAUSETALENT = {
    ["DEATHKNIGHT"] = {
        [53138] = ABSOLUTE, -- Abomination's Might
        [55610] = ABSOLUTE, -- Improved Icy Talons
        [49632] = ABSOLUTE, -- Crypt Fever
        [51161] = ABSOLUTE, -- Ebon Plaguebringer
        [51052] = ABSOLUTE, -- Anti-Magic Zone
        ["DEATHKNIGHT TANK"] = ABSOLUTE, -- DK Tank spec

        [51456] = IMPROVES, -- Improved Icy Touch
      },
    ["DRUID"] = {
        [48396] = ABSOLUTE, -- Improved Moonkin Form
        [48545] = ABSOLUTE, -- Revitalize
        [33891] = ABSOLUTE, -- Tree of Life
        [17007] = ABSOLUTE, -- Leader of the Pack
        [24907] = ABSOLUTE, -- Moonkin Form
        [33917] = ABSOLUTE, -- Mangle
        [48485] = ABSOLUTE, -- Infected Wounds
        [48468] = ABSOLUTE, -- Insect Swarm
        [48511] = ABSOLUTE, -- Earth and Moon
        [33602] = ABSOLUTE, -- Improved Faerie Fire
        ["DRUID TANK"] = ABSOLUTE, -- Druid Tank spec
        [48560] = ABSOLUTE, -- Demoralizing Roar  -- Although this is base class ability, only Druid Tanks will use it so we base it on the same talent

        [17051] = IMPROVES, -- Improved Mark of the Wild
        [16862] = IMPROVES, -- Feral Aggression (Demo Roar)
      },
    ["HUNTER"] = {
        [19506] = ABSOLUTE, -- Trueshot Aura
        [34460] = ABSOLUTE, -- Ferocious Inspiration
        [49050] = ABSOLUTE, -- Aimed Shot
        [53292] = ABSOLUTE, -- Hunting Party (Replenishment)
      },
    ["MAGE"] = {
        [31583] = ABSOLUTE, -- Arcane Empowerment
        [31589] = ABSOLUTE, -- Slow
        [12873] = ABSOLUTE, -- Improved Scorch
        [12571] = ABSOLUTE, -- Permafrost
        [28593] = ABSOLUTE, -- Winter's Chill
        [44561] = ABSOLUTE, -- Enduring Winter (Replenishment)
      },
    ["PALADIN"] = {
        [20140] = ABSOLUTE, -- Improved Devotion Aura
        [31869] = ABSOLUTE, -- Sanctified Retribution (Retribution Aura)
        [53648] = ABSOLUTE, -- Swift Retribution (Retribution Aura)
        [20337] = ABSOLUTE, -- Heart of the Crusader
        [53696] = ABSOLUTE, -- Judgements of the Just
        [31878] = ABSOLUTE, -- Judgement of the Wise (Replenishment)
        [20066] = ABSOLUTE, -- Repentance
        [26016] = ABSOLUTE, -- Vindication
        [64205] = ABSOLUTE, -- Divine Sacrifice
        
        [20045] = IMPROVES, -- Improved Blessing of Might
        [20245] = IMPROVES, -- Improved Blessing of Wisdom
        [20911] = HALF,     -- Blessing of Sanctuary (extra Blessing)   -- Config'd as "HALF" so it requires 2 prot palas to light up a 'green check'
                            --  ^ So it'll show as 'yellow maybe' with only 1 prot paladin, which seems like a decent tradeoff between simplicity and fairness
      },
    ["PRIEST"] = {
        [15363] = ABSOLUTE, -- Inspiration
        [57472] = ABSOLUTE, -- Renewed Hope
        [15316] = ABSOLUTE, -- Improved Mind Blast
        [33193] = ABSOLUTE, -- Misery
        [48160] = ABSOLUTE, -- Vampiric Touch (Replenishment)
        [47537] = ABSOLUTE, -- Rapture
        [33206] = ABSOLUTE, -- Pain Suppression
        [47788] = ABSOLUTE, -- Guardian Spirit

        [14767] = IMPROVES, -- Improved Power Word: Fortitude
      },
    ["ROGUE"] = {
        [58410] = ABSOLUTE, -- Master Poisoner
        [58413] = ABSOLUTE, -- Savage Combat
      },
    ["SHAMAN"] = {
        [16240] = ABSOLUTE, -- Ancestral Healing
        [30809] = ABSOLUTE, -- Unleashed Rage
        [51470] = ABSOLUTE, -- Elemental Oath
        [57722] = ABSOLUTE, -- Totem of Wrath
--        [16190] = ABSOLUTE, -- Mana Tide Totem   -- Not considered (yet)
        [51886] = ABSOLUTE, -- Cleanse Spirit (decurse)

        [52456] = IMPROVES, -- Enhancing Totems (Strength of Earth Totem)
        [16293] = IMPROVES, -- Guardian Totems (Stoneskin Totem)
        [29193] = IMPROVES, -- Improved Windfury Totem
        [16206] = IMPROVES, -- Restorative Totems (Mana Spring Totem)
        [51524] = IMPROVES, -- Earthen Power (Earth Shock)
      },
    ["WARLOCK"] = {
        [47240] = ABSOLUTE, -- Demonic Pact
        [17803] = ABSOLUTE, -- Improved Shadow Bolt
        [54118] = ABSOLUTE, -- Improved Soul Leech (Replenishment, Destro Lock)

        [18696] = IMPROVES, -- Improved Imp
        [54038] = IMPROVES, -- Improved Felhunter
        [18180] = IMPROVES, -- Improved Curse of Weakness
        [18693] = IMPROVES, -- Improved Healthstone
      },
    ["WARRIOR"] = {
        [29801] = ABSOLUTE, -- Rampage
        [46855] = ABSOLUTE, -- Trauma
        [46911] = ABSOLUTE, -- Furious Attacks
        [47486] = ABSOLUTE, -- Mortal Strike
        [29859] = ABSOLUTE, -- Blood Frenzy

        [12861] = IMPROVES, -- Commanding Presence   (Battle Shout/Commanding Shout)
        [12879] = IMPROVES, -- Improved Demoralizing Shout
        [12666] = IMPROVES, -- Improved Thunder Clap
      },
  }
  
addon.IMPROVEDBY = {
    -- DEATHKNIGHT
    [49909] = 51456, -- Icy Touch <- Improved
    -- DRUID
    [48469] = 17051, -- Mark of the Wild <- Improved
    [48560] = 16862, -- Demoralizing Roar <- Feral Aggression
    -- PALADIN
    [48942] = 20140, -- Devotion Aura <- Improved
    [48932] = 20045, -- Blessing of Might <- Improved
    [0] = 31869, -- Any Aura <- Sanctified Retribution
    [1] = 53648, -- Any Aura <- Swift Retribution
    [48936] = 20245, -- Blessing of Wisdom <- Improved
    -- PRIEST
    [48161] = 14767, -- Power Word: Fortitude <- Improved
    -- SHAMAN
    [58643] = 52456, -- Strength of Earth Totem <- Enhancing Totems
    [58753] = 16293, -- Stoneskin Totem <- Guardian Totems
    [8512] = 29193, -- Windfury Totem <- Improved
    [58656] = 52456, -- Flametongue Totem <- Enhancing Totems
    [58774] = 16206, -- Mana Spring Totem <- Restorative Totems
    [49231] = 51524, -- Earth Shock <- Earthen Power
    -- WARLOCK
    [47982] = 18696, -- Blood Pact <- Improved Imp
    [57567] = 54038, -- Fel Intelligence <- Improved Felhunter
    [50511] = 18180, -- Curse of Weakness <- Improved
    [58887] = 18693, -- Ritual of Souls <- Improved Healthstone
    -- WARRIOR
    [47436] = 12861, -- Battle Shout <- Commanding Presence
    [47440] = 12861, -- Commanding Shout <- Commanding Presence
    [47437] = 12879, -- Demoralizing Shout <- Improved
    [47502] = 12666, -- Thunder Clap <- Improved
  }

-- Improved Curse of Weakness does not improve Curse of Weakness in the "-5% Armor" buff-item
-- Though there is only 1 case thus far, the array is used in a generic way.  
addon.IMPROVEDBY_EXCEPTION = {
    ["-5% Armor"] = {
        [50511] = true,
      },
  }

-- If the talent is not listed here, maxRank is required for it to be accepted.
addon.RANKFORACCEPT = {
    ["DEATHKNIGHT"] = {
      },
    ["DRUID"] = {
      },
    ["HUNTER"] = {
        [53292] = 2, -- Hunting Party (Replenishment)
      },
    ["MAGE"] = {
        [44561] = 1, -- Enduring Winter (Replenishment)
      },
    ["PALADIN"] = {
        [31878] = 2, -- Judgements of the Wise (Replenishment)
      },
    ["PRIEST"] = {
      },
    ["ROGUE"] = {
      },
    ["SHAMAN"] = {
      },
    ["WARLOCK"] = {
        [18693] = 1, -- Improved Healthstone
      },
    ["WARRIOR"] = {
        [12879] = 3, -- Improved Demoralizing Shout
        [12861] = 3, -- Commanding Presence
      },
  }
