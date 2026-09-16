MRT = MRT or {}
local DiagonalGlyphAtlas = MRT.DiagonalGlyphAtlas or {}
MRT.DiagonalGlyphAtlas = DiagonalGlyphAtlas
DiagonalGlyphAtlas.atlases = DiagonalGlyphAtlas.atlases or {}
if type(DiagonalGlyphAtlas.data) == "table" and not DiagonalGlyphAtlas.atlases.diagonal then
	DiagonalGlyphAtlas.atlases.diagonal = DiagonalGlyphAtlas.data
end

local function ResolveAtlas(name)
	local byName = name and DiagonalGlyphAtlas.atlases[name]
	if type(byName) == "table"
		and type(byName.chars) == "table"
		and type(byName.file) == "string" then
		return byName
	end
	local default = DiagonalGlyphAtlas.atlases.diagonal or DiagonalGlyphAtlas.data
	if type(default) == "table"
		and type(default.chars) == "table"
		and type(default.file) == "string" then
		return default
	end
	return nil
end

local function HasAtlas()
	return ResolveAtlas(nil) ~= nil
end
local AXIS_DX = 0.5
local AXIS_DY = 0.8660254037844386
local STRIDE_FRACTION = 0.40

local function ClampGlyphSize(size)
	if type(size) ~= "number" or size < 4 then return 20 end
	if size > 96 then return 96 end
	return size
end
local function eachChar(s)
	local i, n = 0, #s
	return function()
		i = i + 1
		if i > n then return nil end
		return s:sub(i, i)
	end
end
local rendererProto = {}

function rendererProto:GetGlyph(index)
	local glyph = self._glyphs[index]
	if glyph then return glyph end
	glyph = self.frame:CreateTexture(nil, self._drawLayer or "OVERLAY")
	local atlas = ResolveAtlas(self._atlasName)
	if atlas then glyph:SetTexture(atlas.file) end
	self._glyphs[index] = glyph
	return glyph
end

function rendererProto:SetDrawLayer(layer, sublayer)
	self._drawLayer = layer
	for i = 1, #self._glyphs do
		local g = self._glyphs[i]
		if sublayer then
			g:SetDrawLayer(layer, sublayer)
		else
			g:SetDrawLayer(layer)
		end
	end
end
function rendererProto:SetTextColor(r, g, b, a)
	r = r or 1; g = g or 1; b = b or 1; a = a or 1
	self._color = { r, g, b, a }
	for i = 1, #self._glyphs do
		self._glyphs[i]:SetVertexColor(r, g, b, a)
	end
end
function rendererProto:SetGlyphSize(size)
	size = ClampGlyphSize(size)
	if self._glyphSize == size then return end
	self._glyphSize = size
	if self._text then
		self:SetText(self._text)
	end
end
function rendererProto:SetStrideFraction(frac)
	if type(frac) ~= "number" or frac <= 0 then return end
	self._strideFraction = frac
	if self._text then
		self:SetText(self._text)
	end
end

function rendererProto:SetReadDirection(dir)
	self._readDirection = (dir and dir < 0) and -1 or 1
	if self._text then
		self:SetText(self._text)
	end
end

function rendererProto:SetAnchorPoint(point)
	if type(point) ~= "string" then return end
	self._anchorPoint = point
	if self._text then
		self:SetText(self._text)
	end
end

function rendererProto:SetAxis(angleDeg)
	if type(angleDeg) ~= "number" then return end
	local rad = math.rad(angleDeg)
	self._axisDx = math.cos(rad)
	self._axisDy = math.sin(rad)
	if self._text then
		self:SetText(self._text)
	end
end

function rendererProto:SetAtlas(name)
	self._atlasName = name
	local atlas = ResolveAtlas(self._atlasName)
	if atlas then
		for i = 1, #self._glyphs do
			self._glyphs[i]:SetTexture(atlas.file)
		end
	end
	if self._text then
		self:SetText(self._text)
	end
end

function rendererProto:SetText(text)
	self._text = text or ""
	if not HasAtlas() then
		for i = 1, #self._glyphs do self._glyphs[i]:Hide() end
		return
	end
	local data = ResolveAtlas(self._atlasName)
	if not data then
		for i = 1, #self._glyphs do self._glyphs[i]:Hide() end
		return
	end
	local cell = data.cell
	local glyphSize = self._glyphSize or 20
	local stride = glyphSize * (self._strideFraction or STRIDE_FRACTION)
	local nChars = 0
	for _ in eachChar(self._text) do nChars = nChars + 1 end
	local dir = self._readDirection or 1
	local axisDx = self._axisDx or AXIS_DX
	local axisDy = self._axisDy or AXIS_DY
	local r, g, b, a
	if self._color then
		r, g, b, a = self._color[1], self._color[2], self._color[3], self._color[4]
	else
		r, g, b, a = 1, 1, 1, 1
	end
	local i = 0
	for ch in eachChar(self._text) do
		i = i + 1
		local glyph = self:GetGlyph(i)
		local cellInfo = data.chars[ch] or data.chars["?"]
		if cellInfo then
			local u0 = cellInfo.col * cell / data.width
			local v0 = cellInfo.row * cell / data.height
			local u1 = (cellInfo.col + 1) * cell / data.width
			local v1 = (cellInfo.row + 1) * cell / data.height
			glyph:SetTexCoord(u0, u1, v0, v1)
		end
		glyph:SetSize(glyphSize, glyphSize)
		glyph:ClearAllPoints()
		local stepIdx = (i - 1) * dir
		local dx = stepIdx * stride * axisDx
		local dy = stepIdx * stride * axisDy
		local anchor = self._anchorPoint or "BOTTOMLEFT"
		glyph:SetPoint(anchor, self.frame, anchor, dx, dy)
		glyph:SetVertexColor(r, g, b, a)
		glyph:Show()
	end
	for j = i + 1, #self._glyphs do
		self._glyphs[j]:Hide()
	end
	if nChars > 0 then
		local span = (nChars - 1) * stride
		self.frame:SetSize(
			math.max(glyphSize, span * math.abs(axisDx) + glyphSize),
			math.max(glyphSize, span * math.abs(axisDy) + glyphSize)
		)
	else
		self.frame:SetSize(1, 1)
	end
end

function rendererProto:SetPoint(...)
	self.frame:SetPoint(...)
end

function rendererProto:ClearAllPoints()
	self.frame:ClearAllPoints()
end

function rendererProto:Show()
	self.frame:Show()
end

function rendererProto:Hide()
	self.frame:Hide()
end
function rendererProto:SetAlpha(a)
	self.frame:SetAlpha(a)
end

function rendererProto:GetAlpha()
	return self.frame:GetAlpha()
end

function rendererProto:GetFrame()
	return self.frame
end

function DiagonalGlyphAtlas:CreateRenderer(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(1, 1)
	local r = setmetatable({
		frame = frame,
		_glyphs = {},
		_glyphSize = 20,
		_readDirection = 1,
	}, { __index = rendererProto })
	return r
end
function DiagonalGlyphAtlas:IsAvailable()
	return HasAtlas()
end
