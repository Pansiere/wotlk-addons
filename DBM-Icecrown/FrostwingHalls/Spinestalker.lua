local mod = DBM:NewMod("Spinestalker", "DBM-Icecrown", 4)
local L = mod:GetLocalizedStrings()

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_SPELLCAST_SUCCEEDED"
)

mod:SetRevision(("$Revision: 4404 $"):sub(12, -3))
mod:SetCreatureID(37534, 38219) --not 38220
mod:RegisterCombat("combat")


local timerBellowingRoar	= mod:NewTimer(21.5, "Next Bellowing Roar", 36922)
local timerBellowingRoar2	= mod:NewTimer(2.5, "Bellowing Roar", 36922)

function mod:OnCombatStart(delay)
	timerBellowingRoar:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(36922) then -- Roar
	timerBellowingRoar:Start(25)
	timerBellowingRoar2:Start()
	end
end	



















