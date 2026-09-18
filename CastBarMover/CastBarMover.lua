-- Destrava a barra de cast nativa da Blizzard (CastingBarFrame, a mesma
-- que mostra o progresso ao conjurar) para poder arrastar e reposicionar.
-- Não mexe na barra de verdade enquanto ela está em uso: mostra um
-- retângulo "proxy" do mesmo tamanho pra arrastar, e só aplica a posição
-- na barra real quando você confirma (rodando o comando de novo).
--
-- Só se move na vertical: sempre ancorado em TOP/UIParent/TOP com X preso
-- em 0, então fica sempre perfeitamente centralizado - só existe uma
-- coordenada pra salvar (y), então não tem como ficar "torto".

local PREFIX = "|cff00ccff[CastBarMover]|r "
local ANCHOR_POINT = "TOP"
local ANCHOR_RELATIVE_POINT = "TOP"
local DEFAULT_Y = -300

CastBarMoverDB = CastBarMoverDB or {}

local unlocked = false

local mover = CreateFrame("Frame", "CastBarMoverFrame", UIParent)
mover:SetFrameStrata("HIGH")
mover:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
})
mover:SetBackdropColor(0, 0.6, 1, 0.35)
mover:SetBackdropBorderColor(0, 0.6, 1, 1)
mover:Hide()

local label = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("CENTER")
label:SetText("Cast Bar (arraste - só move na vertical)")

local function ClampMoverX()
    local _, _, _, _, y = mover:GetPoint()
    mover:ClearAllPoints()
    mover:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, y)
end

mover:SetMovable(true)
mover:EnableMouse(true)
mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", function(self)
    self:StartMoving()
    -- Corrige o X de volta pra 0 a cada frame do arrasto (StartMoving move
    -- livre nos dois eixos) - o efeito visual é o retângulo só andando
    -- para cima/baixo, nunca de lado, mesmo que o mouse se mexa na
    -- horizontal.
    self:SetScript("OnUpdate", ClampMoverX)
end)
mover:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    self:StopMovingOrSizing()
    ClampMoverX()
end)

-- Posiciona o proxy do mesmo tamanho da CastingBarFrame, começando da
-- última posição salva (ou um valor razoável se nunca foi customizada) -
-- não tenta ler a posição nativa atual da barra real porque ela pode estar
-- ancorada num sistema de coordenadas diferente (relativo a outro frame),
-- o que bagunçaria a conversão pro nosso sistema fixo TOP/UIParent/TOP.
local function SyncMoverToCastBar()
    local width, height = CastingBarFrame:GetSize()
    mover:SetSize(width, height)
    mover:ClearAllPoints()
    mover:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, CastBarMoverDB.y or DEFAULT_Y)
end

local function ApplyMoverToCastBar()
    local _, _, _, _, y = mover:GetPoint()

    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, y)

    CastBarMoverDB.y = y
end

local function ApplySavedPosition()
    if CastBarMoverDB.y then
        CastingBarFrame:ClearAllPoints()
        CastingBarFrame:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, CastBarMoverDB.y)
    end
end

local function Unlock()
    SyncMoverToCastBar()
    mover:Show()
    unlocked = true
    print(PREFIX .. "arraste o retângulo azul pra cima/baixo. Rode /castbar (ou /cb) de novo pra confirmar.")
end

local function Lock()
    ApplyMoverToCastBar()
    mover:Hide()
    unlocked = false
    print(PREFIX .. "posição salva.")
end

local function ToggleLock()
    if unlocked then
        Lock()
    else
        Unlock()
    end
end

SLASH_CASTBARMOVER1 = "/castbar"
SLASH_CASTBARMOVER2 = "/cb"
SlashCmdList["CASTBARMOVER"] = function()
    local ok, err = pcall(ToggleLock)
    if not ok then
        print(PREFIX .. "|cffFF0000erro:|r " .. tostring(err))
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    local ok, err = pcall(ApplySavedPosition)
    if not ok then
        print(PREFIX .. "|cffFF0000erro ao aplicar posição salva:|r " .. tostring(err))
    end
end)
