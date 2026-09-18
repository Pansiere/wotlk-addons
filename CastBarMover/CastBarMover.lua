-- Destrava a barra de cast nativa da Blizzard (CastingBarFrame, a mesma
-- que mostra o progresso ao conjurar) para poder arrastar e reposicionar.
-- Não mexe na barra de verdade enquanto ela está em uso: mostra um
-- retângulo "proxy" do mesmo tamanho pra arrastar, e só aplica a posição
-- na barra real quando você confirma (rodando o comando de novo).
--
-- Só se move na vertical: sempre ancorado em BOTTOM/UIParent/BOTTOM (mesmo
-- ponto que a Blizzard usa nativamente) com X preso em 0. O arrasto é
-- calculado manualmente a partir da posição do cursor (GetCursorPosition +
-- GetEffectiveScale), não via StartMoving() nativo — isso considera a
-- escala do frame explicitamente, que StartMoving() sozinho não garante.

local PREFIX = "|cff00ccff[CastBarMover]|r "
local ANCHOR_POINT = "BOTTOM"
local ANCHOR_RELATIVE_POINT = "BOTTOM"
local DEFAULT_Y = 250

-- Tamanho nativo real da CastingBarFrame, confirmado no FrameXML original
-- da Blizzard (<Size><AbsDimension x="195" y="13"/></Size> em
-- CastingBarFrame.xml) - nunca lido dinamicamente via GetSize(), porque se
-- o tamanho real já estivesse errado por qualquer motivo, ler e reaplicar
-- esse valor perpetuaria o erro.
local CASTBAR_WIDTH = 195
local CASTBAR_HEIGHT = 13

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

mover:SetMovable(true)
mover:EnableMouse(true)
mover:RegisterForDrag("LeftButton")

local dragStartCursorY, dragStartFrameY

mover:SetScript("OnDragStart", function(self)
    local _, cursorY = GetCursorPosition()
    dragStartCursorY = cursorY
    local _, _, _, _, y = self:GetPoint()
    dragStartFrameY = y or DEFAULT_Y

    self:SetScript("OnUpdate", function(self)
        local _, currentCursorY = GetCursorPosition()
        -- GetCursorPosition() retorna em pixels de tela reais; o frame
        -- está num sistema de coordenadas escalado por GetEffectiveScale()
        -- (a escala do frame multiplicada pela de todos os pais) - sem
        -- dividir por ela aqui, mover a barra com o mouse ficaria rápido
        -- ou lento demais dependendo da escala da UI, e em casos extremos
        -- de escala muito pequena um pequeno movimento de mouse vira um
        -- deltaY gigante.
        local scale = self:GetEffectiveScale()
        local deltaY = (currentCursorY - dragStartCursorY) / scale
        local newY = dragStartFrameY + deltaY

        self:ClearAllPoints()
        self:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, newY)
    end)
end)

mover:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-- Posiciona o proxy com o tamanho nativo fixo, começando da última posição
-- salva (ou um valor razoável se nunca foi customizada).
local function SyncMoverToCastBar()
    mover:SetSize(CASTBAR_WIDTH, CASTBAR_HEIGHT)
    mover:ClearAllPoints()
    mover:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, CastBarMoverDB.y or DEFAULT_Y)
end

local function ApplyMoverToCastBar()
    local _, _, _, _, y = mover:GetPoint()

    CastingBarFrame:SetScale(1)
    CastingBarFrame:SetSize(CASTBAR_WIDTH, CASTBAR_HEIGHT)
    CastingBarFrame:ClearAllPoints()
    CastingBarFrame:SetPoint(ANCHOR_POINT, UIParent, ANCHOR_RELATIVE_POINT, 0, y)

    CastBarMoverDB.y = y
end

local function ApplySavedPosition()
    if CastBarMoverDB.y then
        CastingBarFrame:SetScale(1)
        CastingBarFrame:SetSize(CASTBAR_WIDTH, CASTBAR_HEIGHT)
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

-- Aplicar direto no handler do evento às vezes não "pega": CastingBarFrame
-- é um frame nativo crítico, e mexer nele bem no instante do login pode
-- cair numa janela de proteção do client (sem gerar erro Lua nenhum - a
-- chamada roda normal, só o resultado visual não reflete). Em vez de
-- aplicar uma vez só ali, tenta de novo em alguns instantes seguintes
-- (sem C_Timer, que não existe em 3.3.5a: um frame com OnUpdate contando
-- o tempo decorrido é a forma clássica de fazer "esperar X segundos").
local retryFrame = CreateFrame("Frame")
local retryElapsed = 0
local retryMarks = { 0.5, 1.5, 3 }
local retryIndex = 0

local function TryApplySavedPosition()
    local ok, err = pcall(ApplySavedPosition)
    if not ok then
        print(PREFIX .. "|cffFF0000erro ao aplicar posição salva:|r " .. tostring(err))
    end
end

local function OnRetryUpdate(self, elapsed)
    retryElapsed = retryElapsed + elapsed
    if retryIndex < #retryMarks and retryElapsed >= retryMarks[retryIndex + 1] then
        retryIndex = retryIndex + 1
        TryApplySavedPosition()
        if retryIndex >= #retryMarks then
            self:SetScript("OnUpdate", nil)
        end
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    TryApplySavedPosition()
    -- reinicia as tentativas seguintes (PLAYER_ENTERING_WORLD pode disparar
    -- de novo em qualquer loading screen, então vale tentar de novo cada vez)
    retryElapsed = 0
    retryIndex = 0
    retryFrame:SetScript("OnUpdate", OnRetryUpdate)
end)
