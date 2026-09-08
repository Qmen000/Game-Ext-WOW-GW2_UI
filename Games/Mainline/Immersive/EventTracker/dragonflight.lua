---@class GW2
local GW = select(2, ...)
local L = GW.L
local ET = GW.EventTracker

-- all Dragonflight events only matter once the Dragon Isles intro is done
local dragonIslesFilter = ET.QuestCompletedFilter(67700)

ET:RegisterEvent("CommunityFeast", {
    dbKey = "communityFeast",
    args = {
        icon = 4687629,
        type = "loopTimer",
        barColor = ET.colorPalette.blue,
        questIDs = { 70893 },
        hasWeeklyReward = true,
        duration = 900,
        interval = 5400,
        eventName = L["Community Feast"],
        location = ET.GetMapName(2024),
        label = L["Feast"],
        runningText = L["Cooking"],
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1679751000, -- NA
            [2] = 1679747400, -- KR
            [3] = 1679749200, -- EU
            [4] = 1679747400, -- TW
            [5] = 1679747400, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2024),
        onClickHelpText = L["Click to show location"]
    }
})

ET:RegisterEvent("SiegeOnDragonbaneKeep", {
    dbKey = "dragonbaneKeep",
    args = {
        icon = 236469,
        type = "loopTimer",
        barColor = ET.colorPalette.red,
        questIDs = { 70866 },
        hasWeeklyReward = true,
        duration = 600,
        interval = 7200,
        eventName = L["Siege On Dragonbane Keep"],
        label = L["Dragonbane Keep"],
        location = ET.GetMapName(2022),
        runningText = IN_PROGRESS,
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1670338860, -- NA
            [2] = 1670698860, -- KR
            [3] = 1670342460, -- EU
            [4] = 1670698860, -- TW
            [5] = 1670677260, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2022),
        onClickHelpText = L["Click to show location"]
    }
})

ET:RegisterEvent("ResearchersUnderFire", {
    dbKey = "researchersUnderFire",
    args = {
        icon = 5140835,
        type = "loopTimer",
        barColor = ET.colorPalette.green,
        questIDs = { 75627, 75628, 75629, 75630 },
        hasWeeklyReward = true,
        duration = 1500,
        interval = 3600,
        eventName = L["Researchers"],
        label = L["Researchers"],
        location = ET.GetMapName(2133),
        runningText = IN_PROGRESS,
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1670333400, -- NA
            [2] = 1670703300, -- KR
            [3] = 1683804600, -- EU
            [4] = 1670702400, -- TW
            [5] = 1670702460, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2133),
        onClickHelpText = L["Click to show location"]
    }
})

ET:RegisterEvent("TimeRiftThaldraszus", {
    dbKey = "timeRiftThaldraszus",
    args = {
        icon = 237538,
        type = "loopTimer",
        barColor = ET.colorPalette.bronze,
        questIDs = { 77236 },
        hasWeeklyReward = true,
        duration = 900,
        interval = 3600,
        eventName = L["Time Rift"],
        label = L["Time Rift"],
        location = ET.GetMapName(2025),
        runningText = IN_PROGRESS,
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1701831600, -- NA
            [2] = 1701853200, -- KR
            [3] = 1689274800, -- EU
            [4] = 1701849600, -- TW
            [5] = 1701824400, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2025),
        onClickHelpText = L["Click to show location"]
    }
})

ET:RegisterEvent("SuperBloom", {
    dbKey = "superBloom",
    args = {
        icon = 133940,
        type = "loopTimer",
        barColor = ET.colorPalette.green,
        questIDs = { 78319 },
        hasWeeklyReward = true,
        duration = 900,
        interval = 3600,
        eventName = L["Superbloom"],
        label = L["Superbloom"],
        location = ET.GetMapName(2200),
        runningText = IN_PROGRESS,
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1699462800, -- NA
            [2] = 1701828010, -- KR
            [3] = 1699462800, -- EU
            [4] = 1701828010, -- TW
            [5] = 1701828010, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2200),
        onClickHelpText = L["Click to show location"]
    }
})

ET:RegisterEvent("BigDig", {
    dbKey = "bigDig",
    args = {
        icon = 1362650,
        type = "loopTimer",
        barColor = ET.colorPalette.purple,
        questIDs = { 79226 },
        hasWeeklyReward = true,
        duration = 600,
        interval = 3600,
        eventName = L["Big Dig"],
        label = L["Big Dig"],
        location = ET.GetMapName(2024),
        runningText = IN_PROGRESS,
        filter = dragonIslesFilter,
        startTimestamp = ET.RegionTimestamp({
            -- need more accurate timers
            [1] = 1705595400, -- NA
            [2] = 1701826200, -- KR
            [3] = 1705595400, -- EU
            [4] = 1701826200, -- TW
            [5] = 1701826200, -- CN
        }),
        onClick = ET.GetWorldMapIDSetter(2024),
        onClickHelpText = L["Click to show location"]
    }
})
