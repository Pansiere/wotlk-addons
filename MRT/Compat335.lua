local _, _, _, uiVersion = GetBuildInfo()
uiVersion = tonumber(uiVersion) or 0
local IS_WOTLK_335 = (uiVersion > 0 and uiVersion <= 30300)
if not IS_WOTLK_335 then
  return
end
local _G = _G
local type = type
local tonumber = tonumber
local tostring = tostring
local select = select
local unpack = unpack
local tinsert = table.insert
local function EnsureTable(globalName)
  local t = _G[globalName]
  if type(t) ~= "table" then
    t = {}
    _G[globalName] = t
  end
  return t
end
if type(wipe) ~= "function" then
  function wipe(t)
    if type(t) == "table" then
      for k in pairs(t) do
        t[k] = nil
      end
    end
    return t
  end
end
if type(table.wipe) ~= "function" then
  table.wipe = wipe
end
if type(CopyTable) ~= "function" then
  function CopyTable(src, deep)
    if type(src) ~= "table" then
      return src
    end
    local dst = {}
    for k, v in pairs(src) do
      if deep and type(v) == "table" then
        dst[k] = CopyTable(v, true)
      else
        dst[k] = v
      end
    end
    return dst
  end
end
if type(strtrim) ~= "function" then
  function strtrim(s)
    if type(s) ~= "string" then
      return s
    end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
  end
end
if type(string.trim) ~= "function" then
  string.trim = strtrim
end
if type(Ambiguate) ~= "function" then
  function Ambiguate(name)
    if type(name) ~= "string" then
      return name
    end
    return (name:match("^([^%-]+)") or name)
  end
end
if type(UnitFullName) ~= "function" then
  function UnitFullName(unit)
    local name, realm = UnitName(unit)
    if realm and realm ~= "" then
      return name, realm
    end
    return name, (GetRealmName and GetRealmName() or nil)
  end
end

if type(UnitNameUnmodified) ~= "function" then
  function UnitNameUnmodified(unit)
    return UnitName(unit)
  end
end
if type(securecallfunction) ~= "function" then
  local function _forward(ok, ...)
    if ok then
      return ...
    end
    local handler = type(geterrorhandler) == "function" and geterrorhandler() or nil
    if handler then
      handler(...)
    end
  end
  function securecallfunction(func, ...)
    if type(func) ~= "function" then
      return
    end
    return _forward(pcall(func, ...))
  end
end
do
  if type(LibStub) == "table" and type(LibStub.libs) == "table"
     and type(debug) == "table"
     and type(debug.getupvalue) == "function"
     and type(debug.setupvalue) == "function" then
    local lib = LibStub.libs["CallbackHandler-1.0"]
    if type(lib) == "table" and type(lib.New) == "function" then
      for i = 1, 64 do
        local name, val = debug.getupvalue(lib.New, i)
        if not name then break end
        if name == "Dispatch" and type(val) == "function" then
          for j = 1, 64 do
            local n2, v2 = debug.getupvalue(val, j)
            if not n2 then break end
            if n2 == "securecallfunction" and v2 == nil and type(securecallfunction) == "function" then
              debug.setupvalue(val, j, securecallfunction)
            end
          end
          break
        end
      end
    end
  end
end
if type(UnitSpellHaste) ~= "function" then
  function UnitSpellHaste(unit)
    if unit == "player" and type(GetCombatRatingBonus) == "function" then
      return GetCombatRatingBonus(20) or 0
    end
    return 0
  end
end
local function _strsplitMaxSplitsOK()
  if type(strsplit) ~= "function" then
    return false
  end
  local ok, n = pcall(function()
    return select("#", strsplit(":", "a:b:c:d", 2))
  end)
  return ok and n == 2
end
if not _strsplitMaxSplitsOK() then
  function strsplit(delim, str, maxSplits)
    if type(delim) ~= "string" or delim == "" then
      return str
    end
    if type(str) ~= "string" then
      return str
    end
    maxSplits = tonumber(maxSplits)
    if maxSplits and maxSplits <= 0 then
      maxSplits = nil
    end
    if maxSplits == 1 then
      return str
    end
    local results = {}
    local pattern = "(.-)" .. delim
    local n = 0
    local lastPos = 1
    while true do
      local s, e, cap = str:find(pattern, lastPos)
      if not s then
        break
      end
      n = n + 1
      results[n] = cap
      lastPos = e + 1
      if maxSplits and n >= maxSplits - 1 then
        break
      end
    end
    n = n + 1
    results[n] = str:sub(lastPos)
    return unpack(results, 1, n)
  end
end
if type(GetNumSubgroupMembers) ~= "function" then
  function GetNumSubgroupMembers()
    return (GetNumPartyMembers and GetNumPartyMembers() or 0)
  end
end
if type(GetNumGroupMembers) ~= "function" then
  function GetNumGroupMembers()
    local raid = (GetNumRaidMembers and GetNumRaidMembers() or 0)
    if raid and raid > 0 then
      return raid
    end
    return (GetNumPartyMembers and GetNumPartyMembers() or 0)
  end
end
if type(IsInRaid) ~= "function" then
  function IsInRaid()
    return (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0
  end
end
if type(IsInGroup) ~= "function" then
  function IsInGroup(category)

    if category == 2 then
      return false
    end
    return (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 or (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0
  end
end
if _G.LE_PARTY_CATEGORY_INSTANCE == nil then
  _G.LE_PARTY_CATEGORY_INSTANCE = 2
end
if type(UnitGetTotalAbsorbs) ~= "function" then
  function UnitGetTotalAbsorbs()
    return 0
  end
end
if type(UnitGetTotalHealAbsorbs) ~= "function" then
  function UnitGetTotalHealAbsorbs()
    return 0
  end
end
if type(Mixin) ~= "function" then
  function Mixin(object, ...)
    for i = 1, select("#", ...) do
      local m = select(i, ...)
      if type(m) == "table" then
        for k, v in pairs(m) do
          object[k] = v
        end
      end
    end
    return object
  end
end
if type(CreateFromMixins) ~= "function" then
  function CreateFromMixins(...)
    return Mixin({}, ...)
  end
end
if type(CreateAndInitFromMixin) ~= "function" then
  function CreateAndInitFromMixin(mixin, ...)
    local object = CreateFromMixins(mixin)
    if type(object.OnLoad) == "function" then
      object:OnLoad(...)
    end
    return object
  end
end
if type(_G.GetClassInfo) ~= "function" then
  local classIDToToken = {
    [1]  = "WARRIOR",
    [2]  = "PALADIN",
    [3]  = "HUNTER",
    [4]  = "ROGUE",
    [5]  = "PRIEST",
    [6]  = "DEATHKNIGHT",
    [7]  = "SHAMAN",
    [8]  = "MAGE",
    [9]  = "WARLOCK",
    [11] = "DRUID",
  }
  local localized
  local function buildLocalized()
    if localized then return localized end
    localized = {}
    if type(_G.LocalizedClassList) == "function" then
      local ok, list = pcall(_G.LocalizedClassList)
      if ok and type(list) == "table" then
        for k, v in pairs(list) do localized[k] = v end
      end
    end
    if type(_G.FillLocalizedClassList) == "function" then
      pcall(_G.FillLocalizedClassList, localized)
    end
    if type(_G.LOCALIZED_CLASS_NAMES_MALE) == "table" then
      for k, v in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do
        if localized[k] == nil then localized[k] = v end
      end
    end
    return localized
  end
  function _G.GetClassInfo(classID)
    local token = classIDToToken[classID]
    if not token then
      return nil
    end
    local name = buildLocalized()[token] or token
    return name, token, classID
  end
end
if type(_G.DebugPrint) ~= "function" then
  function _G.DebugPrint(...)
    if not _G.MRT_VERBOSE_DEBUG then return end
    local parts = {}
    for i = 1, select("#", ...) do
      local v = select(i, ...)
      parts[i] = tostring(v)
    end
    print("|cff80ff80[DebugPrint]|r " .. table.concat(parts, " "))
  end
end
if type(_G.ObjectPoolMixin) ~= "table" then
  local ObjectPoolMixin = {}
  function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc)
    self.creationFunc = creationFunc
    self.resetterFunc = resetterFunc
    self.activeObjects = {}
    self.inactiveObjects = {}
    self.numActiveObjects = 0
  end
  function ObjectPoolMixin:Acquire()
    local n = #self.inactiveObjects
    if n > 0 then
      local obj = self.inactiveObjects[n]
      self.inactiveObjects[n] = nil
      self.activeObjects[obj] = true
      self.numActiveObjects = self.numActiveObjects + 1
      return obj, false
    end
    local newObj = self.creationFunc(self)
    if self.resetterFunc and not self.disallowResetIfNew then
      self.resetterFunc(self, newObj)
    end
    self.activeObjects[newObj] = true
    self.numActiveObjects = self.numActiveObjects + 1
    return newObj, true
  end
  function ObjectPoolMixin:Release(obj)
    if self.activeObjects[obj] then
      self.inactiveObjects[#self.inactiveObjects + 1] = obj
      self.activeObjects[obj] = nil
      self.numActiveObjects = self.numActiveObjects - 1
      if self.resetterFunc then
        self.resetterFunc(self, obj)
      end
      return true
    end
    return false
  end
  function ObjectPoolMixin:ReleaseAll()
    for obj in pairs(self.activeObjects) do
      self:Release(obj)
    end
  end
  function ObjectPoolMixin:SetResetDisallowedIfNew(disallowed)
    self.disallowResetIfNew = disallowed
  end
  function ObjectPoolMixin:EnumerateActive()
    return pairs(self.activeObjects)
  end
  function ObjectPoolMixin:GetNextActive(current)
    return (next(self.activeObjects, current))
  end
  function ObjectPoolMixin:GetNextInactive(current)
    return (next(self.inactiveObjects, current))
  end
  function ObjectPoolMixin:IsActive(obj)
    return self.activeObjects[obj] ~= nil
  end
  function ObjectPoolMixin:GetNumActive()
    return self.numActiveObjects
  end
  function ObjectPoolMixin:EnumerateInactive()
    return ipairs(self.inactiveObjects)
  end
  _G.ObjectPoolMixin = ObjectPoolMixin
end

if type(_G.CreateObjectPool) ~= "function" then
  function _G.CreateObjectPool(creationFunc, resetterFunc)
    local pool = CreateFromMixins(_G.ObjectPoolMixin)
    pool:OnLoad(creationFunc, resetterFunc)
    return pool
  end
end
if type(_G.FramePoolMixin) ~= "table" then
  local FramePoolMixin = CreateFromMixins(_G.ObjectPoolMixin)
  local function FramePoolFactory(framePool)
    return CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate)
  end
  function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc, _forbidden, frameInitFunc)
    local creationFunc = FramePoolFactory
    if type(frameInitFunc) == "function" then
      creationFunc = function(framePool)
        local frame = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate)
        frameInitFunc(frame)
        return frame
      end
    end
    _G.ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc)
    self.frameType = frameType
    self.parent = parent
    self.frameTemplate = frameTemplate
  end
  function FramePoolMixin:GetTemplate()
    return self.frameTemplate
  end
  _G.FramePoolMixin = FramePoolMixin
end

if type(_G.FramePool_Hide) ~= "function" then
  function _G.FramePool_Hide(framePool, frame)
    if frame and frame.Hide then frame:Hide() end
  end
end
if type(_G.FramePool_HideAndClearAnchors) ~= "function" then
  function _G.FramePool_HideAndClearAnchors(framePool, frame)
    if frame and frame.Hide then frame:Hide() end
    if frame and frame.ClearAllPoints then frame:ClearAllPoints() end
  end
end

if type(_G.CreateFramePool) ~= "function" then
  function _G.CreateFramePool(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
    local pool = CreateFromMixins(_G.FramePoolMixin)
    pool:OnLoad(frameType, parent, frameTemplate, resetterFunc or _G.FramePool_HideAndClearAnchors, forbidden, frameInitFunc)
    return pool
  end
end
if type(_G.TexturePoolMixin) ~= "table" then
  local TexturePoolMixin = CreateFromMixins(_G.ObjectPoolMixin)
  local function TexturePoolFactory(texturePool)
    return texturePool.parent:CreateTexture(nil, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer)
  end
  function TexturePoolMixin:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc)
    _G.ObjectPoolMixin.OnLoad(self, TexturePoolFactory, resetterFunc)
    self.parent = parent
    self.layer = layer
    self.subLayer = subLayer
    self.textureTemplate = textureTemplate
  end
  _G.TexturePoolMixin = TexturePoolMixin
end
if type(_G.TexturePool_Hide) ~= "function" then
  function _G.TexturePool_Hide(texturePool, texture)
    if texture and texture.Hide then texture:Hide() end
  end
end
if type(_G.TexturePool_HideAndClearAnchors) ~= "function" then
  function _G.TexturePool_HideAndClearAnchors(texturePool, texture)
    if texture and texture.Hide then texture:Hide() end
    if texture and texture.ClearAllPoints then texture:ClearAllPoints() end
  end
end
if type(_G.CreateTexturePool) ~= "function" then
  function _G.CreateTexturePool(parent, layer, subLayer, textureTemplate, resetterFunc)
    local pool = CreateFromMixins(_G.TexturePoolMixin)
    pool:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc or _G.TexturePool_HideAndClearAnchors)
    return pool
  end
end
if type(ColorMixin) ~= "table" then
  ColorMixin = {}
  function ColorMixin:OnLoad(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function ColorMixin:GetRGB()
    return self.r, self.g, self.b
  end
  function ColorMixin:GetRGBA()
    return self.r, self.g, self.b, self.a
  end
  function ColorMixin:GetRGBAsBytes()
    return (self.r or 0) * 255, (self.g or 0) * 255, (self.b or 0) * 255
  end
  function ColorMixin:GetRGBAAsBytes()
    return (self.r or 0) * 255, (self.g or 0) * 255, (self.b or 0) * 255, (self.a or 1) * 255
  end
  function ColorMixin:SetRGBA(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function ColorMixin:SetRGB(r, g, b)
    self:SetRGBA(r, g, b, nil)
  end
  function ColorMixin:IsEqualTo(other)
    return type(other) == "table"
      and self.r == other.r and self.g == other.g
      and self.b == other.b and self.a == other.a
  end
  function ColorMixin:GenerateHexColor()
    return ("ff%.2x%.2x%.2x"):format(self:GetRGBAsBytes())
  end
  function ColorMixin:GenerateHexColorMarkup()
    return "|c" .. self:GenerateHexColor()
  end
  function ColorMixin:WrapTextInColorCode(text)
    return ("|c%s%s|r"):format(self:GenerateHexColor(), text or "")
  end
end
if type(CreateColor) ~= "function" then
  function CreateColor(r, g, b, a)
    local c = CreateFromMixins(ColorMixin)
    c:OnLoad(r, g, b, a)
    return c
  end
end
if type(CreateColorFromBytes) ~= "function" then
  function CreateColorFromBytes(r, g, b, a)
    return CreateColor((r or 0) / 255, (g or 0) / 255, (b or 0) / 255, (a or 0) / 255)
  end
end
if type(WrapTextInColorCode) ~= "function" then
  function WrapTextInColorCode(text, hex)
    return ("|c%s%s|r"):format(hex or "ffffffff", text or "")
  end
end
do
  local sample = (UIParent or CreateFrame("Frame")):CreateTexture()
  local mt = sample and getmetatable(sample)
  local index = mt and mt.__index
  if type(index) == "table" then
    local nativeSetGradient = index.SetGradient
    local nativeSetGradientAlpha = index.SetGradientAlpha or nativeSetGradient
    if type(nativeSetGradient) == "function" then
      index.SetGradient = function(self, orientation, a, b, c, d, e, f, g, h)
        if type(a) == "table" and type(b) == "table" then
          local minR, minG, minB, minA = a.r or 1, a.g or 1, a.b or 1, a.a or 1
          local maxR, maxG, maxB, maxA = b.r or 1, b.g or 1, b.b or 1, b.a or 1
          if nativeSetGradientAlpha and nativeSetGradientAlpha ~= nativeSetGradient then
            return nativeSetGradientAlpha(self, orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
          end
          return nativeSetGradient(self, orientation, minR, minG, minB, maxR, maxG, maxB)
        end
        return nativeSetGradient(self, orientation, a, b, c, d, e, f, g, h)
      end
    end
    if type(index.SetGradientAlpha) == "function" and index.SetGradientAlpha ~= index.SetGradient then
      local nativeSGA = index.SetGradientAlpha
      index.SetGradientAlpha = function(self, orientation, a, b, c, d, e, f, g, h)
        if type(a) == "table" and type(b) == "table" then
          local minR, minG, minB, minA = a.r or 1, a.g or 1, a.b or 1, a.a or 1
          local maxR, maxG, maxB, maxA = b.r or 1, b.g or 1, b.b or 1, b.a or 1
          return nativeSGA(self, orientation, minR, minG, minB, minA, maxR, maxG, maxB, maxA)
        end
        return nativeSGA(self, orientation, a, b, c, d, e, f, g, h)
      end
    end
  end
end
if type(FormatLargeNumber) ~= "function" then
  function FormatLargeNumber(amount)
    local sep = LARGE_NUMBER_SEPERATOR or ","
    local s = tostring(amount or 0)
    local sign, digits = s:match("^(%-?)(%d+)$")
    if not digits then
      return s
    end
    local out = digits:reverse():gsub("(%d%d%d)", "%1" .. sep)
    out = out:reverse()
    if out:sub(1, #sep) == sep then
      out = out:sub(#sep + 1)
    end
    return sign .. out
  end
end
if type(BreakUpLargeNumbers) ~= "function" then
  BreakUpLargeNumbers = FormatLargeNumber
end
if type(UnitIsGroupLeader) ~= "function" then
  function UnitIsGroupLeader(unit)
    if type(unit) ~= "string" or unit == "" then
      return false
    end
    if (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 then
      local targetName = UnitName(unit)
      if not targetName then return false end
      for i = 1, GetNumRaidMembers() do
        local name, rank = GetRaidRosterInfo(i)
        if name == targetName then
          return (rank or 0) >= 2
        end
      end
      return false
    end
    if unit == "player" then
      if type(IsPartyLeader) == "function" then
        return IsPartyLeader() and true or false
      end
      return false
    end
    if type(UnitIsPartyLeader) == "function" then
      return UnitIsPartyLeader(unit) and true or false
    end
    return false
  end
end
if type(UnitIsGroupAssistant) ~= "function" then
  function UnitIsGroupAssistant(unit)
    if type(unit) ~= "string" or unit == "" then
      return false
    end
    if (GetNumRaidMembers and GetNumRaidMembers() or 0) == 0 then
      return false
    end
    local targetName = UnitName(unit)
    if not targetName then return false end
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == targetName then
        return (rank or 0) == 1
      end
    end
    return false
  end
end
local C_AddOns = EnsureTable("C_AddOns")
if type(C_AddOns.IsAddOnLoaded) ~= "function" then
  function C_AddOns.IsAddOnLoaded(name)
    if type(IsAddOnLoaded) == "function" then
      return IsAddOnLoaded(name)
    end
    return false
  end
end
if type(C_AddOns.GetAddOnMetadata) ~= "function" then
  function C_AddOns.GetAddOnMetadata(name, field)
    if type(GetAddOnMetadata) == "function" then
      return GetAddOnMetadata(name, field)
    end
  end
end
if type(C_AddOns.LoadAddOn) ~= "function" then
  function C_AddOns.LoadAddOn(name)
    if type(LoadAddOn) == "function" then
      return LoadAddOn(name)
    end
  end
end
local C_DateAndTime = EnsureTable("C_DateAndTime")
if type(C_DateAndTime.GetTodaysDate) ~= "function" then
  function C_DateAndTime.GetTodaysDate()
    local t = date("*t")
    return { year = t.year, month = t.month, day = t.day, weekday = t.wday }
  end
end
if type(C_DateAndTime.GetCurrentCalendarTime) ~= "function" then
  function C_DateAndTime.GetCurrentCalendarTime()
    local t = date("*t")
    return {
      year = t.year,
      month = t.month,
      monthDay = t.day,
      weekday = t.wday,
      hour = t.hour,
      minute = t.min,
    }
  end
end
if type(C_DateAndTime.GetServerTime) ~= "function" then
  function C_DateAndTime.GetServerTime()
    return time()
  end
end
local C_InstanceEncounter = EnsureTable("C_InstanceEncounter")
local _MRT_inEncounter = false
function _G.MRT_SetEncounterFlag(v) _MRT_inEncounter = v and true or false end
function _G.MRT_GetEncounterFlag() return _MRT_inEncounter end
if type(_G.IsEncounterInProgress) ~= "function" then
  function _G.IsEncounterInProgress()
    return _MRT_inEncounter
  end
end
if type(C_InstanceEncounter.IsEncounterInProgress) ~= "function" then
  C_InstanceEncounter.IsEncounterInProgress = _G.IsEncounterInProgress
end


local C_ChallengeMode = EnsureTable("C_ChallengeMode")
if type(C_ChallengeMode.IsChallengeModeActive) ~= "function" then
  function C_ChallengeMode.IsChallengeModeActive()
    return false
  end
end
if type(C_ChallengeMode.GetActiveChallengeMapID) ~= "function" then
  function C_ChallengeMode.GetActiveChallengeMapID()
    return nil
  end
end


local C_Spell = EnsureTable("C_Spell")
if type(C_Spell.GetSpellInfo) ~= "function" then
  function C_Spell.GetSpellInfo(spellID)
    local name, rank, icon, castTime, minRange, maxRange, sid = GetSpellInfo(spellID)
    if (not name or not icon) and ExRT and ExRT.F and ExRT.F.GetSpellInfoSafe then
      local n2, r2, t2 = ExRT.F.GetSpellInfoSafe(spellID)
      name = name or n2
      rank = rank or r2
      icon = icon or t2
    end
    if not name then
      return nil
    end
    return {
      name = name,
      rank = rank,
      iconID = icon,
      originalIconID = icon,
      castTime = castTime,
      minRange = minRange,
      maxRange = maxRange,
      spellID = sid or spellID,
    }
  end
end
if type(C_Spell.GetSpellCooldown) ~= "function" then
  function C_Spell.GetSpellCooldown(spellID)
    local startTime, duration, isEnabled = GetSpellCooldown(spellID)
    if startTime == nil then
      return nil
    end
    return {
      startTime = startTime or 0,
      duration = duration or 0,
      isEnabled = isEnabled or 0,
      modRate = 1,
    }
  end
end
if type(C_Spell.GetSpellCharges) ~= "function" then
  function C_Spell.GetSpellCharges()

    return nil
  end
end
if type(C_Spell.GetSpellLink) ~= "function" then
  function C_Spell.GetSpellLink(spellID)
    if type(GetSpellLink) == "function" then
      return GetSpellLink(spellID)
    end
  end
end
if type(C_Spell.GetSpellTexture) ~= "function" then
  function C_Spell.GetSpellTexture(spellID)
    if ExRT and ExRT.F and ExRT.F.GetSpellTextureSafe then
      local tex = ExRT.F.GetSpellTextureSafe(spellID)
      if tex and tex ~= "Interface\\Icons\\INV_Misc_QuestionMark" then
        return tex
      end
    end
    if type(GetSpellTexture) == "function" then
      return GetSpellTexture(spellID)
    end
  end
end
if type(C_Spell.GetSpellName) ~= "function" then
  function C_Spell.GetSpellName(spellID)
    if ExRT and ExRT.F and ExRT.F.GetSpellInfoSafe then
      local name = ExRT.F.GetSpellInfoSafe(spellID)
      if name then return name end
    end
    local name = GetSpellInfo(spellID)
    return name
  end
end
if type(C_Spell.GetSpellLevelLearned) ~= "function" then
  function C_Spell.GetSpellLevelLearned()
    return 1
  end
end


if type(_G.GetSpellCharges) ~= "function" then
  function _G.GetSpellCharges()
    return nil, nil, nil, nil
  end
end


if type(_G.SetRaidTargetIcon) ~= "function" and type(_G.SetRaidTarget) == "function" then
  function _G.SetRaidTargetIcon(unit, index)
    return _G.SetRaidTarget(unit, index)
  end
end
if type(_G.ClearRaidMarker) ~= "function" then
  function _G.ClearRaidMarker()

  end
end
local C_ChatInfo = EnsureTable("C_ChatInfo")
local _SendChatMessage = SendChatMessage
if type(_SendChatMessage) == "function" then

  function C_ChatInfo.SendChatMessage(msg, chatType, language, channel)
    if chatType == "INSTANCE_CHAT" then
      chatType = "PARTY"
    end
    return _SendChatMessage(msg, chatType, language, channel)
  end
end

local _SendAddonMessage = SendAddonMessage
if type(_SendAddonMessage) == "function" then
  function C_ChatInfo.SendAddonMessage(prefix, msg, channel, target)
    if channel == "INSTANCE_CHAT" then
      channel = "PARTY"
    end
    return _SendAddonMessage(prefix, msg, channel, target)
  end
end

if type(C_ChatInfo.RegisterAddonMessagePrefix) ~= "function" then
  function C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    if type(RegisterAddonMessagePrefix) == "function" then
      return RegisterAddonMessagePrefix(prefix)
    end

    return true
  end
end
if type(SendChatMessage) == "function" and (not ChatTypeInfo or not ChatTypeInfo.INSTANCE_CHAT) then
  local __origSendChatMessage = SendChatMessage
  function SendChatMessage(msg, chatType, language, channel)
    if chatType == "INSTANCE_CHAT" then
      chatType = "PARTY"
    end
    if type(msg) == "string" then
      msg = msg:gsub("(item:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+):[%-%d:]+(|h)", "%1%2")
      if msg:find("|Hitem:") then
        msg = msg:gsub("(|H(item:[%-:%d]+)|h)([^%[])", function(full, itemStr, tail)
          local name, _, quality = GetItemInfo(itemStr)
          local _, _, _, color = GetItemQualityColor(quality or 1)
          color = color or "ff9d9d9d"
          return "|c"..color..full.."["..(name or "item").."]|h|r"..tail
        end)
        msg = msg:gsub("(|H(item:[%-:%d]+)|h)$", function(full, itemStr)
          local name, _, quality = GetItemInfo(itemStr)
          local _, _, _, color = GetItemQualityColor(quality or 1)
          color = color or "ff9d9d9d"
          return "|c"..color..full.."["..(name or "item").."]|h|r"
        end)
      end
    end
    return __origSendChatMessage(msg, chatType, language, channel)
  end
end
if type(SendAddonMessage) == "function" then
  local __origSendAddonMessage = SendAddonMessage
  function SendAddonMessage(prefix, msg, channel, target)
    if channel == "INSTANCE_CHAT" then
      channel = "PARTY"
    end
    return __origSendAddonMessage(prefix, msg, channel, target)
  end
end
local C_Timer = EnsureTable("C_Timer")
if type(C_Timer.After) ~= "function"
   or type(C_Timer.NewTimer) ~= "function"
   or type(C_Timer.NewTicker) ~= "function" then

  local timerFrame = CreateFrame("Frame")
  local timers = {}
  local ticking = false

  local function OnUpdate(self, elapsed)
    for i = #timers, 1, -1 do
      local t = timers[i]
      if not t.cancelled then
        t.elapsed = t.elapsed + elapsed
        if t.elapsed >= t.delay then
          t.elapsed = t.elapsed - t.delay
          t.fired = (t.fired or 0) + 1
          local fire = t._fire or t.func
          local ok, err = pcall(fire, t)
          if not ok then

            if type(geterrorhandler) == "function" then
              geterrorhandler()(err)
            else
              print(err)
            end
          end

          if t.iterations and t.fired >= t.iterations then
            t.cancelled = true
          end
          if t.once then
            t.cancelled = true
          end
        end
      end

      if t.cancelled then
        table.remove(timers, i)
      end
    end

    if #timers == 0 then
      self:Hide()
      ticking = false
    end
  end

  timerFrame:SetScript("OnUpdate", OnUpdate)
  timerFrame:Hide()

  local function AddTimer(delay, func, iterations, once)
    delay = tonumber(delay) or 0
    if delay < 0 then
      delay = -delay
    end
    local t = {
      delay = delay,
      elapsed = 0,
      iterations = iterations,
      once = once,
      cancelled = false,
    }
    t._fire = func
    t.func = func
    function t:Cancel()
      self.cancelled = true
    end
    tinsert(timers, t)
    if not ticking then
      ticking = true
      timerFrame:Show()
    end
    return t
  end

  if type(C_Timer.After) ~= "function" then
    function C_Timer.After(delay, func)
      if type(func) ~= "function" then
        return
      end
      return AddTimer(delay, function() func() end, 1, true)
    end
  end

  if type(C_Timer.NewTimer) ~= "function" then
    function C_Timer.NewTimer(delay, func)
      if type(func) ~= "function" then
        return AddTimer(delay or 0, function() end, 1, true)
      end
      return AddTimer(delay, function() func() end, 1, true)
    end
  end

  if type(C_Timer.NewTicker) ~= "function" then
    function C_Timer.NewTicker(delay, func, iterations)
      if type(func) ~= "function" then
        return AddTimer(delay or 0, function() end, iterations, false)
      end
      return AddTimer(delay, func, iterations, false)
    end
  end
end
local C_Item = EnsureTable("C_Item")
if type(GetItemInfoInstant) ~= "function" then
  function GetItemInfoInstant(item)
    if not item then
      return
    end
    local itemID
    if type(item) == "number" then
      itemID = item
    elseif type(item) == "string" then
      itemID = item:match("item:(%d+)")
      itemID = tonumber(itemID)
      if not itemID then
        itemID = tonumber(item)
      end
    end
    if not itemID then
      return
    end

    return itemID
  end
end
if type(C_Item.GetItemInfo) ~= "function" then
  C_Item.GetItemInfo = GetItemInfo
end
if type(C_Item.GetItemInfoInstant) ~= "function" then
  C_Item.GetItemInfoInstant = GetItemInfoInstant
end
if type(C_Item.GetItemSpell) ~= "function" then
  C_Item.GetItemSpell = GetItemSpell
end
if type(C_Item.GetItemQualityColor) ~= "function" then
  C_Item.GetItemQualityColor = GetItemQualityColor
end
local C_CVar = EnsureTable("C_CVar")
if type(C_CVar.GetCVar) ~= "function" and type(GetCVar) == "function" then
  C_CVar.GetCVar = GetCVar
end
if type(C_CVar.SetCVar) ~= "function" and type(SetCVar) == "function" then
  C_CVar.SetCVar = SetCVar
end
local C_UnitAuras = EnsureTable("C_UnitAuras")
if type(C_UnitAuras.GetAuraDataByIndex) ~= "function" then
  function C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, index, filter)
    if not name then
      return nil
    end
    return {
      name = name,
      icon = icon,
      applications = count,
      debuffType = debuffType,
      duration = duration,
      expirationTime = expirationTime,
      sourceUnit = unitCaster,
      isStealable = isStealable,
      spellId = spellId,

      auraInstanceID = nil,
      points = nil,
    }
  end
end
if type(C_UnitAuras.GetAuraDataByAuraInstanceID) ~= "function" then
  function C_UnitAuras.GetAuraDataByAuraInstanceID()
    return nil
  end
end
local C_PvP = EnsureTable("C_PvP")
if type(C_PvP.IsWarModeDesired) ~= "function" then
  function C_PvP.IsWarModeDesired()
    return false
  end
end

if type(_G.SOUNDKIT) ~= "table" then
	_G.SOUNDKIT = {}
end
if _G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON == nil then
	_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON = "igMainMenuOptionCheckBoxOn"
end
if _G.SOUNDKIT.IG_CHARACTER_INFO_OPEN == nil then
	_G.SOUNDKIT.IG_CHARACTER_INFO_OPEN = "igCharacterInfoOpen"
end
local C_GuildInfo = EnsureTable("C_GuildInfo")
if type(C_GuildInfo.GuildRoster) ~= "function" then
  function C_GuildInfo.GuildRoster()
    if type(GuildRoster) == "function" then
      return GuildRoster()
    end
  end
end
local C_FriendList = EnsureTable("C_FriendList")
if type(C_FriendList.GetNumFriends) ~= "function" then
  function C_FriendList.GetNumFriends()
    return (GetNumFriends and GetNumFriends() or 0)
  end
end
if type(C_FriendList.GetFriendInfoByIndex) ~= "function" then
  function C_FriendList.GetFriendInfoByIndex(index)
    if type(GetFriendInfo) ~= "function" then
      return nil
    end
    local name, level, class, area, connected, status, note = GetFriendInfo(index)
    if not name then
      return nil
    end
    return {
      name = name,
      level = level,
      className = class,
      area = area,
      connected = connected,
      status = status,
      notes = note,
    }
  end
end

local C_BattleNet = EnsureTable("C_BattleNet")
if type(C_BattleNet.GetFriendAccountInfo) ~= "function" then
  function C_BattleNet.GetFriendAccountInfo()
    return nil
  end
end
if type(C_BattleNet.GetFriendNumGameAccounts) ~= "function" then
  function C_BattleNet.GetFriendNumGameAccounts()
    return 0
  end
end
if type(C_BattleNet.GetFriendGameAccountInfo) ~= "function" then
  function C_BattleNet.GetFriendGameAccountInfo()
    return nil
  end
end
local C_PartyInfo = EnsureTable("C_PartyInfo")
if type(C_PartyInfo.InviteUnit) ~= "function" then
  C_PartyInfo.InviteUnit = InviteUnit
end
if type(C_PartyInfo.ConvertToRaid) ~= "function" then
  C_PartyInfo.ConvertToRaid = ConvertToRaid
end
if type(C_PartyInfo.GetLootMethod) ~= "function" then
  C_PartyInfo.GetLootMethod = GetLootMethod
end
if type(C_PartyInfo.SetLootMethod) ~= "function" then
  C_PartyInfo.SetLootMethod = SetLootMethod
end
if type(C_PartyInfo.GetInviteReferralInfo) ~= "function" then
  function C_PartyInfo.GetInviteReferralInfo()
    return nil
  end
end
if type(C_PartyInfo.DoCountdown) ~= "function" then
  function C_PartyInfo.DoCountdown()

  end
end
local C_NamePlate = EnsureTable("C_NamePlate")
if type(C_NamePlate.GetNamePlateForUnit) ~= "function" then
  function C_NamePlate.GetNamePlateForUnit()
    return nil
  end
end

local C_Map = EnsureTable("C_Map")
if type(C_Map.GetBestMapForUnit) ~= "function" then
  function C_Map.GetBestMapForUnit()
    return nil
  end
end
if type(C_Map.GetMapInfo) ~= "function" then
  local WOTLK_MAP_NAMES = {
    [249] = "Onyxia's Lair",
    [409] = "Molten Core",
    [469] = "Blackwing Lair",
    [509] = "Ruins of Ahn'Qiraj",
    [531] = "Temple of Ahn'Qiraj",
    [533] = "Naxxramas",
    [532] = "Karazhan",
    [544] = "Magtheridon's Lair",
    [548] = "Serpentshrine Cavern",
    [550] = "Tempest Keep: The Eye",
    [565] = "Gruul's Lair",
    [568] = "Zul'Aman",
    [580] = "The Sunwell",
    [534] = "Hyjal Summit",
    [564] = "Black Temple",
    [309] = "Zul'Gurub",
    [615] = "The Obsidian Sanctum",
    [616] = "The Eye of Eternity",
    [603] = "Ulduar",
    [649] = "Trial of the Crusader",
    [631] = "Icecrown Citadel",
    [724] = "The Ruby Sanctum",
    [624] = "Vault of Archavon",
    [232] = "Icecrown Citadel",
    [287] = "Ulduar",
    [319] = "Trial of the Crusader",
    [331] = "Onyxia's Lair",
    [330] = "Vault of Archavon",
    [162] = "Naxxramas",
    [155] = "The Obsidian Sanctum",
    [141] = "The Eye of Eternity",
    [147] = "Ulduar",
    [172] = "Trial of the Crusader",
    [248] = "Onyxia's Lair (Classic)",
    [99533] = "Naxxramas Vanilla",
    [186] = "Icecrown Citadel",
    [200] = "The Ruby Sanctum",
    [350] = "Karazhan",
    [332] = "Serpentshrine Cavern",
    [334] = "Tempest Keep: The Eye",
    [329] = "Hyjal Summit",
    [339] = "Black Temple",
    [335] = "Zul'Aman",
    [285] = "Sunwell Plateau",
    [328] = "Gruul's Lair",
    [282] = "Magtheridon's Lair",
    [540] = "Shattered Halls",
    [542] = "Blood Furnace",
    [543] = "Hellfire Ramparts",
    [546] = "The Underbog",
    [545] = "Steamvault",
    [547] = "Slave Pens",
    [553] = "Mana-Tombs",
    [554] = "Sethekk Halls",
    [555] = "Shadow Labyrinth",
    [556] = "Auchenai Crypts",
    [557] = "Mana-Tombs",
    [558] = "Arcatraz",
    [560] = "Old Hillsbrad",
    [574] = "Utgarde Keep",
    [575] = "Utgarde Pinnacle",
    [576] = "The Nexus",
    [578] = "The Oculus",
    [585] = "Magister's Terrace",
    [595] = "Culling of Stratholme",
    [599] = "Halls of Stone",
    [600] = "Drak'Tharon Keep",
    [601] = "Azjol-Nerub",
    [602] = "Halls of Lightning",
    [604] = "Gundrak",
    [608] = "Violet Hold",
    [619] = "Ahn'kahet",
    [650] = "Trial of the Champion",
    [658] = "Pit of Saron",
    [668] = "Halls of Reflection",
    [632] = "Forge of Souls",
  }
  function C_Map.GetMapInfo(mapID)
    local name = WOTLK_MAP_NAMES[mapID]
    if name then return { name = name, mapID = mapID } end
    return nil
  end
end
do
  local SYNTHETIC_MAP_NAMES = {
    [99533] = "Naxxramas Vanilla",
    [248]   = "Onyxia's Lair (Classic)",
  }
  local _origGetMapInfo = C_Map.GetMapInfo
  function C_Map.GetMapInfo(mapID)
    local name = SYNTHETIC_MAP_NAMES[mapID]
    if name then return { name = name, mapID = mapID } end
    if _origGetMapInfo then return _origGetMapInfo(mapID) end
    return nil
  end
end
if type(C_Map.GetMapArtLayers) ~= "function" then
  function C_Map.GetMapArtLayers()
    return {}
  end
end
if type(C_Map.GetMapArtLayerTextures) ~= "function" then
  function C_Map.GetMapArtLayerTextures()
    return {}
  end
end
local C_Ping = EnsureTable("C_Ping")
if type(C_Ping.SendMacroPing) ~= "function" then
  function C_Ping.SendMacroPing()

  end
end
local C_PlayerChoice = EnsureTable("C_PlayerChoice")
if type(C_PlayerChoice.GetPlayerChoiceInfo) ~= "function" then
  function C_PlayerChoice.GetPlayerChoiceInfo()
    return nil
  end
end
if type(C_PlayerChoice.GetCurrentPlayerChoiceInfo) ~= "function" then
  function C_PlayerChoice.GetCurrentPlayerChoiceInfo()
    return nil
  end
end
local C_Texture = EnsureTable("C_Texture")
if type(C_Texture.GetAtlasInfo) ~= "function" then
  function C_Texture.GetAtlasInfo()
    return nil
  end
end
local C_EncounterJournal = EnsureTable("C_EncounterJournal")
if type(C_EncounterJournal.GetSectionInfo) ~= "function" then
  function C_EncounterJournal.GetSectionInfo()
    return nil
  end
end
local C_SpellBook = EnsureTable("C_SpellBook")
if type(C_SpellBook.GetNumSpellBookSkillLines) ~= "function" then
	function C_SpellBook.GetNumSpellBookSkillLines()
		if type(GetNumSpellTabs) == "function" then
			return GetNumSpellTabs()
		end
		return 0
	end
end
if type(C_SpellBook.GetSpellBookSkillLineInfo) ~= "function" then
	function C_SpellBook.GetSpellBookSkillLineInfo(tab)
		if type(GetSpellTabInfo) ~= "function" then
			return { name = nil, iconID = nil, itemIndexOffset = 0, numSpellBookItems = 0 }
		end
		local name, texture, offset, numSpells = GetSpellTabInfo(tab)
		return { name = name, iconID = texture, itemIndexOffset = offset or 0, numSpellBookItems = numSpells or 0 }
	end
end
if type(C_SpellBook.GetSpellBookItemInfo) ~= "function" then
	function C_SpellBook.GetSpellBookItemInfo(index, bank)
		local bookType = BOOKTYPE_SPELL or "spell"
		local spellType, spellID
		if type(GetSpellBookItemInfo) == "function" then
			spellType, spellID = GetSpellBookItemInfo(index, bookType)
		end
		local name = (type(GetSpellBookItemName) == "function" and GetSpellBookItemName(index, bookType)) or nil
		local icon = (type(GetSpellBookItemTexture) == "function" and GetSpellBookItemTexture(index, bookType)) or nil
		local isPassive = (type(IsPassiveSpell) == "function" and IsPassiveSpell(index, bookType)) or false
		return { spellID = spellID, name = name, iconID = icon, isPassive = isPassive, spellType = spellType }
	end
end
EnsureTable("C_UIWidgetManager")
EnsureTable("C_VoiceChat")
EnsureTable("C_TTSSettings")
EnsureTable("C_Traits")
EnsureTable("C_ClassTalents")
EnsureTable("C_LootHistory")
EnsureTable("C_AzeriteItem")
EnsureTable("C_AzeriteEmpoweredItem")
EnsureTable("C_AzeriteEssence")
EnsureTable("C_Covenants")
EnsureTable("C_Soulbinds")
EnsureTable("C_SpecializationInfo")
EnsureTable("C_TooltipInfo")
if type(C_TooltipInfo.GetHyperlink) ~= "function" then
  C_TooltipInfo.GetHyperlink = function() return nil end
end
if type(C_TooltipInfo.GetUnit) ~= "function" then
  C_TooltipInfo.GetUnit = function() return nil end
end
if type(C_TooltipInfo.GetInventoryItem) ~= "function" then
  C_TooltipInfo.GetInventoryItem = function() return nil end
end
if type(C_TooltipInfo.GetBagItem) ~= "function" then
  C_TooltipInfo.GetBagItem = function() return nil end
end
if type(C_TTSSettings.GetSpeechRate) ~= "function" then
  C_TTSSettings.GetSpeechRate = function() return 0 end
end
if type(C_TTSSettings.GetSpeechVolume) ~= "function" then
  C_TTSSettings.GetSpeechVolume = function() return 100 end
end
if type(C_TTSSettings.GetSpeechVoiceID) ~= "function" then
  C_TTSSettings.GetSpeechVoiceID = function() return 0 end
end
if type(C_TTSSettings.GetVoiceOptionName) ~= "function" then
  C_TTSSettings.GetVoiceOptionName = function() return "WoW default" end
end
if type(C_TTSSettings.SetSpeechRate) ~= "function" then
  C_TTSSettings.SetSpeechRate = function() end
end
if type(C_TTSSettings.SetSpeechVolume) ~= "function" then
  C_TTSSettings.SetSpeechVolume = function() end
end
if type(C_TTSSettings.SetVoiceOption) ~= "function" then
  C_TTSSettings.SetVoiceOption = function() end
end
if type(C_TTSSettings.SetDefaultSettings) ~= "function" then
  C_TTSSettings.SetDefaultSettings = function() end
end
if type(_G.TextToSpeech_GetSelectedVoice) ~= "function" then
  _G.TextToSpeech_GetSelectedVoice = function() return { voiceID = 0, name = "WoW default" } end
end
local Enum = EnsureTable("Enum")
Enum.VoiceTtsDestination = Enum.VoiceTtsDestination or { QueuedLocalPlayback = 0 }
Enum.TtsVoiceType = Enum.TtsVoiceType or { Standard = 0 }
Enum.Damageclass = Enum.Damageclass or {
  MaskNone = 0,
  MaskPhysical = 1,
  MaskHoly = 2,
  MaskFire = 4,
  MaskNature = 8,
  MaskFrost = 16,
  MaskShadow = 32,
  MaskArcane = 64,
}
Enum.RafLinkType = Enum.RafLinkType or { Recruit = 0 }
Enum.SpellBookSpellBank = Enum.SpellBookSpellBank or { Player = 0, Pet = 1 }
Enum.PhaseReason = Enum.PhaseReason or { WarMode = 0 }
do
  local probe = CreateFrame("Frame")
  if type(probe.RegisterUnitEvent) ~= "function" then
    local mt = getmetatable(probe)
    local idx = mt and mt.__index
    if type(idx) == "table" and type(idx.RegisterUnitEvent) ~= "function" then
      idx.RegisterUnitEvent = function(self, event, ...)
        self:RegisterEvent(event)
        self.__MRT_unitEventFilters = self.__MRT_unitEventFilters or {}
        local filters = self.__MRT_unitEventFilters
        filters[event] = filters[event] or {}
        local t = filters[event]
        for i = 1, select("#", ...) do
          local u = select(i, ...)
          if u and u ~= "" then
            t[#t + 1] = u
          end
        end
        if not self.__MRT_unitEventWrapped then
          self.__MRT_unitEventWrapped = true
          local orig = self:GetScript("OnEvent")
          self.__MRT_unitEventOrig = orig
          self:SetScript("OnEvent", function(frame, ev, ...)
            local f = frame.__MRT_unitEventFilters and frame.__MRT_unitEventFilters[ev]
            if f and #f > 0 then
              local unit = ...
              local ok = false
              if unit then
                for i = 1, #f do
                  if f[i] == unit then
                    ok = true
                    break
                  end
                end
              end
              if not ok then
                return
              end
            end
            local handler = frame.__MRT_unitEventOrig
            if handler then
              handler(frame, ev, ...)
            end
          end)
        end
      end
    end
  end
end
if not _G.__MRT_SetAtlasPatched then
	local f = CreateFrame("Frame")
	local tx = f:CreateTexture()
	local mt = getmetatable(tx)
	if mt and mt.__index then
		local origSetAtlas = mt.__index.SetAtlas
		local function applyKnownAtlas(self, atlas)
			if type(atlas) ~= "string" or not self then return false end
			local classKey = atlas:match("^classicon%-(.+)$") or atlas:match("^groupfinder%-icon%-class%-(.+)$")
			if classKey then
				local up = classKey:upper():gsub("%-", "")
				local sq = _G.ExRT and _G.ExRT.F and _G.ExRT.F.classSquareIcon and _G.ExRT.F.classSquareIcon[up]
				if sq and type(self.SetTexture) == "function" then
					pcall(self.SetTexture, self, sq)
					if type(self.SetTexCoord) == "function" then
						pcall(self.SetTexCoord, self, 0, 1, 0, 1)
					end
					if type(self.SetVertexColor) == "function" then
						pcall(self.SetVertexColor, self, 1, 1, 1, 1)
					end
					return true
				end
				local coords = _G.CLASS_ICON_TCOORDS and _G.CLASS_ICON_TCOORDS[up]
				if coords and type(self.SetTexture) == "function" then
					pcall(self.SetTexture, self, "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
					if type(self.SetTexCoord) == "function" then
						pcall(self.SetTexCoord, self, coords[1], coords[2], coords[3], coords[4])
					end
					if type(self.SetVertexColor) == "function" then
						pcall(self.SetVertexColor, self, 1, 1, 1, 1)
					end
					return true
				end
				return false
			end
			local role = atlas:match("^[Uu][Ii]%-[Ll][Ff][Gg]%-RoleIcon%-(.+)$") or atlas:match("^[Uu][Ii]%-Frame%-(.+)Icon$")
			if role then
				local r = role:lower()
				local path, l, r2, t, b
				if r == "tank" then path, l, r2, t, b = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp", 0, 19/64, 22/64, 41/64
				elseif r == "healer" then path, l, r2, t, b = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp", 20/64, 39/64, 1/64, 20/64
				elseif r == "dps" or r == "damager" then path, l, r2, t, b = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp", 20/64, 39/64, 22/64, 41/64
				end
				if path and type(self.SetTexture) == "function" then
					pcall(self.SetTexture, self, path)
					if type(self.SetTexCoord) == "function" then
						pcall(self.SetTexCoord, self, l, r2, t, b)
					end
					if type(self.SetVertexColor) == "function" then
						pcall(self.SetVertexColor, self, 1, 1, 1, 1)
					end
					return true
				end
				return false
			end
			if atlas == "charactercreate-icon-customize-speechbubble"
				or atlas:match("^[Gg][Mm]%-icon%-settings") then
				if type(self.SetTexture) == "function" then
					pcall(self.SetTexture, self, "Interface\\Icons\\Trade_Engineering")
					if type(self.SetTexCoord) == "function" then
						pcall(self.SetTexCoord, self, 0.08, 0.92, 0.08, 0.92)
					end
					if type(self.SetVertexColor) == "function" then
						pcall(self.SetVertexColor, self, 1, 1, 1, 1)
					end
					return true
				end
				return false
			end

			return false
		end

		mt.__index.SetAtlas = function(self, atlas, useAtlasSize)
			if applyKnownAtlas(self, atlas) then
				return true
			end
			if type(origSetAtlas) == "function" then
				local ok = pcall(origSetAtlas, self, atlas, useAtlasSize)
				if ok then return true end
			end
			if self and type(self.SetTexture) == "function" then
				pcall(self.SetTexture, self, "")
			end
			return false
		end
	end
	_G.__MRT_SetAtlasPatched = true
end
if not _G.DUNGEONS then _G.DUNGEONS = "Dungeons" end
if not _G.PLAYER_DIFFICULTY6 then _G.PLAYER_DIFFICULTY6 = "" end
if not _G.PLAYER_DIFFICULTY_MYTHIC_PLUS then _G.PLAYER_DIFFICULTY_MYTHIC_PLUS = "M+" end
if not _G.EXPANSION_NAME3 then _G.EXPANSION_NAME3 = "" end
if not _G.EXPANSION_NAME4 then _G.EXPANSION_NAME4 = "" end
if not _G.EXPANSION_NAME5 then _G.EXPANSION_NAME5 = "" end
if not _G.EXPANSION_NAME6 then _G.EXPANSION_NAME6 = "" end
if not _G.EXPANSION_NAME7 then _G.EXPANSION_NAME7 = "" end
if not _G.EXPANSION_NAME8 then _G.EXPANSION_NAME8 = "" end
if not _G.EXPANSION_NAME9 then _G.EXPANSION_NAME9 = "" end
if not _G.EXPANSION_NAME10 then _G.EXPANSION_NAME10 = "" end
if not _G.RELIC_SLOT_TYPE_FEL then _G.RELIC_SLOT_TYPE_FEL = "" end
if not _G.RELIC_SLOT_TYPE_FIRE then _G.RELIC_SLOT_TYPE_FIRE = "" end
if not _G.RELIC_SLOT_TYPE_BLOOD then _G.RELIC_SLOT_TYPE_BLOOD = "" end
if not _G.RELIC_SLOT_TYPE_LIFE then _G.RELIC_SLOT_TYPE_LIFE = "" end
if not _G.RELIC_SLOT_TYPE_HOLY then _G.RELIC_SLOT_TYPE_HOLY = "" end
if not _G.RELIC_SLOT_TYPE_FROST then _G.RELIC_SLOT_TYPE_FROST = "" end
if not _G.RELIC_SLOT_TYPE_SHADOW then _G.RELIC_SLOT_TYPE_SHADOW = "" end
if not _G.RELIC_SLOT_TYPE_IRON then _G.RELIC_SLOT_TYPE_IRON = "" end
if not _G.RELIC_SLOT_TYPE_ARCANE then _G.RELIC_SLOT_TYPE_ARCANE = "" end
if not _G.RELIC_SLOT_TYPE_WIND then _G.RELIC_SLOT_TYPE_WIND = "" end
if not _G.PLAYER_DIFFICULTY7 then _G.PLAYER_DIFFICULTY7 = "" end
if not _G.PLAYER_DIFFICULTY8 then _G.PLAYER_DIFFICULTY8 = "" end
if not _G.PLAYER_DIFFICULTY9 then _G.PLAYER_DIFFICULTY9 = "" end
if not _G.PLAYER_DIFFICULTY10 then _G.PLAYER_DIFFICULTY10 = "" end
if type(_G.MuteSoundFile) ~= "function" then function _G.MuteSoundFile() end end
if type(_G.UnmuteSoundFile) ~= "function" then function _G.UnmuteSoundFile() end end
if not _G.__MRT_SetResizeBoundsPatched then
  local f = CreateFrame("Frame")
  local mt = getmetatable(f)
  if mt and mt.__index and type(mt.__index.SetResizeBounds) ~= "function" then
    mt.__index.SetResizeBounds = function(self, minW, minH, maxW, maxH)
      if type(self.SetMinResize) == "function" and minW and minH then self:SetMinResize(minW, minH) end
      if type(self.SetMaxResize) == "function" and maxW and maxH then self:SetMaxResize(maxW, maxH) end
    end
  end
  _G.__MRT_SetResizeBoundsPatched = true
end
if not _G.PLAYER_DIFFICULTY1 then _G.PLAYER_DIFFICULTY1 = "" end
if not _G.PLAYER_DIFFICULTY2 then _G.PLAYER_DIFFICULTY2 = "" end
if not _G.PLAYER_DIFFICULTY3 then _G.PLAYER_DIFFICULTY3 = "" end
if not _G.PLAYER_DIFFICULTY4 then _G.PLAYER_DIFFICULTY4 = "" end
if not _G.PLAYER_DIFFICULTY5 then _G.PLAYER_DIFFICULTY5 = "" end
if not _G.FLEX_RAID_SIZE_LABEL then _G.FLEX_RAID_SIZE_LABEL = "" end
if not _G.ENCOUNTER_JOURNAL_ENCOUNTER then _G.ENCOUNTER_JOURNAL_ENCOUNTER = "Encounter" end
if not _G.LFG_LIST_TITLE then _G.LFG_LIST_TITLE = "Name" end
if not _G.DUNGEONS then _G.DUNGEONS = "Dungeons" end
if not _G.PLAYER_DIFFICULTY_MYTHIC_PLUS then _G.PLAYER_DIFFICULTY_MYTHIC_PLUS = "" end
if not _G.COVENANT_COLON then _G.COVENANT_COLON = "" end
if not _G.SOURCES then _G.SOURCES = (_G.SOURCE and (_G.SOURCE .. "s")) or "Sources" end
if type(_G.RELIC_TOOLTIP_TYPE) ~= "string" then _G.RELIC_TOOLTIP_TYPE = "%s" end
if not _G.TOOLTIP_AZERITE_UNLOCK_LEVELS then _G.TOOLTIP_AZERITE_UNLOCK_LEVELS = "%s" end
if not _G.LANDING_PAGE_SOULBIND_SECTION_HEADER then _G.LANDING_PAGE_SOULBIND_SECTION_HEADER = "" end
if not _G.__MRT_FrameMethodsPatched then
	local function _setShown(self, shown)
		if shown then
			if type(self.Show) == "function" then self:Show() end
		else
			if type(self.Hide) == "function" then self:Hide() end
		end
	end
	local function _noop() end
	local function _setHighlightLocked(self, locked)
		if locked then
			if type(self.LockHighlight) == "function" then self:LockHighlight() end
		else
			if type(self.UnlockHighlight) == "function" then self:UnlockHighlight() end
		end
	end
	local function _getScaledRect(self)
		if type(self) ~= "table" and type(self) ~= "userdata" then return 0,0,0,0 end
		if type(self.GetLeft) ~= "function" or type(self.GetBottom) ~= "function" or type(self.GetWidth) ~= "function" or type(self.GetHeight) ~= "function" then
			return 0,0,0,0
		end
		local left = self:GetLeft() or 0
		local bottom = self:GetBottom() or 0
		local width = self:GetWidth() or 0
		local height = self:GetHeight() or 0
		local scale = 1
		if type(self.GetEffectiveScale) == "function" then
			local ok, s = pcall(self.GetEffectiveScale, self)
			if ok and type(s) == "number" then scale = s end
		end
		return left * scale, bottom * scale, width * scale, height * scale
	end
	local function _adjustPointsOffset(self, x, y)
		x = tonumber(x) or 0
		y = tonumber(y) or 0
		if type(self.GetNumPoints) ~= "function" or type(self.GetPoint) ~= "function" then return end
		local n = self:GetNumPoints() or 0
		if n == 0 then return end
		local snap = {}
		for i = 1, n do
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(i)
			snap[i] = { point, relativeTo, relativePoint, (xOfs or 0) + x, (yOfs or 0) + y }
		end
		self:ClearAllPoints()
		for i = 1, #snap do
			local p = snap[i]
			pcall(self.SetPoint, self, p[1], p[2], p[3], p[4], p[5])
		end
	end
	local kinds = {
		"Frame", "Button", "CheckButton", "EditBox", "ScrollFrame",
		"Slider", "MessageFrame", "ScrollingMessageFrame", "StatusBar",
		"GameTooltip", "ColorSelect", "Cooldown", "SimpleHTML",
		"PlayerModel", "Model",
	}
	local seenMt = {}
	for _, kind in ipairs(kinds) do
		local ok, probe = pcall(CreateFrame, kind)
		if ok and probe then
			if kind == "EditBox" then
				if probe.SetAutoFocus then pcall(probe.SetAutoFocus, probe, false) end
				if probe.ClearFocus then pcall(probe.ClearFocus, probe) end
				if probe.EnableKeyboard then pcall(probe.EnableKeyboard, probe, false) end
			end
			pcall(probe.Hide, probe)
			local mt = getmetatable(probe)
			if mt and mt.__index and not seenMt[mt] then
				seenMt[mt] = true
				if type(mt.__index.SetShown) ~= "function" then
					mt.__index.SetShown = _setShown
				end
				if type(mt.__index.SetObeyStepOnDrag) ~= "function" then
					mt.__index.SetObeyStepOnDrag = _noop
				end
				if type(mt.__index.SetPassThroughButtons) ~= "function" then
					mt.__index.SetPassThroughButtons = _noop
				end
				if type(mt.__index.AdjustPointsOffset) ~= "function" then
					mt.__index.AdjustPointsOffset = _adjustPointsOffset
				end
				if type(mt.__index.SetHighlightLocked) ~= "function" then
					mt.__index.SetHighlightLocked = _setHighlightLocked
				end
				if type(mt.__index.GetScaledRect) ~= "function" then
					mt.__index.GetScaledRect = _getScaledRect
				end
			end
		end
	end
	local slider = CreateFrame("Slider")
	pcall(slider.Hide, slider)
	local smt = getmetatable(slider)
	if smt and smt.__index and (type(smt.__index.SetObeyStepOnDrag) ~= "function" or smt.__index.SetObeyStepOnDrag == _noop) then
		smt.__index.SetObeyStepOnDrag = function(self, obey)
			self.__MRT_obeyStep = obey and true or nil
		end
	end

	_G.__MRT_FrameMethodsPatched = true
end
if not _G.__MRT_FontStringMethodsPatched then
	local f = CreateFrame("Frame")
	local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local mt = getmetatable(fs)
	if mt and mt.__index then
		if type(mt.__index.SetMaxLines) ~= "function" then
			mt.__index.SetMaxLines = function() end
		end
		if type(mt.__index.IsTruncated) ~= "function" then
			mt.__index.IsTruncated = function(self)
				if not self or type(self.GetStringWidth) ~= "function" or type(self.GetWidth) ~= "function" then
					return false
				end
				local sw = self:GetStringWidth() or 0
				local w = self:GetWidth() or 0
				return sw > (w + 0.5)
			end
		end
		if type(mt.__index.SetShown) ~= "function" then
			mt.__index.SetShown = function(self, shown)
				if shown then if self.Show then self:Show() end
				else if self.Hide then self:Hide() end end
			end
		end
		if type(mt.__index.ClearAndSetPoint) ~= "function" then
			mt.__index.ClearAndSetPoint = function(self, ...)
				if self.ClearAllPoints then self:ClearAllPoints() end
				if self.SetPoint then return self:SetPoint(...) end
			end
		end
		if type(mt.__index.GetEffectiveScale) ~= "function" then
			mt.__index.GetEffectiveScale = function(self)
				local p = self.GetParent and self:GetParent()
				if p and p.GetEffectiveScale then return p:GetEffectiveScale() end
				return 1
			end
		end
	end
	_G.__MRT_FontStringMethodsPatched = true
end
if not _G.__MRT_TextureMethodsPatched then
	local f = CreateFrame("Frame")
	local tx = f:CreateTexture(nil, "ARTWORK")
	local mt = getmetatable(tx)
	if mt and mt.__index then
		if type(mt.__index.SetShown) ~= "function" then
			mt.__index.SetShown = function(self, shown)
				if shown then if self.Show then self:Show() end
				else if self.Hide then self:Hide() end end
			end
		end
		if type(mt.__index.ClearAndSetPoint) ~= "function" then
			mt.__index.ClearAndSetPoint = function(self, ...)
				if self.ClearAllPoints then self:ClearAllPoints() end
				if self.SetPoint then return self:SetPoint(...) end
			end
		end
		if type(mt.__index.GetEffectiveScale) ~= "function" then
			mt.__index.GetEffectiveScale = function(self)
				local p = self.GetParent and self:GetParent()
				if p and p.GetEffectiveScale then return p:GetEffectiveScale() end
				return 1
			end
		end
		if type(mt.__index.SetSubTexCoord) ~= "function" then
			mt.__index.SetSubTexCoord = function(self, left, right, top, bottom)
				if self.SetTexCoord then
					return self:SetTexCoord(left or 0, right or 1, top or 0, bottom or 1)
				end
			end
		end
		if type(mt.__index.SetMask) ~= "function" then
			mt.__index.SetMask = function() end
		end
		if type(mt.__index.GetNumMaskTextures) ~= "function" then
			mt.__index.GetNumMaskTextures = function() return 0 end
		end
		if type(mt.__index.SetSnapToPixelGrid) ~= "function" then
			mt.__index.SetSnapToPixelGrid = function() end
		end
		if type(mt.__index.SetTexelSnappingBias) ~= "function" then
			mt.__index.SetTexelSnappingBias = function() end
		end
		if type(mt.__index.SetIgnoreParentAlpha) ~= "function" then
			mt.__index.SetIgnoreParentAlpha = function() end
		end
		if type(mt.__index.SetIgnoreParentScale) ~= "function" then
			mt.__index.SetIgnoreParentScale = function() end
		end
		if type(mt.__index.SetThickness) ~= "function" then
			mt.__index.SetThickness = function() end
		end
		if type(mt.__index.SetStartPoint) ~= "function" then
			mt.__index.SetStartPoint = function() end
		end
		if type(mt.__index.SetEndPoint) ~= "function" then
			mt.__index.SetEndPoint = function() end
		end
	end
	_G.__MRT_TextureMethodsPatched = true
end

if not _G.__MRT_LineCompatPatched then
	local __mrt_hiddenHolder = CreateFrame("Frame")
	__mrt_hiddenHolder:Hide()
	local function __mrt_probe(ftype)
		local w = CreateFrame(ftype)
		if w then
			if ftype == "EditBox" then
				if w.SetAutoFocus then w:SetAutoFocus(false) end
				if w.ClearFocus then w:ClearFocus() end
				if w.EnableKeyboard then w:EnableKeyboard(false) end
			end
			if w.SetParent then w:SetParent(__mrt_hiddenHolder) end
			if w.Hide then w:Hide() end
		end
		return w
	end
	local function __mrt_add(sample,name,func)
		local mt=getmetatable(sample)
		if mt and mt.__index and type(mt.__index[name])~="function" then
			mt.__index[name]=func
		end
	end
	local function __mrt_force_add(sample,name,func)
		local mt=getmetatable(sample)
		if mt and mt.__index then
			mt.__index[name]=func
		end
	end
	local __mrt_texOnly = {
		SetTexture=true, GetTexture=true,
		SetVertexColor=true, GetVertexColor=true,
		SetTexCoord=true, GetTexCoord=true,
		SetDesaturated=true, IsDesaturated=true,
		SetRotation=true, GetRotation=true,
		SetBlendMode=true, GetBlendMode=true,
		SetGradient=true, SetGradientAlpha=true,
		SetNonBlocking=true, GetNonBlocking=true,
		SetHorizTile=true, SetVertTile=true,
		SetAtlas=true, GetAtlas=true,
	}
	local LINE_DOT_TEXTURE = "Interface\\AddOns\\MRT\\media\\circle256"
	local __mrt_CreateLine = function(self,layer,subLevel)
		local lf=CreateFrame("Frame",nil,self)
		lf:SetPoint("TOPLEFT",0,0)
		lf:SetSize(1,1)
		lf:SetFrameLevel((self.GetFrameLevel and self:GetFrameLevel() or 0) + 1)
		lf:Show()
		local tex=lf:CreateTexture(nil,layer or "ARTWORK",nil,subLevel or 0)
		tex:SetPoint("CENTER",lf,"CENTER",0,0)
		tex:SetSize(1,1)
		tex:SetTexture("Interface\\Buttons\\WHITE8X8")
		tex:SetVertexColor(1,1,1,1)
		tex:Hide()
		lf._t=tex
		lf._th=1
		lf._segs={}
		lf._layer=layer or "ARTWORK"
		lf._subLevel=subLevel or 0
		lf._cR,lf._cG,lf._cB,lf._cA=1,1,1,1
		lf._mode="solid"
		local function parse(point,a,b,c,d)
			local rel,relp,x,y
			if type(a)=="number" or a==nil then
				rel=self
				relp=point
				x=a or 0
				y=b or 0
			else
				rel=a
				if type(b)=="string" then
					relp=b
					x=c or 0
					y=d or 0
				else
					relp=point
					x=b or 0
					y=c or 0
				end
			end
			return {p=point,r=rel,rp=relp,x=x,y=y}
		end
		local function _AcquireSegment(i)
			local seg = lf._segs[i]
			if not seg then
				seg = lf:CreateTexture(nil, lf._layer, nil, lf._subLevel)
				seg:SetTexture(LINE_DOT_TEXTURE)
				if seg.SetBlendMode then seg:SetBlendMode("BLEND") end
				lf._segs[i] = seg
			end
			if seg.SetVertexColor then
				seg:SetVertexColor(lf._cR or 1, lf._cG or 1, lf._cB or 1, lf._cA or 1)
			end
			return seg
		end
		local function _Update()
			local s=lf._s
			local e=lf._e
			if s and e and s.r==e.r and s.p==e.p and (s.p=="TOPLEFT" or s.p=="CENTER" or s.p=="BOTTOMLEFT") then
				local x1,y1,x2,y2=s.x,s.y,e.x,e.y
				local dx,dy=x2-x1,y2-y1
				local len=(dx*dx+dy*dy)^0.5
				if len<1 then len=1 end
				local thickness = lf._th or 1
				lf:ClearAllPoints()
				lf:SetPoint(s.p, s.r, s.rp, 0, 0)
				lf:SetSize(1, 1)
				local step = math.max(1, thickness * 0.5)
				local n = math.max(2, math.ceil(len / step) + 1)
				if n > 200 then n = 200 end
				local denom = (n > 1) and (n - 1) or 1
				local dashOn  = (lf._mode == "dashed") and 2 or 1
				local dashLen = (lf._mode == "dashed") and 4 or 1
				for i = 1, n do
					local f = (i - 1) / denom
					local px = x1 + dx * f
					local py = y1 + dy * f
					local seg = _AcquireSegment(i)
					seg:ClearAllPoints()
					seg:SetPoint("CENTER", s.r, s.p, px, py)
					seg:SetSize(thickness, thickness)
					if lf._mode == "dashed" and ((i - 1) % dashLen) >= dashOn then
						seg:Hide()
					else
						seg:Show()
					end
				end
				for i = n + 1, #lf._segs do
					lf._segs[i]:Hide()
				end
			else
				for i = 1, #lf._segs do lf._segs[i]:Hide() end
				lf:ClearAllPoints()
				if s then lf:SetPoint(s.p,s.r,s.rp,s.x,s.y) end
				if e then lf:SetPoint(e.p,e.r,e.rp,e.x,e.y) end
				if not e then lf:SetSize(lf._th or 1,lf._th or 1) end
			end
		end
		lf._Update = function() _Update() end
		lf.SetStartPoint = function(_self,point,a,b,c,d)
			lf._s=parse(point,a,b,c,d)
			_Update()
			lf:Show()
		end
		lf.SetEndPoint = function(_self,point,a,b,c,d)
			lf._e=parse(point,a,b,c,d)
			_Update()
			lf:Show()
		end
		lf.SetThickness = function(_self,v)
			lf._th=v or 1
			_Update()
		end
		lf.SetColorTexture = function(_self,r,g,b,a)
			lf._cR, lf._cG, lf._cB, lf._cA = r, g, b, a or 1
			lf._mode = "solid"
			_Update()
		end
		lf.SetVertexColor = function(_self,r,g,b,a)
			if r == 1 and g == 1 and b == 1 and (a == 1 or a == nil)
				and not (lf._cR == 1 and lf._cG == 1 and lf._cB == 1) then
				return
			end
			lf._cR, lf._cG, lf._cB, lf._cA = r, g, b, a or 1
			_Update()
		end
		lf.SetTexture = function(_self,path, mode)
			if type(path) == "string" and path:lower():find("linegapped") then
				lf._mode = "dashed"
			else
				lf._mode = "solid"
			end
			if tex and tex.SetTexture then
				pcall(tex.SetTexture, tex, path, mode)
			end
			_Update()
		end
		lf.SetTexCoord = function(_self,...)
			if tex and tex.SetTexCoord then
				pcall(tex.SetTexCoord, tex, ...)
			end
		end
		return lf
	end
	local __mrt_f = __mrt_probe("Frame")
	__mrt_force_add(__mrt_f,"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("Button"),"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("StatusBar"),"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("Slider"),"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("ScrollFrame"),"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("CheckButton"),"CreateLine",__mrt_CreateLine)
	__mrt_force_add(__mrt_probe("EditBox"),"CreateLine",__mrt_CreateLine)
	local __mrt_tx=__mrt_f:CreateTexture()
	__mrt_add(__mrt_tx,"SetColorTexture",function(self,r,g,b,a)
		self:SetTexture("Interface\\Buttons\\WHITE8X8")
		if self.SetVertexColor then
			self:SetVertexColor(r,g,b,a or 1)
		end
	end)
	local sf=__mrt_probe("ScrollFrame")
	__mrt_add(sf,"SetChildKey",function() end)
	local bt=__mrt_probe("Button")
	local __mrt_SetEnabled = function(self,v) if v then if self.Enable then self:Enable() end else if self.Disable then self:Disable() end end end
	__mrt_add(bt,"SetEnabled",__mrt_SetEnabled)
	__mrt_add(__mrt_probe("CheckButton"),"SetEnabled",__mrt_SetEnabled)
	__mrt_add(__mrt_probe("EditBox"),"SetEnabled",__mrt_SetEnabled)
	__mrt_add(__mrt_probe("Slider"),"SetEnabled",__mrt_SetEnabled)
	local __mrt_SetShown = function(self, shown)
		if shown then if self.Show then self:Show() end else if self.Hide then self:Hide() end end
	end
	local __mrt_NoOp = function() end
	local __mrt_SetResizeBounds = function(self, minW, minH, maxW, maxH)
		if type(self.SetMinResize) == "function" and minW and minH then self:SetMinResize(minW, minH) end
		if type(self.SetMaxResize) == "function" and maxW and maxH then self:SetMaxResize(maxW, maxH) end
	end
	local __mrt_ClearAndSetPoint = function(self, ...)
		if self.ClearAllPoints then self:ClearAllPoints() end
		if self.SetPoint then return self:SetPoint(...) end
	end
	local __mrt_SetForbidden = function(self) self.___MRT_Forbidden = true end
	local __mrt_IsForbidden = function(self) return self.___MRT_Forbidden == true end
	local __mrt_GetScaledRect = function(self)
		if type(self.GetLeft) ~= "function" or type(self.GetBottom) ~= "function" or type(self.GetWidth) ~= "function" or type(self.GetHeight) ~= "function" then
			return 0,0,0,0
		end
		local left = self:GetLeft() or 0
		local bottom = self:GetBottom() or 0
		local width = self:GetWidth() or 0
		local height = self:GetHeight() or 0
		local scale = 1
		if type(self.GetEffectiveScale) == "function" then
			local ok, s = pcall(self.GetEffectiveScale, self)
			if ok and type(s) == "number" then scale = s end
		end
		return left * scale, bottom * scale, width * scale, height * scale
	end
	for _,ftype in ipairs({"Frame","Button","CheckButton","EditBox","Slider","ScrollFrame","StatusBar","MessageFrame","PlayerModel","Model","Cooldown"}) do
		local ok, w = pcall(__mrt_probe, ftype)
		if ok and w then
			__mrt_add(w,"SetShown",__mrt_SetShown)
			__mrt_add(w,"SetObeyStepOnDrag",__mrt_NoOp)
			__mrt_add(w,"SetResizeBounds",__mrt_SetResizeBounds)
			__mrt_add(w,"ClearAndSetPoint",__mrt_ClearAndSetPoint)
			__mrt_add(w,"SetIgnoreParentScale",__mrt_NoOp)
			__mrt_add(w,"SetIgnoreParentAlpha",__mrt_NoOp)
			__mrt_add(w,"SetClipsChildren",__mrt_NoOp)
			__mrt_add(w,"SetPortraitZoom",__mrt_NoOp)
			__mrt_add(w,"CreateMaskTexture",__mrt_NoOp)
			__mrt_add(w,"SetForbidden",__mrt_SetForbidden)
			__mrt_add(w,"IsForbidden",__mrt_IsForbidden)
			__mrt_add(w,"GetScaledRect",__mrt_GetScaledRect)
		end
	end
	local __mrt_cd = __mrt_probe("Cooldown")
	if __mrt_cd then
		__mrt_add(__mrt_cd,"SetHideCountdownNumbers",function(self, hide)
			self.noCooldownCount = hide and true or nil
		end)
		__mrt_add(__mrt_cd,"SetDrawBling",__mrt_NoOp)
		__mrt_add(__mrt_cd,"SetDrawSwipe",function(self, drawSwipe)
			if self.SetAlpha then self:SetAlpha(drawSwipe and 1 or 0) end
		end)
		__mrt_add(__mrt_cd,"GetDrawSwipe",function(self)
			return self.GetAlpha and (self:GetAlpha() > 0) or true
		end)
		__mrt_add(__mrt_cd,"IsPaused",function() return false end)
		__mrt_add(__mrt_cd,"Pause",__mrt_NoOp)
		__mrt_add(__mrt_cd,"Resume",__mrt_NoOp)
		__mrt_add(__mrt_cd,"Clear",function(self) if self.Hide then self:Hide() end end)
		__mrt_add(__mrt_cd,"SetSwipeTexture",__mrt_NoOp)
		__mrt_add(__mrt_cd,"SetSwipeColor",function(self, r, g, b, a)
			if a and self.SetAlpha then self:SetAlpha(a) end
		end)
		__mrt_add(__mrt_cd,"GetCooldownTimes",function(self)
			local s, d = self.___MRT_Start, self.___MRT_Duration
			if s and d and (GetTime() - (s + d)) >= 0 then
				self.___MRT_Start, self.___MRT_Duration = nil, nil
				s, d = nil, nil
			end
			return s or 0, d or 0
		end)
		__mrt_add(__mrt_cd,"GetCooldownDuration",function(self)
			local d = self.___MRT_Duration
			if d then
				d = d - (GetTime() - (self.___MRT_Start or GetTime()))
				if d <= 0 then
					self.___MRT_Start, self.___MRT_Duration = nil, nil
					d = nil
				end
			end
			return d or 0
		end)
		__mrt_add(__mrt_cd,"SetCooldownDuration",function(self, duration, modrate)
			if self.SetCooldown and GetTime then return self:SetCooldown(GetTime(), duration or 0, modrate) end
		end)
		local mt = getmetatable(__mrt_cd)
		if mt and mt.__index then
			local origSetCooldown = mt.__index.SetCooldown
			if type(origSetCooldown) == "function" and not _G.__MRT_CooldownSetCooldownPatched then
				mt.__index.SetCooldown = function(self, start, duration, modrate)
					self.___MRT_Start = (start and start > 0) and start or nil
					self.___MRT_Duration = (duration and duration > 0) and duration or nil
					return origSetCooldown(self, start, duration, modrate)
				end
				_G.__MRT_CooldownSetCooldownPatched = true
			end
		end
	end

	_G.__MRT_LineCompatPatched=true
end
if type(_G.GetTalentInfoClassic) ~= "function" and type(_G.GetTalentInfo) == "function" then
	function _G.GetTalentInfoClassic(tab, idx, isInspect)
		local name, iconTexture, tier, column, rank, maxRank = GetTalentInfo(tab, idx, isInspect)
		if not name then return nil end
		return name, iconTexture, tier, column, rank or 0, maxRank or 0, false, true
	end
end
if type(_G.UIDropDownMenu_StopCounting) ~= "function"
   or type(_G.UIDropDownMenu_StartCounting) ~= "function" then
	local SHOW_TIME = 2
	local function _redirectToScrollDropDownRoot(frame)
		if not frame then return nil end
		local list = ELib and ELib.ScrollDropDown and ELib.ScrollDropDown.DropDownList
		if not list or not list[1] then return frame end
		local target = frame
		local depth = 0
		while target and depth < 8 do
			for i = 1, #list do
				if list[i] == target then return list[1] end
			end
			if type(target.GetParent) ~= "function" then break end
			local p = target:GetParent()
			if not p or p == target then break end
			target = p
			depth = depth + 1
		end
		return frame
	end

	function _G.UIDropDownMenu_StartCounting(frame)
		local target = _redirectToScrollDropDownRoot(frame)
		if target then
			target.showTimer = SHOW_TIME
			target.isCounting = 1
		end
	end
	function _G.UIDropDownMenu_StopCounting(frame)
		local target = _redirectToScrollDropDownRoot(frame)
		if target then
			target.isCounting = nil
			target.showTimer = nil
		end
	end
end
if type(_G.CreateColor) ~= "function" then
	function _G.CreateColor(r, g, b, a)
		return { r = r or 1, g = g or 1, b = b or 1, a = a or 1,
			GetRGB = function(self) return self.r, self.g, self.b end,
			GetRGBA = function(self) return self.r, self.g, self.b, self.a end,
		}
	end
end
if not _G.__MRT_SetGradientPatched then
	local function isColorObj(v)
		return type(v) == "table" and v.r ~= nil and v.g ~= nil and v.b ~= nil
	end
	local f = CreateFrame("Frame")
	f:Hide()
	local t = f:CreateTexture()
	local mt = getmetatable(t)
	if mt and mt.__index and type(mt.__index.SetGradient) == "function" then
		local orig = mt.__index.SetGradient
		mt.__index.SetGradient = function(self, orientation, c1, c2, ...)
			if isColorObj(c1) and isColorObj(c2) then
				local r1,g1,b1 = c1.r, c1.g, c1.b
				local r2,g2,b2 = c2.r, c2.g, c2.b
				if type(self.SetGradientAlpha) == "function" then
					pcall(self.SetGradientAlpha, self, orientation, r1,g1,b1, c1.a or 1, r2,g2,b2, c2.a or 1)
					return
				end
				return orig(self, orientation, r1,g1,b1, r2,g2,b2)
			end
			return orig(self, orientation, c1, c2, ...)
		end
	end
	_G.__MRT_SetGradientPatched = true
end
do
	_G.MRT_CLEU_SNIFFER = _G.MRT_CLEU_SNIFFER or CreateFrame("Frame", "MRTCleuSnifferFrame", UIParent)
	local f = _G.MRT_CLEU_SNIFFER
	local enabled = false
	local recvCount = 0
	local lastArgs = nil
	f:SetScript("OnEvent", function(self, ev, ...)
		recvCount = recvCount + 1
		if ev ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
		if not enabled then return end
		local timestamp, subEvent, sG, sN, sF, dG, dN, dF, a1, a2, a3 = ...
		lastArgs = string.format("ts=%s ev=%s sN=%s dN=%s a1=%s a2=%s",
			tostring(timestamp), tostring(subEvent), tostring(sN), tostring(dN), tostring(a1), tostring(a2))
		if subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_START" then
			print(string.format("|cff00ffff[MRT/SNIFF]|r %s src=%s spell=%s(%s)",
				tostring(subEvent), tostring(sN), tostring(a2), tostring(a1)))
		end
	end)
	SLASH_MRTCLEU1 = "/mrtcleu"
	SlashCmdList["MRTCLEU"] = function(msg)
		msg = (msg or ""):lower()
		if msg == "on" then
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			enabled = true
			recvCount = 0
			print("|cff00ffff[MRT/SNIFF]|r enabled — cast a spell. Reg=" ..
				tostring(f:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")))
		elseif msg == "off" then
			f:UnregisterAllEvents()
			enabled = false
			print(string.format("|cff00ffff[MRT/SNIFF]|r disabled. Received %d events total. Last=%s",
				recvCount, tostring(lastArgs)))
		elseif msg == "status" then
			local M = _G.MRT or _G.ExRT
			local cleuFrame = M and M.CLEUFrame
			local cleuMods = cleuFrame and cleuFrame.CLEUModules
			local n = -1
			if type(cleuMods) == "table" then
				n = 0
				for _ in pairs(cleuMods) do n = n + 1 end
			end
			print(string.format("|cff00ffff[MRT/SNIFF]|r MRT=%s sniffer=%s recv=%d  CLEUFrame=%s reg=%s  CLEUModules=%d",
				tostring(M and true or false),
				tostring(f:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")),
				recvCount,
				tostring(cleuFrame and true or false),
				tostring(cleuFrame and cleuFrame.IsEventRegistered and cleuFrame:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") or false),
				n))
			if lastArgs then print("|cff00ffff[MRT/SNIFF]|r last: "..lastArgs) end
			if cleuMods and type(cleuMods) == "table" then
				for mod in pairs(cleuMods) do
					print(" - module:", tostring(mod.name or mod))
				end
			end
		else
			print("Usage: /mrtcleu on | off | status")
		end
	end
end
local function setupCompatEncounter()
	local MRT = _G.MRT or _G.ExRT
	if not MRT then return end
	MRT.Compat = MRT.Compat or {}
	MRT.Compat.Map = MRT.Compat.Map or {}
	MRT.Compat.Encounter = MRT.Compat.Encounter or {}

	local M = MRT.Compat.Map
	local E = MRT.Compat.Encounter

	local lastInstanceMapID = -1
	local lastZoneName = ""
	local function refreshZone()
		if SetMapToCurrentZone then
			local ok = pcall(SetMapToCurrentZone)
			if ok and GetCurrentMapAreaID then
				lastInstanceMapID = GetCurrentMapAreaID() or -1
			end
		end
		lastZoneName = (GetRealZoneText and GetRealZoneText()) or (GetZoneText and GetZoneText()) or ""
	end

	function M.GetCurrentMapID()
		if lastInstanceMapID == -1 then refreshZone() end
		return lastInstanceMapID
	end

	function M.GetCurrentZoneName()
		if lastZoneName == "" then refreshZone() end
		return lastZoneName
	end

	function M.GetInstanceMapID()
		if GetInstanceInfo then
			local _,_,_,_,_,_,_,mapID = GetInstanceInfo()
			return mapID or -1
		end
		return -1
	end

	local nameToID = {}
	function M.MapNameToID(name)
		return nameToID[name]
	end
	function M.RegisterMapName(id, name) nameToID[name] = id end
	local bossTable = {}
	local currentEncounterID = nil
	local inCombatWith = nil
	local lastEngageTime = 0
	local lastBossKillID = nil
	local lastBossKillTime = 0

	function E.RegisterBoss(mapID, creatureID, encounterID)
		bossTable[mapID] = bossTable[mapID] or {}
		bossTable[mapID][creatureID] = encounterID
	end
	do
		local WOTLK_BOSS_CIDS = {
			[742]  = {28860,30449,30451,30452},
			[734]  = {28859},
			[744]  = {33113},
			[745]  = {33118},
			[746]  = {33186},
			[747]  = {33293},
			[748]  = {32867,32927,32857},
			[749]  = {32930,32933,32934},
			[750]  = {33515},
			[751]  = {32845},
			[752]  = {32865},
			[753]  = {32906,32913,32914,32915,32916,33203,33202},
			[754]  = {33350,33432,33651,33670,34071},
			[755]  = {33271},
			[756]  = {33288},
			[757]  = {32871},
			[629]  = {34796,35144,34799,34797},
			[633]  = {34780},
			[637]  = {34461,34460,34469,34467,34468,34465,34471,34466,34473,34472,34474,34470,34475,34458,34459,34449,34448,34445,34441,34439,34444,34456,34447,34455},
			[641]  = {34496,34497},
			[645]  = {34564},
			[845]  = {36612},
			[846]  = {36855},
			[848]  = {37813},
			[849]  = {36626},
			[850]  = {36627},
			[851]  = {36678},
			[852]  = {37970,37972,37973},
			[853]  = {37955},
			[854]  = {36789},
			[855]  = {36853},
			[856]  = {36597},
			[887]  = {39863},
			[890]  = {39751},
			[891]  = {39747},
			[893]  = {39746},
			[772]  = {31125},
			[774]  = {33993},
			[776]  = {35013},
			[885]  = {38433},
			[1084] = {10184},
			[1107] = {15956},
			[1110] = {15953},
			[1116] = {15952},
			[1117] = {15954},
			[1118] = {15936},
			[1119] = {16011},
			[1111] = {16061},
			[1112] = {16060},
			[1121] = {16063,16064,16065,30549},
			[1113] = {16028},
			[1114] = {15931},
			[1115] = {15932},
			[1120] = {15928,15929,15930},
			[1109] = {15989},
			[1108] = {15990},
		}
		for encID, cids in pairs(WOTLK_BOSS_CIDS) do
			for i = 1, #cids do
				E.RegisterBoss(0, cids[i], encID)
			end
		end
	end

	function E.GetCurrentEncounterID() return currentEncounterID end

	function E.GetEncounterIDByCreature(creatureID)
		creatureID = tonumber(creatureID)
		if not creatureID then return nil end
		return bossTable[0] and bossTable[0][creatureID] or nil
	end

	local function cidFromGUID(guid)
		if type(guid) ~= "string" or guid == "" then return nil end
		local hex = guid:match("^0x(%x+)$") or guid:match("^(%x+)$")
		if not hex then return nil end
		if #hex < 16 then hex = string.rep("0", 16 - #hex) .. hex end
		if hex:sub(1, 4) == "0000" then return nil end
		local triplet = hex:sub(1, 3):upper()
		if triplet ~= "F13" and triplet ~= "F15" then return nil end
		return tonumber(hex:sub(6, 10), 16)
	end

	local function scanUnit(unit)
		if not UnitExists or not UnitExists(unit) then return nil end
		if UnitIsFriend and UnitIsFriend("player", unit) then return nil end
		local guid = UnitGUID and UnitGUID(unit)
		return cidFromGUID(guid)
	end

	local UNIT_TOKENS = {"target","focus","mouseover","boss1","boss2","boss3","boss4"}

	local function fireMRTEvent(name, ...)
		if MRT.F and type(MRT.F.fireEvent) == "function" then
			pcall(MRT.F.fireEvent, name, ...)
		end
	end
	local function isBossLike(unit)
		if not UnitExists or not UnitExists(unit) then return false end
		if not UnitCanAttack or not UnitCanAttack("player", unit) then return false end
		if UnitIsDead and UnitIsDead(unit) then return false end
		local classification = UnitClassification and UnitClassification(unit)
		if classification == "worldboss" then return true end
		local level = UnitLevel and UnitLevel(unit) or 0
		if level == -1 or level == 999 then return true end
		local maxHp = UnitHealthMax and UnitHealthMax(unit) or 0
		if maxHp > 1000000 then return true end
		return false
	end

	local _nameToEncIDCache
	local function nameToEncIDLookup(bn)
		if not bn or bn == "" then return nil end
		if not _nameToEncIDCache and ExRT and ExRT.L and ExRT.L.bossName then
			_nameToEncIDCache = {}
			for id, name in pairs(ExRT.L.bossName) do
				if type(id) == "number" and type(name) == "string" and name ~= "" then
					if not _nameToEncIDCache[name] then
						_nameToEncIDCache[name] = id
					end
				end
			end
		end
		return _nameToEncIDCache and _nameToEncIDCache[bn] or nil
	end
	function E.InvalidateBossNameCache() _nameToEncIDCache = nil end

	local function tryEngage(unit)
		local cid = scanUnit(unit)
		if not cid then return nil end
		local mapID = M.GetCurrentMapID()
		local tbl = bossTable[mapID] or bossTable[M.GetInstanceMapID()]
		local encID = tbl and tbl[cid]
		if not encID and bossTable[0] then
			encID = bossTable[0][cid]
		end
		local bossName = (UnitName and UnitName(unit)) or ""
		if not encID then
			local resolved = nameToEncIDLookup(bossName)
			if resolved then
				encID = resolved
				bossTable[0] = bossTable[0] or {}
				bossTable[0][cid] = resolved
			end
		end
		if not encID and IsInInstance and IsInInstance() and isBossLike(unit) then
			local zoneType
			if GetInstanceInfo then
				local _name
				_name, zoneType = GetInstanceInfo()
			end
			if zoneType == "raid" then
				encID = cid
			end
		end
		if not encID then return nil end
		inCombatWith = cid
		if currentEncounterID ~= encID then
			local mapForEvent = M.GetCurrentMapID()
			currentEncounterID = encID
			lastEngageTime = GetTime()
			lastBossKillID = nil
			lastBossKillTime = 0
			fireMRTEvent("MRT_ENCOUNTER_START", encID, mapForEvent, cid, bossName)
		end
		return encID
	end

	function E.FireScan()
		for _, unit in ipairs(UNIT_TOKENS) do
			local encID = tryEngage(unit)
			if encID then return encID end
		end
		local n = (IsInRaid and IsInRaid()) and (GetNumGroupMembers and GetNumGroupMembers() or 40) or 0
		for i = 1, n do
			local encID = tryEngage("raid"..i.."target")
			if encID then return encID end
		end
		return nil
	end

	local scanFrame = CreateFrame("Frame", "MRTCompatScanFrame", UIParent)
	scanFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	scanFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	scanFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	scanFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	scanFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	scanFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	scanFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if INSTANCE_ENCOUNTER_ENGAGE_UNIT == nil then
		pcall(scanFrame.RegisterEvent, scanFrame, "INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
	local function scannerTrace(msg)
		local f = _G.MRT_TraceEncounterBridgeLog
		if f then f(msg) end
	end
	scanFrame:SetScript("OnEvent", function(self, ev, ...)
		if ev == "PLAYER_ENTERING_WORLD" or ev == "ZONE_CHANGED_NEW_AREA" then
			refreshZone()
		elseif ev == "PLAYER_REGEN_DISABLED" or ev == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
			refreshZone()
			local zoneType = ""
			if GetInstanceInfo then
				local _, zt = GetInstanceInfo()
				zoneType = zt or ""
			end
			scannerTrace(string.format("|cffaaaaff[scan]|r %s zone=%s mapID=%s",
				ev, tostring(zoneType), tostring(M.GetCurrentMapID())))
			local engagedID = E.FireScan()
			scannerTrace(string.format("|cffaaaaff[scan]|r FireScan -> encID=%s currentEncounterID=%s",
				tostring(engagedID), tostring(currentEncounterID)))
			if C_Timer and C_Timer.After then
				C_Timer.After(0.5, function()
					local r = E.FireScan()
					scannerTrace(string.format("|cffaaaaff[scan]|r retry@0.5 -> encID=%s currentEncounterID=%s",
						tostring(r), tostring(currentEncounterID)))
				end)
				C_Timer.After(2, function()
					local r = E.FireScan()
					scannerTrace(string.format("|cffaaaaff[scan]|r retry@2.0 -> encID=%s currentEncounterID=%s",
						tostring(r), tostring(currentEncounterID)))
				end)
				C_Timer.After(5, function()
					if currentEncounterID then return end
					local r = E.FireScan()
					scannerTrace(string.format("|cffaaaaff[scan]|r retry@5.0 -> encID=%s currentEncounterID=%s",
						tostring(r), tostring(currentEncounterID)))
				end)
			end
		elseif ev == "PLAYER_TARGET_CHANGED" or ev == "UPDATE_MOUSEOVER_UNIT" then
			if currentEncounterID then return end
			if InCombatLockdown and not InCombatLockdown() then return end
			E.FireScan()
		elseif ev == "COMBAT_LOG_EVENT_UNFILTERED" then
			local _ts, subEvent, _sGUID, _sName, _sFlags, destGUID = ...
			if subEvent ~= "UNIT_DIED" then return end
			if type(destGUID) ~= "string" then return end
			local cid = cidFromGUID(destGUID)
			if cid and (currentEncounterID or inCombatWith) then
				scannerTrace(string.format("|cffaaaaff[scan]|r UNIT_DIED cid=%s inCombatWith=%s currentEncounterID=%s",
					tostring(cid), tostring(inCombatWith), tostring(currentEncounterID)))
			end
			if not cid then return end
			if cid == inCombatWith or cid == currentEncounterID then
				lastBossKillID = cid
				lastBossKillTime = GetTime()
				scannerTrace(string.format("|cffaaaaff[scan]|r boss UNIT_DIED cid=%s -> success=true pending REGEN_ENABLED",
					tostring(cid)))
			end
		elseif ev == "PLAYER_REGEN_ENABLED" then
			if currentEncounterID then
				local endEnc = currentEncounterID
				local recent = (GetTime() - lastBossKillTime) < 30
				local matched = lastBossKillID and recent and (
					lastBossKillID == inCombatWith or lastBossKillID == currentEncounterID
				)
				local success = matched and true or false
				if not success and inCombatWith and lastEngageTime > 0
					and (GetTime() - lastEngageTime) > 30
					and UnitIsDeadOrGhost and not UnitIsDeadOrGhost("player") then
					local cidWanted = inCombatWith
					local stillAlive = false
					local sawDead = false
					local stillVisible = false
					for i = 1, 4 do
						local unit = "boss"..i
						if UnitExists and UnitExists(unit) then
							local guid = UnitGUID and UnitGUID(unit)
							local cidHere = guid and cidFromGUID(guid)
							if cidHere == cidWanted then
								stillVisible = true
								if UnitIsDead and UnitIsDead(unit) then
									sawDead = true
								elseif UnitHealth and UnitHealth(unit) == 0 then
									sawDead = true
								else
									stillAlive = true
								end
							end
						end
					end
					if sawDead or (not stillVisible and not stillAlive) then
						success = true
						scannerTrace(string.format("|cffaaaaff[scan]|r body-despawn fallback: cid=%s sawDead=%s stillVisible=%s -> success=true",
							tostring(cidWanted), tostring(sawDead), tostring(stillVisible)))
					end
				end
				scannerTrace(string.format("|cffaaaaff[scan]|r PLAYER_REGEN_ENABLED -> firing MRT_ENCOUNTER_END enc=%s success=%s (kill=%s ago=%.1fs inCombatWith=%s)",
					tostring(endEnc), tostring(success), tostring(lastBossKillID),
					GetTime() - (lastBossKillTime > 0 and lastBossKillTime or GetTime()),
					tostring(inCombatWith)))
				fireMRTEvent("MRT_ENCOUNTER_END", endEnc, M.GetCurrentMapID(), success)
				currentEncounterID = nil
				inCombatWith = nil
				lastBossKillID = nil
				lastBossKillTime = 0
				lastEngageTime = 0
			else
				scannerTrace("|cffaaaaff[scan]|r PLAYER_REGEN_ENABLED but currentEncounterID=nil (no encounter to end)")
			end
		end
	end)
end
local function setupCompatBridge()
	if not (ExRT and ExRT.F and ExRT.F.registerEvent) then return end
	local function getCurrentDiffID()
		if GetInstanceInfo then
			local _, zoneType, difficultyID = GetInstanceInfo()
			difficultyID = difficultyID or 0
			if zoneType == "raid" then
				if difficultyID == 1 then
					return 175
				elseif difficultyID == 2 then
					return 176
				elseif difficultyID == 3 then
					return 193
				elseif difficultyID == 4 then
					return 194
				end
			end
			return difficultyID
		end
		return 0
	end

	local function getCurrentGroupSize()
		if GetInstanceInfo then
			local _, _, _, _, maxPlayers = GetInstanceInfo()
			return maxPlayers or 0
		end
		return 0
	end

	local function dispatch(eventName, ...)
		if not ExRT.Modules then return end
		for _, mod in pairs(ExRT.Modules) do
			local main = mod.main
			if main and type(main[eventName]) == "function"
				and main.events and main.events[eventName]
			then
				local handler = main:GetScript("OnEvent")
				if handler then
					pcall(handler, main, eventName, ...)
				end
			end
		end
	end
	local function traceOn()
		return _G.VMRT and _G.VMRT.DebugReminder and _G.VMRT.DebugReminder.TraceEncounterBridge
	end
	local TRACE_MAX = 200
	local function logTrace(msg)
		if not traceOn() then return end
		print(msg)
		local dr = _G.VMRT and _G.VMRT.DebugReminder
		if not dr then return end
		dr.TraceLog = dr.TraceLog or {}
		local log = dr.TraceLog
		log[#log+1] = string.format("[%.1f] %s", GetTime() or 0, msg)
		while #log > TRACE_MAX do
			tremove(log, 1)
		end
	end
	_G.MRT_TraceEncounterBridgeLog = logTrace
	local function listSubscribers(eventName)
		if not ExRT.Modules then return "?" end
		local hits, misses = {}, {}
		for _, mod in pairs(ExRT.Modules) do
			local main = mod.main
			if main and type(main[eventName]) == "function"
				and main.events and main.events[eventName]
			then
				hits[#hits+1] = mod.name or "?"
			elseif main and type(main[eventName]) == "function" then
				misses[#misses+1] = (mod.name or "?") .. "(no-reg)"
			end
		end
		return table.concat(hits, ",") .. (#misses > 0 and " | skipped: "..table.concat(misses, ",") or "")
	end

	ExRT.F.registerEvent("MRT_ENCOUNTER_START", function(encID, _mapID, _cid, encName)
		if _G.MRT_SetEncounterFlag then _G.MRT_SetEncounterFlag(true) end
		local diffID = getCurrentDiffID()
		local canonicalName = ExRT and ExRT.L and ExRT.L.bossName and encID and ExRT.L.bossName[encID]
		if type(canonicalName) ~= "string" or canonicalName == "" or canonicalName == tostring(encID) then
			canonicalName = encName
		end
		logTrace(string.format("|cffffaa00[bridge]|r MRT_ENCOUNTER_START enc=%s name=%s (raw=%s) diff=%s -> %s",
			tostring(encID), tostring(canonicalName or ""), tostring(encName or ""),
			tostring(diffID), listSubscribers("ENCOUNTER_START")))
		dispatch("ENCOUNTER_START", encID or 0, canonicalName or "", diffID, getCurrentGroupSize())
	end)

	ExRT.F.registerEvent("MRT_ENCOUNTER_END", function(encID, _mapID, success)
		if _G.MRT_SetEncounterFlag then _G.MRT_SetEncounterFlag(false) end
		local diffID = getCurrentDiffID()
		logTrace(string.format("|cffffaa00[bridge]|r MRT_ENCOUNTER_END enc=%s diff=%s success=%s -> %s",
			tostring(encID), tostring(diffID), tostring(success), listSubscribers("ENCOUNTER_END")))
		dispatch("ENCOUNTER_END", encID or 0, "", diffID, getCurrentGroupSize(), success and 1 or 0)
	end)
end
do
  local lastQueuedGUID
  if type(NotifyInspect) == "function" and type(hooksecurefunc) == "function" then
    hooksecurefunc("NotifyInspect", function(unit)
      if not unit then return end
      local guid = type(UnitGUID) == "function" and UnitGUID(unit) or nil
      if guid and (type(UnitIsConnected) ~= "function" or UnitIsConnected(unit)) then
        lastQueuedGUID = guid
      end
    end)
  end
  function _G.MRT_GetQueuedInspectGUID()
    return lastQueuedGUID
  end
end
local function tryCompatSetup()
	pcall(setupCompatEncounter)
	pcall(setupCompatBridge)
end
if _G.MRT and _G.ExRT and _G.ExRT.F and _G.ExRT.F.registerEvent then
	tryCompatSetup()
else
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(self, ev, name)
		if ev == "ADDON_LOADED" and name == "MRT" then
			tryCompatSetup()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end
