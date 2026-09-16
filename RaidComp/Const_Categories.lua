local addon = RaidComp

-- Occurences of " " in the arrays result in empty lines in the GUI
addon.CATEGORIES = {
    {   catName = "Physical",
        items = {
            "+Attack Power",
            "+10% AP",
            "+Agi & Str",
            "+5% Melee Crit",
            "+20% Melee Haste",
            " ",
            " ",
            " ",
            "-20% Armor",
            "-5% Armor",
            "+4% Phys. Dam.",
            "+Bleed Damage",
          },
      },
    {   catName = "Magical",
        items = {
            "+Spell Power",
            "+5% Crit (buff)",
            "+5% Spell Haste",
            "+Intellect",
            "+Spirit",
            "+Mana Regen",
            " ",
            " ",
            "+13% Spell Dam.",
            "+5% Crit (debuff)",
            "+3% Spell Hit",
            "+30% Disease Dam.",
          },
      },
    {   catName = "Survival",
        items = {
            "+Health",
            "+Stamina",
            "+6% Healing",
            "+Armor Aura",
            "+Armor Totem",
            "+25% Armor Proc",
            "-3% Dam. Taken",
            "Healthstone",
            " ",
            "-3% Hit Taken",
            "-Attack Power",
            "-Attack Speed",
          },
      },
    {   catName = "Count",
        items = {
            "Replenishment",
            "Remove Magic",
            "Remove Poison",
            "Remove Curse",
            "Remove Disease",
            "Reduce Damage",
            "Power Restore",
            " ",
            "Interrupt",
            "Purge",
            "Remove Enrage",
            "Remove Protection",
          },
      },
    {   catName = "Multi Purpose",
        items = {
            "Heroism/Bloodlust",
            "+All Stats",
            "+10% All Stats",
            "+3% Damage",
            "+3% Haste",
            " ",
            "+3% Crit",
          },
      },
    {   catName = "Situational",
        items = {
            "Shadow Res.",
            "Fire Res.",
            "Frost Res.",
            "Nature Res.",
            " ",
            "-Healing Received",
            "-Cast Speed",
          },
      }, 
    {   catName = "Crowd Control",
        items = {
            "CC - Humanoid",
            "CC - Beast",
            "CC - Dragonkin",
            "CC - Giant",
            "CC - Elemental",
            "CC - Demon",
            "CC - Undead",
          },
      },
  }
  
addon.SPECCATEGORIES = {
    "Tanks",
    "Melee DPS",
    "Ranged DPS",
    "Healers",
  }

addon.SPECICONS = {
    ["DEATHKNIGHT"] = "Interface\\Icons\\Spell_DeathKnight_ClassIcon.png",
    ["DRUID"] = "Interface\\Icons\\Ability_Druid_Maul.png",
    ["HUNTER"] = "Interface\\Icons\\INV_Weapon_Bow_07.png",
    ["MAGE"] = "Interface\\Icons\\INV_Staff_13.png",
    ["PALADIN"] = "Interface\\Icons\\INV_Hammer_01.png",
    ["PRIEST"] = "Interface\\Icons\\INV_Staff_30.png",
    ["ROGUE"] = "Interface\\Icons\\INV_ThrowingKnife_04.png",
    ["SHAMAN"] = "Interface\\Icons\\Spell_Nature_BloodLust.png",
    ["WARLOCK"] = "Interface\\Icons\\Spell_Nature_Drowsy.png",
    ["WARRIOR"] = "Interface\\Icons\\INV_Sword_27.png",
  }
  
addon.ITEMTYPE_EMPTY = 0
addon.ITEMTYPE_BUFF = 1
addon.ITEMTYPE_DEBUFF = 2
addon.ITEMTYPE_COUNT = 3

function addon:ItemType2Texture(itemType)
    if itemType == addon.ITEMTYPE_EMPTY then
        return nil
    elseif itemType == addon.ITEMTYPE_BUFF then
        return addon.IMAGEPATH.."buff"
    elseif itemType == addon.ITEMTYPE_DEBUFF then
        return addon.IMAGEPATH.."debuff"
    elseif itemType == addon.ITEMTYPE_COUNT then
        return addon.IMAGEPATH.."dot"
    else
        return nil
    end
end  

addon.ITEMTYPE = {
    [" "] = addon.ITEMTYPE_EMPTY,

    -- Physical
    ["+Attack Power"] = addon.ITEMTYPE_BUFF,
    ["+10% AP"] = addon.ITEMTYPE_BUFF,
    ["+Agi & Str"] = addon.ITEMTYPE_BUFF,
    ["+5% Melee Crit"] = addon.ITEMTYPE_BUFF,
    ["+20% Melee Haste"] = addon.ITEMTYPE_BUFF,

    ["-20% Armor"] = addon.ITEMTYPE_DEBUFF,
    ["-5% Armor"] = addon.ITEMTYPE_DEBUFF,
    ["+4% Phys. Dam."] = addon.ITEMTYPE_DEBUFF,
    ["+Bleed Damage"] = addon.ITEMTYPE_DEBUFF,

    -- Magical
    ["+Spell Power"] = addon.ITEMTYPE_BUFF,
    ["+5% Crit (buff)"] = addon.ITEMTYPE_BUFF,
    ["+5% Spell Haste"] = addon.ITEMTYPE_BUFF,
    ["+Intellect"] = addon.ITEMTYPE_BUFF,
    ["+Spirit"] = addon.ITEMTYPE_BUFF,
    ["+Mana Regen"] = addon.ITEMTYPE_BUFF,

    ["+13% Spell Dam."] = addon.ITEMTYPE_DEBUFF,
    ["+5% Crit (debuff)"] = addon.ITEMTYPE_DEBUFF,
    ["+3% Spell Hit"] = addon.ITEMTYPE_DEBUFF,
    ["+30% Disease Dam."] = addon.ITEMTYPE_DEBUFF,

    -- Survival
    ["+Health"] = addon.ITEMTYPE_BUFF,
    ["+Stamina"] = addon.ITEMTYPE_BUFF,
    ["+6% Healing"] = addon.ITEMTYPE_BUFF,
    ["+Armor Aura"] = addon.ITEMTYPE_BUFF,
    ["+Armor Totem"] = addon.ITEMTYPE_BUFF,
    ["+25% Armor Proc"] = addon.ITEMTYPE_BUFF,
    ["-3% Dam. Taken"] = addon.ITEMTYPE_BUFF,
    ["Healthstone"] = addon.ITEMTYPE_BUFF,

    ["-3% Hit Taken"] = addon.ITEMTYPE_DEBUFF,
    ["-Attack Power"] = addon.ITEMTYPE_DEBUFF,
    ["-Attack Speed"] = addon.ITEMTYPE_DEBUFF,
            
    -- Multi Purpose
    ["Heroism/Bloodlust"] = addon.ITEMTYPE_BUFF,
    ["+All Stats"] = addon.ITEMTYPE_BUFF,
    ["+10% All Stats"] = addon.ITEMTYPE_BUFF,
    ["+3% Damage"] = addon.ITEMTYPE_BUFF,
    ["+3% Haste"] = addon.ITEMTYPE_BUFF,

    ["+3% Crit"] = addon.ITEMTYPE_DEBUFF,
    
    -- Situational
    ["Shadow Res."] = addon.ITEMTYPE_BUFF,
    ["Fire Res."] = addon.ITEMTYPE_BUFF,
    ["Frost Res."] = addon.ITEMTYPE_BUFF,
    ["Nature Res."] = addon.ITEMTYPE_BUFF,

    ["-Healing Received"] = addon.ITEMTYPE_DEBUFF,
    ["-Cast Speed"] = addon.ITEMTYPE_DEBUFF,
    
    -- Count
    ["Replenishment"] = addon.ITEMTYPE_COUNT,
    ["Remove Magic"] = addon.ITEMTYPE_COUNT,
    ["Remove Poison"] = addon.ITEMTYPE_COUNT,
    ["Remove Curse"] = addon.ITEMTYPE_COUNT,
    ["Remove Disease"] = addon.ITEMTYPE_COUNT,
    ["Reduce Damage"] = addon.ITEMTYPE_COUNT,
    ["Power Restore"] = addon.ITEMTYPE_COUNT,
    
    ["Interrupt"] = addon.ITEMTYPE_COUNT,
    ["Purge"] = addon.ITEMTYPE_COUNT,
    ["Remove Enrage"] = addon.ITEMTYPE_COUNT,
    ["Remove Protection"] = addon.ITEMTYPE_COUNT,
    
    -- Crowd Control
    ["CC - Humanoid"] = addon.ITEMTYPE_COUNT,
    ["CC - Beast"] = addon.ITEMTYPE_COUNT,
    ["CC - Dragonkin"] = addon.ITEMTYPE_COUNT,
    ["CC - Giant"] = addon.ITEMTYPE_COUNT,
    ["CC - Elemental"] = addon.ITEMTYPE_COUNT,
    ["CC - Demon"] = addon.ITEMTYPE_COUNT,
    ["CC - Undead"] = addon.ITEMTYPE_COUNT,
    
    -- Composition
    ["Tanks"] = addon.ITEMTYPE_COUNT,
    ["Melee DPS"] = addon.ITEMTYPE_COUNT,
    ["Ranged DPS"] = addon.ITEMTYPE_COUNT,
    ["Healers"] = addon.ITEMTYPE_COUNT,
  }
