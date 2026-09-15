local mod	= DBM:NewMod("Putricide", "DBM-Icecrown", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4408 $"):sub(12, -3))
mod:SetCreatureID(36678)
mod:RegisterCombat("yell", L.YellPull)
mod:SetMinSyncRevision(3860)
mod:SetUsedIcons(5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REFRESH",
	"SPELL_AURA_REMOVED",
	"UNIT_HEALTH",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

local warnSlimePuddle				= mod:NewSpellAnnounce(70341, 2)
local warnUnstableExperimentSoon	= mod:NewSoonAnnounce(70351, 3)
local warnUnstableExperiment		= mod:NewSpellAnnounce(70351, 4)
local warnVolatileOozeAdhesive		= mod:NewTargetAnnounce(70447, 3)
local warnGaseousBloat				= mod:NewTargetAnnounce(70672, 3)
local warnPhase2Soon				= mod:NewAnnounce("WarnPhase2Soon", 2)
local warnTearGas					= mod:NewSpellAnnounce(71617, 2)		-- Phase transition normal
local warnVolatileExperiment		= mod:NewSpellAnnounce(72840, 4)		-- Phase transition heroic
local warnMalleableGoo				= mod:NewSpellAnnounce(72295, 2)		-- Phase 2 ability
local warnChokingGasBomb			= mod:NewSpellAnnounce(71255, 3)		-- Phase 2 ability
local warnPhase3Soon				= mod:NewAnnounce("WarnPhase3Soon", 2)
local warnMutatedPlague				= mod:NewAnnounce("WarnMutatedPlague", 2, 72451, mod:IsTank() or mod:IsHealer()) -- Phase 3 ability
local warnUnboundPlague				= mod:NewTargetAnnounce(72856, 3)			-- Heroic Ability

local specWarnVolatileOozeAdhesive	= mod:NewSpecialWarningYou(70447)
local specWarnGaseousBloat			= mod:NewSpecialWarningYou(70672)
local specWarnVolatileOozeOther		= mod:NewSpecialWarningTarget(70447, false)
local specWarnGaseousBloatOther		= mod:NewSpecialWarningTarget(70672, false)
local specWarnMalleableGoo			= mod:NewSpecialWarning("SpecWarnMalleableGoo")
local specWarnMalleableGooNear		= mod:NewSpecialWarning("SpecWarnMalleableGooNear")
local specWarnChokingGasBomb		= mod:NewSpecialWarningSpell(71255, mod:IsTank())
local specWarnMalleableGooCast		= mod:NewSpecialWarningSpell(72295, false)
local specWarnOozeVariable			= mod:NewSpecialWarningYou(70352)		-- Heroic Ability
local specWarnGasVariable			= mod:NewSpecialWarningYou(70353)		-- Heroic Ability
local specWarnUnboundPlague			= mod:NewSpecialWarningYou(72856)		-- Heroic Ability

local timerGaseousBloat				= mod:NewTargetTimer(20, 70672)			-- Duration of debuff
local timerSlimePuddleCD			= mod:NewCDTimer(35, 70341)				-- Approx
local timerUnstableExperimentCD		= mod:NewNextTimer(38, 70351)			-- Used every 38 seconds exactly except after phase changes
local timerChokingGasBombCD			= mod:NewNextTimer(35, 71255) -- On Truewow it's between 35 and 40 seconds
local timerMalleableGooCD			= mod:NewCDTimer(25, 72295) -- On Truewow it's between 21 and 26 seconds since start of phase 2 and between 25 and 30 seconds after first Malleable Goo is cast
local timerTearGas					= mod:NewBuffActiveTimer(16, 71615)
local timerPotions					= mod:NewBuffActiveTimer(30, 73122)
local timerMutatedPlagueCD			= mod:NewCDTimer(10, 72451)				-- 10 to 11
local timerUnboundPlagueCD			= mod:NewNextTimer(60, 72856)
local timerUnboundPlague			= mod:NewBuffActiveTimer(12, 72856)		-- Heroic Ability: we can't keep the debuff 60 seconds, so we have to switch at 12-15 seconds. Otherwise the debuff does to much damage!

-- buffs from "Drink Me"
local timerMutatedSlash				= mod:NewTargetTimer(20, 70542)
local timerRegurgitatedOoze			= mod:NewTargetTimer(20, 70539)

local berserkTimer					= mod:NewBerserkTimer(600)

local soundGaseousBloat 			= mod:NewSound(72455)

mod:AddBoolOption("OozeAdhesiveIcon")
mod:AddBoolOption("GaseousBloatIcon")
mod:AddBoolOption("MalleableGooIcon")
mod:AddBoolOption("UnboundPlagueIcon")					-- icon on the player with active buff
mod:AddBoolOption("GooArrow")
mod:AddBoolOption("YellOnMalleableGoo", true, "announce")
mod:AddBoolOption("YellOnUnbound", false, "announce")
mod:AddBoolOption("BypassLatencyCheck", false)--Use old scan method without syncing or latency check (less reliable but not dependant on other DBM users in raid)
mod:AddBoolOption("SayAboutPhase3", false, "announce")
mod:AddBoolOption("WhisperToGaseousBloatTarget", false, "announce")
mod:AddBoolOption("SayGooSoon", false, "announce")

local warned_preP2 = false
local warned_preP3 = false
local spamPuddle = 0
local spamGas = 0
local phase = 0


function mod:OnCombatStart(delay)
	berserkTimer:Start(-delay)
	timerSlimePuddleCD:Start(10-delay)
	timerUnstableExperimentCD:Start(30-delay)
	warnUnstableExperimentSoon:Schedule(25-delay)
	warned_preP2 = false
	warned_preP3 = false
	phase = 1
	if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
		timerUnboundPlagueCD:Start(10-delay)
	end
end

function mod:MalleableGooTarget()
	local targetname = self:GetBossTarget(36678)
	if not targetname then return end
	if mod:LatencyCheck() then--Only send sync if you have low latency.
		self:SendSync("GooOn", targetname)
	end
end

function mod:OldMalleableGooTarget()
	local targetname = self:GetBossTarget(36678)
	if not targetname then
		return
	end
	if self.Options.MalleableGooIcon then
		self:SetIcon(targetname, 6, 10)
	end
	if targetname == UnitName("player") then
		specWarnMalleableGoo:Show()
		if self.Options.YellOnMalleableGoo then
			SendChatMessage(L.YellMalleable, "SAY")
		end
	elseif targetname then
		local uId = DBM:GetRaidUnitId(targetname)
		if uId then
			local inRange = CheckInteractDistance(uId, 2)
			local x, y = GetPlayerMapPosition(uId)
			if x == 0 and y == 0 then
				SetMapToCurrentZone()
				x, y = GetPlayerMapPosition(uId)
			end
			if inRange then
				specWarnMalleableGooNear:Show()
				if self.Options.GooArrow then
					DBM.Arrow:ShowRunAway(x, y, 10, 5)
				end
			end
		end
	end
end

function mod:startMalleableGooTimer(cdTime)
	timerMalleableGooCD:Cancel()
	timerMalleableGooCD:Start(cdTime)
	self:UnscheduleMethod("WarnSayGooSoon")
	self:ScheduleMethod(cdTime - 3, "WarnSayGooSoon")
end
function mod:cancelMalleableGooTimer()
	timerMalleableGooCD:Cancel()
	self:UnscheduleMethod("WarnSayGooSoon")
end


function mod:SPELL_CAST_START(args)
	if args:IsSpellID(70351, 71966, 71967, 71968) then
		warnUnstableExperimentSoon:Cancel()
		warnUnstableExperiment:Show()
		timerUnstableExperimentCD:Start()
		warnUnstableExperimentSoon:Schedule(33)
	elseif args:IsSpellID(71617) then				--Tear Gas, normal phase change trigger
		warnTearGas:Show()
		warnUnstableExperimentSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		self:cancelMalleableGooTimer()
		--timerMalleableGooCD:Cancel()
		--timerSlimePuddleCD:Cancel()
		timerChokingGasBombCD:Cancel()
		timerUnboundPlagueCD:Cancel()
	elseif args:IsSpellID(72842, 72843) then		--Volatile Experiment (heroic phase change begin)
		warnVolatileExperiment:Show()
		warnUnstableExperimentSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		self:cancelMalleableGooTimer()
		--timerMalleableGooCD:Cancel()
		timerSlimePuddleCD:Cancel()
		timerChokingGasBombCD:Cancel()
		timerUnboundPlagueCD:Cancel()
	elseif args:IsSpellID(72851, 72852) then		--Create Concoction (Heroic phase change end)
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
		timerSlimePuddleCD:Cancel()
		warnVolatileExperiment:Show()
		warnUnstableExperimentSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		timerChokingGasBombCD:Cancel()
			self:startMalleableGooTimer(30)
			timerUnboundPlagueCD:Start(50)
			self:ScheduleMethod(30, "NextPhase")	--May need slight tweaking +- a second or two
			timerPotions:Start()
		end
	elseif args:IsSpellID(73121, 73122) then		--Guzzle Potions (Heroic phase change end)
		timerSlimePuddleCD:Cancel()
		warnVolatileExperiment:Show()
		warnUnstableExperimentSoon:Cancel()
		timerUnstableExperimentCD:Cancel()
		timerChokingGasBombCD:Cancel()
		if mod:IsDifficulty("heroic10") then
			self:startMalleableGooTimer(30)
			self:ScheduleMethod(30, "NextPhase")	--May need slight tweaking +- a second or two
			timerPotions:Start()
		elseif mod:IsDifficulty("heroic25") then
			self:startMalleableGooTimer(30)
			self:ScheduleMethod(30, "NextPhase")
			timerPotions:Start(20)
		end
	end
end

function mod:NextPhase()
	phase = phase + 1
	if phase == 2 then
		warnUnstableExperimentSoon:Schedule(15)
		timerUnstableExperimentCD:Start(20)
		timerSlimePuddleCD:Start(12)
		--timerMalleableGooCD:Start(5)
		--timerMalleableGooCD:Start(21) -- On Truewow first Malleable Goo is cast between 21 and 26 seconds
		timerChokingGasBombCD:Start(16)
		self:startMalleableGooTimer(25)
		--if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
		--else
		--	self:startMalleableGooTimer(21)
		--end
	elseif phase == 3 then
		--timerSlimePuddleCD:Start(15)
		--timerMalleableGooCD:Start(9)
		timerSlimePuddleCD:Start(timerSlimePuddleCD:GetTime() + 30) --On Truewow all events are postponed by 30 seconds
		--timerMalleableGooCD:Start(timerMalleableGooCD:GetTime() + 30)
		self:startMalleableGooTimer(25)
		timerChokingGasBombCD:Start(30)
		timerMutatedPlagueCD:Start(3)

		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			timerUnboundPlagueCD:Start(50)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(70341) and GetTime() - spamPuddle > 5 then
		warnSlimePuddle:Show()
		-- if phase == 3 then
		-- 	timerSlimePuddleCD:Start(20)--In phase 3 it's faster
		-- else
		-- 	timerSlimePuddleCD:Start()
		-- end
		timerSlimePuddleCD:Start()
		spamPuddle = GetTime()
	elseif args:IsSpellID(71255) then
		warnChokingGasBomb:Show()
		specWarnChokingGasBomb:Show()
		timerChokingGasBombCD:Start()
	elseif args:IsSpellID(72855, 72856, 70911) then
		timerUnboundPlagueCD:Start()
	elseif args:IsSpellID(72615, 72295, 74280, 74281) then
		--Malleable Goo timer won't start because there are no events in combat log on Truewow
		warnMalleableGoo:Show()
		specWarnMalleableGooCast:Show()
		
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			self:startMalleableGooTimer(20)
			--timerMalleableGooCD:Start(20)
		else
			self:startMalleableGooTimer(25)
			-- timerMalleableGooCD:Start()
		end
		
		if self.Options.BypassLatencyCheck then
			self:ScheduleMethod(0.1, "OldMalleableGooTarget")
		else
			self:ScheduleMethod(0.1, "MalleableGooTarget")
		end
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(70447, 72836, 72837, 72838) then--Green Slime
		warnVolatileOozeAdhesive:Show(args.destName)
		specWarnVolatileOozeOther:Show(args.destName)
		if args:IsPlayer() then
			specWarnVolatileOozeAdhesive:Show()
		end
		if self.Options.OozeAdhesiveIcon then
			self:SetIcon(args.destName, 8, 8)
		end
	elseif args:IsSpellID(70672, 72455, 72832, 72833) then	--Red Slime
		warnGaseousBloat:Show(args.destName)
		specWarnGaseousBloatOther:Show(args.destName)
		timerGaseousBloat:Start(args.destName)
		if args:IsPlayer() then
			specWarnGaseousBloat:Show()
			soundGaseousBloat:Play()
		end
		if self.Options.GaseousBloatIcon then
			self:SetIcon(args.destName, 7, 20)
		end
		if self.Options.WhisperToGaseousBloatTarget then
			self:SendWhisper(L.SayOrangeOoze, args.destName)
		end
	elseif args:IsSpellID(71615, 71618) then	--71615 used in 10 and 25 normal, 71618?
		timerTearGas:Start()
	elseif args:IsSpellID(72451, 72463, 72671, 72672) then	-- Mutated Plague
		warnMutatedPlague:Show(args.spellName, args.destName, args.amount or 1)
		timerMutatedPlagueCD:Start()
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	elseif args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Show(args.destName)
	elseif args:IsSpellID(70352, 74118) then	--Ooze Variable
		if args:IsPlayer() then
			specWarnOozeVariable:Show()
		end
	elseif args:IsSpellID(70353, 74119) then	-- Gas Variable
		if args:IsPlayer() then
			specWarnGasVariable:Show()
		end
	elseif args:IsSpellID(72855, 72856, 70911) then	 -- Unbound Plague
		warnUnboundPlague:Show(args.destName)
		if self.Options.UnboundPlagueIcon then
			self:SetIcon(args.destName, 5, 20)
		end
		if args:IsPlayer() then
			specWarnUnboundPlague:Show()
			timerUnboundPlague:Start()
			if self.Options.YellOnUnbound then
				SendChatMessage(L.YellUnbound, "SAY")
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(72451, 72463, 72671, 72672) then	-- Mutated Plague
		warnMutatedPlague:Show(args.spellName, args.destName, args.amount or 1)
		timerMutatedPlagueCD:Start()
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	end
end

function mod:SPELL_AURA_REFRESH(args)
	if args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Show(args.destName)
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(70447, 72836, 72837, 72838) then
		if self.Options.OozeAdhesiveIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(70672, 72455, 72832, 72833) then
		timerGaseousBloat:Cancel(args.destName)
		if self.Options.GaseousBloatIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(72855, 72856, 70911) then 						-- Unbound Plague
		timerUnboundPlague:Stop(args.destName)
		if self.Options.UnboundPlagueIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(71615) and GetTime() - spamGas > 5 then 	-- Tear Gas Removal
		self:NextPhase()
		spamGas = GetTime()
	elseif args:IsSpellID(70539, 72457, 72875, 72876) then
		timerRegurgitatedOoze:Cancel(args.destName)
	elseif args:IsSpellID(70542) then
		timerMutatedSlash:Cancel(args.destName)
	end
end

--values subject to tuning depending on dps and his health pool
function mod:UNIT_HEALTH(uId)
	if phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 36678 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.83 then
		warned_preP2 = true
		warnPhase2Soon:Show()
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			if self.Options.RaidWarningStopDpsOn83Percent then
				if DBM:GetRaidRank() >= 1 then
					SendChatMessage(L.SayStopDps, "RAID_WARNING", nil, nil)
					SendChatMessage(L.SayStopDps, "SAY", nil, nil)
					SendChatMessage(L.SayStopDps, "YELL", nil, nil)
					SendChatMessage(L.SayStopDps, "RAID_WARNING", nil, nil)
					SendChatMessage(L.SayStopDps, "SAY", nil, nil)
					SendChatMessage(L.SayStopDps, "YELL", nil, nil)
					SendChatMessage(L.SayStopDps, "RAID_WARNING", nil, nil)
					SendChatMessage(L.SayStopDps, "SAY", nil, nil)
					SendChatMessage(L.SayStopDps, "YELL", nil, nil)
				end
			end
		end
	elseif phase == 2 and not warned_preP3 and self:GetUnitCreatureId(uId) == 36678 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.38 then
		warned_preP3 = true
		if self.Options.SayAboutPhase3 then
			SendChatMessage(L.SayPhase3, "SAY")
		end
		warnPhase3Soon:Show()
	end
end

function mod:WarnSayGooSoon()
	if self.Options.SayGooSoon then
		SendChatMessage(L.SayGooSoonText, "SAY")
		if DBM:GetRaidRank() > 0 then
			SendChatMessage(L.SayGooSoonText, "RAID_WARNING")
		end
		SendChatMessage(L.SayGooSoonText, "SAY")
		if DBM:GetRaidRank() > 0 then
			SendChatMessage(L.SayGooSoonText, "RAID_WARNING")
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if string.find(msg, "Malleable Goo") then
		self:startMalleableGooTimer(25)
	end
end 

function mod:OnSync(msg, target)
	if msg == "GooOn" then
		if not self.Options.BypassLatencyCheck then
			if self.Options.MalleableGooIcon then
				self:SetIcon(target, 6, 10)
			end
			if target == UnitName("player") then
				specWarnMalleableGoo:Show()
				if self.Options.YellOnMalleableGoo then
					SendChatMessage(L.YellMalleable, "SAY")
				end
			elseif target then
				local uId = DBM:GetRaidUnitId(target)
				if uId then
					local inRange = CheckInteractDistance(uId, 2)
					local x, y = GetPlayerMapPosition(uId)
					if x == 0 and y == 0 then
						SetMapToCurrentZone()
						x, y = GetPlayerMapPosition(uId)
					end
					if inRange then
						specWarnMalleableGooNear:Show()
						if self.Options.GooArrow then
							DBM.Arrow:ShowRunAway(x, y, 10, 5)
						end
					end
				end
			end
		end
	end
end