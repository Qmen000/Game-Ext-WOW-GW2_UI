---@class GW2
local GW = select(2, ...)

local windowsList = {
    {
        OnLoad = "LoadPaperDoll",
        FrameName = "GwPaperDollDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwPaperDoll",
        TabIcon = "tabicon_character",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
        HeaderText = CHARACTER,
        TooltipText = CHARACTER_BUTTON,
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
        ]=]
    },
    {
        OnLoad = "LoadProfessions",
        FrameName = "GwProfessionsDetailsFrame",
        SettingName = "USE_PROFESSION_WINDOW",
        RefName = "GwProfessionsFrame",
        TabIcon = "tabicon_professions",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
        HeaderText = TRADE_SKILLS,
        TooltipText = TRADE_SKILLS,
        Bindings = {
            TOGGLEPROFESSIONBOOK = "Professions"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
        ]=]
    },
    {
        OnLoad = "LoadCurrency",
        FrameName = "GwCurrencyDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwCurrencyFrame",
        TabIcon = "tabicon_currency",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon.png",
        HeaderText = CURRENCY,
        TooltipText = CURRENCY,
        Bindings = {
            TOGGLECURRENCY = "Currency"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
        ]=]
    },
    {
        OnLoad = "LoadReputation",
        FrameName = "GwReputationDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwReputationFrame",
        TabIcon = "tabicon_reputation",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/reputation-window-icon.png",
        HeaderText = REPUTATION,
        TooltipText = REPUTATION,
        Bindings = {
            TOGGLECHARACTER2 = "Reputation"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick =
    [=[
    --print("secure click handler button: " .. button)
    local f = self:GetFrameRef("GwCharacterWindow")
    if button == "Close" then
        f:SetAttribute("windowpanelopen", nil)
    elseif button == "PaperDoll" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdoll")
    elseif button == "Reputation" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "reputation")
    elseif button == "Currency" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "currency")
    elseif button == "Professions" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "professions")
    end
    ]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then return end

    -- frames
    local doll = self:GetFrameRef("GwPaperDoll")
    local rep = self:GetFrameRef("GwReputationFrame")
    local cur = self:GetFrameRef("GwCurrencyFrame")
    local prof = self:GetFrameRef("GwProfessionsFrame")
    local dollMenu = self:GetFrameRef("GwPaperDollMenu")
    local dollDress = self:GetFrameRef("GwPaperDollDressingRoom")
    local dollEquipment = self:GetFrameRef("GwPaperDollEquipment")
    local dollOutfits = self:GetFrameRef("GwPaperDollOutfits")
    local dollTitles = self:GetFrameRef("GwPaperDollTitles")

    local keytoggle = self:GetAttribute("keytoggle")
    local selected = value

    if selected == "paperdoll" or selected == "character" or selected == "paperdollequipment" or selected == "paperdolloutfits" or selected == "paperdolltitles" then
        if doll then
            local activeFrame = doll
            if selected == "paperdollequipment" then
                activeFrame = dollEquipment or doll
            elseif selected == "paperdolloutfits" then
                activeFrame = dollOutfits or doll
            elseif selected == "paperdolltitles" then
                activeFrame = dollTitles or doll
            end

            if keytoggle and activeFrame and activeFrame:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                doll:Show()
            end
        end
        if dollMenu then
            if selected == "paperdoll" or selected == "character" then
                dollMenu:Show()
            else
                dollMenu:Hide()
            end
        end
        if dollDress then
            dollDress:Show()
        end
        if dollEquipment then
            if selected == "paperdollequipment" then
                dollEquipment:Show()
            else
                dollEquipment:Hide()
            end
        end
        if dollOutfits then
            if selected == "paperdolloutfits" then
                dollOutfits:Show()
            else
                dollOutfits:Hide()
            end
        end
        if dollTitles then
            if selected == "paperdolltitles" then
                dollTitles:Show()
            else
                dollTitles:Hide()
            end
        end
        if rep then
            rep:Hide()
        end
        if cur then
            cur:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "reputation" then
        if rep then
            if keytoggle and rep:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                rep:Show()
            end
        end
        if doll then doll:Hide() end
        if dollMenu then dollMenu:Hide() end
        if dollDress then dollDress:Hide() end
        if dollEquipment then dollEquipment:Hide() end
        if dollOutfits then dollOutfits:Hide() end
        if dollTitles then dollTitles:Hide() end
        if cur then
            cur:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "currency" then
        if cur then
            if keytoggle and cur:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                cur:Show()
            end
        end
        if doll then doll:Hide() end
        if dollMenu then dollMenu:Hide() end
        if dollDress then dollDress:Hide() end
        if dollEquipment then dollEquipment:Hide() end
        if dollOutfits then dollOutfits:Hide() end
        if dollTitles then dollTitles:Hide() end
        if rep then
            rep:Hide()
        end
        if prof then
            prof:Hide()
        end
    elseif selected == "professions" then
        if prof then
            if keytoggle and prof:IsVisible() then
                self:SetAttribute("keytoggle", nil)
                self:SetAttribute("windowpanelopen", nil)
                return
            else
                prof:Show()
            end
        end
        if doll then doll:Hide() end
        if dollMenu then dollMenu:Hide() end
        if dollDress then dollDress:Hide() end
        if dollEquipment then dollEquipment:Hide() end
        if dollOutfits then dollOutfits:Hide() end
        if dollTitles then dollTitles:Hide() end
        if rep then
            rep:Hide()
        end
        if cur then
            cur:Hide()
        end
    else
        self:Hide()
        self:CallMethod("SoundExit")
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if not self:IsVisible() and value then
        self:Show()
        self:CallMethod("SoundOpen")
    elseif value then
        self:CallMethod("SoundSwap")
        self:CallMethod("AnimatePanelSwitch", selected)
    end
]=]


local function LoadCharacter()
    local anyThingToLoad = false
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    local baseFrame = GW.LoadCharacterWindowBase(charSecure_OnClick, charSecure_OnAttributeChanged, windowsList)

    local tabIndex = 1
    for _, v in pairs(windowsList) do
        if GW.settings[v.SettingName] then
            local container = CreateFrame("Frame", v.FrameName, baseFrame, "GwCharacterTabContainerTemplate")
            local tab = GW.CreateCharacterWindowTabIcon(v.TabIcon, tabIndex)

            baseFrame:SetFrameRef(v.RefName, container)
            container.TabFrame = tab
            container.CharWindow = baseFrame
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.TooltipText

            tab:SetScript("OnEnter", GW.CharacterWindowTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            v.TabFrame = tab
            tab:SetFrameRef("GwCharacterWindow", baseFrame)
            tab:SetAttribute("_onclick", v.OnClick)
            container:SetScript("OnShow", GW.CharacterWindowContainer_OnShow)
            container:SetScript("OnHide", GW.CharacterWindowContainer_OnHide)

            GW[v.OnLoad](container)
            baseFrame.dressingRoom = container.dressingRoom or baseFrame.dressingRoom

            tabIndex = tabIndex + 1
        end
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    baseFrame.UpdateBindings()
end
GW.LoadCharacter = LoadCharacter
