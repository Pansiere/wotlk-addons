--[[
  Cooldown Used by Kiki/Espêrance - European Conseil des Ombres
   Kick plugin
  
  TODO:
   - affiche le CD de tous les joueurs qui ont un kick dispo (qu'on puisse trier par classe)
   - affiche le CD de tous les joueurs qui ont des sorts a CD (qu'on puisse filtrer, par classe, par nom, etc)
   - pouvoir mettre plusieurs sorts par classe
   - afficher une icone quand le joueur a reussi un interrupt
   - ajouter arcane torrent en detectant la classe et le type de power de chaque joueur


  BUGS:
   - 


]]

---------------------------------------------------------
-- Constantes
---------------------------------------------------------

local CU_KICK_SORT_NONE = 0;
local CU_KICK_SORT_AVAILABLE = 1;

---------------------------------------------------------
-- Variables
---------------------------------------------------------

local CU_Kick_MonitoredClass = {
  ["PALADIN"] = {
    { spellID = 10308, cooldown = 60, }, -- Hammer of Justice
  },
  ["ROGUE"] = {
    { spellID = 1766, cooldown = 10, }, -- Kick
  },
  ["WARRIOR"] = {
    { spellID = 72, cooldown = 12, }, -- Shield Bash
    { spellID = 6552, cooldown = 10, }, -- Pummel
  },
  ["SHAMAN"] = {
    { spellID = 57994, cooldown = 6, }, -- Wind Shear
  },
  ["MAGE"] = {
    { spellID = 2139, cooldown = 24, }, -- Counterspell
  },
  ["DEATHKNIGHT"] = {
    { spellID = 47528, cooldown = 10, }, -- Mind Freeze
  },
  --[[["DRUID"] = {
    { spellID = 49802, cooldown = 10, }, -- Maim
  },]]
};
local CU_Kick_Timers = {};
local CU_Kick_Ignored = {};

local CU_Kick_CurrentTime = 0;
local CU_Kick_LastTimeGUI = 0;
local CU_Kick_SortMode = CU_KICK_SORT_NONE;

local strformat = string.format;
local tinsert = table.insert;
local tremove = table.remove;
local tsort = table.sort;

---------------------------------------------------------
-- Status Frames
---------------------------------------------------------

local function CU_Kick_SetSparkPos(prefix,percent)
  local statusbar = getglobal(prefix.."StatusBar");
  if(statusbar)
  then
    local bar_len = statusbar:GetWidth(); -- Add value if increased length
    getglobal(prefix.."StatusBarSpark"):SetPoint("CENTER", getglobal(prefix.."StatusBar"),"LEFT",percent*bar_len/100,0);
  end
end

local function CU_Kick_EnableBars(enabled)
  local i = 1;
  for _,infos in ipairs(CU_Kick_Timers)
  do
    prefix = "CUK_Bar"..i;
    bar = getglobal(prefix);
    if(enabled)
    then
      bar:EnableMouse("true");
    else
      bar:EnableMouse("false");
    end
    i = i + 1;
  end
end

function CU_Kick_Anchor_OnClick(self,button)
  if(button == "LeftButton")
  then
    if(self:GetChecked())
    then
      -- Set unmovable
      self:GetParent().locked = true;
      -- Disable bars
      CU_Kick_EnableBars(false);
    else
      -- Set movable
      self:GetParent().locked = false;
      -- Enable bars
      CU_Kick_EnableBars(true);
    end
  elseif(button == "RightButton")
  then
    ToggleDropDownMenu(1,nil,CU_Kick_ConfigMenu,"cursor");
  end
end

function CU_Kick_SizeChanged(self,width,height)
  getglobal(self:GetName().."StatusBar"):SetWidth(width-6);
  getglobal(self:GetName().."Border"):SetWidth(width);
  getglobal(self:GetName().."Text"):SetWidth(width-6);
  CU_Kick_SetSparkPos(self:GetName(),100);
end

local function CU_Kick_CreateFrame(name,anchor,id)
  local frame = CreateFrame("Frame",name,nil,"CU_Kick_BarTemplate");
  frame:ClearAllPoints();
  frame:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,-2);
  frame:SetWidth(80);
  frame:SetID(id);
  if(CU_Anchor.locked)
  then
    frame:EnableMouse("false");
  else
    frame:EnableMouse("true");
  end
  return frame;
end

local function CU_Kick_UpdateBars()
  local prefix;
  local percent;
  local remain;
  local divider;
  local bar;
  local tim = GetTime();
  local i = 1;

  -- Update bars
  for _,infos in ipairs(CU_Kick_Timers)
  do
    prefix = "CUK_Bar"..i;
    bar = getglobal(prefix);
    divider = infos.EndTime - infos.StartTime;
    percent = 100 - ((tim - infos.StartTime) / divider * 100);
    remain = infos.EndTime - tim;
    if(divider == 0 or percent < 0 or percent > 100)
    then
      percent = 0;
      remain = 0;
    end
    local r_col;
    local g_col;
    local pct = percent / 100;
    if(percent > 50)
    then
      r_col = 1.0;
      g_col = (1.0 - pct) * 2;
    else
      r_col = pct * 2;
      g_col = 1.0;
    end
    local statusbar = getglobal(prefix.."StatusBar");
    local bartext = getglobal(prefix.."Text");
    if(bar.name == nil) -- First set
    then
      bar.name = infos.name;
      -- Set Icon if available
      if(getglobal(prefix.."Icon"))
      then
        getglobal(prefix.."Icon"):SetTexture(infos.texture);
      end
    end
    -- Set time text, if available
    local timetext = getglobal(prefix.."TimeText");
    if(timetext)
    then
      if(remain == 0)
      then
        timetext:SetText("Rdy");
      elseif(remain >= 10)
      then
        timetext:SetText(strformat("%d s",remain));
      else
        timetext:SetText(strformat("%.1f s",remain));
      end
      timetext:SetTextColor(r_col,g_col,0.1);
      if(bartext)
      then
        getglobal(prefix.."Text"):SetText(infos.name);
      end
    end
    if(statusbar)
    then
      statusbar:SetValue(percent);
      statusbar:SetStatusBarColor(r_col,g_col,0.1,1);
    end
    CU_Kick_SetSparkPos(prefix,percent);
    i = i + 1;
  end
end

local function CU_Kick_ResetBarName()
  for i in ipairs(CU_Kick_Timers)
  do
    local frame = getglobal("CUK_Bar"..i);
    frame.name = nil;
  end
end

local function CU_Kick_HideRemainingBars()
  local i = #CU_Kick_Timers + 1;
  local frame = getglobal("CUK_Bar"..i);
  while(frame)
  do
    frame.name = nil;
    frame:Hide();
    i = i + 1;
    frame = getglobal("CUK_Bar"..i);
  end
end


---------------------------------------------------------
-- Timer functions
---------------------------------------------------------

local function CU_Kick_CreateKicker(name,spellID,cooldown,r,g,b)
  local old_count = #CU_Kick_Timers;
  local new_count = old_count + 1;
  local fname = "CUK_Bar"..new_count;
  local frame = getglobal(fname);
  if(frame == nil) -- Must create the frame
  then
    local anchor;
    if(new_count == 1) -- First frame
    then
      anchor = "CU_Anchor";
    else
      anchor = "CUK_Bar"..old_count;
    end
    frame = CU_Kick_CreateFrame(fname,anchor,new_count);
  end
  local infos = GA_GetTable();
  infos.name = name;
  infos.r = r or 0.2;
  infos.g = g or 0.9;
  infos.b = b or 0.1;
  infos.spellID = spellID;
  infos.texture = select(3,GetSpellInfo(spellID));
  infos.StartTime = GetTime();
  infos.EndTime = infos.StartTime;
  infos.Cooldown = cooldown;
  tinsert(CU_Kick_Timers,infos);
  frame:Show();
  CU_Kick_UpdateBars();
end

local function CU_Kick_RemoveKicker(name)
  for i,infos in ipairs(CU_Kick_Timers)
  do
    if(infos.name == name)
    then
      local inf = infos;
      tremove(CU_Kick_Timers,i);
      GA_ReleaseTable(inf);
      CU_Kick_ResetBarName();
      CU_Kick_HideRemainingBars();
      CU_Kick_UpdateBars();
      return;
    end
  end
end

local function CU_Kick_Sort_Available(a,b)
  return a.EndTime < b.EndTime;
end

local function CU_Kick_CheckSorting()
  if(CU_Kick_SortMode == CU_KICK_SORT_AVAILABLE)
  then
    tsort(CU_Kick_Timers,CU_Kick_Sort_Available);
  end
end

local function CU_Kick_StartCooldown(name,spellID)
  local must_refresh = false;
  for i,infos in ipairs(CU_Kick_Timers)
  do
    if(infos.name == name and infos.spellID == spellID)
    then
      infos.name = name;
      infos.StartTime = GetTime();
      infos.EndTime = infos.StartTime + infos.Cooldown;
      must_refresh = true;
    end
  end
  if(must_refresh)
  then
    CU_Kick_CheckSorting();
    CU_Kick_UpdateBars(); -- Update bars now
  end
end

function CU_Kick_SetSorting(mode)
  if(CU_Kick_SortMode ~= mode)
  then
    CU_Kick_SortMode = mode;
    CU_Kick_CheckSorting();
    CU_Kick_UpdateBars();
  end
end

---------------------------------------------------------
-- Callbacks
---------------------------------------------------------

local function CU_Kick_SpellInterrupt(sourceName,destName,spellID,spellName)
  CU_Kick_StartCooldown(sourceName,spellID);
end

local function CU_Kick_SpellMissed(sourceName,destName,spellID,spellName,missType)
  CU_Kick_StartCooldown(sourceName,spellID);
end

local function CU_Kick_GACB(event,param,subevent)
  if(event == GroupAnalyse.EVENT_MEMBER_JOINED)
  then
    local infos = GroupAnalyse.Members[param];
    if(not infos.ispet)
    then
      local kick_infos = CU_Kick_MonitoredClass[infos.class];
      if(kick_infos)
      then
        for _,infos in ipairs(kick_infos)
        do
          CU_Kick_CreateKicker(param,infos.spellID,infos.cooldown);
        end
      end
    end
  elseif(event == GroupAnalyse.EVENT_MEMBER_LEFT)
  then
    CU_Kick_RemoveKicker(param);
  end
end

---------------------------------------------------------
-- Config Menu
---------------------------------------------------------

function CU_Kick_ConfigMenu_OnLoad(self)
  HideDropDownMenu(1);
  self.initialize = CU_Kick_ConfigMenu_OnInitialize;
  self.displayMode = "MENU";
  self.name = "Titre";
end

function CU_Kick_ConfigMenu_OnInitialize(frame,level)
  info = UIDropDownMenu_CreateInfo();
  info.text =  "Kick Module Config";
  info.isTitle = true;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  -- Sub menu, ignored kickers

  -- Sub menu, sort type
  
  info = UIDropDownMenu_CreateInfo();
  info.text = CANCEL;
  info.notCheckable = 1;
  info.func = CU_KickM_Cancel_OnClick;
  UIDropDownMenu_AddButton(info);
end

function CU_KickM_Cancel_OnClick()
  HideDropDownMenu(1);
end

---------------------------------------------------------
-- Kicker Menu
---------------------------------------------------------

local function CU_KickM_IgnoreKicker(self,kicker,id)
  tinsert(CU_Kick_Ignored,kicker);
  tremove(CU_Kick_Timers,id);
  -- Update bars
  CU_Kick_ResetBarName();
  CU_Kick_HideRemainingBars();
  CU_Kick_UpdateBars();
end

local function CU_KickM_MoveUp(self,kicker,id)
  CU_Kick_Timers[id] = CU_Kick_Timers[id-1];
  CU_Kick_Timers[id-1] = kicker;
  -- Update bars
  CU_Kick_ResetBarName();
  CU_Kick_UpdateBars();
end

local function CU_KickM_MoveDown(self,kicker,id)
  CU_Kick_Timers[id] = CU_Kick_Timers[id+1];
  CU_Kick_Timers[id+1] = kicker;
  -- Update bars
  CU_Kick_ResetBarName();
  CU_Kick_UpdateBars();
end

function CU_Kick_KickerMenu_OnLoad(self)
  HideDropDownMenu(1);
  self.initialize = CU_Kick_KickerMenu_OnInitialize;
  self.displayMode = "MENU";
  self.name = "Titre";
end

function CU_Kick_KickerMenu_OnInitialize(frame,level)
  local kicker = CU_Kick_Timers[UIDROPDOWNMENU_MENU_VALUE];

  info = UIDropDownMenu_CreateInfo();
  info.text =  kicker.name;
  info.isTitle = true;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text = "Ignore kicker";
  info.arg1 = kicker;
  info.arg2 = UIDROPDOWNMENU_MENU_VALUE;
  info.func = CU_KickM_IgnoreKicker;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);
  
  info = UIDropDownMenu_CreateInfo();
  info.text =  "Move up";
  info.arg1 = kicker;
  info.arg2 = UIDROPDOWNMENU_MENU_VALUE;
  info.func = CU_KickM_MoveUp;
  info.disabled = UIDROPDOWNMENU_MENU_VALUE <= 1;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  info = UIDropDownMenu_CreateInfo();
  info.text =  "Move down";
  info.arg1 = kicker;
  info.arg2 = UIDROPDOWNMENU_MENU_VALUE;
  info.func = CU_KickM_MoveDown;
  info.disabled = UIDROPDOWNMENU_MENU_VALUE >= #CU_Kick_Timers;
  info.notCheckable = 1;
  UIDropDownMenu_AddButton(info);

  -- Sub menu, ignored kickers

  -- Other options
  
  info = UIDropDownMenu_CreateInfo();
  info.text = CANCEL;
  info.notCheckable = 1;
  info.func = CU_KickM_Cancel_OnClick;
  UIDropDownMenu_AddButton(info);
end

---------------------------------------------------------
-- Main Frame
---------------------------------------------------------

local CU_Kick_Callbacks = {
  [CU_SPELLS_INTERRUPT_USED_SUCCESS] = CU_Kick_SpellInterrupt,
  [CU_SPELLS_INTERRUPT_USED_FAILED] = CU_Kick_SpellMissed,
};

function CU_Kick_OnUpdate(self,elapsed)
  CU_Kick_CurrentTime = CU_Kick_CurrentTime + elapsed;

  -- Update GUI every 0.10 sec
  if(CU_Kick_CurrentTime > (CU_Kick_LastTimeGUI+0.10))
  then
    CU_Kick_UpdateBars();
    CU_Kick_LastTimeGUI = CU_Kick_CurrentTime;
  end
end

local function CU_Kick_EnableModule()
  if(CU_Config.Modules["Kick"] == nil)
  then
    CU_Config.Modules["Kick"] = {};
  end
  GroupAnalyse.RegisterForEvents(CU_Kick_GACB);
  CU_KickMainFrame:Show();
  CU_Anchor:Show();
  -- Set unmovable
  CU_AnchorButton:SetChecked(1);
  CU_Anchor.locked = true;
  -- Disable bars
  CU_Kick_EnableBars(false);
  CU_Anchor.locked = true;
end

local function CU_Kick_DisableModule()
  GroupAnalyse.UnRegisterForEvents(CU_Kick_GACB);
  while(CU_Kick_Timers[1])
  do
    CU_Kick_RemoveKicker(CU_Kick_Timers[1].name);
  end
  CU_KickMainFrame:Hide();
  CU_Anchor:Hide();
end

CU_RegisterModule("Kick",CU_Kick_EnableModule,CU_Kick_DisableModule,CU_Kick_Callbacks);

--CUK_Bar1:SetMovable(1);
