if select(2, UnitClass("player")) ~= "WARRIOR" then return end
local GetSpellInfo = GetSpellInfo
local math_min = math.min
local select = select
local UnitPower = UnitPower
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitDamage = UnitDamage
local IsEquippedItemType = IsEquippedItemType
local GetShapeshiftForm = GetShapeshiftForm

--NOTE; One-Handed Weapon Specialization is handled by API (7th return of UnitDamage("player"), Two-Handed Weapon Specialization is multiplied into weapon damage range

function DrDamage:PlayerData()
	--Health Updates
	self.TargetHealth = { [1] = 0.751, [0.751] = GetSpellInfo(772) }
	--Specials
	--Enraged Regeneration
	self.ClassSpecials[GetSpellInfo(55694)] = function()
		--Glyph of Enraged Regeneration
		if self:HasGlyph(63327) then
			return 0.4 * UnitHealthMax("player"), true
		else
			return 0.3 * UnitHealthMax("player"), true
		end
	end
--GENERAL
	self.Calculation["WARRIOR"] = function( calculation, ActiveAuras, Talents )
		if ActiveAuras["Disarm"] and Talents["Improved Disarm"] then
			calculation.dmgM = calculation.dmgM * (1 + Talents["Improved Disarm"])
		end
		if GetShapeshiftForm() == 1 then
			calculation.armorPen = calculation.armorPen + 0.1 + ((self:GetSetAmount("T9 - Damage") >= 2) and 0.06 or 0)
		end
	end
--TALENTS
	self.Calculation["Two-Handed Weapon Specialization"] = function( calculation, value, baseSpell )
		if self:GetNormM() == 3.3 and not baseSpell.NoWeapon then
			calculation.wDmgM = calculation.wDmgM * (1 + value)
			calculation.dmgM = calculation.dmgM * (1 + value)
		end
	end
	self.Calculation["Precision"] = function( calculation, value, baseSpell )
		if not baseSpell.NoWeapon then
			calculation.hitPerc = calculation.hitPerc + value
		end
	end	
	local oha = GetSpellInfo(196)
	local tha = GetSpellInfo(197)
	local pol = GetSpellInfo(200)
	self.Calculation["Poleaxe Specialization"] = function( calculation, value )
		--Requires One-Handed Axes, Two-Handed Axes, Polearms
		if IsEquippedItemType(oha) or IsEquippedItemType(tha) or IsEquippedItemType(pol) then
			calculation.critM = calculation.critM + (0.02 * value)
		end
	end
	local ohs = GetSpellInfo(201)
	local ths = GetSpellInfo(202)
	local ss = GetSpellInfo(12815)
	self.Calculation["Sword Specialization"] = function( calculation, value, baseSpell )
		--Requires One-Handed Swords, Two-Handed Swords
		local mhType, ohType = self:GetWeaponType()
		local mh = (mhType == ohs) or (mhType == ths)
		local oh = (ohType == ohs) and baseSpell.AutoAttack
		if mh or oh then
			--Note: Cooldown not taken into account at the moment (except rough guesstimation of 7.5% on dual wield)
			calculation.extraDamage = 0
			if baseSpell.AutoAttack then
				calculation.extraAvg = 1
				calculation.extraAvgM = true
				calculation.extraAvgChance = (mh and oh) and (1.5 * value) or value
				calculation.extraTicks = nil
				calculation.extraName = (calculation.extraName and (calculation.extraName .. "+") or "") .. ss
			else
				calculation.extraWeaponDamage = 1
				calculation.extraWeaponDamageM = true
				calculation.extraWeaponDamage_dmgM = select(7,UnitDamage("player"))
				calculation.extra_canCrit = true
				calculation.extraChance = (mh and oh) and (1.5 * value) or value
				calculation.extraName = ss
			end
		end
	end
	local ohm = GetSpellInfo(198)
	local thm = GetSpellInfo(199)
	self.Calculation["Mace Specialization"] = function( calculation, value )
		if IsEquippedItemType(oha) or IsEquippedItemType(thm) then
			calculation.armorPen = calculation.armorPen + value
		end
	end
	local dw = GetSpellInfo(12867)
	self.Calculation["Deep Wounds"] = function( calculation, value )
		if not calculation.unarmed then
			calculation.extraDamage = 0
			calculation.extraTicks = not calculation.extraAvg and 3
			calculation.extraWeaponDamage = calculation.bleedBonus * value
			calculation.extraChanceCrit = true
			calculation.extraName = (calculation.extraName and (calculation.extraName .. "+") or "") .. dw
		end
		if calculation.offHand then
			calculation.extraWeaponDamage_O = calculation.bleedBonus * value
			if calculation.unarmed then
				calculation.extraDamage = 0
				calculation.extraChanceCrit = true
				calculation.extraName = (calculation.extraName and (calculation.extraName .. "+") or "") .. dw
			else
				calculation.extraTicks = nil
			end
		end
	end
--ABILITIES
	self.Calculation["Heroic Strike"] = function( calculation, ActiveAuras, _, spell )
		if ActiveAuras["Dazed"] and spell.Daze then
			calculation.minDam = calculation.minDam + spell.Daze
			calculation.maxDam = calculation.maxDam + spell.Daze
		end
		--Glyph of Heroic Strike
		if self:HasGlyph(58357) then
			calculation.actionCost = calculation.actionCost - 10 * math_min(1, calculation.critPerc / 100)
		end
		if self:GetSetAmount("T9 - Damage") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Shield Slam"] = function( calculation, ActiveAuras, Talents )
		local dr = 24.5 * calculation.playerLevel --1960 at level 80
		local cap = 39.5 * calculation.playerLevel --3160 at level 80
		local bv = calculation.blockValue
		local bonus = 0
		if ActiveAuras["Shield Block"] then
			local mult = (Talents["Shield Mastery"] or 0) + (self:HasGlyph(58375) and 0.1 or 0) + self.MetaGem_BlockBonus
			local bonus = bv / (2 + mult)
			bv = bonus * (1 + mult)
		end
		--TODO: Fix this to 3.3.2 values, for now assuming linear diminishing returns
		if bv > dr then
			--At level 80 true bonus is 2072 with 3160 blockvalue
			bv = math_min(cap, bv)
			local c = (bv - dr)/(cap - dr) * (2072/3160)
			bv = dr + (bv - dr) * (1 - c)
		end
		calculation.minDam = calculation.minDam + bv + bonus
		calculation.maxDam = calculation.maxDam + bv + bonus
		if self:GetSetAmount("T7 - Prot") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T10 - Prot" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	self.Calculation["Devastate"] = function( calculation, ActiveAuras, _, spell )
		if ActiveAuras["Sunder Armor"] then
			calculation.minDam = calculation.minDam + (ActiveAuras["Sunder Armor"] * spell.sunderDmg)
			calculation.maxDam = calculation.maxDam + (ActiveAuras["Sunder Armor"] * spell.sunderDmg)
		end
		if self:GetSetAmount("T8 - Prot") >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if self:GetSetAmount("T9 - Prot") >= 2 then
			calculation.dmgM = calculation.dmgM * 1.05
		end
	end
	self.Calculation["Execute"] = function( calculation, ActiveAuras )
		--Glyph of Execution
		if self:HasGlyph(58367) then
			calculation.extraPowerBonus = 10
		end
		if ActiveAuras["Sudden Death"] then
			calculation.maxPower = 30 - calculation.actionCost
			local bonus = math_min(calculation.maxPower, UnitPower("player",1) - calculation.actionCost)
			local rageleft = UnitPower("player",1) - bonus - calculation.actionCost
			local limit = select(ActiveAuras["Sudden Death"], 3, 7, 10)
			if rageleft < limit then
				calculation.maxCost = bonus + calculation.actionCost - (limit - rageleft)
			end
		end
	end
	self.Calculation["Cleave"] = function( calculation )
		--Glyph of Cleaving
		if self:HasGlyph(58366) then
			calculation.aoe = calculation.aoe + 1
		end
	end
	self.Calculation["Mocking Blow"] = function( calculation )
		--Glyph of Mocking Blow
		if self:HasGlyph(58099) then
			calculation.dmgM = calculation.dmgM * 1.25
		end
	end
	self.Calculation["Mortal Strike"] = function( calculation )
		--Glyph of Mortal Strike
		if self:HasGlyph(58368) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T8 - Damage") >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Rend"] = function( calculation, _, _, spell )
		--Glyph of Rending
		if self:HasGlyph(58385) then
			calculation.eDuration = calculation.eDuration + 6
		end
		if spell.healthBonus and (UnitHealth("target") / UnitHealthMax("target")) > 0.75 then
			calculation.dmgM = calculation.dmgM * (1 + spell.healthBonus)
		end
	end
	self.Calculation["Bloodthirst"] = function( calculation )
		if self:GetSetAmount("T8 - Damage") >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Slam"] = function( calculation )
		if self:GetSetAmount("T7 - Damage") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T9 - Damage") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Shockwave"] = function( calculation )
		--Glyph of Shockwave
		if self:HasGlyph(63325) then
			calculation.cooldown = calculation.cooldown - 3
		end
		if self:GetSetAmount( "T10 - Prot" ) >= 2 then
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end
	self.Calculation["Victory Rush"] = function( calculation )
		--Glyph of Victory Rush
		if self:HasGlyph(58382) then
			calculation.critPerc = calculation.critPerc + 30
		end
	end
	self.Calculation["Whirlwind"] = function( calculation )
		--Glyph of Whirlwind
		if self:HasGlyph(58370) then
			calculation.cooldown = calculation.cooldown - 2
		end
	end
	self.Calculation["Bladestorm"] = function( calculation )
		--Glyph of Bladestorm
		if self:HasGlyph(63324) then
			calculation.cooldown = calculation.cooldown - 15
		end
	end
--SETS
	self.SetBonuses["T7 - Damage"] = { 40525, 40527, 40528, 40529, 40530, 39605, 39606, 39607, 39608, 39609 }
	self.SetBonuses["T7 - Prot"] = { 40544, 40545, 40546, 40547, 40548, 39610, 39611, 39612,  39613,  39622  }
	self.SetBonuses["T8 - Damage"] = { 46146, 46148, 46149, 46150, 46151, 45429, 45430, 45431, 45432, 45433 }
	self.SetBonuses["T8 - Prot"] = { 46162, 46164, 46166, 46167, 46169, 45424, 45425, 45426, 45427, 45428 }
	self.SetBonuses["T9 - Damage"] = { 48386, 48387, 48388, 48389, 48390, 48371, 48372, 48373, 48374, 48375, 48391, 48392, 48393, 48394, 48395, 48396, 48397, 48398, 48399, 48400, 48376, 48377, 48378, 48379, 48380, 48385, 48384, 48383, 48382, 48381 }
	self.SetBonuses["T9 - Prot"] = { 48456, 48457, 48458, 48459, 48460, 48429, 48436, 48445, 48448, 48449, 48450, 48430, 48452, 48446, 48454, 48451, 48433, 48453, 48447, 48455, 48461, 48463, 48462, 48464, 48465, 48466, 48468, 48467, 48469, 48470 }
	self.SetBonuses["T10 - Prot"] = { 50846, 50847, 50849, 50848, 50850, 51215, 51224, 51216, 51223, 51217, 51222, 51218, 51221, 51219, 51220    }
--AURA
--Player
	--Revenge
	self.PlayerAura[GetSpellInfo(37517)] = { Value = 0.1, ID = 37517 }
	--Juggernaut
	self.PlayerAura[GetSpellInfo(65156)] = { Value = 25, ModType = "critPerc", Spells = { 1464, 12294 }, ID = 65156 }
	--Shield Block
	self.PlayerAura[GetSpellInfo(2565)] = { Spells = 23922, ActiveAura = "Shield Block", NoManual = true }
	--Recklessness
	self.PlayerAura[GetSpellInfo(1719)] = { Value = 100, ModType = "critPerc", ID = 1719, Not = { "Attack", "Shockwave", "Concussion Blow", "Heroic Throw", "Shattering Throw", "Thunder Clap" } }
--Target
	--Dazed
	self.TargetAura[GetSpellInfo(1604)] = { ActiveAura = "Dazed", Spells = 78, ID = 1604 }
	--Disarm
	self.TargetAura[GetSpellInfo(676)] = { ActiveAura = "Disarm", ID = 676 }
	--Sudden Death
	self.TargetAura[GetSpellInfo(29723)] = { ActiveAura = "Sudden Death", Ranks = 3, Spells = 5308, ID = 29723 }
	--Sunder Armor
	self.TargetAura[GetSpellInfo(7386)] = { ActiveAura = "Sunder Armor", Apps = 5, Value = 0.04, ModType = "armorM", Category = "-20% Armor", Manual = GetSpellInfo(7386), ID = 7386 }

	self.spellInfo = {
		[GetSpellInfo(78)] = {
			["Name"] = "Heroic Strike",
			[0] = { WeaponDamage = 1, NextMelee = true, NoNormalization = true },
			[1] = { 11, },
			[2] = { 21, },
			[3] = { 32, },
			[4] = { 44, },
			[5] = { 60, },
			[6] = { 93, },
			[7] = { 136, },
			[8] = { 178, },
			[9] = { 201, },
			[10] = { 234, Daze = 81.9 },
			[11] = { 317, Daze = 110.95 },
			[12] = { 432, Daze = 151.2 },
			[13] = { 495, Daze = 173.25 },
		},
		[GetSpellInfo(772)] = {
			["Name"] = "Rend",
			[0] = { WeaponDamage = 1, NoCrits = true, eDuration = 15, NoNormalization = true, Bleed = true },
			[1] = { 25 },
			[2] = { 40 },
			[3] = { 50 },
			[4] = { 70 },
			[5] = { 115 },
			[6] = { 150 },
			[7] = { 185 },
			[8] = { 215 },
			[9] = { 315, healthBonus = 0.35 },
			[10] = { 380, healthBonus = 0.35 },
		},
		[GetSpellInfo(7384)] = {
			["Name"] = "Overpower",
			[0] = { WeaponDamage = 1, Unavoidable = true },
			[1] = { 0 },
		},
		[GetSpellInfo(6572)] = {
			["Name"] = "Revenge",
			[0] = { APBonus = 0.207, Cooldown = 5, },
			[1] = { 89, 107 },
			[2] = { 129, 157 },
			[3] = { 175, 213 },
			[4] = { 320, 390 },
			[5] = { 498, 608 },
			[6] = { 643, 785, },
			[7] = { 699, 853, },
			[8] = { 855, 1045, },
			[9] = { 1454, 1776, },
		},
		[GetSpellInfo(694)] = {
			["Name"] = "Mocking Blow",
			[0] = { WeaponDamage = 1 },
			[1] = { 0 },
		},
		[GetSpellInfo(6343)] = {
			["Name"] = "Thunder Clap",
			[0] = { APBonus = 0.12, NoWeapon = true, SpellCrit = "Nature", AoE = true },
			[1] = { 15 },
			[2] = { 34 },
			[3] = { 55 },
			[4] = { 82 },
			[5] = { 123 },
			[6] = { 154 },
			[7] = { 184 },
			[8] = { 247 },
			[9] = { 300 },
		},
		[GetSpellInfo(845)] = {
			["Name"] = "Cleave",
			[0] = { WeaponDamage = 1, AoE = 2, NextMelee = true, NoNormalization = true },
			[1] = { 15 },
			[2] = { 30 },
			[3] = { 50 },
			[4] = { 70 },
			[5] = { 95 },
			[6] = { 135 },
			[7] = { 189 },
			[8] = { 222 },
		},
		[GetSpellInfo(5308)] = {
			["Name"] = "Execute",
			[0] = { APBonus = 0.2, MaxPower = 30 },
			[1] = { 93, PowerBonus = 3 },
			[2] = { 159, PowerBonus = 6 },
			[3] = { 282, PowerBonus = 9 },
			[4] = { 404, PowerBonus = 12 },
			[5] = { 554, PowerBonus = 15 },
			[6] = { 687, PowerBonus = 18 },
			[7] = { 865, PowerBonus = 21 },
			[8] = { 1142, PowerBonus = 30 },
			[9] = { 1456, PowerBonus = 38 },
		},
		[GetSpellInfo(20252)] = {
			["Name"] = "Intercept",
			[0] = { APBonus = 0.12, Cooldown = 30, NoWeapon = true },
			[1] = { 0 },
		},
		[GetSpellInfo(1464)] = {
			["Name"] = "Slam",
			[0] = { WeaponDamage = 1, SpamDPS = 1.5, NoNormalization = true },
			[1] = { 32 },
			[2] = { 43 },
			[3] = { 68 },
			[4] = { 87 },
			[5] = { 105 },
			[6] = { 140 },
			[7] = { 220 },
			[8] = { 250 },
		},
		[GetSpellInfo(23881)] = {
			["Name"] = "Bloodthirst",
			[0] = { APBonus = 0.5, Cooldown = 5 },
			[1] = { 0 },
		},
		[GetSpellInfo(12294)] = {
			["Name"] = "Mortal Strike",
			[0] = { WeaponDamage = 1, Cooldown = 6 },
			[1] = { 85 },
			[2] = { 110 },
			[3] = { 135 },
			[4] = { 160 },
			[5] = { 185 },
			[6] = { 210 },
			[7] = { 320 },
			[8] = { 380 },
		},
		[GetSpellInfo(23922)] = {
			["Name"] = "Shield Slam",
			[0] = { Offhand = select(7, GetItemInfo(40700)), NoWeapon = true }, --Fix for "Shields" translation
			[1] = { 294, 308, },
			[2] = { 346, 362, },
			[3] = { 396, 416, },
			[4] = { 447, 469, },
			[5] = { 499, 523, },
			[6] = { 549, 577, },
			[7] = { 837, 879, },
			[8] = { 990, 1040, },
		},
		[GetSpellInfo(20243)] = {
			["Name"] = "Devastate",
			[0] = { WeaponDamage = 1.2, },
			[1] = { 0, sunderDmg = 48 * 1.2 },
			[2] = { 0, sunderDmg = 80 * 1.2 },
			[3] = { 0, sunderDmg = 112 * 1.2 },
			[4] = { 0, sunderDmg = 170 * 1.2 },
			[5] = { 0, sunderDmg = 202 * 1.2 },
		},
		[GetSpellInfo(34428)] = {
			["Name"] = "Victory Rush",
			[0] = { APBonus = 0.45, NoWeapon = true },
			[1] = { 0 },
		},
		[GetSpellInfo(46968)] = {
			["Name"] = "Shockwave",
			[0] = { APBonus = 0.75, NoWeapon = true, AoE = true },
			[1] = { 0 },
		},
		[GetSpellInfo(1680)] = {
			["Name"] = "Whirlwind",
			[0] = { WeaponDamage = 1, DualAttack = true, Cooldown = 10, AoE = 4 },
			[1] = { 0 },
		},
		[GetSpellInfo(46924)] = {
			["Name"] = "Bladestorm",
			[0] = { WeaponDamage = 1, DualAttack = true, Cooldown = 90, Hits = 7, AoE = 4 },
			[1] = { 0 },
		},
		[GetSpellInfo(12809)] = {
			["Name"] = "Concussion Blow",
			[0] = { APBonus = 0.38 },
			[1] = { 0 },
		},
		[GetSpellInfo(57755)] = {
			["Name"] = "Heroic Throw",
			[0] = { APBonus = 0.5, Cooldown = 60 },
			[1] = { 12 },
		},
		[GetSpellInfo(64382)] = {
			["Name"] = "Shattering Throw",
			[0] = { APBonus = 0.5, Cooldown = 300 },
			[1] = { 12 },
		},
	}
	self.talentInfo = {
	--ARMS:
		--Improved Rend
		[GetSpellInfo(12286)] = {	[1] = { Effect = 0.1, Spells = "Rend" }, },
		--Improved Overpower
		[GetSpellInfo(12290)] = {	[1] = { Effect = 25, Spells = "Overpower", ModType = "critPerc" }, },
		--Impale
		[GetSpellInfo(16493)] = {	[1] = { Effect = 0.1, Spells = "All", ModType = "critM", Specials = true, }, },
		--Deep Wounds
		[GetSpellInfo(12867)] = {	[1] = { Effect = 0.16, Spells = "Attack", ModType = "Deep Wounds", }, },
		--Two-Handed Weapon Specialization
		[GetSpellInfo(12163)] = {	[1] = { Effect = 0.02, Spells = "All", ModType = "Two-Handed Weapon Specialization" }, },
		--Poleaxe Specialization
		[GetSpellInfo(12700)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Poleaxe Specialization", }, },
		--Mace Specialization
		[GetSpellInfo(12284)] = {	[1] = { Effect = 0.03, Spells = "All", ModType = "Mace Specialization" }, },
		--Sword Specialization
		[GetSpellInfo(12281)] = {	[1] = { Effect = 0.02, Spells = { "Attack", "Hamstring", "Mortal Strike", "Concussion Blow", "Devastate", "Slam", "Execute", "Cleave", "Revenge", "Overpower", "Rend", "Heroic Strike"  }, ModType = "Sword Specialization", }, },
		--Improved Mortal Strike (additive)
		[GetSpellInfo(35446)] = {	[1] = { Effect = { 0.03, 0.06, 0.1 }, Spells = "Mortal Strike", },
									[2] = { Effect = { -0.333, -0.666, -1 }, Multiply = true, Spells = "Mortal Strike", ModType = "cooldown" }, },
		--Unrelenting Assault
		[GetSpellInfo(46859)] = {	[1] = { Effect = -2, Spells = { "Overpower", "Revenge" }, ModType = "cooldown" },
									[2] = { Effect = 0.1, Spells = { "Overpower", "Revenge" }, }, },
		--Endless Rage
		[GetSpellInfo(29623)] = {	[1] = { Effect = 0.25, Spells = { "Heroic Strike", "Cleave" }, ModType = "rageBonus" }, },
	--FURY:
		--Improved Cleave
		[GetSpellInfo(12329)] = {	[1] = { Effect = 0.4, Spells = "Cleave", ModType = "bDmgM", Multiply = true }, },
		--Dual Wield Specialization
		[GetSpellInfo(23584)] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "offHdmgM", Multiply = true  }, NoManual = true },
		--Precision, TODO: Does this apply to everything?
		[GetSpellInfo(29590)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Precision" }, },
		--Improved Intercept
		[GetSpellInfo(29888)] = {	[1] = { Effect = -5, Spells = "Intercept", ModType = "cooldown" }, },
		--Improved Whirlwind (additive)
		[GetSpellInfo(29721)] = {	[1] = { Effect = 0.1, Spells = "Whirlwind" }, },
		--Unending Fury (additive)
		[GetSpellInfo(56927)] = {	[1] = { Effect = 0.02, Spells = { "Slam", "Whirlwind", "Bloodthirst", } }, },
	--PROTECTION:
		--Improved Thunder Clap
		[GetSpellInfo(12287)] = {	[1] = { Effect = 0.1, Spells = "Thunder Clap" }, },
		--Incite
		[GetSpellInfo(50685)] = {	[1] = { Effect = 5, Spells = { "Heroic Strike", "Thunder Clap", "Cleave" }, ModType = "critPerc" }, },
		--Improved Revenge
		[GetSpellInfo(12797)] = {	[1] = { Effect = 0.1, Spells = "Revenge" }, },
		--Shield Mastery
		[GetSpellInfo(29598)] = {	[1] = { Effect = 0.15, Spells = "Shield Slam", ModType = "Shield Mastery" }, },
		--Improved Disarm
		[GetSpellInfo(12313)] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "Improved Disarm"  }, },
		--Gag Order
		[GetSpellInfo(12311)] = {	[1] = { Effect = 0.05, Spells = "Shield Slam"}, },
		--Critical Block
		[GetSpellInfo(47294)] = {	[1] = { Effect = 5, Spells = "Shield Slam", ModType = "critPerc" }, },
		--Sword and Board
		[GetSpellInfo(46951)] = {	[1] = { Effect = 5, Spells = "Devastate", ModType = "critPerc" }, },
	}
end