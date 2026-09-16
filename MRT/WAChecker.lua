local GlobalAddonName, ExRT = ...

local module = ExRT:New("WAChecker",ExRT.L.WAChecker)
local ELib,L = ExRT.lib,ExRT.L

local LibDeflate = LibStub:GetLibrary("LibDeflate")

local AceCommCached
local function getAceComm()
	if AceCommCached then return AceCommCached end
	if type(LibStub) ~= "table" or type(LibStub.GetLibrary) ~= "function" then return nil end
	local ok, comm = pcall(LibStub.GetLibrary, LibStub, "AceComm-3.0", true)
	if ok and type(comm) == "table" and type(comm.SendCommMessage) == "function" then
		AceCommCached = comm
		return comm
	end
	return nil
end

local IsEncounterInProgress = C_InstanceEncounter and C_InstanceEncounter.IsEncounterInProgress or IsEncounterInProgress

module.db.responces = {}
module.db.responces2 = {}
module.db.lastReq = {}
module.db.lastReq2 = {}
module.db.lastCheck = {}
module.db.lastCheckName = {}
local sync_db = {}

local CHUNK_SIZE = 180
local CHUNK_BUDGET = 10

local nonTxFields = {
	authorMode = true,
	skipWagoUpdate = true,
	ignoreWagoUpdate = true,
	preferToUpdate = true,
	information = {
		saved = true,
	},
}

local function stripNonTx(datum, fieldMap)
	if type(datum) ~= "table" then return end
	for k, v in pairs(fieldMap) do
		if type(v) == "table" and type(datum[k]) == "table" then
			stripNonTx(datum[k], v)
		elseif v == true then
			datum[k] = nil
		end
	end
end

local sharedChunkBufs = {}
local function chunkBufsForSender(kind, sender)
	if not sharedChunkBufs[kind] then sharedChunkBufs[kind] = {} end
	if not sharedChunkBufs[kind][sender] then sharedChunkBufs[kind][sender] = {} end
	return sharedChunkBufs[kind][sender]
end
local function chunkBufFor(kind, sender, streamID, total)
	local senderBufs = chunkBufsForSender(kind, sender)
	local buf = senderBufs[streamID]
	if not buf then
		buf = {chunks = {}, total = total, count = 0, ts = GetTime()}
		senderBufs[streamID] = buf
	end
	return buf
end
local function chunkBufComplete(buf, idx, chunk)
	if not buf or not chunk then return false end
	if buf.chunks[idx] == nil then
		buf.chunks[idx] = chunk
		buf.count = buf.count + 1
	end
	return buf.count >= buf.total
end
local function chunkBufAssemble(buf)
	local pieces = {}
	for i=1,buf.total do pieces[i] = buf.chunks[i] or "" end
	return table.concat(pieces)
end
local function chunkBufDrop(kind, sender, streamID)
	if sharedChunkBufs[kind] and sharedChunkBufs[kind][sender] then
		sharedChunkBufs[kind][sender][streamID] = nil
	end
end
local function chunkBufGC(kind, maxAge)
	local now = GetTime()
	local kindBufs = sharedChunkBufs[kind]
	if not kindBufs then return end
	for sender,senderBufs in pairs(kindBufs) do
		for streamID,buf in pairs(senderBufs) do
			if not buf.ts or (now - buf.ts) > maxAge then
				senderBufs[streamID] = nil
			end
		end
	end
end

function module.options:Load()
	self:CreateTilte()

	local UpdatePage, UpdatePageView

	local Filter

	local errorNoWA = ELib:Text(self,L.WACheckerWANotFound):Point("TOP",0,-30)
	errorNoWA:Hide()

	local PAGE_HEIGHT,PAGE_WIDTH = 520,680
	local LINE_HEIGHT,LINE_NAME_WIDTH = 16,160
	local VERTICALNAME_WIDTH = 20
	local VERTICALNAME_COUNT = 24

	local mainScroll = ELib:ScrollFrame(self):Size(PAGE_WIDTH,PAGE_HEIGHT):Point("TOP",0,-80):Height(700)
	ELib:Border(mainScroll,0)

	ELib:DecorationLine(self):Point("BOTTOM",mainScroll,"TOP",0,0):Point("LEFT",self):Point("RIGHT",self):Size(0,1)
	ELib:DecorationLine(self):Point("TOP",mainScroll,"BOTTOM",0,0):Point("LEFT",self):Point("RIGHT",self):Size(0,1)

	local prevTopLine = 0
	local prevPlayerCol = 0

	mainScroll.ScrollBar:ClickRange(LINE_HEIGHT)
	mainScroll.ScrollBar.slider:SetScript("OnValueChanged", function (self,value)
		local parent = self:GetParent():GetParent()
		parent:SetVerticalScroll(value % LINE_HEIGHT)
		self:UpdateButtons()
		local currTopLine = floor(value / LINE_HEIGHT)
		if currTopLine ~= prevTopLine then
			prevTopLine = currTopLine
			UpdatePageView()
		end
	end)

	local raidSlider = ELib:Slider(self,""):Point("TOPLEFT",mainScroll,"BOTTOMLEFT",LINE_NAME_WIDTH + 15,-3):Range(0,25):Size(VERTICALNAME_WIDTH*VERTICALNAME_COUNT):SetTo(0):OnChange(function(self,value)
		local currPlayerCol = floor(value or 0)
		if currPlayerCol < 0 then currPlayerCol = 0 end
		if currPlayerCol ~= prevPlayerCol then
			prevPlayerCol = currPlayerCol
			UpdatePageView()
		end
	end)
	raidSlider:EnableMouseWheel(true)
	raidSlider:SetScript("OnMouseWheel", function(self, delta)
		local minVal,maxVal = self:GetMinMaxValues()
		local v = (tonumber(self:GetValue()) or 0) - delta
		if v < minVal then v = minVal end
		if v > maxVal then v = maxVal end
		self:SetValue(v)
	end)
	raidSlider.Low:Hide()
	raidSlider.High:Hide()
	raidSlider.text:Hide()
	raidSlider.Low.Show = raidSlider.Low.Hide
	raidSlider.High.Show = raidSlider.High.Hide


	local icon5 = C_Texture.GetAtlasInfo("Islands-QuestBangDisable") or C_Texture.GetAtlasInfo("QuestTurnin")
	local function SetIcon(self,type)
		if self.texturechanged then
			self:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
			self.texturechanged = nil
		end
		if not type or type == 0 then
			self:SetAlpha(0)
		elseif type == 1 then
			self:SetAlpha(1)
			self:SetTexCoord(0.5,0.5625,0.5,0.625)
			self:SetVertexColor(.8,0,0,1)
		elseif type == 2 then
			self:SetAlpha(1)
			self:SetTexCoord(0.5625,0.625,0.5,0.625)
			self:SetVertexColor(0,.8,0,1)
		elseif type == 3 then
			self:SetAlpha(1)
			self:SetTexCoord(0.625,0.6875,0.5,0.625)
			self:SetVertexColor(.8,.8,0,1)
		elseif type == 4 then
			self:SetAlpha(1)
			self:SetTexCoord(0.875,0.9375,0.5,0.625)
			self:SetVertexColor(.8,.8,0,1)
		elseif type == 5 then
			if icon5 then
				self:SetTexture(icon5.file)
				self:SetTexCoord(icon5.leftTexCoord,icon5.rightTexCoord,icon5.topTexCoord,icon5.bottomTexCoord)
				self:SetVertexColor(1,1,1,1)
				self.texturechanged = true
			else
				self:SetTexCoord(0.6875,0.75,0.5,0.625)
				self:SetVertexColor(.8,.4,.8,1)
			end
			self:SetAlpha(1)
		elseif type == -1 or type < 0 then
			if module.SetIconExtra then
				module.SetIconExtra(self,type)
			end
		end
	end

	self.helpicons = {}
	for i=0,3 do
		local icon = self:CreateTexture(nil,"ARTWORK")
		icon:SetPoint("TOPLEFT",5,-10-i*12)
		icon:SetSize(14,14)
		icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
		SetIcon(icon,i+1)
		local t = ELib:Text(self,"",10):Point("LEFT",icon,"RIGHT",2,0):Size(0,16):Color(1,1,1)
		if i==0 then
			t:SetText(L.WACheckerMissingAura)
		elseif i==1 then
			t:SetText(L.WACheckerExistsAura)
		elseif i==2 then
			t:SetText(L.WACheckerPlayerHaveNotWA)
		elseif i==3 then
			SetIcon(icon,5)
			t:SetText(L.WACheckerDiff)
		end
		self.helpicons[i+1] = {icon,t}
	end

	self.filterEdit = ELib:Edit(self):Size(LINE_NAME_WIDTH,16):Point("BOTTOMLEFT",mainScroll,"TOPLEFT",-1,4):Tooltip(FILTER):OnChange(function(self,isUser)
		if not isUser then
			return
		end
		if self:GetText() == "" then
			Filter = nil
		else
			Filter = self:GetText():lower()
		end
		UpdatePage()
	end)

	local function addChildsToReq(req,data)
		if not data then
			return
		end
		if not data.childs then
			return
		end
		for k,v in pairs(data.childs) do
			req[k] = true
			addChildsToReq(req,v)
		end
	end

	local function LineName_OnClick(self,_,_,force)
		if IsShiftKeyDown() or force then
			local name, realm = UnitFullName("player")
			local fullName = name.."-"..realm
			local id = self:GetParent().db.data.id

			local link = "[WeakAuras: "..fullName.." - "..id.."]"


			module:SendWA(id)
		else
			local db = self:GetParent().db
			local data = db and db.data
			local id = data and data.id or "--"
			local req = {[id]=true}
			addChildsToReq(req,db)
			module:SendReq2(req)
		end
	end
	local function LineName_ShareButton_OnEnter(self)
		if module.ShareButtonHover then
			module.ShareButtonHover(self)
		end
		self.background:SetVertexColor(1,1,0,1)
	end
	local function LineName_ShareButton_OnLeave(self)
		if module.ShareButtonLeave then
			module.ShareButtonLeave(self)
		end
		self.background:SetVertexColor(1,1,1,0.7)
	end
	local function LineName_ShareButton_OnClick(self,...)
		if not module.ExportWA then
			LineName_OnClick(self:GetParent().name,nil,nil,true)
		else
			module.ShareButtonClick(self,...)
		end
	end

	local function LineName_Icon_OnEnter(self)
		if self.HOVER_TEXT then
			ELib.Tooltip.Show(self,nil,self.HOVER_TEXT)
		end
		if module.IconHoverFunctions then
			for i=1,#module.IconHoverFunctions do
				module.IconHoverFunctions[i](self,true)
			end
		end
	end
	local function LineName_Icon_OnLeave(self)
		if self.HOVER_TEXT then
			ELib.Tooltip.Hide()
		end
		if module.IconHoverFunctions then
			for i=1,#module.IconHoverFunctions do
				module.IconHoverFunctions[i](self,false)
			end
		end
	end

	local lines = {}
	self.lines = lines
	for i=1,floor(PAGE_HEIGHT / LINE_HEIGHT) + 2 do
		local line = CreateFrame("Frame",nil,mainScroll.C)
		lines[i] = line
		line:SetPoint("TOPLEFT",0,-(i-1)*LINE_HEIGHT)
		line:SetPoint("TOPRIGHT",0,-(i-1)*LINE_HEIGHT)
		line:SetSize(0,LINE_HEIGHT)

		line.name = ELib:Text(line,"",10):Point("LEFT",2,0):Size(LINE_NAME_WIDTH-LINE_HEIGHT/2,LINE_HEIGHT):Color(1,1,1):Tooltip("ANCHOR_LEFT",true)
		line.name.TooltipFrame:SetScript("OnClick",LineName_OnClick)

		line.share = CreateFrame("Button",nil,line)
		line.share:SetPoint("LEFT",line.name,"RIGHT",0,0)
		line.share:SetSize(LINE_HEIGHT,LINE_HEIGHT)
		line.share:SetFrameLevel((line:GetFrameLevel() or 0)+5)
		line.share:SetHitRectInsets(-2,-2,-2,-2)
		line.share:SetScript("OnEnter",LineName_ShareButton_OnEnter)
		line.share:SetScript("OnLeave",LineName_ShareButton_OnLeave)
		line.share:SetScript("OnClick",LineName_ShareButton_OnClick)
		line.share:RegisterForClicks("LeftButtonDown","RightButtonDown")

		line.share.background = line.share:CreateTexture(nil,"ARTWORK")
		line.share.background:SetPoint("CENTER")
		line.share.background:SetSize(LINE_HEIGHT,LINE_HEIGHT)
		line.share.background:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
		line.share.background:SetTexCoord(0.125+(0.1875 - 0.125)*4,0.1875+(0.1875 - 0.125)*4,0.5,0.625)
		line.share.background:SetVertexColor(1,1,1,0.7)

		line.icons = {}
		local iconSize = min(VERTICALNAME_WIDTH,LINE_HEIGHT)
		for j=1,VERTICALNAME_COUNT do
			local icon = line:CreateTexture(nil,"ARTWORK")
			line.icons[j] = icon
			icon:SetPoint("CENTER",line,"LEFT",LINE_NAME_WIDTH + 15 + VERTICALNAME_WIDTH*(j-1) + VERTICALNAME_WIDTH / 2,0)
			icon:SetSize(iconSize,iconSize)
			icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
			SetIcon(icon,(i+j)%4)

			icon.hoverFrame = CreateFrame("Frame",nil,line)
			icon.hoverFrame:Hide()
			icon.hoverFrame:SetAllPoints(icon)
			icon.hoverFrame:SetScript("OnEnter",LineName_Icon_OnEnter)
			icon.hoverFrame:SetScript("OnLeave",LineName_Icon_OnLeave)
		end

		line.t=line:CreateTexture(nil,"BACKGROUND")
		line.t:SetAllPoints()
		line.t:SetColorTexture(1,1,1,.05)
	end

	local function RaidNames_OnEnter(self)
		local t = (self.t and self.t.__rawText) or (self.t and self.t:GetText()) or ""
		if t ~= "" then
			ELib.Tooltip.Show(self,"ANCHOR_LEFT",t)
		end
	end

	local raidNames = CreateFrame("Frame",nil,self)
	for i=1,VERTICALNAME_COUNT do
		raidNames[i] = ELib:Text(raidNames,"RaidName"..i,10):Point("BOTTOMLEFT",mainScroll,"TOPLEFT",LINE_NAME_WIDTH + 15 + VERTICALNAME_WIDTH*(i-1),0):Color(1,1,1)

		local f = CreateFrame("Frame",nil,self)
		f:SetPoint("BOTTOMLEFT",mainScroll,"TOPLEFT",LINE_NAME_WIDTH + 15 + VERTICALNAME_WIDTH*(i-1),0)
		f:SetSize(VERTICALNAME_WIDTH,80)
		f:SetScript("OnEnter",RaidNames_OnEnter)
		f:SetScript("OnLeave",ELib.Tooltip.Hide)
		f.t = raidNames[i]

		local t=mainScroll:CreateTexture(nil,"BACKGROUND")
		raidNames[i].t = t
		t:SetPoint("TOPLEFT",LINE_NAME_WIDTH + 15 + VERTICALNAME_WIDTH*(i-1),0)
		t:SetSize(VERTICALNAME_WIDTH,PAGE_HEIGHT)
		if i%2==1 then
			t:SetColorTexture(.5,.5,1,.05)
			t.Vis = true
		end
	end
	local glyphAtlas = MRT and MRT.DiagonalGlyphAtlas
	local function applyDiagonalText(fs, text)
		text = text or ""
		if not fs.__diagRenderer and glyphAtlas and glyphAtlas.CreateRenderer then
			local r = glyphAtlas:CreateRenderer(fs:GetParent())
			r:SetGlyphSize(20)
			r:SetPoint("BOTTOMLEFT", fs, "BOTTOMLEFT", 0, 0)
			fs.__diagRenderer = r
		end
		if fs.__diagRenderer then
			fs.__diagRenderer:SetText(text)
		end
	end
	for i = 1, VERTICALNAME_COUNT do
		local fs = raidNames[i]
		if fs and not fs.__diagonalHooked then
			fs.__diagonalHooked = true
			local origSetText = fs.SetText
			fs.SetText = function(self, t)
				self.__rawText = t or ""
				origSetText(self, "")
				applyDiagonalText(self, t or "")
			end
			local origSetTextColor = fs.SetTextColor
			fs.SetTextColor = function(self, r, g, b, a)
				origSetTextColor(self, r, g, b, a)
				if self.__diagRenderer then
					self.__diagRenderer:SetTextColor(r, g, b, a or 1)
				end
			end
			fs:SetAlpha(0)
			local current = fs:GetText() or ""
			fs.__rawText = current
			origSetText(fs, "")
			applyDiagonalText(fs, current)
		end
	end

	local highlight_y = mainScroll.C:CreateTexture(nil,"BACKGROUND",nil,2)
	highlight_y:SetColorTexture(1,1,1,.2)
	local highlight_x = mainScroll:CreateTexture(nil,"BACKGROUND",nil,2)
	highlight_x:SetColorTexture(1,1,1,.2)

	local highlight_onupdate_maxY = (floor(PAGE_HEIGHT / LINE_HEIGHT) + 2) * LINE_HEIGHT
	local highlight_onupdate_minX = LINE_NAME_WIDTH + 15
	local highlight_onupdate_maxX = highlight_onupdate_minX + #raidNames * VERTICALNAME_WIDTH
	mainScroll.C:SetScript("OnUpdate",function(self)
		local x,y = ExRT.F.GetCursorPos(mainScroll)
		if y < 0 or y > PAGE_HEIGHT then
			highlight_x:Hide()
			highlight_y:Hide()
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if y >= 0 and y <= highlight_onupdate_maxY then
			y = floor(y / LINE_HEIGHT)
			highlight_y:ClearAllPoints()
			highlight_y:SetAllPoints(lines[y+1])
			highlight_y:Show()
		else
			highlight_x:Hide()
			highlight_y:Hide()
			return
		end
		if x >= highlight_onupdate_minX and x <= highlight_onupdate_maxX then
			x = floor((x - highlight_onupdate_minX) / VERTICALNAME_WIDTH)
			highlight_x:ClearAllPoints()
			highlight_x:SetAllPoints(raidNames[x+1].t)
			highlight_x:Show()
		elseif x >= 0 and x <= (PAGE_WIDTH - 16) then
			highlight_x:Hide()
		else
			highlight_x:Hide()
			highlight_y:Hide()
		end
	end)

	local UpdateButton = ELib:Button(self,UPDATE):Point("TOPLEFT",mainScroll,"BOTTOMLEFT",-2,-5):Size(130,20):OnClick(function(self)
		module:SendReq2()
	end)

	function self:ReqProgress(progress,parts)
		if progress == parts then
			UpdateButton:Enable()
			UpdateButton:SetText(UPDATE)
		else
			UpdateButton:Disable()
			UpdateButton:SetText(UPDATE..format(" %d%%",progress/(parts or 1)*100))
		end
	end

	local function sortByName(a,b)
		if a and b and a.name and b.name then
			return a.name < b.name
		end
	end

	local resp_to_icon = {
		[0] = 1,
		[1] = 5,
		[2] = 2,
		[3] = 6,
	}

	local function checkChilds(data)
		if not data.childs then
			return
		end
		for k,v in pairs(data.childs) do
			checkChilds(v)
			if v.shouldDisplay then
				data.shouldDisplay = true
			end
		end
	end

	local function addChildsSorted(auras,childLevel)
		childLevel = (childLevel or -1) + 1
		local aurasSorted = {}
		for WA_name,data in pairs(auras) do
			if data.shouldDisplay then
				aurasSorted[#aurasSorted+1] = data
			end
		end
		sort(aurasSorted,sortByName)
		for i=#aurasSorted,1,-1 do
			local aura = aurasSorted[i]
			aura.childLevel = childLevel
			if aura.childs then
				local d = addChildsSorted(aura.childs,childLevel)
				for j=#d,1,-1 do
					tinsert(aurasSorted,i+1,d[j])
				end
			end
		end
		return aurasSorted
	end

	local function NameHover(self)
		local t = self.lastCheck
		local name = strsplit("-",self.lastCheckName)
		if UnitName(name) then
			local class = select(2,UnitClass(name))
			name = "|c"..ExRT.F.classColor(class)..name.."|r"
		end
		local n = time()
		return "Last check: "..date("%X",t).."\n"..(n-t).." "..SECONDS.." ago by "..name
	end

	function UpdatePageView()
		local namesList = self.namesList or {}
		local namesList2 = {}
		local raidNamesUsed = 0
		for i=1+prevPlayerCol,#namesList do
			raidNamesUsed = raidNamesUsed + 1
			if not raidNames[raidNamesUsed] then
				break
			end
			local name = ExRT.F.delUnitNameServer(namesList[i].name)
			raidNames[raidNamesUsed]:SetText(name)
			raidNames[raidNamesUsed]:SetTextColor(ExRT.F.classColorNum(namesList[i].class))
			namesList2[raidNamesUsed] = name
			if raidNames[raidNamesUsed].Vis then
				raidNames[raidNamesUsed]:SetAlpha(.05)
			end
		end
		for i=raidNamesUsed+1,#raidNames do
			raidNames[i]:SetText("")
			raidNames[i].t:SetAlpha(0)
		end

		local sortedTable = self.sortedTable or {}

		local lineNum = 1
		local backgroundLineStatus = (prevTopLine % 2) == 1

		local myWAVER = WeakAuras.versionString

		for i=prevTopLine+1,#sortedTable do
			local aura = sortedTable[i]
			local line = lines[lineNum]
			if not line then
				break
			end
			line:Show()
			line.name:SetText((aura.childLevel and aura.childLevel > 0 and ("  "):rep(aura.childLevel).."- " or "")..aura.name)
			line.db = aura
			line.t:SetShown(backgroundLineStatus)
			if i == 1 and aura.name == "VERSION" then
				line.share:Hide()
			else
				line.share:Show()
			end
			local lastCheck = module.db.lastCheck[ aura.name ]
			if lastCheck then
				line.name.lastCheck = lastCheck
				line.name.lastCheckName = module.db.lastCheckName[ aura.name ]
				line.name.extraTip = NameHover
			else
				line.name.extraTip = nil
			end
			for j=1,VERTICALNAME_COUNT do
				local pname = namesList2[j] or "-"

				local db
				for name,DB in pairs(module.db.responces2) do
					if name == pname or name:find("^"..pname) then
						db = DB
						break
					end
				end
				if not db then
					for name,DB in pairs(module.db.responces) do
						if name == pname or name:find("^"..pname) then
							db = DB
							break
						end
					end
				end

				local hoverText

				if not db then
					SetIcon(line.icons[j],0)
				elseif db.noWA then
					SetIcon(line.icons[j],3)
				elseif aura.name == "VERSION" then
					hoverText = db.wa_ver or "NO DATA"
					SetIcon(line.icons[j],myWAVER == db.wa_ver and 2 or (db.wa_ver and 1) or 3)
				elseif type(db[ aura.name ]) == 'number' then
					SetIcon(line.icons[j],resp_to_icon[ db[ aura.name ] or -1] or 0)
				elseif db[ aura.name ] then
					SetIcon(line.icons[j],2)
				elseif not lastCheck then
					SetIcon(line.icons[j],0)
				else
					SetIcon(line.icons[j],1)
				end

				if module.ShowHoverIcons then
					line.icons[j].hoverFrame.HOVER_TEXT = nil
					line.icons[j].hoverFrame.name = pname
					line.icons[j].hoverFrame:Show()
				elseif hoverText then
					line.icons[j].hoverFrame.HOVER_TEXT = hoverText
					line.icons[j].hoverFrame:Show()
				else
					line.icons[j].hoverFrame.HOVER_TEXT = nil
					line.icons[j].hoverFrame:Hide()
				end
			end
			backgroundLineStatus = not backgroundLineStatus
			lineNum = lineNum + 1
		end
		for i=lineNum,#lines do
			lines[i]:Hide()
		end
	end

	function UpdatePage()
		if not WeakAurasSaved then
			errorNoWA:Show()
			mainScroll:Hide()
			raidSlider:Hide()
			for i=1,#self.helpicons do
				self.helpicons[i][1]:SetAlpha(0)
				self.helpicons[i][2]:SetAlpha(0)
			end
			UpdateButton:Hide()
			raidNames:Hide()
			self.filterEdit:Hide()
			self.allIsHidden = true
			return
		end
		if self.allIsHidden then
			self.allIsHidden = false
			errorNoWA:Hide()
			mainScroll:Show()
			for i=1,#self.helpicons do
				self.helpicons[i][1]:SetAlpha(1)
				self.helpicons[i][2]:SetAlpha(1)
			end
			UpdateButton:Show()
			raidNames:Show()
		end

		do
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and WeakAurasSaved then
				module.db.responces2[selfName] = module.db.responces2[selfName] or {}
				module.db.responces2[selfName].noWA = nil
				if WeakAuras and WeakAuras.versionString then
					module.db.responces2[selfName].wa_ver = tostring(WeakAuras.versionString)
				end
			end
		end

		local auras = {}
		for WA_name,WA_data in pairs(WeakAurasSaved.displays) do
			local aura = {
				name = WA_name,
				data = WA_data,
				parent = WA_data.parent,
				shouldDisplay = not Filter or WA_name:lower():find(Filter),
			}
			auras[WA_name] = aura
		end
		local toremove = {}
		for WA_name,data in pairs(auras) do
			if data.parent then
				local parent = auras[data.parent]
				if parent then
					parent.childs = parent.childs or {}
					parent.childs[WA_name] = data
					toremove[WA_name] = true
				else
					print('no parent for',data.name,data.parent,auras[data.parent])
				end
			end
		end
		for WA_name in pairs(toremove) do
			auras[WA_name] = nil
		end
		for WA_name,data in pairs(auras) do
			checkChilds(data)
		end

		local sortedTable = addChildsSorted(auras)
		self.sortedTable = sortedTable

		tinsert(sortedTable,1,{name="VERSION"})

		mainScroll.ScrollBar:Range(0,max(0,#sortedTable * LINE_HEIGHT - 1 - PAGE_HEIGHT),nil,true)

		local namesList = {}
		self.namesList = namesList
		for _,name,_,class in ExRT.F.IterateRoster do
			namesList[#namesList + 1] = {
				name = name,
				class = class,
			}
		end
		sort(namesList,sortByName)

		if #namesList <= VERTICALNAME_COUNT then
			raidSlider:Hide()
			prevPlayerCol = 0
			raidSlider.__MRT_lastStep = nil
			raidSlider:SetValue(0)
		else
			raidSlider:Show()
			raidSlider:Range(0,#namesList - VERTICALNAME_COUNT)
			local currVal = tonumber(raidSlider:GetValue()) or 0
			local maxVal = #namesList - VERTICALNAME_COUNT
			if currVal > maxVal then
				raidSlider.__MRT_lastStep = nil
				raidSlider:SetValue(maxVal)
				prevPlayerCol = maxVal
			end
		end

		UpdatePageView()
	end
	self.UpdatePage = UpdatePage

	function self:OnShow()
		UpdatePage()
	end
end

local function WAChecker_PrefixOpt()
	return (ExRT.F.GetOwnPartyNum() or 1) + 1
end

function module:SendReq(ownList)
	local str = ""
	local c = 0
	if type(ownList) == "table" then
		for WA_name in pairs(ownList) do
			str = str..WA_name.."''"
			c = c + 1
		end
	else
		for WA_name,WA_data in pairs(WeakAurasSaved.displays) do
			str = str..WA_name.."''"
			c = c + 1
		end
	end
	str = str:gsub("''$","")

	if #str == 0 then
		return
	end

	local compressed = LibDeflate:CompressDeflate(str,{level = 7})
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	encoded = encoded .. "##F##"
	local parts = ceil(#encoded / 240)

	local pn = WAChecker_PrefixOpt()

	for i=1,parts do
		local msg = encoded:sub( (i-1)*240+1 , i*240 )
		if i == 1 then
			ExRT.F.SendExMsgExt({prefixNum=pn},"wac2", ExRT.F.CreateAddonMsg("G","H",msg))
		else
			ExRT.F.SendExMsgExt({prefixNum=pn},"wac2", ExRT.F.CreateAddonMsg("G",msg))
		end
	end
end

local SendRespSch = nil

function module:SendResp()
	SendRespSch = nil
	local pn = WAChecker_PrefixOpt()
	if not WeakAurasSaved then
		ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("R","NOWA"))
		return
	end
	ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("R","DATA",tostring(WeakAuras.versionString)))

	local isChanged = true
	local buffer,bufferStart = {},0
	local r,rNow = 0,0
	for i=1,#module.db.lastReq do
		if WeakAurasSaved.displays[ module.db.lastReq[i] ] then
			r = bit.bor(r,2^rNow)
		end
		rNow = rNow + 1
		isChanged = true
		if i % 32 == 0 then
			buffer[#buffer + 1] = r
			r = 0
			rNow = 0
			if #buffer == 19 then
				ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("R",bufferStart,unpack(buffer)))
				wipe(buffer)
				bufferStart = i
				isChanged = false
			end
		end
	end
	if isChanged then
		buffer[#buffer + 1] = r
		ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("R",bufferStart,unpack(buffer)))
	end
end


local LONG = 2^31
function module:hash(str)
	local h = 5381
	for i=1, #str do
		h = math.fmod(h*33 + str:byte(i),LONG)
	end
	return h
end


local fieldsToClear = {
        load = true,
        grow = true,
        xOffset = true,
        yOffset = true,
        width = true,
        height = true,
        zoom = true,
        scale = true,
        texture = true,
        barColor = true,
        barColor2 = true,
        enableGradient = true,
        backgroundColor = true,
        color = true,
        font = true,
        fontSize = true,
	alpha = true,
	align = true,
	anchorFrameType = true,
  	anchorPerUnit = true,
	anchorPoint = true,
	backdropColor = true,
	columnSpace = true,
	selfPoint = true,
	frameStrata = true,
	inverse = true,
	rotation = true,
	sort = true,
	space = true,
	rowSpace = true,
	selfPoint = true,
	keepAspectRatio = true,
	gridType = true,
	gridWidth = true,
	limit = true,
	useLimit = true,
     	subRegions = {},
        conditions = {},
        actions = {
            start = {
                glow_color = true,
                use_glow_color = true,
                glow_type = true,
                glow_lines = true,
                glow_length = true,
                glow_thickness = true,
                glow_frequency = true,
                sound = true,
                sound_channel = true,
		do_sound = true,
            },
        },
	config = true,

	preferToUpdate = true,
	source = true,
	tocversion = true,
	fsdate = true,
	sortHybridTable = true,
	controlledChildren = true,
	uid = true,

        authorMode = true,
        skipWagoUpdate = true,
        ignoreWagoUpdate = true,
        preferToUpdate = true,
        information = {
            saved = true,
        },
}

do
    local subregionKeep = {
	anchorXOffset = true,
	anchorYOffset = true,

	text_anchorPoint = true,
	text_anchorXOffset = true,
	text_anchorYOffset = true,
	text_automaticWidth = true,
        text_color = true,
	text_fixedWidth = true,
        text_font = true,
	text_fontSize = true,
	text_fontType = true,
	text_justify = true,
	text_selfPoint = true,
	text_shadowColor = true,
	text_shadowXOffset = true,
	text_shadowYOffset = true,
	text_visible = true,
	text_wordWrap = true,

	glow = true,
        glowBorder = true,
        glowColor = true,
	glowFrequency = true,
	glowLength = true,
        glowLines = true,
        glowScale = true,
        glowThickness = true,
        glowType = true,
	glowXOffset = true,
	glowYOffset = true,
        useGlowColor = true,

	border_color = true,
	border_edge = true,
	border_offset = true,
	border_size = true,
	border_visible = true,
    }

    local conditionKeep = {
        glow_color = true,
        use_glow_color = true,
        glow_type = true,
        glow_lines = true,
        glow_length = true,
        glow_thickness = true,
        glow_frequency = true,
        sound = true,
        sound_channel = true,
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
    }

    for i = 1, 10 do
        tinsert(fieldsToClear.subRegions, CopyTable(subregionKeep))
	local changes_template = {
		value = CopyTable(conditionKeep)
	}
	local changes = {}
	for j=1,10 do
		tinsert(changes,changes_template)
	end
        tinsert(fieldsToClear.conditions, {
		changes = changes
        })
    end
end

local function ClearFields(table,fields)
	for name,arg in pairs(fields) do
		if type(arg) == "table" then
			if type(table[name])=="table" then
				ClearFields(table[name],arg)
			end
		elseif arg then
			table[name] = nil
		end
	end
end
local function ClearBools(table)
	for name,arg in pairs(table) do
		if type(arg) == "table" then
			ClearBools(arg)
		elseif arg == false then
			table[name] = nil
		end
	end
end

function module:wa_clear(data)
	local data = ExRT.F.table_copy2(data)

	ClearFields(data, fieldsToClear)
	ClearBools(data)

	return data
end


function module:SendReq2(ownList)
	if self.locked then return end
	self.locked = true
	module.options:ReqProgress(0)

	local Comm = getAceComm()
	if not Comm then
		self.locked = false
		print("MRT: AceComm-3.0 not available; cannot run Update. Make sure WeakAuras is loaded.")
		return
	end

	sync_db.wac3_G_count = (sync_db.wac3_G_count or 0) + 1
	local selfC = sync_db.wac3_G_count
	local selfReqPairs = {}
	module.db.lastReq2[selfC] = selfReqPairs

	local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
	if selfName then
		selfReqPairs[selfName] = true
		module.db.responces2[selfName] = module.db.responces2[selfName] or {}
		module.db.responces2[selfName].noWA = nil
		if WeakAuras and WeakAuras.versionString then
			module.db.responces2[selfName].wa_ver = tostring(WeakAuras.versionString)
		end
		if WeakAurasSaved and WeakAurasSaved.displays then
			for WA_name in pairs(WeakAurasSaved.displays) do
				module.db.responces2[selfName][WA_name] = 2
			end
		end
		if module.options:IsVisible() and module.options.UpdatePage then
			module.options.UpdatePage()
		end
	end

	local distribution
	if IsInRaid() then
		distribution = "RAID"
	elseif IsInGroup() then
		distribution = "PARTY"
	end
	if not distribution then
		self.locked = false
		module.options:ReqProgress(1,1)
		return
	end

	ExRT.F:AddCoroutine(function()
		local str = ""
		local c = 0
		local selfResp = selfName and module.db.responces2[selfName]
		if type(ownList) == "table" then
			for WA_name in pairs(ownList) do
				local WA_data = WeakAurasSaved.displays[WA_name]
				if WA_data then
					local hashStr = tostring(module:hash(ExRT.F.table_to_string(module:wa_clear(WA_data))))
					str = str..WA_name.."''"..hashStr.."''"
					selfReqPairs[#selfReqPairs+1] = {WA_name, hashStr}
					if selfResp then selfResp[WA_name] = 2 end
					c = c + 1
				end
			end
		else
			local t_len = ExRT.F.table_len(WeakAurasSaved.displays)
			for WA_name,WA_data in pairs(WeakAurasSaved.displays) do
				local hashStr = tostring(module:hash(ExRT.F.table_to_string(module:wa_clear(WA_data))))
				str = str..WA_name.."''"..hashStr.."''"
				selfReqPairs[#selfReqPairs+1] = {WA_name, hashStr}
				if selfResp then selfResp[WA_name] = 2 end
				c = c + 1

				if c % 10 == 0 then
					module.options:ReqProgress(c,t_len*2)
					coroutine.yield()
				end
			end
		end
		str = str:gsub("''$","")

		C_Timer.After(300,function() if module.db.lastReq2[selfC] == selfReqPairs then module.db.lastReq2[selfC] = 0 end end)

		self.locked = false

		if #str == 0 then
			module.options:ReqProgress(1,1)
			if module.options.UpdatePage then module.options.UpdatePage() end
			return
		end

		local compressed = LibDeflate:CompressDeflate(str,{level = 9})
		local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
		local payload = tostring(selfC).."\t"..encoded

		Comm:SendCommMessage("MRTWAReq", payload, distribution, nil, "BULK", function(arg, doneBytes, allBytes)
			if doneBytes and allBytes and allBytes > 0 then
				module.options:ReqProgress(doneBytes, allBytes)
			end
		end, selfC)
	end)
end


function module:SendResp2(reqTable, reqID, requester)
	SendRespSch = nil

	local Comm = getAceComm()
	local pn = WAChecker_PrefixOpt()
	local newProto = reqID and requester
	local useAce = Comm and newProto and true or false

	if not WeakAurasSaved then
		if useAce then
			Comm:SendCommMessage("MRTWARespVer", tostring(reqID).."\tNOWA", "WHISPER", requester, "BULK")
		else
			ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("Y","NOWA"))
		end
		return
	end

	if useAce then
		Comm:SendCommMessage("MRTWARespVer", tostring(reqID).."\tDATA\t"..tostring(WeakAuras.versionString), "WHISPER", requester, "BULK")
	else
		ExRT.F.SendExMsgExt({prefixNum=pn},"wachk", ExRT.F.CreateAddonMsg("Y","DATA",tostring(WeakAuras.versionString)))
	end

	local reqTable = ExRT.F.table_copy2(reqTable)
	ExRT.F:AddCoroutine(function()
		local res = ""
		local c = 0
		for i=1,#reqTable do
			if IsEncounterInProgress() then return end
			local data = reqTable[i]
			local wa_name, wa_hash = data[1],data[2]
			c = c + 1

			local r = 0
			if WeakAurasSaved.displays[ wa_name ] then
				r = 1
				if wa_hash == tostring( module:hash(ExRT.F.table_to_string(module:wa_clear(WeakAurasSaved.displays[ wa_name ]))) or "") then
					r = 2
				end
			end
			res = res .. r

			if c % 10 == 0 then
				coroutine.yield()
			end
		end

		if #res == 0 then return end

		local compressed = LibDeflate:CompressDeflate(res,{level = 9})
		local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

		if useAce then
			Comm:SendCommMessage("MRTWAResp", tostring(reqID).."\t"..encoded, "WHISPER", requester, "BULK")
		elseif newProto then
			local opt = {maxPer5Sec = CHUNK_BUDGET, prefixNum = pn}
			local parts = ceil(#encoded / CHUNK_SIZE)
			for i=1,parts do
				local msg = encoded:sub( (i-1)*CHUNK_SIZE+1 , i*CHUNK_SIZE )
				ExRT.F.SendExMsgExt(opt,"wachk", ExRT.F.CreateAddonMsg("Y2",requester,reqID,i,parts,msg))
			end
		else
			local opt = {maxPer5Sec = CHUNK_BUDGET, prefixNum = pn}
			encoded = encoded .. "#F#"
			local parts = ceil(#encoded / CHUNK_SIZE)
			for i=1,parts do
				local msg = encoded:sub( (i-1)*CHUNK_SIZE+1 , i*CHUNK_SIZE )
				if i == 1 then
					ExRT.F.SendExMsgExt(opt,"wachk", ExRT.F.CreateAddonMsg("Y","H",msg))
				else
					ExRT.F.SendExMsgExt(opt,"wachk", ExRT.F.CreateAddonMsg("Y",msg))
				end
			end
		end
	end)
end

function module.main:ADDON_LOADED()
	module:RegisterAddonMessage()
	module:RegisterAceCommHandler()
end

function module:CheckAuraIsSame(aura,id)
	if not WeakAurasSaved.displays[ id ] then
		return false
	end
	local hash1 = module:hash(ExRT.F.table_to_string(module:wa_clear(aura)))
	local hash2 = module:hash(ExRT.F.table_to_string(module:wa_clear(WeakAurasSaved.displays[ id ])))
	if hash1 == hash2 then
		return true
	else
		return false
	end
end

local function processShareData(payload, id, playername)
	if not WeakAurasSaved then return end
	if type(payload) ~= "string" or #payload < 7 then return end
	if payload:sub(1,6) ~= "!WA:2!" then return end

	local deserialized
	do
		local str = payload:sub(7)
		local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
		if decoded then
			local decompressed = LibDeflate:DecompressDeflate(decoded)
			if decompressed then
				local LibSerialize = LibStub("LibSerialize")
				local ok, d = LibSerialize:Deserialize(decompressed)
				if ok and type(d) == "table" then
					deserialized = d
				end
			end
		end
	end

	if not id and deserialized and deserialized.d and deserialized.d.id then
		id = deserialized.d.id
	end

	if deserialized and deserialized.d and id and WeakAurasSaved.displays[ id ] then
		if module:CheckAuraIsSame(deserialized.d,id) then
			if not deserialized.c then
				return
			else
				local isPass = false
				for i=1,#deserialized.c do
					local child = deserialized.c[i]
					local cid = child and child.id
					if not child or not cid or not module:CheckAuraIsSame(child,cid) then
						isPass = true
						break
					end
				end
				if not isPass then
					return
				end
			end
		end
	end

	if not ExRT.isWotLKOnly and id and playername then
		local link = "|Hgarrmission:weakauras|h|cFF8800FF["..playername.." |r|cFF8800FF- "..id.."]|h|r"
		pcall(SetItemRef, "garrmission:weakauras", link)
	end

	if ExRT.isWotLKOnly and type(_G.WeakAuras) == "table" and type(_G.WeakAuras.Import) == "function" then
		if deserialized then
			xpcall(function() _G.WeakAuras.Import(deserialized) end, geterrorhandler())
		end
	else
		local Comm = LibStub:GetLibrary("AceComm-3.0")
		if Comm and Comm.callbacks then
			Comm.callbacks:Fire("WeakAuras", payload, "RAID", playername)
		end
	end
end

function module:RegisterAceCommHandler()
	if module._aceCommRegistered then return end
	local Comm = getAceComm()
	if not Comm or type(Comm.RegisterComm) ~= "function" then return end
	module._aceCommRegistered = true

	Comm:RegisterComm("MRTWAShare", function(prefix, message, distribution, sender)
		local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
		if selfName and Ambiguate(sender or "", "none") == selfName then return end
		processShareData(message, nil, sender)
	end)

	Comm:RegisterComm("MRTWAReq", function(prefix, message, distribution, sender)
		local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
		if selfName and Ambiguate(sender or "", "none") == selfName then return end
		if type(message) ~= "string" then return end
		local sep = message:find("\t", 1, true)
		if not sep then return end
		local reqID = tonumber(message:sub(1, sep-1))
		local encoded = message:sub(sep+1)
		if not reqID or #encoded == 0 then return end
		local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
		if not decoded then return end
		local decompressed = LibDeflate:DecompressDeflate(decoded)
		if not decompressed then return end

		local pairsList = {}
		local now_time = time()
		local pos = 1
		while true do
			local ns,ne = decompressed:find("''",pos,true)
			if not ns then break end
			local wa_name = decompressed:sub(pos,ns-1)
			local hs,he = decompressed:find("''",ne+1,true)
			if hs then hs = hs-1 end
			local wa_hash = decompressed:sub(ne+1,hs)
			pairsList[#pairsList + 1] = {wa_name,wa_hash}
			module.db.lastCheck[wa_name] = now_time
			module.db.lastCheckName[wa_name] = sender
			if not he then break end
			pos = he + 1
		end
		module:SendResp2(pairsList, reqID, sender)
	end)

	Comm:RegisterComm("MRTWARespVer", function(prefix, message, distribution, sender)
		local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
		if selfName and Ambiguate(sender or "", "none") == selfName then return end
		if type(message) ~= "string" then return end
		local p1, rest = message:match("^([^\t]*)\t(.+)$")
		if not p1 then return end
		local reqID = tonumber(p1)
		if not reqID then return end
		module.db.responces2[sender] = module.db.responces2[sender] or {}
		if rest == "NOWA" then
			module.db.responces2[sender].noWA = true
		else
			local kind, ver = rest:match("^([^\t]*)\t(.+)$")
			if kind == "DATA" and ver then
				module.db.responces2[sender].noWA = nil
				module.db.responces2[sender].wa_ver = ver
			end
		end
		if module.options:IsVisible() and module.options.UpdatePage then
			module.options.UpdatePage()
		end
	end)

	Comm:RegisterComm("MRTWAResp", function(prefix, message, distribution, sender)
		local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
		if selfName and Ambiguate(sender or "", "none") == selfName then return end
		if type(message) ~= "string" then return end
		local sep = message:find("\t", 1, true)
		if not sep then return end
		local reqID = tonumber(message:sub(1, sep-1))
		local encoded = message:sub(sep+1)
		if not reqID or #encoded == 0 then return end
		local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
		if not decoded then return end
		local decompressed = LibDeflate:DecompressDeflate(decoded)
		if not decompressed then return end

		local workingReq = module.db.lastReq2[reqID]
		if type(workingReq) ~= "table" then return end
		if #workingReq ~= #decompressed then return end
		if workingReq[sender] then return end
		workingReq[sender] = true
		module.db.responces2[sender] = module.db.responces2[sender] or {}
		for i=1,#decompressed do
			module.db.responces2[sender][workingReq[i][1]] = tonumber(decompressed:sub(i,i),10)
		end
		if module.options:IsVisible() and module.options.UpdatePage then
			module.options.UpdatePage()
		end
	end)
end

local pendingShareV2 = {}
local function tryFinalizeShareV2(sender, streamID)
	local senderEntry = pendingShareV2[sender]
	if not senderEntry then return end
	local entry = senderEntry[streamID]
	if not entry then return end

	local senderBufs = sharedChunkBufs.D2 and sharedChunkBufs.D2[sender]
	local buf = senderBufs and senderBufs[streamID]
	if not buf or not buf.total or buf.count < buf.total then return end

	local payload = chunkBufAssemble(buf)
	chunkBufDrop("D2", sender, streamID)
	senderEntry[streamID] = nil

	processShareData(payload, entry.id, entry.playername)
end

local lastSenderTime,lastSender = 0

function module:addonMessage(sender, prefix, prefix2, ...)
	if prefix == "wachk" then
		if prefix2 == "G" then
			local time = GetTime()
			if lastSender ~= sender and (time - lastSenderTime) < 1.5 then
				return
			end
			lastSender = sender
			lastSenderTime = time
			local str1, str2 = ...
			if str1 == "H" and str2 then
				wipe(module.db.lastReq)
				str1 = str2
			end
			if not str1 then
				return
			end

			while str1:find("''") do
				local wa_name,o = str1:match("^(.-)''(.*)$")

				module.db.lastReq[#module.db.lastReq + 1] = wa_name

				str1 = o
			end

			module.db.lastReq[#module.db.lastReq + 1] = str1

			if not SendRespSch then
				SendRespSch = C_Timer.NewTimer(1,module.SendResp)
			end
		elseif prefix2 == "R" then
			local str1, str2 = ...
			module.db.responces[ sender ] = module.db.responces[ sender ] or {}
			if str1 == "NOWA" then
				module.db.responces[ sender ].noWA = true
				return
			elseif str1 == "DATA" then
				local _, wa_ver = ...
				module.db.responces[ sender ].wa_ver = wa_ver

				if module.options:IsVisible() and module.options.UpdatePage then
					module.options.UpdatePage()
				end
				return
			end
			local start = tonumber(str1 or "?")
			if not start then
				return
			end
			module.db.responces[ sender ].noWA = nil
			for j=2,select("#", ...) do
				local res = tonumber(select(j, ...),nil)

				for i=1,32 do
					if not module.db.lastReq[i + start] then
						break
					elseif bit.band(res,2^(i-1)) > 0 then
						module.db.responces[ sender ][ module.db.lastReq[i + start] ] = true
					else
						module.db.responces[ sender ][ module.db.lastReq[i + start] ] = false
					end
				end

				start = start + 32
			end

			if module.options:IsVisible() and module.options.UpdatePage then
				module.options.UpdatePage()
			end
		elseif prefix2 == "Y" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local str1, str2 = ...
			module.db.responces2[ sender ] = module.db.responces2[ sender ] or {}
			if str1 == "NOWA" then
				module.db.responces2[ sender ].noWA = true
				return
			elseif str1 == "DATA" then
				local _, wa_ver = ...
				module.db.responces2[ sender ].wa_ver = wa_ver

				if module.options:IsVisible() and module.options.UpdatePage then
					module.options.UpdatePage()
				end
				return
			end
			if ... == "H" then
				if not module.db.syncStr2 then
					module.db.syncStr2 = {}
				end
				module.db.syncStr2[ sender ] = ""
			end
			local str = table.concat({select(... == "H" and 2 or 1,...)}, "\t")

			module.db.syncStr2[ sender ] = (module.db.syncStr2[ sender ] or "") .. str
			if module.db.syncStr2[ sender ]:find("#F#$") then
				local str = module.db.syncStr2[ sender ]:sub(1,-4)
				module.db.syncStr2[ sender ] = nil

				local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
				local decompressed = LibDeflate:DecompressDeflate(decoded)

				decompressed = decompressed

				local workingReq
				local maxC = sync_db.wac3_G_count or #module.db.lastReq2
				for j=maxC,1,-1 do
					local lastReq = module.db.lastReq2[j]
					if type(lastReq)=="table" and #lastReq == #decompressed and not lastReq[sender] and selfName and lastReq[selfName] then
						workingReq = lastReq
						break
					end
				end
				if not workingReq then
					for j=maxC,1,-1 do
						local lastReq = module.db.lastReq2[j]
						if type(lastReq)=="table" and #lastReq == #decompressed and not lastReq[sender] then
							workingReq = lastReq
							break
						end
					end
				end
				if workingReq then
					workingReq[sender] = true
					for i=1,#decompressed do
						module.db.responces2[ sender ][ workingReq[i][1] ] = tonumber( decompressed:sub(i,i),10 )
					end
				end
			end

			if module.options:IsVisible() and module.options.UpdatePage then
				module.options.UpdatePage()
			end
		elseif prefix2 == "Y2" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local target, arg2, arg3, arg4, chunk = ...
			if not target or not selfName or Ambiguate(target, "none") ~= selfName then
				return
			end
			local reqID = tonumber(arg2)
			local idx = tonumber(arg3)
			local total = tonumber(arg4)
			if not reqID or not idx or not total or not chunk then return end
			if total <= 0 or idx <= 0 or idx > total then return end

			module.db.responces2[ sender ] = module.db.responces2[ sender ] or {}

			local buf = chunkBufFor("Y2", sender, reqID, total)
			if not chunkBufComplete(buf, idx, chunk) then return end

			local fullEncoded = chunkBufAssemble(buf)
			chunkBufDrop("Y2", sender, reqID)

			local decoded = LibDeflate:DecodeForWoWAddonChannel(fullEncoded)
			if not decoded then return end
			local decompressed = LibDeflate:DecompressDeflate(decoded)
			if not decompressed then return end

			local workingReq = module.db.lastReq2[reqID]
			if type(workingReq) ~= "table" then
				return
			end
			if #workingReq ~= #decompressed then return end
			if workingReq[sender] then return end

			workingReq[sender] = true
			for i=1,#decompressed do
				module.db.responces2[ sender ][ workingReq[i][1] ] = tonumber( decompressed:sub(i,i),10 )
			end

			if module.options:IsVisible() and module.options.UpdatePage then
				module.options.UpdatePage()
			end
		elseif prefix2 == "SWA2" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local streamArg, id, playername = ...
			local streamID = tonumber(streamArg)
			if not streamID or not id or not playername then return end

			pendingShareV2[sender] = pendingShareV2[sender] or {}
			pendingShareV2[sender][streamID] = {id = id, playername = playername, ts = GetTime()}
			tryFinalizeShareV2(sender, streamID)
			chunkBufGC("D2", 600)
		elseif prefix2 == "SWA" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local id, playername = ...

			if module.db.synqWAData[sender] then
				if not WeakAurasSaved then return end
				local payload = module.db.synqWAData[sender]
				module.db.synqWAData[sender] = nil

				local deserialized
				do
					local str = payload:sub(7)
					local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
					if decoded then
						local decompressed = LibDeflate:DecompressDeflate(decoded)
						if decompressed then
							local LibSerialize = LibStub("LibSerialize")
							local ok, d = LibSerialize:Deserialize(decompressed)
							if ok and type(d) == "table" then
								deserialized = d
							end
						end
					end
				end

				if deserialized and deserialized.d and WeakAurasSaved.displays[ id ] then
					if module:CheckAuraIsSame(deserialized.d,id) then
						if not deserialized.c then
							return
						else
							local isPass = false
							for i=1,#deserialized.c do
								local child = deserialized.c[i]
								local cid = child and child.id
								if not child or not cid or not module:CheckAuraIsSame(child,cid) then
									isPass = true
									break
								end
							end
							if not isPass then
								return
							end
						end
					end
				end


				if not ExRT.isWotLKOnly then
					local link = "|Hgarrmission:weakauras|h|cFF8800FF["..playername.." |r|cFF8800FF- "..id.."]|h|r"
					pcall(SetItemRef, "garrmission:weakauras", link)
				end

				if ExRT.isWotLKOnly and type(_G.WeakAuras) == "table" and type(_G.WeakAuras.Import) == "function" then
					if deserialized then
						xpcall(function() _G.WeakAuras.Import(deserialized) end, geterrorhandler())
					end
				else
					local Comm = LibStub:GetLibrary("AceComm-3.0")
					if Comm and Comm.callbacks then
						Comm.callbacks:Fire("WeakAuras", payload, "RAID", playername)
					end
				end
			end
		end
	elseif prefix == "wac2" then
		if prefix2 == "G" then
			local time = GetTime()
			if lastSender ~= sender and (time - lastSenderTime) < 2 then
				return
			end
			lastSender = sender
			lastSenderTime = time
			if ... == "H" then
				wipe(module.db.lastReq)
				module.db.syncStr = ""
			end

			local str = table.concat({select(... == "H" and 2 or 1,...)}, "\t")
			module.db.syncStr = module.db.syncStr or ""
			module.db.syncStr = module.db.syncStr .. str
			if module.db.syncStr:find("##F##$") then
				local str = module.db.syncStr:sub(1,-6)
				module.db.syncStr = nil

				local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
				local decompressed = LibDeflate:DecompressDeflate(decoded)

				while decompressed:find("''") do
					local wa_name,o = decompressed:match("^(.-)''(.*)$")

					module.db.lastReq[#module.db.lastReq + 1] = wa_name

					decompressed = o
				end

				module.db.lastReq[#module.db.lastReq + 1] = decompressed

				module:SendResp()
			end
		end
	elseif prefix == "wac3" then
		if prefix2 == "G" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local now = GetTime()
			if not sync_db.wac3_G_syncStr then sync_db.wac3_G_syncStr = {} end
			if not sync_db.wac3_G_senderToCount then sync_db.wac3_G_senderToCount = {} end

			if ... == "H" then
				sync_db.wac3_G_count = (sync_db.wac3_G_count or 0) + 1
				sync_db.wac3_G_senderToCount[sender] = sync_db.wac3_G_count
				module.db.lastReq2[sync_db.wac3_G_count] = {}
				sync_db.wac3_G_syncStr[sender] = ""
			end
			if not sync_db.wac3_G_senderToCount[sender] then
				return
			end

			local str = table.concat({select(... == "H" and 2 or 1,...)}, "\t")
			sync_db.wac3_G_syncStr[sender] = (sync_db.wac3_G_syncStr[sender] or "") .. str
			if sync_db.wac3_G_syncStr[sender]:find("##F##$") then
				local str = sync_db.wac3_G_syncStr[sender]:sub(1,-6)
				sync_db.wac3_G_syncStr[sender] = nil

				local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
				local decompressed = LibDeflate:DecompressDeflate(decoded)

				decompressed = decompressed

				local c = sync_db.wac3_G_senderToCount[sender]
				local now_time = time()
				local pos = 1
				while true do
					local ns,ne = decompressed:find("''",pos,true)
					if not ns then break end
					local wa_name = decompressed:sub(pos,ns-1)
					local hs,he = decompressed:find("''",ne+1,true)
					if hs then hs = hs-1 end
					local wa_hash = decompressed:sub(ne+1,hs)

					module.db.lastReq2[c][#module.db.lastReq2[c] + 1] = {wa_name,wa_hash}
					module.db.lastCheck[wa_name] = now_time
					module.db.lastCheckName[wa_name] = sender
					if not he then break end
					pos = he + 1
				end

				C_Timer.After(300,function() module.db.lastReq2[c] = 0 end)
				module:SendResp2(module.db.lastReq2[c])
			end
		elseif prefix2 == "G2" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local arg1, arg2, arg3, chunk = ...
			local reqID = tonumber(arg1)
			local idx = tonumber(arg2)
			local total = tonumber(arg3)
			if not reqID or not idx or not total or not chunk then return end
			if total <= 0 or idx <= 0 or idx > total then return end

			local buf = chunkBufFor("G2", sender, reqID, total)
			if not chunkBufComplete(buf, idx, chunk) then return end

			local fullEncoded = chunkBufAssemble(buf)
			chunkBufDrop("G2", sender, reqID)
			chunkBufGC("G2", 600)

			local decoded = LibDeflate:DecodeForWoWAddonChannel(fullEncoded)
			if not decoded then return end
			local decompressed = LibDeflate:DecompressDeflate(decoded)
			if not decompressed then return end

			local pairsList = {}
			local now_time = time()
			local pos = 1
			while true do
				local ns,ne = decompressed:find("''",pos,true)
				if not ns then break end
				local wa_name = decompressed:sub(pos,ns-1)
				local hs,he = decompressed:find("''",ne+1,true)
				if hs then hs = hs-1 end
				local wa_hash = decompressed:sub(ne+1,hs)

				pairsList[#pairsList + 1] = {wa_name,wa_hash}
				module.db.lastCheck[wa_name] = now_time
				module.db.lastCheckName[wa_name] = sender
				if not he then break end
				pos = he + 1
			end

			module:SendResp2(pairsList, reqID, sender)
		elseif prefix2 == "D" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			if IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender) then

			end
			local arg1 = ...

			local currMsg = table.concat({select(2,...)}, "\t")
			if tostring(arg1) == tostring(module.db.synqIndexWA[sender]) and type(module.db.synqTextWA[sender])=='string' then
				module.db.synqTextWA[sender] = module.db.synqTextWA[sender] .. currMsg
			else
				module.db.synqTextWA[sender] = currMsg
				module.db.synqWAData[sender] = nil
			end
			module.db.synqIndexWA[sender] = arg1

			if type(module.db.synqTextWA[sender])=='string' and module.db.synqTextWA[sender]:find("##F##$") then
				local str = module.db.synqTextWA[sender]:sub(1,-6)

				module.db.synqTextWA[sender] = nil
				module.db.synqIndexWA[sender] = nil
				module.db.synqWAData[sender] = str
			end
		elseif prefix2 == "D2" then
			local selfName = ExRT.SDB and ExRT.SDB.charName or UnitName("player")
			if selfName and Ambiguate(sender, "none") == selfName then
				return
			end
			local arg1, arg2, arg3, chunk = ...
			local streamID = tonumber(arg1)
			local idx = tonumber(arg2)
			local total = tonumber(arg3)
			if not streamID or not idx or not total or not chunk then return end
			if total <= 0 or idx <= 0 or idx > total then return end

			local buf = chunkBufFor("D2", sender, streamID, total)
			chunkBufComplete(buf, idx, chunk)
			tryFinalizeShareV2(sender, streamID)
		end
	end
end

module.db.synqTextWA = {}
module.db.synqIndexWA = {}
module.db.synqWAData = {}

local function shouldInclude(data, includeGroups, includeLeafs)
	if data.controlledChildren then
		return includeGroups
	else
		return includeLeafs
	end
end

local function Traverse(data, includeSelf, includeGroups, includeLeafs)
	if includeSelf and shouldInclude(data, includeGroups, includeLeafs) then
		coroutine.yield(data)
	end

	if data.controlledChildren then
		for _, child in ipairs(data.controlledChildren) do
			Traverse(WeakAurasSaved.displays[child], true, includeGroups, includeLeafs)
		end
	end
end

local function TraverseAllCo(data)
	return Traverse(data, true, true, true)
end

local function TraverseAllChildrenCo(data)
	return Traverse(data, false, true, true)
end

local function TraverseAll(data)
	return coroutine.wrap(TraverseAllCo), data
end

local function TraverseAllChildren(data)
	return coroutine.wrap(TraverseAllChildrenCo), data
end

local bytetoB64 = {
	[0]="a","b","c","d","e","f","g","h",
	"i","j","k","l","m","n","o","p",
	"q","r","s","t","u","v","w","x",
	"y","z","A","B","C","D","E","F",
	"G","H","I","J","K","L","M","N",
	"O","P","Q","R","S","T","U","V",
	"W","X","Y","Z","0","1","2","3",
	"4","5","6","7","8","9","(",")"
  }

local function GenerateUniqueID()

	local s = {}
	for i = 1, 11 do
		tinsert(s, bytetoB64[math.random(0, 63)])
	end
	return table.concat(s)
end

function module:WA_DisplayToTable(id)
	local data = WeakAurasSaved.displays[id]
	if data then
		data.uid = data.uid or GenerateUniqueID()
		local copy = ExRT.F.table_copy2(data)
		stripNonTx(copy, nonTxFields)
		copy.tocversion = WeakAuras.BuildInfo or copy.tocversion
		local transmit = {
			m = "d",
			d = copy,
			s = WeakAuras.versionString,
			v = 2000,
		}
		if data.controlledChildren then
			transmit.c = {}
			local uids = {}
			local index = 1
			for child in TraverseAllChildren(data) do
				if child.uid then
					if uids[child.uid] then
						child.uid = GenerateUniqueID()
					else
						uids[child.uid] = true
					end
				else
					child.uid = GenerateUniqueID()
				end
				local childCopy = ExRT.F.table_copy2(child)
				stripNonTx(childCopy, nonTxFields)
				childCopy.tocversion = WeakAuras.BuildInfo or childCopy.tocversion
				transmit.c[index] = childCopy
				index = index + 1
			end
		end
		return transmit
	end
end

function module:TableToString(t)
	local LibSerialize = LibStub("LibSerialize")

	local serialized = LibSerialize:SerializeEx({errorOnUnserializableType=false}, t)
	local compressed = LibDeflate:CompressDeflate(serialized, {level=9})
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	return encoded
end

function module:SendWA(id)
	local now = GetTime()
	if module.db.prevSendWA and now - module.db.prevSendWA < 1 then
		return
	end
	module.db.prevSendWA = now

	local Comm = getAceComm()
	if not Comm then
		print("MRT: AceComm-3.0 not available; cannot share WeakAura. Make sure WeakAuras is loaded.")
		return
	end

	local encoded = "!WA:2!"..module:TableToString(module:WA_DisplayToTable(id))

	local targets = {}
	local seen = {}
	if IsInRaid() then
		for i=1,GetNumGroupMembers() do
			local rname = GetRaidRosterInfo(i)
			if rname then
				local short = Ambiguate(rname, "none")
				if short and not seen[short] and not UnitIsUnit("raid"..i, "player") then
					seen[short] = true
					targets[#targets+1] = rname
				end
			end
		end
	elseif IsInGroup() then
		for i=1,GetNumSubgroupMembers() do
			local unit = "party"..i
			local pname = UnitName(unit)
			if pname and not seen[pname] and not UnitIsUnit(unit, "player") then
				seen[pname] = true
				targets[#targets+1] = pname
			end
		end
	end

	if #targets == 0 then
		print(id,"no recipients in group")
		return
	end

	local total = #targets
	local doneCount = 0
	for _,target in ipairs(targets) do
		Comm:SendCommMessage("MRTWAShare", encoded, "WHISPER", target, "BULK", function(arg, doneBytes, allBytes)
			if doneBytes and allBytes and doneBytes >= allBytes then
				doneCount = doneCount + 1
				if doneCount >= total then
					print(id, "sended to", total, "raid member(s)")
				elseif doneCount % 5 == 0 then
					print(id, "sended to", doneCount.."/"..total)
				end
			end
		end, id)
	end
end
