-- Exporta o equipamento do personagem no formato que o parser de import
-- do armory-br já reconhece: linhas "slot=nome,id=NUMERO" (mesmo padrão
-- que um perfil do SimulationCraft usa). Só usa API nativa do 3.3.5a —
-- sem libs externas, sem depender de nenhum addon de terceiro.

local SLOT_ORDER = {
    { slot = INVSLOT_HEAD, name = "head" },
    { slot = INVSLOT_NECK, name = "neck" },
    { slot = INVSLOT_SHOULDER, name = "shoulder" },
    { slot = INVSLOT_BACK, name = "back" },
    { slot = INVSLOT_CHEST, name = "chest" },
    { slot = INVSLOT_BODY, name = "shirt" },
    { slot = INVSLOT_TABARD, name = "tabard" },
    { slot = INVSLOT_WRIST, name = "wrist" },
    { slot = INVSLOT_HAND, name = "hand" },
    { slot = INVSLOT_WAIST, name = "waist" },
    { slot = INVSLOT_LEGS, name = "legs" },
    { slot = INVSLOT_FEET, name = "feet" },
    { slot = INVSLOT_FINGER1, name = "finger1" },
    { slot = INVSLOT_FINGER2, name = "finger2" },
    { slot = INVSLOT_TRINKET1, name = "trinket1" },
    { slot = INVSLOT_TRINKET2, name = "trinket2" },
    { slot = INVSLOT_MAINHAND, name = "main_hand" },
    { slot = INVSLOT_OFFHAND, name = "off_hand" },
    { slot = INVSLOT_RANGED, name = "ranged" },
}

-- raceID (3º retorno de UnitRace) em vez do nome textual: não depende do
-- idioma do client nem de variações de grafia ("Undead" vs "Scourge").
local RACE_ID_SLUG = {
    [1] = "human", [2] = "orc", [3] = "dwarf", [4] = "night_elf",
    [5] = "undead", [6] = "tauren", [7] = "gnome", [8] = "troll",
    [10] = "blood_elf", [11] = "draenei",
}

-- GetProfessionInfo só existe a partir do Patch 4.0.1 (Cataclysm) - em
-- 3.3.5a chamar essa função é erro fatal de Lua ("attempt to call a nil
-- value"), que para a execução no meio e explica um /armorybr que "não
-- fazia nada" (o comando estava registrado, só a função crashava antes de
-- mostrar a janela). GetSkillLineInfo é a API de antes: foi removida no
-- mesmo patch que introduziu GetProfessionInfo, ou seja, existe em 3.3.5a.
-- Ela não dá o skillLine numérico, só o nome já traduzido pro idioma do
-- client - comparamos contra nomes em inglês porque o client instalado é
-- enUS (Data/enUS na pasta do jogo).
local PROFESSION_NAME_SLUG = {
    ["Alchemy"] = "alchemy", ["Blacksmithing"] = "blacksmithing",
    ["Enchanting"] = "enchanting", ["Engineering"] = "engineering",
    ["Herbalism"] = "herbalism", ["Inscription"] = "inscription",
    ["Jewelcrafting"] = "jewelcrafting", ["Leatherworking"] = "leatherworking",
    ["Mining"] = "mining", ["Skinning"] = "skinning", ["Tailoring"] = "tailoring",
    ["Cooking"] = "cooking", ["First Aid"] = "first_aid", ["Fishing"] = "fishing",
}

local function BuildCharacterMetaLines()
    local lines = {}

    table.insert(lines, "name=" .. UnitName("player"))

    local _, _, raceId = UnitRace("player")
    local raceSlug = RACE_ID_SLUG[raceId]
    if raceSlug then
        table.insert(lines, "race=" .. raceSlug)
    end

    table.insert(lines, "level=" .. UnitLevel("player"))

    -- pairs(), não ipairs(): GetProfessions() retorna 6 valores na ordem
    -- fixa (prof1, prof2, archaeology, fishing, cooking, firstAid), e
    -- archaeology é sempre nil em WotLK — ipairs pararia aí e nunca
    -- chegaria em fishing/cooking/firstAid, que vêm depois na lista.
    for i = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
        local slug = (not isHeader) and PROFESSION_NAME_SLUG[skillName] or nil
        if slug then
            table.insert(lines, "profession=" .. slug .. ":" .. (skillRank or 0))
        end
    end

    return lines
end

local function Slugify(itemName)
    return itemName:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
end

-- Gemas engastadas nos sockets do item, na ordem dos sockets (até 3).
-- GetItemGem retorna nil pro socket quando ele está vazio ou o item não
-- tem socket naquela posição — ambos os casos são pulados.
local function GetGemIds(itemLink)
    local gemIds = {}
    for socketIndex = 1, 3 do
        local _, gemLink = GetItemGem(itemLink, socketIndex)
        local gemId = gemLink and gemLink:match("item:(%d+)")
        if gemId then
            table.insert(gemIds, gemId)
        end
    end
    return gemIds
end

local function BuildExportText()
    local lines = BuildCharacterMetaLines()
    for _, entry in ipairs(SLOT_ORDER) do
        local link = GetInventoryItemLink("player", entry.slot)
        if link then
            local itemId = link:match("item:(%d+)")
            if itemId then
                local itemName = GetItemInfo(link)
                local slug = itemName and Slugify(itemName) or "item"
                local line = entry.name .. "=" .. slug .. ",id=" .. itemId

                local gemIds = GetGemIds(link)
                if #gemIds > 0 then
                    line = line .. ",gems=" .. table.concat(gemIds, "/")
                end

                table.insert(lines, line)
            end
        end
    end
    return table.concat(lines, "\n")
end

local frame = CreateFrame("Frame", "ArmoryBRExportFrame", UIParent)
frame:SetSize(480, 420)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Armory BR - Exportar equipamento")

local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hint:SetPoint("TOP", title, "BOTTOM", 0, -6)
hint:SetText("Ctrl+A pra selecionar tudo, Ctrl+C pra copiar, e cole no armory-br.")

local closeButton = CreateFrame("Button", "ArmoryBRExportCloseButton", frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -4, -4)

local scrollFrame = CreateFrame("ScrollFrame", "ArmoryBRExportScroll", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 20, -60)
scrollFrame:SetPoint("BOTTOMRIGHT", -36, 20)

local editBox = CreateFrame("EditBox", "ArmoryBRExportEditBox", scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(400)
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function()
    frame:Hide()
end)
scrollFrame:SetScrollChild(editBox)

-- pcall pra nunca falhar em silêncio: sem isso, um erro de Lua no meio da
-- geração do texto (ex.: chamar uma API que não existe nesse client) para a
-- execução sem avisar nada — foi exatamente assim que a versão anterior
-- desse addon "não fazia nada" ao rodar o comando.
local function OpenExportWindow()
    local ok, textOrError = pcall(BuildExportText)

    if not ok then
        print("|cffFF0000[ArmoryBRExport] Erro ao gerar o export:|r " .. tostring(textOrError))
        return
    end

    editBox:SetText(textOrError)
    frame:Show()
    editBox:SetFocus()
    editBox:HighlightText()
end

SLASH_ARMORYBREXPORT1 = "/armorybr"
SLASH_ARMORYBREXPORT2 = "/abr"
SlashCmdList["ARMORYBREXPORT"] = OpenExportWindow
