local L = LibStub("AceLocale-3.0"):NewLocale("RaidComp", "enUS", true)

if L then

-- Core.lua
-- =================================
-- No translations


-- Support.lua
-- =================================
L["FAKE"] = "Fake"
L["HYBRID"] = "Hybrid"
L["UNKNOWN"] = "Unknown"

L["time_weeks"] = "wks"
L["time_days"] = "days"
L["time_hours"] = "hrs"
L["time_minutes"] = "mins"
L["time_seconds"] = "secs"

-- Classes, not used in Support.lua direct, but seemed like a good place
L["DEATHKNIGHT"] = "Death Knight"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"

-- Talent Trees, used in addon:GetSpecName(engClass, specId)
L["DEATHKNIGHT1"] = "Blood"
L["DEATHKNIGHT2"] = "Frost"
L["DEATHKNIGHT3"] = "Unholy"
L["DRUID1"] = "Balance"
L["DRUID2"] = "Feral Combat"
L["DRUID3"] = "Restoration"
L["HUNTER1"] = "Beast Mastery"
L["HUNTER2"] = "Marksmanship"
L["HUNTER3"] = "Survival"
L["MAGE1"] = "Arcane"
L["MAGE2"] = "Fire"
L["MAGE3"] = "Frost"
L["PALADIN1"] = "Holy"
L["PALADIN2"] = "Protection"
L["PALADIN3"] = "Retribution"
L["PRIEST1"] = "Discipline"
L["PRIEST2"] = "Holy"
L["PRIEST3"] = "Shadow"
L["ROGUE1"] = "Assassination"
L["ROGUE2"] = "Combat"
L["ROGUE3"] = "Subtlety"
L["SHAMAN1"] = "Elemental"
L["SHAMAN2"] = "Enhancement"
L["SHAMAN3"] = "Restoration"
L["WARLOCK1"] = "Affliction"
L["WARLOCK2"] = "Demonology"
L["WARLOCK3"] = "Destruction"
L["WARRIOR1"] = "Arms"
L["WARRIOR2"] = "Fury"
L["WARRIOR3"] = "Protection"


-- Options.lua
-- =================================
L["menu_version_name"] = "version %s"
L["menu_options_name"] = "Options"
L["menu_options_desc"] = "Configure options for RaidComp."
L["menu_gui_name"] = "Open GUI"
L["menu_gui_desc"] = "Open the Graphical User Interface."
L["menu_purgeobsolete_name"] = "Purge Obsolete Records"
L["menu_purgeobsolete_desc"] = "Purges records that are more than 90 days old from the internal database."
L["menu_purgeobsolete_confirm"] = "Are you sure you want to remove all records that have not been updated for 90 days from the database?"
L["menu_purgerescan_name"] = "Purge Database & Rescan"
L["menu_purgerescan_desc"] = "Purges all records from the internal and external talent databases and orders a rescan."
L["menu_purgerescan_confirm"] = "Are you sure you want to wipe the internal and external databases and rescan the current raid?"
L["menu_debug_name"] = "Debug mode"
L["menu_debug_desc"] = "If enabled, debug-messages will be printed to assist with debugging."


-- RaidCheck.lua
-- ==============================
L["format_purgeobsolete"] = "RaidComp Database Purge complete: %s records removed."
L["purge_and_rescan"] = "RaidComp Database Purge complete: All records removed, beginning rescan."


-- Const_Categories.lua
-- =================================
L["Physical"] = "Physical"
L["+Attack Power"] = "+Attack Power"
L["+10% AP"] = "+10% AP"
L["+Agi & Str"] = "+Agi & Str"
L["+5% Melee Crit"] = "+5% Melee Crit"
L["+20% Melee Haste"] = "+20% Haste"
L["-20% Armor"] = "-20% Armor"
L["-5% Armor"] = "-5% Armor"
L["+4% Phys. Dam."] = "+4% Phys. Dam."
L["+Bleed Damage"] = "+Bleed Damage"

L["Magical"] = "Magical"
L["+Spell Power"] = "+Spell Power"
L["+5% Crit (buff)"] = "+5% Crit (buff)"
L["+5% Spell Haste"] = "+5% Spell Haste"
L["+Intellect"] = "+Intellect"
L["+Spirit"] = "+Spirit"
L["+Mana Regen"] = "+Mana Regen"
L["+13% Spell Dam."] = "+13% Spell Dam."
L["+5% Crit (debuff)"] = "+5% Crit (debuff)"
L["+3% Spell Hit"] = "+3% Spell Hit"
L["+30% Disease Dam."] = "+30% Disease Dam."

L["Survival"] = "Survival"
L["+Health"] = "+Health"
L["+Stamina"] = "+Stamina"
L["+6% Healing"] = "+6% Healing"
L["+Armor Aura"] = "+Armor Aura"
L["+Armor Totem"] = "+Armor Totem"
L["+25% Armor Proc"] = "+25% Armor Proc"
L["-3% Dam. Taken"] = "-3% Dam. Taken"
L["Healthstone"] = "Healthstone"
L["-3% Hit Taken"] = "-3% Hit Taken"
L["-Attack Power"] = "-Attack Power"
L["-Attack Speed"] = "-Attack Speed"

L["Multi Purpose"] = "Multi Purpose"
L["Heroism/Bloodlust"] = "Heroism/Bloodlust"
L["Heroism/BloodlustAlliance"] = "Heroism"
L["Heroism/BloodlustHorde"] = "Bloodlust"
L["+All Stats"] = "+All Stats"
L["+10% All Stats"] = "+10% All Stats"
L["+3% Damage"] = "+3% Damage"
L["+3% Haste"] = "+3% Haste"
L["+3% Crit"] = "+3% Crit"

L["Situational"] = "Situational"
L["Shadow Res."] = "Shadow Res."
L["Fire Res."] = "Fire Res."
L["Frost Res."] = "Frost Res."
L["Nature Res."] = "Nature Res."
L["-Healing Received"] = "-Healing Received"
L["-Cast Speed"] = "-Cast Speed"

L["Count"] = "Count"
L["Replenishment"] = "Replenishment"
L["Remove Magic"] = "Remove Magic"
L["Remove Poison"] = "Remove Poison"
L["Remove Curse"] = "Remove Curse"
L["Remove Disease"] = "Remove Disease"
L["Reduce Damage"] = "Reduce Damage"
L["Power Restore"] = "Power Restore"
L["Interrupt"] = "Interrupt"
L["Purge"] = "Purge"
L["Remove Enrage"] = "Remove Enrage"
L["Remove Protection"] = "Remove Protection"

L["Crowd Control"] = "Crowd Control"
L["CC - Humanoid"] = "CC - Humanoid"
L["CC - Beast"] = "CC - Beast"
L["CC - Dragonkin"] = "CC - Dragonkin"
L["CC - Giant"] = "CC - Giant"
L["CC - Elemental"] = "CC - Elemental"
L["CC - Demon"] = "CC - Demon"
L["CC - Undead"] = "CC - Undead"


-- Const_Presets.lua
-- =================================
-- Death Knight
L["Blood DPS"] = "Blood DPS"
L["Blood Tank"] = "Blood Tank"
L["Frost DPS"] = "Frost DPS"
L["Frost Tank"] = "Frost Tank"
L["Unholy DPS"] = "Unholy DPS"
L["Unholy Tank"] = "Unholy Tank"
-- Druid
L["Balance"] = "Balance"
L["Feral DPS"] = "Feral DPS"
L["Feral Tank"] = "Feral Tank"
L["Restoration"] = "Restoration"
-- Hunter
L["Beast Mastery"] = "Beast Mastery"
L["Marksmanship"] = "Marksmanship"
L["Survival"] = "Survival"
-- Mage
L["Arcane"] = "Arcane"
L["Fire"] = "Fire"
L["Frost"] = "Frost"
-- Paladin
L["Holy"] = "Holy"
L["Protection"] = "Protection"
L["Retribution"] = "Retribution"
-- Priest
L["Discipline"] = "Discipline"
L["Holy"] = "Holy"
L["Shadow"] = "Shadow"
-- Rogue
L["Assassination"] = "Assassination"
L["Combat"] = "Combat"
L["Subtlety"] = "Subtlety"
-- Shaman
L["Elemental"] = "Elemental"
L["Enhancement"] = "Enhancement"
L["Restoration"] = "Restoration"
-- Warlock
L["Affliction"] = "Affliction"
L["Demonology"] = "Demonology"
L["Demo-Destro"] = "Demo-Destro"
L["Destruction"] = "Destruction"
-- Warrior
L["Arms"] = "Arms"
L["Fury"] = "Fury"
L["Protection"] = "Protection"


-- Player_Fakes.lua
-- =================================
L["format_fakename"] = "FAKE %s"


-- GUI_Support.lua
-- =================================
L["shortI"] = "|cffff8000".."I"..FONT_COLOR_CODE_CLOSE
L["shortO"] = "|cffffff00".."O"..FONT_COLOR_CODE_CLOSE
L["shortK"] = "|cff00ff00".."K"..FONT_COLOR_CODE_CLOSE
L["shortS"] = "|cff0080ff".."S"..FONT_COLOR_CODE_CLOSE
L["shortT"] = "|cffffff80".."T"..FONT_COLOR_CODE_CLOSE
L["shortM"] = "|cffff0000".."M"..FONT_COLOR_CODE_CLOSE
L["shortF"] = "|cffff00ff".."F"..FONT_COLOR_CODE_CLOSE

L["longI"] = "|cffff8000".."I"..FONT_COLOR_CODE_CLOSE.."gnored"
L["longO"] = "|cffffff00".."O"..FONT_COLOR_CODE_CLOSE.."verride"
L["longK"] = "O".."|cff00ff00".."K"..FONT_COLOR_CODE_CLOSE
L["longS"] = "|cff0080ff".."S"..FONT_COLOR_CODE_CLOSE.."tored"
L["longT"] = "|cffffff80".."T"..FONT_COLOR_CODE_CLOSE.."emporary"
L["longM"] = "|cffff0000".."M"..FONT_COLOR_CODE_CLOSE.."issing"
L["longF"] = "|cffff00ff".."F"..FONT_COLOR_CODE_CLOSE.."ake"


-- Calendar.lua
-- =================================
L["shortInvited"] = "|cffffff00".."I"..FONT_COLOR_CODE_CLOSE
L["shortAccepted"] = "|cff00ff00".."A"..FONT_COLOR_CODE_CLOSE
L["shortDeclined"] = "|cffff0000".."D"..FONT_COLOR_CODE_CLOSE
L["shortConfirmed"] = "|cff00ff00".."C"..FONT_COLOR_CODE_CLOSE
L["shortOut"] = "|cffff0000".."O"..FONT_COLOR_CODE_CLOSE
L["shortStandby"] = "|cffff8000".."B"..FONT_COLOR_CODE_CLOSE
L["shortSignedUp"] = "|cffffff00".."S"..FONT_COLOR_CODE_CLOSE
L["shortNotSignedUp"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE
L["shortTentative"] = "|cffff8000".."T"..FONT_COLOR_CODE_CLOSE

L["longInvited"] = "|cffffff00".."I"..FONT_COLOR_CODE_CLOSE.."nvited"
L["longAccepted"] = "|cff00ff00".."A"..FONT_COLOR_CODE_CLOSE.."ccepted"
L["longDeclined"] = "|cffff0000".."D"..FONT_COLOR_CODE_CLOSE.."eclined"
L["longConfirmed"] = "|cff00ff00".."C"..FONT_COLOR_CODE_CLOSE.."onfirmed"
L["longOut"] = "|cffff0000".."O"..FONT_COLOR_CODE_CLOSE.."ut"
L["longStandby"] = "Stand".."|cffff8000".."B"..FONT_COLOR_CODE_CLOSE.."y"
L["longSignedUp"] = "|cffffff00".."S"..FONT_COLOR_CODE_CLOSE.."igned Up"
L["longNotSignedUp"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE.."ot Signed Up"
L["longTentative"] = "|cffff8000".."T"..FONT_COLOR_CODE_CLOSE.."entative"

L["status_viewingraid"] = "Viewing current raid"
L["format_status_event"] = "Viewing calendar event on %s (%s) at %s"
L["format_status_announcement"] = "Guild Announcement (%s) selected"
L["format_status_system"] = "Calendar Event (%s) selected"
L["status_noevent"] = "No event selected in Calendar"

L["format_createdby"] = "Created by %s"


-- GUI_Events.lua
-- =================================
L["tooltip_shift+click"] = "shift+click"
L["tooltip_ctrl+click"] = "ctrl+click"
L["tooltip_alt+click"] = "alt+click"
L["tooltip_removefake"] = "remove fake"
L["tooltip_unignore"] = "unignore"
L["tooltip_ignore"] = "ignore"
L["tooltip_override"] = "override"
L["tooltip_altoverride"] = "alt spec override"
L["tooltip_clearoverride"] = "clear override"
L["tooltip_temporary"] = "set temporary data"
L["tooltip_cleartemporary"] = "clear temporary data"

L["format_timetooltip"] = "(updated %s ago)"

L["format_providedby"] = "Provided by %s"
L["format_providedbytalent"] = "Provided by %s (Talent)"

L["tooltip_petability"] = "(Pet Ability)"

L["format_report_sourcesof"] = "RaidComp Report - Sources of %s"
L["format_report_specs"] = "RaidComp Report - %s"
L["format_report_spell"] = "* %s (%s) - %s"
L["format_report_petability"] = "* %s (%s (Pet)) - %s"
L["format_report_spec"] = "* %s - %s"
L["report_none"] = "None"

L["pet_worm"] = "Worm"
L["pet_wasp"] = "Wasp"
L["pet_corehound"] = "Core Hound"
L["pet_carrionbird"] = "Carrion Bird"
L["pet_rhino"] = "Rhino"
L["pet_imp"] = "Imp"
L["pet_felhunter"] = "Felhunter"

L["tooltip_addasfake"] = "add as fake"
L["tooltip_addaltasfake"] = "add alt spec as fake"


-- GUI.lua
-- =================================
L["button_close"] = "Close"
L["button_help"] = "Help"

L["caption_selection"] = "Player Selection"
L["button_raidmode"] = "View Raid"
L["button_calendarmode"] = "View Calendar"
L["format_clearignores"] = "Clear Ignores (%s)"
L["format_clearoverrides"] = "Clear Overrides (%s)"
L["format_clearfakes"] = "Clear Fakes (%s)"
L["format_checkboxgroup"] = "Raid group %s"

L["format_raidmembers"] = "Raid Members (%s/%s)"
L["caption_playername"] = "Name"
L["caption_class"] = "(Class)"
L["caption_subgroup"] = "  #"
L["caption_status"] = "@"
L["caption_mainspec"] = "Current Spec"
L["caption_altspec"] = "Alt Spec"
L["caption_update"] = "Last update"
L["button_addfake"] = "Fake"
L["button_pets"] = "Pets"
L["button_database"] = "Database"

L["caption_buffs"] = "Buffs / Debuffs"

L["caption_talentscans"] = "Talent Scans"
L["Tanks"] = "Tanks"
L["Melee DPS"] = "Melee DPS"
L["Ranged DPS"] = "Ranged DPS"
L["Healers"] = "Healers"
L["format_timedifference"] = "Updated: %s ago"
L["format_scanspending"] = "Scans pending: %s of %s"
L["format_dbentries"] = "Scans in database: %s"

L["caption_database"] = "RaidComp Database"
L["caption_databaserecords"] = "Database records"
L["format_timeold"] = "%s ago"
L["format_status_database"] = "%s player records in database"


-- GUI_Support.lua   HELP TOOLTIP
-- ==============================
L["help1"] = "This frame contains a short overview of used icons/abbreviations."
L["help2"] = "For more detailed help visit 'wow.curseforge.com/addons/arc/'"

L["help3"] = "Icons to identify categories:"
L["help_buff"] = "Spells in this category are Buffs."
L["help_debuff"] = "Spells in this category are Debuffs."
L["help_dot"] = "This is a 'Count'-category."

L["help4"] = "Icons that represent presence of a (de)buff:"
L["help_check"] = "(De)buff is present in the raid."
L["help_nonoptimal"] = "(De)buff is present, but not the best in its category."
L["help_nonoptimal_ex1"] = "Example: Horn of Winter gives less agi+str"
L["help_nonoptimal_ex2"] = "    than a talented Strength of Earth Totem."
L["help_maybe"] = "Buff could be present, but it's mutually exclusive with another."
L["help_maybe_ex1"] = "Example: One Shaman can not use Windfury Totem and"
L["help_maybe_ex2"] = "    Wrath of Air Totem at the same time."
L["help_cross"] = "(De)buff is not in the raid."

L["help5"] = "Codes used to mark the status of a player:"
L["help_ignore"] = "In the calculation, this player will be skipped."
L["help_override"] = "Data you specified overrides stored data."
L["help_ok"] = "Player's talents have been scanned in the last 15 minutes."
L["help_stored"] = "Player's talent data is older than 15 minutes."
L["help_temporary"] = "Custom data to use until player is scanned."
L["help_missing"] = "No talent data about this player."
L["help_fake"] = "This player was added with 'Add Fake'."

end
