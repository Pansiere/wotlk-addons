--[[
  Cooldown Used by Kiki/Espêrance - European Conseil des Ombres

 Description:
   What is Cooldown Used (CDUsed)?
   It's an addon that monitors many spell casts from your party/raid members (mostly, special spells with long cooldown), like Shield Wall, Rebirth, Guardian Spirit...
   Everytime such a spell is used by a party/raid member, it's displayed in many ways on your screen (or chat channels).
   You can choose for each spell category (Aura gained, Aura lost, cooldown used, Interrupt used, ...) many display options such in floating combat text, chat channel (party/raid/custom channel), or simply in the special CDUsed window.
   You can add custom spells (not monitored by default) to any category, make templates of monitored spells, or use the default templates (tank, heal, kicker, everything).
   The addon also tracks tank taunts (miss/success), and kickers interrupts (miss/success).
   
   This addon can be very helpful for raid leaders who want to track who used there survival cooldowns at a critical time, who didn't and caused a wipe.
   It can also be very useful for healers to easily see if the tank is under a survival cooldown, and for tanks to see if another tank failed to taunt a boss (miss, immune).
   
   The addon supports plugins which can be added to do special things when a spell is used.
   A small plugin named "kick" is installed by default, when enabled, it monitors all party/raid members that are able to use an interrupt spell, and if said spell is in cooldown or not (showing a small progression bar for all player's kick spell).
   
   You can choose to enable or disable the addon on some locations (world, wintergrasp, 5-man instance, raid, battleground, arena) from the configuration menu.
   
   While in-game, use "/cu" to show the CDUsed window. Right click on the window's title to open the configuration menu.
   You can resize the window by dragging the bottom right corner of the window.
   
 ChangeLog:
   - 2010/06/30 : Version 3.1
     - Fixed lua errors caused by new ChatFrames
   - 2010/06/11: Version 3.0
     - Reworked how spells are stored by caterogy, allowing the user to select (per category) which spell he wants to monitor (and add new spells!)
     - Few minor fixes
     - Added a new plugin to display custom messages when someone drops a feast
     - You can now save/load templates of monitored spells
   - 2010/01/06: Version 2.32
     - Added Holy Wrath as interrupt spell
   - 2010/01/06: Version 2.3
     - Slight perf improvement
     - Now displaying spell links in chat and CU console
   - 2009/12/24:
     - Simulating a raid warning message if you don't have the rights to issue a real one
   - 2009/12/14: Version 2.22
     - Updated TOC
   - 2009/09/29: Version 2.2
     - Fix (hack) for dropdown menu auto closing (error in blizzard LFG code): Disabling "PARTY_MEMBERS_CHANGED" event monitoring in blizzard LFG frame
     - Added monitoring of "create objects" like toy train
   - 2009/08/19: Version 2.1
     - Added class name colors to chat messages
     - Added spell icon to chat messages
   - 2009/08/18:
     - Improved Kick module
   - 2009/08/05:
     - Removed EarthShock as interrupt spell, and renamed WindShock to WindShear
   - 2009/07/13: Version 2.0
     - Full rewrite of announce handling
     - Added customizable support for multiple combat text
   - 2009/07/09: Version 1.5
     - Many improvements
   - 2009/06/04: Version 1.0
     - Module created
  
  TODO:
   - Faire un nouveau plugin special healer:
     - Affiche le CD de tous les heals (et tanks)
   - Option pour ne pas annoncer les miss:IMMUNE
   - Kick module: 
     - Pouvoir choisir l'ordre de tri (fixe, le plus 'ready', ...)
     - Detecter qu'un mec est mort et afficher "Dead en rouge" !
   - Feasts module:
     - Config pour choisir les phrases a envoyer
     - Config pour choisir où poster les messages (raid/raid_warning/party/self)

TODO Nouveau plugin: Afficher le taunt immune sur un boss (enfin, detecter qu'il est taunt immune et afficher un timer). Se baser sur le guid pour tracker qui a ete taunt

  BUGS:
   - Le kick module s'ouvre, meme si l'addon est pas activé (genre Show in Raid=off et dans un raid)
     -> Faire en sorte que les modules s'auto-lancent qd le core s'active, et se cache qd le core se disable
     -> Mais attention, si on utilise les api de load/unload, ca va deconfig entierement les modules, donc pas bon


]]


--------------- Saved variables ---------------

CU_Config = {};
CU_Spells = {};
CU_SpellsTemplates = {};


--------------- Shared variables ---------------

CU_VERSION = GetAddOnMetadata("CDUsed", "Version");


--------------- Local Constantes ---------------

local CU_FILTER_RAID_PLAYERS = bit.bor(
  COMBATLOG_OBJECT_AFFILIATION_MINE,COMBATLOG_OBJECT_AFFILIATION_PARTY,COMBATLOG_OBJECT_AFFILIATION_RAID, -- Me, or in my group/raid
  COMBATLOG_OBJECT_REACTION_MASK,
  COMBATLOG_OBJECT_CONTROL_MASK,
  COMBATLOG_OBJECT_TYPE_PLAYER -- Just players, no pets
);

local CU_FILTER_ME = bit.bor(
  COMBATLOG_OBJECT_AFFILIATION_MINE, -- Me
  COMBATLOG_OBJECT_REACTION_MASK,
  COMBATLOG_OBJECT_CONTROL_MASK,
  COMBATLOG_OBJECT_TYPE_PLAYER -- Just players, no pets
);

local CU_FILTER_TARGET = bit.bor(
  COMBATLOG_OBJECT_AFFILIATION_OUTSIDER, -- Not in my raid/group
  COMBATLOG_OBJECT_REACTION_HOSTILE,COMBATLOG_OBJECT_REACTION_NEUTRAL, -- Only hostiles
  COMBATLOG_OBJECT_CONTROL_MASK,
  COMBATLOG_OBJECT_TYPE_MASK -- Any target
);


--------------- Local variables ---------------

local CU_Modules = {};
local CU_VarsLoaded = false;
local CU_NeedInit = true;
local CU_PlayerName = nil;
local CU_PlayerClass = nil;
local CU_IsEnabled = false;
local CUM_CurrentAnnounceType = nil;

local CU_ClassColors = {
  ["MAGE"] = "ff00ffff",
  ["WARLOCK"] = "ff8d54fb",
  ["PRIEST"] = "ffcccccc",
  ["DRUID"] = "ffff8a00",
  ["SHAMAN"] = "ff00dbba",
  ["PALADIN"] = "ffff71a8",
  ["ROGUE"] = "ffffff00",
  ["HUNTER"] = "ff00ff00",
  ["WARRIOR"] = "ffb39442",
  ["DEATHKNIGHT"] = "ffc41e3a",
};

local CU_AllowCombatText = {
  [CU_SPELLS_COOLDOWN_USED] = true,
  [CU_SPELLS_AURA_GAINED] = true,
  [CU_SPELLS_AURA_LOST] = true,
};

local CombatLog_Object_IsA = CombatLog_Object_IsA;
local COMBATLOG_FILTER_MINE = COMBATLOG_FILTER_MINE;
local strformat = string.format;
local strfind = string.find;
local tsort = table.sort;
local tinsert = table.insert;

--------------- Internal functions ---------------

function CU_ChatPrint(str,r,g,b)
  if(DEFAULT_CHAT_FRAME)
  then
    DEFAULT_CHAT_FRAME:AddMessage("CDUsed: "..str, r or 0.4, g or 0.6, b or 1.0);
  end
end

function CU_ChatMessage(fname,str,r,g,b)
  if(fname == nil)
  then
    return;
  end

  local col_r = r or 1.0;
  local col_g = g or 1.0;
  local col_b = b or 1.0;

  local frame = getglobal(fname) or fname;
  if(frame)
  then
    frame:AddMessage(str,col_r,col_g,col_b);
  end
end

function CU_ChatLog(str,r,g,b)
  CU_ChatMessage("CU_ChatFrame",str,r,g,b);
end

local function CU_IsSpellOfType(spell_type,spellID)
  local spells = CU_Spells[spell_type];
  if(spells ~= nil)
  then
    return spells[spellID] ~= nil; -- Has a value (true or false, whatever)
  end
  return false;
end

local function CU_IsSpellMonitored(spell_type,spellID)
  local spells = CU_Spells[spell_type];
  if(spells ~= nil)
  then
    return spells[spellID]; -- True if monitored, false otherwise
  end
  return false;
end

local function CU_CheckEnableParsing()
  local must_enable;
  local zone = GetRealZoneText();
  local _,instanceType = IsInInstance();

  if(instanceType == nil)
  then
    return;
  elseif(instanceType == "none")
  then
    if(zone == CU_ZONE_WINTERGRASP)
    then
      must_enable = CU_Config.Enables["Wintergrasp"];
    else
      must_enable = CU_Config.Enables["World"];
    end
  elseif(instanceType == "pvp")
  then
    must_enable = CU_Config.Enables["BG"];
  elseif(instanceType == "arena")
  then
    must_enable = CU_Config.Enables["Arena"];
  elseif(instanceType == "party")
  then
    must_enable = CU_Config.Enables["Instance"];
  elseif(instanceType == "raid")
  then
    must_enable = CU_Config.Enables["Raid"];
  end
  
  if(must_enable and not CU_IsEnabled)
  then
    CU_evFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    --CU_evFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE");
    CU_IsEnabled = true;
    CU_ChatPrint("Monitoring |cff10ff10enabled|r");
  elseif(not must_enable and CU_IsEnabled)
  then
    CU_evFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    --CU_evFrame:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE");
    CU_IsEnabled = false;
    CU_ChatPrint("Monitoring |cffff1010disabled|r");
  end
end

local function CU_SpellLink(spellID,spellName)
  local link = GetSpellLink(spellID);
  if(link)
  then
    return link;
  end
  return spellName;
end

local function CU_FixSpellName(spellName)
  if(strfind(spellName,"%(") ~= nil)
  then
    return spellName.."()";
  end
  return spellName;
end

function CU_CallPlugin(spell_type,...)
  for i,infos in ipairs(CU_Modules)
  do
    if(infos.callbacks[spell_type])
    then
      infos.callbacks[spell_type](...);
    end
  end
end

function CU_AnnounceTypeIsSelf(name)
  if(name == "CU_ChatFrame" or strfind(name,"ChatFrame"))
  then
    return true;
  end
  return false;
end

function CU_AnnounceTypeIsCustom(name)
  if(name == "none" or name == "party" or name == "raid" or name == "warning")
  then
    return false;
  end
  return CU_AnnounceTypeIsSelf(name) == false;
end


--------------------------------------

function CU_GetEnableAnnounce(announceType,announceChannel)
  local channels = CU_Config.Announce[announceType];
  if(channels)
  then
    local infos = channels[announceChannel];
    if(infos)
    then
      return infos.enabled;
    end
  end
  return false;
end

function CU_SetEnableAnnounce(announceType,announceChannel,enable)
  local channels = CU_Config.Announce[announceType];
  if(channels)
  then
    local infos = channels[announceChannel];
    if(infos)
    then
      infos.enabled = enable;
    end
  end
end

function CU_GetEnableCT(announceType,announceChannel)
  local channels = CU_Config.CombatText[announceType];
  if(channels)
  then
    local infos = channels[announceChannel];
    if(infos)
    then
      return infos.enabled;
    end
  end
  return false;
end

function CU_SetEnableCT(announceType,announceChannel,enable)
  local channels = CU_Config.CombatText[announceType];
  if(channels)
  then
    local infos = channels[announceChannel];
    if(infos)
    then
      infos.enabled = enable;
    end
  end
end

local function CU_ColoredClass(name)
  local _,clas = UnitClass(name);
  if(clas and CU_ClassColors[clas])
  then
    return "|c"..CU_ClassColors[clas]..name.."|r";
  end
  return name;
end

local function CU_GetSpellChatIcon(spellID)
  local _,_,icon = GetSpellInfo(spellID);
  if(icon)
  then
    return "|T"..icon..":0|t";
  end
  return "";
end

local function CU_CombatText(announceType,spellID,selfText)
  local channels = CU_Config.CombatText[announceType];
  
  if(channels)
  then
    for channelName,infos in pairs(channels)
    do
      if(infos.enabled)
      then
        if(channelName == "bct")
        then
          CombatText_AddMessage(selfText,COMBAT_TEXT_SCROLL_FUNCTION,infos.r,infos.g,infos.b,infos.displayType, nil);
        elseif(channelName == "sct")
        then
          SCT:DisplayCustomEvent(selfText,{r=infos.r,g=infos.g,b=infos.b},infos.isCrit);
        elseif(channelName == "msbt")
        then
          local texture = nil;
          if(infos.showIcon)
          then
            local name,_,icon = GetSpellInfo(spellID);
            texture = icon;
          end
          MikSBT.DisplayMessage(selfText,infos.fname,infos.isCrit,infos.r*255,infos.g*255,infos.b*255,nil,nil,nil,texture);
        end
      end
    end
  end
end

local function CU_Announce(announceType,announceText,selfText)
  local channels = CU_Config.Announce[announceType];
  
  if(channels)
  then
    for channelName,infos in pairs(channels)
    do
      if(infos.enabled)
      then
        if(channelName == "raid")
        then
          SendChatMessage(announceText,GroupAnalyse.SendChatMessageTarget);
        elseif(channelName == "warning")
        then
          if(GroupAnalyse.Myself.rank > 0)
          then
            SendChatMessage(announceText,"RAID_WARNING");
          else -- Simulate raid warning
            RaidNotice_AddMessage(RaidWarningFrame,announceText,ChatTypeInfo["RAID_WARNING"]);
            PlaySound("RaidWarning");
          end
        elseif(channelName == "party")
        then
          if(GroupAnalyse.CurrentGroupMode ~= GroupAnalyse.MODE_SOLO)
          then
            SendChatMessage(announceText,"PARTY");
          end
        elseif(channelName == "custom" and infos.channel)
        then
          local id = GetChannelName(infos.channel);
          if(id ~= 0)
          then
            SendChatMessage(announceText,"CHANNEL",nil,id);
          end
        elseif(channelName == "self" and infos.fname)
        then
          CU_ChatMessage(infos.fname,selfText);
        end
      end
    end
  end
end

local function CU_InitAnnounceCTValues(announceType,name,r,g,b)
  if(CU_Config.CombatText[announceType][name] == nil)
  then
    local infos = { enabled = false, r = r, g = g, b = b };
    CU_Config.CombatText[announceType][name] = infos;
    -- Custom init
    if(name == "bct")
    then
      infos.displayType = "crit"; -- nil or "crit" or "sticky"
    elseif(name == "sct")
    then
      infos.isCrit = 1; -- nil or 1
    elseif(name == "msbt")
    then
      infos.isCrit = true; -- false or true
      infos.showIcon = true; -- false or true
      if(MikSBT and MikSBT.DISPLAYTYPE_NOTIFICATION)
      then
        infos.fname = MikSBT.DISPLAYTYPE_NOTIFICATION; -- MSBT's frame name to use
      else
        infos.fname = "Notification";
      end
    end
    return true;
  end
  -- Check module exist
  if(name == "bct")
  then
    if(_G.SHOW_COMBAT_TEXT ~= "1")
    then
      CU_SetEnableCT(announceType,name,false);
    end
  elseif(name == "sct")
  then
    if(SCT == nil or SCT.DisplayCustomEvent == nil)
    then
      CU_SetEnableCT(announceType,name,false);
    end
  elseif(name == "msbt")
  then
    if(MikSBT == nil or MikSBT.DisplayMessage == nil)
    then
      CU_SetEnableCT(announceType,name,false);
    end
  end
  return false;
end

local function CU_GetAnnounceInfos(announceType,name)
  local channels = CU_Config.Announce[announceType];
  if(channels)
  then
    return channels[name];
  end
  return nil;
end

local function CU_GetCTInfos(announceType,name)
  local channels = CU_Config.CombatText[announceType];
  if(channels)
  then
    return channels[name];
  end
  return nil;
end

local function CU_InitAnnounceChannelValues(announceType,name)
  if(CU_Config.Announce[announceType][name] == nil)
  then
    CU_Config.Announce[announceType][name] = { enabled = false };
    return true;
  end
  return false;
end

local function CU_InitAnnounceValues(announceType,announceChannel,r,g,b)
  -- Announce channels
  if(CU_Config.Announce[announceType] == nil)
  then
    CU_Config.Announce[announceType] = {};
  end

  if(CU_InitAnnounceChannelValues(announceType,"self") == true) -- Created
  then
    CU_Config.Announce[announceType]["self"].enabled = true;
    CU_Config.Announce[announceType]["self"].fname = announceChannel;
  end
  CU_InitAnnounceChannelValues(announceType,"party");
  CU_InitAnnounceChannelValues(announceType,"raid");
  CU_InitAnnounceChannelValues(announceType,"warning");
  CU_InitAnnounceChannelValues(announceType,"custom");
  
  -- Combat Text
  if(CU_AllowCombatText[announceType])
  then
    if(CU_Config.CombatText[announceType] == nil)
    then
      CU_Config.CombatText[announceType] = {};
    end

    CU_InitAnnounceCTValues(announceType,"bct",r,b,g);
    CU_InitAnnounceCTValues(announceType,"sct",r,b,g);
    CU_InitAnnounceCTValues(announceType,"msbt",r,b,g);
  end
end

local function CU_InitValue(name,def,...)
  local count = select("#",...);
  local conf = CU_Config;
  if(count ~= 0)
  then
    for i=1,count
    do
      conf = conf[select(i,...)];
    end
  end
  if(conf[name] == nil)
  then
    conf[name] = def;
  end
end

local function reminderOnClick(self, button, down) 
    PlaySound("igChatBottom"); 
    if (IsShiftKeyDown()) then
        module.copyformat = "wowace"
    end
    if (IsControlKeyDown()) then
        self.PratCopyChat:ScrapeFullChatFrame(self:GetParent()) 
    else
        self.PratCopyChat:ScrapeChatFrame(self:GetParent()) 
    end
        
    self.PratCopyChat.copyformat = nil
end
local function reminderOnEnter(self, motion) self:SetAlpha(0.9) end
local function reminderOnLeave(self, motion) self:SetAlpha(0.2) end

local function CU_SetupPratTimestamps()
  if(LibStub)
  then
    local Stub = LibStub("AceAddon-3.0");
    if(Stub)
    then
      local MyAddon = Stub:GetAddon("Prat");
      if(MyAddon)
      then
        local MyModule = MyAddon:GetModule("Timestamps");
        MyModule:RawHook(CU_ChatFrame,"AddMessage",true);
        CU_ChatLog("Prat Timestamps module found!",0,1,0);
      end
    end
  end
end

local function CU_SetupPratCopyChat()
  if(LibStub)
  then
    local Stub = LibStub("AceAddon-3.0");
    if(Stub)
    then
      local MyAddon = Stub:GetAddon("Prat");
      if(MyAddon)
      then
        local MyModule = MyAddon:GetModule("CopyChat");
        CU_ChatLog("Prat CopyChat module found!",0,1,0);
        
        local cf = _G["CU_ChatFrame"]
        local name = "CU_ChatFrame".."PratCCReminder"
        local b = _G[name]
        if not b then
          b = CreateFrame("Button", name, cf)
          b:SetFrameStrata("MEDIUM")
          b:SetWidth(24)
          b:SetHeight(24)
          b:SetNormalTexture("Interface\\Addons\\Prat-3.0\\textures\\prat-chatcopy2")
          b:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down")
          b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
          b:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0)
          b:SetScript("OnClick", reminderOnClick)
          b:SetScript("OnEnter", reminderOnEnter)
          b:SetScript("OnLeave", reminderOnLeave)
          b:SetAlpha(0.2)
          b:Show()
        end
        
        b.PratCopyChat = MyModule;
      end
    end
  end
end

local function CU_StartModules()
  for i,infos in ipairs(CU_Modules)
  do
    if(CU_Config.EnabledModules[infos.name] and infos.init)
    then
      infos.init();
      infos.enabled = true;
    end
  end
end

local function CU_StartModule(name)
  for i,infos in ipairs(CU_Modules)
  do
    if(infos.name == name and infos.init)
    then
      infos.init();
      infos.enabled = true;
    end
  end
end

local function CU_StopModule(name)
  for i,infos in ipairs(CU_Modules)
  do
    if(infos.name == name and infos.uninit)
    then
      infos.uninit();
      infos.enabled = false;
    end
  end
end

local function CU_SetChatWindowAlpha(self,alpha)
  for index, value in pairs(CHAT_FRAME_TEXTURES) do
    getglobal("CU_ChatFrame"..value):SetAlpha(alpha);
    getglobal("CU_ChatFrame"..value):SetVertexColor(0,0,0);
  end
  CU_Config.Alpha = alpha;
end

local function CU_SetChatWindowFontSize(self, chatFrame, fontSize)
  if ( not chatFrame ) then
    chatFrame = FCF_GetCurrentChatFrame();
  end
  if ( not fontSize ) then
    fontSize = self.value;
  end
  local fontFile, unused, fontFlags = chatFrame:GetFont();
  chatFrame:SetFont(fontFile, fontSize, fontFlags);
  if ( GMChatFrame and chatFrame == DEFAULT_CHAT_FRAME ) then
    GMChatFrame:SetFont(fontFile, fontSize, fontFlags);
  end
  SetChatWindowSize(chatFrame:GetID(), fontSize);
  CU_Config.FontSize = fontSize;
end

local function CU_UpdateShowWindow()
  if(CU_Config.ShowMainWindow)
  then
    CU_ChatFrame:Show();
  else
    CU_ChatFrame:Hide();
  end
end

local function CU_Init_CheckUpgradeFromVersion2()
  if(CU_Config.Version == nil) -- Upgrade from v2.x
  then
    -- Convert announce array
    local old_tab = CU_Config.Announce;
    CU_Config.Announce = {}; -- Start a new clean array
    for id,name in ipairs(CU_SpellTypeToName)
    do
      local value = old_tab[name]; -- search in old config format
      if(value ~= nil)
      then
        CU_Config.Announce[id] = value;
      end
    end
    -- Convert combatText array
    local old_tab = CU_Config.CombatText;
    CU_Config.CombatText = {}; -- Start a new clean array
    for id,name in ipairs(CU_SpellTypeToName)
    do
      local value = old_tab[name]; -- search in old config format
      if(value ~= nil and CU_AllowCombatText[id])
      then
        CU_Config.CombatText[id] = value;
      end
    end
    -- Setup default monitored spells (all spells)
    CU_Spells = CU_Template_All;
    -- Done
    CU_ChatPrint("Conversion from CDUsed v2.x to v"..CU_VERSION.." completed!");
  end
  CU_Config.Version = CU_VERSION;
end

local function CU_StartupInitVars()
  local playerName = UnitName("player");
  if((playerName) and (playerName ~= UNKNOWNOBJECT) and (playerName ~= UKNOWNBEING))
  then
    -- Initialize Toon specific stuff
    CU_PlayerName = playerName;
    _,CU_PlayerClass = UnitClass("player");
    if(CU_Config == nil)
    then
      CU_Config = {};
    end
    -- Check for convert from version 2.x
    CU_Init_CheckUpgradeFromVersion2();
    -- Zones
    CU_InitValue("Enables",{});
    CU_InitValue("Wintergrasp",false,"Enables");
    CU_InitValue("World",false,"Enables");
    CU_InitValue("Instance",true,"Enables");
    CU_InitValue("Raid",true,"Enables");
    CU_InitValue("BG",false,"Enables");
    CU_InitValue("Arena",false,"Enables");
    -- Announces
    CU_InitValue("Announce",{});
    CU_InitValue("CombatText",{});
    CU_InitAnnounceValues(CU_SPELLS_AURA_GAINED,"CU_ChatFrame",0.4,0.6,1);
    CU_InitAnnounceValues(CU_SPELLS_AURA_LOST,"CU_ChatFrame",1,0.1,0.1);
    CU_InitAnnounceValues(CU_SPELLS_COOLDOWN_USED,"CU_ChatFrame",0.4,0.6,1);
    CU_InitAnnounceValues(CU_SPELLS_CREATIONS,"CU_ChatFrame",0.9,0.9,0.9);
    CU_InitAnnounceValues(CU_SPELLS_RESURRECT,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_INTERRUPT_USED_SUCCESS,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_INTERRUPTED,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_INTERRUPT_USED_FAILED,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_TAUNTED,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_TAUNT_MISSED,"CU_ChatFrame",1,1,1);
    CU_InitAnnounceValues(CU_SPELLS_FEAST,"CU_ChatFrame",1,1,1);
    -- Other
    CU_InitValue("ShowMainWindow",true);
    CU_InitValue("Alpha",0.6);
    CU_InitValue("FontSize",12);
    CU_InitValue("EnabledModules",{});
    CU_InitValue("Modules",{});
    pcall(CU_SetupPratTimestamps);
    pcall(CU_SetupPratCopyChat);
    CU_SetChatWindowAlpha(CU_ChatFrame,CU_Config.Alpha);
    CU_SetChatWindowFontSize(nil,CU_ChatFrame,CU_Config.FontSize);
    if(LFGParentFrame)
    then
      LFGParentFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED"); -- Fixup for dropdown menu auto closing
    end
    CU_StartModules();
    -- Set window title
    CU_ChatFrameTabText:SetText("CD Used Log by Espêrance - v"..CU_VERSION);
    CU_UpdateShowWindow();
    CU_NeedInit = false;
  end
end

local function CU_Commands(command)
  local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$");
  if(not cmd) then cmd = command; end
  if(not cmd) then cmd = ""; end
  if(not param) then param = ""; end

  if(cmd == "help")
  then
    CU_ChatPrint("Usage:");
    CU_ChatPrint(" /cu announce [none|self||raid]: Forces all announces to the same type");
  elseif(cmd == "announce")
  then
    if(param == "none" or param == "self" or param == "raid")
    then
      for announceType,channels in pairs(CU_Config.Announce)
      do
        -- Disable all channels
        for channelName,infos in pairs(channels)
        do
          infos.enabled = false;
        end
        if(param ~= "none")
        then
          -- Enable new one
          if(param == "self")
          then
            CU_SetEnableAnnounce(announceType,"self",true);
            local infos = CU_GetAnnounceInfos(announceType,"self");
            if(infos)
            then
              infos.fname = "CU_ChatFrame";
            end
          else
            CU_SetEnableAnnounce(announceType,param,true);
          end
        end
      end
      if(param == "none")
      then
        CU_ChatPrint("All announces disabled");
      else
        CU_ChatPrint("All announces set to '"..param.."'");
      end
    else
      CU_ChatPrint("Unknown parameter for 'announce' command. See /cu help");
    end
  else
    if(CU_ChatFrame:IsShown())
    then
      CU_Config.ShowMainWindow = false;
    else
      CU_Config.ShowMainWindow = true;
    end
    CU_UpdateShowWindow();
  end
end

--------------- XML functions ---------------

local function CU_OnEvent(self,event,...)
  if(event == "VARIABLES_LOADED")
  then
    CU_VarsLoaded = true;
  end
  if(CU_NeedInit)
  then
    if(CU_VarsLoaded == false)
    then
      return;
    end
    CU_StartupInitVars();
  end

  if(event == "COMBAT_LOG_EVENT_UNFILTERED")
  then
    local timestamp,eventType,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags = ...;
    if(CombatLog_Object_IsA(destFlags,CU_FILTER_RAID_PLAYERS))
    then
      if(eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_APPLIED_DOSE")
      then
        local spellID,spellName,_,auraType = select(9,...);
        if(auraType == "BUFF" or auraType == "DEBUFF")
        then
          if(CU_IsSpellOfType(CU_SPELLS_AURA_GAINED,spellID))
          then
            CU_CallPlugin(CU_SPELLS_AURA_GAINED,sourceName,destName,spellID,spellName);
            if(CU_IsSpellMonitored(CU_SPELLS_AURA_GAINED,spellID))
            then
              if(sourceName == destName)
              then
                CU_Announce(CU_SPELLS_AURA_GAINED,strformat("### %s gained %s ###",destName,CU_SpellLink(spellID,spellName)),strformat("%s |cff00ff00gained|r %s %s",CU_ColoredClass(destName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
              else
                CU_Announce(CU_SPELLS_AURA_GAINED,strformat("### %s gained %s's %s ###",destName,sourceName,CU_SpellLink(spellID,spellName)),strformat("%s |cff00ff00gained|r %s's %s %s",CU_ColoredClass(destName),CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
              end
              if(destName == CU_PlayerName)
              then
                if(sourceName == destName)
                then
                  CU_CombatText(CU_SPELLS_AURA_GAINED,spellID,strformat("GAINED %s",spellName));
                else
                  CU_CombatText(CU_SPELLS_AURA_GAINED,spellID,strformat("GAINED %s from %s",spellName,sourceName));
                end
              end
            end
          end
        end

      elseif(eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REMOVED_DOSE")
      then
        local spellID,spellName,_,auraType = select(9,...);
        if(auraType == "BUFF")
        then
          if(CU_IsSpellOfType(CU_SPELLS_AURA_LOST,spellID))
          then
            CU_CallPlugin(CU_SPELLS_AURA_LOST,sourceName,destName,spellID,spellName);
            if(CU_IsSpellMonitored(CU_SPELLS_AURA_LOST,spellID))
            then
              if(sourceName == destName)
              then
                CU_Announce(CU_SPELLS_AURA_LOST,strformat("### %s lost %s ###",destName,CU_SpellLink(spellID,spellName)),strformat("%s |cffff0000lost|r %s %s",CU_ColoredClass(destName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
              else
                CU_Announce(CU_SPELLS_AURA_LOST,strformat("### %s lost %s's %s ###",destName,sourceName,CU_SpellLink(spellID,spellName)),strformat("%s |cffff0000lost|r %s's %s %s",CU_ColoredClass(destName),CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
              end
              if(destName == CU_PlayerName)
              then
                CU_CombatText(CU_SPELLS_AURA_LOST,spellID,strformat("%s FADED",spellName));
              end
            end
          end
        end
      end
    end

    if(CombatLog_Object_IsA(sourceFlags,CU_FILTER_RAID_PLAYERS))
    then
      if(eventType == "SPELL_MISSED")
      then
        local spellID,spellName,_,missType = select(9,...);
        if(CU_IsSpellOfType(CU_SPELLS_INTERRUPT_USED_FAILED,spellID))
        then
          CU_CallPlugin(CU_SPELLS_INTERRUPT_USED_FAILED,sourceName,destName,spellID,spellName,missType);
          if(CU_IsSpellMonitored(CU_SPELLS_INTERRUPT_USED_FAILED,spellID))
          then
            CU_Announce(CU_SPELLS_INTERRUPT_USED_FAILED,strformat("### %s's interrupt MISSED: %s ###",sourceName,missType),strformat("%s's %s %s |cffff0000MISSED|r: %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID),missType));
          end
        end
        if(CU_IsSpellOfType(CU_SPELLS_TAUNT_MISSED,spellID))
        then
          CU_CallPlugin(CU_SPELLS_TAUNT_MISSED,sourceName,destName,spellID,spellName,missType);
          if(CU_IsSpellMonitored(CU_SPELLS_TAUNT_MISSED,spellID))
          then
            CU_Announce(CU_SPELLS_TAUNT_MISSED,strformat("### %s's taunt on %s MISSED: %s ###",sourceName,destName,missType),strformat("%s's |cffff00fftaunt|r %s |cffff0000MISSED|r: %s",CU_ColoredClass(sourceName),CU_GetSpellChatIcon(spellID),missType));
          end
        end

      elseif(eventType == "SPELL_CAST_SUCCESS")
      then
        local spellID,spellName = select(9,...);
        if(CU_IsSpellOfType(CU_SPELLS_COOLDOWN_USED,spellID))
        then
          CU_CallPlugin(CU_SPELLS_COOLDOWN_USED,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_COOLDOWN_USED,spellID))
          then
            if(destName)
            then
              CU_Announce(CU_SPELLS_COOLDOWN_USED,strformat("### %s casted %s on %s ###",sourceName,CU_SpellLink(spellID,spellName),destName),strformat("%s |cff0000ffcasted|r %s %s on %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID),CU_ColoredClass(destName)));
            else
              CU_Announce(CU_SPELLS_COOLDOWN_USED,strformat("### %s casted %s ###",sourceName,CU_SpellLink(spellID,spellName)),strformat("%s |cff0000ffcasted|r %s %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
            end
            if(destName == CU_PlayerName)
            then
              if(sourceName == destName)
              then
                CU_CombatText(CU_SPELLS_COOLDOWN_USED,spellID,strformat("%s USED",spellName));
              else
                CU_CombatText(CU_SPELLS_COOLDOWN_USED,spellID,strformat("%s USED %s on you",sourceName,spellName));
              end
            end
          end
        end
        if(CU_IsSpellOfType(CU_SPELLS_TAUNTED,spellID))
        then
          CU_CallPlugin(CU_SPELLS_TAUNTED,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_TAUNTED,spellID))
          then
            if(destName)
            then
              CU_Announce(CU_SPELLS_TAUNTED,strformat("### %s taunted %s ###",sourceName,destName),strformat("%s |cffff00fftaunted|r %s %s",CU_ColoredClass(sourceName),CU_GetSpellChatIcon(spellID),CU_ColoredClass(destName)));
            else
              CU_Announce(CU_SPELLS_TAUNTED,strformat("### %s taunted ###",sourceName),strformat("%s |cffff00fftaunted|r %s",CU_ColoredClass(sourceName),CU_GetSpellChatIcon(spellID)));
            end
          end
        end
        if(CU_IsSpellOfType(CU_SPELLS_INTERRUPT_USED_SUCCESS,spellID))
        then
          CU_CallPlugin(CU_SPELLS_INTERRUPT_USED_SUCCESS,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_INTERRUPT_USED_SUCCESS,spellID))
          then
            CU_Announce(CU_SPELLS_INTERRUPT_USED_SUCCESS,strformat("### %s used his interrupt spell %s ###",sourceName,CU_SpellLink(spellID,spellName)),strformat("%s |cff008080used interrupt|r %s %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
          end
        end

      elseif(eventType == "SPELL_RESURRECT")
      then
        local spellID,spellName = select(9,...);
        if(CU_IsSpellOfType(CU_SPELLS_RESURRECT,spellID))
        then
          CU_CallPlugin(CU_SPELLS_RESURRECT,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_RESURRECT,spellID))
          then
            if(destName)
            then
              CU_Announce(CU_SPELLS_RESURRECT,strformat("### %s resurrected %s ###",sourceName,destName),strformat("%s |cff00ff00resurrected|r %s %s",CU_ColoredClass(sourceName),CU_GetSpellChatIcon(spellID),CU_ColoredClass(destName)));
            else
              CU_Announce(CU_SPELLS_RESURRECT,strformat("### %s casted %s ###",sourceName,CU_SpellLink(spellID,spellName)),strformat("%s |cff00ff00casted|r %s %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
            end
          end
        end

      elseif(eventType == "SPELL_INTERRUPT")
      then
        local spellID,spellName,_,extraSpellID,extraSpellName,extraSchool = select(9,...);
        if(CU_IsSpellOfType(CU_SPELLS_INTERRUPTED,spellID))
        then
          CU_CallPlugin(CU_SPELLS_INTERRUPTED,sourceName,destName,spellID,spellName,extraSpellID,extraSpellName);
          if(CU_IsSpellMonitored(CU_SPELLS_INTERRUPTED,spellID))
          then
            CU_Announce(CU_SPELLS_INTERRUPTED,strformat("### %s interrupted %s's %s with %s ###",sourceName,destName,CU_SpellLink(extraSpellID,extraSpellName),CU_SpellLink(spellID,spellName)),strformat("%s |cff00ffffinterrupted|r %s's %s with %s %s",CU_ColoredClass(sourceName),CU_ColoredClass(destName),CU_SpellLink(extraSpellID,extraSpellName),CU_SpellLink(spellID,spellName),CU_GetSpellChatIcon(spellID)));
          end
        else
          if(kud)
          then
            kud(sourceName.." interrupted a spell using '"..spellName.."' ("..spellID..")");
          end
        end
      
      elseif(eventType == "SPELL_CREATE")
      then
        local spellID,spellName = select(9,...);
        if(CU_IsSpellOfType(CU_SPELLS_CREATIONS,spellID))
        then
          CU_CallPlugin(CU_SPELLS_CREATIONS,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_CREATIONS,spellID))
          then
            CU_Announce(CU_SPELLS_CREATIONS,strformat("### %s created %s ###",sourceName,CU_SpellLink(spellID,spellName)),strformat("%s created %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName)));
          end
        elseif(CU_IsSpellOfType(CU_SPELLS_FEAST,spellID))
        then
          CU_CallPlugin(CU_SPELLS_FEAST,sourceName,destName,spellID,spellName);
          if(CU_IsSpellMonitored(CU_SPELLS_FEAST,spellID))
          then
            CU_Announce(CU_SPELLS_FEAST,strformat("### %s created %s ###",sourceName,CU_SpellLink(spellID,spellName)),strformat("%s created %s",CU_ColoredClass(sourceName),CU_SpellLink(spellID,spellName)));
          end
        end
      end
    end
  
  --[[elseif(event == "CHAT_MSG_MONSTER_EMOTE")
  then
    local text,name = ...;
    if(text and strfind(text,CU_EMOTE_FISH_FEAST))
    then
      CU_CallPlugin(CU_SPELLS_FEAST,name,"FISH");
      CU_Announce(CU_SPELLS_FEAST,strformat(CU_TEXT_FISH_FEAST,name),strformat("%s prepares a Fish Feast!",CU_ColoredClass(name)));
    elseif(text and strfind(text,CU_EMOTE_GREAT_FEAST))
    then
      CU_CallPlugin(CU_SPELLS_FEAST,name,"GREAT");
      CU_Announce(CU_SPELLS_FEAST,strformat(CU_TEXT_GREAT_FEAST,name),strformat("%s prepares a Great Feast!",CU_ColoredClass(name)));
    elseif(text and strfind(text,CU_EMOTE_FRUIT_FEAST))
    then
      CU_CallPlugin(CU_SPELLS_FEAST,name,"FRUIT");
      CU_Announce(CU_SPELLS_FEAST,strformat(CU_TEXT_FRUIT_FEAST,name),strformat("%s prepares a Bountiful Feast!",CU_ColoredClass(name)));
    end
  ]]
  elseif(event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA")
  then
    CU_CheckEnableParsing();
    self:UnregisterEvent("PLAYER_ENTERING_WORLD"); -- Always unregister PLAYER_ENTERING_WORLD once we got either one, because PLAYER_ENTERING_WORLD is triggered alone only after a reloadui
  end
end

function CU_OnMouseWheel(self,value)
  if ( IsShiftKeyDown() ) then
    if ( value > 0 ) then
      self:ScrollToTop()
    elseif ( value < 0 ) then
      self:ScrollToBottom();
    end
  else
    if ( value > 0 ) then
      self:ScrollUp();
    elseif ( value < 0 ) then
      self:ScrollDown();
    end
  end
end


--------------- API functions ---------------



--------------- Other functions ---------------


--------------- Popup Menu functions ---------------

StaticPopupDialogs["CU_SAVE_CUSTOM_TEMPLATE"] = {
  text = "Select custom template name:",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 31,
  whileDead = 1,
  OnAccept = function(self,name)
    local name = self.editBox:GetText();
    if(name and name ~= "")
    then
      CU_SpellsTemplates[name] = GA_DuplicateTable(CU_Spells);
      CU_ChatPrint("Custom template '"..name.."' saved!");
    end
    self.editBox:SetText("");
  end,
  timeout = 0,
  EditBoxOnEnterPressed = function(self,name)
    local parent = self:GetParent();
    local editBox = parent.editBox;
    local name = editBox:GetText();
    if(name and name ~= "")
    then
      CU_SpellsTemplates[name] = GA_DuplicateTable(CU_Spells);
      CU_ChatPrint("Custom template '"..name.."' saved!");
    end
    editBox:SetText("");
    parent:Hide();
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide();
  end,
  hideOnEscape = 1
};

StaticPopupDialogs["CU_ADD_NEW_SPELL"] = {
  text = "Add a new monitored spell to category '%s'\nEnter Spell ID to add.",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 6,
  whileDead = 1,
  OnAccept = function(self,name)
    local category = self.data;
    local spellString = self.editBox:GetText();
    self.editBox:SetText("");
    local spellID = tonumber(spellString);
    if(spellID == nil)
    then
      CU_ChatMessage(DEFAULT_CHAT_FRAME,"Not a Spell ID: '"..spellString.."'",1,0,0.3);
      return;
    end
    local spellName = GetSpellInfo(spellID);
    if(spellName == nil)
    then
      CU_ChatMessage(DEFAULT_CHAT_FRAME,"Unknown Spell ID: '"..spellID.."'",1,0,0.3);
      return;
    end
    CU_ChatMessage(DEFAULT_CHAT_FRAME,"Added spell '"..spellName.."' to category '"..CU_SpellTypeToName[category].."'",0.1,1,0.2);
    CU_Spells[category][spellID] = true;
  end,
  timeout = 0,
  EditBoxOnEnterPressed = function(self,name)
    local parent = self:GetParent();
    local category = parent.data;
    local editBox = parent.editBox;
    local spellString = editBox:GetText();
    editBox:SetText("");
    parent:Hide();
    local spellID = tonumber(spellString);
    if(spellID == nil)
    then
      CU_ChatMessage(DEFAULT_CHAT_FRAME,"Not a Spell ID: '"..spellString.."'",1,0,0.3);
      return;
    end
    local spellName = GetSpellInfo(spellID);
    if(spellName == nil)
    then
      CU_ChatMessage(DEFAULT_CHAT_FRAME,"Unknown Spell ID: '"..spellID.."'",1,0,0.3);
      return;
    end
    CU_ChatMessage(DEFAULT_CHAT_FRAME,"Added spell '"..spellName.."' to category '"..CU_SpellTypeToName[category].."'",0.1,1,0.2);
    CU_Spells[category][spellID] = true;
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide();
  end,
  hideOnEscape = 1
};

StaticPopupDialogs["CU_CUSTOM_CHANNEL"] = {
  text = "Select custom channel to announce '%s' to:",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 31,
  whileDead = 1,
  OnAccept = function(self,name)
    local channel = self.editBox:GetText();
    if(channel and channel ~= "")
    then
      CU_SetEnableAnnounce(name,"custom",true);
      local infos = CU_GetAnnounceInfos(name,"custom");
      if(infos)
      then
        infos.channel = channel;
      end
    end
    self.editBox:SetText("");
  end,
  timeout = 0,
  EditBoxOnEnterPressed = function(self,name)
    local parent = self:GetParent();
    local editBox = parent.editBox;
    local channel = editBox:GetText();
    if(channel and channel ~= "")
    then
      CU_SetEnableAnnounce(name,"custom",true);
      local infos = CU_GetAnnounceInfos(name,"custom");
      if(infos)
      then
        infos.channel = channel;
      end
    end
    editBox:SetText("");
    parent:Hide();
  end,
  EditBoxOnEscapePressed = function(self)
    self:GetParent():Hide();
  end,
  hideOnEscape = 1
};

local function CUM_HideMainWindow(self)
  CU_Config.ShowMainWindow = false;
  CU_UpdateShowWindow();
  CU_ChatPrint("Main window hidden. Type /cu to reshow it.");
end

local function CUM_SetAnnounceType(self,name,value,checked)
  if(value == "custom")
  then
    if(checked)
    then
      local dialog = StaticPopup_Show("CU_CUSTOM_CHANNEL",name);
      if(dialog)
      then
        dialog.data = name;
        if(dialog.editBox)
        then
          local infos = CU_GetAnnounceInfos(name,"custom");
          if(infos and infos.channel)
          then
            dialog.editBox:SetText(infos.channel);
          else
            dialog.editBox:SetText("");
          end
        end
        self:GetParent():Hide();
      end
    else
      CU_SetEnableAnnounce(name,"custom",false);
    end
    return;
  end
  CU_SetEnableAnnounce(name,value,checked);
  CloseDropDownMenus(4);
end

local function CUM_SetCTType(self,name,value,checked)
  CU_SetEnableCT(name,value,checked);
  CloseDropDownMenus(5);
end

local function CUM_CreateAnnounceMenuItem(value)
  info = UIDropDownMenu_CreateInfo();
  info.text = value;
  info.arg1 = CUM_CurrentAnnounceType;
  info.arg2 = value;
  info.func = CUM_SetAnnounceType;
  info.keepShownOnClick = true;
  info.checked = CU_GetEnableAnnounce(CUM_CurrentAnnounceType,value);
  if(value == "self")
  then
    info.hasArrow = 1;
  end
  return info;
end

local function CUM_CreateCTMenuItem(name,value)
  info = UIDropDownMenu_CreateInfo();
  info.text = name;
  info.arg1 = CUM_CurrentAnnounceType;
  info.arg2 = value;
  info.func = CUM_SetCTType;
  info.keepShownOnClick = true;
  info.checked = CU_GetEnableCT(CUM_CurrentAnnounceType,value);
  info.hasArrow = 1;
  if(value == "bct")
  then
    if(_G.SHOW_COMBAT_TEXT ~= "1")
    then
      info.disabled = true;
    end
  elseif(value == "sct")
  then
    if(SCT == nil or SCT.DisplayCustomEvent == nil)
    then
      info.disabled = true;
    end
  elseif(value == "msbt")
  then
    if(MikSBT == nil or MikSBT.DisplayMessage == nil)
    then
      info.disabled = true;
    end
  end
  return info;
end

local function CUM_SetEnableType(self,name)
  if(CU_Config.Enables[name])
  then
    CU_Config.Enables[name] = false;
  else
    CU_Config.Enables[name] = true;
  end
  CU_CheckEnableParsing();
end

local function CUM_SetModuleState(self,name,state)
  if(state)
  then
    CU_StopModule(name);
    CU_ChatPrint(name.." module disabled");
    CU_Config.EnabledModules[name] = false;
  else
    CU_StartModule(name);
    CU_ChatPrint(name.." module enabled");
    CU_Config.EnabledModules[name] = true;
  end
end

local function CUM_SetAnnounceSelf(self,event,channel)
  local infos = CU_GetAnnounceInfos(event,"self");
  if(infos)
  then
    infos.fname = channel;
  end
end

local function CUM_LoadDefaultTemplate(self,template,name)
  CU_Spells = GA_DuplicateTable(template);
  CU_ChatPrint("Default template '"..name.."' loaded!");
  CloseDropDownMenus(1);
end

local function CUM_LoadCustomTemplate(self,name)
  local template = CU_SpellsTemplates[name];
  if(template)
  then
    CU_Spells = GA_DuplicateTable(template);
    CU_ChatPrint("Custom template '"..name.."' loaded!");
  end
  CloseDropDownMenus(1);
end

local function CUM_SaveCustomTemplate(self)
  StaticPopup_Show("CU_SAVE_CUSTOM_TEMPLATE");
  CloseDropDownMenus(1);
end

local function CUM_ToggleMonitoredSpell(self,event,spellID)
  local spells = CU_Spells[event];
  if(spells)
  then
    -- Need to explicitly check for true/false in case we have a nil value
    if(spells[spellID] == true)
    then
      spells[spellID] = false;
    elseif(spells[spellID] == false)
    then
      spells[spellID] = true;
    end
  end
  CloseDropDownMenus(4);
end

local function CUM_AddNewSpell(self,event)
  local dialog = StaticPopup_Show("CU_ADD_NEW_SPELL",CU_SpellTypeToName[event]);
  if(dialog)
  then
    dialog.data = event;
    --self:GetParent():Hide();
  end
  CloseDropDownMenus(1);
end

local function CUM_SetMikSBT_ShowIcon(self,name,value,checked)
  local ctinfos = CU_GetCTInfos(name,value);
  if(ctinfos)
  then
    ctinfos.showIcon = checked;
  end
  CloseDropDownMenus(6);
end

local function CUM_SetMikSBT_IsCrit(self,name,value,checked)
  local ctinfos = CU_GetCTInfos(name,value);
  if(ctinfos)
  then
    ctinfos.isCrit = checked;
  end
  CloseDropDownMenus(6);
end

local function CUM_SetMikSBT_SetColor()
  local ctinfos = CU_GetCTInfos(CUM_CurrentAnnounceType,"msbt");
  if(ctinfos)
  then
    local r,g,b = ColorPickerFrame:GetColorRGB();
    ctinfos.r = r;
    ctinfos.g = g;
    ctinfos.b = b;
  end
end

local function CUM_SetMikSBT_CancelColor(previousValues)
  local ctinfos = CU_GetCTInfos(CUM_CurrentAnnounceType,"msbt");
  if(ctinfos)
  then
    ctinfos.r = previousValues.r / 255;
    ctinfos.g = previousValues.g / 255;
    ctinfos.b = previousValues.b / 255;
  end
end

local function CUM_SetMikSBT_Frame(self,name,fname)
  local ctinfos = CU_GetCTInfos(name,"msbt");
  if(ctinfos)
  then
    ctinfos.fname = fname;
  end
end

function CUM_OnLoad()
  HideDropDownMenu(1);
  CU_ConfigMenu.initialize = CUM_OnInitialize;
  CU_ConfigMenu.displayMode = "MENU";
  CU_ConfigMenu.name = "CD Used Config Menu";
end

function CUM_OnInitialize(frame,level)
  local info;
  -- If level 2
  if(level == 2)
  then
    CUM_CurrentAnnounceType = nil;
    if(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_ANNOUNCES)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_ANNOUNCES;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      for id in ipairs(CU_Config.Announce)
      do
        local name = CU_SpellTypeToName[id];
        if(name)
        then
          info = UIDropDownMenu_CreateInfo();
          info.text = name;
          info.value = CU_MENU_ANNOUNCES.."-"..id;
          info.hasArrow = 1;
          info.func = nil;
          info.notCheckable = 1;
          UIDropDownMenu_AddButton(info,level);
        end
      end
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_SPELLS)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_SPELLS;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      for id in ipairs(CU_Config.Announce)
      do
        local name = CU_SpellTypeToName[id];
        if(name)
        then
          info = UIDropDownMenu_CreateInfo();
          info.text = name;
          info.value = CU_MENU_SPELLS.."-"..id;
          info.hasArrow = 1;
          info.func = nil;
          info.notCheckable = 1;
          UIDropDownMenu_AddButton(info,level);
        end
      end
      -- Add templates button
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_SPELLS_TEMPLATES;
      info.hasArrow = 1;
      info.func = nil;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_ENABLES)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_ENABLES;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      local list = GA_GetTable();
      for name in pairs(CU_Config.Enables)
      do
        tinsert(list,name);
      end
      tsort(list,function(a,b) return a < b end);
      for _,name in ipairs(list)
      do
        local value = CU_Config.Enables[name];
        info = UIDropDownMenu_CreateInfo();
        info.text = name;
        info.value = value;
        info.arg1 = name;
        info.func = CUM_SetEnableType;
        info.checked = value;
        UIDropDownMenu_AddButton(info,level);
      end
      GA_ReleaseTable(list);
    elseif(UIDROPDOWNMENU_MENU_VALUE == FONT_SIZE)
    then
      -- Add the font heights from the font height table
      local value;
      for i=1, #CHAT_FONT_HEIGHTS
      do
        value = CHAT_FONT_HEIGHTS[i];
        info = UIDropDownMenu_CreateInfo();
        info.text = format(FONT_SIZE_TEMPLATE, value);
        info.value = value;
        info.arg1 = CU_ChatFrame;
        info.func = CU_SetChatWindowFontSize;
        local fontFile, fontHeight, fontFlags = CU_ChatFrame:GetFont();
        if ( value == floor(fontHeight+0.5) )
        then
          info.checked = 1;
        end
        UIDropDownMenu_AddButton(info,level);
      end
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_ALPHA_VALUE)
    then
      for i=0.1,1.0,0.1
      do
        info = UIDropDownMenu_CreateInfo();
        info.text = tostring(i*100).."%";
        info.arg1 = i;
        info.func = CU_SetChatWindowAlpha;
        if(i == CU_Config.Alpha)
        then
          info.checked = 1;
        end
        UIDropDownMenu_AddButton(info,level);
      end
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_MODULES)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_MODULES;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      
      for i,infos in ipairs(CU_Modules)
      do
        info = UIDropDownMenu_CreateInfo();
        info.text = infos.name;
        info.value = infos.name;
        info.arg1 = infos.name;
        info.arg2 = infos.enabled;
        info.func = CUM_SetModuleState;
        info.checked = infos.enabled;
        UIDropDownMenu_AddButton(info,level);
      end
    end
    return;
  -- If level 3
  elseif(level == 3)
  then
    local _,_,option,spell_type = strfind(UIDROPDOWNMENU_MENU_VALUE,"([^-]+)-(%d+)");
    if(option == nil or spell_type == nil)
    then
      if(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_SPELLS_TEMPLATES)
      then
        info = UIDropDownMenu_CreateInfo();
        info.text = CU_MENU_SPELLS_TEMPLATES;
        info.isTitle = true;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
        --
        info = UIDropDownMenu_CreateInfo();
        info.text = CU_MENU_SPELLS_TEMPLATES_LOAD_DEFAULT;
        info.hasArrow = 1;
        info.func = nil;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
        --
        info = UIDropDownMenu_CreateInfo();
        info.text = CU_MENU_SPELLS_TEMPLATES_LOAD_CUSTOM;
        info.hasArrow = 1;
        info.func = nil;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
        --
        info = UIDropDownMenu_CreateInfo();
        info.text = CU_MENU_SPELLS_TEMPLATES_SAVE_CUSTOM;
        info.func = CUM_SaveCustomTemplate;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
      end
      return;
    end
    spell_type = tonumber(spell_type);
    if(option == CU_MENU_ANNOUNCES and CU_Config.Announce[spell_type])
    then
      CUM_CurrentAnnounceType = spell_type;
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_SpellTypeToName[CUM_CurrentAnnounceType];
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      UIDropDownMenu_AddButton(CUM_CreateAnnounceMenuItem("self"),level);
      UIDropDownMenu_AddButton(CUM_CreateAnnounceMenuItem("party"),level);
      UIDropDownMenu_AddButton(CUM_CreateAnnounceMenuItem("raid"),level);
      UIDropDownMenu_AddButton(CUM_CreateAnnounceMenuItem("warning"),level);
      UIDropDownMenu_AddButton(CUM_CreateAnnounceMenuItem("custom"),level);

      if(CU_AllowCombatText[CUM_CurrentAnnounceType])
      then
        info = UIDropDownMenu_CreateInfo();
        info.text =  CU_MENU_COMBAT_TEXT;
        info.hasArrow = 1;
        info.func = nil;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
      end
    elseif(option == CU_MENU_SPELLS and CU_Spells[spell_type])
    then
      CUM_CurrentAnnounceType = spell_type;
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_SpellTypeToName[CUM_CurrentAnnounceType];
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      for spellID,enabled in pairs(CU_Spells[spell_type])
      do
        --
        info = UIDropDownMenu_CreateInfo();
        info.text =  GetSpellInfo(spellID);
        info.arg1 = CUM_CurrentAnnounceType;
        info.arg2 = spellID;
        info.checked = enabled;
        info.keepShownOnClick = true;
        info.func = CUM_ToggleMonitoredSpell;
        UIDropDownMenu_AddButton(info,level);
      end
      -- AddNewSpell button
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_ADD_SPELL;
      info.arg1 = CUM_CurrentAnnounceType;
      info.func = CUM_AddNewSpell;
      UIDropDownMenu_AddButton(info,level);
    end
    return;
  -- If level 4
  elseif(level == 4)
  then
    if(UIDROPDOWNMENU_MENU_VALUE == "self")
    then
      local chaninfos = CU_GetAnnounceInfos(CUM_CurrentAnnounceType,"self");
      info = UIDropDownMenu_CreateInfo();
      info.text =  "Self announce";
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      info = UIDropDownMenu_CreateInfo();
      info.text = "CD Used window";
      info.arg1 = CUM_CurrentAnnounceType;
      info.arg2 = "CU_ChatFrame";
      info.checked = chaninfos.fname == "CU_ChatFrame";
      info.func = CUM_SetAnnounceSelf;
      UIDropDownMenu_AddButton(info,level);

      local i = 1;
      local name = "ChatFrame"..i;
      while(getglobal(name))
      do
        info = UIDropDownMenu_CreateInfo();
        info.text = name;
        info.arg1 = CUM_CurrentAnnounceType;
        info.arg2 = name;
        info.checked = chaninfos.fname == name;
        info.func = CUM_SetAnnounceSelf;
        UIDropDownMenu_AddButton(info,level);
        i = i + 1;
        name = "ChatFrame"..i;
      end
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_COMBAT_TEXT)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_COMBAT_TEXT;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      UIDropDownMenu_AddButton(CUM_CreateCTMenuItem(CU_MENU_CT_BLIZZARD,"bct"),level);
      UIDropDownMenu_AddButton(CUM_CreateCTMenuItem(CU_MENU_CT_SCT,"sct"),level);
      UIDropDownMenu_AddButton(CUM_CreateCTMenuItem(CU_MENU_CT_MSBT,"msbt"),level);
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_SPELLS_TEMPLATES_LOAD_DEFAULT)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_SPELLS_TEMPLATES_LOAD_DEFAULT;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      --
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_SPELLS_TEMPLATES_DEFAULT_ALL;
      info.arg1 = CU_Template_All;
      info.arg2 = CU_MENU_SPELLS_TEMPLATES_DEFAULT_ALL;
      info.func = CUM_LoadDefaultTemplate;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      --
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_SPELLS_TEMPLATES_DEFAULT_TANK;
      info.arg1 = CU_Template_Tank;
      info.arg2 = CU_MENU_SPELLS_TEMPLATES_DEFAULT_TANK;
      info.func = CUM_LoadDefaultTemplate;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      --
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_SPELLS_TEMPLATES_DEFAULT_HEAL;
      info.arg1 = CU_Template_Heal;
      info.arg2 = CU_MENU_SPELLS_TEMPLATES_DEFAULT_HEAL;
      info.func = CUM_LoadDefaultTemplate;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      --
      info = UIDropDownMenu_CreateInfo();
      info.text = CU_MENU_SPELLS_TEMPLATES_DEFAULT_KICKER;
      info.arg1 = CU_Template_Kicker;
      info.arg2 = CU_MENU_SPELLS_TEMPLATES_DEFAULT_KICKER;
      info.func = CUM_LoadDefaultTemplate;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_SPELLS_TEMPLATES_LOAD_CUSTOM)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  CU_MENU_SPELLS_TEMPLATES_LOAD_CUSTOM;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      --
      for name in pairs(CU_SpellsTemplates)
      do
        info = UIDropDownMenu_CreateInfo();
        info.text = name;
        info.arg1 = name;
        info.func = CUM_LoadCustomTemplate;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info,level);
      end
    end
    return;
  -- If level 5
  elseif(level == 5)
  then
    if(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_CT_BLIZZARD)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  UIDROPDOWNMENU_MENU_VALUE;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

    
    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_CT_SCT)
    then
      info = UIDropDownMenu_CreateInfo();
      info.text =  UIDROPDOWNMENU_MENU_VALUE;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

    elseif(UIDROPDOWNMENU_MENU_VALUE == CU_MENU_CT_MSBT)
    then
      local ctinfos = CU_GetCTInfos(CUM_CurrentAnnounceType,"msbt");
      info = UIDropDownMenu_CreateInfo();
      info.text =  UIDROPDOWNMENU_MENU_VALUE;
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);

      -- Frame selection
      info = UIDropDownMenu_CreateInfo();
      info.text = "Frame";
      info.hasArrow = 1;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      -- ShowIcon
      info = UIDropDownMenu_CreateInfo();
      info.text = "Show Icon";
      info.arg1 = CUM_CurrentAnnounceType;
      info.arg2 = "msbt";
      info.checked = ctinfos.showIcon;
      info.keepShownOnClick = true;
      info.func = CUM_SetMikSBT_ShowIcon;
      UIDropDownMenu_AddButton(info,level);
      -- IsCrit
      info = UIDropDownMenu_CreateInfo();
      info.text = "IsCrit";
      info.arg1 = CUM_CurrentAnnounceType;
      info.arg2 = "msbt";
      info.checked = ctinfos.isCrit;
      info.keepShownOnClick = true;
      info.func = CUM_SetMikSBT_IsCrit;
      UIDropDownMenu_AddButton(info,level);
      -- Color selection
      info = UIDropDownMenu_CreateInfo();
      info.text = "Message color";
      info.arg1 = CUM_CurrentAnnounceType;
      info.notCheckable = 1;
      info.r = ctinfos.r;
      info.g = ctinfos.g;
      info.b = ctinfos.b;
      info.hasColorSwatch = true;
      info.swatchFunc = CUM_SetMikSBT_SetColor;
      info.cancelFunc = CUM_SetMikSBT_CancelColor;
      UIDropDownMenu_AddButton(info,level);
    end
    return;
  elseif(level == 6)
  then
    if(UIDROPDOWNMENU_MENU_VALUE == "Frame")
    then
      local ctinfos = CU_GetCTInfos(CUM_CurrentAnnounceType,"msbt");
      info = UIDropDownMenu_CreateInfo();
      info.text =  "Choose Frame";
      info.isTitle = true;
      info.notCheckable = 1;
      UIDropDownMenu_AddButton(info,level);
      
      for scrollAreaKey,scrollAreaName in MikSBT.IterateScrollAreas()
      do
        info = UIDropDownMenu_CreateInfo();
        info.text = scrollAreaName;
        info.arg1 = CUM_CurrentAnnounceType;
        info.arg2 = scrollAreaName;
        info.checked = ctinfos.fname == scrollAreaName;
        info.func = CUM_SetMikSBT_Frame;
        UIDropDownMenu_AddButton(info,level);
      end
    end
    return;
  end

  CUM_CurrentAnnounceType = nil;
  info = UIDropDownMenu_CreateInfo();
  info.text =  "CD Used Config Menu";
  info.isTitle = true;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text = CU_MENU_HIDE_MAIN_WINDOW;
  info.func = CUM_HideMainWindow;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);
  
  info = UIDropDownMenu_CreateInfo();
  info.text =  CU_MENU_ENABLES;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text =  CU_MENU_ANNOUNCES;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text = FONT_SIZE;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text = CU_ALPHA_VALUE;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text =  CU_MENU_SPELLS;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text =  CU_MENU_MODULES;
  info.hasArrow = 1;
  info.func = nil;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text = CANCEL;
  info.notCheckable = 1;
  info.func = CUM_Cancel_OnClick;
  UIDropDownMenu_AddButton(info);
end

function CUM_Cancel_OnClick()
  HideDropDownMenu(1);
end


--------------- Initialization functions ---------------

function CU_RegisterModule(name,initfunc,uninitfunc,callbacks)
  local infos = {};
  infos.name = name;
  infos.init = initfunc;
  infos.uninit = uninitfunc;
  infos.enabled = false;
  infos.callbacks = callbacks;
  tinsert(CU_Modules,infos);
end


CU_evFrame = CreateFrame("Frame");
-- Register events
CU_evFrame:RegisterEvent("VARIABLES_LOADED");
CU_evFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CU_evFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
CU_evFrame:SetScript("OnEvent",CU_OnEvent);

-- Initialize Slash commands
SLASH_CU1 = "/cu";
SlashCmdList["CU"] = function(msg)
  CU_Commands(msg);
end

CU_ChatPrint("Version "..CU_VERSION.." active! (/cu for help)");
