--[[
  Cooldown Used by Kiki/Espêrance - European Conseil des Ombres
   Feasts plugin
]]

---------------------------------------------------------
-- Constantes
---------------------------------------------------------

local GREAT_FEAST = 57301;
local FISH_FEAST = 57426;
local BOUNTIFUL_FEAST = 66476;

if(GetLocale() == "frFR")
then
  CU_TEXT_GREAT_FEAST = "%s nous a préparé un super festin de poiscaille, merci à toi et bon appetit !";
  CU_TEXT_FISH_FEAST = "%s nous a préparé un super festin de poiscaille, merci à toi et bon appetit !";
  CU_TEXT_FRUIT_FEAST = "%s nous a préparé une corbeille de fruit, mangez en 5 par jour, merci à toi !";
else
  CU_TEXT_GREAT_FEAST = "%s nous a préparé un cochon grillé, merci à toi et bon appetit !";
  CU_TEXT_FISH_FEAST = "%s nous a préparé un super festin de poiscaille, merci à toi et bon appetit !";
  CU_TEXT_FRUIT_FEAST = "%s nous a préparé une corbeille de fruit, mangez en 5 par jour, merci à toi !";
end

local strformat = string.format;

---------------------------------------------------------
-- Callbacks
---------------------------------------------------------

local function CU_Feasts_Announce(sourceName,destName,spellID,spellName)
  -- Check if we must announce
  if(CU_Spells[CU_SPELLS_FEAST][spellID])
  then
    local text = nil;
    if(spellID == GREAT_FEAST)
    then
      text = strformat(CU_TEXT_GREAT_FEAST,sourceName);
    elseif(spellID == FISH_FEAST)
    then
      text = strformat(CU_TEXT_FISH_FEAST,sourceName);
    elseif(spellID == BOUNTIFUL_FEAST)
    then
      text = strformat(CU_TEXT_FRUIT_FEAST,sourceName);
    end
    if(text)
    then
      if(GroupAnalyse.SendChatMessageTarget) -- In a party or a raid
      then
        if(GroupAnalyse.Myself.rank > 0) -- Have the rights to issue a raid warning
        then
          SendChatMessage(text,"RAID_WARNING");
        else
          RaidNotice_AddMessage(RaidWarningFrame,text,ChatTypeInfo["RAID_WARNING"]); -- Simulate raid warning
          PlaySound("RaidWarning");
          SendChatMessage(text,GroupAnalyse.SendChatMessageTarget); -- Send to party or raid channel
        end
      end
    end
  end
end

---------------------------------------------------------
-- Main Frame
---------------------------------------------------------

local CU_Feasts_Callbacks = {};

local function CU_Feasts_EnableModule()
  CU_Feasts_Callbacks[CU_SPELLS_FEAST] = CU_Feasts_Announce;
end

local function CU_Feasts_DisableModule()
  CU_Feasts_Callbacks[CU_SPELLS_FEAST] = nil;
end

CU_RegisterModule("Feasts",CU_Feasts_EnableModule,CU_Feasts_DisableModule,CU_Feasts_Callbacks);
