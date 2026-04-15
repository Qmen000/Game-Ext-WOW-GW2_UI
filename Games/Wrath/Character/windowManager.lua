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
        Bindings = {
            TOGGLECHARACTER0 = "PaperDoll",
            TOGGLECHARACTER1 = "Skills",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
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
        Bindings = {
            TOGGLECHARACTER2 = "Reputation"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
        ]=]
    },
    {
        OnLoad = "LoadTalents",
        FrameName = "GwTalentsFrame",
        SettingName = "USE_TALENT_WINDOW",
        RefName = "GwTalentsFrame",
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
        FrameName = "GwSpellbookFrame",
        SettingName = "USE_SPELLBOOK_WINDOW",
        RefName = "GwSpellbookFrame",
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
        FrameName = "GwGlyphsFrame",
        SettingName = "USE_TALENT_WINDOW",
        RefName = "GwGlyphsFrame",
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
        FrameName = "GwCurrencyFrame",
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
        OnLoad = "LoadPvp",
        FrameName = "GwPvpFrame",
        SettingName = "USE_CHARACTER_WINDOW",
        RefName = "GwPvpFrame",
        TabIcon = "tabicon-pvp",
        HeaderIcon = "Interface/AddOns/GW2_UI/textures/character/pvp-window-icon.png",
        HeaderText = PVP,
        TooltipText = PVP,
        Bindings = {
            TOGGLECHARACTER4 = "Pvp"
        },
        OnClick = [=[
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "pvp")
        ]=]
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Currency = "currency",
    GearSet = "gearset",
    Glyphes = "glyphes",
    PaperDoll = "paperdoll",
    PetBook = "petbook",
    PetPaperDollFrame = "paperdollpet",
    Pvp = "pvp",
    Reputation = "reputation",
    Skills = "paperdollskills",
    SpellBook = "spellbook",
    Talents = "talents",
    Titles = "titles",
})

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwPaperDoll")
    local fmDollMenu = self:GetFrameRef("GwHeroPanelMenu")
    local fmDollRepu = self:GetFrameRef("GwReputationFrame")
    local fmDollSkills = self:GetFrameRef("GwPaperSkills")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local fmDollTitles = self:GetFrameRef("GwTitleWindow")
    local fmDollGearSets = self:GetFrameRef("GwPaperGearSets")

    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollSkills = false
    local showDollTitles = false
    local showDollGearSets = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbookFrame")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentsFrame")
    local showTal = false
    local fmGlyphes = self:GetFrameRef("GwGlyphsFrame")
    local showGlyphes = false
    local fmCurrency = self:GetFrameRef("GwCurrencyFrame")
    local showCurrency = false
    local fmPvp = self:GetFrameRef("GwPvpFrame")
    local showPvp = false

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
    elseif fmPvp ~= nil and value == "pvp" then
        if keytoggle and fmPvp:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showPvp = true
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
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() and (not fmDollSkills:IsVisible() and not fmDollPetCont:IsVisible() and not fmDollTitles:IsVisible() and not fmDollGearSets:IsVisible()) then
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
    elseif fmDollSkills ~= nil and value == "paperdollskills" then
        if keytoggle and fmDollSkills:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollSkills = true
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
            fmDollSkills:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
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
    if fmPvp then
        if showPvp and not close then
            fmPvp:Show()
        else
            fmPvp:Hide()
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
    if fmDollSkills and showDollSkills then
        if showDollSkills and not close then
            fmDoll:Show()
            fmDollSkills:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollPetCont and showDollPetCont then
        if showDollPetCont and not close then
            fmDoll:Show()
            fmDollPetCont:Show()

            fmDollSkills:Hide()
            fmDollDress:Hide()
            fmDollMenu:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollTitles and showDollTitles then
        if showDollTitles and not close then
            fmDoll:Show()
            fmDollTitles:Show()
            fmDollDress:Show()

            fmDollSkills:Hide()
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

            fmDollSkills:Hide()
            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
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


GW.RegisterCharacterWindowConfig({
    windowsList = windowsList,
    charSecure_OnClick = charSecure_OnClick,
    charSecure_OnAttributeChanged = charSecure_OnAttributeChanged,
})
