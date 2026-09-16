-- Author: Shurshik
-- version: 1.112
-- http://phoenix-wow.ru

function rsc_onload()

rsclocale()
if GetLocale()=="deDE" or GetLocale()=="ruRU" or GetLocale()=="zhTW" or GetLocale()=="frFR" or GetLocale()=="koKR" or GetLocale()=="esES" or GetLocale()=="esMX" then
rsclocalel()
end

rscversion=1.112

--==============POTIONS=============
rscpotiontable = {

-- BC
28494,	-- Insane Strength Potion
38929,	-- Fel mana potion

-- WOTLK
53909,	-- Potion of Wild Magic
53908,	-- Potion of Speed
53750,	-- Crazy Alchemist's Potion
53761,	-- Powerful Rejuvenation Potion
43185,	-- Healing Potion
43186,	-- Restore Mana
53753,	-- Nightmare Slumber
53910,	-- Arcane Protection
53911,	-- Fire Protection 
53913,	-- Frost Protection
53914,	-- Nature Protection
53915,	-- Shadow Protection
53762,	-- Indestructible
67490	-- runic mana
}

--==============FOOD=================
rscfoodtable={
	57356, -- Rhinolicious Wormsteak
	57358, -- Hearty Rhino
	57360, -- Snapper Extreme/Worg Tartare
	57367, -- Blackened Dragonfin
	57365, -- Cuttlesteak
	57371, -- Dragonfin Filet
	57399, -- Fish Feast
	57329, -- Spiced Worm Burger/Spicy Blue Nettlefish
	57332, -- Imperial Manta Steak/Very Burnt Worg
	57327, -- Firecracker Salmon/Tender Shoveltusk Steak
	57325, -- Mega Mammoth Meal/Poached Northern Sculpin
	57334, -- Mighty Rhino Dogs/Spicy Fried Herring
}

--==============FLASKS===============
rscflasktable={
	17627, -- Distilled Wisdom
	53752, -- Lesser Flask of Toughness
	53755, -- Flask of the Frost Wyrm
	53758, -- Flask of Stoneblood
	53760, -- Flask of Pure Mojo
	54212, -- Flask of Endless Rage
	62380, -- Lesser Flask of Resistance
}

--=============ELIXIRS guarg=========
rscelixirtable1={
	53747, -- Elixir of Spirit
	60347, -- Elixir of Mighty Thoughts
	53764, -- Elixir of Mighty Mageblood
	53751, -- Elixir of Mighty Fortitude
	60343, -- Elixir of Mighty Defense
}

--=============ELIXIRS battle=========
rscelixirtable2={
	53746, -- Wrath Elixir
	53749, -- Guru's Elixir
	53763, -- Elixir of Protection
	53748, -- Elixir of Mighty Strength
	28497, -- Elixir of Mighty Agility
	60346, -- Elixir of Lightning Speed
	60344, -- Elixir of Expertise
	60341, -- Elixir of Deadly Strikes
	60345, -- Elixir of Armor Piercing
	60340, -- Elixir of Accuracy
	33721, -- Spellpower Elixir
}



	if(rscraidlrep==nil) then rscraidlrep=true end
	if(rsccolornick==nil) then rsccolornick=true end
	if rscchatrep==nil then rscchatrep="raid" end

	rscboy=0
	rscbilresnut=0
	rscboynachat=0
	rscwasheroism=0
	rscwasyellpull=GetTime()
	rscherashowed=0
	rscsmotryuboy=1
	rscraidrostertable={}
	rscpotioninfotable={}
	rscchoosepotion={}
	rscbossnamestable={}

	rscpotionnotincombat={}

	if rscpotionscombatsaves==nil then rscpotionscombatsaves=8 end


	--buff after rez
	if rscwhomustbufflist==nil then rscwhomustbufflist={"","","","","","","","",""} end
	if rscbuffschat==nil then rscbuffschat={"raid","raid"} end
	if rscbuffcheckb==nil then rscbuffcheckb={1,1,1,1,1,0} end
	if rscbuffwhichtrack==nil then rscbuffwhichtrack={1,1,1,0,0,0,0,0,0} end
	if rscbufftimers==nil then rscbufftimers={15,40} end

	rscrebirth1={} --rebirt awaiting
	rscrebirth2={} --names after reb
	rscrebirth3={} --time begin
	rscrebirth4={} --name for 2 check
	rscrebirth5={} --time for second check

	--flask check
	if rscminflaskgood==nil then rscminflaskgood=5 end
	if rscignorzone==nil then rscignorzone={rscdefaultzone1,rscdefaultzone2} end
	if rscflaskcheckb==nil then rscflaskcheckb={1,1,1,1,0,1,1} end
	if rscflaskchat==nil then rscflaskchat={"raid","raid"} end
	rscflaskimportchat1={"whisp","raid"}
	rscflaskimportchat2={0,0}
	rscflaskdelayrep={0,0} -- whips i raid, delay но! цифра не геттайм а геттайм+делей, тоесть если просто больше моей значит репортить можно
	rscbosstriggertable={rscbosstrigger1,rscbosstrigger2,rscbosstrigger3ally,rscbosstrigger3horde,rscbosstrigger4ally,rscbosstrigger4horde,rscbosstrigger5,rscbosstrigger6,rscbosstrigger7,rscbosstrigger8,rscbosstrigger9,rscbosstrigger10,rscbosstrigger11,rscbosstrigger12,rscbosstriggerruby}
rscbosstrigger1=nil
rscbosstrigger2=nil
rscbosstrigger3ally=nil
rscbosstrigger3horde=nil
rscbosstrigger4ally=nil
rscbosstrigger4horde=nil
rscbosstrigger5=nil
rscbosstrigger6=nil
rscbosstrigger7=nil
rscbosstrigger8=nil
rscbosstrigger9=nil
rscbosstrigger10=nil
rscbosstrigger11=nil
rscbosstrigger12=nil

	SLASH_RaidSlackCheck1 = "/raidslackcheck"
	SLASH_RaidSlackCheck2 = "/raidslack"
	SLASH_RaidSlackCheck3 = "/slack"
	SLASH_RaidSlackCheck4 = "/слак"
	SLASH_RaidSlackCheck5 = "/рейдслак"
	SLASH_RaidSlackCheck6 = "/rsc"
	SlashCmdList["RaidSlackCheck"] = RaidSlackCheck_Command


	this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("PLAYER_ALIVE")
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("CHAT_MSG_ADDON")
	this:RegisterEvent("READY_CHECK")
	this:RegisterEvent("CHAT_MSG_MONSTER_YELL")


end



function rsc_OnUpdate(curtime)


--flask report
if rscdelayreportstart and curtime>rscdelayreportstart+1.5 then
rscdelayreportstart=nil
rscreportslackwithflask("auto", rscflaskchat[1])
end

--removechatfilters
if rscchatfiltime and curtime>rscchatfiltime+11 then
rscchatfiltime=nil
ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", rscChatFilter)
end

--buffs check module
if rscbuffcheckb[1] and rscbuffcheckb[1]==1 then


--1 check
if #rscrebirth3>0 and ((rscrebnextupd and curtime>rscrebnextupd) or rscrebnextupd==nil) then

	if rscrebnextupd==nil then
		rscrebnextupd=rscrebirth3[1]
		for tt=1,#rscrebirth3 do
			if rscrebirth3[tt]<rscrebnextupd then
				rscrebnextupd=rscrebirth3[tt]
			end
		end
	end


	if rscrebnextupd and curtime>rscrebnextupd then
		rscrebnextupd=nil
		for yy=1,#rscrebirth3 do
			if rscrebirth3[yy] and curtime>rscrebirth3[yy] then
				--время после реса прошло, проверяем жив ли игрок и в бою ли он
				if UnitIsDeadOrGhost(rscrebirth2[yy])==nil and UnitAffectingCombat(rscrebirth2[yy]) and rscbuffcheckb[1]==1 and (rscbuffcheckb[2]==1 or rscbuffcheckb[3]==1 or rscbuffcheckb[4]==1 or rscbuffcheckb[5]==1) and (rscbcanannounce==nil or (rscbcanannounce and GetTime()>rscbcanannounce+180)) then
					--игрок жив в бою, проверка бафов и репорты
					local strin="" --список бафов нету


					--1 модуль для всех


					local tablid={{25898,20217,69378},{48470,48469},{48161,48162,69377}, {48073,48074,48104}, {48169,48170}, {48100,61024,42995,61316,43002}, {48936,48938}, {48932,48934}, {43017}} --ид бафов
					local buffnamelist={rscbuffnameslit1,rscbuffnameslit2,rscbuffnameslit3,rscbuffnameslit4,rscbuffnameslit5,rscbuffnameslit6,rscbuffnameslit7,rscbuffnameslit8,rscbuffnameslit9}
					local classesnorm={"PALADIN","DRUID","PRIEST","PRIEST","PRIEST","MAGE","PALADIN","PALADIN","MAGE"}
					local buffnotneed={{}, {}, {}, {"ROGUE","HUNTER","WARRIOR","DEATHKNIGHT"}, {}, {"ROGUE","WARRIOR","DEATHKNIGHT"}, {"ROGUE","WARRIOR","DEATHKNIGHT"}, {"PRIEST","WARLOCK","MAGE"},{}} --не нужны бафы кому


					for x=1,9 do
						if rscbuffwhichtrack[x]==1 then
							local byl=0
							for z=1,#tablid[x] do

								if UnitBuff(rscrebirth2[yy], GetSpellInfo(tablid[x][z])) then
									byl=1
								end
							end

							if byl==0 then
								if #buffnotneed[x]>0 then
									local _, plclass = UnitClass(rscrebirth2[yy])
									for ccc=1,#buffnotneed[x] do
										if plclass==buffnotneed[x][ccc] then
											byl=1
										end
									end
								end
							end

							if byl==0 then
								if string.len(strin)>1 then strin=strin..", "
								end
								strin=strin..buffnamelist[x]
								if rscbuffcheckb[4]==1 then
									rscbuffcheckprioritylist(x,rscrebirth2[yy],buffnamelist[x],rscbufftimers[1])
									if rscprioritytemp==nil then --только для 1 проверки
										for ee=1,GetNumRaidMembers() do local name, _, _, _, _, claass = GetRaidRosterInfo(ee)
											if claass==classesnorm[x] and UnitIsDeadOrGhost(name)==nil and UnitAffectingCombat(name) then
												rscreportchatbyname(rscrebirth2[yy],name,rscbufftimers[1],buffnamelist[x],1)
											end
										end
									end
								end
							end
						end
					end



					if string.len(strin)>2 and rscbuffcheckb[2]==1 then
						if UnitSex(rscrebirth2[yy]) and UnitSex(rscrebirth2[yy])==3 then
							rscreportchatnobufs(rscbuffschat[1],"{rt3}"..rscrebirth2[yy].." - "..rscreleasedtxt1f.." "..rscbufftimers[1].." "..rscsec.." "..rscreleasedtxt2..", "..rscreleasedtxt3..": "..strin)
						else
							rscreportchatnobufs(rscbuffschat[1],"{rt3}"..rscrebirth2[yy].." - "..rscreleasedtxt1.." "..rscbufftimers[1].." "..rscsec.." "..rscreleasedtxt2..", "..rscreleasedtxt3..": "..strin)
						end
					end
					



					--перенос таблиц на 2 проверку если они включены
					if string.len(strin)>2 and (rscbuffcheckb[3]==1 or rscbuffcheckb[5]==1) then
						table.insert(rscrebirth4,rscrebirth2[yy])
						table.insert(rscrebirth5,(rscrebirth3[yy]+(rscbufftimers[2]-rscbufftimers[1])))
					end

					--удаление таблиц
					table.remove(rscrebirth2,yy)
					table.remove(rscrebirth3,yy)								








				else
					table.remove(rscrebirth2,yy)
					table.remove(rscrebirth3,yy)
				end
			end
		end
	end
end










--2 check
if #rscrebirth5>0 and ((rscrebnextupd2 and curtime>rscrebnextupd2) or rscrebnextupd2==nil) then

	if rscrebnextupd2==nil then
		rscrebnextupd2=rscrebirth5[1]
		for tt=1,#rscrebirth5 do
			if rscrebirth5[tt]<rscrebnextupd2 then
				rscrebnextupd2=rscrebirth5[tt]
			end
		end
	end


	if rscrebnextupd2 and curtime>rscrebnextupd2 then
		rscrebnextupd2=nil
		for yy=1,#rscrebirth5 do
			if rscrebirth5[yy] and curtime>rscrebirth5[yy] then
				--время после реса прошло, проверяем жив ли игрок и в бою ли он
				if UnitIsDeadOrGhost(rscrebirth4[yy])==nil and UnitAffectingCombat(rscrebirth4[yy]) and rscbuffcheckb[1]==1 and (rscbuffcheckb[3]==1 or rscbuffcheckb[5]==1) and (rscbcanannounce==nil or (rscbcanannounce and GetTime()>rscbcanannounce+180)) then
					--игрок жив в бою, проверка бафов и репорты
					local strin="" --список бафов нету


					--1 модуль для всех
					local tablid={{25898,20217,69378},{48470,48469},{48161,48162,69377}, {48073,48074,48104}, {48169,48170}, {48100,61024,42995,61316,43002}, {48936,48938}, {48932,48934}, {43017}} --ид бафов
					local buffnamelist={rscbuffnameslit1,rscbuffnameslit2,rscbuffnameslit3,rscbuffnameslit4,rscbuffnameslit5,rscbuffnameslit6,rscbuffnameslit7,rscbuffnameslit8,rscbuffnameslit9}
					local classesnorm={"PALADIN","DRUID","PRIEST","PRIEST","PRIEST","MAGE","PALADIN","PALADIN","MAGE"}
					local buffnotneed={{}, {}, {}, {"ROGUE","HUNTER","WARRIOR","DEATHKNIGHT"}, {}, {"ROGUE","WARRIOR","DEATHKNIGHT"}, {"ROGUE","WARRIOR","DEATHKNIGHT"}, {"PRIEST","WARLOCK","MAGE"},{}} --не нужны бафы кому


					for x=1,9 do
						if rscbuffwhichtrack[x]==1 then
							local byl=0
							for z=1,#tablid[x] do
								if UnitBuff(rscrebirth4[yy], GetSpellInfo(tablid[x][z])) then
									byl=1
								end
							end

							if byl==0 then
								if #buffnotneed[x]>0 then
									local _, plclass = UnitClass(rscrebirth4[yy])
									for ccc=1,#buffnotneed[x] do
										if plclass==buffnotneed[x][ccc] then
											byl=1
										end
									end
								end
							end

							if byl==0 then
								if string.len(strin)>1 then strin=strin..", "
								end
								strin=strin..buffnamelist[x]
								if rscbuffcheckb[5]==1 then
									rscbuffcheckprioritylist(x,rscrebirth4[yy],buffnamelist[x],rscbufftimers[2],classesnorm[x])
									for ee=1,GetNumRaidMembers() do local name, _, _, _, _, claass = GetRaidRosterInfo(ee)
										if claass==classesnorm[x] and UnitIsDeadOrGhost(name)==nil and UnitAffectingCombat(name) then
											rscreportchatbyname(rscrebirth4[yy],name,rscbufftimers[2],buffnamelist[x],2)
										end
									end
								end
							end
						end
					end


					if string.len(strin)>2 and rscbuffcheckb[3]==1 then
						rscreportchatnobufs(rscbuffschat[2],"{rt4}"..rscrebirth4[yy].." - "..rscbufftimers[2].." "..rscsec.." "..rscreleasedtxt4..": "..strin.." ("..rscreleasedtxt5..")")
					end
					

					--удаление таблиц
					table.remove(rscrebirth4,yy)
					table.remove(rscrebirth5,yy)								



				else
					table.remove(rscrebirth4,yy)
					table.remove(rscrebirth5,yy)
				end
			end
		end
	end
end













end --buff check mod

end --onupd



function rsc_OnEvent()


if event == "PLAYER_REGEN_DISABLED" then
rscboy=1

if rscbilresnut==1 then
else
--обнулять все данные при начале боя тут:

table.wipe(rscrebirth1)
table.wipe(rscrebirth2)
table.wipe(rscrebirth3)
table.wipe(rscrebirth4)
table.wipe(rscrebirth5)

--5 сек пауза после окончания боя
if rsclastfightdelay==nil or (rsclastfightdelay and GetTime()-rsclastfightdelay>5) then
if rsclastfightdelay==nil then
rsclastfightdelay=GetTime()
end

if GetNumRaidMembers() > 0 then
if rscpotionscombatsaves<3 then rscpotionscombatsaves=3 end
if rscpotionscombatsaves>25 then rscpotionscombatsaves=25 end


	table.insert(rscraidrostertable,1,{})

	table.insert(rscpotioninfotable,1,{})

	table.insert(rscchoosepotion,1,{})

	table.insert(rscbossnamestable,1,"0")


if #rscraidrostertable>rscpotionscombatsaves then
	for ty=rscpotionscombatsaves+1,#rscraidrostertable do
	
	rscraidrostertable[ty]=nil
	rscpotioninfotable[ty]=nil
	rscchoosepotion[ty]=nil
	rscbossnamestable[ty]=nil

	end
end


	if GetRaidDifficulty()==1 or GetRaidDifficulty()==3 then
	rscskokagrup=2
	else
	rscskokagrup=5
	end
	for i = 1,GetNumRaidMembers() do local name,rank,subgroup = GetRaidRosterInfo(i)
	if (subgroup <= rscskokagrup) then do table.insert(rscraidrostertable[1],(GetRaidRosterInfo(i))) end end end
	table.sort(rscraidrostertable[1])


	rscboynachat=GetTime()
	rscwasheroism=0

	--добавить название бой начат
	table.insert(rscpotionnotincombat, 1, GetTime().."++combatstart")
	rscpotionnotincombat[28]=nil



	openrscchoosbattle()
	openrscchoosepot()
	if rscframeuse1 and rscsmotryuboy==1 then rscrefleshinfo(1) end

end
end


end
end

if event == "PLAYER_REGEN_ENABLED" then
rscboy=0
if rsclastfightdelay then
rsclastfightdelay=GetTime()
end
end


if event == "PLAYER_ALIVE" then
rscbilresnut=1
end

if event == "READY_CHECK" then
if rscflaskcheckb[3]==1 then
rscflaskcheckgo()
end
end

if event == "CHAT_MSG_MONSTER_YELL" then

if rscflaskcheckb[1]==1 then

local byl=0
for i=1,#rscbosstriggertable do
	if rscbosstriggertable[i] and arg1 and (string.find(arg1,rscbosstriggertable[i]) or arg1==rscbosstriggertable[i] or string.find(string.lower(arg1),string.lower(rscbosstriggertable[i]))) then
		byl=1
		i=40
	end
end
if byl==1 then
rscwasyellpull=GetTime()
rscflaskcheckgo()
end
end
end

if event == "ADDON_LOADED" then
if arg1=="RaidSlackCheck" then

if rscflaskcheckb and rscflaskcheckb[7]==nil then rscflaskcheckb[7]=1 end

if psversion then
rscout1=psreportframe1
rscout2=psreportframe2
rscout3=psreportframe3
rscframetoshowall4=PSFrscflask
rscframetoshowall5=PSFrscbuff
else
rscout1=rscreportframe1
rscout2=rscreportframe2
rscout3=rscreportframe3
rscframetoshowall4=rscmain4
rscframetoshowall5=rscmain5
end

end
end

if event == "CHAT_MSG_ADDON" then
--buffs
if arg1=="RSCb" then

local tbl={}
local tttxt=UnitName("player")
	if UnitName("player")=="Шуршик" or UnitName("player")=="Шурши" then
		tttxt="0"..UnitName("player")
	end
	if(IsRaidOfficer()==1) then
		tttxt="0"..tttxt
	end
table.insert(tbl,tttxt)
table.insert(tbl,arg2)
table.sort(tbl)
	if tbl[1]==tttxt then
	else
		rscbcanannounce=GetTime()
	end


end

--flasks
if arg1=="RSCf" then

if string.find(arg2,"wchat") and arg4~=UnitName("player") then


local tbl={}
local tttxt=UnitName("player")
	if UnitName("player")=="Шуршик" or UnitName("player")=="Шурши" then
		tttxt="0"..UnitName("player")
	end
	if(IsRaidOfficer()==1) then
		tttxt="0"..tttxt
	end
table.insert(tbl,tttxt)
table.insert(tbl,string.sub(arg2,string.find(arg2,"nyyyck")+6))
table.sort(tbl)
	if tbl[1]==tttxt then
	else
			local byl=0
			local chatik=string.sub(arg2,string.find(arg2,"wchat")+5,string.find(arg2,"+")-1)
			if chatik=="raid" or chatik=="raid_warning" then
				rscflaskimportchat2[2]=GetTime()
			else
				for t=1,#rscflaskimportchat1 do
					if rscflaskimportchat1[t]==chatik then
						rscflaskimportchat2[t]=GetTime()
						byl=1
					end
				end
				if byl==0 then
					table.insert(rscflaskimportchat1,chatik)
					table.insert(rscflaskimportchat2,GetTime())
				end
			end
	end


end


if string.find(arg2,"whisp:yes") and arg4~=UnitName("player") then

local tbl={}
local tttxt=UnitName("player")
	if UnitName("player")=="Шуршик" or UnitName("player")=="Шурши" then
		tttxt="0"..UnitName("player")
	end
	if(IsRaidOfficer()==1) then
		tttxt="0"..tttxt
	end
table.insert(tbl,tttxt)
table.insert(tbl,string.sub(arg2,string.find(arg2,"nyyyck")+6))
table.sort(tbl)
	if tbl[1]==tttxt then
	else
		rscflaskimportchat2[1]=GetTime()
	end


end


--вижу в чате свои месаги
if arg4==UnitName("player") then
rscdelayreportstart=GetTime()
end


end --"RSCf"

if arg1=="PhoenixStyle-pull" and rscflaskcheckb[2] and rscflaskcheckb[2]==1 then
rscflaskcheckgo()
end

if arg1=="RSCfs1" and arg4~=UnitName("player") then
rscflaskdelayrep[2]=GetTime()
end

if arg1=="RSCfs2" and arg4~=UnitName("player") then
rscflaskdelayrep[1]=GetTime()
end

end


if GetNumRaidMembers() > 0 and event == "COMBAT_LOG_EVENT_UNFILTERED" then

--обнуление после реса
if rscbilresnut==1 then
if rsctimeresnut==nil then
rsctimeresnut=arg1+3
end
if arg1>rsctimeresnut then rscbilresnut=0 rsctimeresnut=nil end
end



if (rscboy==1 or (rscboy==0 and UnitIsDead("player"))) then
--мы в бою
if arg2=="SPELL_CAST_SUCCESS" then
for i,usedpotion in ipairs(rscpotiontable) do if usedpotion == arg9 then
	rscpotdrunk(1, arg4, arg9, arg10)
	end end
end

--героизм
if (arg2=="SPELL_CAST_SUCCESS" and (arg9==2825 or arg9==32182)) then
if rscwasheroism==0 then
rscwasheroism=1
--начало геры
rscvremya=GetTime()-rscboynachat
rscsec2=math.fmod (rscvremya, 60)
rscmin2=math.floor (rscvremya/60)
rscsec2=math.ceil(rscsec2)
rscpotinfo=""
if rscmin2<10 then rscpotinfo="0"..rscmin2 else rscpotinfo=rscmin2 end
if rscsec2<10 then rscpotinfo=rscpotinfo..":0"..rscsec2 else rscpotinfo=rscpotinfo..":"..rscsec2 end
rscpotinfo=rscpotinfo.."+Heroism1\124cff71d5ff\124Hspell:"..arg9.."\124h["..arg10.."]\124h\124r"
if rscpotioninfotable[1] then
table.insert(rscpotioninfotable[1], rscpotinfo)
end

--конец геры
rscpotinfo=""
rscvremya=rscvremya+40
rscsec2=math.fmod (rscvremya, 60)
rscmin2=math.floor (rscvremya/60)
rscsec2=math.ceil(rscsec2)
if rscmin2<10 then rscpotinfo="0"..rscmin2 else rscpotinfo=rscmin2 end
if rscsec2<10 then rscpotinfo=rscpotinfo..":0"..rscsec2 else rscpotinfo=rscpotinfo..":"..rscsec2 end
rscpotinfo=rscpotinfo.."+Heroism0\124cff71d5ff\124Hspell:"..arg9.."\124h["..arg10.."]\124h\124r"
if rscpotioninfotable[1] then
table.insert(rscpotioninfotable[1], rscpotinfo)

table.sort(rscpotioninfotable[1])
end

end
end


else
--не в бою
if arg2=="SPELL_CAST_SUCCESS" then
for i,usedpotion in ipairs(rscpotiontable) do if usedpotion == arg9 then
	if UnitInRaid(arg4) then
rscclasscheck(arg4)
table.insert(rscpotionnotincombat, 1, GetTime().."++"..arg4.."!!"..rsccodeclass..arg9)
rscpotionnotincombat[28]=nil
if rscframeuse1 and rscsmotryuboy==#rsctemptableval then rscnotincombatreflesh() end
	end
end end
end

end



--RSC buffs check



if arg2=="SPELL_RESURRECT" and rscbuffcheckb[1]==1 and (rscbuffcheckb[6]==1 or IsRaidOfficer()==1 or psfnopromrep) and (arg9==48477 or arg9==20484 or arg9==20742 or arg9==20739 or arg9==20747 or arg9==20748 or arg9==26994) and UnitAffectingCombat(arg4) and (rscbcanannounce==nil or (rscbcanannounce and GetTime()>rscbcanannounce+180)) then
--works ONLY IN THE RAID-INSTANCE!
local a1,a2=IsInInstance()
if a1 and a2 and a2=="raid" then

local mojn=0

if #rscignorzone>0 then
	for ug=1,#rscignorzone do
		if rscignorzone[ug]==GetRealZoneText() then
			mojn=1
		end
	end
end

if mojn==0 then

local bilne=0
if #rscrebirth1>0 then
	for i=1,#rscrebirth1 do
		if rscrebirth1[i]==arg7 then
			bilne=1
		end
	end
end

if bilne==0 then
table.insert(rscrebirth1,arg7)

	if (rscbuffcheckb[2]==1 and (rscbuffschat[1]~="sebe")) or (rscbuffcheckb[3]==1 and (rscbuffschat[2]~="sebe")) or rscbuffcheckb[4]==1 or rscbuffcheckb[5]==1 then
local stxt=UnitName("player")

if stxt=="Шуршик" or stxt=="Шурши" then
	stxt="0"..stxt
end
if(IsRaidOfficer()==1) then
	stxt="0"..stxt
end
SendAddonMessage("RSCb", stxt, "RAID")
	end

end
end
end
end


if #rscrebirth1>0 and arg2=="SPELL_AURA_APPLIED" then
local bilne=0
for i=1,#rscrebirth1 do
	if rscrebirth1[i] and rscrebirth1[i]==arg7 then
		bilne=1
		table.remove(rscrebirth1,i)
	end
end


if bilne==1 then
	if #rscrebirth2>0 then
		local biil=0
		for u=1,#rscrebirth2 do
			if rscrebirth2[u] and rscrebirth2[u]==arg7 then
				biil=1
				rscrebirth3[u]=GetTime()+rscbufftimers[1]
			end
		end

		if biil==0 then
			table.insert(rscrebirth2,arg7)
			table.insert(rscrebirth3,GetTime()+rscbufftimers[1])
		end
	else
		table.insert(rscrebirth2,arg7)
		table.insert(rscrebirth3,GetTime()+rscbufftimers[1])
	end
end

end

























end --комбат текст
end --конец основной функции аддона





--==========МЕНЮ==


function RaidSlackCheck_Command(msg)

if psversion then
PSF_potionscheck(1)
else
rscmain1:Hide()
rscmain3:Hide()
rsc_closeallpr()

rscmain1:Show()
rscmain3:Show()
rscframeuse1=1
getglobal("rscmain3_Text"):SetText("    RaidSlackCheck - "..psfpotchecklocal)
rscrefleshinfo(1)
end

end


function rsc_closeallpr()
rscmain3:Hide()
rscmain4:Hide()
rscmain5:Hide()
end

--НАСТРОЙКА данных при загрузке окна настроек
function rsc_showoptions()
bigmenuchatlistrsc = {
rscchatlist1,
rscchatlist2,
rscchatlist3,
rscchatlist4,
rscchatlist5,
rscchatlist6,
rscchatlist7,
rscchatlist8,
}

if rscfirstcreate==nil then
rscfirstcreate=1
if psversion then
rscreporttxt = PSFpotioncheckframe:CreateFontString()
rscreporttxt2 = PSFpotioncheckframe:CreateFontString()
else
rscreporttxt = rscmain3:CreateFontString()
rscreporttxt2 = rscmain3:CreateFontString()
end
rscreporttxt:SetFont(GameFontNormal:GetFont(), 14)
rscreporttxt:SetText(rsclocrep1)
rscreporttxt:SetJustifyH("LEFT")
rscreporttxt:SetPoint("TOPLEFT",415,-130)

rscreporttxt2:SetFont(GameFontNormal:GetFont(), 12)
rscreporttxt2:SetText(rsclocpot12)
rscreporttxt2:SetJustifyH("LEFT")
rscreporttxt2:SetWidth(200)
rscreporttxt2:SetHeight(15)
rscreporttxt2:SetPoint("TOPLEFT",390,-235)

end

openrscchoosbattle()
openrscchoosepot()
openmenureprsc()

if psversion then
if (rscraidlrep) then PSFpotioncheckframe_CheckButton1:SetChecked() else PSFpotioncheckframe_CheckButton1:SetChecked(false) end
if (rsccolornick) then PSFpotioncheckframe_CheckButton2:SetChecked() else PSFpotioncheckframe_CheckButton2:SetChecked(false) end
else
if (rscraidlrep) then rscmain3_CheckButton1:SetChecked() else rscmain3_CheckButton1:SetChecked(false) end
if (rsccolornick) then rscmain3_CheckButton2:SetChecked() else rscmain3_CheckButton2:SetChecked(false) end
end


end



function rscchange()

if rscraidlrep then
rscraidlrep=false
else
rscraidlrep=true
end

if psversion then
if (rscraidlrep) then PSFpotioncheckframe_CheckButton1:SetChecked() else PSFpotioncheckframe_CheckButton1:SetChecked(false) end
else
if (rscraidlrep) then rscmain3_CheckButton1:SetChecked() else rscmain3_CheckButton1:SetChecked(false) end
end

end

function rscchange2()

if rsccolornick then
rsccolornick=false
else
rsccolornick=true
end

if psversion then
if (rsccolornick) then PSFpotioncheckframe_CheckButton2:SetChecked() else PSFpotioncheckframe_CheckButton2:SetChecked(false) end
else
if (rsccolornick) then rscmain3_CheckButton2:SetChecked() else rscmain3_CheckButton2:SetChecked(false) end
end

--обн. тек список
if rscframeuse1 and #rsctemptableval==rscsmotryuboy then
--вне боя смотрю
rscnotincombatreflesh()
elseif rscframeuse1 and rscsmotryupot>1 then
--иной пот
rscrefleshchosedpot(rscsmotryuboy, rscsmotryupot-1)
elseif rscframeuse1 then
--просто рефреш
rscrefleshinfo(rscsmotryuboy)
end


end



function rsc_buttonclose()
rsc_closeallpr()
rscmain1:Hide()
rscframeuse1=nil
if rscframeuse3 then
rscsavenicks3()
rscframeuse3=nil
end
end


function bigmenuchatrsc(bigma)
if(bigma==1)then wherereporttempbigma="raid"
	elseif(bigma==2) then wherereporttempbigma="raid_warning"
	elseif(bigma==3) then wherereporttempbigma="officer"
	elseif(bigma==4) then wherereporttempbigma="party"
	elseif(bigma==5) then wherereporttempbigma="guild"
	elseif(bigma==6) then wherereporttempbigma="say"
	elseif(bigma==7) then wherereporttempbigma="yell"
	elseif(bigma==8) then wherereporttempbigma="sebe"
end
end

function bigmenuchatrsc2(bigma2)
if (bigma2=="raid") then bigma2num=1
elseif (bigma2=="raid_warning") then bigma2num=2
elseif (bigma2=="officer") then bigma2num=3
elseif (bigma2=="party") then bigma2num=4
elseif (bigma2=="guild") then bigma2num=5
elseif (bigma2=="say") then bigma2num=6
elseif (bigma2=="yell") then bigma2num=7
elseif (bigma2=="sebe") then bigma2num=8
else
bigma2num=0
end
end




--пот выпит
function rscpotdrunk(boy, imya, idpot, imyapot)
	if boy==1 then

if rscraidrostertable[1] then
for i,nepilescho in ipairs(rscraidrostertable[1]) do if nepilescho == imya then
table.remove(rscraidrostertable[1],i)

rscvremya=GetTime()-rscboynachat
rscsec2=math.fmod (rscvremya, 60)
rscmin2=math.floor (rscvremya/60)
rscsec2=math.ceil(rscsec2)
rscpotinfo=""
if rscmin2<10 then rscpotinfo="0"..rscmin2 else rscpotinfo=rscmin2 end
if rscsec2<10 then rscpotinfo=rscpotinfo..":0"..rscsec2 else rscpotinfo=rscpotinfo..":"..rscsec2 end
rscclasscheck(arg4)
rscpotinfo=rscpotinfo..imya.."++"..rsccodeclass..idpot

table.insert(rscpotioninfotable[1], rscpotinfo)
table.sort(rscpotioninfotable[1])

--проверка открыто ли окно и если да - обновление фреймов в нем
if rscframeuse1 and rscsmotryuboy==1 and rscsmotryupot==1 then
rscrefleshinfo(1)
elseif rscframeuse1 and rscsmotryuboy==1 then
--выбран иной пот
rscrefleshchosedpot(rscsmotryuboy, rscsmotryupot)
end

		bililinet=0
		for i,usedpotion2 in ipairs(rscchoosepotion[1]) do if usedpotion2 == imyapot then bililinet=1 end end
		if bililinet==0 then table.insert (rscchoosepotion[1], imyapot) table.sort(rscchoosepotion[1]) openrscchoosepot() end


end end
end
	end

end



--обновление инфы во фреймах
function rscrefleshinfo(numr)
rscout1:Clear()
rscout2:Clear()
rscout3:Clear()

if rscpotioninfotable[numr]==nil then else

	--отображение кто пил поты
	for i=1,#rscpotioninfotable[numr] do
--проверяем не гера ли
		if string.find(rscpotioninfotable[numr][i], "+Heroism") then
		rscherashowed=1
		--гера

		rscout1:AddMessage(string.sub(rscpotioninfotable[numr][i],1,5), 0.0, 1.0, 0.0)
		rscout2:AddMessage(">"..string.sub(rscpotioninfotable[numr][i],15).."<", 0.0, 1.0, 0.0)
			if string.find(rscpotioninfotable[numr][i], "+Heroism1") then
			rscout3:AddMessage("ON", 0.0, 1.0, 0.0)
			else
			rscout3:AddMessage("OFF", 0.0, 1.0, 0.0)
			end


		else


	rscout1:AddMessage(string.sub(rscpotioninfotable[numr][i],1,5))
if rsccolornick then
rsccolorset(string.sub(rscpotioninfotable[numr][i],6,string.find(rscpotioninfotable[numr][i], "++")-1),string.sub(rscpotioninfotable[numr][i],string.find(rscpotioninfotable[numr][i], "++")+2,string.find(rscpotioninfotable[numr][i], "++")+3))
else
	rscout2:AddMessage(string.sub(rscpotioninfotable[numr][i],6,string.find(rscpotioninfotable[numr][i], "++")-1))
end
local rscspellname=GetSpellInfo(tonumber(string.sub(rscpotioninfotable[numr][i],string.find(rscpotioninfotable[numr][i], "++")+4)))
	rscout3:AddMessage("\124cff71d5ff\124Hspell:"..string.sub(rscpotioninfotable[numr][i],string.find(rscpotioninfotable[numr][i], "++")+4).."\124h["..rscspellname.."]\124h\124r")



		end
	end

	--кто еще не выпил
	for i=1,#rscraidrostertable[numr] do
	rscout1:AddMessage(" ")
	rscout2:AddMessage(rscraidrostertable[numr][i], 1.0, 0.0, 0.0)
	rscout3:AddMessage(" ")
	end

	--если не было геры 2 пустые клетки
	if rscherashowed==0 then
	rscout1:AddMessage(" ")
	rscout1:AddMessage(" ")
	rscout2:AddMessage(" ")
	rscout2:AddMessage(" ")
	rscout3:AddMessage(" ")
	rscout3:AddMessage(" ")
	else rscherashowed=0 end



end

end



function openrscchoosbattle()
if not DropDownMenurscchoosbattle then
if psversion then
CreateFrame("Frame", "DropDownMenurscchoosbattle", PSFpotioncheckframe, "UIDropDownMenuTemplate")
else
CreateFrame("Frame", "DropDownMenurscchoosbattle", rscmain3, "UIDropDownMenuTemplate")
end
end

DropDownMenurscchoosbattle:ClearAllPoints()
DropDownMenurscchoosbattle:SetPoint("TOPLEFT", 385, -20)
DropDownMenurscchoosbattle:Show()


rsctemptableval={}
table.wipe(rsctemptableval)
if rscbossnamestable[1]=="0" or rscbossnamestable[1]==nil then
	rsctemptableval={rscloclastf,}
else
	rsctemptableval={rscbossnamestable[1],}
end
for i=2,# rscpotioninfotable do
	if rscbossnamestable[i]==nil or (rscbossnamestable[i] and rscbossnamestable[i]=="0") then
		table.insert (rsctemptableval, "-"..(i-1))
	else
		table.insert (rsctemptableval, rscbossnamestable[i])
	end
end
table.insert(rsctemptableval, rsclocnotinc)

local items = rsctemptableval

local function OnClick(self)
UIDropDownMenu_SetSelectedID(DropDownMenurscchoosbattle, self:GetID())

if #rsctemptableval==self:GetID() then
--вне боя активно
rscsmotryuboy=self:GetID()
rscnotincombatreflesh()
rscmain3_Button10:Hide()
rscmain3_Button11:Hide()
rscmain3_Button30:Show()
rscmain3_Button40:Show()
if rscreporttxt2 then rscreporttxt2:Show() end
if psversion then
PSFpotioncheckframe_Button10:Hide()
PSFpotioncheckframe_Button11:Hide()
PSFpotioncheckframe_Button30:Show()
PSFpotioncheckframe_Button40:Show()
if rscreporttxt2 then rscreporttxt2:Show() end
end

else
--просмотр
rscmain3_Button10:Show()
rscmain3_Button11:Show()
rscmain3_Button30:Hide()
rscmain3_Button40:Hide()
if rscreporttxt2 then rscreporttxt2:Hide() end
if psversion then
PSFpotioncheckframe_Button10:Show()
PSFpotioncheckframe_Button11:Show()
PSFpotioncheckframe_Button30:Hide()
PSFpotioncheckframe_Button40:Hide()
if rscreporttxt2 then rscreporttxt2:Hide() end
end
rscsmotryuboy=self:GetID()
rscrefleshinfo(self:GetID())
end
openrscchoosepot()


end

local function initialize(self, level)
local info = UIDropDownMenu_CreateInfo()
for k,v in pairs(items) do
	info = UIDropDownMenu_CreateInfo()
	info.text = v
	info.value = v
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end
end

rscsmotryuboy=1
rscmain3_Button10:Show()
rscmain3_Button11:Show()
rscmain3_Button30:Hide()
rscmain3_Button40:Hide()
if rscreporttxt2 then rscreporttxt2:Hide() end
if psversion then
PSFpotioncheckframe_Button10:Show()
PSFpotioncheckframe_Button11:Show()
PSFpotioncheckframe_Button30:Hide()
PSFpotioncheckframe_Button40:Hide()
if rscreporttxt2 then rscreporttxt2:Hide() end
end
UIDropDownMenu_Initialize(DropDownMenurscchoosbattle, initialize)
UIDropDownMenu_SetWidth(DropDownMenurscchoosbattle, 140);
UIDropDownMenu_SetButtonWidth(DropDownMenurscchoosbattle, 155)
UIDropDownMenu_SetSelectedID(DropDownMenurscchoosbattle,1)
UIDropDownMenu_JustifyText(DropDownMenurscchoosbattle, "LEFT")
end



--меню выбор пота
function openrscchoosepot()
if not DropDownMenurscchoosepot then
if psversion then
CreateFrame("Frame", "DropDownMenurscchoosepot", PSFpotioncheckframe, "UIDropDownMenuTemplate")
else
CreateFrame("Frame", "DropDownMenurscchoosepot", rscmain3, "UIDropDownMenuTemplate")
end
end

DropDownMenurscchoosepot:ClearAllPoints()
DropDownMenurscchoosepot:SetPoint("TOPLEFT", 385, -60)
DropDownMenurscchoosepot:Show()


rsctemptableval2={}
table.wipe(rsctemptableval2)
	if rscsmotryuboy==#rsctemptableval then
	rsctemptableval2={rsclocallpot}
	else
rsctemptableval2={rsclocallpot,}
		if rscchoosepotion[rscsmotryuboy] then
for i=1,# rscchoosepotion[rscsmotryuboy] do
table.insert (rsctemptableval2, rscchoosepotion[rscsmotryuboy][i])
end
		end
	end


local items = rsctemptableval2

local function OnClick(self)
UIDropDownMenu_SetSelectedID(DropDownMenurscchoosepot, self:GetID())

--
if rscsmotryuboy==#rsctemptableval and self:GetID()==1 then
rscnotincombatreflesh()
elseif self:GetID()==1 then
rscrefleshinfo(rscsmotryuboy)
else
rscrefleshchosedpot(rscsmotryuboy, self:GetID()-1)
end
rscsmotryupot=self:GetID()

if psversion then
if rscsmotryupot>1 then
PSFpotioncheckframe_Button20:Show()
PSFpotioncheckframe_Button11:Hide()
else
PSFpotioncheckframe_Button20:Hide()
if rscsmotryuboy==#rsctemptableval then else PSFpotioncheckframe_Button11:Show() end
end
else
if rscsmotryupot>1 then
rscmain3_Button20:Show()
rscmain3_Button11:Hide()
else
rscmain3_Button20:Hide()
if rscsmotryuboy==#rsctemptableval then else rscmain3_Button11:Show() end
end
end

end

local function initialize(self, level)
local info = UIDropDownMenu_CreateInfo()
for k,v in pairs(items) do
	info = UIDropDownMenu_CreateInfo()
	info.text = v
	info.value = v
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end
end

rscsmotryupot=1
if psversion then
PSFpotioncheckframe_Button20:Hide()
else
rscmain3_Button20:Hide()
end

UIDropDownMenu_Initialize(DropDownMenurscchoosepot, initialize)
UIDropDownMenu_SetWidth(DropDownMenurscchoosepot, 140);
UIDropDownMenu_SetButtonWidth(DropDownMenurscchoosepot, 155)
UIDropDownMenu_SetSelectedID(DropDownMenurscchoosepot,1)
UIDropDownMenu_JustifyText(DropDownMenurscchoosepot, "LEFT")
end


function rscnotincombatreflesh()
rscout1:Clear()
rscout2:Clear()
rscout3:Clear()

i=#rscpotionnotincombat
while i>0 do

rscvremya=GetTime()-tonumber(string.sub(rscpotionnotincombat[i],1,string.find(rscpotionnotincombat[i], "++")-1))
rscsec2=math.fmod (rscvremya, 60)
rscmin2=math.floor (rscvremya/60)
rscsec2=math.ceil(rscsec2)
rscpotinfo=""
if rscmin2<10 then rscpotinfo="0"..rscmin2 else rscpotinfo=rscmin2 end
if rscsec2<10 then rscpotinfo=rscpotinfo..":0"..rscsec2 else rscpotinfo=rscpotinfo..":"..rscsec2 end
	if rscmin2>99 then rscout1:AddMessage("-"..rscmin2) else
rscout1:AddMessage("-"..rscpotinfo)
	end
		if string.find(rscpotionnotincombat[i], "combatstart") then
		rscout2:AddMessage("Combat +", 0.0, 1.0, 0.0)
		rscout3:AddMessage(" ")
		else
if rsccolornick then
rsccolorset(string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i], "++")+2,string.find(rscpotionnotincombat[i], "!!")-1),string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i], "!!")+2,string.find(rscpotionnotincombat[i], "!!")+3))
else
rscout2:AddMessage(string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i], "++")+2,string.find(rscpotionnotincombat[i], "!!")-1))
end
local rscspellname=GetSpellInfo(tonumber(string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i], "!!")+4)))
rscout3:AddMessage("\124cff71d5ff\124Hspell:"..string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i], "!!")+4).."\124h["..rscspellname.."]\124h\124r")
		end

i=i-1
end
end


function rscrefleshchosedpot(numrboy, numrpot)
if rscotherpotdrunk==nil then rscotherpotdrunk={} end
table.wipe(rscotherpotdrunk)

rscout1:Clear()
rscout2:Clear()
rscout3:Clear()
if rscpotioninfotable[numrboy]==nil then else

	--отображение кто пил поты
	for i=1,#rscpotioninfotable[numrboy] do
--проверяем не гера ли
		if string.find(rscpotioninfotable[numrboy][i], "+Heroism") then
		rscherashowed=1
		--гера
		rscout1:AddMessage(string.sub(rscpotioninfotable[numrboy][i],1,5), 0.0, 1.0, 0.0)
		rscout2:AddMessage(">"..string.sub(rscpotioninfotable[numrboy][i],15).."<", 0.0, 1.0, 0.0)
			if string.find(rscpotioninfotable[numrboy][i], "+Heroism1") then
			rscout3:AddMessage("ON", 0.0, 1.0, 0.0)
			else
			rscout3:AddMessage("OFF", 0.0, 1.0, 0.0)
			end
		else


local rscspellname2=GetSpellInfo(tonumber(string.sub(rscpotioninfotable[numrboy][i],string.find(rscpotioninfotable[numrboy][i], "++")+4)))
if rscspellname2==rscchoosepotion[numrboy][numrpot] then
	rscout1:AddMessage(string.sub(rscpotioninfotable[numrboy][i],1,5))
if rsccolornick then
rsccolorset(string.sub(rscpotioninfotable[numrboy][i],6,string.find(rscpotioninfotable[numrboy][i], "++")-1),string.sub(rscpotioninfotable[numrboy][i],string.find(rscpotioninfotable[numrboy][i], "++")+2,string.find(rscpotioninfotable[numrboy][i], "++")+3))
else
	rscout2:AddMessage(string.sub(rscpotioninfotable[numrboy][i],6,string.find(rscpotioninfotable[numrboy][i], "++")-1))
end
local rscspellname=GetSpellInfo(tonumber(string.sub(rscpotioninfotable[numrboy][i],string.find(rscpotioninfotable[numrboy][i], "++")+4)))
	rscout3:AddMessage("\124cff71d5ff\124Hspell:"..string.sub(rscpotioninfotable[numrboy][i],string.find(rscpotioninfotable[numrboy][i], "++")+4).."\124h["..rscspellname.."]\124h\124r")
else
--добавить ник в список в конце
table.insert(rscotherpotdrunk, rscpotioninfotable[numrboy][i])


end
		end
	end

	--кто пил отображен зеленым
		if rscotherpotdrunk then
		if #rscotherpotdrunk>0 then
	rscout1:AddMessage("------", 0.0, 1.0, 0.0)
	rscout2:AddMessage("-------------", 0.0, 1.0, 0.0)
	rscout3:AddMessage("------------------", 0.0, 1.0, 0.0)
	
	for i=1,#rscotherpotdrunk do
	rscout1:AddMessage(string.sub(rscotherpotdrunk[i],1,5), 0.0, 1.0, 0.0)
	rscout2:AddMessage(string.sub(rscotherpotdrunk[i],6,string.find(rscotherpotdrunk[i], "++")-1), 0.0, 1.0, 0.0)
local rscspellname=GetSpellInfo(tonumber(string.sub(rscotherpotdrunk[i],string.find(rscotherpotdrunk[i], "++")+4)))
	rscout3:AddMessage("\124cff71d5ff\124Hspell:"..string.sub(rscotherpotdrunk[i],string.find(rscotherpotdrunk[i], "++")+4).."\124h["..rscspellname.."]\124h\124r")
	end

		end end

	--кто еще не выпил
	if #rscraidrostertable>0 then
	for i=1,#rscraidrostertable[numrboy] do
	rscout1:AddMessage(" ")
	rscout2:AddMessage(rscraidrostertable[numrboy][i], 1.0, 0.0, 0.0)
	rscout3:AddMessage(" ")
	end
	end


	--если не было геры 2 пустые клетки
	if rscherashowed==0 then
	rscout1:AddMessage(" ")
	rscout1:AddMessage(" ")
	rscout2:AddMessage(" ")
	rscout2:AddMessage(" ")
	rscout3:AddMessage(" ")
	rscout3:AddMessage(" ")
	else rscherashowed=0 end


end



end


function openmenureprsc()
if not DropDownMenureprsc then
if psversion then
CreateFrame("Frame", "DropDownMenureprsc", PSFpotioncheckframe, "UIDropDownMenuTemplate")
else
CreateFrame("Frame", "DropDownMenureprsc", rscmain3, "UIDropDownMenuTemplate")
end
end

DropDownMenureprsc:ClearAllPoints()
DropDownMenureprsc:SetPoint("TOPLEFT", 385, -180)
DropDownMenureprsc:Show()

local items = bigmenuchatlistrsc

if psversion then
items = bigmenuchatlist
end

local function OnClick(self)
UIDropDownMenu_SetSelectedID(DropDownMenureprsc, self:GetID())

if psversion then

if self:GetID()>8 then
rscchatrep=psfchatadd[self:GetID()-8]
else
rscchatrep=bigmenuchatlisten[self:GetID()]
end

else
	if self:GetID()>8 then
	bigmenuchatrsc(1)
	else
	bigmenuchatrsc(self:GetID())
	end
rscchatrep=wherereporttempbigma
end

end

local function initialize(self, level)
local info = UIDropDownMenu_CreateInfo()
for k,v in pairs(items) do
	info = UIDropDownMenu_CreateInfo()
	info.text = v
	info.value = v
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end
end

if psversion then

bigmenuchat2(rscchatrep)
if bigma2num==0 then
rscchatrep=bigmenuchatlisten[1]
bigma2num=1
end

else

bigmenuchatrsc2(rscchatrep)
if bigma2num==0 then
rscchatrep="raid"
bigma2num=1
end

end

UIDropDownMenu_Initialize(DropDownMenureprsc, initialize)
UIDropDownMenu_SetWidth(DropDownMenureprsc, 110)
UIDropDownMenu_SetButtonWidth(DropDownMenureprsc, 125)
UIDropDownMenu_SetSelectedID(DropDownMenureprsc,bigma2num)
UIDropDownMenu_JustifyText(DropDownMenureprsc, "LEFT")
end


function rscrepnopot()
if rscraidrostertable[1] then


local tablpotdrink={}
if #rscpotioninfotable[rscsmotryuboy]>0 then
for i=1,#rscpotioninfotable[rscsmotryuboy] do
     if string.find(rscpotioninfotable[rscsmotryuboy][i],"Heroism") then else
     table.insert(tablpotdrink, string.sub(rscpotioninfotable[rscsmotryuboy][i],6,string.find(rscpotioninfotable[rscsmotryuboy][i],"++")-1))
     end
end
end
table.sort(tablpotdrink)


local rscstrochka=""
local rscstrochka2=""
local kakojboi=""

if rscsmotryuboy==1 then
kakojboi="("..rsclocfight1..")"
elseif rscsmotryuboy==2 then
kakojboi="("..rsclocfight2..")"
else
kakojboi="(-"..(rscsmotryuboy-1).." "..rsclocfight3..")"
end



if #tablpotdrink==0 then
--никто не пил
rscstrochka=rsclocpot17.." "..kakojboi.."."
rscchatsendreports(rscchatrep,rscstrochka, " ", " ", " ", " ")

elseif #rscraidrostertable[rscsmotryuboy]>0 then

rscstrochka="{rt8}"..rsclocpot3.." "..kakojboi..": "


for i=1,#rscraidrostertable[rscsmotryuboy] do

if rscraidlrep then else
rsccheckleader(rscraidrostertable[rscsmotryuboy][i])
end

			if rscraidleader==nil then
	if #rscraidrostertable[rscsmotryuboy]==i then
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscraidrostertable[rscsmotryuboy][i].."."
		else
		rscstrochka2=rscstrochka2..rscraidrostertable[rscsmotryuboy][i].."."
		end
	else
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscraidrostertable[rscsmotryuboy][i]..", "
		else
		rscstrochka2=rscstrochka2..rscraidrostertable[rscsmotryuboy][i]..", "
		end
	end

			end
rscraidleader=nil


end

rscchatsendreports(rscchatrep,rscstrochka, rscstrochka2, " ", " ", " ")



else

local rscstrochka=""

if rscsmotryuboy==1 then
rscstrochka=rsclocpot4.." ("..rsclocfight1..")."
elseif rscsmotryuboy==2 then
rscstrochka=rsclocpot4.." ("..rsclocfight2..")."
else
rscstrochka=rsclocpot4.." (-"..(rscsmotryuboy-1).." "..rsclocfight3..")."
end

rscchatsendreports(rscchatrep,rscstrochka, " ", " ", " ", " ")


end






end
end



function rscrepnochossedpot()
if rscraidrostertable[1] then
local rscstrochka="{rt6}RaidSlackCheck - "..rsclocpot5.." '"..rscchoosepotion[rscsmotryuboy][rscsmotryupot-1].."' "
local rscstrochka2=""
local rscstrochka3=""
local rscstrochka4=""
local rscstrochka5=""
local rsckakojboj=""

if rscsmotryuboy==1 then
rsckakojboj="("..rsclocfight1..")"
elseif rscsmotryuboy==2 then
rsckakojboj="("..rsclocfight2..")"
else
rsckakojboj="(-"..(rscsmotryuboy-1).." "..rsclocfight3..")"
end

rscstrochka=rscstrochka..rsckakojboj..":"
rscstrochka2="{rt8}"..rsclocpot6

--кто не пил поты
if #rscraidrostertable[rscsmotryuboy]>0 then
	
for i=1,#rscraidrostertable[rscsmotryuboy] do

if rscraidlrep then else
rsccheckleader(rscraidrostertable[rscsmotryuboy][i])
end

			if rscraidleader==nil then

	if #rscraidrostertable[rscsmotryuboy]==i then
		if string.len(rscstrochka2)<230 then
		rscstrochka2=rscstrochka2..rscraidrostertable[rscsmotryuboy][i].."."
		else
		rscstrochka3=rscstrochka3..rscraidrostertable[rscsmotryuboy][i].."."
		end
	else
		if string.len(rscstrochka2)<230 then
		rscstrochka2=rscstrochka2..rscraidrostertable[rscsmotryuboy][i]..", "
		else
		rscstrochka3=rscstrochka3..rscraidrostertable[rscsmotryuboy][i]..", "
		end
	end

			end
rscraidleader=nil

end

else
rscstrochka2=rscstrochka2..rsclocpot7.."."
end

--другие поты

if #rscotherpotdrunk>0 then

rscstrochka4="{rt7}"..rsclocpot8
for i=1,#rscotherpotdrunk do
	if #rscotherpotdrunk==i then
		if string.len(rscstrochka4)<230 then
		rscstrochka4=rscstrochka4..(string.sub(rscotherpotdrunk[i],6,string.find(rscotherpotdrunk[i], "++")-1)).."."
		else
		rscstrochka5=rscstrochka5..(string.sub(rscotherpotdrunk[i],6,string.find(rscotherpotdrunk[i], "++")-1)).."."
		end
	else
		if string.len(rscstrochka4)<230 then
		rscstrochka4=rscstrochka4..(string.sub(rscotherpotdrunk[i],6,string.find(rscotherpotdrunk[i], "++")-1))..", "
		else
		rscstrochka5=rscstrochka5..(string.sub(rscotherpotdrunk[i],6,string.find(rscotherpotdrunk[i], "++")-1))..", "
		end
	end
end

else
rscstrochka4=rsclocpot9
end


rscchatsendreports(rscchatrep,rscstrochka, rscstrochka2, rscstrochka3, rscstrochka4, rscstrochka5)



end
end


function rscchatsendreports(chat,nnn1, nnn2, nnn3, nnn4, nnn5, nnn6, nnn7, nnn8, nnn9, nnn10)
if chat=="raid_warning" and IsRaidOfficer()==nil then chat="raid" end
if nnn2==nil then nnn2=" " end
if nnn3==nil then nnn3=" " end
if nnn4==nil then nnn4=" " end
if nnn5==nil then nnn5=" " end
if nnn6==nil then nnn6=" " end
if nnn7==nil then nnn7=" " end
if nnn8==nil then nnn8=" " end
if nnn9==nil then nnn9=" " end
if nnn10==nil then nnn10=" " end
local nnn={nnn1,nnn2,nnn3,nnn4,nnn5, nnn6, nnn7, nnn8, nnn9, nnn10}
for i=1,10 do
if string.len(nnn[i])>2 then

if chat=="sebe" then
DEFAULT_CHAT_FRAME:AddMessage(nnn[i])
else
bigmenuchatrsc2(chat)
	if bigma2num>0 then
		SendChatMessage(nnn[i], chat)
	else

local nrchatmy=GetChannelName(chat)
	if nrchatmy==0 then
	JoinPermanentChannel(chat)
	ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, chat)
	nrchatmy=GetChannelName(chat)
	end
if nrchatmy>0 then
SendChatMessage(nnn[i], "CHANNEL",nil,nrchatmy)
end

	end
end


end
end
end

function rsccheckleader(nname)
	for i = 1,GetNumRaidMembers() do local name,rank = GetRaidRosterInfo(i)
	if (rank == 2 and nname==name) then rscraidleader=1 end end
end

function rscbeforelastcombatcheck()
if #rscpotionnotincombat>0 then
	local i=1
	while i<=#rscpotionnotincombat do
		if rscboyfound==1 then
			--бой найден собираем инфу о никах до след боя или минуту
			if (string.find(rscpotionnotincombat[i], "combatstart") or (rscttime-tonumber(string.sub(rscpotionnotincombat[i],1,string.find(rscpotionnotincombat[i],"++")-1)))>59) then
				i=100
			else
				table.insert(rscdrinkbeforecom, string.sub(rscpotionnotincombat[i],string.find(rscpotionnotincombat[i],"++")+2,string.find(rscpotionnotincombat[i],"!!")-1))
				table.sort(rscdrinkbeforecom)
			end
		else
			--бой еще не найден, ищем
			if string.find(rscpotionnotincombat[i], "combatstart") then
				rscttime=tonumber(string.sub(rscpotionnotincombat[i],1,string.find(rscpotionnotincombat[i],"++")-1))
				rscboyfound=1
			end
		end
	i=i+1
	end
end
end

function rscrepnortafretcom1()

rscttime=0 --время последнего боя
rscdrinkbeforecom={} --записывать сюда список тех кто пили поты
rscboyfound=0

rscbeforelastcombatcheck()

if #rscdrinkbeforecom>0 then

--тут вывод тех кто пил


local rscstrochka="{rt1}"..rsclocpot13
local rscstrochka2=""

for i=1,#rscdrinkbeforecom do



	if #rscdrinkbeforecom==i then
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscdrinkbeforecom[i].."."
		else
		rscstrochka2=rscstrochka2..rscdrinkbeforecom[i].."."
		end
	else
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscdrinkbeforecom[i]..", "
		else
		rscstrochka2=rscstrochka2..rscdrinkbeforecom[i]..", "
		end
	end

end

rscchatsendreports(rscchatrep,rscstrochka, rscstrochka2, " ", " ", " ")

elseif rscboyfound==1 then
rscchatsendreports(rscchatrep,"{rt8}"..rsclocpot14, " ", " ", " ", " ")
end

rscttime=nil
rscdrinkbeforecom=nil
rscboyfound=nil

end


function rscrepnortafretcom2()

rscttime=0 --время последнего боя
rscdrinkbeforecom={} --записывать сюда список тех кто пили поты
rscboyfound=0

rscbeforelastcombatcheck()

if #rscdrinkbeforecom==0 then
--никто не пил поты вообще!
if rscboyfound==1 then
rscchatsendreports(rscchatrep,"{rt8}"..rsclocpot14, " ", " ", " ", " ")
end

elseif #rscdrinkbeforecom<4 then
--выпило поты всего пару чел
local rsctxttmp="{rt1}"..rsclocpot15..#rscdrinkbeforecom..": "
local rsckoma=""
	for i=1,#rscdrinkbeforecom do
	if #rscdrinkbeforecom==i then rsckoma="." else rsckoma=", " end
	rsctxttmp=rsctxttmp..rscdrinkbeforecom[i]..rsckoma
	end
rscchatsendreports(rscchatrep,rsctxttmp, " ", " ", " ", " ")

else

--тут собрать список и вывести результат
local rscdrinkallraid={} --весь рейд список

if #rscraidrostertable[1]>0 then
for i=1,#rscraidrostertable[1] do
	table.insert(rscdrinkallraid, rscraidrostertable[1][i])
end
end

if #rscpotioninfotable[1]>0 then
for i=1,#rscpotioninfotable[1] do
	if string.find(rscpotioninfotable[1][i],"Heroism") then else
	table.insert(rscdrinkallraid, string.sub(rscpotioninfotable[1][i],6,string.find(rscpotioninfotable[1][i],"++")-1))
	end
end
end

table.sort(rscdrinkallraid)

--тут отсеивать с теми кто пил
local k=1
while k<=#rscdrinkbeforecom do
	local l=1
	while l<=#rscdrinkallraid do
		if rscdrinkallraid[l]==rscdrinkbeforecom[k] then
			table.remove(rscdrinkallraid,l)
			l=100
		end
	l=l+1
	end
k=k+1
end


--тут вывод списка
if #rscdrinkallraid>0 then

local rscstrochka="{rt8}"..rsclocpot16
local rscstrochka2=""

for i=1,#rscdrinkallraid do

if rscraidlrep then else
rsccheckleader(rscdrinkallraid[i])
end

			if rscraidleader==nil then
	if #rscdrinkallraid==i then
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscdrinkallraid[i].."."
		else
		rscstrochka2=rscstrochka2..rscdrinkallraid[i].."."
		end
	else
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..rscdrinkallraid[i]..", "
		else
		rscstrochka2=rscstrochka2..rscdrinkallraid[i]..", "
		end
	end

			end
rscraidleader=nil


end

rscchatsendreports(rscchatrep,rscstrochka, rscstrochka2, " ", " ", " ")
end

rscdrinkallraid=nil

end




rscttime=nil
rscdrinkbeforecom=nil
rscboyfound=nil

end


--кто пил поты репорт
function rscrepnopot2()


if rscpotioninfotable[1] then

local kakojboi=""
local rscstrochka=""
local rscstrochka2=""

if rscsmotryuboy==1 then
kakojboi="("..rsclocfight1..")"
elseif rscsmotryuboy==2 then
kakojboi="("..rsclocfight2..")"
else
kakojboi="(-"..(rscsmotryuboy-1).." "..rsclocfight3..")"
end


if rscraidrostertable[rscsmotryuboy] and #rscpotioninfotable[rscsmotryuboy]==0 then
--никто не пил поты поты!
rscstrochka=rsclocpot17.." "..kakojboi.."."
end


if rscpotioninfotable[rscsmotryuboy] and #rscraidrostertable[rscsmotryuboy]==0 then
--все пили поты!
rscstrochka=rsclocpot4.." "..kakojboi.."."

elseif #rscpotioninfotable[rscsmotryuboy]>0 then

rscstrochka="{rt1}"..rsclocpot18.." "..kakojboi..": "


local tablpotdrink={}
if #rscpotioninfotable[rscsmotryuboy]>0 then
for i=1,#rscpotioninfotable[rscsmotryuboy] do
	if string.find(rscpotioninfotable[rscsmotryuboy][i],"Heroism") then else
	table.insert(tablpotdrink, string.sub(rscpotioninfotable[rscsmotryuboy][i],6,string.find(rscpotioninfotable[rscsmotryuboy][i],"++")-1))
	end
end
end
table.sort(tablpotdrink)


for i=1,#tablpotdrink do


	if #tablpotdrink==i then
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..tablpotdrink[i].."."
		else
		rscstrochka2=rscstrochka2..tablpotdrink[i].."."
		end
	else
		if string.len(rscstrochka)<230 then
		rscstrochka=rscstrochka..tablpotdrink[i]..", "
		else
		rscstrochka2=rscstrochka2..tablpotdrink[i]..", "
		end
	end


end


end

rscchatsendreports(rscchatrep,rscstrochka, rscstrochka2, " ", " ", " ")




end
end

function rscclasscheck(imya)
rsccodeclass="00"
local _, rsctekclass = UnitClass(imya)
				if rsctekclass then
rsctekclass=string.lower(rsctekclass)

if rsctekclass=="warrior" then rsccodeclass="01"
elseif rsctekclass=="deathknight" then rsccodeclass="02"
elseif rsctekclass=="paladin" then rsccodeclass="03"
elseif rsctekclass=="priest" then rsccodeclass="04"
elseif rsctekclass=="shaman" then rsccodeclass="05"
elseif rsctekclass=="druid" then rsccodeclass="06"
elseif rsctekclass=="rogue" then rsccodeclass="07"
elseif rsctekclass=="mage" then rsccodeclass="08"
elseif rsctekclass=="warlock" then rsccodeclass="09"
elseif rsctekclass=="hunter" then rsccodeclass="10"
end
				end
end


function rsccolorset(imya,colid)
if colid=="01" then rscout2:AddMessage("|CFFC69B6D"..imya.."|r")
elseif colid=="02" then rscout2:AddMessage("|CFFC41F3B"..imya.."|r")
elseif colid=="03" then rscout2:AddMessage("|CFFF48CBA"..imya.."|r")
elseif colid=="04" then rscout2:AddMessage("|CFFFFFFFF"..imya.."|r")
elseif colid=="05" then rscout2:AddMessage("|CFF1a3caa"..imya.."|r")
elseif colid=="06" then rscout2:AddMessage("|CFFFF7C0A"..imya.."|r")
elseif colid=="07" then rscout2:AddMessage("|CFFFFF468"..imya.."|r")
elseif colid=="08" then rscout2:AddMessage("|CFF68CCEF"..imya.."|r")
elseif colid=="09" then rscout2:AddMessage("|CFF9382C9"..imya.."|r")
elseif colid=="10" then rscout2:AddMessage("|CFFAAD372"..imya.."|r")
else
rscout2:AddMessage(imya)
end
end


function rscbossfrompssave(bosss,time)
if rscbossnamestable and rscbossnamestable[1]=="0" and bosss and time then
rscbossnamestable[1]=bosss..", "..time
end
end

function rscrezetpot()
if rscboy==0 then

	rscraidrostertable={}
	rscpotioninfotable={}
	rscchoosepotion={}
	rscbossnamestable={}

	rscpotionnotincombat={}





rscmain3_Button10:Show()
rscmain3_Button11:Show()
rscmain3_Button30:Hide()
rscmain3_Button40:Hide()
openrscchoosbattle()
if rscreporttxt2 then rscreporttxt2:Hide() end
if psversion then
PSFpotioncheckframe_Button10:Show()
PSFpotioncheckframe_Button11:Show()
PSFpotioncheckframe_Button30:Hide()
PSFpotioncheckframe_Button40:Hide()
if rscreporttxt2 then rscreporttxt2:Hide() end
end
rscsmotryuboy=1
rscrefleshinfo(1)
openrscchoosepot()


end
end

function rscwindow1()
rsc_closeallpr()
if rscframeuse3 then
rscsavenicks3()
rscframeuse3=nil
end
rscmain3:Show()
getglobal("rscmain3_Text"):SetText("    RaidSlackCheck - "..psfpotchecklocal)
rscframeuse1=1
rscrefleshinfo(1)
end

function rscwindow2()
--фласкочек
rsc_closeallpr()
if rscframeuse3 then
rscsavenicks3()
rscframeuse3=nil
end
	if psversion then
getglobal("PSFrscflask_Text"):SetText("    "..psfpotchecklocalt2)
	else
getglobal("rscmain4_Text"):SetText("    RaidSlackCheck - "..psfpotchecklocalt2)
	end
rscframetoshowall4:Show()

rsccreateframeflasks()

end

function rscwindow3()
--бафы после бреса
rsc_closeallpr()
if rscframeuse3 then
rscsavenicks3()
rscframeuse3=nil
end
rscframetoshowall5:Show()
	if psversion then
getglobal("PSFrscbuff_Text"):SetText("    "..psfpotchecklocalt322)
	else
getglobal("rscmain5_Text"):SetText("    RaidSlackCheck - "..psfpotchecklocalt322)
	end
rscframeuse3=1
rsccreateframebafs()
end


function rscChatFilter(self, event, msg, author, ...)
if msg and self then
msg=string.lower(msg)
	if msg:find(string.lower(rscflaskwhisptxt1)) or msg:find(string.lower(rscflaskwhisptxt2)) or msg:find(string.lower(rscflaskwhisptxt3)) or msg:find(string.lower(rscflaskwhisptxt4)) or msg:find(string.lower(rscflaskwhisptxt5)) or msg:find(string.lower(rscflaskwhisptxt11)) or msg:find(string.lower(rscflaskwhisptxt33)) or msg:find(string.lower(rscflaskwhisptxt40)) or msg:find(string.lower(rscflaskwhisptxt44)) or msg:find(string.lower(rscflaskwhisptxt55)) or msg:find(string.lower(rscflaskwhisptxt56)) or msg:find(string.lower(rscreleasedtxt6)) or msg:find(string.lower(rscreleasedtxt6f)) or msg:find(string.lower(rscreleasedtxt7)) or msg:find(string.lower(rscreleasedtxt7f)) then
	return true

	end
end
end

function rscchatfiltimefunc()
if rscchatfiltime==nil then
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", rscChatFilter)
rscchatfiltime=GetTime()
else
rscchatfiltime=GetTime()
end
end

function out(text)
DEFAULT_CHAT_FRAME:AddMessage(text)
UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end