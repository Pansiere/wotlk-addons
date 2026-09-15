local mod	= DBM:NewMod("Deathwhisper", "DBM-Icecrown", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4411 $"):sub(12, -3))
mod:SetCreatureID(36855)
mod:SetUsedIcons(4, 5, 6, 7, 8)
mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"SPELL_INTERRUPT",
	"SPELL_SUMMON",
	"SWING_DAMAGE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_TARGET"
)

local canPurge = select(2, UnitClass("player")) == "MAGE"
			or select(2, UnitClass("player")) == "SHAMAN"
			or select(2, UnitClass("player")) == "PRIEST"

local warnAddsSoon					= mod:NewAnnounce("WarnAddsSoon", 2)
local warnDominateMind				= mod:NewTargetAnnounce(71289, 3)
local warnDeathDecay				= mod:NewSpellAnnounce(72108, 2)
local warnSummonSpirit				= mod:NewSpellAnnounce(71426, 2)
local warnReanimating				= mod:NewAnnounce("WarnReanimating", 3)
local warnDarkTransformation		= mod:NewSpellAnnounce(70900, 4)
local warnDarkEmpowerment			= mod:NewSpellAnnounce(70901, 4)
local warnPhase2					= mod:NewPhaseAnnounce(2, 1)	
local warnFrostbolt					= mod:NewCastAnnounce(72007, 2)
local warnTouchInsignificance		= mod:NewAnnounce("WarnTouchInsignificance", 2, 71204, mod:IsTank() or mod:IsHealer())
local warnDarkMartyrdom				= mod:NewSpellAnnounce(72499, 4)

local specWarnCurseTorpor			= mod:NewSpecialWarningYou(71237)
local specWarnDeathDecay			= mod:NewSpecialWarningMove(72108)
local specWarnTouchInsignificance	= mod:NewSpecialWarningStack(71204, nil, 3)
local specWarnVampricMight			= mod:NewSpecialWarningDispel(70674, canPurge)
local specWarnDarkMartyrdom			= mod:NewSpecialWarningMove(72499, mod:IsMelee())
local specWarnFrostbolt				= mod:NewSpecialWarningInterupt(72007, false)
local specWarnVengefulShade			= mod:NewSpecialWarning("SpecWarnVengefulShade", not mod:IsTank())

local timerAdds						= mod:NewTimer(60, "TimerAdds", 61131)
local timerDominateMind				= mod:NewBuffActiveTimer(12, 71289)
local timerDominateMindCD			= mod:NewCDTimer(40, 71289)
local timerSummonSpiritCD			= mod:NewCDTimer(10, 71426, nil, false)
local timerFrostboltCast			= mod:NewCastTimer(4, 72007)
local timerTouchInsignificance		= mod:NewTargetTimer(30, 71204, nil, mod:IsTank() or mod:IsHealer())

local berserkTimer					= mod:NewBerserkTimer(600)

mod:AddBoolOption("SetIconOnDominateMind", true)
mod:AddBoolOption("SetIconOnDeformedFanatic", true)
mod:AddBoolOption("SetIconOnEmpoweredAdherent", false)
mod:AddBoolOption("ShieldHealthFrame", true, "misc")
mod:RemoveOption("HealthFrame")
mod:AddBoolOption("RaidWarningAboutAdds", false, "announce")

local lastDD	= 0
local dominateMindTargets	= {}
local dominateMindIcon 	= 6
local deformedFanatic
local empoweredAdherent
local timeBeforeAddsCome
local ADDS_SIDE_BOTH = 0
local ADDS_SIDE_LEFT = 1
local ADDS_SIDE_RIGHT = 2
local ADDS_SIDE_GATES = 3
local addsSide = ADDS_SIDE_BOTH
local lowBossHealthAddsWarningDisabled = false

function mod:OnCombatStart(delay)
	if self.Options.ShieldHealthFrame then
		DBM.BossHealth:Show(L.name)
		DBM.BossHealth:AddBoss(36855, L.name)
		self:ScheduleMethod(0.5, "CreateShildHPFrame")
	end		
	berserkTimer:Start(-delay)
	timerAdds:Start(5)
	warnAddsSoon:Schedule(2)			-- 3sec pre-warning on start
	self:ScheduleMethod(2, "raidWarningAboutAdds")
	timeBeforeAddsCome = 3
	self:ScheduleMethod(5, "addsTimer")
	if not mod:IsDifficulty("normal10") then
		timerDominateMindCD:Start(27)		-- Sometimes 1 fails at the start, then the next will be applied 70 secs after start ?? :S
	end
	table.wipe(dominateMindTargets)
	dominateMindIcon = 6
	deformedFanatic = nil
	empoweredAdherent = nil
	if mod:IsDifficulty("heroic10") or mod:IsDifficulty("normal10") then
		addsSide = ADDS_SIDE_LEFT
	else
		addsSide = ADDS_SIDE_BOTH
	end	
	lowBossHealthAddsWarningDisabled = false
end

function mod:OnCombatEnd()
	DBM.BossHealth:Clear()
end

do	-- add the additional Shield Bar
	local last = 100
	local function getShieldPercent()
		local guid = UnitGUID("focus")
		if mod:GetCIDFromGUID(guid) == 36855 then 
			last = math.floor(UnitMana("focus")/UnitManaMax("focus") * 100)
			return last
		end
		for i = 0, GetNumRaidMembers(), 1 do
			local unitId = ((i == 0) and "target") or "raid"..i.."target"
			local guid = UnitGUID(unitId)
			if mod:GetCIDFromGUID(guid) == 36855 then
				last = math.floor(UnitMana(unitId)/UnitManaMax(unitId) * 100)
				return last
			end
		end
		return last
	end
	function mod:CreateShildHPFrame()
		DBM.BossHealth:AddBoss(getShieldPercent, L.ShieldPercent)
	end
end

function mod:sendRaidWarningAboutAdds(text)
	if DBM:GetRaidRank() >= 1 and self.Options.RaidWarningAboutAdds then
		SendChatMessage(text, "RAID_WARNING", nil, nil) 	
	end
end

function mod:raidWarningAboutAdds()
	if timeBeforeAddsCome == 3 then
		if addsSide == ADDS_SIDE_BOTH then
			self:sendRaidWarningAboutAdds(L.RaidWarningAdds3Both) 	
		elseif addsSide == ADDS_SIDE_LEFT then
			addsSide = ADDS_SIDE_RIGHT
			self:sendRaidWarningAboutAdds(L.RaidWarningAdds3Left) 	
		elseif addsSide == ADDS_SIDE_RIGHT then
			addsSide = ADDS_SIDE_LEFT
			self:sendRaidWarningAboutAdds(L.RaidWarningAdds3Right) 	
		elseif addsSide == ADDS_SIDE_GATES then
			self:sendRaidWarningAboutAdds(L.RaidWarningAdds3Gates) 	
		end
		
		self:ScheduleMethod(1, "raidWarningAboutAdds")
		timeBeforeAddsCome = 2
	elseif timeBeforeAddsCome == 2 then
		self:sendRaidWarningAboutAdds(L.RaidWarningAdds2)
		self:ScheduleMethod(1, "raidWarningAboutAdds")
		timeBeforeAddsCome = 1
	elseif timeBeforeAddsCome == 1 then
		self:sendRaidWarningAboutAdds(L.RaidWarningAdds1)
		self:ScheduleMethod(1, "raidWarningAboutAdds")
		timeBeforeAddsCome = 0
	elseif timeBeforeAddsCome == 0 then
		self:sendRaidWarningAboutAdds(L.RaidWarningAdds0)
		timeBeforeAddsCome = 3
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			self:ScheduleMethod(42, "raidWarningAboutAdds")
		else
			self:ScheduleMethod(57, "raidWarningAboutAdds")
		end
	end
end

function mod:addsTimer()
	timerAdds:Cancel()
	warnAddsSoon:Cancel()
	if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
		warnAddsSoon:Schedule(40)	-- 5 secs prewarning
		self:ScheduleMethod(45, "addsTimer")
		timerAdds:Start(45)
	else
		warnAddsSoon:Schedule(55)	-- 5 secs prewarning
		self:ScheduleMethod(60, "addsTimer")
		timerAdds:Start()
	end
end

function mod:TrySetTarget()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitGUID("raid"..i.."target") == deformedFanatic then
				deformedFanatic = nil
				SetRaidTarget("raid"..i.."target", 8)
			elseif UnitGUID("raid"..i.."target") == empoweredAdherent then
				empoweredAdherent = nil
				SetRaidTarget("raid"..i.."target", 7)
			end
			if not (deformedFanatic or empoweredAdherent) then
				break
			end
		end
	end
end

do
	local function showDominateMindWarning()
		warnDominateMind:Show(table.concat(dominateMindTargets, "<, >"))
		timerDominateMind:Start()
		timerDominateMindCD:Start()
		table.wipe(dominateMindTargets)
		dominateMindIcon = 6
	end
	
	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpellID(71289) then
			dominateMindTargets[#dominateMindTargets + 1] = args.destName
			if self.Options.SetIconOnDominateMind then
				self:SetIcon(args.destName, dominateMindIcon, 12)
				dominateMindIcon = dominateMindIcon - 1
			end
			self:Unschedule(showDominateMindWarning)
			if mod:IsDifficulty("heroic10") or mod:IsDifficulty("normal25") or (mod:IsDifficulty("heroic25") and #dominateMindTargets >= 3) then
				showDominateMindWarning()
			else
				self:Schedule(0.9, showDominateMindWarning)
			end
		elseif args:IsSpellID(71001, 72108, 72109, 72110) then
			if args:IsPlayer() then
				specWarnDeathDecay:Show()
			end
			if (GetTime() - lastDD > 5) then
				warnDeathDecay:Show()
				lastDD = GetTime()
			end
		elseif args:IsSpellID(71237) and args:IsPlayer() then
			specWarnCurseTorpor:Show()
		elseif args:IsSpellID(70674) and not args:IsDestTypePlayer() and (UnitName("target") == L.Fanatic1 or UnitName("target") == L.Fanatic2 or UnitName("target") == L.Fanatic3) then
			specWarnVampricMight:Show(args.destName)
		elseif args:IsSpellID(71204) then
			warnTouchInsignificance:Show(args.spellName, args.destName, args.amount or 1)
			timerTouchInsignificance:Start(args.destName)
			if args:IsPlayer() and (args.amount or 1) >= 3 and (mod:IsDifficulty("normal10") or mod:IsDifficulty("normal25")) then
				specWarnTouchInsignificance:Show(args.amount)
			elseif args:IsPlayer() and (args.amount or 1) >= 5 and (mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25")) then
				specWarnTouchInsignificance:Show(args.amount)
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70842) then
		warnPhase2:Show()
		self:UnscheduleMethod("addsTimer")
		self:UnscheduleMethod("raidWarningAboutAdds")
		timerAdds:Cancel()
		warnAddsSoon:Cancel()
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			self:ScheduleMethod(45, "addsTimer")
			timerAdds:Start(45)
			warnAddsSoon:Schedule(42)
			self:ScheduleMethod(42, "raidWarningAboutAdds")
			if mod:IsDifficulty("heroic10") then
				addsSide = ADDS_SIDE_GATES
			else
				addsSide = ADDS_SIDE_BOTH --ADDS_SIDE_LEFT - seems to be randomized, no longer can be said for sure
			end
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71420, 72007, 72501, 72502) then
		warnFrostbolt:Show()
		timerFrostboltCast:Start()
	elseif args:IsSpellID(70900) then
		warnDarkTransformation:Show()
		if self.Options.SetIconOnDeformedFanatic then
			deformedFanatic = args.sourceGUID
			self:TrySetTarget()
		end
	elseif args:IsSpellID(70901) then
		warnDarkEmpowerment:Show()
		if self.Options.SetIconOnEmpoweredAdherent then
			empoweredAdherent = args.sourceGUID
			self:TrySetTarget()
		end
	elseif args:IsSpellID(72499, 72500, 72497, 72496) then
		warnDarkMartyrdom:Show()
		specWarnDarkMartyrdom:Show()
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and (args.extraSpellId == 71420 or args.extraSpellId == 72007 or args.extraSpellId == 72501 or args.extraSpellId == 72502) then
		timerFrostboltCast:Cancel()
	end
end

local lastSpirit = 0
function mod:SPELL_SUMMON(args)
	if args:IsSpellID(71426) then -- Summon Vengeful Shade
		if time() - lastSpirit > 5 then
			warnSummonSpirit:Show()
			timerSummonSpiritCD:Start()
			lastSpirit = time()
		end
	end
end

function mod:SWING_DAMAGE(args)
	if args:IsPlayer() and args:GetSrcCreatureID() == 38222 then
		specWarnVengefulShade:Show()
	end
end

function mod:UNIT_TARGET()
	if empoweredAdherent or deformedFanatic then
		self:TrySetTarget()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellReanimatedFanatic or msg:find(L.YellReanimatedFanatic) then
		warnReanimating:Show()
	end
end

--values subject to tuning depending on dps and his health pool
function mod:UNIT_HEALTH(uId)
	if (not lowBossHealthAddsWarningDisabled) and (self:GetUnitCreatureId(uId) == 36855) and (UnitHealth(uId) / UnitHealthMax(uId) <= 0.20) then
		self:UnscheduleMethod("raidWarningAboutAdds")
		lowBossHealthAddsWarningDisabled = true
	end
end