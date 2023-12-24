local _, GW = ...
local GW_UF = GW.oUF
local FillTable = GW.FillTable
local INDICATORS = GW.INDICATORS

local headers = {}
GW.GridGroupHeaders = headers

local profiles = {
    PARTY = {
        name = "Party",
        visibility = "[group:raid][nogroup] hide; [group:party] show;hide",
        numGroups = 1
    },
    RAID_PET = {
        name = "RaidPet",
        visibility = "[group:raid] show; hide",
        numGroups = 8
    },
    RAID40 = {
        name = "Raid40",
        size = 40,
        visibility = "[@raid26,noexists] hide; show",
        visibilityAll = "[group:raid] show;hide",
        visibilityIncl25 = "[@raid11,noexists] hide; show",
        numGroups = 8
    },
    RAID25 = {
        name = "Raid25",
        size = 25,
        visibility = "[@raid11,noexists][@raid26,exists] hide;show",
        visibilityIncl10 = "[@raid1,noexists][@raid26,exists] hide; show",
        numGroups = 5
    },
    RAID10 = {
        name = "Raid10",
        size = 10,
        visibility = "[@raid1,noexists][@raid11,exists] hide;show",
        numGroups = 5,
    },
    TANK = {
        name = "Maintank",
        visibility = "[group:raid] show; hide",
        numGroups = 1,
    },
}

--SecureCmdOptionParse("[@raid1,noexists][@raid11,exists] hide;show")
--SecureCmdOptionParse("[@raid11,noexists][@raid26,exists] hide;show")
--SecureCmdOptionParse("[group:party] hide;show")
local DIRECTION_TO_POINT = {
	["DOWN+RIGHT"] = "TOP",
	["DOWN+LEFT"] = "TOP",
	["UP+RIGHT"] = "BOTTOM",
	["UP+LEFT"] = "BOTTOM",
	["RIGHT+DOWN"] = "LEFT",
	["RIGHT+UP"] = "LEFT",
	["LEFT+DOWN"] = "RIGHT",
	["LEFT+UP"] = "RIGHT"
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	["DOWN+RIGHT"] = "LEFT",
	["DOWN+LEFT"] = "RIGHT",
	["UP+RIGHT"] = "LEFT",
	["UP+LEFT"] = "RIGHT",
	["RIGHT+DOWN"] = "TOP",
	["RIGHT+UP"] = "BOTTOM",
	["LEFT+DOWN"] = "TOP",
	["LEFT+UP"] = "BOTTOM",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	["DOWN+RIGHT"] = 1,
	["DOWN+LEFT"] = -1,
	["UP+RIGHT"] = 1,
	["UP+LEFT"] = -1,
	["RIGHT+DOWN"] = 1,
	["RIGHT+UP"] = 1,
	["LEFT+DOWN"] = -1,
	["LEFT+UP"] = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	["DOWN+RIGHT"] = -1,
	["DOWN+LEFT"] = -1,
	["UP+RIGHT"] = 1,
	["UP+LEFT"] = 1,
	["RIGHT+DOWN"] = -1,
	["RIGHT+UP"] = 1,
	["LEFT+DOWN"] = -1,
	["LEFT+UP"] = 1,
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	["DOWN+RIGHT"] = "TOPLEFT",
	["DOWN+LEFT"] = "TOPRIGHT",
	["UP+RIGHT"] = "BOTTOMLEFT",
	["UP+LEFT"] = "BOTTOMRIGHT",
	["RIGHT+DOWN"] = "TOPLEFT",
	["RIGHT+UP"] = "BOTTOMLEFT",
	["LEFT+DOWN"] = "TOPRIGHT",
	["LEFT+UP"] = "BOTTOMRIGHT",
    ["OUT+RIGHT+UP"] = "BOTTOM",
	["OUT+LEFT+UP"] = "BOTTOM",
	["OUT+RIGHT+DOWN"] = "TOP",
	["OUT+LEFT+DOWN"] = "TOP",
	["OUT+UP+RIGHT"] = "LEFT",
	["OUT+UP+LEFT"] = "RIGHT",
	["OUT+DOWN+RIGHT"] = "LEFT",
	["OUT+DOWN+LEFT"] = "RIGHT",
}

local settings = {
    enabled = {},
    missing = {},
    ignored = {},
    raidClassColor = {},
    raidUnitHealthString = {},
    raidUnitFlag = {},
    raidUnitMarkers = {},
    raidUnitPowerBar = {},
    raidAuraTooltipInCombat = {},
    raidShowDebuffs = {},
    raidShowOnlyDispelDebuffs = {},
    raidShowImportendInstanceDebuffs = {},
    raidIndicators = {},
    groupSpacing = {},
    horizontalSpacing = {},
    verticalSpacing = {},
    showRoleIcon = {},
    showTankIcon = {},
    showLeaderAssistIcon = {},

    raidWidth = {},
    raidHeight = {},
    startFromCenter = {},
    raidGrow = {},
    groupsPerColumnRow = {},
    raidWideSorting = {},
    groupBy = {},
    sortDirection = {},
    sortMethod = {}
}
GW.GridSettings = settings

local settingsEventFrame = CreateFrame("Frame")

local headerGroupBy = {
	CLASS = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK")
		header:SetAttribute("sortMethod", sortMethod or "NAME")
		header:SetAttribute("groupBy", "CLASS")
	end,
	ROLE = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute("sortMethod", sortMethod or "NAME")
		header:SetAttribute("groupBy", "ASSIGNEDROLE")
	end,
	NAME = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
	end,
	GROUP = function(header, profile)
		local sortMethod = settings.sortMethod[profile]
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", sortMethod or "INDEX")
		header:SetAttribute("groupBy", "GROUP")
	end,
	PETNAME = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
		header:SetAttribute("filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", nil)
	end,
    TANK = function(header)
        header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", nil)
        header:SetAttribute("groupFilter", "MAINTANK")
    end,
}

local function UpdateSettings(profile, onlyHeaderUpdate, updateHeaderAndFrames)
    --frame enabled settings
    settings.enabled.RAID_PET = GW.settings.RAID_PET_FRAMES
    settings.enabled.PARTY = GW.settings.RAID_STYLE_PARTY
    settings.enabled.RAID40 = GW.settings.RAID_FRAMES
    settings.enabled.RAID25 = GW.settings.RAID25_ENABLED
    settings.enabled.RAID10 = GW.settings.RAID10_ENABLED
    settings.enabled.TANK = GW.settings.RAID_MAINTANK_FRAMES_ENABLED

    -- generell settings
    settings.raidDebuffScale = GW.settings.RAIDDEBUFFS_Scale
    settings.raidDispelDebuffScale = GW.settings.DISPELL_DEBUFFS_Scale
    settings.raidIndicatorIcon = GW.settings.INDICATORS_ICON
    settings.raidIndicatorTime = GW.settings.INDICATORS_TIME
    settings.aurasIgnored = GW.settings.AURAS_IGNORED
    settings.aurasMissing = GW.settings.AURAS_MISSING
    settings.missing = FillTable({}, true, strsplit(",", (settings.aurasMissing:trim():gsub("%s*,%s*", ","))))
    settings.ignored = FillTable({}, true, strsplit(",", (settings.aurasIgnored:trim():gsub("%s*,%s*", ","))))

    for _, pos in ipairs(INDICATORS) do
        settings.raidIndicators[pos] = GW.settings["INDICATOR_" .. pos]
    end

    -- profile settings for the unitframes
    settings.raidClassColor.PARTY = GW.settings.RAID_CLASS_COLOR_PARTY
    settings.raidClassColor.RAID_PET = GW.settings.RAID_CLASS_COLOR_PET
    settings.raidClassColor.RAID40 = GW.settings.RAID_CLASS_COLOR
    settings.raidClassColor.RAID25 = GW.settings.RAID_CLASS_COLOR_RAID25
    settings.raidClassColor.RAID10 = GW.settings.RAID_CLASS_COLOR_RAID10
    settings.raidClassColor.TANK = GW.settings.RAID_CLASS_COLOR_TANK

    settings.raidUnitHealthString.PARTY = GW.settings.RAID_UNIT_HEALTH_PARTY
    settings.raidUnitHealthString.RAID_PET = GW.settings.RAID_UNIT_HEALTH_PET
    settings.raidUnitHealthString.RAID40 = GW.settings.RAID_UNIT_HEALTH
    settings.raidUnitHealthString.RAID25 = GW.settings.RAID_UNIT_HEALTH_RAID25
    settings.raidUnitHealthString.RAID10 = GW.settings.RAID_UNIT_HEALTH_RAID10
    settings.raidUnitHealthString.TANK = GW.settings.RAID_UNIT_HEALTH_TANK

    settings.horizontalSpacing.PARTY = GW.settings.RAID_UNITS_HORIZONTAL_SPACING_PARTY
    settings.horizontalSpacing.RAID_PET = GW.settings.RAID_UNITS_HORIZONTAL_SPACING_PET
    settings.horizontalSpacing.RAID40 = GW.settings.RAID_UNITS_HORIZONTAL_SPACING
    settings.horizontalSpacing.RAID25 = GW.settings.RAID_UNITS_HORIZONTAL_SPACING_RAID25
    settings.horizontalSpacing.RAID10 = GW.settings.RAID_UNITS_HORIZONTAL_SPACING_RAID10
    settings.horizontalSpacing.TANK = GW.settings.RAID_UNITS_HORIZONTAL_SPACING_TANK

    settings.verticalSpacing.PARTY = GW.settings.RAID_UNITS_VERTICAL_SPACING_PARTY
    settings.verticalSpacing.RAID_PET = GW.settings.RAID_UNITS_VERTICAL_SPACING_PET
    settings.verticalSpacing.RAID40 = GW.settings.RAID_UNITS_VERTICAL_SPACING
    settings.verticalSpacing.RAID25 = GW.settings.RAID_UNITS_VERTICAL_SPACING_RAID25
    settings.verticalSpacing.RAID10 = GW.settings.RAID_UNITS_VERTICAL_SPACING_RAID10
    settings.verticalSpacing.TANK = GW.settings.RAID_UNITS_VERTICAL_SPACING_TANK

    settings.groupSpacing.PARTY = GW.settings.RAID_UNITS_GROUP_SPACING_PARTY
    settings.groupSpacing.RAID_PET = GW.settings.RAID_UNITS_GROUP_SPACING_PET
    settings.groupSpacing.RAID40 = GW.settings.RAID_UNITS_GROUP_SPACING
    settings.groupSpacing.RAID25 = GW.settings.RAID_UNITS_GROUP_SPACING_RAID25
    settings.groupSpacing.RAID10 = GW.settings.RAID_UNITS_GROUP_SPACING_RAID10
    settings.groupSpacing.TANK = GW.settings.RAID_UNITS_GROUP_SPACING_TANK

    settings.raidUnitFlag.PARTY = GW.settings.RAID_UNIT_FLAGS_PARTY
    settings.raidUnitFlag.RAID_PET = GW.settings.RAID_UNIT_FLAGS_PET
    settings.raidUnitFlag.RAID40 = GW.settings.RAID_UNIT_FLAGS
    settings.raidUnitFlag.RAID25 = GW.settings.RAID_UNIT_FLAGS_RAID25
    settings.raidUnitFlag.RAID10 = GW.settings.RAID_UNIT_FLAGS_RAID10
    settings.raidUnitFlag.TANK = GW.settings.RAID_UNIT_FLAGS_TANK

    settings.raidUnitMarkers.PARTY = GW.settings.RAID_UNIT_MARKERS_PARTY
    settings.raidUnitMarkers.RAID_PET = GW.settings.RAID_UNIT_MARKERS_PET
    settings.raidUnitMarkers.RAID40 = GW.settings.RAID_UNIT_MARKERS
    settings.raidUnitMarkers.RAID25 = GW.settings.RAID_UNIT_MARKERS_RAID25
    settings.raidUnitMarkers.RAID10 = GW.settings.RAID_UNIT_MARKERS_RAID10
    settings.raidUnitMarkers.TANK = GW.settings.RAID_UNIT_MARKERS_TANK

    settings.raidUnitPowerBar.PARTY = GW.settings.RAID_POWER_BARS_PARTY
    settings.raidUnitPowerBar.RAID_PET = GW.settings.RAID_POWER_BARS_PET
    settings.raidUnitPowerBar.RAID40 = GW.settings.RAID_POWER_BARS
    settings.raidUnitPowerBar.RAID25 = GW.settings.RAID_POWER_BARS_RAID25
    settings.raidUnitPowerBar.RAID10 = GW.settings.RAID_POWER_BARS_RAID10
    settings.raidUnitPowerBar.TANK = GW.settings.RAID_POWER_BARS_TANK

    settings.raidAuraTooltipInCombat.PARTY = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_PARTY
    settings.raidAuraTooltipInCombat.RAID_PET = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_PET
    settings.raidAuraTooltipInCombat.RAID40 = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT
    settings.raidAuraTooltipInCombat.RAID25 = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_RAID25
    settings.raidAuraTooltipInCombat.RAID10 = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_RAID10
    settings.raidAuraTooltipInCombat.TANK = GW.settings.RAID_AURA_TOOLTIP_INCOMBAT_TANK

    settings.raidShowDebuffs.PARTY = GW.settings.RAID_SHOW_DEBUFFS_PARTY
    settings.raidShowDebuffs.RAID_PET = GW.settings.RAID_SHOW_DEBUFFS_PET
    settings.raidShowDebuffs.RAID40 = GW.settings.RAID_SHOW_DEBUFFS
    settings.raidShowDebuffs.RAID25 = GW.settings.RAID_SHOW_DEBUFFS_RAID25
    settings.raidShowDebuffs.RAID10 = GW.settings.RAID_SHOW_DEBUFFS_RAID10
    settings.raidShowDebuffs.TANK = GW.settings.RAID_SHOW_DEBUFFS_TANK

    settings.raidShowOnlyDispelDebuffs.PARTY = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_PARTY
    settings.raidShowOnlyDispelDebuffs.RAID_PET = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_PET
    settings.raidShowOnlyDispelDebuffs.RAID40 = GW.settings.RAID_ONLY_DISPELL_DEBUFFS
    settings.raidShowOnlyDispelDebuffs.RAID25 = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_RAID25
    settings.raidShowOnlyDispelDebuffs.RAID10 = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_RAID10
    settings.raidShowOnlyDispelDebuffs.TANK = GW.settings.RAID_ONLY_DISPELL_DEBUFFS_TANK

    settings.raidShowImportendInstanceDebuffs.PARTY = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY
    settings.raidShowImportendInstanceDebuffs.RAID_PET = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PET
    settings.raidShowImportendInstanceDebuffs.RAID40 = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF
    settings.raidShowImportendInstanceDebuffs.RAID25 = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID25
    settings.raidShowImportendInstanceDebuffs.RAID10 = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_RAID10
    settings.raidShowImportendInstanceDebuffs.TANK = GW.settings.RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_TANK

    settings.raidWidth.PARTY = tonumber(GW.settings.RAID_WIDTH_PARTY)
    settings.raidWidth.RAID_PET = tonumber(GW.settings.RAID_WIDTH_PET)
    settings.raidWidth.RAID40 = tonumber(GW.settings.RAID_WIDTH)
    settings.raidWidth.RAID25 = tonumber(GW.settings.RAID_WIDTH_RAID25)
    settings.raidWidth.RAID10 = tonumber(GW.settings.RAID_WIDTH_RAID10)
    settings.raidWidth.TANK = tonumber(GW.settings.RAID_WIDTH_TANK)

    settings.raidHeight.PARTY = tonumber(GW.settings.RAID_HEIGHT_PARTY)
    settings.raidHeight.RAID_PET = tonumber(GW.settings.RAID_HEIGHT_PET)
    settings.raidHeight.RAID40 = tonumber(GW.settings.RAID_HEIGHT)
    settings.raidHeight.RAID25 = tonumber(GW.settings.RAID_HEIGHT_RAID25)
    settings.raidHeight.RAID10 = tonumber(GW.settings.RAID_HEIGHT_RAID10)
    settings.raidHeight.TANK = tonumber(GW.settings.RAID_HEIGHT_TANK)

    settings.showRoleIcon.PARTY = GW.settings.RAID_SHOW_ROLE_ICON_PARTY
    settings.showRoleIcon.RAID_PET = GW.settings.RAID_SHOW_ROLE_ICON_PET
    settings.showRoleIcon.RAID40 = GW.settings.RAID_SHOW_ROLE_ICON
    settings.showRoleIcon.RAID25 = GW.settings.RAID_SHOW_ROLE_ICON_RAID25
    settings.showRoleIcon.RAID10 = GW.settings.RAID_SHOW_ROLE_ICON_RAID10
    settings.showRoleIcon.TANK = GW.settings.RAID_SHOW_ROLE_ICON_TANK

    settings.showTankIcon.PARTY = GW.settings.RAID_SHOW_TANK_ICON_PARTY
    settings.showTankIcon.RAID_PET = GW.settings.RAID_SHOW_TANK_ICON_PET
    settings.showTankIcon.RAID40 = GW.settings.RAID_SHOW_TANK_ICON
    settings.showTankIcon.RAID25 = GW.settings.RAID_SHOW_TANK_ICON_RAID25
    settings.showTankIcon.RAID10 = GW.settings.RAID_SHOW_TANK_ICON_RAID10
    settings.showTankIcon.TANK = GW.settings.RAID_SHOW_TANK_ICON_TANK

    settings.showLeaderAssistIcon.PARTY = GW.settings.RAID_SHOW_LEADER_ICON_PARTY
    settings.showLeaderAssistIcon.RAID_PET = GW.settings.RAID_SHOW_LEADER_ICON_PET
    settings.showLeaderAssistIcon.RAID40 = GW.settings.RAID_SHOW_LEADER_ICON
    settings.showLeaderAssistIcon.RAID25 = GW.settings.RAID_SHOW_LEADER_ICON_RAID25
    settings.showLeaderAssistIcon.RAID10 = GW.settings.RAID_SHOW_LEADER_ICON_RAID10
    settings.showLeaderAssistIcon.TANK = GW.settings.RAID_SHOW_LEADER_ICON_TANK

    -- profile settings for the header
    settings.startFromCenter.PARTY = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER_PARTY
    settings.startFromCenter.RAID_PET = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER_PET
    settings.startFromCenter.RAID40 = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER
    settings.startFromCenter.RAID25 = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER_RAID25
    settings.startFromCenter.RAID10 = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER_RAID10
    settings.startFromCenter.RAID10 = GW.settings.UNITFRAME_ANCHOR_FROM_CENTER_TANK

    settings.raidGrow.PARTY = GW.settings.RAID_GROW_PARTY
    settings.raidGrow.RAID_PET = GW.settings.RAID_GROW_PET
    settings.raidGrow.RAID40 = GW.settings.RAID_GROW
    settings.raidGrow.RAID25 = GW.settings.RAID_GROW_RAID25
    settings.raidGrow.RAID10 = GW.settings.RAID_GROW_RAID10
    settings.raidGrow.TANK = GW.settings.RAID_GROW_TANK

    settings.groupsPerColumnRow.PARTY = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN_PARTY)
    settings.groupsPerColumnRow.RAID_PET = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN_PET)
    settings.groupsPerColumnRow.RAID40 = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN)
    settings.groupsPerColumnRow.RAID25 = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN_RAID25)
    settings.groupsPerColumnRow.RAID10 = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN_RAID10)
    settings.groupsPerColumnRow.TANK = tonumber(GW.settings.RAID_GROUPS_PER_COLUMN_TANK)

    settings.raidWideSorting.PARTY = GW.settings.RAID_WIDE_SORTING_PARTY
    settings.raidWideSorting.RAID_PET = GW.settings.RAID_WIDE_SORTING_PET
    settings.raidWideSorting.RAID40 = GW.settings.RAID_WIDE_SORTING
    settings.raidWideSorting.RAID25 = GW.settings.RAID_WIDE_SORTING_RAID25
    settings.raidWideSorting.RAID10 = GW.settings.RAID_WIDE_SORTING_RAID10
    settings.raidWideSorting.TANK = GW.settings.RAID_WIDE_SORTING_TANK

    settings.groupBy.PARTY = GW.settings.RAID_GROUP_BY_PARTY
    settings.groupBy.RAID_PET = GW.settings.RAID_GROUP_BY_PET
    settings.groupBy.RAID40 = GW.settings.RAID_GROUP_BY
    settings.groupBy.RAID25 = GW.settings.RAID_GROUP_BY_RAID25
    settings.groupBy.RAID10 = GW.settings.RAID_GROUP_BY_RAID10
    settings.groupBy.TANK = GW.settings.RAID_GROUP_BY_TANK

    settings.sortDirection.PARTY = GW.settings.RAID_SORT_DIRECTION_PARTY
    settings.sortDirection.RAID_PET = GW.settings.RAID_SORT_DIRECTION_PET
    settings.sortDirection.RAID40 = GW.settings.RAID_SORT_DIRECTION
    settings.sortDirection.RAID25 = GW.settings.RAID_SORT_DIRECTION_RAID25
    settings.sortDirection.RAID10 = GW.settings.RAID_SORT_DIRECTION_RAID10
    settings.sortDirection.TANK = GW.settings.RAID_SORT_DIRECTION_TANK

    settings.sortMethod.PARTY = GW.settings.RAID_RAID_SORT_METHOD_PARTY
    settings.sortMethod.RAID_PET = GW.settings.RAID_RAID_SORT_METHOD_PET
    settings.sortMethod.RAID40 = GW.settings.RAID_RAID_SORT_METHOD
    settings.sortMethod.RAID25 = GW.settings.RAID_RAID_SORT_METHOD_RAID25
    settings.sortMethod.RAID10 = GW.settings.RAID_RAID_SORT_METHOD_RAID10
    settings.sortMethod.TANK = GW.settings.RAID_RAID_SORT_METHOD_TANK

    -- Update this settings on a spec switch
    if not settingsEventFrame.isSetup then
        settingsEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        settingsEventFrame:SetScript("OnEvent", function(_, event)
            UpdateSettings(profile, false, true)
            if event == "PLAYER_REGEN_ENABLED" then settingsEventFrame:UnregisterEvent(event) end
        end)

        settingsEventFrame.isSetup = true
    end

    if not onlyHeaderUpdate or updateHeaderAndFrames then
        if InCombatLockdown() then
            settingsEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        for headerProfile, header in pairs(headers) do
            if headerProfile == profile then
                for i = 1, header.numGroups do
                    local group = header.groups[i]
                    for _, child in ipairs({ group:GetChildren() }) do
                        GW["UpdateGrid" ..  header.profileName .. "Frame"](child, header.groupName)
                    end
                end
            end
        end
    end

    if (onlyHeaderUpdate or updateHeaderAndFrames) and headers[profile] then
        if InCombatLockdown() then
            settingsEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            GW.UpdateGridHeader(profile)
        end
    end
end
GW.UpdateGridSettings = UpdateSettings

local function GetGroupHeaderForProfile(profile)
    for headerProfile, header in pairs(GW.GridGroupHeaders) do
        if headerProfile == profile then
            return header
        end
    end

    return nil
end
GW.GetGroupHeaderForProfile = GetGroupHeaderForProfile

local function CreateRaisedText(raised)
	local text = raised:CreateFontString(nil, "OVERLAY")
	text:SetFont(UNIT_NAME_FONT, 11)
    text:SetShadowOffset(-1, -1)
    text:SetShadowColor(0, 0, 0, 1)

	return text
end
GW.CreateRaisedText = CreateRaisedText

local function CreateRaisedElement(frame)
	local raised = CreateFrame("Frame", nil, frame)
	local level = frame:GetFrameLevel() + 100
	raised:SetFrameLevel(level)
	raised.__owner = frame
	raised.TextureParent = CreateFrame("Frame", nil, raised)

	return raised
end
GW.CreateRaisedElement = CreateRaisedElement

local function UpdateGroupVisibility(header, profile, enabled)
    if not header.isForced then
        local numGroups = header.numGroups
        local raidWideSorting = settings.raidWideSorting[profile]
        local visibilityToUseForGroups

        if profile == "RAID40" then
            if settings.enabled.RAID40 and settings.enabled.RAID25 and settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID40.visibility)
                visibilityToUseForGroups = profiles.RAID40.visibility
            elseif settings.enabled.RAID40 and not settings.enabled.RAID25 and settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID40.visibilityIncl25)
                visibilityToUseForGroups = profiles.RAID40.visibilityIncl25
            elseif settings.enabled.RAID40 and not settings.enabled.RAID25 and not settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID40.visibilityAll)
                visibilityToUseForGroups = profiles.RAID40.visibilityAll
            elseif not settings.enabled.RAID40 then
                RegisterStateDriver(header, "visibility", "hide")
            end
        elseif profile == "RAID25" then
            if settings.enabled.RAID25 and settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID25.visibility)
                visibilityToUseForGroups = profiles.RAID25.visibility
            elseif settings.enabled.RAID25 and not settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID25.visibilityIncl10)
                visibilityToUseForGroups = profiles.RAID25.visibilityIncl10
            elseif not settings.enabled.RAID25 then
                RegisterStateDriver(header, "visibility", "hide")
            end
        elseif profile == "RAID10" then
            if settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", profiles.RAID10.visibility)
                visibilityToUseForGroups = profiles.RAID10.visibility
            else
                RegisterStateDriver(header, "visibility", "hide")
            end
        elseif profile == "RAID_PET" then
            if settings.enabled.RAID_PET then
                RegisterStateDriver(header, "visibility", profiles.RAID_PET.visibility)
                visibilityToUseForGroups = profiles.RAID_PET.visibility
            else
                RegisterStateDriver(header, "visibility", "hide")
            end
        end

        for i = 1, numGroups do
            local group = header.groups[i]
            if group then
                if enabled then
                    -- register the correct visibility state driver
                    if numGroups > 1 and i > 1 then
                        if raidWideSorting then
                            RegisterStateDriver(group, "visibility", "hide")
                        else
                            RegisterStateDriver(group, "visibility", visibilityToUseForGroups)
                        end
                    elseif numGroups > 1 and i == 1 then
                        RegisterStateDriver(group, "visibility", visibilityToUseForGroups)
                    end
                else
                    RegisterStateDriver(group, "visibility", "hide")
                end
            end
        end
    end
end
GW.UpdateGroupVisibility = UpdateGroupVisibility

local function UpdateGridHeader(profile)
    -- Update header values
    local header = headers[profile]
    if header.isUpdating then return end
    header.isUpdating = true

    local x, y = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[settings.raidGrow[profile]], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[settings.raidGrow[profile]]
    local numGroups = header.numGroups
    local isParty = profile == "PARTY"
    local groupsPerRowCol = isParty and 1 or tonumber(settings.groupsPerColumnRow[profile])
    local width, height, newCols, newRows = 0, 0, 0, 0
    local groupSpacing = tonumber(settings.groupSpacing[profile])
    local horizontalSpacing = tonumber(settings.horizontalSpacing[profile])
    local verticalSpacing = tonumber(settings.verticalSpacing[profile])
    local WIDTH = GW.Scale(settings.raidWidth[profile]) + horizontalSpacing
    local HEIGHT = GW.Scale(settings.raidHeight[profile]) + verticalSpacing
    local HEIGHT_FIVE = HEIGHT * 5
    local WIDTH_FIVE = WIDTH * 5
    local groupBy = settings.groupBy[profile]
    local sortDirection = settings.sortDirection[profile]
    local raidWideSorting = settings.raidWideSorting[profile]

    for i = 1, numGroups do
        local group = header.groups[i]
        local lastIndex = i - 1
        local lastGroup = lastIndex % groupsPerRowCol

        if group then
            group:ClearAllPoints()

            local idx = 1
            local child = group:GetAttribute("child"..idx)
            while child do
                child:ClearAllPoints()
                idx = idx + 1
                child = group:GetAttribute("child"..idx)
            end


            local point = DIRECTION_TO_POINT[settings.raidGrow[profile]]
            group:SetAttribute("point", point)

            if point == "LEFT" or point == "RIGHT" then
                group:SetAttribute("xOffset", horizontalSpacing * x)
                group:SetAttribute("yOffset", 0)
                group:SetAttribute("columnSpacing", verticalSpacing)
            else
                group:SetAttribute("xOffset", 0)
                group:SetAttribute("yOffset", verticalSpacing * y)
                group:SetAttribute("columnSpacing", horizontalSpacing)
            end

            if not group.isForced then
                if not group.initialized then
                    group:SetAttribute("startingIndex", raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
                    group:Show()
                    group.initialized = true
                end
                group:SetAttribute("startingIndex", 1)
            end

            group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[settings.raidGrow[profile]])

            if not group.isForced then
                group:SetAttribute("maxColumns", raidWideSorting and numGroups or 1)
                group:SetAttribute("unitsPerColumn", raidWideSorting and (groupsPerRowCol * 5) or 5)
                group:SetAttribute("showPlayer", true)
                group:SetAttribute("sortDir", sortDirection)
                -- sorting
                if profile == "RAID_PET" then
                    headerGroupBy.PETNAME(group)
                elseif profile == "TANK" then
                    headerGroupBy.TANK(group)
                else
                    local func = headerGroupBy[groupBy] or headerGroupBy.INDEX
                    func(group, profile)
                end
            end

            if profile ~= "TANK" then
                local groupWide = i == 1 and raidWideSorting and strsub("1,2,3,4,5,6,7,8", 1, numGroups + numGroups-1)
                group:SetAttribute("groupFilter", groupWide or tostring(i))
            end

            -- register the correct visibility state driver
            if profile == "PARTY" then
                if not GW.settings.RAID_STYLE_PARTY and not GW.settings.RAID_STYLE_PARTY_AND_FRAMES then
                    RegisterStateDriver(group, "visibility", "hide")
                else
                    RegisterStateDriver(group, "visibility", profiles.PARTY.visibility)
                end
            end
        end

        local point = DIRECTION_TO_GROUP_ANCHOR_POINT[settings.raidGrow[profile]]
        if (isParty or raidWideSorting) and settings.startFromCenter[profile] then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT+" .. settings.raidGrow[profile]]
		end

        if lastGroup == 0 then
            if DIRECTION_TO_POINT[settings.raidGrow[profile]] == "LEFT" or DIRECTION_TO_POINT[settings.raidGrow[profile]] == "RIGHT" then
                if group then group:SetPoint(point, header, point, 0, height * y) end
                height = height + HEIGHT + groupSpacing
                newRows = newRows + 1
            else
                if group then group:SetPoint(point, header, point, width * x, 0) end
                width = width + WIDTH + groupSpacing
                newCols = newCols + 1
            end
        else
            if DIRECTION_TO_POINT[settings.raidGrow[profile]] == "LEFT" or DIRECTION_TO_POINT[settings.raidGrow[profile]] == "RIGHT" then
                if newRows == 1 then
                    if group then group:SetPoint(point, header, point, width * x, 0) end
                    width = width + WIDTH_FIVE + groupSpacing
                    newCols = newCols + 1
                elseif group then
                    group:SetPoint(point, header, point, ((WIDTH_FIVE * lastGroup) + lastGroup * groupSpacing) * x, ((HEIGHT + groupSpacing) * (newRows - 1)) * y)
                end
            else
                if newCols == 1 then
                    if group then group:SetPoint(point, header, point, 0, height * y) end
                    height = height + HEIGHT_FIVE + groupSpacing
                    newRows = newRows + 1
                elseif group then
                    group:SetPoint(point, header, point, ((WIDTH + groupSpacing) * (newCols - 1)) * x, ((HEIGHT_FIVE * lastGroup) + lastGroup * groupSpacing) * y)
                end
            end
        end

        if height == 0 then height = height + HEIGHT_FIVE + groupSpacing end
        if width == 0 then width = width + WIDTH_FIVE + groupSpacing end
    end

    header:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
    header.gwMover:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)

    --check if we can diable the frame and also the mover
    if not header.isForced then
        if profile == "RAID40" then
            RegisterStateDriver(header, "visibility", profiles.RAID40.visibility)
            UpdateGroupVisibility(header, profile, true)
        elseif profile == "RAID25" then
            GW.ToggleMover(header.gwMover, settings.enabled.RAID25)
            if not settings.enabled.RAID25 then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID25.visibility)
            end
            UpdateGroupVisibility(header, profile, settings.enabled.RAID25)
        elseif profile == "RAID10" then
            GW.ToggleMover(header.gwMover, settings.enabled.RAID10)
            if not settings.enabled.RAID10 then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID10.visibility)
            end
            UpdateGroupVisibility(header, profile, settings.enabled.RAID10)
        elseif profile == "RAID_PET" then
            GW.ToggleMover(header.gwMover, settings.enabled.RAID_PET)
            if not settings.enabled.RAID_PET then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.RAID_PET.visibility)
            end
            UpdateGroupVisibility(header, profile, settings.enabled.RAID_PET)
        elseif profile == "TANK" then
            GW.ToggleMover(header.gwMover, settings.enabled.TANK)
            if not settings.enabled.TANK then
                RegisterStateDriver(header, "visibility", "hide")
            else
                RegisterStateDriver(header, "visibility", profiles.TANK.visibility)
            end
            UpdateGroupVisibility(header, profile, settings.enabled.TANK)
        end
    end

    header.isUpdating = false
end
GW.UpdateGridHeader = UpdateGridHeader

local function CreateHeader(parent, profile, options, overrideName, groupFilter)
    parent:SetActiveStyle("GW2_Grid" .. options.name)

    local header = parent:SpawnHeader(overrideName, (options.name == "RaidPet" and "SecureGroupPetHeaderTemplate" or nil), "custom " .. options.visibility,
        "showParty", true,
        "showRaid", options.name ~= "Party",
        "showPlayer", true,
        "groupFilter", groupFilter,
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "oUF-initialConfigFunction", format("self:SetWidth(%d); self:SetHeight(%d);", settings.raidWidth[profile], settings.raidHeight[profile])
    )

    header.groupName = profile
    header.profileName = options.name
    header.numGroups = options.numGroups

    return header
end

local function Setup(self)
    -- create headers and groups for all profiles
    for profile, options in pairs(profiles) do
        self:RegisterStyle("GW2_Grid" .. options.name, GW["GW2_Grid" .. options.name .. "StyleRegister"])
        self:SetActiveStyle("GW2_Grid" .. options.name)

        -- Create a holding header
        local Header = CreateFrame("Frame", "GW2_" .. options.name .. "GridContainer", UIParent, "SecureHandlerStateTemplate")
        Header.groups = {}
        Header.groupName = profile
        Header.numGroups = options.numGroups
        Header.profileName = options.name
        headers[profile] = Header

        Header.groups[1] = CreateHeader(self, profile, options, "GW2_" .. options.name .. "Group1")

        while options.numGroups > #Header.groups do
            local index = tostring(#Header.groups + 1)
            tinsert(Header.groups, CreateHeader(self, profile, options, "GW2_" .. options.name .. "Group" .. index, index))
        end

        RegisterStateDriver(Header, "visibility", options.visibility)

        -- movable frame for the container
        if profile == "PARTY" then
            GW.RegisterMovableFrame(Header, GW.L["Group Frames"], "raid_party_pos",  ALL .. ",Unitframe,Group", nil, {"default", "default"})
        elseif profile == "RAID_PET" then
            GW.RegisterMovableFrame(Header, GW.L["Raid pet's Grid"], "raid_pet_pos",  ALL .. ",Unitframe,Rid", nil, {"default", "default"})
        elseif profile == "RAID40" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "RAID25" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid25_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "RAID10" then
            GW.RegisterMovableFrame(Header, RAID_FRAMES_LABEL .. ": " .. options.size, "raid10_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        elseif profile == "TANK" then
            GW.RegisterMovableFrame(Header, MAINTANK, "raidMaintank_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})
        end

        Header:ClearAllPoints()
        Header:SetPoint("TOPLEFT", Header.gwMover)

        UpdateGridHeader(profile)
    end

    C_Timer.After(0, function()
        for profile, _ in pairs(profiles) do
            UpdateSettings(profile)
        end
    end)
end
local function Initialize()
    if not GwManageGroupButton then
        GW.manageButton()
    end

    for profile, _ in pairs(profiles) do
        UpdateSettings(profile)
    end

    GW.Create_Tags()
    Setup(GW_UF)
end
GW.InitializeRaidFrames = Initialize