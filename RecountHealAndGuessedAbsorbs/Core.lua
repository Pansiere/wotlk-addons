--[[
  Name: Recount heal and Guessed Absorbs Module
  Author: Extrêm
]]

if not Recount then return end --  Forget about this if no Recount is present

local Recount = Recount

local Rhga = LibStub("AceAddon-3.0"):NewAddon("RecountHealAndGuessedAbsorbs", "AceEvent-3.0", "AceTimer-3.0","AceConsole-3.0")
Rhga.Version = tonumber(string.sub("$Revision: 17 $", 12, -3))

local RL = LibStub("AceLocale-3.0"):GetLocale("Recount")
local L = LibStub("AceLocale-3.0"):GetLocale("RecountHealAndGuessedAbsorbs")
local Epsilon=0.000000000000000001
local DetailTitles={}
DetailTitles.GuessedAbsorbed={
	TopNames = RL["Ability Name"],
	TopCount = RL["Count"],
	TopAmount = RL["Absorbed"],
	BotNames = "",
	BotMin = RL["Min"],
	BotAvg = RL["Avg"],
	BotMax = RL["Max"],
	BotAmount = RL["Count"]
}

DetailTitles.ShieldedWho={
	TopNames = RL["Player/Mob Name"],
	TopCount = "",
	TopAmount = RL["Count"],
	BotNames = RL["Ability Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = RL["Count"]
}

-- global OnEnable
function Rhga:OnEnable()

	if not Recount then return end -- No recount found

    --Parser Events
	--RecountGuessedAbsorbs:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogEvent")
	
	-- fill upvalues with meaningful data
end

-- global OnDisable
function Rhga:OnDisable()
	Recount:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- The data on the panel
function Rhga:DataModesHealAndGuessedAbsorbs(data, num)
 	if not data then return 0, 0 end
 	if num==1 then
		--return ((data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbs or 0)+(data.Fights[Recount.db.profile.CurDataSet].Healing or 0)), ((data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbs or 0)+(data.Fights[Recount.db.profile.CurDataSet].Healing or 0))/((data.Fights[Recount.db.profile.CurDataSet].ActiveTime or 0) + Epsilon)
		local healing, hps = Recount:MergedPetHealingDPS(data,Recount.db.profile.CurDataSet)
		return ((data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbs or 0)+healing), (data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbs or 0)/((data.Fights[Recount.db.profile.CurDataSet].ActiveTime or 0) + Epsilon) + hps
 	else
		local healing, hps = Recount:MergedPetHealingDPS(data,Recount.db.profile.CurDataSet)
		local ga = data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbed
		local he = data.Fights[Recount.db.profile.CurDataSet].Heals
		local gahe = Recount:GetTable()
		if ga then
			for k,v in pairs(ga) do
				gahe[k] = v
			end
		end

		if he then
			for k,v in pairs(he) do
				gahe[k] = v
			end
		end
 		return ((data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbs or 0)+healing), {{gahe,L["Heal & absorb"],DetailTitles.GuessedAbsorbed},{data.Fights[Recount.db.profile.CurDataSet].ShieldedWho," "..L["Shielded Who"],DetailTitles.ShieldedWho}}
 	end
end


-- On over function
function Rhga:TooltipFuncsHealGuessedAbsorbs(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	local ga = data.Fights[Recount.db.profile.CurDataSet].GuessedAbsorbed
	local he = data.Fights[Recount.db.profile.CurDataSet].Heals
	local gahe = Recount:GetTable()
	if ga then
		for k,v in pairs(ga) do
			gahe[k] = v
		end
	end

	if he then
		for k,v in pairs(he) do
			gahe[k] = v
		end
	end
	
	Recount:AddSortedTooltipData(RL["Top 3"].." "..L["Heal & absorb"],data and data.Fights[Recount.db.profile.CurDataSet] and gahe,3)
	--GameTooltip:AddLine("")
	--Recount:AddSortedTooltipData(RL["Top 3"].." "..L["Healing"],data and data.Fights[Recount.db.profile.CurDataSet] and data.Fights[Recount.db.profile.CurDataSet].Heals,3)
end

-- Add the panel to recount
Recount:AddModeTooltip(L["Heal & absorb"],Rhga.DataModesHealAndGuessedAbsorbs,Rhga.TooltipFuncsHealGuessedAbsorbs,nil,nil,nil,nil)
