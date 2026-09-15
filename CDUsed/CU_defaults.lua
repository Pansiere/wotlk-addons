--[[
  Cooldown Used by Kiki/Espêrance - European Conseil des Ombres
]]


--------------- Shared Constantes ---------------

CU_SPELLS_COOLDOWN_USED = 1; -- Spell used by raid member on someone
CU_SPELLS_AURA_GAINED = 2; -- Raid member gained an aura
CU_SPELLS_AURA_LOST = 3; -- Raid member lost an aura
CU_SPELLS_INTERRUPTED = 4; -- Raid member interrupted someone
CU_SPELLS_INTERRUPT_USED_SUCCESS = 5; -- SpellCastSuccess with an interrupt spell
CU_SPELLS_INTERRUPT_USED_FAILED = 6; -- SpellFailed with an interrupt
CU_SPELLS_TAUNTED = 7; -- Raid member successfully taunted
CU_SPELLS_TAUNT_MISSED = 8; -- Raid member failed to taunt
CU_SPELLS_RESURRECT = 9; -- Resurrection spell used
CU_SPELLS_CREATIONS = 10; -- Raid member creating things
CU_SPELLS_FEAST = 11; -- Feasts

CU_SpellTypeToName = {
 [CU_SPELLS_COOLDOWN_USED] = "CooldownUsed",
 [CU_SPELLS_AURA_GAINED] = "AuraGained",
 [CU_SPELLS_AURA_LOST] = "AuraLost",
 [CU_SPELLS_INTERRUPTED] = "Interrupted",
 [CU_SPELLS_INTERRUPT_USED_SUCCESS] = "InterruptUsedSuccess",
 [CU_SPELLS_INTERRUPT_USED_FAILED] = "InterruptUsedFailed",
 [CU_SPELLS_TAUNTED] = "Taunted",
 [CU_SPELLS_TAUNT_MISSED] = "TauntMissed",
 [CU_SPELLS_RESURRECT] = "SpellRez",
 [CU_SPELLS_CREATIONS] = "Creations",
 [CU_SPELLS_FEAST] = "Feast",
};

--------------- Spells ---------------

-- Spell creations
local TOY_TRAIN_SET = 61031;

-- Feasts
local GREAT_FEAST = 57301;
local FISH_FEAST = 57426;
local BOUNTIFUL_FEAST = 66476;

-- Cooldown spells
local DIVINE_PROTECTION = 498;
local HAND_OF_SACRIFICE = 6940;
local LAY_ON_HANDS = 48788;
local DIVINE_INTERVENTION = 19752;
local DIVINE_SACRIFICE = 64205;
local LAST_STAND = 12975;
local SHIELD_WALL = 871;
local PAIN_SUPPRESSION = 33206;
local GUARDIAN_SPIRIT = 47788;
local INNERVATE = 29166;
local HYSTERIA = 49016;
local REBIRTH = 48477;
local ICEBOUND_FORTITUDE = 48792;
local VAMPIRIC_BLOOD = 55233;
local UNBREAKABLE_ARMOR = 51271;
local ARDENT_DEFENDER = 66233;
local HAND_OF_SALVATION = 1038;
local AURA_MASTERY = 31821;
local HAND_OF_PROTECTION = 10278;
local MISDIRECTION = 34477;
local TRICKOFTRADE = 57934;
local CLOAK_OF_SHADOWS = 31224;
local ICE_BLOCK = 45438;
local FEIGN_DEATH = 5384;
local DETERRENCE = 19263;
local ANTIMAGIC_SHELL = 48707;
local DIVINE_PLEA = 54428;

-- Taunts
local HAND_OF_RECKONING = 62124;
local GROWL = 6795;
local TAUNT = 355;
local DARK_COMMAND = 56222;
local RIGHTEOUS_DEFENSE = 31789;
local DISTRACTING_SHOT = 20736;

-- Interrupts
local KICK = 1766;
local THROWING_SPECIALIZATION = 51680;
local HAMMER_OF_JUSTICE = 10308;
local SHIELD_BASH = 72;
local WIND_SHEAR = 57994;
local COUNTERSPELL = 2139;
local MIND_FREEZE = 47528;
local INTERRUPT = 32747; -- Druid's Maim
local FERAL_CHARGE = 19675;
local PUMMEL = 6552;
local ARCANE_TORRENT_MANA = 28730;
local ARCANE_TORRENT_ENERGY = 25046;
local ARCANE_TORRENT_RUNIC_POWER = 50613;
local AVENGERS_SHIELD = 48827;
local HOLY_WRATH = 48817;

--------------- Templates ---------------

CU_Template_All = {
 [CU_SPELLS_CREATIONS] = {
  [TOY_TRAIN_SET] = true,
 },
 [CU_SPELLS_FEAST] = {
  [GREAT_FEAST] = true,
  [FISH_FEAST] = true,
  [BOUNTIFUL_FEAST] = true,
 },
 [CU_SPELLS_AURA_GAINED] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
  [ARDENT_DEFENDER] = true,
  [DIVINE_PLEA] = true,
 },
 [CU_SPELLS_AURA_LOST] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
  [DIVINE_PLEA] = true,
 },
 [CU_SPELLS_INTERRUPTED] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_INTERRUPT_USED_SUCCESS] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_INTERRUPT_USED_FAILED] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_TAUNTED] = {
  [HAND_OF_RECKONING] = true,
  [GROWL] = true,
  [TAUNT] = true,
  [DARK_COMMAND] = true,
  [RIGHTEOUS_DEFENSE] = true,
 },
 [CU_SPELLS_TAUNT_MISSED] = {
  [HAND_OF_RECKONING] = true,
  [GROWL] = true,
  [TAUNT] = true,
  [DARK_COMMAND] = true,
  [RIGHTEOUS_DEFENSE] = true,
 },
 [CU_SPELLS_COOLDOWN_USED] = {
  [LAY_ON_HANDS] = true,
  [DIVINE_INTERVENTION] = true,
  [DIVINE_SACRIFICE] = true,
  [INNERVATE] = true,
  [HYSTERIA] = true,
  [REBIRTH] = true,
  [HAND_OF_SALVATION] = true,
  [AURA_MASTERY] = true,
  [HAND_OF_PROTECTION] = true,
  [MISDIRECTION] = true,
  [TRICKOFTRADE] = true,
  [CLOAK_OF_SHADOWS] = true,
  [ICE_BLOCK] = true,
  [FEIGN_DEATH] = true,
  [DETERRENCE] = true,
  [ANTIMAGIC_SHELL] = true,
 },
 [CU_SPELLS_RESURRECT] = {
  [REBIRTH] = true,
 },
};

CU_Template_Tank = {
 [CU_SPELLS_CREATIONS] = {
 },
 [CU_SPELLS_FEAST] = {
 },
 [CU_SPELLS_AURA_GAINED] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
  [ARDENT_DEFENDER] = true,
 },
 [CU_SPELLS_AURA_LOST] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
 },
 [CU_SPELLS_INTERRUPTED] = {
 },
 [CU_SPELLS_INTERRUPT_USED_SUCCESS] = {
 },
 [CU_SPELLS_INTERRUPT_USED_FAILED] = {
 },
 [CU_SPELLS_TAUNTED] = {
  [HAND_OF_RECKONING] = true,
  [GROWL] = true,
  [TAUNT] = true,
  [DARK_COMMAND] = true,
  [RIGHTEOUS_DEFENSE] = true,
 },
 [CU_SPELLS_TAUNT_MISSED] = {
  [HAND_OF_RECKONING] = true,
  [GROWL] = true,
  [TAUNT] = true,
  [DARK_COMMAND] = true,
  [RIGHTEOUS_DEFENSE] = true,
 },
 [CU_SPELLS_COOLDOWN_USED] = {
  [MISDIRECTION] = true,
  [TRICKOFTRADE] = true,
 },
 [CU_SPELLS_RESURRECT] = {
 },
};

CU_Template_Heal = {
 [CU_SPELLS_CREATIONS] = {
 },
 [CU_SPELLS_FEAST] = {
 },
 [CU_SPELLS_AURA_GAINED] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
  [ARDENT_DEFENDER] = true,
  [DIVINE_PLEA] = true,
 },
 [CU_SPELLS_AURA_LOST] = {
  [DIVINE_PROTECTION] = true,
  [LAST_STAND] = true,
  [SHIELD_WALL] = true,
  [HAND_OF_SACRIFICE] = true,
  [PAIN_SUPPRESSION] = true,
  [GUARDIAN_SPIRIT] = true,
  [ICEBOUND_FORTITUDE] = true,
  [VAMPIRIC_BLOOD] = true,
  [UNBREAKABLE_ARMOR] = true,
  [DIVINE_PLEA] = true,
 },
 [CU_SPELLS_INTERRUPTED] = {
 },
 [CU_SPELLS_INTERRUPT_USED_SUCCESS] = {
 },
 [CU_SPELLS_INTERRUPT_USED_FAILED] = {
 },
 [CU_SPELLS_TAUNTED] = {
 },
 [CU_SPELLS_TAUNT_MISSED] = {
 },
 [CU_SPELLS_COOLDOWN_USED] = {
  [LAY_ON_HANDS] = true,
  [DIVINE_INTERVENTION] = true,
  [DIVINE_SACRIFICE] = true,
  [INNERVATE] = true,
  [REBIRTH] = true,
  [AURA_MASTERY] = true,
  [ANTIMAGIC_SHELL] = true,
 },
 [CU_SPELLS_RESURRECT] = {
  [REBIRTH] = true,
 },
};

CU_Template_Kicker = {
 [CU_SPELLS_CREATIONS] = {
 },
 [CU_SPELLS_FEAST] = {
 },
 [CU_SPELLS_AURA_GAINED] = {
 },
 [CU_SPELLS_AURA_LOST] = {
 },
 [CU_SPELLS_INTERRUPTED] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_INTERRUPT_USED_SUCCESS] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_INTERRUPT_USED_FAILED] = {
  [KICK] = true,
  [THROWING_SPECIALIZATION] = true,
  [HAMMER_OF_JUSTICE] = true,
  [SHIELD_BASH] = true,
  [WIND_SHEAR] = true,
  [COUNTERSPELL] = true,
  [MIND_FREEZE] = true,
  [INTERRUPT] = true,
  [FERAL_CHARGE] = true,
  [PUMMEL] = true,
  [ARCANE_TORRENT_MANA] = true,
  [ARCANE_TORRENT_ENERGY] = true,
  [ARCANE_TORRENT_RUNIC_POWER] = true,
  [AVENGERS_SHIELD] = true,
  [HOLY_WRATH] = true,
 },
 [CU_SPELLS_TAUNTED] = {
 },
 [CU_SPELLS_TAUNT_MISSED] = {
 },
 [CU_SPELLS_COOLDOWN_USED] = {
 },
 [CU_SPELLS_RESURRECT] = {
 },
};

