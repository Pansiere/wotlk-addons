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

local function Slugify(itemName)
    return itemName:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
end

local function BuildExportText()
    local lines = {}
    for _, entry in ipairs(SLOT_ORDER) do
        local link = GetInventoryItemLink("player", entry.slot)
        if link then
            local itemId = link:match("item:(%d+)")
            if itemId then
                local itemName = GetItemInfo(link)
                local slug = itemName and Slugify(itemName) or "item"
                table.insert(lines, entry.name .. "=" .. slug .. ",id=" .. itemId)
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

local function OpenExportWindow()
    editBox:SetText(BuildExportText())
    frame:Show()
    editBox:SetFocus()
    editBox:HighlightText()
end

SLASH_ARMORYBREXPORT1 = "/armorybr"
SLASH_ARMORYBREXPORT2 = "/abr"
SlashCmdList["ARMORYBREXPORT"] = OpenExportWindow
