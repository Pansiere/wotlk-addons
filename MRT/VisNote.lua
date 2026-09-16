local GlobalAddonName, ExRT = ...

local ELib,L = ExRT.lib,ExRT.L
local module = ExRT:New("VisNote",L.VisualNote)

local VMRT = nil

local wipe, pairs, type, max, min, unpack, abs, select, sqrt, tremove, string, floor, math, PI = wipe, pairs, type, max, min, unpack, abs, select, sqrt, tremove, string, floor, math, PI

local LibDeflate = LibStub:GetLibrary("LibDeflate")

module.db.await = {}

local DATA_VERSION = 2

function module.options:Load()
	self:CreateTilte()
	self.title:Point(2,5)

	local __testFrame = CreateFrame("Button")
	local __testButton = CreateFrame("Button")
	 local __testTex = __testFrame:CreateTexture();
	if not __testFrame.CreateLine or not __testButton.CreateLine or not (__testTex and __testTex.SetRotation) then
		ELib:Text(self,"Visual Note is not supported on WoW 3.3.5a.",12):Point("TOPLEFT",10,-40):Size(760,40)
		return
	end

	local special_counter = 0
	local update_tmr = 0
	local isLiveSession = false
	self:SetScript("OnUpdate",function(self,elapsed)
		update_tmr = update_tmr + elapsed
		if update_tmr > 1 then
			update_tmr = 0
			if special_counter > 0 then
				special_counter = 0
				module.options:SaveData()
				if isLiveSession then
					module.options:GenerateString(true)
				end
			end
		end
	end)

	local timers = {}

	local dots = {}
	local dot_size,half_dot_size_sq = 6,4
	local dots_pos_X,dots_pos_Y = {},{}
	local dots_SIZE,dots_COLOR,dots_GROUP = {},{},{}
	local dots_OBJ,dots_SYNC = {},{}

	local icons = {}
	local icon_pos_X,icon_pos_Y = {},{}
	local icon_SIZE,icon_TYPE,icon_GROUP = {},{},{}
	local icon_OBJ,icon_SYNC = {},{}

	local texts = {}
	local text_pos_X,text_pos_Y = {},{}
	local text_SIZE,text_DATA,text_GROUP,text_COLOR = {},{},{},{}
	local text_OBJ,text_SYNC = {},{}

	local objects = {}
	local object_pos_X,object_pos_Y = {},{}
	local object_SIZE,object_GROUP,object_COLOR,object_TYPE = {},{},{},{}
	local object_DATA1,object_DATA2,object_SYNC = {},{},{}

	local images = {}
	local image_pos_X,image_pos_Y = {},{}
	local image_pos_X2,image_pos_Y2 = {},{}
	local image_path,image_alpha = {},{}
	local image_GROUP = {}
	local image_OBJ,image_SYNC = {},{}

	local lines = {}

	local locked_img = {}

	local lockedGroups = {}

	local backgrounds = {}
	local curr_group = 0
	local curr_color = 4
	local curr_map = 1
	local curr_data = {}
	local curr_icon = 1
	local curr_text = ""
	local curr_imgpath = ExRT.isClassic and "interface/icons/ability_hunter_snipershot" or "interface/icons/achievement_boss_archaedas"
	local curr_object = 1
	local curr_trans = 100

	local tool_selected = 1

	module.db.opt_data = {
		dots = dots,
		dots_pos_X = dots_pos_X,
		dots_pos_Y = dots_pos_Y,
		dots_SIZE = dots_SIZE,
		dots_COLOR = dots_COLOR,
		dots_GROUP = dots_GROUP,
		dots_OBJ = dots_OBJ,
		dots_SYNC = dots_SYNC,

		icons = icons,
		icon_pos_X = icon_pos_X,
		icon_pos_Y = icon_pos_Y,
		icon_SIZE = icon_SIZE,
		icon_TYPE = icon_TYPE,
		icon_GROUP = icon_GROUP,
		icon_OBJ = icon_OBJ,
		icon_SYNC = icon_SYNC,

		texts = texts,
		text_pos_X = text_pos_X,
		text_pos_Y = text_pos_Y,
		text_SIZE = text_SIZE,
		text_DATA = text_DATA,
		text_COLOR = text_COLOR,
		text_GROUP = text_GROUP,
		text_OBJ = text_OBJ,
		text_SYNC = text_SYNC,

		objects = objects,
		object_pos_X = object_pos_X,
		object_pos_Y = object_pos_Y,
		object_SIZE = object_SIZE,
		object_GROUP = object_GROUP,
		object_COLOR = object_COLOR,
		object_TYPE = object_TYPE,
		object_DATA1 = object_DATA1,
		object_DATA2 = object_DATA2,
		object_SYNC = object_SYNC,

		lines = lines,

		images = images,
		image_pos_X = image_pos_X,
		image_pos_Y = image_pos_Y,
		image_pos_X2 = image_pos_X2,
		image_pos_Y2 = image_pos_Y2,
		image_path = image_path,
		image_alpha = image_alpha,
		image_GROUP = image_GROUP,
		image_OBJ = image_OBJ,
		image_SYNC = image_SYNC,

		locked_img = locked_img,

		backgrounds = backgrounds,
	}

	local colors = {
		{0,0,0},
		{127/255,127/255,127/255},
		{136/255,0/255,21/255},
		{237/255,28/255,36/255},
		{255/255,127/255,39/255},
		{255/255,242/255,0/255},
		{34/255,177/255,76/255},
		{0/255,162/255,232/255},
		{63/255,72/255,204/255},
		{163/255,73/255,164/255},

		{1,1,1},
		{195/255,195/255,195/255},
		{185/255,122/255,87/255},
		{255/255,174/255,201/255},
		{255/255,201/255,14/255},
		{239/255,228/255,176/255},
		{181/255,230/255,29/255},
		{153/255,217/255,234/255},
		{112/255,146/255,190/255},
		{200/255,191/255,231/255},

		{0.67,0.83,.45},
		{0,1,.59},
		{.53,.53,.93},
		{.64,.19,.79},
		{0.20,0.58,0.50},
	}

	local icons_list = {
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
		{"Interface\\LFGFrame\\UI-LFG-ICON-ROLES",0,0.26171875,0.26171875,0.5234375},
		{"Interface\\LFGFrame\\UI-LFG-ICON-ROLES",0.26171875,0.5234375,0,0.26171875},
		{"Interface\\LFGFrame\\UI-LFG-ICON-ROLES",0.26171875,0.5234375,0.26171875,0.5234375},
		UnitFactionGroup("player") == "Alliance" and "Interface\\FriendsFrame\\PlusManz-Alliance" or "Interface\\FriendsFrame\\PlusManz-Horde",
		{ExRT.F.classSquareIcon["WARRIOR"],0,1,0,1},
		{ExRT.F.classSquareIcon["PALADIN"],0,1,0,1},
		{ExRT.F.classSquareIcon["HUNTER"],0,1,0,1},
		{ExRT.F.classSquareIcon["ROGUE"],0,1,0,1},
		{ExRT.F.classSquareIcon["PRIEST"],0,1,0,1},
		{ExRT.F.classSquareIcon["DEATHKNIGHT"],0,1,0,1},
		{ExRT.F.classSquareIcon["SHAMAN"],0,1,0,1},
		{ExRT.F.classSquareIcon["MAGE"],0,1,0,1},
		{ExRT.F.classSquareIcon["WARLOCK"],0,1,0,1},
		{"Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",0.5,0.73828125,0.5,0.75},
		{ExRT.F.classSquareIcon["DRUID"],0,1,0,1},
		{"Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",0.7421875,0.98828125,0.5,0.75},
	}

	local IsDotIn
	local LockedImgHideAll

	function self:Clear()
		for d,_ in pairs(dots) do
			d:Hide()
		end
		wipe(dots_pos_X)
		wipe(dots_pos_Y)
		wipe(dots_SIZE)
		wipe(dots_COLOR)
		wipe(dots_GROUP)
		wipe(dots_OBJ)
		wipe(dots_SYNC)

		for d,_ in pairs(icons) do
			d:Hide()
		end
		wipe(icon_pos_X)
		wipe(icon_pos_Y)
		wipe(icon_SIZE)
		wipe(icon_TYPE)
		wipe(icon_GROUP)
		wipe(icon_OBJ)
		wipe(icon_SYNC)

		for d,_ in pairs(texts) do
			d:Hide()
		end
		wipe(text_pos_X)
		wipe(text_pos_Y)
		wipe(text_SIZE)
		wipe(text_DATA)
		wipe(text_COLOR)
		wipe(text_GROUP)
		wipe(text_OBJ)
		wipe(text_SYNC)

		for d,_ in pairs(objects) do
			d:Hide()
		end
		wipe(object_pos_X)
		wipe(object_pos_Y)
		wipe(object_SIZE)
		wipe(object_GROUP)
		wipe(object_COLOR)
		wipe(object_TYPE)
		wipe(object_DATA1)
		wipe(object_DATA2)
		wipe(object_SYNC)

		for d,_ in pairs(lines) do
			d:Hide()
		end

		wipe(image_pos_X)
		wipe(image_pos_Y)
		wipe(image_pos_X2)
		wipe(image_pos_Y2)
		wipe(image_path)
		wipe(image_alpha)
		wipe(image_GROUP)
		wipe(image_OBJ)
		wipe(image_SYNC)

		for d,_ in pairs(images) do
			d:Hide()
		end

		if self.main and self.main.ResetScale then
			self.main:ResetScale()
		end
	end


	self.main = ELib:ScrollFrame(self):Size(790,535):Point("TOP",0,-81):Height(535)
	self.main.C:SetWidth(790-2)
	self.main.ScrollBar:Hide()
	self.main.C:EnableMouse(true)


	function self:SetTool(data)
		if tool_selected == 7 then
			LockedImgHideAll()
		end

		tool_selected = data.tool
		curr_object = data.object

		if not self.curr_color_texture then return end

		self.curr_color_texture:SetShown((data.color or data.icon or data.imgpath) and true or false)
		if data.color then
			self.curr_color_texture:SetColorTexture(unpack(data.color))
			if data.colorMini then
				for i=1,#self.color_selector_mini do self.color_selector_mini[i]:Show() end
				for i=1,#self.color_selector do self.color_selector[i]:Hide() end
			else
				for i=1,#self.color_selector do self.color_selector[i]:Show() end
				for i=1,#self.color_selector_mini do self.color_selector_mini[i]:Hide() end
			end
		else
			for i=1,#self.color_selector do self.color_selector[i]:Hide() end
			for i=1,#self.color_selector_mini do self.color_selector_mini[i]:Hide() end
		end

		if tool_selected == 4 and (curr_object == 3 or curr_object == 5 or curr_object == 6) then
			for i=1,#self.line_selector do
				ELib:Border(self.line_selector[i],2,.24,.25,.30,1)
				self.line_selector[i]:Show()
			end
			ELib:Border(curr_object == 3 and self.line_selector[1] or curr_object == 5 and self.line_selector[2] or curr_object == 6 and self.line_selector[3],2,.24,.7,.30,1)
		else
			for i=1,#self.line_selector do self.line_selector[i]:Hide() end
		end

		if data.icon then
			self.curr_color_texture:SetTexture(data.icon)
			for i=1,#self.icon_selector do self.icon_selector[i]:Show() end
		else
			for i=1,#self.icon_selector do self.icon_selector[i]:Hide() end
		end

		if data.size then
			self.size:Show()
			self.size:SetTo(data.size)
		else
			self.size:Hide()
		end

		if data.transparent then
			self.trans:Show()
			self.trans:SetTo(data.transparent)
		else
			self.trans:Hide()
		end

		if data.imgpath then
			self.imgpath:Show()
			self.imgpath:SetText(curr_imgpath)
			self.imgpath:SetCursorPosition(1)
			self.curr_color_texture:SetTexture(curr_imgpath)
		else
			self.imgpath:Hide()
		end

		self.textAddData:SetShown(data.text)

		for k,v in pairs(self) do
			if type(k)=='string' and k:find("^tool_select_") then
				ELib:Border(v,2,.24,.25,.30,1)
			end
		end
		ELib:Border(data.button,2,.24,.7,.30,1)
	end

	self.tool_select_brush = ELib:Icon(self,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256",25,true):Point("TOPLEFT",10,-20):OnClick(function(self)
		module.options:SetTool{
			tool = 1,
			color = colors[curr_color],
			size = dot_size,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_brush,2,.24,.25,.30,1)
	self.tool_select_brush.texture:ClearAllPoints()
	self.tool_select_brush.texture:SetPoint("CENTER")
	self.tool_select_brush.texture:SetSize(8,8)

	self.tool_select_icons = ELib:Icon(self,"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",25,true):Point("LEFT",self.tool_select_brush,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 2,
			icon = icons_list[curr_icon],
			button = self,
		}
	end)
	ELib:Border(self.tool_select_icons,2,.24,.25,.30,1)
	self.tool_select_icons.texture:ClearAllPoints()
	self.tool_select_icons.texture:SetPoint("CENTER")
	self.tool_select_icons.texture:SetSize(20,20)

	self.tool_select_text = ELib:Icon(self,nil,25,true):Point("LEFT",self.tool_select_icons,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 3,
			color = colors[curr_color],
			text = true,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_text,2,.24,.25,.30,1)
	self.tool_select_text.texture:Hide()
	self.tool_select_text.text = self.tool_select_text:CreateFontString(nil,"ARTWORK","GameFontWhite")
	self.tool_select_text.text:SetFont(self.tool_select_text.text:GetFont(),10,"")
	self.tool_select_text.text:SetPoint("CENTER")
	self.tool_select_text.text:SetText("TEXT")


	self.tool_select_objects = ELib:Icon(self,"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",25,true):Point("LEFT",self.tool_select_text,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 4,
			object = 1,
			color = colors[curr_color],
			size = dot_size,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_objects,2,.24,.25,.30,1)
	self.tool_select_objects.texture:Hide()
	do
		local size = 8
		local circleLen = 2*PI*size
		local len = ceil(circleLen / (2 / 2))
		for i=0,len do
			local x = 0 + size * math.cos(2*PI/len*i)
			local y = 0 + size * math.sin(2*PI/len*i)

			local o = self.tool_select_objects:CreateTexture()
			o:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
			o:SetPoint("CENTER",self.tool_select_objects,"CENTER",x,-y)

			o:SetSize(2,2)
		end
	end


	self.tool_select_objects_fullcircle = ELib:Icon(self,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256",25,true):Point("TOPLEFT",self.tool_select_brush,"BOTTOMLEFT",0,-5):OnClick(function(self)
		module.options:SetTool{
			tool = 4,
			object = 2,
			color = colors[curr_color],
			transparent = curr_trans/2,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_objects_fullcircle,2,.24,.25,.30,1)
	self.tool_select_objects_fullcircle.texture:ClearAllPoints()
	self.tool_select_objects_fullcircle.texture:SetPoint("CENTER")
	self.tool_select_objects_fullcircle.texture:SetSize(20,20)
	self.tool_select_objects_fullcircle.texture:SetAlpha(.75)


	self.tool_select_objects_line = ELib:Icon(self,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256",25,true):Point("LEFT",self.tool_select_objects_fullcircle,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 4,
			object = 3,
			color = colors[curr_color],
			colorMini = true,
			size = dot_size,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_objects_line,2,.24,.25,.30,1)
	self.tool_select_objects_line.texture:Hide()
	do
		if self.tool_select_objects_line.CreateLine then
			local l = self.tool_select_objects_line:CreateLine()
			l:SetStartPoint("CENTER",-8,-8)
			l:SetEndPoint("CENTER",8,8)
			l:SetColorTexture(1,1,1,1)
			l:SetThickness(2)
		else
			self.tool_select_objects_line.texture:Show()
		end
	end

		do
		self.line_selector = {}
		for i=1,3 do
			self.line_selector[i] = ELib:Icon(self,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256",30,true):Point("TOPLEFT",420 + 33 * (i-1),-35):OnClick(function(self)
				module.options:SetTool{
					tool = 4,
					object = (i == 1 and 3) or (i == 2 and 5) or (i == 3 and 6),
					color = colors[curr_color],
					colorMini = true,
					size = dot_size,
					button = self,
				}
			end)
			ELib:Border(self.line_selector[i],2,.24,.25,.30,1)
			self.line_selector[i].texture:Hide()
			do
				local l = self.line_selector[i]:CreateLine()
				l:SetStartPoint("CENTER",-8,-8)
				l:SetEndPoint("CENTER",8,8)
				l:SetColorTexture(1,1,1,1)
				l:SetThickness(2)
				if i == 3 then
					l:SetTexture("Interface/AddOns/"..GlobalAddonName.."/media/lineGapped.tga","REPEAT")
					l:SetTexCoord(0,.15,0,1)
					l:SetThickness(4)
				elseif i == 2 then
					local lr = self.line_selector[i]:CreateLine()
					lr:SetStartPoint("CENTER",0,8)
					lr:SetEndPoint("CENTER",8,8)
					lr:SetColorTexture(1,1,1,1)
					lr:SetThickness(2)
					local ll = self.line_selector[i]:CreateLine()
					ll:SetStartPoint("CENTER",8,0)
					ll:SetEndPoint("CENTER",8,8)
					ll:SetColorTexture(1,1,1,1)
					ll:SetThickness(2)
				end
			end
		end
	end


	self.tool_select_objects_rectangle = ELib:Icon(self,nil,25,true):Point("LEFT",self.tool_select_objects_line,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 4,
			object = 4,
			color = colors[curr_color],
			transparent = curr_trans/2,
			button = self,
		}
	end):Icon(1,1,1,1)
	ELib:Border(self.tool_select_objects_rectangle,2,.24,.25,.30,1)
	self.tool_select_objects_rectangle.texture:ClearAllPoints()
	self.tool_select_objects_rectangle.texture:SetPoint("CENTER")
	self.tool_select_objects_rectangle.texture:SetSize(16,16)
	self.tool_select_objects_rectangle.texture:SetAlpha(.75)


	self.tool_select_move = ELib:Icon(self,"Interface\\Cursor\\Point",25,true):Point("LEFT",self.tool_select_objects_rectangle,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 5,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_move,2,.24,.25,.30,1)
	self.tool_select_move.texture:ClearAllPoints()
	self.tool_select_move.texture:SetPoint("CENTER")
	self.tool_select_move.texture:SetSize(18,18)
	self.tool_select_move.texture:SetAlpha(.75)
	if not self.tool_select_move.texture:GetTexture() then
		self.tool_select_move.texture:Hide()
		self.tool_select_move.glyph = self.tool_select_move:CreateFontString(nil,"ARTWORK","GameFontWhite")
		self.tool_select_move.glyph:SetPoint("CENTER")
		self.tool_select_move.glyph:SetFont(STANDARD_TEXT_FONT,16,"OUTLINE")
		self.tool_select_move.glyph:SetText("+")
	end


	self.tool_select_objects_image = ELib:Icon(self,curr_imgpath,25,true):Point("LEFT",self.tool_select_objects,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 6,
			imgpath = curr_imgpath,
			transparent = curr_trans/2,
			button = self,
		}
	end)
	ELib:Border(self.tool_select_objects_image,2,.24,.25,.30,1)
	self.tool_select_objects_image.texture:ClearAllPoints()
	self.tool_select_objects_image.texture:SetPoint("CENTER")
	self.tool_select_objects_image.texture:SetSize(20,20)
	self.tool_select_objects_image.texture:SetTexCoord(.1,.9,.1,.9)


	self.tool_select_objects_locker = ELib:Icon(self,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128",25,true):Point("LEFT",self.tool_select_move,"RIGHT",5,0):OnClick(function(self)
		module.options:SetTool{
			tool = 7,
			button = self,
		}
	end):Tooltip("Left click on note - Lock/unlock objects for moving/removing\nRight click on note - select specific object from all objects under cursor")
	ELib:Border(self.tool_select_objects_locker,2,.24,.25,.30,1)
	self.tool_select_objects_locker.texture:ClearAllPoints()
	self.tool_select_objects_locker.texture:SetPoint("CENTER")
	self.tool_select_objects_locker.texture:SetSize(20,20)
	self.tool_select_objects_locker.texture:SetTexCoord(.625,.6875,.5,.625)


	local COLOR_SIZE = 45
	self.curr_color_texture = self:CreateTexture()
	self.curr_color_texture:SetPoint("TOPLEFT",290,-31)
	self.curr_color_texture:SetSize(COLOR_SIZE,COLOR_SIZE)
	self.curr_color_texture:SetColorTexture(0,0,0)
	self.curr_color_texture._SetTexture = self.curr_color_texture.SetTexture
	function self.curr_color_texture:SetTexture(texture)
		if self.SetVertexColor then
			self:SetVertexColor(1,1,1,1)
		end
		if type(texture) == 'table' then
			self:SetTexCoord(select(2,unpack(texture)))
			self:_SetTexture(texture[1])
		elseif type(texture) == 'number' then
			self:SetTexCoord(0,1,0,1)
			local icon = GetItemIcon and GetItemIcon(texture)
			if not icon and GetSpellTexture then icon = GetSpellTexture(texture) end
			self:_SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
		else
			self:SetTexCoord(0,1,0,1)
			self:_SetTexture(texture)
		end
	end

	self.color_selector = {}
	for i=1,#colors do
		self.color_selector[i] = ELib:Icon(self,nil,floor(COLOR_SIZE / 2),true):Icon(unpack(colors[i])):OnClick(function()
			curr_color = i
			self.curr_color_texture:SetColorTexture(unpack(colors[i]))
		end)
		if i == 1 then
			self.color_selector[i]:NewPoint("TOPLEFT",self.curr_color_texture,"TOPRIGHT",1,0)
		elseif i == 11 then
			self.color_selector[i]:NewPoint("BOTTOMLEFT",self.curr_color_texture,"BOTTOMRIGHT",1,0)
		elseif i == 21 then
			self.color_selector[i]:NewPoint("LEFT",self.color_selector[10],"RIGHT",1,0)
		elseif i == 23 then
			self.color_selector[i]:NewPoint("LEFT",self.color_selector[20],"RIGHT",1,0)
		else
			self.color_selector[i]:NewPoint("LEFT",self.color_selector[i-1],"RIGHT",1,0)
		end
	end

	self.color_selector_mini = {}
	for i=1,#colors do
		local colorNum = i
		if i > 10 and i <= 12 then
			colorNum = i + 10
		elseif i > 12 and i <= 22 then
			colorNum = i - 2
		end

		self.color_selector_mini[i] = ELib:Icon(self,nil,floor((COLOR_SIZE - 3) / 4),true):Icon(unpack(colors[colorNum])):OnClick(function()
			curr_color = colorNum
			self.curr_color_texture:SetColorTexture(unpack(colors[colorNum]))
		end)
		if i == 1 then
			self.color_selector_mini[i]:NewPoint("TOPLEFT",self.curr_color_texture,"TOPRIGHT",1,-1)
		elseif (i - 1) % 6 == 0 then
			self.color_selector_mini[i]:NewPoint("TOP",self.color_selector_mini[i-6],"BOTTOM",0,-1)
		else
			self.color_selector_mini[i]:NewPoint("LEFT",self.color_selector_mini[i-1],"RIGHT",1,0)
		end
	end

	local ICONS_SIZE = 40
	self.icon_selector = {}
	for i=1,#icons_list do
		local t = icons_list[i]
		self.icon_selector[i] = ELib:Icon(self,type(t)=='table' and t[1] or t,floor(ICONS_SIZE / 2),true):OnClick(function()
			curr_icon = i
			self.curr_color_texture:SetTexture(icons_list[i])
		end)
		if type(t)=='table' then
			self.icon_selector[i].texture:SetTexCoord(select(2,unpack(t)))
		end
		if i == 1 then
			self.icon_selector[i]:NewPoint("TOPLEFT",self.curr_color_texture,"TOPRIGHT",1,0)
		elseif i == 13 then
			self.icon_selector[i]:NewPoint("BOTTOMLEFT",self.curr_color_texture,"BOTTOMRIGHT",1,0)
		else
			self.icon_selector[i]:NewPoint("LEFT",self.icon_selector[i-1],"RIGHT",1,0)
		end
	end

	self.size = ELib:Slider(self,L.VisualNoteSize):Size(100):Point("TOPLEFT",170,-50):Range(3,36):SetTo(8):OnChange(function(self,val)
		dot_size = floor(val+0.5)
		half_dot_size_sq = (dot_size / 3) ^ 2
		self.tooltipText = dot_size
		self:tooltipReload()
	end)

	self.trans = ELib:Slider(self,L.bossmodsalpha):Size(100):Point("TOPLEFT",170,-50):Range(1,50):SetTo(50):OnChange(function(self,val)
		curr_trans = floor(val+0.5) * 2
		self.tooltipText = curr_trans
		self:tooltipReload()
	end)
	self.trans.Low:SetText("0%")
	self.trans.High:SetText("100%")
	self.trans.Low.SetText = function() end
	self.trans.High.SetText = function() end

	self.textAddData = ELib:Edit(self):Size(100,20):Point("TOPLEFT",160,-50):TopText(L.VisualNoteTextToAdd):OnChange(function(self)
		curr_text = self:GetText()
	end)
	self.textAddData:SetMaxBytes(100)
	self.textAddData.Button = ELib:Templates_GUIcons(3,self.textAddData)
	self.textAddData.Button:SetPoint("LEFT",self.textAddData,"RIGHT",1,0)
	self.textAddData.Button:SetSize(20,20)
	ELib:Border(self.textAddData.Button,1,.24,.25,.30,1)

	local classToColor = {
		WARRIOR=13,
		PALADIN=14,
		HUNTER=21,
		ROGUE=6,
		PRIEST=11,
		DEATHKNIGHT=4,
		SHAMAN=9,
		MAGE=8,
		WARLOCK=23,
		DRUID=5,
	}

	local function TextAddData_SetValue(_,arg1,arg2)
		ELib:DropDownClose()
		self.textAddData:SetText(arg1)
		curr_color = arg2
		self.curr_color_texture:SetColorTexture(unpack(colors[arg2]))
	end

	self.textAddData.Button:SetScript("OnClick",function(self)
		self.List = {}

		for _, name, _, class in ExRT.F.IterateRoster do
			name = ExRT.F.delUnitNameServer(name)
			local colorTable = colors[ classToColor[class] ]
			self.List[#self.List + 1] = {
				text = name,
				colorCode = "|cff"..format("%02x%02x%02x",colorTable[1]*255,colorTable[2]*255,colorTable[3]*255),
				justifyH = "CENTER",
				arg1 = name,
				arg2 = classToColor[class],
				func = TextAddData_SetValue,
			}
		end

		ELib.ScrollDropDown.ClickButton(self)
	end)
	self.textAddData.Button.Width = 200
	self.textAddData.Button.Lines = 20
	self.textAddData.Button.isButton = true
	self.textAddData.Button.isModern = true

	self.imgpath = ELib:Edit(self):Size(250,20):Point("LEFT",self.curr_color_texture,"RIGHT",10,0):TopText("Image path:"):Text(curr_imgpath):OnChange(function(self)
		curr_imgpath = self:GetText():trim()
		curr_imgpath = tonumber(curr_imgpath) or curr_imgpath
		module.options.curr_color_texture:SetTexture(curr_imgpath)
	end)


	self.tool_select_brush:Click()


	local function GetBackground()
		local dot
		for d,_ in pairs(backgrounds) do
			if not d:IsShown() then
				dot = d
				break
			end
		end
		if not dot then
			dot = self.main.C:CreateTexture(nil,"BACKGROUND")
			backgrounds[dot] = true
		end
		dot:Show()
		return dot
	end
	local function _wm(folder, name, floor, cols, rows)
		return { file = "Interface\\WorldMap\\"..folder.."\\"..name, floor = floor or 0,
		         cols = cols or 4, rows = rows or 3, tileW = 256, tileH = 256 }
	end
	local CLASSIC_RAID_MAPS = {
		-- =========== WotLK ===========
		-- Naxxramas: 6 floors, no overview
		[1001] = _wm("Naxxramas","Naxxramas",1),
		[1002] = _wm("Naxxramas","Naxxramas",2),
		[1003] = _wm("Naxxramas","Naxxramas",3),
		[1004] = _wm("Naxxramas","Naxxramas",4),
		[1005] = _wm("Naxxramas","Naxxramas",5),
		[1006] = _wm("Naxxramas","Naxxramas",6),
		-- Ulduar: overview + 5 floors
		[1010] = _wm("Ulduar","Ulduar",0),
		[1011] = _wm("Ulduar","Ulduar",1),
		[1012] = _wm("Ulduar","Ulduar",2),
		[1013] = _wm("Ulduar","Ulduar",3),
		[1014] = _wm("Ulduar","Ulduar",4),
		[1015] = _wm("Ulduar","Ulduar",5),
		-- Icecrown Citadel: 8 floors, no overview
		[1031] = _wm("IcecrownCitadel","IcecrownCitadel",1),
		[1032] = _wm("IcecrownCitadel","IcecrownCitadel",2),
		[1033] = _wm("IcecrownCitadel","IcecrownCitadel",3),
		[1034] = _wm("IcecrownCitadel","IcecrownCitadel",4),
		[1035] = _wm("IcecrownCitadel","IcecrownCitadel",5),
		[1036] = _wm("IcecrownCitadel","IcecrownCitadel",6),
		[1037] = _wm("IcecrownCitadel","IcecrownCitadel",7),
		[1038] = _wm("IcecrownCitadel","IcecrownCitadel",8),
		-- Onyxia's Lair (1 floor)
		[1050] = _wm("OnyxiasLair","OnyxiasLair",1),
		-- Trial of the Crusader / Argent Coliseum (2 floors)
		[1051] = _wm("TheArgentColiseum","TheArgentColiseum",1),
		[1052] = _wm("TheArgentColiseum","TheArgentColiseum",2),
		-- Eye of Eternity (overview + 1 floor)
		[1053] = _wm("EyeOfEternity","EyeOfEternity",0),
		[1054] = _wm("EyeOfEternity","EyeOfEternity",1),
		-- Vault of Archavon (1 floor)
		[1055] = _wm("VaultOfArchavon","VaultOfArchavon",1),
		-- Obsidian Sanctum (overview + 1 floor)
		[1056] = _wm("TheObsidianSanctum","TheObsidianSanctum",0),
		[1057] = _wm("TheObsidianSanctum","TheObsidianSanctum",1),
		-- Ruby Sanctum (overview only)
		[1058] = _wm("TheRubySanctum","TheRubySanctum",0),

		-- =========== TBC ===========
		-- Karazhan: 17 floors (each room is its own tiny dungeon level)
		[1070] = _wm("Karazhan","Karazhan",1),
		[1071] = _wm("Karazhan","Karazhan",2),
		[1072] = _wm("Karazhan","Karazhan",3),
		[1073] = _wm("Karazhan","Karazhan",4),
		[1074] = _wm("Karazhan","Karazhan",5),
		[1075] = _wm("Karazhan","Karazhan",6),
		[1076] = _wm("Karazhan","Karazhan",7),
		[1077] = _wm("Karazhan","Karazhan",8),
		[1078] = _wm("Karazhan","Karazhan",9),
		[1079] = _wm("Karazhan","Karazhan",10),
		[1080] = _wm("Karazhan","Karazhan",11),
		[1081] = _wm("Karazhan","Karazhan",12),
		[1082] = _wm("Karazhan","Karazhan",13),
		[1083] = _wm("Karazhan","Karazhan",14),
		[1084] = _wm("Karazhan","Karazhan",15),
		[1085] = _wm("Karazhan","Karazhan",16),
		[1086] = _wm("Karazhan","Karazhan",17),
		-- Single-floor TBC raids
		[1087] = _wm("GruulsLair","GruulsLair",1),
		[1088] = _wm("MagtheridonsLair","MagtheridonsLair",1),
		[1089] = _wm("ZulAman","ZulAman",0),
		[1090] = _wm("CoilfangReservoir","CoilfangReservoir",1),
		[1091] = _wm("TempestKeep","TempestKeep",1),
		[1092] = _wm("CoTMountHyjal","CoTMountHyjal",0),
		-- Black Temple (overview + 7 floors)
		[1093] = _wm("BlackTemple","BlackTemple",0),
		[1094] = _wm("BlackTemple","BlackTemple",1),
		[1095] = _wm("BlackTemple","BlackTemple",2),
		[1096] = _wm("BlackTemple","BlackTemple",3),
		[1097] = _wm("BlackTemple","BlackTemple",4),
		[1098] = _wm("BlackTemple","BlackTemple",5),
		[1099] = _wm("BlackTemple","BlackTemple",6),
		[1100] = _wm("BlackTemple","BlackTemple",7),
		-- Sunwell Plateau (overview + 1 floor)
		[1107] = _wm("SunwellPlateau","SunwellPlateau",0),
		[1108] = _wm("SunwellPlateau","SunwellPlateau",1),

		-- =========== Classic ===========
		-- Molten Core (1 floor)
		[1120] = _wm("MoltenCore","MoltenCore",1),
		-- Blackwing Lair (4 floors)
		[1121] = _wm("BlackwingLair","BlackwingLair",1),
		[1122] = _wm("BlackwingLair","BlackwingLair",2),
		[1123] = _wm("BlackwingLair","BlackwingLair",3),
		[1124] = _wm("BlackwingLair","BlackwingLair",4),
		-- Zul'Gurub / AQ20 / AQ40 (overview only)
		[1125] = _wm("ZulGurub","ZulGurub",0),
		[1126] = _wm("RuinsOfAhnQiraj","RuinsOfAhnQiraj",0),
		[1127] = _wm("AhnQirajTheFallenKingdom","AhnQirajTheFallenKingdom",0),
	}

	local function SetBackground(background,centerX,centerY,scale)
		self.bgState = nil
		for b,_ in pairs(backgrounds) do
			b:Hide()
		end
		if type(background) == 'string' then
			local b = GetBackground()
			local w, h = self.main:GetSize()
			if (w or 0) < 1 or (h or 0) < 1 then w, h = 800, 550 end
			b:SetSize(w, h)
			if b.SetVertexColor then b:SetVertexColor(1, 1, 1, 1) end
			if b.SetTexCoord then b:SetTexCoord(0, 1, 0, 1) end
			local tex = background
			if type(tex) == "string" then
				local stripped = tex:gsub("%.[Tt][Gg][Aa]$", ""):gsub("%.[Bb][Ll][Pp]$", ""):gsub("%.[Pp][Nn][Gg]$", "")
				local variants = {
					(stripped:gsub("/", "\\")) .. ".tga",
					(stripped:gsub("/", "\\")) .. ".blp",
					(stripped:gsub("/", "\\")),
					stripped .. ".tga",
					stripped,
				}
				local loaded
				for i = 1, #variants do
					b:SetTexture(variants[i])
					if b.GetTexture and b:GetTexture() then
						loaded = variants[i]
						break
					end
				end
				if not loaded then
					b:SetTexture(tex)
				end
			else
				b:SetTexture(tex)
			end
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self.main.C, "TOPLEFT", 0, 0)
			return b
		elseif type(background) == 'table' then
			local b = GetBackground()
			b:SetSize(self.main:GetSize())
			b:SetColorTexture(unpack(background))
			b:SetPoint("TOPLEFT",0,0)
			return b
		elseif type(background) == 'number' then
			local md = CLASSIC_RAID_MAPS[background]
			if md then
				local widthCount, heightCount = md.cols, md.rows
				local layerW, layerH = md.cols * md.tileW, md.rows * md.tileH

				-- Auto-fill the 1024x768 layer into the visible main frame
				-- (typically ~790x535) so the map covers the whole frame
				-- without empty padding. Caller-provided scale still wins
				-- when set.
				local mainW, mainH = self.main:GetSize()
				if (mainW or 0) < 1 or (mainH or 0) < 1 then mainW, mainH = 790, 535 end
				if not scale then
					scale = math.max(mainW / layerW, mainH / layerH) * 1.06
				end

				local adjustX = mainW / 2 - layerW * (centerX or 0.5) * scale
				local adjustY = mainH / 2 - layerH * (centerY or 0.5) * scale

				self.bgState = {layerW = layerW, layerH = layerH, cx = (centerX or 0.5), cy = (centerY or 0.5), scale = scale, mainW = mainW, mainH = mainH}

				-- 3.3.5a: dungeon level <floor> turns "<file>N" into "<file><floor>_N"
				local prefix = (md.floor and md.floor > 0) and (md.file .. md.floor .. "_") or md.file
				for i=1,heightCount do
					for j=1,widthCount do
						local p = (i-1)*widthCount + j
						local t = GetBackground()
						t:SetSize(md.tileW*scale, md.tileH*scale)
						t:ClearAllPoints()
						t:SetPoint("TOPLEFT", self.main.C, "TOPLEFT", adjustX + md.tileW*(j-1)*scale, -(i-1)*md.tileH*scale - adjustY)
						t:SetTexture(prefix .. p)
					end
				end
				return
			end
			local layers = C_Map.GetMapArtLayers(background)
			if layers and layers[1] then
				local layerInfo = layers[1]

				local backData = C_Map.GetMapArtLayerTextures(background,1)

				local widthCount = ceil(layerInfo.layerWidth/layerInfo.tileWidth)
				local heightCount = ceil(layerInfo.layerHeight/layerInfo.tileHeight)

				scale = scale or 1

				local adjustX = self.main:GetWidth() / 2 - layerInfo.layerWidth * (centerX or 0.5) * scale
				local adjustY = self.main:GetHeight() / 2 - layerInfo.layerHeight * (centerY or 0.5) * scale

				self.bgState = {layerW = layerInfo.layerWidth, layerH = layerInfo.layerHeight, cx = (centerX or 0.5), cy = (centerY or 0.5), scale = scale, mainW = self.main:GetWidth(), mainH = self.main:GetHeight()}

				for i=1,heightCount do
					for j=1,widthCount do
						local p = (i-1)*widthCount + j
						local t = GetBackground()

						t:SetSize(layerInfo.tileWidth*scale,layerInfo.tileHeight*scale)
						t:SetPoint("TOPLEFT",adjustX + layerInfo.tileWidth * (j-1) * scale,-(i-1)*layerInfo.tileHeight * scale-adjustY)

						t:SetTexture(backData[p])
					end
				end
			end
		end
	end
	self.SetBackground = SetBackground

	self.SelectMapDropDown = ELib:DropDown(self,260,11):Size(90):Point("TOPLEFT",615,-55):SetText(L.VisualNoteSelectMap.."...")
	self.SelectMapDropDown.Lines = nil
	local maps
	local function SelectMapDropDown_SetValue(_,arg1,arg2)
		ELib:DropDownClose()
		curr_data.lockCX = nil
		curr_data.lockCY = nil
		curr_data.lockScale = nil
		if module.options.chkLockArea then module.options.chkLockArea:SetChecked(false) end
		SetBackground(unpack(arg1))
		curr_map = arg2
		curr_data[2] = arg2
		if maps and maps[arg2] and maps[arg2][1] then
			module.options.SelectMapDropDown:SetText(maps[arg2][1])
		end
	end
	self.SelectMapDropDown.Text:SetFont(self.SelectMapDropDown.Text:GetFont(),8,"")

	local function ZoneNameFromMap(mapID)
		return (C_Map.GetMapInfo(mapID or 0) or {}).name or ("Map ID "..mapID)
	end

	maps = {

		{"None",{}},
		{ICON_TAG_RAID_TARGET_SKULL3 or "white",{"Interface/Buttons/WHITE8X8"}},
		{L.NoteColorBlack:lower(),{{0,0,0,1}}},
		{L.NoteColorGrey:lower(),{{.5,.5,.5,1}}},
		{L.NoteColorGreen:lower(),{{.5,1,.5,1}}},
		{L.NoteColorRed:lower(),{{1,.5,.5,1}}},
		{L.NoteColorBlue:lower(),{{.5,.5,1,1}}},
		{L.NoteColorYellow:lower(),{{1,1,.5,1}}},
		[1000] = {"None WotLK",{}},
		-- ===== WotLK =====
		[1001] = {"Naxxramas 1",{1001}},
		[1002] = {"Naxxramas 2",{1002}},
		[1003] = {"Naxxramas 3",{1003}},
		[1004] = {"Naxxramas 4",{1004}},
		[1005] = {"Naxxramas 5",{1005}},
		[1006] = {"Naxxramas 6",{1006}},
		[1010] = {"Ulduar Overview",{1010}},
		[1011] = {"Ulduar 1",{1011}},
		[1012] = {"Ulduar 2",{1012}},
		[1013] = {"Ulduar 3",{1013}},
		[1014] = {"Ulduar 4",{1014}},
		[1015] = {"Ulduar 5",{1015}},
		[1031] = {"Icecrown Citadel 1",{1031}},
		[1032] = {"Icecrown Citadel 2",{1032}},
		[1033] = {"Icecrown Citadel 3",{1033}},
		[1034] = {"Icecrown Citadel 4",{1034}},
		[1035] = {"Icecrown Citadel 5",{1035}},
		[1036] = {"Icecrown Citadel 6",{1036}},
		[1037] = {"Icecrown Citadel 7",{1037}},
		[1038] = {"Icecrown Citadel 8",{1038}},
		[1050] = {"Onyxia's Lair",{1050}},
		[1051] = {"Trial of the Crusader 1",{1051}},
		[1052] = {"Trial of the Crusader 2",{1052}},
		[1053] = {"Eye of Eternity Overview",{1053}},
		[1054] = {"Eye of Eternity",{1054}},
		[1055] = {"Vault of Archavon",{1055}},
		[1056] = {"Obsidian Sanctum Overview",{1056}},
		[1057] = {"Obsidian Sanctum",{1057}},
		[1058] = {"Ruby Sanctum",{1058}},
		-- ===== TBC =====
		[1070] = {"Karazhan 1",{1070}},
		[1071] = {"Karazhan 2",{1071}},
		[1072] = {"Karazhan 3",{1072}},
		[1073] = {"Karazhan 4",{1073}},
		[1074] = {"Karazhan 5",{1074}},
		[1075] = {"Karazhan 6",{1075}},
		[1076] = {"Karazhan 7",{1076}},
		[1077] = {"Karazhan 8",{1077}},
		[1078] = {"Karazhan 9",{1078}},
		[1079] = {"Karazhan 10",{1079}},
		[1080] = {"Karazhan 11",{1080}},
		[1081] = {"Karazhan 12",{1081}},
		[1082] = {"Karazhan 13",{1082}},
		[1083] = {"Karazhan 14",{1083}},
		[1084] = {"Karazhan 15",{1084}},
		[1085] = {"Karazhan 16",{1085}},
		[1086] = {"Karazhan 17",{1086}},
		[1087] = {"Gruul's Lair",{1087}},
		[1088] = {"Magtheridon's Lair",{1088}},
		[1089] = {"Zul'Aman",{1089}},
		[1090] = {"Serpentshrine Cavern",{1090}},
		[1091] = {"Tempest Keep",{1091}},
		[1092] = {"Battle for Mount Hyjal",{1092}},
		[1093] = {"Black Temple Overview",{1093}},
		[1094] = {"Black Temple 1",{1094}},
		[1095] = {"Black Temple 2",{1095}},
		[1096] = {"Black Temple 3",{1096}},
		[1097] = {"Black Temple 4",{1097}},
		[1098] = {"Black Temple 5",{1098}},
		[1099] = {"Black Temple 6",{1099}},
		[1100] = {"Black Temple 7",{1100}},
		[1107] = {"Sunwell Plateau Overview",{1107}},
		[1108] = {"Sunwell Plateau",{1108}},
		-- ===== Classic =====
		[1120] = {"Molten Core",{1120}},
		[1121] = {"Blackwing Lair 1",{1121}},
		[1122] = {"Blackwing Lair 2",{1122}},
		[1123] = {"Blackwing Lair 3",{1123}},
		[1124] = {"Blackwing Lair 4",{1124}},
		[1125] = {"Zul'Gurub",{1125}},
		[1126] = {"Ruins of Ahn'Qiraj",{1126}},
		[1127] = {"Temple of Ahn'Qiraj",{1127}},
	}


	local mapsSorted = {
		1,
		{L.NoteColor,2,3,4,5,6,7,8},
	}
	if ExRT.isLK then
		ExRT.F.table_add(mapsSorted,{
			1058,
			{"Icecrown Citadel", 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038},
			{"Trial of the Crusader", 1051, 1052},
			1050,
			{"Ulduar", 1010, 1011, 1012, 1013, 1014, 1015},
			{"The Eye of Eternity", 1053, 1054},
			{"The Obsidian Sanctum", 1056, 1057},
			{"Naxxramas", 1001, 1002, 1003, 1004, 1005, 1006},
			{"Sunwell Plateau", 1107, 1108},
			1089,
			{"Black Temple", 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100},
			1092,
			1091,
			1090,
			1088,
			1087,
			{"Karazhan", 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078,
			             1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086},
			1127,
			1126,
			1125,
			{"Blackwing Lair", 1121, 1122, 1123, 1124},
			1120,
		})
	end
	local raidNameToMapID = {
		["Icecrown Citadel"] = 631,
		["Ulduar"] = 603,
		["Trial of the Crusader"] = 649,
		["Naxxramas"] = 533,
		["The Eye of Eternity"] = 616,
		["The Obsidian Sanctum"] = 615,
		["Sunwell Plateau"] = 580,
		["Black Temple"] = 564,
		["Karazhan"] = 532,
		["Blackwing Lair"] = 469,
		["Ruby Sanctum"] = 724,
		["Vault of Archavon"] = 624,
		["Onyxia's Lair"] = 249,
		["Battle for Mount Hyjal"] = 534,
		["Tempest Keep"] = 550,
		["Serpentshrine Cavern"] = 548,
		["Magtheridon's Lair"] = 544,
		["Gruul's Lair"] = 565,
		["Zul'Aman"] = 568,
		["Temple of Ahn'Qiraj"] = 531,
		["Molten Core"] = 409,
		["Zul'Gurub"] = 309,
		["Ruins of Ahn'Qiraj"] = 509,
	}
	local function visMapNameToMapID(name)
		if type(name) ~= "string" then return nil end
		if raidNameToMapID[name] then return raidNameToMapID[name] end
		local stripped = name:gsub(" Overview$",""):gsub(" %d+$","")
		return raidNameToMapID[stripped]
	end
	local function visIconForName(name)
		local mapID = visMapNameToMapID(name)
		if mapID and ExRT.GDB.RaidIconByMapID then
			return ExRT.GDB.RaidIconByMapID[mapID]
		end
		return nil
	end
	for i=1,#mapsSorted do
		local p = mapsSorted[i]
		if type(p)=='table' then
			local subList = {}
			for j=2,#p do
				if type(p[j])=="string" then
					subList[#subList + 1] = {
						text = p[j],
						isTitle = true,
					}
				else
					local map = maps[ p[j] ]
					if map then
						subList[#subList + 1] = {
							text = maps[ p[j] ][1],
							func = SelectMapDropDown_SetValue,
							arg1 = maps[ p[j] ][2],
							arg2 = mapsSorted[i][j],
						}
					else
						print('error','map '..p[j]..' not found')
					end
				end
			end
			self.SelectMapDropDown.List[#self.SelectMapDropDown.List + 1] = {
				text = p[1],
				subMenu = subList,
				icon = visIconForName(p[1]),
			}
		else
			self.SelectMapDropDown.List[#self.SelectMapDropDown.List + 1] = {
				text = maps[p][1],
				func = SelectMapDropDown_SetValue,
				arg1 = maps[p][2],
				arg2 = mapsSorted[i],
				icon = visIconForName(maps[p][1]),
			}
		end
	end
	function self:SetPredefinedMap(pos)
		local mapPos = maps[pos] and pos or 1
		local args = maps[mapPos][2]
		if curr_data and curr_data.lockScale then
			SetBackground(args[1], curr_data.lockCX, curr_data.lockCY, curr_data.lockScale)
		else
			SetBackground(unpack(args))
		end
		curr_map = mapPos
		if maps[curr_map] and maps[curr_map][1] then
			module.options.SelectMapDropDown:SetText(maps[curr_map][1])
		end
	end
	function self:SetDebugMap(...)
		SetBackground(...)
	end


	local function GetDot()
		local dot
		for d,_ in pairs(dots) do
			if not d:IsShown() then
				dot = d
				break
			end
		end
		if not dot then
			dot = self.main.C:CreateTexture(nil,"ARTWORK",nil,2)
			dot:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
			dots[dot] = true
		end
		dot:Show()
		return dot
	end

	local ignoreLimitations
	local function AddDot(x,y)
		x = floor(x + 0.5)
		y = floor(y + 0.5)
		if x > self.main:GetWidth() or y > self.main:GetHeight() then
			return
		end
		if not ignoreLimitations then
			for i=1,#dots_pos_X do
				local x2,y2 = dots_pos_X[i],dots_pos_Y[i]

				local dX = (x - x2)
				local dY = (y - y2)
				if dots_COLOR[i] == curr_color and (dX * dX + dY * dY) <= half_dot_size_sq then
					return
				end
			end
		end

		local d = GetDot()
		d:SetSize(dot_size,dot_size)
		d:SetPoint("CENTER",self.main.C,"TOPLEFT", x, -y)
		d:SetAlpha(1)
		d:SetVertexColor(unpack(colors[curr_color]))
		local p = #dots_pos_X+1
		dots_pos_X[p] = x
		dots_pos_Y[p] = y
		dots_SIZE[p] = dot_size
		dots_COLOR[p] = curr_color
		dots_GROUP[p] = curr_group
		dots_OBJ[p] = d
		if ignoreLimitations then
			dots_SYNC[p] = true
		else
			special_counter = special_counter + 1
		end
	end

	function self:AddDot(x,y,color,size)
		local a,b = dot_size,curr_color
		dot_size = size
		curr_color = color
		ignoreLimitations = true
		AddDot(x,y)
		dot_size = a
		curr_color = b
		ignoreLimitations = nil
	end
	function self:NextGroup()
		curr_group = curr_group + 1
	end

	local function ProcessDot(fromX,fromY,toX,toY,stackFix)
		if stackFix > 300 then
			return
		end
		local dX = (fromX - toX)
		local dY = (fromY - toY)
		local dist = sqrt(dX * dX + dY * dY)

		local k = 2 / max(1,dist)
		local x = fromX + (toX - fromX) * k
		local y = fromY + (toY - fromY) * k

		if (fromX == toX and fromY == toY) or (dX == 0 and dY == 0) then
			AddDot(toX,toY)
			return
		elseif (fromX < toX and x > toX) or (fromX > toX and x < toX) then
			AddDot(toX,toY)
			return
		else
			AddDot(x,y)
			ProcessDot(x,y,toX,toY,stackFix+1)
			return
		end
	end


	local function GetLine()
		local line
		for l,_ in pairs(lines) do
			if not l:IsShown() then
				line = l
				break
			end
		end
		if not line then
			line = self.main.C:CreateLine(nil,"ARTWORK",nil,2)
			line:SetTexture("interface/buttons/white8x8")
			lines[line] = true
		end
		line:Show()
		return line
	end


	local function LockedImgSetState(self,state)
		if state then
			self:SetTexCoord(.625,.6875,.5,.625)
			self:SetVertexColor(1,.5,.5,1)
		else
			self:SetTexCoord(.6875,.75,.5,.625)
			self:SetVertexColor(.5,1,.5,1)
		end
	end

	local function SetLockedImg(obj,group,isHide)
		local img
		for l,_ in pairs(locked_img) do
			if l.g == group then
				img = l
				break
			end
		end
		if isHide then
			if img then
				img:Hide()
				img.g = nil
			end
			return
		end
		if not img then
			for l,_ in pairs(locked_img) do
				if not l:IsShown() then
					img = l
					break
				end
			end
		end
		if not img then
			img = self.main.C:CreateTexture(nil,"ARTWORK",nil,7)
			img:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
			img.SetState = LockedImgSetState
			locked_img[img] = true
		end
		img:ClearAllPoints()
		img:SetPoint("CENTER",obj,0,0)
		img:SetSize(30,30)
		img.o = obj
		img.g = group
		img:SetState(lockedGroups[group])
		img:Show()
		return img
	end
	local function UpdateLockedImg(group)
		for l,_ in pairs(locked_img) do
			if l.g == group then
				l:SetState(lockedGroups[group])
			end
		end
	end
	function LockedImgHideAll()
		for l,_ in pairs(locked_img) do
			if l:IsShown() then
				l:Hide()
			end
			l.g = nil
		end
	end


	local function GetIcon()
		local icon
		for i,_ in pairs(icons) do
			if not i:IsShown() then
				icon = i
				break
			end
		end
		if not icon then
			icon = self.main.C:CreateTexture(nil,"ARTWORK",nil,-1)
			icons[icon] = true
		end
		local t = icons_list[curr_icon]
		if type(t) == 'table' then
			icon:SetTexCoord(select(2,unpack(t)))
			icon:SetTexture(t[1])
		else
			icon:SetTexCoord(0,1,0,1)
			icon:SetTexture(t)
		end
		icon:SetAlpha(1)
		icon:Show()
		return icon
	end

	local function ProcessIcon(fromX,fromY,toX,toY)
		local I = nil
		local p = nil
		for i=#icon_pos_X,1,-1 do
			if icon_GROUP[i] == curr_group then
				I = icon_OBJ[i]
				p = i
				break
			elseif icon_GROUP[i] < curr_group then
				break
			end
		end

		if not I then
			I = GetIcon()
		end
		I:SetPoint("CENTER",self.main.C,"TOPLEFT",fromX,-fromY)
		local size = max(max(6,toX - fromX),max(6,toY - fromY)) * 2
		I:SetSize(size,size)

		if not p then
			p = #icon_pos_X+1
		end
		icon_pos_X[p] = fromX
		icon_pos_Y[p] = fromY
		icon_SIZE[p] = size
		icon_OBJ[p] = I
		icon_TYPE[p] = curr_icon
		icon_GROUP[p] = curr_group
	end

	function self:AddIcon(x,y,type,size)
		local a = curr_icon
		curr_icon = type

		if icons_list[curr_icon] then
			local I = GetIcon()
			I:SetPoint("CENTER",self.main.C,"TOPLEFT",x,-y)
			I:SetSize(size,size)

			local p = #icon_pos_X+1

			icon_pos_X[p] = x
			icon_pos_Y[p] = y
			icon_SIZE[p] = size
			icon_OBJ[p] = I
			icon_TYPE[p] = curr_icon
			icon_SYNC[p] = true
			icon_GROUP[p] = curr_group
		end

		curr_icon = a
	end


	local function GetText()
		local text
		for t,_ in pairs(texts) do
			if not t:IsShown() then
				text = t
				break
			end
		end
		if not text then
			text = self.main.C:CreateFontString(nil,"ARTWORK","GameFontNormal",4)
			text:SetFont(text:GetFont(),12,"OUTLINE")
			texts[text] = true
		end
		text:SetTextColor(unpack(colors[curr_color]))
		text:SetAlpha(1)
		text:SetText(curr_text)
		text:Show()
		return text
	end

	local function ProcessText(fromX,fromY,toX,toY)
		local T = nil
		local p = nil
		for i=#text_pos_X,1,-1 do
			if text_GROUP[i] == curr_group then
				T = text_OBJ[i]
				p = i
				break
			elseif text_GROUP[i] < curr_group then
				break
			end
		end

		if not T then
			T = GetText()
		end
		T:SetPoint("CENTER",self.main.C,"TOPLEFT",fromX,-fromY)
		local size = max(10,toX - fromX)
		T:SetFont(T:GetFont(),size,"OUTLINE")

		if not p then
			p = #text_pos_X+1
		end
		text_pos_X[p] = fromX
		text_pos_Y[p] = fromY
		text_SIZE[p] = size
		text_OBJ[p] = T
		text_DATA[p] = curr_text
		text_COLOR[p] = curr_color
		text_GROUP[p] = curr_group
	end

	function self:AddText(x,y,text,color,size)
		local a,b = curr_text,curr_color
		curr_text = text
		curr_color = color

		local T = GetText()
		T:SetPoint("CENTER",self.main.C,"TOPLEFT",x,-y)
		T:SetFont(T:GetFont(),size,"OUTLINE")

		local p = #text_pos_X+1

		text_pos_X[p] = x
		text_pos_Y[p] = y
		text_SIZE[p] = size
		text_OBJ[p] = T
		text_DATA[p] = curr_text
		text_COLOR[p] = curr_color
		text_SYNC[p] = true
		text_GROUP[p] = curr_group

		curr_text = a
		curr_color = b
	end


	local function GetDotObj()
		local dot
		for d,_ in pairs(objects) do
			if not d:IsShown() then
				dot = d
				break
			end
		end
		if not dot then
			dot = self.main.C:CreateTexture(nil,"ARTWORK",nil,1)
			dot:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
			dot.isC = true
			objects[dot] = true
		end
		if not dot.isC then
			dot:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\circle256")
			dot.isC = true
		end
		dot:SetPoint("CENTER",self.main.C,"TOPLEFT",-1000,1000)
		dot:Show()
		return dot
	end

	local function ProcessObject(fromX,fromY,toX,toY)
		for o,_ in pairs(objects) do
			if o.g == curr_group then
				o:Hide()
			end
		end
		for l,_ in pairs(lines) do
			if l.g == curr_group then
				l:Hide()
			end
		end
		local size
		if curr_object == 1 then
			size = min(max(10,toX - fromX),max(10,toY - fromY)) * 2
			local circleLen = 2*PI*size
			local len = ceil(circleLen / (dot_size / 2))
			for i=0,len-1 do
				local x = fromX + size * math.cos(2*PI/len*i)
				local y = fromY + size * math.sin(2*PI/len*i)

				local o = GetDotObj()
				o:SetPoint("CENTER",self.main.C,"TOPLEFT",x,-y)
				o.g = curr_group
				o.t = nil

				o:SetSize(dot_size,dot_size)
				o:SetAlpha(1)
				o:SetVertexColor(unpack(colors[curr_color]))
			end
		elseif curr_object == 2 then
			size = min(max(10,toX - fromX),max(10,toY - fromY)) * 2

			local o = GetDotObj()
			o:SetPoint("CENTER",self.main.C,"TOPLEFT",fromX,-fromY)
			o.g = curr_group
			o.t = curr_trans / 100

			o:SetSize(size,size)
			o:SetVertexColor(unpack(colors[curr_color]))
			o:SetAlpha(curr_trans / 100)
		elseif curr_object == 3 or curr_object == 5 or curr_object == 6 then
			fromX,fromY = max(0,min(800,fromX)), max(0,min(550,fromY))
			toX,toY = max(0,min(800,toX)), max(0,min(550,toY))

			size = dot_size

			local l = GetLine()

			l:SetStartPoint("TOPLEFT",self.main.C,fromX,-fromY)
			l:SetEndPoint("TOPLEFT",self.main.C,toX,-toY)

			l.g = curr_group
			l.t = nil

			l:SetThickness(size)
			l:SetAlpha(1)

			if curr_object == 3 or curr_object == 5 then
				l:SetColorTexture(unpack(colors[curr_color]))
				l:SetVertexColor(1,1,1,1)

				if curr_object == 5 then
					local ll,lr = GetLine(), GetLine()

					ll:SetColorTexture(unpack(colors[curr_color]))
					ll:SetVertexColor(1,1,1,1)
					lr:SetColorTexture(unpack(colors[curr_color]))
					lr:SetVertexColor(1,1,1,1)

					ll.g = curr_group
					lr.g = curr_group

					ll:SetThickness(size)
					ll:SetAlpha(1)
					lr:SetThickness(size)
					lr:SetAlpha(1)

					ll:SetEndPoint("TOPLEFT",self.main.C,toX,-toY)
					lr:SetEndPoint("TOPLEFT",self.main.C,toX,-toY)

					local angle = 20 * (PI/180)
					local rotatedX = math.cos(angle) * (fromX - toX) * 0.2 - math.sin(angle) * (fromY - toY) * 0.2 + toX
					local rotatedY = math.sin(angle) * (fromX - toX) * 0.2 + math.cos(angle) * (fromY - toY) * 0.2 + toY

					ll:SetStartPoint("TOPLEFT",self.main.C,rotatedX,-rotatedY)

					local angle = -20 * (PI/180)
					local rotatedX = math.cos(angle) * (fromX - toX) * 0.2 - math.sin(angle) * (fromY - toY) * 0.2 + toX
					local rotatedY = math.sin(angle) * (fromX - toX) * 0.2 + math.cos(angle) * (fromY - toY) * 0.2 + toY

					lr:SetStartPoint("TOPLEFT",self.main.C,rotatedX,-rotatedY)
				end
			elseif curr_object == 6 then

				l:SetTexture("Interface/AddOns/"..GlobalAddonName.."/media/lineGapped","REPEAT")
				l:SetVertexColor(unpack(colors[curr_color]))

				local dX = (fromX - toX)
				local dY = (fromY - toY)
				local dist = sqrt(dX * dX + dY * dY)

				local c = dist / 1024 * 4

				l:SetTexCoord(0,c,0,1)
			end
		elseif curr_object == 4 then
			size = curr_trans

			local o = GetDotObj()
			o:SetTexture()
			o:SetColorTexture(unpack(colors[curr_color]))
			o.isC = nil

			local width,height = max(5,toX-fromX),max(5,toY-fromY)
			if IsShiftKeyDown() then
				width = max(width,height)
				height = width
			end
			toX = fromX + width
			toY = fromY + height

			o:SetPoint("CENTER",self.main.C,"TOPLEFT",fromX+width/2,-fromY-height/2)
			o.g = curr_group
			o.t = curr_trans / 100

			o:SetSize(width,height)
			o:SetAlpha(curr_trans / 100)
		end

		local p
		for i=#object_pos_X,1,-1 do
			if object_GROUP[i] == curr_group then
				p = i
				break
			elseif object_GROUP[i] < curr_group then
				break
			end
		end
		if not p then
			p = #object_pos_X+1
		end
		object_pos_X[p] = fromX
		object_pos_Y[p] = fromY
		object_SIZE[p] = size
		object_TYPE[p] = curr_object
		object_GROUP[p] = curr_group
		object_COLOR[p] = curr_color
		if curr_object == 1 then
			object_DATA1[p] = dot_size
			object_DATA2[p] = 0
		elseif curr_object == 2 then
			object_DATA1[p] = curr_trans
			object_DATA2[p] = 0
		elseif curr_object == 3 or curr_object == 5 or curr_object == 6 then
			object_DATA1[p] = toX
			object_DATA2[p] = toY
		elseif curr_object == 4 then
			object_DATA1[p] = toX
			object_DATA2[p] = toY
		end

		return p
	end

	function self:AddObject(x,y,type,size,color,data1,data2)
		local a,b,c,d = curr_object,dot_size,curr_color,curr_trans
		curr_object = type
		dot_size = type == 1 and data1 or size
		curr_color = color
		curr_trans = type == 4 and size or data1

		local p
		if type == 3 or type == 5 or type == 6 then
			p = ProcessObject(x,y,data1,data2)
		elseif type == 4 then
			p = ProcessObject(x,y,data1,data2)
		else
			p = ProcessObject(x,y,x+size/2,y+size/2)
		end
		object_SYNC[p] = true

		curr_object = a
		dot_size = b
		curr_color = c
		curr_trans = d
	end


	local function GetImage()
		local image
		for i,_ in pairs(images) do
			if not i:IsShown() then
				image = i
				break
			end
		end
		if not image then
			image = self.main.C:CreateTexture(nil,"ARTWORK",nil,-2)
			images[image] = true
		end
		image:SetAlpha(curr_trans / 100)
		image:SetTexture(curr_imgpath)
		image:Show()
		return image
	end

	local function ProcessImage(fromX,fromY,toX,toY)
		local I = nil
		local p = nil
		for i=#image_pos_X,1,-1 do
			if image_GROUP[i] == curr_group then
				I = image_OBJ[i]
				p = i
				break
			elseif image_GROUP[i] < curr_group then
				break
			end
		end

		if not I then
			I = GetImage()
		end

		local revHor,revVer
		local width = max(2,abs(toX - fromX))
		local height = max(2,abs(toY - fromY))
		if toX < fromX then
			revHor = true
		end
		if toY < fromY then
			revVer = true
		end
		if abs(fromX - toX) < 2 then
			toX = fromX + (revHor and -2 or 2)
		end
		if abs(fromY - toY) < 2 then
			toY = fromY + (revVer and -2 or 2)
		end
		if IsShiftKeyDown() then
			if width == height then

			elseif width < height then
				toY = fromY + (revVer and -1 or 1)*abs(toX - fromX)
				height = max(2,abs(fromY - toY))
			else
				toX = fromX + (revHor and -1 or 1)*abs(toY - fromY)
				width = max(2,abs(toX - fromX))
			end
		end

		local layer = -2
		local sq = abs(toX - fromX)*abs(fromY - toY)
		if sq > 350000 then
			layer = -6
		elseif sq > 100000 then
			layer = -5
		elseif sq > 50000 then
			layer = -4
		elseif sq > 20000 then
			layer = -3
		end

		I:SetPoint("TOPLEFT",self.main.C,"TOPLEFT",revHor and toX or fromX,-(revVer and toY or fromY))
		I:SetSize(width,height)
		I:SetTexCoord(revHor and 1 or 0,revHor and 0 or 1,revVer and 1 or 0,revVer and 0 or 1)
		I:SetDrawLayer("ARTWORK",layer)
		I.t = curr_trans / 100

		if not p then
			p = #image_pos_X+1
		end
		image_pos_X[p] = fromX
		image_pos_Y[p] = fromY
		image_pos_X2[p] = toX
		image_pos_Y2[p] = toY
		image_path[p] = curr_imgpath
		image_alpha[p] = curr_trans
		image_OBJ[p] = I
		image_GROUP[p] = curr_group
	end

	function self:AddImage(x,y,x2,y2,path,alpha)
		local a,b = curr_imgpath,curr_trans
		curr_imgpath = path
		curr_trans = alpha

		local I = GetImage()

		local revHor,revVer
		local width = max(2,x2 - x)
		local height = max(2,y2 - y)
		if x2 < x then
			revHor = true
			width = max(2,x - x2)
		end
		if y2 < y then
			revVer = true
			height = max(2,y - y2)
		end
		if abs(x - x2) < 2 then
			x2 = x + (revHor and -2 or 2)
		end
		if abs(y - y2) < 2 then
			y2 = y + (revVer and -2 or 2)
		end

		local layer = -2
		local sq = abs(x - x2)*abs(y - y2)
		if sq > 350000 then
			layer = -6
		elseif sq > 100000 then
			layer = -5
		elseif sq > 50000 then
			layer = -4
		elseif sq > 20000 then
			layer = -3
		end

		I:SetPoint("TOPLEFT",self.main.C,"TOPLEFT",revHor and x2 or x,-(revVer and y2 or y))
		I:SetSize(width,height)
		I:SetTexCoord(revHor and 1 or 0,revHor and 0 or 1,revVer and 1 or 0,revVer and 0 or 1)
		I:SetDrawLayer("ARTWORK",layer)
		I.t = curr_trans / 100

		local p = #image_pos_X+1

		image_pos_X[p] = x
		image_pos_Y[p] = y
		image_pos_X2[p] = x2
		image_pos_Y2[p] = y2
		image_path[p] = curr_imgpath
		image_alpha[p] = curr_trans
		image_OBJ[p] = I
		image_GROUP[p] = curr_group

		curr_imgpath = a
		curr_trans = b
	end


	local movePrevX,movePrevY
	local moveObjects = {}
	local function ProcessMove(fromX,fromY,toX,toY)
		if movePrevX ~= fromX or movePrevY ~= fromY then
			wipe(moveObjects)
			movePrevX = fromX
			movePrevY = fromY

			for i=1,#dots_pos_X do
				local x2,y2 = dots_pos_X[i],dots_pos_Y[i]

				local dX = (fromX - x2)
				local dY = (fromY - y2)
				if sqrt(dX * dX + dY * dY) <= (dots_SIZE[i]/2) and not moveObjects[ dots_GROUP[i] ] then
					moveObjects[ dots_GROUP[i] ] = {
						type = 1,
					}
					local all_obj = moveObjects[ dots_GROUP[i] ]
					for j=1,#dots_pos_X do
						if dots_GROUP[i] == dots_GROUP[j] then
							all_obj[#all_obj+1] = {
								obj = dots_OBJ[j],
								index = j,
								x_table = dots_pos_X,
								y_table = dots_pos_Y,
								x = dots_pos_X[j],
								y = dots_pos_Y[j],
							}
						end
					end
				end
			end
			for i=1,#icon_pos_X do
				local x2,y2 = icon_pos_X[i],icon_pos_Y[i]

				local dX = (fromX - x2)
				local dY = (fromY - y2)
				if sqrt(dX * dX + dY * dY) <= (icon_SIZE[i]/2) then
					moveObjects[ icon_GROUP[i] ] = {
						type = 2,
						index = i,
						x_table = icon_pos_X,
						y_table = icon_pos_Y,
						obj = icon_OBJ[i],
						x = x2,
						y = y2,
					}
				end
			end
			for i=1,#text_pos_X do
				local obj = text_OBJ[i]
				if MouseIsOver(obj) then
					moveObjects[ text_GROUP[i] ] = {
						type = 3,
						index = i,
						x_table = text_pos_X,
						y_table = text_pos_Y,
						obj = text_OBJ[i],
						x = text_pos_X[i],
						y = text_pos_Y[i],
					}
				end
			end
			for i=1,#object_pos_X do
				local x2,y2 = object_pos_X[i],object_pos_Y[i]

				if object_TYPE[i] == 1 then
					local dX = (fromX - x2)
					local dY = (fromY - y2)
					local d = sqrt(dX * dX + dY * dY)
					if d <= (object_SIZE[i] + object_DATA1[i] / 2) and d >= (object_SIZE[i] - object_DATA1[i] / 2) then
						moveObjects[ object_GROUP[i] ] = {
							type = 4,
							index = i,
							x_table = object_pos_X,
							y_table = object_pos_Y,
							x = object_pos_X[i],
							y = object_pos_Y[i],
						}
						local all_obj = moveObjects[ object_GROUP[i] ]
						for d,_ in pairs(objects) do
							if d.g == object_GROUP[i] then
								all_obj[#all_obj+1] = {
									obj = d,
									x = select(4,d:GetPoint()),
									y = -select(5,d:GetPoint()),
								}
							end
						end
					end
				elseif object_TYPE[i] == 2 then
					local dX = (fromX - x2)
					local dY = (fromY - y2)
					if sqrt(dX * dX + dY * dY) <= (object_SIZE[i] / 2) then
						moveObjects[ object_GROUP[i] ] = {
							type = 5,
							index = i,
							x_table = object_pos_X,
							y_table = object_pos_Y,
							x = object_pos_X[i],
							y = object_pos_Y[i],
						}
						for o,_ in pairs(objects) do
							if o.g == object_GROUP[i] then
								moveObjects[ object_GROUP[i] ].obj = o
								break
							end
						end
					end
				elseif object_TYPE[i] == 3 or object_TYPE[i] == 5 or object_TYPE[i] == 6 then
					if IsDotIn(fromX,fromY,x2,object_DATA1[i],object_DATA1[i],x2,y2-object_SIZE[i],object_DATA2[i]-object_SIZE[i],object_DATA2[i]+object_SIZE[i],y2+object_SIZE[i]) or
					IsDotIn(fromX,fromY,x2-object_SIZE[i],x2+object_SIZE[i],object_DATA1[i]+object_SIZE[i],object_DATA1[i]-object_SIZE[i],y2,y2,object_DATA2[i],object_DATA2[i]) then
						moveObjects[ object_GROUP[i] ] = {
							type = 6,
							index = i,
							x_table = object_pos_X,
							y_table = object_pos_Y,
							x = object_pos_X[i],
							y = object_pos_Y[i],
							x2_table = object_DATA1,
							y2_table = object_DATA2,
							x2 = object_DATA1[i],
							y2 = object_DATA2[i],
						}
						local all_obj = moveObjects[ object_GROUP[i] ]
						for d,_ in pairs(lines) do
							if d.g == object_GROUP[i] then
								all_obj[#all_obj+1] = {
									obj = d,
								}
							end
						end
					end
				elseif object_TYPE[i] == 4 then
					if fromX >= x2 and fromX <= object_DATA1[i] and fromY >= y2 and fromY <= object_DATA2[i] then
						moveObjects[ object_GROUP[i] ] = {
							type = 7,
							index = i,
							x_table = object_pos_X,
							y_table = object_pos_Y,
							x = object_pos_X[i],
							y = object_pos_Y[i],
							x2_table = object_DATA1,
							y2_table = object_DATA2,
							x2 = object_DATA1[i],
							y2 = object_DATA2[i],
						}
						for o,_ in pairs(objects) do
							if o.g == object_GROUP[i] then
								moveObjects[ object_GROUP[i] ].obj = o
								break
							end
						end
					end
				end
			end
			for i=1,#image_pos_X do
				local xg1,yg1 = image_pos_X, image_pos_Y
				local xg2,yg2 = image_pos_X2, image_pos_Y2

				local x2,y2 = image_pos_X[i],image_pos_Y[i]
				local x3,y3 = image_pos_X2[i],image_pos_Y2[i]

				if x3 < x2 then
					x2,x3 = x3,x2
					xg1,xg2 = xg2,xg1
				end
				if y3 < y2 then
					y2,y3 = y3,y2
					yg1,yg2 = yg2,yg1
				end

				if fromX >= x2 and fromX <= x3 and fromY >= y2 and fromY <= y3 then
					moveObjects[ image_GROUP[i] ] = {
						type = 8,
						index = i,
						x_table1 = xg1,
						y_table1 = yg1,
						x_table2 = xg2,
						y_table2 = yg2,
						obj = image_OBJ[i],
						x1 = x2,
						y1 = y2,
						x2 = x3,
						y2 = y3,
					}
				end
			end
		end

		local diffX,diffY = toX - fromX, toY - fromY
		for group,data in pairs(moveObjects) do
			if lockedGroups[group] then

			elseif data.type == 1 then
				local a_data = data
				for i=1,#a_data do
					local data = a_data[i]
					data.x_table[ data.index ] = max(0,min(800,data.x + diffX))
					data.y_table[ data.index ] = max(0,min(550,data.y + diffY))
					data.obj:SetPoint("CENTER",self.main.C,"TOPLEFT",data.x_table[ data.index ],-data.y_table[ data.index ])
				end
			elseif data.type == 2 or data.type == 3 or data.type == 5 then
				data.x_table[ data.index ] = max(0,min(800,data.x + diffX))
				data.y_table[ data.index ] = max(0,min(550,data.y + diffY))
				data.obj:SetPoint("CENTER",self.main.C,"TOPLEFT",data.x_table[ data.index ],-data.y_table[ data.index ])
			elseif data.type == 4 then
				data.x_table[ data.index ] = max(0,min(800,data.x + diffX))
				data.y_table[ data.index ] = max(0,min(550,data.y + diffY))

				local a_data = data
				for i=1,#a_data do
					local data = a_data[i]
					data.obj:SetPoint("CENTER",self.main.C,"TOPLEFT",data.x + diffX,-(data.y + diffY))
				end
			elseif data.type == 6 then
				local x1,y1 = max(0,min(800,data.x + diffX)), max(0,min(550,data.y + diffY))
				local x2,y2 = max(0,min(800,data.x2 + diffX)), max(0,min(550,data.y2 + diffY))

				data.x_table[ data.index ] = x1
				data.y_table[ data.index ] = y1
				data.x2_table[ data.index ] = x2
				data.y2_table[ data.index ] = y2

				local a_data = data
				for i=1,#a_data do
					local obj_data = a_data[i]
					obj_data.obj:SetStartPoint("TOPLEFT",self.main.C,x1,-y1)
					obj_data.obj:SetEndPoint("TOPLEFT",self.main.C,x2,-y2)
				end
			elseif data.type == 7 then
				data.x_table[ data.index ] = max(0,min(800,data.x + diffX))
				data.y_table[ data.index ] = max(0,min(550,data.y + diffY))
				data.x2_table[ data.index ] = max(0,min(800,data.x2 + diffX))
				data.y2_table[ data.index ] = max(0,min(550,data.y2 + diffY))

				local width,height = max(5,data.x2_table[ data.index ]-data.x_table[ data.index ]),max(5,data.y2_table[ data.index ]-data.y_table[ data.index ])
				data.obj:SetPoint("CENTER",self.main.C,"TOPLEFT",data.x_table[ data.index ]+width/2,-data.y_table[ data.index ]-height/2)
				data.obj:SetSize(width,height)
			elseif data.type == 8 then
				data.x_table1[ data.index ] = data.x1 + diffX
				data.y_table1[ data.index ] = data.y1 + diffY
				data.x_table2[ data.index ] = data.x2 + diffX
				data.y_table2[ data.index ] = data.y2 + diffY

				local width,height = max(2,data.x_table2[ data.index ]-data.x_table1[ data.index ]),max(2,data.y_table2[ data.index ]-data.y_table1[ data.index ])
				data.obj:SetPoint("TOPLEFT",self.main.C,"TOPLEFT",data.x_table1[ data.index ],-data.y_table1[ data.index ])
				data.obj:SetSize(width,height)
			end
		end
	end


	local CheckAlpha

	local prevX,prevY
	local function DotsUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		ProcessDot(prevX or x,prevY or y,x,y,1)
		prevX,prevY = x,y
	end

	local function IconsUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if not prevX then
			prevX,prevY = x,y
		end
		ProcessIcon(prevX,prevY,x,y)
	end

	local function TextsUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if not prevX then
			prevX,prevY = x,y
		end
		ProcessText(prevX,prevY,x,y)
	end

	local function ObjectsUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if not prevX then
			prevX,prevY = x,y
		end
		ProcessObject(prevX,prevY,x,y)
	end

	local function MoveUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if not prevX then
			prevX,prevY = x,y
		end
		ProcessMove(prevX,prevY,x,y)
	end

	local function ImageUpdate(self,elapsed)
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate",CheckAlpha)
			return
		end
		local x,y = ExRT.F.GetCursorPos(self)
		if not prevX then
			prevX,prevY = x,y
		end
		ProcessImage(prevX,prevY,x,y)
	end

	local groups_alpha_now,groups_alpha_pending = {},{}

	function IsDotIn(pX,pY,point1x,point2x,point3x,point4x,point1y,point2y,point3y,point4y)
		local D1 = (pX - point1x) * (point2y - point1y) - (pY - point1y) * (point2x - point1x)
		local D2 = (pX - point2x) * (point3y - point2y) - (pY - point2y) * (point3x - point2x)
		local D3 = (pX - point3x) * (point4y - point3y) - (pY - point3y) * (point4x - point3x)
		local D4 = (pX - point4x) * (point1y - point4y) - (pY - point4y) * (point1x - point4x)

		return (D1 < 0 and D2 < 0 and D3 < 0 and D4 < 0) or (D1 > 0 and D2 > 0 and D3 > 0 and D4 > 0)
	end

	local groupsUnderCursor = {}
	local function UpdateGroupsUnderCursor(x,y)
		for k,v in pairs(groupsUnderCursor) do
			groupsUnderCursor[k] = nil
		end

		for i=1,#dots_pos_X do
			local x2,y2 = dots_pos_X[i],dots_pos_Y[i]

			local dX = (x - x2)
			local dY = (y - y2)
			if sqrt(dX * dX + dY * dY) <= (dots_SIZE[i]/2) then
				groupsUnderCursor[ dots_GROUP[i] ] = true
			end
		end
		for i=1,#icon_pos_X do
			local x2,y2 = icon_pos_X[i],icon_pos_Y[i]

			local dX = (x - x2)
			local dY = (y - y2)
			if sqrt(dX * dX + dY * dY) <= (icon_SIZE[i]/2) then
				groupsUnderCursor[ icon_GROUP[i] ] = true
			end
		end
		for i=1,#text_pos_X do
			local obj = text_OBJ[i]
			if MouseIsOver(obj) then
				groupsUnderCursor[ text_GROUP[i] ] = true
			end
		end
		for i=1,#object_pos_X do
			local x2,y2 = object_pos_X[i],object_pos_Y[i]

			if object_TYPE[i] == 1 then
				local dX = (x - x2)
				local dY = (y - y2)
				local d = sqrt(dX * dX + dY * dY)
				if d <= (object_SIZE[i] + object_DATA1[i] / 2) and d >= (object_SIZE[i] - object_DATA1[i] / 2) then
					groupsUnderCursor[ object_GROUP[i] ] = true
				end
			elseif object_TYPE[i] == 2 then
				local dX = (x - x2)
				local dY = (y - y2)
				if sqrt(dX * dX + dY * dY) <= (object_SIZE[i] / 2) then
					groupsUnderCursor[ object_GROUP[i] ] = true
				end
			elseif object_TYPE[i] == 3 or object_TYPE[i] == 5 or object_TYPE[i] == 6 then
				if IsDotIn(x,y,x2,object_DATA1[i],object_DATA1[i],x2,y2-object_SIZE[i],object_DATA2[i]-object_SIZE[i],object_DATA2[i]+object_SIZE[i],y2+object_SIZE[i]) then
					groupsUnderCursor[ object_GROUP[i] ] = true
				elseif IsDotIn(x,y,x2-object_SIZE[i],x2+object_SIZE[i],object_DATA1[i]+object_SIZE[i],object_DATA1[i]-object_SIZE[i],y2,y2,object_DATA2[i],object_DATA2[i]) then
					groupsUnderCursor[ object_GROUP[i] ] = true
				end
			elseif object_TYPE[i] == 4 then
				if x >= x2 and x <= object_DATA1[i] and y >= y2 and y <= object_DATA2[i] then
					groupsUnderCursor[ object_GROUP[i] ] = true
				end
			end
		end
		for i=1,#image_pos_X do
			local x2,y2 = image_pos_X[i],image_pos_Y[i]
			local x3,y3 = image_pos_X2[i],image_pos_Y2[i]

			if x3 < x2 then x2,x3 = x3,x2 end
			if y3 < y2 then y2,y3 = y3,y2 end

			if x >= x2 and x <= x3 and y >= y2 and y <= y3 then
				groupsUnderCursor[ image_GROUP[i] ] = true
			end
		end
	end

	local alphaTabPos = nil
	local alphaTabNow = nil
	function CheckAlpha(self,elapsed)
		local x,y = ExRT.F.GetCursorPos(self)
		UpdateGroupsUnderCursor(x,y)
		if (alphaTabNow and not groupsUnderCursor[alphaTabNow]) or tool_selected ~= 7 then
			alphaTabNow = nil
			alphaTabPos = nil
		end
		if not alphaTabNow then
			for k,v in pairs(groupsUnderCursor) do
				if tool_selected == 7 or not lockedGroups[k] then
					groups_alpha_pending[ k ] = true
				end
			end
		else
			groups_alpha_pending[ alphaTabNow ] = true
		end

		for g,_ in pairs(groups_alpha_pending) do
			if not groups_alpha_now[g] then
				groups_alpha_now[g] = true
				for i=1,#dots_pos_X do
					if dots_GROUP[i] == g then
						dots_OBJ[i]:SetAlpha(.5)

						if tool_selected == 7 then
							SetLockedImg(dots_OBJ[i],g)
						end
					end
				end
				for i=1,#icon_pos_X do
					if icon_GROUP[i] == g then
						icon_OBJ[i]:SetAlpha(.5)

						if tool_selected == 7 then
							SetLockedImg(icon_OBJ[i],g)
						end
					end
				end
				for i=1,#text_pos_X do
					if text_GROUP[i] == g then
						text_OBJ[i]:SetAlpha(.5)

						if tool_selected == 7 then
							SetLockedImg(text_OBJ[i],g)
						end
					end
				end
				for o,_ in pairs(objects) do
					if o.g == g then
						if o.t then
							o:SetAlpha(o.t >= .5 and o.t / 2 or o.t + .5)
						else
							o:SetAlpha(.5)
						end

						if tool_selected == 7 then
							SetLockedImg(o,g)
						end
					end
				end
				for l,_ in pairs(lines) do
					if l.g == g then
						l:SetAlpha(.5)

						if tool_selected == 7 then
							SetLockedImg(l,g)
						end
					end
				end
				for i=1,#image_pos_X do
					if image_GROUP[i] == g then
						image_OBJ[i]:SetAlpha(image_OBJ[i].t >= .5 and image_OBJ[i].t / 2 or image_OBJ[i].t + .5)

						if tool_selected == 7 then
							SetLockedImg(image_OBJ[i],g)
						end
					end
				end
			end
		end
		for g,_ in pairs(groups_alpha_now) do
			if not groups_alpha_pending[g] then
				groups_alpha_now[g] = nil
				for i=1,#dots_pos_X do
					if dots_GROUP[i] == g then
						dots_OBJ[i]:SetAlpha(1)

						if tool_selected == 7 then
							SetLockedImg(dots_OBJ[i],g,true)
						end
					end
				end
				for i=1,#icon_pos_X do
					if icon_GROUP[i] == g then
						icon_OBJ[i]:SetAlpha(1)

						if tool_selected == 7 then
							SetLockedImg(icon_OBJ[i],g,true)
						end
					end
				end
				for i=1,#text_pos_X do
					if text_GROUP[i] == g then
						text_OBJ[i]:SetAlpha(1)

						if tool_selected == 7 then
							SetLockedImg(text_OBJ[i],g,true)
						end
					end
				end
				for o,_ in pairs(objects) do
					if o.g == g then
						o:SetAlpha(o.t or 1)

						if tool_selected == 7 then
							SetLockedImg(o,g,true)
						end
					end
				end
				for l,_ in pairs(lines) do
					if l.g == g then
						l:SetAlpha(1)

						if tool_selected == 7 then
							SetLockedImg(l,g,true)
						end
					end
				end
				for i=1,#image_pos_X do
					if image_GROUP[i] == g then
						image_OBJ[i]:SetAlpha(image_OBJ[i].t)

						if tool_selected == 7 then
							SetLockedImg(image_OBJ[i],g,true)
						end
					end
				end
			end
		end
		for g,_ in pairs(groups_alpha_pending) do
			groups_alpha_pending[g] = nil
		end
	end

	local function CheckAlphaTab(self)
		local list = {}
		for k,v in pairs(groupsUnderCursor) do
			list[#list+1] = {tostring(k),k}
		end
		sort(list,function(a,b)return a[1]<b[1] end)
		alphaTabPos = (alphaTabPos or 0) + 1
		if alphaTabPos > #list then
			alphaTabPos = nil
		end
		if alphaTabPos and #list > 1 then
			alphaTabNow = list[alphaTabPos][2]
		else
			alphaTabNow = nil
		end
	end

	local function ClearSomething(self)
		local x,y = ExRT.F.GetCursorPos(self)
		UpdateGroupsUnderCursor(x,y)

		local groups_to_remove = {}
		local isSomethingRemoved = false
		for k,v in pairs(groupsUnderCursor) do
			if not lockedGroups[k] then
				groups_to_remove[ k ] = true
				isSomethingRemoved = true
			end
		end

		for i=#dots_pos_X,1,-1 do
			if groups_to_remove[ dots_GROUP[i] ] then
				dots_OBJ[i]:Hide()
				tremove(dots_pos_X,i)
				tremove(dots_pos_Y,i)
				tremove(dots_SIZE,i)
				tremove(dots_COLOR,i)
				tremove(dots_GROUP,i)
				tremove(dots_OBJ,i)
				tremove(dots_SYNC,i)
			end
		end
		for i=#icon_pos_X,1,-1 do
			if groups_to_remove[ icon_GROUP[i] ] then
				icon_OBJ[i]:Hide()
				tremove(icon_pos_X,i)
				tremove(icon_pos_Y,i)
				tremove(icon_SIZE,i)
				tremove(icon_GROUP,i)
				tremove(icon_OBJ,i)
				tremove(icon_TYPE,i)
				tremove(icon_SYNC,i)
			end
		end
		for i=#text_pos_X,1,-1 do
			if groups_to_remove[ text_GROUP[i] ] then
				text_OBJ[i]:Hide()
				tremove(text_pos_X,i)
				tremove(text_pos_Y,i)
				tremove(text_SIZE,i)
				tremove(text_GROUP,i)
				tremove(text_OBJ,i)
				tremove(text_DATA,i)
				tremove(text_COLOR,i)
				tremove(text_SYNC,i)
			end
		end
		for i=#object_pos_X,1,-1 do
			if groups_to_remove[ object_GROUP[i] ] then
				for o,_ in pairs(objects) do
					if o.g == object_GROUP[i] then
						o:Hide()
					end
				end
				for l,_ in pairs(lines) do
					if l.g == object_GROUP[i] then
						l:Hide()
					end
				end
				tremove(object_pos_X,i)
				tremove(object_pos_Y,i)
				tremove(object_SIZE,i)
				tremove(object_GROUP,i)
				tremove(object_COLOR,i)
				tremove(object_TYPE,i)
				tremove(object_DATA1,i)
				tremove(object_DATA2,i)
				tremove(object_SYNC,i)
			end
		end
		for i=#image_pos_X,1,-1 do
			if groups_to_remove[ image_GROUP[i] ] then
				image_OBJ[i]:Hide()
				tremove(image_pos_X,i)
				tremove(image_pos_Y,i)
				tremove(image_pos_X2,i)
				tremove(image_pos_Y2,i)
				tremove(image_OBJ,i)
				tremove(image_GROUP,i)
				tremove(image_path,i)
				tremove(image_alpha,i)
				tremove(image_SYNC,i)
			end
		end

		if isSomethingRemoved and isLiveSession then
			module.options:GenerateString()
		elseif isSomethingRemoved then
			module.options:SaveData()
		end
	end

	local function LockUnlockSomething(self)
		local x,y = ExRT.F.GetCursorPos(self)
		UpdateGroupsUnderCursor(x,y)

		if alphaTabNow then
			lockedGroups[alphaTabNow] = not lockedGroups[alphaTabNow]
			UpdateLockedImg(alphaTabNow)
		else
			for k,v in pairs(groupsUnderCursor) do
				lockedGroups[k] = not lockedGroups[k]
				UpdateLockedImg(k)
			end
		end
	end


	self.main.C:SetScript("OnMouseDown",function(self,button)
		if self.popup then return end
		prevX,prevY = nil
		if button == "LeftButton" then
			module.options:NextGroup()
			if tool_selected == 1 then
				self:SetScript("OnUpdate",DotsUpdate)
			elseif tool_selected == 2 then
				self:SetScript("OnUpdate",IconsUpdate)
			elseif tool_selected == 3 then
				if curr_text == "" then return end
				self:SetScript("OnUpdate",TextsUpdate)
			elseif tool_selected == 4 then
				self:SetScript("OnUpdate",ObjectsUpdate)
			elseif tool_selected == 5 then
				self:SetScript("OnUpdate",MoveUpdate)
			elseif tool_selected == 6 then
				if curr_imgpath == "" then return end
				self:SetScript("OnUpdate",ImageUpdate)
			elseif tool_selected == 7 then
				LockUnlockSomething(self)
			end
		elseif button == "RightButton" then
			if tool_selected == 7 then
				CheckAlphaTab(self)
			else
				ClearSomething(self)
			end
		end
	end)
	self.main.C:SetScript("OnMouseUp",function(self,button)
		if self.popup then return end
		if tool_selected ~= 1 and button == "LeftButton" then
			special_counter = special_counter + 1
		end
		if tool_selected == 5 and button == "LeftButton" then
			if isLiveSession then
				module.options:GenerateString()
			else
				module.options:SaveData()
			end
		end
		self:SetScript("OnUpdate",CheckAlpha)
	end)
	self.main.C:SetScript("OnUpdate",CheckAlpha)

	self.main:SetScript("OnMouseWheel",function(self,delta)
		local x,y = ExRT.F.GetCursorPos(self)

		local oldScale = self.C:GetScale()
		local newScale = oldScale + delta * 0.25
		if newScale < 1 then
			newScale = 1
		elseif newScale > 7 then
			newScale = 7
		end
		self.C:SetScale( newScale )

		self.scrollH = self:GetWidth() - self:GetWidth() / newScale
		self.scrollV = self:GetHeight() - self:GetHeight() / newScale

		local scrollNowH = self:GetHorizontalScroll()
		local scrollNowV = self:GetVerticalScroll()

		scrollNowH = scrollNowH + x / oldScale - x / newScale
		scrollNowV = scrollNowV + y / oldScale - y / newScale

		if scrollNowH > self.scrollH then scrollNowH = self.scrollH end
		if scrollNowH < 0 then scrollNowH = 0 end
		if scrollNowV > self.scrollV then scrollNowV = self.scrollV end
		if scrollNowV < 0 then scrollNowV = 0 end

		self:SetHorizontalScroll(scrollNowH)
		self:SetVerticalScroll(scrollNowV)
	end)
	function self.main:ResetScale()
		self.C:SetScale(1)
		self:SetHorizontalScroll(0)
		self:SetVerticalScroll(0)
	end


	local function ConvertMapIDToString(n)
		local res={}
		repeat
			table.insert(res,1,n%253)
			n=floor(n/253)
		until n==0
		for i=2,#res do
			res[i]=res[i]+1
		end

		local r = ""
		for i=1,#res do
			r = r .. string.char(res[i])
		end
		return r
	end

	function self:GenerateString(live)
		self:SaveData()

		if type(curr_data) ~= "table" or not curr_data[1] then return end

		local uid = curr_data[1]
		if uid then
			VMRT.VisNote.sync_data[uid] = VMRT.VisNote.sync_data[uid] or {}
			local syncData = VMRT.VisNote.sync_data[uid]
			syncData.sender = ExRT.SDB.charKey
			syncData.time = time()

			module.options.lastUpdate:SetText( L.NoteLastUpdate..": "..syncData.sender.." ("..date("%H:%M:%S %d.%m.%Y",syncData.time)..")" )
		end


		local str = live and "" or (string.char(254)..string.char(1)..string.char(DATA_VERSION)..string.char(#curr_data[1])..curr_data[1]..string.char(#(curr_data.name or "")+1)..(curr_data.name or "")..string.char(254)..string.char(2)..ConvertMapIDToString(curr_map))
		if not live and curr_data.lockScale then
			local cxRaw = min(max(floor(curr_data.lockCX * 10000 + 0.5) + 25000, 0), 62499)
			local cyRaw = min(max(floor(curr_data.lockCY * 10000 + 0.5) + 25000, 0), 62499)
			local sRaw = min(max(floor(curr_data.lockScale * 1000 + 0.5), 0), 62499)
			str = str .. string.char(254) .. string.char(3)
				.. string.char(floor(cxRaw / 250) + 1) .. string.char(cxRaw % 250 + 1)
				.. string.char(floor(cyRaw / 250) + 1) .. string.char(cyRaw % 250 + 1)
				.. string.char(floor(sRaw / 250) + 1) .. string.char(sRaw % 250 + 1)
		end
		local prevGroup,prevX,prevY,prevDiffX,prevDiffY

		local function UpdateHeader(i)
			local p1 = dots_COLOR[i] * 1000 + dots_pos_X[i]
			local p2 = dots_SIZE[i] * 1000 + dots_pos_Y[i]
			str = str .. string.char(255) .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

			prevX = dots_pos_X[i]
			prevY = dots_pos_Y[i]
			prevGroup = dots_GROUP[i]
			prevDiffX,prevDiffY = nil
		end

		for i=1,#dots_pos_X do
			if not live or not dots_SYNC[i] then
				if dots_GROUP[i] ~= prevGroup then
					UpdateHeader(i)
				end
				local diffX = dots_pos_X[i] - prevX
				local diffY = dots_pos_Y[i] - prevY
				if abs(diffX) >= 50 or abs(diffY) >= 50 then
					UpdateHeader(i)
					diffX = dots_pos_X[i] - prevX
					diffY = dots_pos_Y[i] - prevY
				end
				if prevDiffX == diffX and prevDiffY == diffY then
					str = str ..string.char(254)
				else
					local p = ((diffX < 0 and 50 or 0) + diffX * (diffX < 0 and -1 or 1)) * 100 + (diffY < 0 and 50 or 0) + diffY * (diffY < 0 and -1 or 1)
					str = str ..string.char(floor(p / 250) + 1) .. string.char(p % 250 + 1)
				end
				prevX = dots_pos_X[i]
				prevY = dots_pos_Y[i]
				prevDiffX,prevDiffY = diffX,diffY

				dots_SYNC[i] = true
			end
		end


		for i=1,#icon_pos_X do
			if not live or not icon_SYNC[i] then
				str = str .. string.char(255) .. string.char(251) .. string.char(1)

				local p1 = icon_TYPE[i] * 1000 + icon_pos_X[i]
				local p2 = icon_pos_Y[i]

				str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

				local p3 = icon_SIZE[i]
				str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1)

				icon_SYNC[i] = true
			end
		end

		for i=1,#text_pos_X do
			if not live or not text_SYNC[i] then
				local text_len = #text_DATA[i]
				str = str .. string.char(255) .. string.char(251) .. string.char(2)

				local p1 = text_COLOR[i] * 1000 + text_pos_X[i]
				local p2 = text_pos_Y[i]

				str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

				local p3 = text_SIZE[i]
				str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1)

				str = str .. string.char(text_len + 1) .. text_DATA[i]

				text_SYNC[i] = true
			end
		end

		for i=1,#object_pos_X do
			if not live or not object_SYNC[i] then
				if object_TYPE[i] == 1 then
					str = str .. string.char(255) .. string.char(251) .. string.char(3)

					local p1 = object_COLOR[i] * 1000 + object_pos_X[i]
					local p2 = object_DATA1[i] * 1000 + object_pos_Y[i]

					str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

					local p3 = object_SIZE[i]
					str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1)
				elseif object_TYPE[i] == 2 then
					str = str .. string.char(255) .. string.char(251) .. string.char(4)

					local p1 = object_COLOR[i] * 1000 + object_pos_X[i]
					local p2 = floor(object_DATA1[i] / 2 + 0.5) * 1000 + object_pos_Y[i]

					str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

					local p3 = object_SIZE[i]
					str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1)
				elseif object_TYPE[i] == 3 or object_TYPE[i] == 5 or object_TYPE[i] == 6 then
					str = str .. string.char(255) .. string.char(251) .. string.char((object_TYPE[i] == 3 and 5) or (object_TYPE[i] == 5 and 7) or (object_TYPE[i] == 6 and 8))

					local p1 = object_COLOR[i] * 1000 + object_pos_X[i]
					local p2 = object_SIZE[i] * 1000 + object_pos_Y[i]

					str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

					local p3 = object_DATA1[i]
					local p4 = object_DATA2[i]
					str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1) .. string.char(floor(p4 / 250) + 1) .. string.char(p4 % 250 + 1)
				elseif object_TYPE[i] == 4 then
					str = str .. string.char(255) .. string.char(251) .. string.char(6)

					local p1 = object_COLOR[i] * 1000 + object_pos_X[i]
					local p2 = floor(object_SIZE[i] / 2 + 0.5) * 1000 + object_pos_Y[i]

					str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

					local p3 = object_DATA1[i]
					local p4 = object_DATA2[i]
					str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1) .. string.char(floor(p4 / 250) + 1) .. string.char(p4 % 250 + 1)
				end

				object_SYNC[i] = true
			end
		end

		for i=1,#image_pos_X do
			if not live or not image_SYNC[i] then
				str = str .. string.char(255) .. string.char(251) .. string.char(9)

				local p1 = (image_pos_X[i] < 0 and 20000 or 0) + abs(image_pos_X[i])
				local p2 = (image_pos_Y[i] < 0 and 20000 or 0) + abs(image_pos_Y[i])

				str = str .. string.char(floor(p1 / 250) + 1) .. string.char(p1 % 250 + 1) .. string.char(floor(p2 / 250) + 1) .. string.char(p2 % 250 + 1)

				local p3 = (image_pos_X2[i] < 0 and 20000 or 0) + abs(image_pos_X2[i])
				local p4 = (image_pos_Y2[i] < 0 and 20000 or 0) + abs(image_pos_Y2[i])

				str = str .. string.char(floor(p3 / 250) + 1) .. string.char(p3 % 250 + 1) .. string.char(floor(p4 / 250) + 1) .. string.char(p4 % 250 + 1)

				local p5 = image_alpha[i]

				str = str .. string.char(floor(p5 / 250) + 1) .. string.char(p5 % 250 + 1)

				local map = {}
				local path = tostring(image_path[i]):sub(1,10000)
				for j=1,#path do
					local b = path:sub(j,j):byte()
					if b > 250 then
						map[#map+1] = j
						path = path:sub(1,j-1)..string.char(b - 250)..path:sub(j+1)
					end
				end

				local str_len = #path
				str = str .. string.char(floor(str_len / 250) + 1) .. string.char(str_len % 250 + 1) .. path

				local map_len = #map
				str = str .. string.char(floor(map_len / 250) + 1) .. string.char(map_len % 250 + 1)

				for j=1,map_len do
					str = str .. string.char(floor(map[j] / 250) + 1) .. string.char(map[j] % 250 + 1)
				end

				image_SYNC[i] = true
			end
		end

		if #str == 0 then
			return
		end

		local compressed = LibDeflate:CompressDeflate(str,{level = 9})
		local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

		encoded = encoded .. "##F##"

		local parts = ceil(#encoded / 252)


		for i=1,parts do
			local msg = encoded:sub( (i-1)*252+1 , i*252 )
			ExRT.F.SendExMsg("VN",msg)
		end
	end
	function self:SaveData()
		local data = curr_data
		data[2] = curr_map
		local str = ""

		for i=3,#data do
			data[i] = nil
		end

		local prevGroup,prevX,prevY

		local function UpdateHeader(i)
			if str ~= "" then
				data[#data+1] = str
			end
			data[#data + 1] = "D"
			data[#data + 1] = dots_pos_X[i]
			data[#data + 1] = dots_pos_Y[i]
			data[#data + 1] = dots_COLOR[i]
			data[#data + 1] = dots_SIZE[i]

			str = ""

			prevX = dots_pos_X[i]
			prevY = dots_pos_Y[i]
			prevGroup = dots_GROUP[i]
		end
		for i=1,#dots_pos_X do
			if dots_GROUP[i] ~= prevGroup then
				UpdateHeader(i)
			end
			local diffX = dots_pos_X[i] - prevX
			local diffY = dots_pos_Y[i] - prevY

			str = str .. diffX .. ","
			str = str .. diffY .. ","

			prevX = dots_pos_X[i]
			prevY = dots_pos_Y[i]
		end
		if str ~= "" then
			data[#data+1] = str
		end

		for i=1,#icon_pos_X do
			data[#data + 1] = "I"
			data[#data + 1] = icon_pos_X[i]
			data[#data + 1] = icon_pos_Y[i]
			data[#data + 1] = icon_TYPE[i]
			data[#data + 1] = icon_SIZE[i]
		end
		for i=1,#text_pos_X do
			data[#data + 1] = "T"
			data[#data + 1] = text_pos_X[i]
			data[#data + 1] = text_pos_Y[i]
			data[#data + 1] = text_COLOR[i]
			data[#data + 1] = text_SIZE[i]
			data[#data + 1] = text_DATA[i]
		end
		for i=1,#object_pos_X do
			data[#data + 1] = "O"
			data[#data + 1] = object_pos_X[i]
			data[#data + 1] = object_pos_Y[i]
			data[#data + 1] = object_COLOR[i]
			data[#data + 1] = object_SIZE[i]
			data[#data + 1] = object_DATA1[i]
			data[#data + 1] = object_DATA2[i]
			data[#data + 1] = object_TYPE[i]
		end
		for i=1,#image_pos_X do
			data[#data + 1] = "G"
			data[#data + 1] = image_pos_X[i]
			data[#data + 1] = image_pos_Y[i]
			data[#data + 1] = image_pos_X2[i]
			data[#data + 1] = image_pos_Y2[i]
			data[#data + 1] = image_alpha[i]
			data[#data + 1] = image_path[i]
		end

		return data
	end
	function self:LoadData(data)
		module.options:Clear()
		curr_data = data
		module.options:SetPredefinedMap(data[2])

		local pos = 3
		local color,size
		local X,Y
		while data[pos] do
			if data[pos] == "D" then
				module.options:NextGroup()
				color,size = data[pos+3],data[pos+4]
				X,Y = data[pos+1],data[pos+2]
				local str_data = data[pos+5]

				while str_data ~= "" do
					local x,y,p2 = strsplit(",",str_data,3)
					str_data = p2
					x = tonumber(x)
					y = tonumber(y)

					module.options:AddDot(X+x,Y+y,color,size)

					X = X+x
					Y = Y+y
				end

				pos = pos + 6
			elseif data[pos] == "I" then
				module.options:NextGroup()
				color,size = data[pos+3],data[pos+4]
				X,Y = data[pos+1],data[pos+2]

				module.options:AddIcon(X,Y,color,size)

				pos = pos + 5
			elseif data[pos] == "T" then
				module.options:NextGroup()
				color,size = data[pos+3],data[pos+4]
				X,Y = data[pos+1],data[pos+2]
				local str_data = data[pos+5]

				module.options:AddText(X,Y,str_data,color,size)

				pos = pos + 6
			elseif data[pos] == "O" then
				module.options:NextGroup()
				color,size = data[pos+3],data[pos+4]
				X,Y = data[pos+1],data[pos+2]
				local data1,data2,type = data[pos+5],data[pos+6],data[pos+7]

				module.options:AddObject(X,Y,type,size,color,data1,data2)

				pos = pos + 8
			elseif data[pos] == "G" then
				module.options:NextGroup()
				local x,y = data[pos+1],data[pos+2]
				local x2,y2 = data[pos+3],data[pos+4]
				local alpha,path = data[pos+5],data[pos+6]

				module.options:AddImage(x,y,x2,y2,path,alpha)

				pos = pos + 7
			else
				pos = pos + 1
			end
		end

		module.options.NoteName:SetText(data.name or "")
		do
			local noteName = data.name
			if not noteName or #noteName == 0 then
				for i=1,#VMRT.VisNote.data do
					if VMRT.VisNote.data[i] == data then
						noteName = L.messageTab1.." "..i
						break
					end
				end
			end
			module.options.SelectNote:SetText(noteName or (L.VisualNoteSelectNote.."..."))
		end
		local syncData = VMRT.VisNote.sync_data[data[1] or ""]
		if syncData then
			module.options.lastUpdate:SetText( L.NoteLastUpdate..": "..syncData.sender.." ("..date("%H:%M:%S %d.%m.%Y",syncData.time)..")" )
		else
			module.options.lastUpdate:SetText("")
		end

		module.options.chkStopUpdate:SetChecked(data.disableUpdate)
		module.options.chkLockArea:SetChecked(data.lockScale and true)
	end
	function self:CreateNew()
		local new = {}
		local guid = UnitGUID('player') or "0x000000000000"
		local _,serverID,playerUID = strsplit("-",guid)
		if not playerUID then
			serverID = "x"
			playerUID = tostring(guid):gsub("^0x","")
		end
		local t = time()
		local uid = serverID..playerUID..t
		local foundUID = false
		while true do
			for i=1,#VMRT.VisNote.data do
				if VMRT.VisNote.data[i][1] == uid then
					foundUID = true
					break
				end
			end
			if foundUID then
				t = t - 1
				uid = serverID..playerUID..t
			else
				break
			end
		end
		new[1] = uid
		return new
	end
	function self:LoadNewest()
		local newest,nT = nil
		for uid,data in pairs(VMRT.VisNote.sync_data) do
			if not newest or nT < data.time then
				newest = uid
				nT = data.time
			end
		end
		local toLoad = nil
		if newest then
			for i=1,#VMRT.VisNote.data do
				if VMRT.VisNote.data[i][1] == newest then
					toLoad = VMRT.VisNote.data[i]
					break
				end
			end
		end
		if not toLoad then
			if #VMRT.VisNote.data > 0 then
				toLoad = VMRT.VisNote.data[#VMRT.VisNote.data]
			else
				VMRT.VisNote.data[1] = self:CreateNew()
				toLoad = VMRT.VisNote.data[1]
			end
		end
		self:LoadData(toLoad)
	end
	function self:GetCurrentData()
		return curr_data
	end

	self.clearAll = ELib:Button(self,L.messagebutclear):Size(90,20):Point("TOPLEFT",615,-30):OnClick(function(self)
		module.options:Clear()
		module.options:SaveData()
	end)

	self.sendButton = ELib:Button(self,L.messagebutsend):Size(90,20):Point("TOPLEFT",710,-30):OnClick(function(self)
		module.options:GenerateString()
	end)

	self.liveButton = ELib:Button(self,L.VisualNoteLiveSession):Size(90,20):Point("TOPLEFT",710,-55):OnClick(function(self)
		if not isLiveSession then
			module.options:GenerateString()
			self.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.26,0.09,1), CreateColor(0.20,0.41,0.25,1))
		else
			self.Texture:SetGradient("VERTICAL",CreateColor(0.05,0.06,0.09,1), CreateColor(0.20,0.21,0.25,1))
		end
		isLiveSession = not isLiveSession
	end)

	self.SelectNote = ELib:DropDown(self,205,10):Size(135):Point("TOPLEFT",195,-5):SetText(L.VisualNoteSelectNote.."...")
	local function SelectNote_SetValue(_,arg)
		ELib:DropDownClose()
		module.options:LoadData(arg)
	end
	function self.SelectNote:PreUpdate()
		self.List = {
			{
				colorCode = "|cff00ff00",
				text = L.ProfilesNew,
				justifyH = "CENTER",
				func = function ()
					ELib.ScrollDropDown.Close()
					local new = module.options:CreateNew()
					VMRT.VisNote.data[#VMRT.VisNote.data + 1] = new
					module.options:LoadData(new)
				end,
			}
		}
		for i=#VMRT.VisNote.data,1,-1 do
			local noteName = VMRT.VisNote.data[i].name
			if not noteName or #noteName == 0 then
				noteName = L.messageTab1.." "..i
			end
			self.List[#self.List + 1] = {
				text = noteName,
				justifyH = "CENTER",
				arg1 = VMRT.VisNote.data[i],
				func = SelectNote_SetValue,
			}
		end
	end

	self.NoteName = ELib:Edit(self):Size(200,20):Point(410,-5):LeftText(LFG_LIST_TITLE..":"):OnChange(function(self,isUser)
		if not isUser then return end
		curr_data.name = self:GetText()
		local label = self:GetText()
		if not label or #label == 0 then
			for i=1,#VMRT.VisNote.data do
				if VMRT.VisNote.data[i] == curr_data then
					label = L.messageTab1.." "..i
					break
				end
			end
		end
		module.options.SelectNote:SetText(label or (L.VisualNoteSelectNote.."..."))
	end)
	self.NoteName:SetMaxBytes(50)

	self.removeButton = ELib:Button(self,L.cd2RemoveButton):Size(90,20):Point("TOPLEFT",615,-5):OnClick(function(self)
		StaticPopupDialogs["EXRT_VISNOTE_REMOVE"] = {
			text = L.cd2RemoveButton,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				for i=#VMRT.VisNote.data,1,-1 do
					if VMRT.VisNote.data[i] == curr_data then
						tremove(VMRT.VisNote.data,i)
					end
				end
				if #VMRT.VisNote.data == 0 then
					local new = module.options:CreateNew()
					VMRT.VisNote.data[#VMRT.VisNote.data + 1] = new
				end
				module.options:LoadData(VMRT.VisNote.data[#VMRT.VisNote.data])
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_VISNOTE_REMOVE")
	end)

	self.lastUpdate = ELib:Text(self,"",8):Point("BOTTOMLEFT",self,"BOTTOMLEFT",5,2):Color()

	self.chkHidePopup = ELib:Check(self,L.VisualNoteDisablePopup,VMRT.VisNote.DisablePopup):Point("BOTTOMRIGHT",self,"BOTTOMRIGHT",-10,5):Scale(.8):Size(10,10):Left():OnClick(function(self)
		if self:GetChecked() then
			VMRT.VisNote.DisablePopup = true
		else
			VMRT.VisNote.DisablePopup = nil
		end
	end)

	self.chkStopUpdate = ELib:Check(self,L.VisualNoteDisableUpdateShort):Tooltip(L.VisualNoteDisableUpdate):Point("BOTTOMRIGHT",self,"BOTTOMRIGHT",-240,5):Scale(.8):Size(10,10):Left():OnClick(function(self)
		curr_data.disableUpdate = self:GetChecked()
	end)

	self.chkLockArea = ELib:Check(self,L.VisualNoteLockArea):Tooltip(L.VisualNoteLockAreaTip):Point("BOTTOMRIGHT",self,"BOTTOMRIGHT",-360,5):Scale(.8):Size(10,10):Left():OnClick(function(self)
		local opt = module.options
		if self:GetChecked() then
			local st = opt.bgState
			if not st then
				self:SetChecked(false)
				return
			end
			local W,H = opt.main:GetWidth(), opt.main:GetHeight()
			local Z = opt.main.C:GetScale()
			local sH,sV = opt.main:GetHorizontalScroll(), opt.main:GetVerticalScroll()
			local ccX = sH + (W/2)/Z
			local ccY = sV + (H/2)/Z
			curr_data.lockCX = st.cx + (ccX - st.mainW/2) / (st.layerW * st.scale)
			curr_data.lockCY = st.cy + (ccY - st.mainH/2) / (st.layerH * st.scale)
			curr_data.lockScale = st.scale * Z
			opt:SetPredefinedMap(curr_map)
			opt.main:ResetScale()
		else
			local cx,cy,sc = curr_data.lockCX, curr_data.lockCY, curr_data.lockScale
			curr_data.lockCX = nil
			curr_data.lockCY = nil
			curr_data.lockScale = nil
			opt:SetPredefinedMap(curr_map)
			local st = opt.bgState
			if st and sc then
				local Z = sc / st.scale
				if Z < 1 then Z = 1 elseif Z > 7 then Z = 7 end
				local W,H = opt.main:GetWidth(), opt.main:GetHeight()
				local ccX = W/2 + st.layerW * st.scale * ((cx or .5) - st.cx)
				local ccY = H/2 + st.layerH * st.scale * ((cy or .5) - st.cy)
				opt.main.C:SetScale(Z)
				opt.main.scrollH = W - W/Z
				opt.main.scrollV = H - H/Z
				local nH = ccX - (W/2)/Z
				local nV = ccY - (H/2)/Z
				if nH > opt.main.scrollH then nH = opt.main.scrollH elseif nH < 0 then nH = 0 end
				if nV > opt.main.scrollV then nV = opt.main.scrollV elseif nV < 0 then nV = 0 end
				opt.main:SetHorizontalScroll(nH)
				opt.main:SetVerticalScroll(nV)
			else
				opt.main:ResetScale()
			end
		end
		if isLiveSession then
			opt:GenerateString()
		else
			opt:SaveData()
		end
	end)

	self.copyButton = ELib:Button(self,L.BossmodsKormrokCopy):Size(90,20):Point("TOPLEFT",710,-5):OnClick(function()
		self:SaveData()
		local new = self:CreateNew()
		for i=2,#curr_data do
			new[i] = curr_data[i]
		end
		new.name = (curr_data.name or "").." *"
		VMRT.VisNote.data[#VMRT.VisNote.data + 1] = new
		self:LoadData(new)
	end)

	local SCALE = 1 / 4

	local frame = ELib:Popup(L.message):Size(790*SCALE+6,535*SCALE+15+3):Point("LEFT",UIParent,"LEFT",100,0)
	module.frame = frame
	frame:Hide()
	frame.defWidth = 790*SCALE+6
	frame.defHeight = 535*SCALE+15+3

	frame.Close:SetScript("OnClick",function (self)
		module.db.PopupIsOn = false
		self:GetParent():Hide()
	end)

	if frame.SetResizable then frame:SetResizable(true) end
	frame.buttonResize = CreateFrame("Frame",nil,frame)
	frame.buttonResize:SetSize(15,15)
	frame.buttonResize:SetPoint("BOTTOMRIGHT", 0, 0)
	frame.buttonResize:EnableMouse(true)
	frame.buttonResize:SetFrameStrata("DIALOG")
	frame.buttonResize:SetFrameLevel((frame:GetFrameLevel() or 1) + 50)
	frame.buttonResize.back = frame.buttonResize:CreateTexture(nil, "BACKGROUND")
	frame.buttonResize.back:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\Resize.tga")
	frame.buttonResize.back:SetAllPoints()
	frame.buttonResize.back:SetAlpha(.7)
	frame.buttonResize:SetScript("OnMouseDown", function(self)
		if frame.SetResizable then frame:SetResizable(true) end
		frame.Prop = frame:GetWidth() / frame:GetHeight()
		if frame.StartSizing then
			frame:StartSizing("BOTTOMRIGHT")
		end
	end)
	frame.buttonResize:SetScript("OnMouseUp", function(self)
		frame:StopMovingOrSizing()
	end)
	frame:SetScript("OnSizeChanged", function (self, width, height)
		if self.lock or not self.Prop then
			return
		end
		if width/height >= self.Prop then
			width = height * self.Prop
			self.lock = true
			self:SetWidth(width)
			self.lock = false
		else
			height = width / self.Prop
			self.lock = true
			self:SetHeight(height)
			self.lock = false
		end
		local rate = width / frame.defWidth
		VMRT.VisNote.PopupSizeRate = rate
		VMRT.VisNote.PopupWidth = width
		VMRT.VisNote.PopupHeight = height
		module.options.main:SetScale(SCALE * rate)
	end)
	frame:SetScript("OnDragStart", function(self)
		if self:IsMovable() then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		VMRT.VisNote.PopupLeft = self:GetLeft()
		VMRT.VisNote.PopupTop = self:GetTop()
	end)


	function module.ShowPopup()
		frame:Show()
		if VMRT.VisNote.PopupWidth and VMRT.VisNote.PopupHeight then
			frame:SetSize(VMRT.VisNote.PopupWidth, VMRT.VisNote.PopupHeight)
		end
		self.main:SetScale(SCALE*(VMRT.VisNote.PopupSizeRate or 1))
		self.main:SetParent(frame)
		self.main:ClearAllPoints()
		self.main:SetPoint("CENTER",0,-9)
		self.main.C.popup = true

		self.main.C:SetScript("OnUpdate",nil)

		if VMRT.VisNote.PopupLeft and VMRT.VisNote.PopupTop then
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",VMRT.VisNote.PopupLeft,VMRT.VisNote.PopupTop)
		end

		self.showPopup:Hide()
	end

	self.showPopup = ELib:Button(self,""):Size(20,20):Point("TOPLEFT",self.main,0,0):Tooltip(L.VisualNotePopupButTooltip.."\n"..L.VisualNotePopupButTooltip2):OnClick(function()
		if IsShiftKeyDown() then
			VMRT.VisNote.PopupWidth = nil
			VMRT.VisNote.PopupHeight = nil
			VMRT.VisNote.PopupSizeRate = nil
			VMRT.VisNote.PopupLeft = nil
			VMRT.VisNote.PopupTop = nil
			frame:Size(790*SCALE+6,535*SCALE+15+3):NewPoint("LEFT",UIParent,"LEFT",100,0)
		end
		module.db.PopupIsOn = true
		module:ShowPopup()

		ExRT.Options.Frame:Hide()
	end)
	self.showPopup:SetFrameStrata("DIALOG")

	self.showPopup.texture = self.showPopup:CreateTexture(nil,"ARTWORK")
	self.showPopup.texture:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
	self.showPopup.texture:SetTexCoord(0.4375,0.5,0.5,0.625)
	self.showPopup.texture:SetPoint("CENTER")
	self.showPopup.texture:SetSize(18,18)

	self.isWide = 810
	function self:OnShow()
		if self.main.C.popup then
			self.main:SetScale(1)
			self.main:SetParent(self)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOP",0,-81)

			self.main.C.popup = nil

			self.main.C:SetScript("OnUpdate",CheckAlpha)

			self.showPopup:Show()

			frame:Hide()

			self.main:ResetScale()
		end

		self:LoadNewest()
	end
	self:SetScript("OnHide",function()
		if module.db.PopupIsOn then
			module:ShowPopup()
		end
	end)
end

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.VisNote = VMRT.VisNote or {}
	VMRT.VisNote.data = VMRT.VisNote.data or {}
	VMRT.VisNote.sync_data = VMRT.VisNote.sync_data or {}

	module:RegisterAddonMessage()
end

function module:UnpackString(str,sender)
	if str:sub(1,1):byte() == 254 then
		local c = str:sub(2,2):byte()
		if c == 1 then
			c = str:sub(3,3):byte()
			if c ~= DATA_VERSION then
				module.db.await = nil
				return
			end
			module.db.await = {}
			c = str:sub(4,4):byte()
			module.db.await[1] = str:sub(5,5+c-1)
			str = str:sub(5+c)

			c = str:sub(1,1):byte()
			module.db.await.name = str:sub(2,2+c-2)
			str = str:sub(2+c-1)

			local found = nil
			for i=1,#VMRT.VisNote.data do
				if VMRT.VisNote.data[i][1] == module.db.await[1] then
					if VMRT.VisNote.data[i].disableUpdate then
						module.db.await = nil
						return
					end
					VMRT.VisNote.data[i] = module.db.await
					found = true
					break
				end
			end
			if not found then
				VMRT.VisNote.data[#VMRT.VisNote.data + 1] = module.db.await
			end
			module.popup:Popup(sender)
			local uid = module.db.await[1]
			if uid then
				VMRT.VisNote.sync_data[uid] = VMRT.VisNote.sync_data[uid] or {}
				VMRT.VisNote.sync_data[uid].sender = sender
				VMRT.VisNote.sync_data[uid].time = time()
			end
		end
	end
	if str:sub(1,1):byte() == 254 then
		local c = str:sub(2,2):byte()
		if c == 2 then
			if not module.db.await then
				return
			end
			local mapIDstr = str:match("^..([^"..string.char(254)..string.char(255).."]+)")
			c = 0
			for i=1,#mapIDstr do
				c = c * 253 + mapIDstr:sub(i,i):byte() + (i > 1 and -1 or 0)

			end
			module.db.await[2] = c
			str = str:sub(2+#mapIDstr+1)
		end
	end
	if str:sub(1,1):byte() == 254 then
		local c = str:sub(2,2):byte()
		if c == 3 then
			if not module.db.await then
				return
			end
			local cxRaw = (str:sub(3,3):byte() - 1) * 250 + (str:sub(4,4):byte() - 1)
			local cyRaw = (str:sub(5,5):byte() - 1) * 250 + (str:sub(6,6):byte() - 1)
			local sRaw  = (str:sub(7,7):byte() - 1) * 250 + (str:sub(8,8):byte() - 1)
			module.db.await.lockCX = (cxRaw - 25000) / 10000
			module.db.await.lockCY = (cyRaw - 25000) / 10000
			module.db.await.lockScale = sRaw / 1000
			str = str:sub(9)
		end
	end
	if not module.db.await then
		return
	end
	local data = {strsplit(string.char(255),str)}
	for i=1,#data do
		local len = #data[i]
		if len > 0 and data[i]:sub(1,1):byte() <= 250 then
			local p1 = (data[i]:sub(1,1):byte() - 1) * 250 + (data[i]:sub(2,2):byte() - 1)
			local p2 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)

			local x,y = p1 % 1000,p2 % 1000
			local color,size = floor(p1 / 1000),floor(p2 / 1000)

			module.db.await[#module.db.await + 1] = "D"
			module.db.await[#module.db.await + 1] = x
			module.db.await[#module.db.await + 1] = y
			module.db.await[#module.db.await + 1] = color
			module.db.await[#module.db.await + 1] = size

			local pos = 5
			local prevDiffX,prevDiffY
			local astr = ""
			while true do
				local c = data[i]:sub(pos,pos)
				if c == "" then
					break
				end
				local X,Y
				if c:byte()==254 then
					X,Y = prevDiffX,prevDiffY
					pos = pos + 1
				else
					local p = (data[i]:sub(pos,pos):byte() - 1) * 250 + (data[i]:sub(pos+1,pos+1):byte() - 1)
					X,Y = floor(p / 100),p % 100
					if X > 50 then
						X = -(X - 50)
					end
					if Y > 50 then
						Y = -(Y - 50)
					end
					pos = pos + 2
				end
				prevDiffX,prevDiffY = X,Y

				astr = astr .. X .. "," .. Y ..","

				x = X+x
				y = Y+y
			end

			module.db.await[#module.db.await + 1] = astr
		elseif len > 0 and data[i]:sub(1,1):byte() == 251 then
			local c = data[i]:sub(2,2):byte()
			if c == 1 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local icon_type,size = floor(p1 / 1000),p3

				module.db.await[#module.db.await + 1] = "I"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = icon_type
				module.db.await[#module.db.await + 1] = size
			elseif c == 2 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)
				local p4 = (data[i]:sub(9,9):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local color,size = floor(p1 / 1000),p3

				module.db.await[#module.db.await + 1] = "T"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = color
				module.db.await[#module.db.await + 1] = size
				module.db.await[#module.db.await + 1] = data[i]:sub(10,10+p4-1)
			elseif c == 3 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local color,think = floor(p1 / 1000),floor(p2 / 1000)
				local size = p3

				module.db.await[#module.db.await + 1] = "O"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = color
				module.db.await[#module.db.await + 1] = size
				module.db.await[#module.db.await + 1] = think
				module.db.await[#module.db.await + 1] = 0
				module.db.await[#module.db.await + 1] = 1
			elseif c == 4 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local color,think = floor(p1 / 1000),floor(p2 / 1000)
				local size = p3

				module.db.await[#module.db.await + 1] = "O"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = color
				module.db.await[#module.db.await + 1] = size
				module.db.await[#module.db.await + 1] = think * 2
				module.db.await[#module.db.await + 1] = 0
				module.db.await[#module.db.await + 1] = 2
			elseif c == 5 or c == 7 or c == 8 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)
				local p4 = (data[i]:sub(9,9):byte() - 1) * 250 + (data[i]:sub(10,10):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local color,size = floor(p1 / 1000),floor(p2 / 1000)

				module.db.await[#module.db.await + 1] = "O"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = color
				module.db.await[#module.db.await + 1] = size
				module.db.await[#module.db.await + 1] = p3
				module.db.await[#module.db.await + 1] = p4
				module.db.await[#module.db.await + 1] = (c == 5 and 3) or (c == 7 and 5) or (c == 8 and 6) or 3
			elseif c == 6 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)
				local p4 = (data[i]:sub(9,9):byte() - 1) * 250 + (data[i]:sub(10,10):byte() - 1)

				local x,y = p1 % 1000,p2 % 1000
				local color,size = floor(p1 / 1000),floor(p2 / 1000)

				module.db.await[#module.db.await + 1] = "O"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = color
				module.db.await[#module.db.await + 1] = size * 2
				module.db.await[#module.db.await + 1] = p3
				module.db.await[#module.db.await + 1] = p4
				module.db.await[#module.db.await + 1] = 4
			elseif c == 9 then
				local p1 = (data[i]:sub(3,3):byte() - 1) * 250 + (data[i]:sub(4,4):byte() - 1)
				local p2 = (data[i]:sub(5,5):byte() - 1) * 250 + (data[i]:sub(6,6):byte() - 1)
				local p3 = (data[i]:sub(7,7):byte() - 1) * 250 + (data[i]:sub(8,8):byte() - 1)
				local p4 = (data[i]:sub(9,9):byte() - 1) * 250 + (data[i]:sub(10,10):byte() - 1)
				local p5 = (data[i]:sub(11,11):byte() - 1) * 250 + (data[i]:sub(12,12):byte() - 1)

				local x,y = p1 > 20000 and -(p1-20000) or p1,p2 > 20000 and -(p2-20000) or p2
				local x2,y2 = p3 > 20000 and -(p3-20000) or p3,p4 > 20000 and -(p4-20000) or p4
				local alpha = p5

				local str_len = (data[i]:sub(13,13):byte() - 1) * 250 + (data[i]:sub(14,14):byte() - 1)

				local path = data[i]:sub(15,14+str_len)

				local map_len = (data[i]:sub(15+str_len,15+str_len):byte() - 1) * 250 + (data[i]:sub(16+str_len,16+str_len):byte() - 1)
				for j=1,map_len do
					local pos = (data[i]:sub(16+str_len+j*2-1,16+str_len+j*2-1):byte() - 1) * 250 + (data[i]:sub(16+str_len+j*2,16+str_len+j*2):byte() - 1)

					path = path:sub(1,pos-1)..string.char(path:sub(pos,pos):byte() + 250)..path:sub(pos+1)
				end

				path = tonumber(path) or path

				module.db.await[#module.db.await + 1] = "G"
				module.db.await[#module.db.await + 1] = x
				module.db.await[#module.db.await + 1] = y
				module.db.await[#module.db.await + 1] = x2
				module.db.await[#module.db.await + 1] = y2
				module.db.await[#module.db.await + 1] = alpha
				module.db.await[#module.db.await + 1] = path
			end
		end
	end

	if module.options.LoadData then
		module.options:LoadData(module.db.await)
	end
end

module.db.syncStr = {}
function module:addonMessage(sender, prefix, ...)
	if prefix == "VN" then
		local _, zoneType, difficulty, _, maxPlayers, _, _, mapID = GetInstanceInfo()
		if difficulty == 7 or difficulty == 17 then
			return
		end
		if (IsInRaid() and not ExRT.F.IsPlayerRLorOfficer(sender))
			or sender == ExRT.SDB.charKey
			or sender == ExRT.SDB.charName
		then
			return
		end
		local str = table.concat({...}, "\t")
		module.db.syncStr[sender] = module.db.syncStr[sender] or ""
		module.db.syncStr[sender] = module.db.syncStr[sender] .. str
		if module.db.syncStr[sender]:find("##F##$") then
			local str = module.db.syncStr[sender]:sub(1,-6)
			module.db.syncStr[sender] = nil

			local decoded = LibDeflate:DecodeForWoWAddonChannel(str)
			local decompressed = LibDeflate:DecompressDeflate(decoded)

			module:UnpackString(decompressed,sender)
		end
	end
end

do
	local frame = CreateFrame("Frame",nil,UIParent,BackdropTemplateMixin and "BackdropTemplate")
	module.popup = frame

	frame:Hide()
	frame:SetBackdrop({bgFile="Interface\\Addons\\"..GlobalAddonName.."\\media\\White"})
	frame:SetBackdropColor(0.05,0.05,0.07,0.98)
	frame:SetSize(250,65)
	frame:SetPoint("RIGHT",UIParent,"CENTER",-200,0)
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)

	frame.border = ExRT.lib:Shadow(frame,20)

	frame.label = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.label:SetFont(frame.label:GetFont(),10,"")
	frame.label:SetPoint("TOP",0,-4)
	frame.label:SetTextColor(1,1,1,1)
	frame.label:SetText("MRT: "..L.VisualNote)

	frame.player = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.player:SetFont(frame.player:GetFont(),10,"")
	frame.player:SetPoint("TOP",0,-16)
	frame.player:SetTextColor(1,1,1,1)
	frame.player:SetText("MyName-MyRealm")

	frame.b1 = ELib:Button(frame,L.minimapmenuclose):Point("BOTTOMLEFT",5,5):Size(100,20):OnClick(function() frame:Hide() end)
	frame.b3 = ELib:Button(frame,L.VisualNoteOpen):Point("BOTTOMRIGHT",-5,5):Size(100,20):OnClick(function()
		frame:Hide()
		ExRT.Options:Open(module.options)
		if module.options.LoadData and module.db.await then
			module.options:LoadData(module.db.await)
		end
	end)

	frame.b1.icon = frame.b1:CreateTexture(nil,"ARTWORK")
	frame.b1.icon:SetPoint("RIGHT",frame.b1:GetTextObj(),"LEFT")
	frame.b1.icon:SetSize(18,18)
	frame.b1.icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
	frame.b1.icon:SetTexCoord(0.125+(0.1875 - 0.125)*6,0.1875+(0.1875 - 0.125)*6,0.5,0.625)
	frame.b1.icon:SetVertexColor(1,0,0,1)

	frame.b3.icon = frame.b3:CreateTexture(nil,"ARTWORK")
	frame.b3.icon:SetPoint("RIGHT",frame.b3:GetTextObj(),"LEFT")
	frame.b3.icon:SetSize(18,18)
	frame.b3.icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\DiesalGUIcons16x256x128")
	frame.b3.icon:SetTexCoord(0.125+(0.1875 - 0.125)*7,0.1875+(0.1875 - 0.125)*7,0.5,0.625)
	frame.b3.icon:SetVertexColor(0,1,0,1)

	function frame:Popup(player)
		if module.options.main and module.options.main.C:IsVisible() then
			return
		end
		if VMRT and VMRT.VisNote and VMRT.VisNote.DisablePopup then
			return
		end
		frame.player:SetText(player)
		frame:Show()
	end

end
