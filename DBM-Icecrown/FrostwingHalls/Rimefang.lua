--[[ Documentation:
Important to know:
- Timers are not accurate (airphase one), they vary from 30-44 (?) seconds.
- First airphase timer is the shortest.
- Ground phase timer is measured by the amount of Icy Blast (snow on floor) Rimefang does.
- Icy Blast will always happen only 7 times.
- Timers are longer depending on when Rimefang uses breath.
- Breath is not recorded anywhere.

Abilities:
- Frost Aura: 71387
- Frost Breath: 71386
- Icy Blast: 71376

Document is done.
--]]

local mod = DBM:NewMod("Rimefang", "DBM-Icecrown", 4)
local L = mod:GetLocalizedStrings()

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_SPELLCAST_SUCCEEDED"
)

mod:SetRevision(("$Revision: 4404 $"):sub(12, -3))
mod:SetCreatureID(37533) --not 38220
mod:RegisterCombat("combat")

--Timers
local timerAirPhase	= mod:NewTimer(0, "Air Phase", 43810)
local timerGroundPhase = mod:NewTimer(0, "Ground Phase", 43810)

--Counters
local icyBlastCounter = 0

function mod:OnCombatStart(delay)
	mod:StartNewAirPhase(32)
end

function mod:StartNewAirPhase(value)
	timerAirPhase = mod:NewTimer(value, "Air Phase", 43810)
	timerAirPhase:Start()
end

function mod:StartNewGroundPhase(value)
	timerGroundPhase = mod:NewTimer(value, "Ground Phase", 43810)
	timerGroundPhase:Start()
	mod:ScheduleMethod(value, "StartNewAirPhase", 40)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71376) then --Icy Blast
		icyBlastCounter = icyBlastCounter + 1
		if icyBlastCounter == 7 then
			mod:StartNewGroundPhase(5)
			icyBlastCounter = 0
		end
	end
end	



















