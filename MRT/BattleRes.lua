local GlobalAddonName, ExRT = ...
if ExRT.isClassic and not ExRT.isLK then
	return
end

local VMRT = nil

local GetSpellCharges, GetTime, floor, GetSpellTexture = ExRT.F.GetSpellCharges or GetSpellCharges, GetTime, floor, GetSpellTexture
local GetSpellCooldown = GetSpellCooldown
local function IsDruidBattleResFallback()
	if not ExRT.isWotLKOnly then return false end
	local _, classFile = UnitClass("player")
	return classFile == "DRUID"
end
local REBIRTH_CD = 600
local REBIRTH_RANKS = {
	[20484]=true, [20739]=true, [20742]=true, [20747]=true,
	[20748]=true, [26994]=true, [48477]=true,
}
local druidCDs = {}

local function ShortName(name)
	if not name or name == "" then return nil end
	if ExRT and ExRT.F and ExRT.F.delUnitNameServer then
		return ExRT.F.delUnitNameServer(name)
	end
	return (strsplit("-",name))
end

local function IsUnitEligibleDruid(unit, name)
	if not name then return false end
	if UnitIsConnected and not UnitIsConnected(unit) then return false end
	if UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit) then return false end
	if UnitInRange then
		local inRange, checked = UnitInRange(unit)
		if checked then
			if not inRange then return false end
		end
	end
	return true
end

local function CollectCurrentDruids()
	local out = {} -- key: shortName, value: name
	local raidNum = GetNumRaidMembers and GetNumRaidMembers() or 0
	local partyNum = GetNumPartyMembers and GetNumPartyMembers() or 0
	if raidNum > 0 then
		for i=1,raidNum do
			local name,_,_,_,_,classFile = GetRaidRosterInfo(i)
			if classFile == "DRUID" and name then
				local unit = "raid"..i
				if IsUnitEligibleDruid(unit, name) then
					out[ShortName(name)] = name
				end
			end
		end
	elseif partyNum > 0 then
		do
			local _, classFile = UnitClass("player")
			if classFile == "DRUID" then
				local name = UnitName("player")
				if name and IsUnitEligibleDruid("player", name) then
					out[ShortName(name)] = name
				end
			end
		end
		for i=1,partyNum do
			local unit = "party"..i
			local _, cf = UnitClass(unit)
			if cf == "DRUID" then
				local name = UnitName(unit)
				if name and IsUnitEligibleDruid(unit, name) then
					out[ShortName(name)] = name
				end
			end
		end
	else
		local _, classFile = UnitClass("player")
		if classFile == "DRUID" then
			local name = UnitName("player")
			if name then
				out[ShortName(name)] = name
			end
		end
	end
	return out
end

local function NoteRebirthCast(sourceGUID, sourceName)
	local key = ShortName(sourceName)
	if not key then return end
	druidCDs[key] = {
		name = sourceName,
		cdEnd = GetTime() + REBIRTH_CD,
	}
end

local function NoteRemoteCD(sender, remaining)
	local key = ShortName(sender)
	if not key then return end
	if not remaining or remaining <= 0 then
		druidCDs[key] = nil
		return
	end
	if remaining > REBIRTH_CD + 5 then
		remaining = REBIRTH_CD
	end
	druidCDs[key] = {
		name = sender,
		cdEnd = GetTime() + remaining,
	}
end
local function GetAggregateBattleRes()
	local currentDruids = CollectCurrentDruids()
	local total = 0
	for _ in pairs(currentDruids) do total = total + 1 end
	if total == 0 then
		for k in pairs(druidCDs) do druidCDs[k] = nil end
		return nil
	end

	if IsDruidBattleResFallback() then
		local cdStart, cdDuration = GetSpellCooldown(20484)
		local playerName = UnitName("player")
		local playerKey = ShortName(playerName)
		if playerKey and cdDuration and cdDuration > 1.5 then
			local cdEnd = cdStart + cdDuration
			local existing = druidCDs[playerKey]
			if not existing or existing.cdEnd < cdEnd - 5 then
				druidCDs[playerKey] = { name = playerName, cdEnd = cdEnd }
			end
		elseif playerKey then
			druidCDs[playerKey] = nil
		end
	end

	local now = GetTime()
	for key in pairs(druidCDs) do
		if not currentDruids[key] then
			druidCDs[key] = nil
		end
	end

	local nOnCD = 0
	local minCDEnd
	for key, info in pairs(druidCDs) do
		if info.cdEnd <= now then
			druidCDs[key] = nil
		else
			nOnCD = nOnCD + 1
			if not minCDEnd or info.cdEnd < minCDEnd then
				minCDEnd = info.cdEnd
			end
		end
	end

	local charges = total - nOnCD
	if charges < 0 then charges = 0 end
	return charges, total, minCDEnd
end

local module = ExRT:New("BattleRes",ExRT.L.BattleRes)
local ELib,L = ExRT.lib,ExRT.L

function module.options:Load()
	self:CreateTilte()

	self.enableChk = ELib:Check(self,L.Enable,VMRT.BattleRes.enabled):Point(15,-30):AddColorState():OnClick(function(self)
		if self:GetChecked() then
			VMRT.BattleRes.enabled = true
			module:Enable()
		else
			VMRT.BattleRes.enabled = nil
			module:Disable()
		end
	end)

	self.fixChk = ELib:Check(self,L.BattleResFix,VMRT.BattleRes.fix):Point(15,-55):OnClick(function(self)
		if self:GetChecked() then
			VMRT.BattleRes.fix = true
			if VMRT.BattleRes.enabled then
				local charges, maxCharges, started, duration = GetSpellCharges(20484)
				if not maxCharges or maxCharges == 0 then
					module.frame:Hide()
					module:ResetStates()
				end
			else
				module.frame:Hide()
				module:ResetStates()
			end
			module.frame:SetMovable(false)
		else
			VMRT.BattleRes.fix = nil
			if VMRT.BattleRes.enabled then
				module.frame:Show()
			end
			module.frame:SetMovable(true)
		end
	end)

	self.SliderScale = ELib:Slider(self,L.BattleResScale):Size(640):Point("TOP",0,-95):Range(5,200):SetTo(VMRT.BattleRes.Scale or 100):OnChange(function(self,event)
		event = event - event%1
		VMRT.BattleRes.Scale = event
		ExRT.F.SetScaleFix(module.frame,event/100)
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.SliderAlpha = ELib:Slider(self,L.BattleResAlpha):Size(640):Point("TOP",0,-130):Range(0,100):SetTo(VMRT.BattleRes.Alpha or 100):OnChange(function(self,event)
		event = event - event%1
		VMRT.BattleRes.Alpha = event
		module.frame:SetAlpha(event/100)
		self.tooltipText = event
		self:tooltipReload(self)
	end)

	self.shtml1 = ELib:Text(self,L.BattleResHelp,12):Size(650,0):Point("TOP",0,-165):Top()

	self.hideTimerChk = ELib:Check(self,L.BattleResHideTime,VMRT.BattleRes.HideTimer):Point(15,-200):Tooltip(L.BattleResHideTimeTooltip):OnClick(function(self)
		if self:GetChecked() then
			VMRT.BattleRes.HideTimer = true
			module.frame.time:Hide()
		else
			VMRT.BattleRes.HideTimer = nil
			module.frame.time:Show()
		end
	end)

	self.frameStrataDropDown = ELib:DropDown(self,275,8):Point(15,-225):Size(260):SetText(L.S_Strata)
	local function FrameStrataDropDown_SetVaule(_,arg)
		VMRT.BattleRes.Strata = arg
		ELib:DropDownClose()
		for i=1,#self.frameStrataDropDown.List do
			self.frameStrataDropDown.List[i].checkState = arg == self.frameStrataDropDown.List[i].arg1
		end
		module.frame:SetFrameStrata(arg)
	end
	for i,strataString in ipairs({"BACKGROUND","LOW","MEDIUM","HIGH","DIALOG","FULLSCREEN","FULLSCREEN_DIALOG","TOOLTIP"}) do
		self.frameStrataDropDown.List[i] = {
			text = strataString,
			checkState = VMRT.BattleRes.Strata == strataString,
			radio = true,
			arg1 = strataString,
			func = FrameStrataDropDown_SetVaule,
		}
	end
end

function module:Enable()
	if not VMRT.BattleRes.HideTimer then
		module.frame.cooldown.noCooldownCount = true
	else
		module.frame.cooldown.noCooldownCount = nil
	end
	module:RegisterTimer()
	if ExRT.isWotLKOnly then
		module:RegisterEvents("COMBAT_LOG_EVENT_UNFILTERED","SPELL_UPDATE_COOLDOWN","PLAYER_ENTERING_WORLD","GROUP_ROSTER_UPDATE")
		module:RequestRaidSync()
	end
	if not VMRT.BattleRes.fix then
		module:ResetStates()
		module.frame:Show()
		module.frame:SetMovable(true)
	else
		module.frame:SetMovable(false)
	end
end
function module:Disable()
	module:UnregisterTimer()
	if ExRT.isWotLKOnly then
		module:UnregisterEvents("COMBAT_LOG_EVENT_UNFILTERED","SPELL_UPDATE_COOLDOWN","PLAYER_ENTERING_WORLD","GROUP_ROSTER_UPDATE")
	end
	module.frame:Hide()
end
if ExRT.isWotLKOnly then
	function module.main.COMBAT_LOG_EVENT_UNFILTERED(_, eventType, _, sourceGUID, sourceName, _, _, _, _, _, _, spellID)
		if eventType ~= "SPELL_CAST_SUCCESS" and eventType ~= "SPELL_RESURRECT" then return end
		if not REBIRTH_RANKS[spellID] then return end
		NoteRebirthCast(sourceGUID, sourceName)
	end
end
local lastBroadcastRem, lastBroadcastTime = nil, 0
local heartbeatTimer

local function ScheduleHeartbeat()
	if heartbeatTimer then return end
	heartbeatTimer = C_Timer.NewTimer(30, function()
		heartbeatTimer = nil
		if VMRT and VMRT.BattleRes and VMRT.BattleRes.enabled and IsDruidBattleResFallback() then
			module:BroadcastOwnCD(true)
			ScheduleHeartbeat()
		end
	end)
end

function module:BroadcastOwnCD(force)
	if not IsDruidBattleResFallback() then return end
	if (GetNumRaidMembers and GetNumRaidMembers() or 0) == 0 and (GetNumPartyMembers and GetNumPartyMembers() or 0) == 0 then
		return
	end
	local cdStart, cdDuration = GetSpellCooldown(20484)
	local rem = 0
	if cdStart and cdDuration and cdDuration > 1.5 then
		rem = (cdStart + cdDuration) - GetTime()
		if rem < 0 then rem = 0 end
	end
	rem = floor(rem + 0.5)
	local now = GetTime()
	if not force and rem == lastBroadcastRem and (now - lastBroadcastTime) < 5 then
		return
	end
	lastBroadcastRem = rem
	lastBroadcastTime = now
	local pn = (ExRT.F.GetOwnPartyNum and ExRT.F.GetOwnPartyNum() or 1) + 1
	ExRT.F.SendExMsgExt({prefixNum=pn},"battleres","SQ\t"..rem)
end

function module:RequestRaidSync()
	if not IsDruidBattleResFallback() then
		if (GetNumRaidMembers and GetNumRaidMembers() or 0) == 0 and (GetNumPartyMembers and GetNumPartyMembers() or 0) == 0 then
			return
		end
		ExRT.F.SendExMsg("battleres","REQ")
		return
	end
	ExRT.F.SendExMsg("battleres","REQ")
	module:BroadcastOwnCD(true)
	ScheduleHeartbeat()
end

function module:addonMessage(sender, prefix, subPrefix, ...)
	if prefix ~= "battleres" then return end
	if sender and ShortName(sender) == ShortName(UnitName("player")) then
		return
	end
	if subPrefix == "SQ" then
		local rem = tonumber((select(1,...)) or "")
		if rem then NoteRemoteCD(sender, rem) end
	elseif subPrefix == "REQ" then
		if VMRT and VMRT.BattleRes and VMRT.BattleRes.enabled and IsDruidBattleResFallback() then
			module:BroadcastOwnCD(true)
		end
	end
end

if ExRT.isWotLKOnly then
	function module.main:SPELL_UPDATE_COOLDOWN()
		if not (VMRT and VMRT.BattleRes and VMRT.BattleRes.enabled) then return end
		if not IsDruidBattleResFallback() then return end
		module:BroadcastOwnCD(false)
		ScheduleHeartbeat()
	end

	function module.main:PLAYER_ENTERING_WORLD()
		if VMRT and VMRT.BattleRes and VMRT.BattleRes.enabled then
			module:RequestRaidSync()
		end
	end

	function module.main:GROUP_ROSTER_UPDATE()
		if VMRT and VMRT.BattleRes and VMRT.BattleRes.enabled then
			module:RequestRaidSync()
		end
	end
end

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.BattleRes = VMRT.BattleRes or {}

	if VMRT.BattleRes.Left and VMRT.BattleRes.Top then
		module.frame:ClearAllPoints()
		module.frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.BattleRes.Left,VMRT.BattleRes.Top)
	end
	if VMRT.BattleRes.Alpha then module.frame:SetAlpha(VMRT.BattleRes.Alpha/100) end
	if VMRT.BattleRes.Scale then module.frame:SetScale(VMRT.BattleRes.Scale/100) end

	if VMRT.BattleRes.HideTimer then
		module.frame.time:Hide()
	end

	if VMRT.BattleRes.enabled then
		module:Enable()
	end

	VMRT.BattleRes.Strata = VMRT.BattleRes.Strata or "HIGH"
	module.frame:SetFrameStrata(VMRT.BattleRes.Strata)
	module:RegisterAddonMessage()
end

do
	local stateHidden = true
	local is0Charges
	local isCooldownHidden
	local cooldownStarted, cooldownDur, chargesNow
	function module:ResetStates()
		stateHidden = true
	end
	if ExRT.isWotLKOnly then
		function module:timer(elapsed)
			local charges, total, minCDEnd = GetAggregateBattleRes()
			if not charges or total == 0 then
				if not stateHidden then
					module.frame.time:SetText("")
					module.frame.charge:SetText("")
					module.frame.cooldown:Hide()
					chargesNow = nil
					isCooldownHidden = true
					cooldownStarted = nil
					cooldownDur = nil
					stateHidden = true
				end
				module.frame:Hide()
				return
			elseif stateHidden then
				module.frame:Show()
				stateHidden = false
			end

			if charges > 0 then
				module.frame.time:SetText("")
				if chargesNow ~= charges then
					module.frame.charge:SetText(charges)
					chargesNow = charges
				end
				if not isCooldownHidden then
					module.frame.cooldown:Hide()
					isCooldownHidden = true
				end
				if is0Charges then
					module.frame.charge:SetTextColor(1,1,1,1)
					is0Charges = false
				end
			else
				local rem = (minCDEnd or GetTime()) - GetTime()
				if rem < 0 then rem = 0 end
				module.frame.time:SetFormattedText("%d:%02d", floor(rem/60), rem%60)
				if chargesNow ~= 0 then
					module.frame.charge:SetText(0)
					chargesNow = 0
				end
				if not is0Charges then
					module.frame.charge:SetTextColor(1,0,0,1)
					is0Charges = true
				end
				if isCooldownHidden then
					module.frame.cooldown:Show()
					isCooldownHidden = false
				end
				local startVirtual = (minCDEnd or GetTime()) - REBIRTH_CD
				if cooldownStarted ~= startVirtual or cooldownDur ~= REBIRTH_CD then
					module.frame.cooldown:SetCooldown(startVirtual, REBIRTH_CD)
					cooldownStarted = startVirtual
					cooldownDur = REBIRTH_CD
				end
			end
		end
	else
		function module:timer(elapsed)
			local charges, maxCharges, started, duration = GetSpellCharges(20484)
			if charges == 0 and maxCharges == 0 then
				charges, maxCharges, started, duration = nil
			end
			if not charges and IsDruidBattleResFallback() then
				local cdStart, cdDuration = GetSpellCooldown(20484)
				if cdDuration and cdDuration > 1.5 then
					charges, maxCharges = 0, 1
					started, duration = cdStart, cdDuration
				else
					charges, maxCharges = 1, 1
					started, duration = 0, 0
				end
			end
			if not charges then
				if not stateHidden then
					if VMRT.BattleRes.fix then
						module.frame:Hide()
					end
					module.frame.time:SetText("")
					module.frame.charge:SetText("")
					module.frame.cooldown:Hide()
					chargesNow = nil
					isCooldownHidden = true
					cooldownStarted = nil
					cooldownDur = nil
					stateHidden = true
				end
				return
			elseif stateHidden then
				module.frame:Show()
				stateHidden = false
			end

			if maxCharges == charges then
				module.frame.time:SetFormattedText("")
				if chargesNow ~= charges then
					module.frame.charge:SetText(charges)
					chargesNow = charges
				end
				if not isCooldownHidden then
					module.frame.cooldown:Hide()
					isCooldownHidden = true
				end
			else
				local time = duration - (GetTime() - started)

				module.frame.time:SetFormattedText("%d:%02d", floor(time/60), time%60)
				if chargesNow ~= charges then
					module.frame.charge:SetText(charges)
					chargesNow = charges
				end
				if isCooldownHidden then
					module.frame.cooldown:Show()
					isCooldownHidden = false
				end
				if (cooldownStarted ~= started) or (cooldownDur ~= duration) then
					module.frame.cooldown:SetCooldown(started,duration)
					cooldownStarted = started
					cooldownDur = duration
				end
			end
			if charges == 0 and not is0Charges then
				module.frame.charge:SetTextColor(1,0,0,1)
				is0Charges = true
			elseif charges ~= 0 and is0Charges then
				module.frame.charge:SetTextColor(1,1,1,1)
				is0Charges = false
			end
		end
	end
end

do
	local frame = CreateFrame("Frame","MRTBattleRes",UIParent)
	module.frame = frame
	frame:Hide()
	frame:SetSize(64,64)
	frame:SetPoint("TOP", 0,-200)
	frame:SetFrameStrata("HIGH")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if self:IsMovable() then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		VMRT.BattleRes.Left = self:GetLeft()
		VMRT.BattleRes.Top = self:GetTop()
	end)

	frame.texture = frame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetTexture((ExRT.F.GetSpellTextureSafe and ExRT.F.GetSpellTextureSafe(20484)) or GetSpellTexture(20484) or "Interface\\Icons\\Spell_Nature_Reincarnation")
	frame.texture:SetAllPoints()
	frame.texture:SetTexCoord(.1,.9,.1,.9)

	frame.backdrop = CreateFrame("Frame",nil,frame, BackdropTemplateMixin and "BackdropTemplate")
	frame.backdrop:SetPoint("TOPLEFT",-3,3)
	frame.backdrop:SetPoint("BOTTOMRIGHT",3,-3)
	frame.backdrop:SetBackdrop({bgFile = "",edgeFile = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\UI-Tooltip-Border_grey",tile = true,tileSize = 16,edgeSize = 16,insets = {left = 3,right = 3,top = 3,bottom = 3}})
	frame.backdrop:SetBackdropBorderColor(.3,.3,.3)

	frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.cooldown:SetHideCountdownNumbers(true)
	frame.cooldown:SetAllPoints()
	frame.cooldown:SetDrawEdge(false)
	frame.cooldown:SetFrameLevel(40)
	frame.texts = CreateFrame("Frame",nil,frame)
	frame.texts:SetAllPoints()
	frame.texts:SetFrameLevel(50)
	frame.time = frame.texts:CreateFontString(nil,"ARTWORK","ExRTFontNormal")
	frame.time:SetAllPoints()
	frame.time:SetJustifyH("CENTER")
	frame.time:SetJustifyV("MIDDLE")
	frame.time:SetFont(frame.time:GetFont() or (GameFontNormal and GameFontNormal:GetFont()) or STANDARD_TEXT_FONT,18,"OUTLINE")
	frame.time:SetTextColor(1,1,1,1)
	frame.charge = frame.texts:CreateFontString(nil,"ARTWORK","ExRTFontNormal")
	frame.charge:SetAllPoints()
	frame.charge:SetJustifyH("RIGHT")
	frame.charge:SetJustifyV("BOTTOM")
	frame.charge:SetFont(frame.charge:GetFont() or (GameFontNormal and GameFontNormal:GetFont()) or STANDARD_TEXT_FONT,16,"OUTLINE")
	frame.charge:SetShadowOffset(1,-1)
	frame.charge:SetTextColor(1,1,1,1)

end
