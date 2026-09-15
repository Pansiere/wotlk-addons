local mod	= DBM:NewMod("Valkyr", "DBM-Icecrown", 4)
local L		= mod:GetLocalizedStrings()


mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_SPELLCAST_SUCCEEDED"
)

mod:SetRevision(("$Revision: 4404 $"):sub(12, -3))
mod:SetCreatureID(38418, 37098)
mod:RegisterCombat("combat")


local timerSeveredEssence	= mod:NewTimer(20, "Severed Essence", 71906, 71942)
local timerSeveredEssence2	= mod:NewTimer(49, "2nd Severed Essence", 71906, 71942)
local timerSeveredEssence3	= mod:NewTimer(74, "3rd Severed Essence", 71906, 71942)
local timerSeveredEssence4	= mod:NewTimer(100, "4th Severed Essence", 71906, 71942)



function mod:OnCombatStart(delay)
	timerSeveredEssence:Start(-delay)
	timerSeveredEssence2:Start(-delay)
	timerSeveredEssence3:Start(-delay)
	timerSeveredEssence4:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71906, 71203) then
		timerSeveredEssence:Start()
	end
end
