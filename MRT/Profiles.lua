local GlobalAddonName, ExRT = ...

local module = ExRT:New("Profiles",ExRT.L.Profiles)
local ELib,L = ExRT.lib,ExRT.L

local LibDeflate = LibStub:GetLibrary("LibDeflate")

local MAJOR_KEYS = {
	["Addon"]=true,
	["Profiles"]=true,
	["Profile"]=true,
	["ProfileKeys"]=true,
}

function module:ReselectProfileOnLoad()
	if VMRT.ProfileKeys and not VMRT.ProfileKeys[ ExRT.SDB.charKey ] then
		VMRT.ProfileKeys[ ExRT.SDB.charKey ] = "default"
	end
	if not VMRT.ProfileKeys or not VMRT.ProfileKeys[ ExRT.SDB.charKey ] or not VMRT.Profile or not VMRT.Profiles then
		return
	end
	local charProfile = VMRT.ProfileKeys[ ExRT.SDB.charKey ]
	if charProfile == VMRT.Profile then
		return
	end
	if not VMRT.Profiles[ charProfile ] then
		VMRT.ProfileKeys[ ExRT.SDB.charKey ] = VMRT.Profile
		return
	end
	local saveDB = {}
	VMRT.Profiles[ VMRT.Profile ] = saveDB

	for key,val in pairs(VMRT) do
		if not MAJOR_KEYS[key] then
			saveDB[key] = val
		end
	end

	for key,val in pairs(VMRT) do
		if not MAJOR_KEYS[key] then
			VMRT[key] = nil
		end
	end

	for key,val in pairs( VMRT.Profiles[ charProfile ] ) do
		if not MAJOR_KEYS[key] then
			VMRT[key] = val
		end
	end
	VMRT.Profiles[ charProfile ] = {}
	VMRT.Profile = charProfile
end

function module.options:Load()
	local function GetCurrentProfileName()
		return VMRT.Profile=="default" and L.ProfilesDefault or VMRT.Profile
	end
	local function GetCurrentProfilesList(func)
		local list = {
			{ text = L.ProfilesDefault, func = func, arg1 = "default", _sort = "0" },
		}
		for name,_ in pairs(VMRT.Profiles) do
			if name ~= "default" then
				list[#list + 1] = { text = name, func = func, arg1 = name, _sort = "1"..name }
			end
		end
		sort(list,function(a,b) return a._sort < b._sort end)
		return list
	end
	local function SaveCurrentProfiletoDB()
		local profileName = VMRT.Profile or "default"
		local saveDB = {}
		VMRT.Profiles[ profileName ] = saveDB

		for key,val in pairs(VMRT) do
			if not MAJOR_KEYS[key] then
				saveDB[key] = val
			end
		end
	end
	local function LoadProfileFromDB(profileName,isCopy)
		local loadDB = VMRT.Profiles[ profileName ]
		if not loadDB then
			print("Error")
			return
		end

		for key,val in pairs(VMRT) do
			if not MAJOR_KEYS[key] then
				VMRT[key] = nil
			end
		end
		for key,val in pairs(loadDB) do
			if not MAJOR_KEYS[key] then
				VMRT[key] = val
			end
		end

		if not isCopy then
			VMRT.Profiles[ profileName ] = {}
		end

		ReloadUI()
	end

	self:CreateTilte()

	self.introText = ELib:Text(self,L.ProfilesIntro,11):Size(650,200):Point(15,-45):Top():Color()

	self.currentText = ELib:Text(self,L.ProfilesCurrent,11):Size(650,200):Point(15,-90):Top():Color()
	self.currentName = ELib:Text(self,GetCurrentProfileName(),11):Size(650,200):Point(210,-90):Top()

	self.choseText = ELib:Text(self,L.ProfilesChooseDesc,11):Size(650,200):Point(15,-130):Top():Color()

	self.choseNewText = ELib:Text(self,L.ProfilesNew,11):Size(650,200):Point(15,-158):Top()
	self.choseNew = ELib:Edit(self):Size(170,20):Point(10,-170)

	self.choseNewButton = ELib:Button(self,L.ProfilesAdd):Size(70,20):Point("LEFT",self.choseNew,"RIGHT",0,0):OnClick(function (self)
		local text = module.options.choseNew:GetText()
		module.options.choseNew:SetText("")
		if text == "" or text == "default" or VMRT.Profiles[text] then
			return
		end
		VMRT.Profiles[text] = {}

		StaticPopupDialogs["EXRT_PROFILES_ACTIVATE"] = {
			text = L.ProfilesActivateAlert,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				SaveCurrentProfiletoDB()
				VMRT.Profile = text
				VMRT.ProfileKeys[ ExRT.SDB.charKey ] = text
				LoadProfileFromDB(text)
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_PROFILES_ACTIVATE")
	end)

	self.choseSelectText = ELib:Text(self,L.ProfilesSelect,11):Size(605,200):Point(335,-158):Top()
	self.choseSelectDropDown = ELib:DropDown(self,220,10):Point(330,-170):Size(235):SetText(GetCurrentProfileName())

	local function RefreshSelectedProfileText()
		if module.options.choseSelectDropDown and module.options.choseSelectDropDown.SetText then
			module.options.choseSelectDropDown:SetText(GetCurrentProfileName() or "")
		end
		if module.options.currentName and module.options.currentName.SetText then
			module.options.currentName:SetText(GetCurrentProfileName() or "")
		end
	end
	self:HookScript("OnShow", function()
		RefreshSelectedProfileText()
	end)

	local function SelectProfile(_,name)
		ELib:DropDownClose()
		if name == VMRT.Profile then
			return
		end
		SaveCurrentProfiletoDB()
		VMRT.Profile = name
		VMRT.ProfileKeys[ ExRT.SDB.charKey ] = name
		LoadProfileFromDB(name)
	end
	function self.choseSelectDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(SelectProfile)
	end

	local function CopyProfile(_,name)
		ELib:DropDownClose()
		LoadProfileFromDB(name,true)
	end
	self.copyText = ELib:Text(self,L.ProfilesCopy,11):Size(605,200):Point(15,-208):Top()
	self.copyDropDown = ELib:DropDown(self,220,10):Point(10,-220):Size(235)
	function self.copyDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(CopyProfile)
		for i=1,#self.List do
			if self.List[i].arg1 == VMRT.Profile then
				for j=i,#self.List do
					self.List[j] = self.List[j+1]
				end
				break
			end
		end
	end

	local function DeleteProfile(_,name)
		ELib:DropDownClose()
		StaticPopupDialogs["EXRT_PROFILES_REMOVE"] = {
			text = L.ProfilesDeleteAlert,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				VMRT.Profiles[name] = nil
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_PROFILES_REMOVE")
	end
	self.deleteText = ELib:Text(self,L.ProfilesDelete,11):Size(605,200):Point(15,-258):Top()
	self.deleteDropDown = ELib:DropDown(self,220,10):Point(10,-270):Size(235)
	function self.deleteDropDown:ToggleUpadte()
		self.List = GetCurrentProfilesList(DeleteProfile)
		for i=1,#self.List do
			if self.List[i].arg1 == VMRT.Profile then
				for j=i,#self.List do
					self.List[j] = self.List[j+1]
				end
				break
			end
		end
		for i=1,#self.List do
			if self.List[i].arg1 == "default" then
				for j=i,#self.List do
					self.List[j] = self.List[j+1]
				end
				break
			end
		end
	end

	module.importWindow, module.exportWindow = ExRT.F.CreateImportExportWindows()

	function module.importWindow:ImportFunc(str)
		local headerLen = str:sub(1,4) == "EXRT" and 6 or 5

		local header = str:sub(1,headerLen)
		if (header:sub(1,headerLen-1) ~= "EXRTP" and header:sub(1,headerLen-1) ~= "MRTP") or (header:sub(headerLen,headerLen) ~= "0" and header:sub(headerLen,headerLen) ~= "1") then
			StaticPopupDialogs["EXRT_PROFILES_IMPORT"] = {
				text = "|cffff0000"..ERROR_CAPS.."|r "..L.ProfilesFail3,
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("EXRT_PROFILES_IMPORT")
			return
		end

		module:TextToProfile(str:sub(headerLen+1),header:sub(headerLen,headerLen)=="0")
	end

	self.exportButton = ELib:Button(self,L.ProfilesExport):Size(235,25):Point(10,-320):Tooltip(format(L.ProfilesExportTooltip,"|cffffff00"..L.sencounter..", "..L.LootHistory..", "..L.Attendance.."|r")):OnClick(function (self)
		module.exportWindow:NewPoint("CENTER",UIParent,0,0)
		module:ProfileToText(IsShiftKeyDown())
	end)

	self.importButton = ELib:Button(self,L.ProfilesImport):Size(235,25):Point("LEFT",self.exportButton,"RIGHT",85,0):OnClick(function (self)
		module.importWindow:NewPoint("CENTER",UIParent,0,0)
		module.importWindow:Show()
	end)

	self.selectReplaceWindow = ELib:Popup(L.ProfilesSelectModules):Size(300,350):Point("CENTER",UIParent,"CENTER",0,0)
	self.selectReplaceWindow.clist = ELib:ScrollCheckList(self.selectReplaceWindow):Point("TOP",0,-20):Size(290,302)
	function self.selectReplaceWindow.clist:UpdateAdditional()
		for i=1,#self.List do
			local line = self.List[i]
			if line.index then
				local key = self.L[line.index]
				line:SetText(type(module.db.EXPORT_KEYS[key]) == "string" and module.db.EXPORT_KEYS[key] or type(module.db.EXPORT_FULL_KEYS[key]) == "string" and module.db.EXPORT_FULL_KEYS[key] or key)
			end
		end
	end
	self.selectReplaceWindow.rewriteButton = ELib:Button(self.selectReplaceWindow,L.ProfilesRewrite):Point("BOTTOMLEFT",6,5):Size(140,20):OnClick(function(self)
		local keyToIndex = {}
		local clist = self:GetParent().clist
		for i=1,#clist.L do
			if clist.C[i] then
				keyToIndex[ clist.L[i] ] = true
			end
		end
		for k,v in pairs(self:GetParent().data) do
			if keyToIndex[k] then
				VMRT[k] = v
			end
		end
		ReloadUI()
	end)
	self.selectReplaceWindow.newButton = ELib:Button(self.selectReplaceWindow,L.ProfilesSaveAsNew):Point("BOTTOMRIGHT",-6,5):Size(140,20):OnClick(function(self)
		local keyToIndex = {}
		local clist = self:GetParent().clist
		for i=1,#clist.L do
			if clist.C[i] then
				keyToIndex[ clist.L[i] ] = true
			end
		end
		local new = {}
		for k,v in pairs(self:GetParent().data) do
			if keyToIndex[k] then
				new[k] = v
			end
		end
		local name = self:GetParent().name
		while VMRT.Profiles[name] do
			name = name .. "*"
		end
		print(L.ProfilesAddedText.." |cff00ff00"..name)
		VMRT.Profiles[name] = new
		self:GetParent():Hide()
	end)
	self.selectReplaceWindow:SetScript("OnHide",function(self)
		self.data = nil
		self.name = nil
	end)

	function module:SelectedReplace(dataTable,profileName)
		local l,c = {},{}
		for k,v in pairs(dataTable) do
			l[#l+1] = k
			c[#c+1] = true
		end
		sort(l,function(a,b)
			local a1 = type(module.db.EXPORT_KEYS[a]) == "string" and module.db.EXPORT_KEYS[a] or type(module.db.EXPORT_FULL_KEYS[a]) == "string" and module.db.EXPORT_FULL_KEYS[a] or a
			local b1 = type(module.db.EXPORT_KEYS[b]) == "string" and module.db.EXPORT_KEYS[b] or type(module.db.EXPORT_FULL_KEYS[b]) == "string" and module.db.EXPORT_FULL_KEYS[b] or b
			return a1 < b1
		end)

		module.options.selectReplaceWindow.data = dataTable
		module.options.selectReplaceWindow.name = profileName
		module.options.selectReplaceWindow.clist.L = l
		module.options.selectReplaceWindow.clist.C = c
		module.options.selectReplaceWindow:Show()
	end
end

function module.main:ADDON_LOADED()
	if not VMRT then
		return
	end
	VMRT.ProfileKeys = VMRT.ProfileKeys or {}
	VMRT.Profiles = VMRT.Profiles or {}
	VMRT.Profile = VMRT.Profile or "default"

	VMRT.ProfileKeys[ ExRT.SDB.charKey ] = VMRT.Profile
end


module.db.EXPORT_KEYS = {
	["BattleRes"] = L.BattleRes,
	["BossWatcher"] = L.BossWatcher,
	["ExCD2"] = L.cd2,
	["InspectViewer"] = L.InspectViewer,
	["Interrupts"] = true,
	["InviteTool"] = L.invite,
	["Logging"] = L.Logging,
	["LootLink"] = L.LootLink,
	["Marks"] = L.marks,
	["MarksBar"] = L.marksbar,
	["MarksSimple"] = true,
	["Note"] = L.message,
	["RaidCheck"] = L.raidcheck,
	["RaidGroups"] = L.RaidGroups,
	["Timers"] = L.timers,
	["VisNote"] = L.VisualNote,
	["WhoPulled"] = L.WhoPulled,
}
module.db.EXPORT_FULL_KEYS = {
	["Encounter"] = L.sencounter,
	["Attendance"] = L.Attendance,
	["LootHistory"] = L.LootHistory,
	["Reminder"] = true,
	["Reminder2"] = true,
}

function module:ProfileToText(isFullExport)
	local new = {}
	for key,val in pairs(VMRT) do
		if module.db.EXPORT_KEYS[key] or (isFullExport and module.db.EXPORT_FULL_KEYS[key]) then
			new[key] = val
		end
	end
	local strlist = ExRT.F.TableToText(new)
	strlist[1] = (VMRT.Profile or "default"):sub(1,200):gsub(",","")..","..(ExRT.isClassic and "1" or "0")..","..strlist[1]
	local str = table.concat(strlist)

	local compressed
	if #str < 1000000 then
		compressed = LibDeflate:CompressDeflate(str,{level = 5})
	end
	local encoded = "MRTP"..(compressed and "1" or "0")..LibDeflate:EncodeForPrint(compressed or str)

	ExRT.F.dprint("Str len:",#str,"Encoded len:",#encoded)

	if ExRT.isDev then
		module.db.exportTable = new
	end
	if not module.exportWindow then
		module.options:Load()
	end
	module.exportWindow.Edit:SetText(encoded)
	module.exportWindow:Show()
end

function module:TextToProfile(str,uncompressed)
	local decoded = LibDeflate:DecodeForPrint(str)
	local decompressed
	if uncompressed then
		decompressed = decoded
	else
		decompressed = LibDeflate:DecompressDeflate(decoded)
	end
	decoded = nil

	if not decompressed then
		print('error: import string is broken')
		return
	end

	local profileName,clientVersion,tableData = strsplit(",",decompressed,3)
	decompressed = nil

	if clientVersion == "1" then
		local successful, res = pcall(ExRT.F.TextToTable,tableData)
		if ExRT.isDev then
			module.db.lastImportDB = res
			if module.db.exportTable and type(res)=="table" then
				module.db.diffTable = {}
				print("Compare table",ExRT.F.table_compare(res,module.db.exportTable,module.db.diffTable))
			end
		end
		if successful and res then
			ExRT.F.ImportChoicePopup(
				L.ProfilesNewProfile.." \""..profileName.."\"",
				{
					{text = L.ProfilesRewrite, func = function()
						for k,v in pairs(res) do
							VMRT[k] = v
						end
						ReloadUI()
					end},
					{text = L.ProfilesSaveAsNew, func = function()
						local name = profileName
						while VMRT.Profiles[name] do
							name = name .. "*"
						end
						print(L.ProfilesAddedText.." |cff00ff00"..name)
						VMRT.Profiles[name] = res
					end},
					{text = L.ProfilesSelectModules, func = function()
						if not module.SelectedReplace then
							module.options:Load()
						end
						module:SelectedReplace(res,profileName)
					end},
					{text = CANCEL, func = function()
						res = nil
					end},
				}
			)
			return
		else
			StaticPopupDialogs["EXRT_PROFILES_IMPORT"] = {
				text = L.ProfilesFail1..(res and "\nError code: "..res or ""),
				button1 = OKAY,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
		end
	else
		StaticPopupDialogs["EXRT_PROFILES_IMPORT"] = {
			text = L.ProfilesFail2,
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
	end

	StaticPopup_Show("EXRT_PROFILES_IMPORT")
end

do
	local function mrtToUpmCharKey(mrtKey)
		if type(mrtKey) ~= "string" then return mrtKey end
		local sep = mrtKey:find("-", 1, true)
		if not sep then return mrtKey end
		return mrtKey:sub(1, sep-1) .. " - " .. mrtKey:sub(sep+1)
	end

	local function buildBridgeSV()
		local out = {profiles = {}, profileKeys = {}}
		out.profiles["default"] = {}
		if type(VMRT) == "table" then
			if type(VMRT.Profiles) == "table" then
				for name in pairs(VMRT.Profiles) do
					if type(name) == "string" then
						out.profiles[name] = {}
					end
				end
			end
			if type(VMRT.Profile) == "string" then
				out.profiles[VMRT.Profile] = out.profiles[VMRT.Profile] or {}
			end
			if type(VMRT.ProfileKeys) == "table" then
				for mrtKey, profileName in pairs(VMRT.ProfileKeys) do
					if type(mrtKey) == "string" and type(profileName) == "string" then
						out.profileKeys[mrtToUpmCharKey(mrtKey)] = profileName
					end
				end
			end
		end
		if type(ExRT) == "table" and type(ExRT.SDB) == "table" and type(ExRT.SDB.charKey) == "string" then
			local upmKey = mrtToUpmCharKey(ExRT.SDB.charKey)
			if type(VMRT) == "table" and type(VMRT.Profile) == "string" then
				out.profileKeys[upmKey] = VMRT.Profile
			end
		end
		return out
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()

		if type(LibStub) ~= "table" and type(LibStub) ~= "function" then return end
		local AceDB
		local ok, lib = pcall(LibStub, "AceDB-3.0", true)
		if ok then AceDB = lib end
		if type(AceDB) ~= "table" or type(AceDB.New) ~= "function" then return end

		if type(VMRT) ~= "table" then return end

		_G.VMRT_UPMBridge = buildBridgeSV()

		local bridgeDB
		local ok2, db = pcall(AceDB.New, AceDB, "VMRT_UPMBridge")
		if ok2 then bridgeDB = db end
		if type(bridgeDB) ~= "table" or type(bridgeDB.RegisterCallback) ~= "function" then return end

		local mrtCharKey = type(ExRT) == "table" and type(ExRT.SDB) == "table" and ExRT.SDB.charKey or nil
		local upmCharKey = type(mrtCharKey) == "string" and mrtToUpmCharKey(mrtCharKey) or nil

		bridgeDB.RegisterCallback(bridgeDB, "OnProfileChanged", function(_, _, newProfileKey)
			if type(newProfileKey) ~= "string" then return end
			if type(VMRT) ~= "table" then return end
			if type(mrtCharKey) ~= "string" then return end
			if VMRT.Profile == newProfileKey then return end

			VMRT.ProfileKeys = type(VMRT.ProfileKeys) == "table" and VMRT.ProfileKeys or {}
			VMRT.Profiles = type(VMRT.Profiles) == "table" and VMRT.Profiles or {}
			VMRT.ProfileKeys[mrtCharKey] = newProfileKey
			if newProfileKey ~= "default" then
				VMRT.Profiles[newProfileKey] = VMRT.Profiles[newProfileKey] or {}
			end

			if type(ReloadUI) == "function" then
				ReloadUI()
			end
		end)

		bridgeDB.RegisterCallback(bridgeDB, "OnNewProfile", function(_, _, newProfileKey)
			if type(newProfileKey) ~= "string" or newProfileKey == "default" then return end
			if type(VMRT) ~= "table" then return end
			VMRT.Profiles = type(VMRT.Profiles) == "table" and VMRT.Profiles or {}
			VMRT.Profiles[newProfileKey] = VMRT.Profiles[newProfileKey] or {}
		end)

		bridgeDB.RegisterCallback(bridgeDB, "OnProfileDeleted", function(_, _, deletedProfileKey)
			if type(deletedProfileKey) ~= "string" or deletedProfileKey == "default" then return end
			if type(VMRT) ~= "table" then return end
			if type(VMRT.Profiles) == "table" then
				VMRT.Profiles[deletedProfileKey] = nil
			end
			if type(VMRT.ProfileKeys) == "table" then
				for k, v in pairs(VMRT.ProfileKeys) do
					if v == deletedProfileKey then
						VMRT.ProfileKeys[k] = "default"
					end
				end
			end
		end)

		bridgeDB.RegisterCallback(bridgeDB, "OnProfileCopied", function(_, _, sourceProfileKey)
			if type(sourceProfileKey) ~= "string" then return end
			if type(VMRT) ~= "table" or type(VMRT.Profiles) ~= "table" then return end
			if type(upmCharKey) ~= "string" then return end
			local destProfileKey = bridgeDB.sv and bridgeDB.sv.profileKeys and bridgeDB.sv.profileKeys[upmCharKey]
			if type(destProfileKey) ~= "string" or destProfileKey == sourceProfileKey then return end
			local source = VMRT.Profiles[sourceProfileKey]
			if type(source) ~= "table" then return end
			local clone = {}
			for k, v in pairs(source) do clone[k] = v end
			VMRT.Profiles[destProfileKey] = clone
		end)

		bridgeDB.RegisterCallback(bridgeDB, "OnProfileReset", function()
			if type(VMRT) ~= "table" or type(mrtCharKey) ~= "string" then return end
			VMRT.ProfileKeys = type(VMRT.ProfileKeys) == "table" and VMRT.ProfileKeys or {}
			VMRT.ProfileKeys[mrtCharKey] = "default"
			if type(ReloadUI) == "function" then
				ReloadUI()
			end
		end)
	end)
end
