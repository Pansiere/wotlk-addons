-- Destrava a barra de cast nativa da Blizzard (CastingBarFrame, a mesma
-- que mostra o progresso ao conjurar) para poder arrastar e reposicionar.
-- Não mexe na barra de verdade enquanto ela está em uso: mostra um
-- retângulo "proxy" do mesmo tamanho pra arrastar, e só aplica a posição
-- na barra real quando você confirma (rodando o comando de novo).

local PREFIX = "|cff00ccff[CastBarMover]|r "

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
label:SetText("Cast Bar (arraste e rode /castbar de novo)")

mover:SetMovable(true)
mover:EnableMouse(true)
mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", mover.StartMoving)
mover:SetScript("OnDragStop", mover.StopMovingOrSizing)

-- Posiciona o proxy em cima de onde a CastingBarFrame está agora, do
-- mesmo tamanho, pra começar a arrastar de um lugar que faz sentido.
local function SyncMoverToCastBar()
    local width, height = CastingBarFrame:GetSize()
    mover:SetSize(width, height)

    local point, _, relativePoint, x, y = CastingBarFrame:GetPoint()
    mover:ClearAllPoints()
    mover:SetPoint(point or "CENTER", UIParent, relativePoint or "CENTER", x or 0, y or 0)
end

-- Copia a posição do proxy pra barra real e salva pra persistir entre
-- sessões. Reancora relativo a UIParent (a tela) em vez do frame original
-- (geralmente PlayerFrame) - é isso que "destrava" a posição de verdade.
local function ApplyMoverToCastBar()
    local point, _, relativePoint, x, y = mover:GetPoint()

    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint(point, UIParent, relativePoint, x, y)

    CastBarMoverDB.point = point
    CastBarMoverDB.relativePoint = relativePoint
    CastBarMoverDB.x = x
    CastBarMoverDB.y = y
end

local function ApplySavedPosition()
    local db = CastBarMoverDB
    if db.point then
        CastingBarFrame:ClearAllPoints()
        CastingBarFrame:SetPoint(db.point, UIParent, db.relativePoint, db.x, db.y)
    end
end

local function Unlock()
    SyncMoverToCastBar()
    mover:Show()
    unlocked = true
    print(PREFIX .. "arraste o retângulo azul pra onde quiser a barra de cast. Rode /castbar (ou /cb) de novo pra confirmar.")
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

-- PLAYER_LOGIN sozinho não é garantia: dispara uma vez no início do
-- carregamento, e se algo mais tarde no processo reancorar a CastingBarFrame
-- por conta própria, a posição salva fica sobrescrita silenciosamente.
-- PLAYER_ENTERING_WORLD dispara depois (inclusive de novo em qualquer
-- loading screen/teleporte) - reaplicar ali também é uma garantia extra sem
-- efeito colateral, já que é sempre a mesma posição salva sendo reaplicada.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    local ok, err = pcall(ApplySavedPosition)
    if not ok then
        print(PREFIX .. "|cffFF0000erro ao aplicar posição salva:|r " .. tostring(err))
    end
end)
