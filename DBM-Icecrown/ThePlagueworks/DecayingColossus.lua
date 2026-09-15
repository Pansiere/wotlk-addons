local mod	= DBM:NewMod("DecayingColossus", "DBM-Icecrown", 2)
local L		= mod:GetLocalizedStrings()


mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_SPELLCAST_SUCCEEDED"
)

mod:SetRevision(("$Revision: 4404 $"):sub(12, -3))
mod:SetCreatureID(37655, 36880)
mod:RegisterCombat("combat")


local timerStomp	= mod:NewTimer(9, "1st Stomp", 71114)
local timerStomp2	= mod:NewTimer(25, "2nd Stomp", 71114)
local timerStomp3	= mod:NewTimer(42, "3rd Stomp", 71114)
local timerStomp4	= mod:NewTimer(57.5, "4th Stomp", 71114)



function mod:OnCombatStart(delay)
	timerStomp:Start(-delay)
	timerStomp2:Start(-delay)
	timerStomp3:Start(-delay)
	timerStomp4:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71114) then
		timerStomp:Start()
	end
end
