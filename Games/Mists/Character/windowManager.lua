---@class GW2
local GW = select(2, ...)


local hideCharframe = true

local windowsList = {
    {
        OnLoad = "LoadPaperDoll",
        SettingName = "USE_CHARACTER_WINDOW",
        TabIcon = "tabicon_character",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
        HeaderText = CHARACTER,
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
        ]=]
    },
    {
        OnLoad = "LoadReputation",
        SettingName = "USE_CHARACTER_WINDOW",
        TabIcon = "tabicon_reputation",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png",
        HeaderText = REPUTATION,
        Bindings = {
            TOGGLECHARACTER2 = "Reputation"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
        ]=]
    },
    {
        OnLoad = "LoadTalents",
        SettingName = "USE_TALENT_WINDOW",
        TabIcon = "tabicon-talents",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/talents-window-icon.png",
        HeaderText = TALENTS,
        Bindings = {
            TOGGLETALENTS = "Talents"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
        ]=]
    },
    {
        OnLoad = "LoadSpellBook",
        SettingName = "USE_SPELLBOOK_WINDOW",
        TabIcon = "tabicon_spellbook",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon.png",
        HeaderText = SPELLS,
        Bindings = {
            TOGGLESPELLBOOK = "SpellBook",
            TOGGLEPETBOOK = "PetBook"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
        ]=]
    },
    {
        OnLoad = "LoadGlyphes",
        SettingName = "USE_TALENT_WINDOW",
        TabIcon = "tabicon-glyph",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/glyph-window-icon.png",
        HeaderText = GLYPHS,
        Bindings = {
            TOGGLEINSCRIPTION = "Glyphes"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "glyphes")
        ]=]
    },
    {
        OnLoad = "LoadCurrency",
        SettingName = "USE_CHARACTER_WINDOW",
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
        OnLoad = "LoadProfessions",
        FrameName = "GwProfessionsDetailsFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwProfessionsFrame",
        TabIcon = "tabicon_professions",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/professions-window-icon.png",
        HeaderText = TRADE_SKILLS,
        TooltipText = TRADE_SKILLS,
        Bindings = {
            TOGGLEPROFESSIONBOOK = "Professions",
            TOGGLECHARACTER1 = "Professions"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "professions")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = [=[
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
    elseif button == "SpellBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "spellbook")
    elseif button == "PetBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "petbook")
    elseif button == "Glyphes" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "glyphes")
    elseif button == "Currency" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "currency")
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetPaperDollFrame" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollpet")
    elseif button == "Titles" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "titles")
    elseif button == "GearSet" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "gearset")
    elseif button == "Equipemnt" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "equipment")
    elseif button == "Professions" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "professions")
    end
]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwCharacterWindowContainer")
    local fmDollMenu = self:GetFrameRef("GwHeroPanelMenu")
    local fmDollRepu = self:GetFrameRef("GwPaperReputationContainer")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local fmDollTitles = self:GetFrameRef("GwTitleWindow")
    local fmDollGearSets = self:GetFrameRef("GwPaperGearSets")
    local fmDollBagItemList = self:GetFrameRef("GwPaperDollBagItemList")

    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollTitles = false
    local showDollGearSets = false
    local showDollEquipment = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbook")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = false
    local fmGlyphes = self:GetFrameRef("GwGlyphesFrame")
    local showGlyphes = false
    local fmCurrency = self:GetFrameRef("GwCurrencyDetailsFrame")
    local showCurrency = false
    local fmProf = self:GetFrameRef("GwProfessionsFrame")
    local showProf = false

    local hasPetUI = self:GetAttribute("HasPetUI")

    local close = false
    local keytoggle = self:GetAttribute("keytoggle")

    if fmTal ~= nil and value == "talents" then
        if keytoggle and fmTal:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showTal = true
        end
    elseif fmGlyphes ~= nil and value == "glyphes" then
        if keytoggle and fmGlyphes:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showGlyphes = true
        end
    elseif fmCurrency ~= nil and value == "currency" then
        if keytoggle and fmCurrency:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCurrency = true
        end
    elseif fmSBM ~= nil and value == "spellbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmSBM ~= nil and value == "petbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmProf ~= nil and value == "professions" then
        if keytoggle and fmProf:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showProf = true
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() and (not fmDollPetCont:IsVisible() and not fmDollTitles:IsVisible() and not fmDollGearSets:IsVisible() and not fmDollBagItemList:IsVisible()) then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDoll = true
        end
    elseif fmDollRepu ~= nil and value == "reputation" then
        if keytoggle and fmDollRepu:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollRepu = true
        end
    elseif fmDollTitles ~= nil and value == "titles" then
        if keytoggle and fmDollTitles:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollTitles = true
        end
    elseif fmDollGearSets ~= nil and value == "gearset" then
        if keytoggle and fmDollGearSets:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollGearSets = true
        end
    elseif fmDollBagItemList ~= nil and value == "equipment" then
        if keytoggle and fmDollBagItemList:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollEquipment = true
        end
    elseif fmDollPetCont ~= nil and value == "paperdollpet" and hasPetUI then
        if keytoggle and fmDollPetCont:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollPetCont = true
        end
    else
        close = true
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if fmDoll then
        if showDoll and not close then
            fmDoll:Show()
            fmDollMenu:Show()
            fmDollDress:Show()

            fmDollRepu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
            fmDollBagItemList:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmTal then
        if showTal and not close then
            fmTal:Show()
        else
            fmTal:Hide()
        end
    end
    if fmGlyphes then
        if showGlyphes and not close then
            fmGlyphes:Show()
        else
            fmGlyphes:Hide()
        end
    end
    if fmCurrency then
        if showCurrency and not close then
            fmCurrency:Show()
        else
            fmCurrency:Hide()
        end
    end
    if fmProf then
        if showProf and not close then
            fmProf:Show()
        else
            fmProf:Hide()
        end
    end
    if fmSBM then
        if showSpell and not close then
            fmSBM:Show()
        else
            fmSBM:Hide()
        end
    end
    if fmDollRepu then
        if showDollRepu and not close then
            fmDollRepu:Show()
        else
            fmDollRepu:Hide()
        end
    end
    if fmDollPetCont and showDollPetCont then
        if showDollPetCont and not close then
            fmDoll:Show()
            fmDollPetCont:Show()

            fmDollDress:Hide()
            fmDollMenu:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
            fmDollBagItemList:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollTitles and showDollTitles then
        if showDollTitles and not close then
            fmDoll:Show()
            fmDollTitles:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollGearSets and showDollGearSets then
        if showDollGearSets and not close then
            fmDoll:Show()
            fmDollGearSets:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollBagItemList:Hide()
        else
            fmDoll:Hide()
        end
    end

    if fmDollBagItemList and showDollEquipment then
        if showDollEquipment and not close then
            fmDoll:Show()
            fmDollBagItemList:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end

    if close then
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
        self:CallMethod("AnimatePanelSwitch", value)
    end
]=]

local function LoadCharacter()
    if InCombatLockdown() then
        GW.CombatQueue_Queue("load_character_window", LoadCharacter)
        return
    end

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
            local container = GW[v.OnLoad](baseFrame)
            local tab = GW.CreateCharacterWindowTabIcon(v.TabIcon, tabIndex)

            baseFrame:SetFrameRef(container:GetName(), container)
            container:SetScript("OnShow", GW.CharacterWindowContainer_OnShow)
            container:SetScript("OnHide", GW.CharacterWindowContainer_OnHide)
            tab:SetFrameRef("GwCharacterWindow", baseFrame)
            tab:SetAttribute("_OnClick", v.OnClick)

            container.TabFrame = tab
            container.CharWindow = baseFrame
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.HeaderText

            tab:SetScript("OnEnter", GW.CharacterWindowTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            if container:GetName() == "GwCharacterWindowContainer" then
                baseFrame:SetHeroPanelMenu(GwHeroPanelMenu)
                baseFrame:SetFrameRef("GwHeroPanelMenu", GwHeroPanelMenu)
                baseFrame:SetFrameRef("GwTitleWindow", GwTitleWindow)
                baseFrame:SetFrameRef("GwDressingRoom", GwDressingRoom)
                baseFrame:SetFrameRef("GwPetContainer", GwPetContainer)
                baseFrame:SetFrameRef("GwPaperGearSets", GwPaperDollOutfits)
                baseFrame:SetFrameRef("GwPaperDollBagItemList", GwPaperDollBagItemList)

                GW.CharacterMenuButton_OnLoad(GwHeroPanelMenu.titleMenu, true, true)
                GW.CharacterMenuButton_OnLoad(GwHeroPanelMenu.gearMenu, false, true)
                GW.CharacterMenuButton_OnLoad(GwHeroPanelMenu.equipmentMenu, true, true)
                GW.CharacterMenuButton_OnLoad(GwHeroPanelMenu.petMenu, false, true)

                -- add addon buttons here
                baseFrame:SetAttribute("myClassId", GW.myClassID)
                if GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6 then
                    baseFrame:SetNextAddonMenuButtonShadowState(true)
                else
                    baseFrame:SetNextAddonMenuButtonShadowState(false)
                end
                baseFrame:SetNextAddonMenuButtonAnchor((GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6) and GwHeroPanelMenu.petMenu or GwHeroPanelMenu.equipmentMenu)
                GwHeroPanelMenu.Outfitter = GW.AddAddonMenuButtonToHeroPanelMenu({
                    name = "Outfitter",
                    setting = GW.settings.USE_CHARACTER_WINDOW,
                    showFunction = function() hideCharframe = false Outfitter:OpenUI() end,
                    hideOurFrame = true,
                })

                GwHeroPanelMenu["GearQuipper-TBC"] = GW.AddAddonMenuButtonToHeroPanelMenu({
                    name = "GearQuipper-TBC",
                    setting = GW.settings.USE_CHARACTER_WINDOW,
                    showFunction = function() gearquipper:ToggleUI() end,
                    hideOurFrame = false,
                    onCreated = function(createdButton)
                        createdButton:SetText("GearQuipper")
                        GqUiFrame:ClearAllPoints()
                        GqUiFrame:SetParent(GwCharacterWindow)
                        GqUiFrame:SetPoint("TOPRIGHT", GwCharacterWindow, "TOPRIGHT", 350, -12)
                    end,
                })
                GwHeroPanelMenu.Clique = GW.AddAddonMenuButtonToHeroPanelMenu({
                    name = "Clique",
                    setting = GW.settings.USE_SPELLBOOK_WINDOW,
                    showFunction = function() ShowUIPanel(CliqueConfig) end,
                    hideOurFrame = true,
                })

                GwHeroPanelMenu.Pawn = GW.AddAddonMenuButtonToHeroPanelMenu({
                    name = "Pawn",
                    setting = GW.settings.USE_CHARACTER_WINDOW,
                    showFunction = PawnUIShow,
                    hideOurFrame = false,
                })

                GW.ToggleCharacterItemInfo(true)

                GW.SetCharacterWindowOpenAttribute(GwHeroPanelMenu.titleMenu, "titles")
                GW.SetCharacterWindowOpenAttribute(GwHeroPanelMenu.gearMenu, "gearset")
                GW.SetCharacterWindowOpenAttribute(GwHeroPanelMenu.equipmentMenu, "equipment")
                GW.SetCharacterWindowOpenAttribute(GwHeroPanelMenu.petMenu, "paperdollpet")

                -- pet GwDressingRoom
                GwHeroPanelMenu.petMenu:SetAttribute("_onstate-petstate", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    local myClassId = f:GetAttribute("myClassId")
                    if myClassId == 3 or myClassId == 6 or myClassId == 9 then
                        self:Show()
                    else
                        self:Hide()
                    end
                    if newstate == "nopet" then
                        self:Disable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
                    elseif newstate == "hasPet" then
                        self:Enable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
                    end
                ]=])
                RegisterAttributeDriver(GwHeroPanelMenu.petMenu, "state-petstate", "[@pet,noexists] nopet; [@pet,help] hasPet; [@pet,harm] nopet")
            end
            v.TabFrame = tab

            tabIndex = tabIndex + 1
        end
    end

    if GW.settings.USE_CHARACTER_WINDOW then
        CharacterFrame:SetScript("OnShow", function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end)

        CharacterFrame:UnregisterAllEvents()
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    baseFrame.UpdateBindings()
end
GW.LoadCharacter = LoadCharacter
