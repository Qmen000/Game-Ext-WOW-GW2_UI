---@class GW2
local GW = select(2, ...)
local L = GW.L
local ET = GW.EventTracker

ET:RegisterEvent("WeeklyTWW", {
    dbKey = "weeklyTWW",
    args = {
        icon = 236681,
        type = "weekly",
        questIDs = {
            [ET.WeeklyName(6025441, L["Delves Weekly"])] = {
                82706, -- Delves: Worldwide Research
                82708, 82709, 82710, 82711, 82712, 82746, -- Bountiful Delves
            },
            [ET.WeeklyName(1411833, L["Archives Weekly"])] = {
                82678, -- Archives: The First Disc
                82679, -- Archives: Seeking History
            },
            [ET.WeeklyName(134015, L["Weekend Event"])] = {
                83345, -- A Call to Battle
                83347, -- Emissary of War
                83357, -- The Very Best
                83358, -- A Call to Arena
                83359, -- A Shattered Path Through Time
                83360, -- A Fel-Touched Path Through Time
                83362, -- A Shrouded Path Through Time
                83363, -- A Burning Path Through Time
                83364, -- A Shattered Path Through Time
                83365, -- A Frozen Path Through Time
                83366, -- The World Awaits
                84776, -- Delve into the Depths
            },
            [ET.WeeklyName(5554512, L["Dungeon Weekly"])] = {
                -- https://www.wowhead.com/npc=226623/biergoth
                83432, -- The Rookery
                83436, -- Cinderbrew Meadery
                83443, -- Darkflame Cleft
                83457, -- The Stonevault
                83458, -- Priory of the Sacred Flame
                83459, -- The Dawnbreaker
                83465, -- Ara-Kara, City of Echoes
                83469, -- City of Threads
                86203, -- Operation: Floodgate
            },
        },
        questProgress = ET.StorylineQuestProgress,
        eventName = format("%s (%s)", L["Weekly Quest"], L["The War Within"]),
        location = ET.GetMapName(2339),
        label = format("%s (%s)", L["Weekly Quest"], "TWW"),
        onClick = ET.GetWorldMapIDSetter(2339),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("EcologicalSuccession", {
    dbKey = "ecologicalSuccession",
    args = {
        icon = 6921877,
        type = "weekly",
        questIDs = { 85460 }, -- Ecological Succession
        hasWeeklyReward = true,
        eventName = L["Ecological Succession"],
        location = ET.GetMapName(2371),
        label = L["Ecological Succession"],
        onClick = ET.GetWorldMapIDSetter(2371),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("Nightfall", {
    dbKey = "nightFall",
    args = {
        icon = 6694198,
        type = "loopTimer",
        runningBarColor = ET.colorPalette.purple,
        questIDs = { 91173 },
        hasWeeklyReward = true,
        duration = 15 * 60,
        interval = 60 * 60,
        eventName = L["Nightfall"],
        location = ET.GetMapName(2215),
        label = L["Nightfall"],
        runningText = IN_PROGRESS,
        startTimestamp = ET.RegionTimestamp({
            [1] = 1757134800, -- NA
            [2] = 1757134800, -- KR
            [3] = 1757134800, -- EU
            [4] = 1757134800, -- TW
            [5] = 1757134800, -- CN
            [72] = 1757134800, -- PTR
            [90] = 1757134800, -- Midnight PTR
        }),
        onClick = ET.GetWorldMapIDSetter(2215),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("TheaterTroupe", {
    dbKey = "theaterTroupe",
    args = {
        icon = 5788303,
        type = "loopTimer",
        barColor = ET.colorPalette.bronze,
        runningBarColor = ET.colorPalette.green,
        questIDs = { 83240 },
        hasWeeklyReward = true,
        duration = 15 * 60,
        interval = 60 * 60,
        eventName = L["Theater Troupe"],
        location = ET.GetMapName(2248),
        label = L["Theater"],
        runningText = L["Performing"],
        startTimestamp = ET.RegionTimestamp({
            [1] = 1724976005, -- NA
            [2] = 1724976005, -- KR
            [3] = 1724976005, -- EU
            [4] = 1724976005, -- TW
            [5] = 1724976005, -- CN
            [72] = 1724976000, -- PTR
        }),
        onClick = ET.GetWorldMapIDSetter(2248),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("RingingDeeps", {
    dbKey = "ringingDeeps",
    args = {
        icon = 2120036,
        type = "weekly",
        questIDs = { 83333 },
        hasWeeklyReward = true,
        eventName = L["Ringing Deeps"],
        location = ET.GetMapName(2214),
        label = L["Ringing Deeps"],
        completedText = CRITERIA_COMPLETED,
        notCompletedText = CRITERIA_NOT_COMPLETED,
        onClick = ET.GetWorldMapIDSetter(2214),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("SpreadingTheLight", {
    dbKey = "spreadingTheLight",
    args = {
        icon = 5927633,
        type = "weekly",
        questIDs = { 76586 },
        hasWeeklyReward = true,
        eventName = L["Spreading The Light"],
        location = ET.GetMapName(2215),
        label = L["Spreading The Light"],
        completedText = CRITERIA_COMPLETED,
        notCompletedText = CRITERIA_NOT_COMPLETED,
        onClick = ET.GetWorldMapIDSetter(2215),
        onClickHelpText = L["Click to show location"],
    },
})

ET:RegisterEvent("UnderworldOperative", {
    dbKey = "underworldOperative",
    args = {
        icon = 5309857,
        type = "weekly",
        questIDs = { 80670, 80671, 80672 },
        hasWeeklyReward = true,
        eventName = L["Underworld Operative"],
        location = ET.GetMapName(2255),
        label = L["Underworld Operative"],
        completedText = CRITERIA_COMPLETED,
        notCompletedText = CRITERIA_NOT_COMPLETED,
        onClick = ET.GetWorldMapIDSetter(2255),
        onClickHelpText = L["Click to show location"],
    },
})
