---@class GW2
local GW = select(2, ...)

local fmMenu
local hideCharframe = true
local dressingRoom
local paperDollBagItemList
local paperDollOutfits
local paperDollTitles

local function characterPanelToggle(frame)
    if InCombatLockdown() then
        GW.Notice(ERR_NOT_IN_COMBAT)
        return
    end
    fmMenu:Hide()
    paperDollBagItemList:Hide()
    paperDollOutfits:Hide()
    paperDollTitles:Hide()

    if frame == nil then
        dressingRoom:Hide()
        return
    end

    frame:Show()
    dressingRoom:Show()
end


local function toggleCharacter(tab, onlyShow)
    -- TODO: update bag frame to a secure stack, or at least the currency icon
    if InCombatLockdown() then
        return
    end

    if tab == "ReputationFrame" then
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "reputation")
    elseif tab == "TokenFrame" then
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
    else
        -- PaperDollFrame or any other value
        if not onlyShow then
            GwCharacterWindow:SetAttribute("keytoggle", true)
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", "character")
    end
end

local function menuItem_OnClick(self)
    characterPanelToggle(self.ToggleMe)
end


local function menu_SetupBackButton(_, fmBtn, key)
    GW.CharacterMenuButtonBack_OnLoad(fmBtn, key, false)
    fmBtn:SetScript("OnClick", function() characterPanelToggle(fmMenu) end)
end

local function LoadPaperDoll(tabContainer)
    fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterPanelMenuTemplate")
    GwCharacterWindow:SetHeroPanelMenu(fmMenu)
    fmMenu.SetupBackButton = menu_SetupBackButton

    dressingRoom, paperDollBagItemList = GW.LoadPDBagList(fmMenu, tabContainer)
    paperDollOutfits = GW.LoadPDEquipset(fmMenu, tabContainer)
    paperDollTitles = GW.LoadPDTitles(fmMenu, tabContainer)

    fmMenu.equipmentMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterPanelMenuButtonTemplate")
    fmMenu.equipmentMenu.ToggleMe = paperDollBagItemList
    fmMenu.equipmentMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.equipmentMenu:SetText(BAG_FILTER_EQUIPMENT)
    fmMenu.equipmentMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    fmMenu.equipmentMenu:ClearAllPoints()
    fmMenu.equipmentMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")

    fmMenu.outfitsMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterPanelMenuButtonTemplate")
    fmMenu.outfitsMenu.ToggleMe = paperDollOutfits
    fmMenu.outfitsMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.outfitsMenu:SetText(EQUIPMENT_MANAGER)
    fmMenu.outfitsMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    fmMenu.outfitsMenu:ClearAllPoints()
    fmMenu.outfitsMenu:SetPoint("TOPLEFT", fmMenu.equipmentMenu, "BOTTOMLEFT")

    fmMenu.titlesMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterPanelMenuButtonTemplate")
    fmMenu.titlesMenu.ToggleMe = paperDollTitles
    fmMenu.titlesMenu:SetScript("OnClick", menuItem_OnClick)
    fmMenu.titlesMenu:SetText(PAPERDOLL_SIDEBAR_TITLES)
    fmMenu.titlesMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    fmMenu.titlesMenu:ClearAllPoints()
    fmMenu.titlesMenu:SetPoint("TOPLEFT", fmMenu.outfitsMenu, "BOTTOMLEFT")

    GW.CharacterMenuButton_OnLoad(fmMenu.equipmentMenu, true)
    GW.CharacterMenuButton_OnLoad(fmMenu.outfitsMenu, false)
    GW.CharacterMenuButton_OnLoad(fmMenu.titlesMenu, true)
    GW.SetCharacterWindowOpenAttribute(fmMenu.equipmentMenu, "paperdollequipment", false)
    GW.SetCharacterWindowOpenAttribute(fmMenu.outfitsMenu, "paperdolloutfits", false)
    GW.SetCharacterWindowOpenAttribute(fmMenu.titlesMenu, "paperdolltitles", false)

    -- pull corruption thingy from default paperdoll
    if (CharacterStatsPane and CharacterStatsPane.ItemLevelFrame) then
        local cpt = CharacterStatsPane.ItemLevelFrame.Corruption
        local attr = dressingRoom.stats
        if (cpt and attr) then
            cpt:SetParent(attr)
            cpt:ClearAllPoints()
            cpt:SetPoint("TOPRIGHT", attr, "TOPRIGHT", 22, 28)
        end
    end

    --AddOn Support
    GwCharacterWindow:SetNextAddonMenuButtonShadowState(false)
    GwCharacterWindow:SetNextAddonMenuButtonAnchor(fmMenu.titlesMenu)
    fmMenu.Pawn = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Pawn",
        showFunction = PawnUIShow,
        hideOurFrame = true,
    })

    fmMenu.Clique = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Clique",
        showFunction = function() ShowUIPanel(CliqueConfig) end,
        hideOurFrame = true,
    })

    fmMenu.Outfitter = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Outfitter",
        setting = GW.settings.USE_CHARACTER_WINDOW,
        showFunction = function() hideCharframe = false Outfitter:OpenUI() end,
        hideOurFrame = true,
    })

    fmMenu.MyRolePlay = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "MyRolePlay",
        setting = GW.settings.USE_CHARACTER_WINDOW,
        showFunction = function() hideCharframe = false ToggleCharacter("MyRolePlayCharacterFrame") end,
        hideOurFrame = true,
    })

    fmMenu.TalentSetManager = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "TalentSetManager",
        setting = GW.settings.USE_TALENT_WINDOW,
        showFunction = function() TalentFrame_LoadUI() if PlayerTalentFrame_Toggle then PlayerTalentFrame_Toggle(TALENTS_TAB) end end,
        hideOurFrame = true,
    })

    fmMenu.ItemUpgradeTip = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "ItemUpgradeTip",
        showFunction = function() if ItemUpgradeTip then ItemUpgradeTip:ToggleView() end end,
        hideOurFrame = true,
    })

    GW.ToggleCharacterItemInfo(true)
    CharacterFrame:SetScript(
        "OnShow",
        function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end
    )

    CharacterFrame:UnregisterAllEvents()

    hooksecurefunc("ToggleCharacter", toggleCharacter)
    hooksecurefunc("PaperDollFrame_UpdateCorruptedItemGlows", function(glow)
        for _, v in pairs(GW.char_equipset_SavedItems) do
            if v.HasPaperDollAzeriteItemOverlay then
                v:UpdateCorruptedGlow(ItemLocation:CreateFromEquipmentSlot(v:GetID()), glow)
            end
        end
    end)
    dressingRoom.background:AddMaskTexture(tabContainer.CharWindow.backgroundMask)
end
GW.LoadPaperDoll = LoadPaperDoll
