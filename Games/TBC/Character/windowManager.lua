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
            TOGGLECHARACTER2 = "Reputation",
            TOGGLECHARACTER1 = "Skills",
            TOGGLECHARACTER3 = "PetPaperDollFrame",
            TOGGLECHARACTER4 = "Honor"
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
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = GW.BuildCharacterWindowClickHandler({
    Honor = "paperdollhonor",
    PaperDoll = "paperdoll",
    PetBook = "petbook",
    PetPaperDollFrame = "paperdollpet",
    Reputation = "reputation",
    Runes = "paperdollengravings",
    Skills = "paperdollskills",
    SpellBook = "spellbook",
    Talents = "talents",
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
    local fmDollHonor = self:GetFrameRef("GwPaperHonor")
    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollSkills = false
    local showDollEngavings = false
    local showDollHonor = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbookFrame")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentsFrame")
    local showTal = false

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
        if keytoggle and fmDoll:IsVisible() and (not fmDollSkills:IsVisible() and not fmDollPetCont:IsVisible() and not fmDollHonor:IsVisible()) then
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
    elseif fmDollHonor ~= nil and value == "paperdollhonor" then
        if keytoggle and fmDollHonor:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollHonor = true
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
            fmDollHonor:Hide()
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
            fmDollHonor:Hide()
        else
            fmDoll:Hide()
        end
    end

    if fmDollHonor and showDollHonor then
        if showDollHonor and not close then
            fmDoll:Show()
            fmDollHonor:Show()

            fmDollSkills:Hide()
            fmDollMenu:Hide()
            fmDollDress:Hide()
            fmDollPetCont:Hide()
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
            fmDollHonor:Hide()
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
