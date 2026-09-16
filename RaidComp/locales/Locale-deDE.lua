local L = LibStub("AceLocale-3.0"):NewLocale("RaidComp", "deDE")

if L then

-- Core.lua
-- =================================
-- No translations


-- Support.lua
-- =================================
L["FAKE"] = "Fake"
L["HYBRID"] = "Hybrid"
L["UNKNOWN"] = "Unbekannt"

L["time_weeks"] = "Wochen"
L["time_days"] = "Tage"
L["time_hours"] = "Stunden"
L["time_minutes"] = "Minuten"
L["time_seconds"] = "Sekunden"

-- Classes, not used in Support.lua direct, but seemed like a good place
L["DEATHKNIGHT"] = "Todesritter"
L["DRUID"] = "Druide"
L["HUNTER"] = "Jäger"
L["MAGE"] = "Magier"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priester"
L["ROGUE"] = "Schurke"
L["SHAMAN"] = "Schamane"
L["WARLOCK"] = "Hexenmeister"
L["WARRIOR"] = "Krieger"

-- Talent Trees, used in addon:GetSpecName(engClass, specId)
L["DEATHKNIGHT1"] = "Blut"
L["DEATHKNIGHT2"] = "Frost"
L["DEATHKNIGHT3"] = "Unheilig"
L["DRUID1"] = "Gleichgewicht"
L["DRUID2"] = "Wilder Kampf"
L["DRUID3"] = "Wiederherstellung"
L["HUNTER1"] = "Tierherrschaft"
L["HUNTER2"] = "Treffsicherheit"
L["HUNTER3"] = "Überleben"
L["MAGE1"] = "Arkan"
L["MAGE2"] = "Feuer"
L["MAGE3"] = "Frost"
L["PALADIN1"] = "Heilig"
L["PALADIN2"] = "Schutz"
L["PALADIN3"] = "Vergeltung"
L["PRIEST1"] = "Disziplin"
L["PRIEST2"] = "Heilig"
L["PRIEST3"] = "Schatten"
L["ROGUE1"] = "Meucheln"
L["ROGUE2"] = "Kampf"
L["ROGUE3"] = "Täuschung"
L["SHAMAN1"] = "Elementar"
L["SHAMAN2"] = "Verstärkung"
L["SHAMAN3"] = "Wiederherstellung"
L["WARLOCK1"] = "Gebrechen"
L["WARLOCK2"] = "Dämonologie"
L["WARLOCK3"] = "Zerstörung"
L["WARRIOR1"] = "Waffen"
L["WARRIOR2"] = "Furor"
L["WARRIOR3"] = "Schutz"


-- Options.lua
-- =================================
L["menu_version_name"] = "version %s"
L["menu_options_name"] = "Optionen"
L["menu_options_desc"] = "Optionen für RaidComp einstellen."
L["menu_gui_name"] = "GUI öffnen"
L["menu_gui_desc"] = "Die graphische Benutzeroberfläche öffnen."
L["menu_purgeobsolete_name"] = "veraltete Einträge löschen"
L["menu_purgeobsolete_desc"] = "Löscht Einträge die älter als 90 Tage sind aus der internen Datenbank."
L["menu_purgeobsolete_confirm"] = "Sind Sie sicher, dass Sie alle Einträge die mindestens 90 Tage nicht aktualisiert wurden, aus der internen Datenbank löschen wollen?"
L["menu_purgerescan_name"] = "Datenbank löschen & Rescan"
L["menu_purgerescan_desc"] = "Löscht alle Einträge aus internen und externen Talentdatenbanken und löst einen Rescan aus."
L["menu_purgerescan_confirm"] = "Sind Sie sicher, dass Sie die internen und externen Datenbanken löschen und aus dem aktuellen Schlachtzug neu befüllen möchten?"
L["menu_debug_name"] = "Debug Modus"
L["menu_debug_desc"] = "Zeigt Nachrichten die bei der Fehlersuche behilflich sind."


-- RaidCheck.lua
-- ==============================
L["format_purgeobsolete"] = "Alte Einträge aus der RaidComp Datenbank gelöscht: %s Einträge entfernt."
L["purge_and_rescan"] = "RaidComp Datenbank gelöscht: Alle Einträge entfernt, starte Rescan."


-- Const_Categories.lua
-- =================================
L["Physical"] = "Physisch"
L["+Attack Power"] = "+Angriffskraft"
L["+10% AP"] = "+10% AP"
L["+Agi & Str"] = "+Bew & St"
L["+5% Melee Crit"] = "+5% kritische Nahkampftrefferchance"
L["+20% Melee Haste"] = "+20% Angriffstempo"
L["-20% Armor"] = "-20% Rüstung"
L["-5% Armor"] = "-5% Rüstung"
L["+4% Phys. Dam."] = "+4% phys. Schaden"
L["+Bleed Damage"] = "+Blutungsschaden"

L["Magical"] = "Magisch"
L["+Spell Power"] = "+Zaubermacht"
L["+5% Crit (buff)"] = "+5% kritische Zaubertrefferchance (buff)"
L["+5% Spell Haste"] = "+5% Zaubertempo"
L["+Intellect"] = "+Intelligenz"
L["+Spirit"] = "+Willenskraft"
L["+Mana Regen"] = "+Mana Regeneration"
L["+13% Spell Dam."] = "+13% Zauber Schaden"
L["+5% Crit (debuff)"] = "+5% kritische Zaubertrefferchance (debuff)"
L["+3% Spell Hit"] = "+3% Zaubertrefferchance"
L["+30% Disease Dam."] = "+30% erhöhter Schaden durch Krankheiten"

L["Survival"] = "Überleben"
L["+Health"] = "+Gesundheit"
L["+Stamina"] = "+Ausdauer"
L["+6% Healing"] = "+6% Heilung"
L["+Armor Aura"] = "+Rüstungsaura"
L["+Armor Totem"] = "+Rüstungstotem"
L["+25% Armor Proc"] = "+25% Rüstungs Proc"
L["-3% Dam. Taken"] = "-3% erlittener Schaden"
L["Healthstone"] = "Gesundheitsstein"
L["-3% Hit Taken"] = "-3% Chance getroffen zu werden"
L["-Attack Power"] = "-Angriffskraft"
L["-Attack Speed"] = "-Angriffsgeschwindigkeit"

L["Multi Purpose"] = "Universell"
L["Heroism/Bloodlust"] = "Heldentum/Kampfrausch"
L["Heroism/BloodlustAlliance"] = "Heldentum"
L["Heroism/BloodlustHorde"] = "Kampfrausch"
L["+All Stats"] = "+Alle Werte"
L["+10% All Stats"] = "+10% Alle Werte"
L["+3% Damage"] = "+3% Schaden"
L["+3% Haste"] = "+3% Tempo"
L["+3% Crit"] = "+3% Crit"

L["Situational"] = "Situationsbedingt"
L["Shadow Res."] = "Schattenwiderstand"
L["Fire Res."] = "Feuerwiderstand"
L["Frost Res."] = "Frostwiderstand"
L["Nature Res."] = "Naturwiderstand"
L["-Healing Received"] = "-erhaltene Heilung"
L["-Cast Speed"] = "-Zaubertempo"

L["Count"] = "Anzahl"
L["Replenishment"] = "Erfrischung"
L["Remove Magic"] = "Magie entfernen"
L["Remove Poison"] = "Gift entfernen"
L["Remove Curse"] = "Fluch aufheben"
L["Remove Disease"] = "Krankheit heilen"
L["Reduce Damage"] = "Schadensminderung"
L["Power Restore"] = "Energie wiederherstellen"
L["Interrupt"] = "Unterbrechung"
L["Purge"] = "Reinigen"
L["Remove Enrage"] = "Wuteffekt entfernen"
L["Remove Protection"] = "Schutzeffekt entfernen"

L["Crowd Control"] = "Crowd Control"
L["CC - Humanoid"] = "CC - Humanoid"
L["CC - Beast"] = "CC - Wildtier"
L["CC - Dragonkin"] = "CC - Drache"
L["CC - Giant"] = "CC - Riese"
L["CC - Elemental"] = "CC - Elementar"
L["CC - Demon"] = "CC - Dämon"
L["CC - Undead"] = "CC - Untot"


-- Const_Presets.lua
-- =================================
-- Death Knight
L["Blood DPS"] = "Blut DPS"
L["Blood Tank"] = "Blut Tank"
L["Frost DPS"] = "Frost DPS"
L["Frost Tank"] = "Frost Tank"
L["Unholy DPS"] = "Unheilig DPS"
L["Unholy Tank"] = "Unheilig Tank"
-- Druid
L["Balance"] = "Gleichgewicht"
L["Feral DPS"] = "Wilder Kampf DPS"
L["Feral Tank"] = "Wilder Kampf Tank"
L["Restoration"] = "Wiederherstellung"
-- Hunter
L["Beast Mastery"] = "Tierherrschaft"
L["Marksmanship"] = "Treffsicherheit"
L["Survival"] = "Überleben"
-- Mage
L["Arcane"] = "Arkan"
L["Fire"] = "Feuer"
L["Frost"] = "Frost"
-- Paladin
L["Holy"] = "Heilig"
L["Protection"] = "Schutz"
L["Retribution"] = "Vergeltung"
-- Priest
L["Discipline"] = "Disziplin"
L["Holy"] = "Heilig"
L["Shadow"] = "Schatten"
-- Rogue
L["Assassination"] = "Meucheln"
L["Combat"] = "Kampf"
L["Subtlety"] = "Täuschung"
-- Shaman
L["Elemental"] = "Elementar"
L["Enhancement"] = "Verstärkung"
L["Restoration"] = "Wiederherstellung"
-- Warlock
L["Affliction"] = "Gebrechen"
L["Demonology"] = "Dämonologie"
L["Demo-Destro"] = "Dämo-Zerstörung"
L["Destruction"] = "Zerstörung"
-- Warrior
L["Arms"] = "Waffen"
L["Fury"] = "Furor"
L["Protection"] = "Schutz"


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
L["shortInvited"] = "|cffffff00".."E"..FONT_COLOR_CODE_CLOSE
L["shortAccepted"] = "|cff00ff00".."An"..FONT_COLOR_CODE_CLOSE
L["shortDeclined"] = "|cffff0000".."Ab"..FONT_COLOR_CODE_CLOSE
L["shortConfirmed"] = "|cff00ff00".."B"..FONT_COLOR_CODE_CLOSE
L["shortOut"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE
L["shortStandby"] = "|cffff8000".."S"..FONT_COLOR_CODE_CLOSE
L["shortSignedUp"] = "|cffffff00".."A"..FONT_COLOR_CODE_CLOSE
L["shortNotSignedUp"] = "|cffff0000".."nA"..FONT_COLOR_CODE_CLOSE
L["shortTentative"] = "|cffff8000".."V"..FONT_COLOR_CODE_CLOSE

L["longInvited"] = "|cffffff00".."E"..FONT_COLOR_CODE_CLOSE.."ingeladen"
L["longAccepted"] = "|cff00ff00".."An"..FONT_COLOR_CODE_CLOSE.."genommen"
L["longDeclined"] = "|cffff0000".."Ab"..FONT_COLOR_CODE_CLOSE.."gelehnt"
L["longConfirmed"] = "|cff00ff00".."B"..FONT_COLOR_CODE_CLOSE.."estätigt"
L["longOut"] = "|cffff0000".."N"..FONT_COLOR_CODE_CLOSE.."icht dabei"
L["longStandby"] = "|cffff8000".."S"..FONT_COLOR_CODE_CLOSE.."tandby"
L["longSignedUp"] = "|cffffff00".."A"..FONT_COLOR_CODE_CLOSE.."ngemeldet"
L["longNotSignedUp"] = "|cffff0000".."n"..FONT_COLOR_CODE_CLOSE.."icht ".."|cffff0000".."A"..FONT_COLOR_CODE_CLOSE.."ngemeldet"
L["longTentative"] = "|cffff8000".."V"..FONT_COLOR_CODE_CLOSE.."orläufig"

L["status_viewingraid"] = "zeige momentanen Schlachtzug"
L["format_status_event"] = "zeige Kalendereintrag vom %s (%s) at %s"
L["format_status_announcement"] = "Gildenankündigung (%s) ausgewählt"
L["format_status_system"] = "Kalendereintrag (%s) ausgewählt"
L["status_noevent"] = "kein Kalendereintrag ausgewählt"

L["format_createdby"] = "Created by %s"


-- GUI_Events.lua
-- =================================
L["tooltip_shift+click"] = "shift+click"
L["tooltip_ctrl+click"] = "strg+click"
L["tooltip_alt+click"] = "alt+click"
L["tooltip_removefake"] = "fake entfernen"
L["tooltip_unignore"] = "nicht mehr ignorieren"
L["tooltip_ignore"] = "ignorieren"
L["tooltip_override"] = "override"
L["tooltip_altoverride"] = "alt spec override"
L["tooltip_clearoverride"] = "clear override"
L["tooltip_temporary"] = "temporäre Daten setzen"
L["tooltip_cleartemporary"] = "temporäre Daten löschen"

L["format_timetooltip"] = "(letztes Update vor %s)"

L["format_providedby"] = "beigesteuert durch %s"
L["format_providedbytalent"] = "beigesteuert durch %s (Talent)"

L["tooltip_petability"] = "(Begleiter Fertigkeit)"

L["format_report_sourcesof"] = "RaidComp Report - Quellen von %s"
L["format_report_specs"] = "RaidComp Report - %s"
L["format_report_spell"] = "* %s (%s) - %s"
L["format_report_petability"] = "* %s (%s (Begleiter)) - %s"
L["format_report_spec"] = "* %s - %s"
L["report_none"] = "None"

L["pet_worm"] = "Wurm"
L["pet_wasp"] = "Wespen"
L["pet_corehound"] = "Kernhund"
L["pet_carrionbird"] = "Vogel"
L["pet_rhino"] = "Rhino"
L["pet_imp"] = "Wichtel"
L["pet_felhunter"] = "Teufelsjäger"

L["tooltip_addasfake"] = "als fake hinzugefügt"
L["tooltip_addaltasfake"] = "zweite Talentspezialisierung als fake hinzufügen"


-- GUI.lua
-- =================================
L["button_close"] = "Schliessen"
L["button_help"] = "Hilfe"

L["caption_selection"] = "Spieler Auswahl"
L["button_raidmode"] = "Schlachtzug betrachten"
L["button_calendarmode"] = "Kalender betrachten"
L["format_clearignores"] = "Ignores löschen (%s)"
L["format_clearoverrides"] = "Overrides löschen (%s)"
L["format_clearfakes"] = "Fakes löschen (%s)"
L["format_checkboxgroup"] = "Schlachtzug %s"

L["format_raidmembers"] = "Schlachtzug Teilnehmer (%s/%s)"
L["caption_playername"] = "Name"
L["caption_class"] = "(Klasse)"
L["caption_subgroup"] = "  #"
L["caption_status"] = "@"
L["caption_mainspec"] = "aktive Talentspezialisierung"
L["caption_altspec"] = "alternative Talentspezialisierung"
L["caption_update"] = "letztes Update"
L["button_addfake"] = "Fake"
L["button_pets"] = "Begleiter"
L["button_database"] = "Datenbank"

L["caption_buffs"] = "Stärkungs- / Schwächungszauber"

L["caption_talentscans"] = "Talent Scans"
L["Tanks"] = "Tanks"
L["Melee DPS"] = "Nahkampf DPS"
L["Ranged DPS"] = "Fernkampf DPS"
L["Healers"] = "Heiler"
L["format_timedifference"] = "letztes Update vor: %s"
L["format_scanspending"] = "laufende Scans: %s von %s"
L["format_dbentries"] = "Scans in Datenbank: %s"

L["caption_database"] = "RaidComp Datenbank"
L["caption_databaserecords"] = "Datenbank Einträge"
L["format_timeold"] = "vor %s"
L["format_status_database"] = "%s Spielereinträge in der Datenbank"


-- GUI_Support.lua   HELP TOOLTIP
-- ==============================
L["help1"] = "Dieses Fenster enthält eine kurze Übersicht verwendeter Icons/Abkürzungen."
L["help2"] = "Für eine ausführlichere Hilfe besuchen Sie bitte 'wow.curseforge.com/addons/arc/'"

L["help3"] = "Icons um Kategorien zu identifizieren:"
L["help_buff"] = "Zauber in dieser Kategorie  sind Stärkungszauber."
L["help_debuff"] = "Zauber in dieser Kategorie  sind Schwächungszauber."
L["help_dot"] = "Dies ist eine 'Anzahl'-kategorie."

L["help4"] = "Icons welche die Verfügbarkeit eines Stärkungs-/Schwächungszaubers anzeigen:"
L["help_check"] = "Stärkungs-/Schwächungszauber ist im Schlachtzug verfügbar."
L["help_nonoptimal"] = "Art des Stärkungs-/Schwächungszaubers ist im Schlachtzug verfügbar, aber nicht in der stärksten Form."
L["help_nonoptimal_ex1"] = "Beispiel: Horn des Winters gewährt weniger Bew+St"
L["help_nonoptimal_ex2"] = "          als ein verbessertes Erdstärke Totem."
L["help_maybe"] = "Stärkungszauber bedingt verfügbar."
L["help_maybe_ex1"] = "Beispiel: Ein einziger Schamane kann nicht gleichzeitig Totem des Windzorns"
L["help_maybe_ex2"] = "          und Totem des stürmischen Zorns bereit stellen."
L["help_cross"] = "Stärkungs-/Schwächungszauber ist nicht verfügbar."

L["help5"] = "Codes die den Status eines Spielers anzeigen:"
L["help_ignore"] = "Dieser Spieler wird in der Auswertung nicht berücksichtigt."
L["help_override"] = "Von Ihnen angegebene Daten überschreiben bereits vorhandene."
L["help_ok"] = "Die Talente dieses Spielers wurden innerhalb der letzten 15 Minuten gescannt."
L["help_stored"] = "Die Talente dieses Spielers wurden das letzte mal vor mehr als 15 Minuten gescannt."
L["help_temporary"] = "Daten welche verwendet werden sollen bis der Spieler gescannt wurde."
L["help_missing"] = "Für diesen Spieler sind keine Talentdaten verfügbar."
L["help_fake"] = "Dieser Spieler wurde per als 'Fake' hinzugefügt."

end
