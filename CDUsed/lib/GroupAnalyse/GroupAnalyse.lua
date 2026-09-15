--[[
  Group Analyse by Kiki/Espêrance - European Cho'gall (Alliance) - Conseil des Ombres (Horde)
   
  Notes : 
    This addon should be used by all addons that hook the RAID_ROSTER_UPDATE event
   to retrieve raiders data using the GetRaidRosterInfo function.
   Calling this function in every addon lead to small freezes everytime a member joins/leaves/zones,
   while just reading data from a struct does not.
   All this because it takes much much less time to read a variable from a structure, than calling Blizzard functions.
  
  Usage :
   During the VARIABLES_LOADED event of your AddOn, call the GroupAnalyse.RegisterForEvents(callback_func) function.
   You must pass a "function" parameter, which will be called everytime :
    - A new member joins your group/raid        (GroupAnalyse.EVENT_MEMBER_JOINED event)
    - A member leaves your group/raid           (GroupAnalyse.EVENT_MEMBER_LEFT event)
    - Group mode has changed (solo-group-raid)  (GroupAnalyse.EVENT_GROUP_MODE_CHANGED event)
    - Loot mode has changed (solo-group-raid)   (GroupAnalyse.EVENT_LOOT_CHANGED event)
    - Members datas changed                     (GroupAnalyse.EVENT_INFOS_CHANGED event)
    - Members vital changed (life/power)        (GroupAnalyse.EVENT_VITAL_CHANGED event)
   The function prototype must be "function Callback_Func(event,param,subevent)"
   Event being one of the following event, and param being :
    - GroupAnalyse.EVENT_MEMBER_JOINED : Name of the new member
    - GroupAnalyse.EVENT_MEMBER_LEFT : Name of the leaving member
    - GroupAnalyse.EVENT_GROUP_MODE_CHANGED : New mode - One of GroupAnalyse.MODE_SOLO, GroupAnalyse.MODE_GROUP or GroupAnalyse.MODE_RAID
    - GroupAnalyse.EVENT_LOOT_CHANGED : New mode - One of GroupAnalyse.LOOT_xxx
    - GroupAnalyse.EVENT_INFOS_CHANGED : None
    - GroupAnalyse.EVENT_VITAL_CHANGED : Infos struct (see below), Sub-Event

   You can then globally access the GroupAnalyse.Members[] struct (indexed by members name) to retrieve group informations such as :
    - STRING name      : Unit's short name
    - STRING fullname  : Unit's full name (Name-Realm) in cross-server battlegrounds (equals to name out of BG, or from your realm) (BG RAID only)
    - STRING unitid    : UnitId, used by almost all unit functions like UnitHealth()
    - INT    rank      : Current group rank - 0=normal member, 1=raid assist, 2=group or raid leader
    - INT    subgrp    : Subgrp in raid mode. 1 if solo or in group
    - INT    level     : Level of the member
    - STRING class     : International class name of the member (like "PRIEST", "PALADIN", "DRUID"...)
    - STRING zone      : Current zone. Might be nil if not in raid
    - BOOL   online    : True if member is online, false otherwise
    - BOOL   isdead    : True if member is dead or in ghost form, false otherwise
    - BOOL   ischarmed : True if unit is charmed, false otherwise (not mind controlled)
    - STRING role      : Unit's role in the raid ("maintank", "mainassist", or "") (RAID only)
    - BOOL   isML      : True if unit is the master loot, false otherwise
    - INT    hp
    - INT    hpmax
    - INT    hppercent
    - INT    mp
    - INT    mpmax
    - INT    mppercent
    - INT    powertype
    - BOOL   ispet

  TODO :

 ChangeLog :
   - 2010/06/15 : (Version 3.6)
     - Added a new function: GA_DuplicateTable
   - 2010/01/04 : (Version 3.5)
     - Update ToC
     - Removed warning message
   - 2009/09/07 : (Version 3.4)
     - Attempt to fix an init error while in a raid group
   - 2009/08/02 : (Version 3.3)
     - Pets now have a correct subgrp value
   - 2009/07/09 : (Version 3.2)
     - isML is not valid in group and solo
     - Added GroupAnalyse.EVENT_LOOT_CHANGED event
     - Added GroupAnalyse.CurrentLootMode variable
   - 2009/06/06 : (Version 3.1)
     - Added a new variable: GroupAnalyse.SendChatMessageTarget
   - 2009/02/19 : (Version 3.0)
     - Updated ToC
     - File saved as UTF-8
   - 2009/02/19 : (Version 2.9)
     - Added GroupAnalyse.Count
   - 2009/01/20 : (Version 2.8)
     - Not registering a callback 'nil'
   - 2009/01/19 : (Version 2.7)
     - Added support for pets
   - 2008/12/19 : (Version 2.6)
     - Now using UnitPower/UnitPowerMax instead of UnitMana/UnitManaMax
     - Fixed EVENT_VITAL_CHANGED to support DK's RunicPower
     - Changed doc to indicate that GroupAnalyse.RegisterForEvents should be called during VARIABLES_LOADED event, instead of OnLoad of the addon
     - Now listening to UNIT_LEVEL event, and calling a GroupAnalyse.EVENT_INFOS_CHANGED event when unit level is known
     - Now always calling GroupAnalyse.EVENT_GROUP_MODE_CHANGED before GroupAnalyse.EVENT_MEMBER_JOINED when switching to party mode
   - 2008/07/22 : (Version 2.5)
     - Adding realtime vitals (hp/mp) calculation to GA infos
   - 2007/10/16 : (Version 2.4)
     - GA_ReleaseTable returns nil
   - 2007/08/31 : (Version 2.3)
     - Added new fields to the struct, to handle cross-realm bg, and new values in raid (masterLoot, maintank)
   - 2007/04/25 : (Version 2.2)
     - Great memory improvements (thanks to the new memory profiling tools)
     - Added table recycling functions
     - TOC update
   - 2007/01/31 : (Version 2.1)
     - Possibility to embed the addon
   - 2006/11/20 : (Version 2.0)
     - WoW 2.0 compatibility
     - Removed frame hooks
   - 2006/08/28 : (Version 1.4)
     - Updated TOC
     - Added a new global variable : GA_Myself
   - 2006/07/31 : (Version 1.3)
     - Added new frames to hook (thanks sarf)
   - 2006/07/19 :
     - Removed isfriend variable, and added ischarmed instead
   - 2006/05/29 : (Version 1.2)
     - Fixed possible lua error when zoning
     - Now hooking OnEvent function for known Frames that use the RAID_ROSTER_UPDATE event to call GetRaidRosterInfo (instead of relying on GroupAnalyse)
   - 2006/04/24 :
     - Now hooking GetRaidRosterInfo to reduce freezes. Addons calling this function should add an optionalDep to GroupAnalyse to insure accurate infos (if they don't want to use internal GA structs)
   - 2006/04/20 :
     - Fixed possible lua error
   - 2006/04/19 : 1.0
     - Module Created
]]


local GA_VERS = "3.6";

--------------- Version Check ---------------

local isBetterInstanceLoaded = ( GroupAnalyse and GroupAnalyse.version and GroupAnalyse.version >= GA_VERS );

if (not isBetterInstanceLoaded) then

if(not GroupAnalyse)
then
  GroupAnalyse = {};
end
GroupAnalyse.version = GA_VERS;


--------------- Shared Constantes ---------------

-- Events
GroupAnalyse.EVENT_GROUP_MODE_CHANGED = 1; -- Param = NewMode
GroupAnalyse.EVENT_MEMBER_JOINED = 2;      -- Param = Member Name;
GroupAnalyse.EVENT_MEMBER_LEFT = 3;        -- Param = Member Name;
GroupAnalyse.EVENT_INFOS_CHANGED = 4;
GroupAnalyse.EVENT_VITAL_CHANGED = 5;      -- Param = infos struct
GroupAnalyse.EVENT_LOOT_CHANGED = 6;       -- Param = NewMode
-- Sub-Events
GroupAnalyse.SUBEVENT_VITAL_CHANGED_HEALTH = 1;
GroupAnalyse.SUBEVENT_VITAL_CHANGED_POWER = 2;
GroupAnalyse.SUBEVENT_VITAL_CHANGED_POWER_TYPE = 3;
GroupAnalyse.SUBEVENT_VITAL_CHANGED_DEATH = 4;
GroupAnalyse.SUBEVENT_VITAL_CHANGED_CHARMED = 5;
GroupAnalyse.SUBEVENT_VITAL_CHANGED_ONLINE = 6;

-- Group Modes
GroupAnalyse.MODE_NONE = 0;
GroupAnalyse.MODE_SOLO = 1
GroupAnalyse.MODE_GROUP = 2
GroupAnalyse.MODE_RAID = 3;

-- Loot Modes
GroupAnalyse.LOOT_NONE = 0; -- Init mode
GroupAnalyse.LOOT_FFA = 1; -- "freeforall"
GroupAnalyse.LOOT_ROBIN = 2; -- "roundrobin"
GroupAnalyse.LOOT_MASTER = 3; -- "master"
GroupAnalyse.LOOT_GROUP = 4; -- "group"
GroupAnalyse.LOOT_NEED = 5; -- "needbeforegreed"


--------------- Shared variables ---------------

GroupAnalyse.PlayerName = nil;
GroupAnalyse.Members = {};
GroupAnalyse.MembersByID = {};
GroupAnalyse.CurrentGroupMode = GroupAnalyse.MODE_NONE;
GroupAnalyse.CurrentLootMode = GroupAnalyse.LOOT_NONE;
GroupAnalyse.SendChatMessageTarget = nil;
GroupAnalyse.Myself = nil;
GroupAnalyse.CurrentTime = 0;
GroupAnalyse.Count = 0;
GroupAnalyse.MasterLootID = nil;


--------------- Local Constantes ---------------

local GA_MAX_HEAL_UPDATES = 10; -- Keep max 10 incoming heal per raider


--------------- Local variables ---------------

local GA_Callbacks = {};
GroupAnalyse.Tables = {};
-- Optims
local tinsert = table.insert;
local tremove = table.remove;


--------------- Internal functions ---------------

function GroupAnalyse.ChatPrint(str,r,g,b)
  if(DEFAULT_CHAT_FRAME)
  then
    DEFAULT_CHAT_FRAME:AddMessage("GroupAnalyse : "..str, r or 1.0, g or 0.7, b or 0.15);
  end
end

local function _GA_CheckDeadOrGhost(infos)
  if(UnitIsDeadOrGhost(infos.unitid) and UnitIsFeignDeath(infos.unitid) == nil) -- Is dead
  then
    if(not infos.isdead) -- First detection
    then
      -- Dead
      infos.isdead = true;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_DEATH);
      end
    end
  else -- Not dead
    if(infos.isdead == true) -- First detection
    then
      -- Rezzed
      infos.isdead = false;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_DEATH);
      end
    end
  end
end

local function _GA_CheckCharmed(infos)
  if(UnitIsCharmed(infos.unitid)) -- Is charmed
  then
    if(not infos.ischarmed) -- First detection
    then
      -- Charmed
      infos.ischarmed = true;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_CHARMED);
      end
    end
  else -- Not charmed
    if(infos.ischarmed == true) -- First detection
    then
      -- Not charmed
      infos.ischarmed = false;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_CHARMED);
      end
    end
  end
end

local function _GA_CheckOnline(infos)
  if(UnitIsConnected(infos.unitid)) -- Is connected
  then
    if(not infos.online) -- First detection
    then
      -- Connected
      infos.online = true;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_ONLINE);
      end
    end
  else -- Not connected
    if(infos.online == true) -- First detection
    then
      -- Not charmed
      infos.online = false;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_ONLINE);
      end
    end
  end
end

local function _GA_GetUnitVitals(infos)
  infos.hp = UnitHealth(infos.unitid);
  infos.hpmax = UnitHealthMax(infos.unitid);
  if(infos.hpmax == 0)
  then
    infos.hp = 1;
    infos.hpmax = 1;
  end
  infos.mp = UnitPower(infos.unitid);
  infos.mpmax = UnitPowerMax(infos.unitid);
  if(infos.mpmax == 0)
  then
    infos.mp = 1;
    infos.mpmax = 1;
  end
  infos.powertype = UnitPowerType(infos.unitid);

  infos.hppercent = floor(infos.hp / infos.hpmax * 100);
  infos.mppercent = floor(infos.mp / infos.mpmax * 100);
end

local function _GA_GetUnitInfos(unitid,ispet,subgrp)
  local name = UnitName(unitid);
  local infos = GroupAnalyse.Members[name];
  if(infos == nil)
  then
    infos = GA_GetTable();
  end
  -- Fill infos
  infos.name = name;
  infos.ispet = ispet;
  infos.fullname = fullname;
  infos.unitid = unitid;
  if(UnitIsPartyLeader(unitid))
  then
    infos.rank = 2;
  else
    infos.rank = 0;
  end
  infos.subgrp = subgrp;
  infos.level = UnitLevel(unitid);
  _,infos.class = UnitClass(unitid);
  infos.zone = nil;
  infos.role = nil;
  infos.isML = false;
  _GA_GetUnitVitals(infos);
  if(infos.isdead == nil)
  then
    infos.isdead = false;
  end
  if(infos.online == nil)
  then
    infos.online = true;
  end
  if(infos.ischarmed == nil)
  then
    infos.ischarmed = false;
  end
  return name,infos;
end

local function _GA_AnalyseLootMode()
  local lootmethod,masterlooterPartyID,masterlooterRaidID = GetLootMethod();
  local new_mode = GroupAnalyse.LOOT_NONE;
  
  if(lootmethod == "freeforall")
  then
    new_mode = GroupAnalyse.LOOT_FFA;
  elseif(lootmethod == "roundrobin")
  then
    new_mode = GroupAnalyse.LOOT_ROBIN;
  elseif(lootmethod == "master")
  then
    new_mode = GroupAnalyse.LOOT_MASTER;
  elseif(lootmethod == "group")
  then
    new_mode = GroupAnalyse.LOOT_GROUP;
  elseif(lootmethod == "needbeforegreed")
  then
    new_mode = GroupAnalyse.LOOT_NEED;
  end

  if(new_mode == GroupAnalyse.LOOT_MASTER)
  then
    if(masterlooterRaidID)
    then
      GroupAnalyse.MasterLootID = "raid"..masterlooterRaidID;
    elseif(masterlooterPartyID)
    then
      if(masterlooterPartyID == 0) -- Myself
      then
        GroupAnalyse.MasterLootID = "player";
      else
        GroupAnalyse.MasterLootID = "party"..masterlooterPartyID;
      end
    else
      GroupAnalyse.MasterLootID = nil;
    end
  else
    GroupAnalyse.MasterLootID = nil;
  end
  
  if(GroupAnalyse.CurrentLootMode ~= new_mode)
  then
    for _,func in pairs(GA_Callbacks)
    do
      func(GroupAnalyse.EVENT_LOOT_CHANGED,newmode);
    end
    GroupAnalyse.CurrentLootMode = new_mode;
  end
end

local function _GA_AnalyseGroupMembers()
  local newmode = GroupAnalyse.MODE_NONE;
  local new_members = GA_GetTable();
  local raid_count = GetNumRaidMembers();
  local party_count;
  local name,rank,subgrp,level,_,class,zone,online,isdead,role,isml;
  local infos;
  local first_time = false;

  GA_WipeTable(GroupAnalyse.MembersByID);
  if(raid_count ~= 0) -- In a raid
  then
    GroupAnalyse.Count = raid_count;
    if(GroupAnalyse.CurrentGroupMode ~= GroupAnalyse.MODE_RAID) -- But was not
    then
      GroupAnalyseFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
      GroupAnalyseFrame:UnregisterEvent("UNIT_LEVEL");
    end
    newmode = GroupAnalyse.MODE_RAID;
    for i = 1, raid_count
    do
      fullname,rank,subgrp,level,localclass,class,zone,online,isdead,role,isml = GetRaidRosterInfo(i);
      if(fullname and (fullname ~= UNKNOWNOBJECT) and (fullname ~= UKNOWNBEING))
      then
        local id = "raid"..i;
        local name = UnitName(id);
        infos = GroupAnalyse.Members[name];
        if(infos == nil)
        then
          infos = GA_GetTable();
        end
        new_members[name] = infos;
        -- Fill infos
        infos.name = name;
        infos.fullname = fullname;
        infos.unitid = id;
        infos.rank = rank;
        infos.subgrp = subgrp;
        infos.level = level;
        infos.localclass = localclass;
        infos.class = class;
        infos.zone = zone;
        infos.role = role;
        if(isml) then
          infos.isML = true;
        else
          infos.isML = false;
        end
        _GA_GetUnitVitals(infos);
        if(infos.isdead == nil)
        then
          infos.isdead = false;
        end
        if(infos.online == nil)
        then
          infos.online = true;
        end
        if(infos.ischarmed == nil)
        then
          infos.ischarmed = false;
        end
        GroupAnalyse.MembersByID[id] = infos;
        -- Check for pet
        local petid = "raidpet"..i;
        if(UnitExists(petid))
        then
          name,infos = _GA_GetUnitInfos(petid,true,subgrp);
          new_members[name] = infos;
          GroupAnalyse.MembersByID[petid] = infos;
        end
      end
    end
  else -- Not in a RAID (in a group or solo)
    if(GroupAnalyse.CurrentGroupMode == GroupAnalyse.MODE_RAID) -- Was in a RAID
    then
      GroupAnalyseFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
      GroupAnalyseFrame:RegisterEvent("UNIT_LEVEL");
    end
    name,infos = _GA_GetUnitInfos("player",false,1);
    new_members[name] = infos;
    if(UnitExists("pet"))
    then
      name,infos = _GA_GetUnitInfos("pet",true,1);
      new_members[name] = infos;
      GroupAnalyse.MembersByID["pet"] = infos;
    end
    if(GroupAnalyse.CurrentLootMode == GroupAnalyse.LOOT_MASTER)
    then
      infos.isML = GroupAnalyse.MasterLootID == "player";
    else
      infos.isML = false;
    end
    party_count = GetNumPartyMembers();
    if(party_count ~= 0) -- In a group
    then
      GroupAnalyse.Count = party_count + 1;
      newmode = GroupAnalyse.MODE_GROUP;
      for i = 1,party_count
      do
        local id = "party"..i;
        name,infos = _GA_GetUnitInfos(id,false,1);
        new_members[name] = infos;
        GroupAnalyse.MembersByID[id] = infos;
        if(GroupAnalyse.CurrentLootMode == GroupAnalyse.LOOT_MASTER)
        then
          infos.isML = GroupAnalyse.MasterLootID == id;
        else
          infos.isML = false;
        end
        local petid = "partypet"..i;
        if(UnitExists(petid))
        then
          name,infos = _GA_GetUnitInfos(petid,true,1);
          new_members[name] = infos;
          GroupAnalyse.MembersByID[petid] = infos;
        end
      end
    else
      GroupAnalyse.Count = 1;
      newmode = GroupAnalyse.MODE_SOLO;
    end
  end

  if(GroupAnalyse.PlayerName == nil or new_members[GroupAnalyse.PlayerName] == nil) -- Fix for late init when in a raid group (sometimes when you log in, while in a raid, all members are not listed immediatly, it might happen for yourself)
  then
    --GroupAnalyse.ChatPrint("Init warning: "..tostring(GroupAnalyse.PlayerName).." - "..tostring(new_members[GroupAnalyse.PlayerName]),1,0,0);
    local name,infos = _GA_GetUnitInfos("player",false,1);
    new_members[name] = infos;
  end
  GroupAnalyse.Myself = new_members[GroupAnalyse.PlayerName];
  GroupAnalyse.MembersByID["player"] = GroupAnalyse.Myself;

  -- Remove old raiders
  for n,tab in pairs(GroupAnalyse.Members)
  do
    if(new_members[n] == nil) -- No longer in the raid
    then
      GA_ReleaseTable(GroupAnalyse.Members[n]);
      GroupAnalyse.Members[n] = nil;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_MEMBER_LEFT,n);
      end
    end
  end

  -- Notify group mode change, if any
  if(GroupAnalyse.CurrentGroupMode == GroupAnalyse.MODE_NONE) -- Init, check death status (other death checks are made during health updates)
  then
    first_time = true;
  end

  if(GroupAnalyse.CurrentGroupMode ~= newmode)
  then
    for _,func in pairs(GA_Callbacks)
    do
      func(GroupAnalyse.EVENT_GROUP_MODE_CHANGED,newmode);
    end
  end
  GroupAnalyse.CurrentGroupMode = newmode;
  if(GroupAnalyse.CurrentGroupMode == GroupAnalyse.MODE_RAID)
  then
    GroupAnalyse.SendChatMessageTarget = "RAID";
  elseif(GroupAnalyse.CurrentGroupMode == GroupAnalyse.MODE_GROUP)
  then
    GroupAnalyse.SendChatMessageTarget = "PARTY";
  else
    GroupAnalyse.SendChatMessageTarget = nil;
  end

  -- Add new raiders
  for n,tab in pairs(new_members)
  do
    local raider = GroupAnalyse.Members[n];
    if(raider == nil) -- New member
    then
      GroupAnalyse.Members[n] = tab;
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_MEMBER_JOINED,n);
      end
    end
  end

  -- Notify some infos has changed
  for _,func in pairs(GA_Callbacks)
  do
    func(GroupAnalyse.EVENT_INFOS_CHANGED);
  end

  -- Check death status
  for id,infos in pairs(GroupAnalyse.MembersByID)
  do
    if(first_time)
    then
      _GA_CheckDeadOrGhost(infos);
    end
    _GA_CheckCharmed(infos);
    _GA_CheckOnline(infos);
  end

  GA_ReleaseTable(new_members);
end


--------------- Shared functions ---------------

function GroupAnalyse.RegisterForEvents(callback_func)
  if(callback_func == nil)
  then
    error("GroupAnalyse.RegisterForEvents: Trying to register a nil CB function");
  end
  tinsert(GA_Callbacks,callback_func);

  if(GroupAnalyse.CurrentGroupMode ~= GroupAnalyse.MODE_NONE) -- Late initialization
  then
    callback_func(GroupAnalyse.EVENT_GROUP_MODE_CHANGED,GroupAnalyse.CurrentGroupMode);
    for n in pairs(GroupAnalyse.Members)
    do
      callback_func(GroupAnalyse.EVENT_MEMBER_JOINED,n);
    end
    callback_func(GroupAnalyse.EVENT_INFOS_CHANGED);

    callback_func(GroupAnalyse.EVENT_LOOT_CHANGED,GroupAnalyse.CurrentLootMode);
  end
end

function GroupAnalyse.UnRegisterForEvents(callback_func)
  if(callback_func == nil)
  then
    error("GroupAnalyse.UnRegisterForEvents: Trying to unregister a nil CB function");
  end
  for i,v in ipairs(GA_Callbacks)
  do
    if(v == callback_func)
    then
      tremove(GA_Callbacks,i);
      return;
    end
  end
end


--------------- Event function ---------------

function GroupAnalyse.OnEvent(self,event,...)
  -- Unit events
  if(event == "UNIT_COMBAT")
  then
    local unitid,dmg_type,_,value = select(1,...);
    --local dmg_type = select(2,...);
    --local value = select(4,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      if(dmg_type == "WOUND")
      then
        infos.hp = infos.hp - value;
        if(infos.hp <= 0) then infos.hp = 1; end
      elseif(dmg_type == "HEAL")
      then
        infos.hp = infos.hp + value;
        if(infos.hp > infos.hpmax) then infos.hp = infos.hpmax; end
      else
        return;
      end
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_HEALTH);
      end
    end
    return;
  -- Health/Mana events
  elseif(event == "UNIT_HEALTH")
  then
    local unitid = select(1,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      infos.hp = UnitHealth(unitid);
      infos.hppercent = floor(infos.hp / infos.hpmax * 100);
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_HEALTH);
      end
      _GA_CheckDeadOrGhost(infos);
    end
    return;
  elseif(event == "UNIT_MAXHEALTH")
  then
    local unitid = select(1,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      infos.hpmax = UnitHealthMax(unitid);
      if(infos.hpmax == 0)
      then
        infos.hp = 1;
        infos.hp_real = 1;
        infos.hpmax = 1;
      end
      infos.hppercent = floor(infos.hp / infos.hpmax * 100);
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_HEALTH);
      end
    end
    return;
  elseif(event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_ENERGY" or event == "UNIT_RUNIC_POWER" or event == "UNIT_FOCUS")
  then
    local unitid = select(1,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      infos.mp = UnitPower(unitid);
      infos.mppercent = floor(infos.mp / infos.mpmax * 100);
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_POWER);
      end
    end
    return;
  elseif(event == "UNIT_MAXMANA" or event == "UNIT_MAXRAGE" or event == "UNIT_MAXENERGY" or event == "UNIT_MAXRUNIC_POWER" or event == "UNIT_MAXFOCUS")
  then
    local unitid = select(1,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      infos.mpmax = UnitPowerMax(unitid);
      if(infos.mpmax == 0)
      then
        infos.mpmax = 1;
      end
      infos.mppercent = floor(infos.mp / infos.mpmax * 100);
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_POWER);
      end
    end
    return;
  elseif(event == "UNIT_DISPLAYPOWER")
  then
    local unitid = select(1,...);
    local infos = GroupAnalyse.MembersByID[unitid];
    if(infos)
    then
      infos.powertype = UnitPowerType(unitid);
      -- Update Mana and ManaMax to handle druid shapeshift
      infos.mp = UnitPower(unitid);
      infos.mpmax = UnitPowerMax(unitid);
      if(infos.mpmax == 0)
      then
        infos.mpmax = 1;
      end
      infos.mppercent = floor(infos.mp / infos.mpmax * 100);
      for _,func in pairs(GA_Callbacks)
      do
        func(GroupAnalyse.EVENT_VITAL_CHANGED,infos,GroupAnalyse.SUBEVENT_VITAL_CHANGED_POWER_TYPE);
      end
    end
    return;
  
  -- Group events
  elseif(event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE")
  then
    _GA_AnalyseLootMode();
    _GA_AnalyseGroupMembers();
  elseif(event == "VARIABLES_LOADED")
  then
    GroupAnalyse.PlayerName = UnitName("player");
    GroupAnalyseFrame:Show();
  elseif(event == "PLAYER_ENTERING_WORLD")
  then
    _GA_AnalyseLootMode();
    _GA_AnalyseGroupMembers();
  elseif(event == "UNIT_LEVEL")
  then
    local unitid = select(1,...);
    if(unitid)
    then
      _GA_AnalyseGroupMembers();
    end
  end
end

function GroupAnalyse.OnUpdate(self,dt)
  GroupAnalyse.CurrentTime = GroupAnalyse.CurrentTime + dt;
end


--------------- GroupAnalyse Main Frame ---------------

  --Event Driver
  if(not GroupAnalyseFrame)
  then
    CreateFrame("Frame", "GroupAnalyseFrame");
  end
  --Event Registration
  GroupAnalyseFrame:RegisterEvent("VARIABLES_LOADED");
  GroupAnalyseFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
  GroupAnalyseFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
  GroupAnalyseFrame:RegisterEvent("UNIT_LEVEL");
  GroupAnalyseFrame:RegisterEvent("RAID_ROSTER_UPDATE");
  GroupAnalyseFrame:RegisterEvent("UNIT_COMBAT");
  GroupAnalyseFrame:RegisterEvent("UNIT_HEALTH");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXHEALTH");
  GroupAnalyseFrame:RegisterEvent("UNIT_MANA");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXMANA");
  GroupAnalyseFrame:RegisterEvent("UNIT_RAGE");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXRAGE");
  GroupAnalyseFrame:RegisterEvent("UNIT_ENERGY");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXENERGY");
  GroupAnalyseFrame:RegisterEvent("UNIT_FOCUS");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXFOCUS");
  GroupAnalyseFrame:RegisterEvent("UNIT_RUNIC_POWER");
  GroupAnalyseFrame:RegisterEvent("UNIT_MAXRUNIC_POWER");
  GroupAnalyseFrame:RegisterEvent("UNIT_DISPLAYPOWER");
  --Frame Scripts
  GroupAnalyseFrame:SetScript("OnEvent", GroupAnalyse.OnEvent);
  GroupAnalyseFrame:SetScript("OnUpdate", GroupAnalyse.OnUpdate);
  GroupAnalyseFrame:Show();
  -- Print init message
  GroupAnalyse.ChatPrint("Version "..GA_VERS.." Loaded !");

end -- not isBetterInstanceLoaded

--------------- Table recycling functions ---------------

function GA_WipeTable(t1,recurseCount)
  if(type(t1) ~= "table")
  then
    if(t1 == nil)
    then
      return GA_GetTable();
    end
    return t1;
  end

  for k,v in pairs(t1)
  do
    if(recurseCount and (recurseCount > 0) and (type(v) == "table")) -- Recurse release table
    then
      GA_ReleaseTable(v,recurseCount-1);
    end
    t1[k] = nil;
  end

  return t1;
end

function GA_GetTable()
  local recTable;
  if(#GroupAnalyse.Tables >= 1)
  then
    recTable = tremove(GroupAnalyse.Tables);
  else
    recTable = {};
  end
  return recTable;
end

function GA_ReleaseTable(t1,recurseCount)
  if(type(t1) ~= "table")
  then
    return;
  end
  
  for k,v in pairs(t1)
  do
    if(recurseCount and (recurseCount > 0) and (type(v) == "table")) -- Recurse release table
    then
      GA_ReleaseTable(v,recurseCount-1);
    end
    t1[k] = nil;
  end
  
  tinsert(GroupAnalyse.Tables,t1);
  return nil;
end

function GA_DuplicateTable(t1)
  if(type(t1) ~= "table")
  then
    return nil;
  end
  local newtab = GA_GetTable();
  for n,v in pairs(t1)
  do
    if(type(v) == "table") -- recurs dup
    then
      newtab[n] = GA_DuplicateTable(v);
    else
      newtab[n] = v;
    end
  end
  return newtab;
end

