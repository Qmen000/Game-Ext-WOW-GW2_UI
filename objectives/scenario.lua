local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR
local ParseCriteria = GW.ParseCriteria
local ParseObjectiveString = GW.ParseObjectiveString
local CreateObjectiveNormal = GW.CreateObjectiveNormal
local CreateTrackerObject = GW.CreateTrackerObject
local UpdateQuestItem = GW.UpdateQuestItem
local setBlockColor = GW.setBlockColor

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local timerBlock
local scenarioBlock

local allowedWidgetUpdateIdsForTimer = {
    [3302] = true, -- DF cooking event
    [6183] = true, -- TWW delve
    [5483] = true, -- TWW theather event
    [5865] = true, -- TWW echos
    [5986] = true, -- 20th
    [5990] = true, -- 20th
    [5991] = true, -- 20th
}

local allowedWidgetUpdateIdsForStatusBar = {
    [6350] = true, -- 20th
}

local function getObjectiveBlock(self, index)
    local block = _G[self:GetName() .. "GwQuestObjective" .. index]
    if block then
        block:SetScript("OnEnter", nil)
        block:SetScript("OnLeave", nil)
        block.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
        block.isMythicKeystone = false
        return block
    end

    if self.objectiveBlocksNum == nil then
        self.objectiveBlocksNum = 0
    end
    self.objectiveBlocks = self.objectiveBlocks or {}
    self.objectiveBlocksNum = self.objectiveBlocksNum + 1

    local newBlock = CreateObjectiveNormal(self:GetName() .. "GwQuestObjective" .. self.objectiveBlocksNum, self)
    tinsert(self.objectiveBlocks, newBlock)
    newBlock:SetParent(self)
    if self.objectiveBlocksNum == 1 then
        newBlock:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -5)
    else
        newBlock:SetPoint(
            "TOPRIGHT",
            _G[self:GetName() .. "GwQuestObjective" .. (self.objectiveBlocksNum - 1)],
            "BOTTOMRIGHT",
            0,
            0
        )
    end

    newBlock.hasObjectToHide = false
    newBlock.objectToHide = nil
    newBlock.resetParent = false
    newBlock.isMythicKeystone = false
    newBlock:SetScript("OnEnter", nil)
    newBlock:SetScript("OnLeave", nil)
    newBlock.StatusBar:SetStatusBarColor(self.color.r, self.color.g, self.color.b)

    return newBlock
end
GW.GetScenarioObjectivesBlock = getObjectiveBlock
GW.AddForProfiling("scenario", "getObjectiveBlock", getObjectiveBlock)

local function addObjectiveBlock(block, text, finished, objectiveIndex, objectiveType, quantity, isMythicKeystone)
    local objectiveBlock = getObjectiveBlock(block, objectiveIndex)
    objectiveBlock.isMythicKeystone = isMythicKeystone

    if text then
        if objectiveBlock.hasObjectToHide then
            if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = nil end
            objectiveBlock.objectToHide:SetParent(GW.HiddenFrame)
            if objectiveBlock.resetParent then objectiveBlock.objectToHide.SetParent = GW.NoOp end
        end
        objectiveBlock:Show()
        objectiveBlock.ObjectiveText:SetText(text)
        objectiveBlock.ObjectiveText:SetHeight(objectiveBlock.ObjectiveText:GetStringHeight() + 15)
        if finished then
            objectiveBlock.ObjectiveText:SetTextColor(0.8, 0.8, 0.8)
        else
            objectiveBlock.ObjectiveText:SetTextColor(1, 1, 1)
        end

        if not ParseObjectiveString(objectiveBlock, text, objectiveType, quantity, nil, nil, isMythicKeystone) then
            objectiveBlock.StatusBar:Hide()
        end
        local h = objectiveBlock.ObjectiveText:GetStringHeight() + 10
        objectiveBlock:SetHeight(h)
        if objectiveBlock.StatusBar:IsShown() then
            if block.numObjectives >= 1 then
                h = h + objectiveBlock.StatusBar:GetHeight() + 10
            else
                h = h + objectiveBlock.StatusBar:GetHeight() + 5
            end
            objectiveBlock:SetHeight(h)
        end
        block.height = block.height + objectiveBlock:GetHeight()
        block.numObjectives = block.numObjectives + 1
    end
end
GW.AddScenarioObjectivesBlock = addObjectiveBlock
GW.AddForProfiling("scenario", "addObjectiveBlock", addObjectiveBlock)

local function updateCurrentScenario(self, event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local w = ...
        if not w or (w and allowedWidgetUpdateIdsForTimer[w.widgetID] == nil and allowedWidgetUpdateIdsForStatusBar[w.widgetID] == nil) then
            return
        end
    end

    GW.RemoveTrackerNotificationOfType("SCENARIO")
    GW.RemoveTrackerNotificationOfType("TORGHAST")
    GW.RemoveTrackerNotificationOfType("DELVE")

    local compassData = {}
    local showTimerAsBonus = false
    local GwQuestTrackerTimerSavedHeight = 1
    local isEmberCourtWidget = false
    local isEventTimerBarByWidgetId = false

    compassData.TYPE = "SCENARIO"
    compassData.TITLE = "Unknown Scenario"
    compassData.ID = "unknown"
    compassData.QUESTID = "unknown"
    compassData.COMPASS = false

    compassData.MAPID = nil
    compassData.X = nil
    compassData.Y = nil

    compassData.COLOR = TRACKER_TYPE_COLOR.SCENARIO

    scenarioBlock.height = 1

    if timerBlock:IsShown() then
        scenarioBlock.height = timerBlock.height
    end

    scenarioBlock.numObjectives = 0
    scenarioBlock.questLogIndex = 0
    scenarioBlock:Show()

    -- here we show only the statusbar
    for id, _ in pairs(allowedWidgetUpdateIdsForStatusBar) do
        local widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(id)
        if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
            addObjectiveBlock(
            scenarioBlock,
            ParseCriteria(widgetInfo.barValue, widgetInfo.barMax, widgetInfo.text),
            false,
            1,
            "object",
            widgetInfo.barValue)

            for i = scenarioBlock.numObjectives + 1, 20 do
                if _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i] then
                    _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
                end
            end

            compassData.TITLE = widgetInfo.text
            compassData.DESC = widgetInfo.text
            GW.AddTrackerNotification(compassData)

            scenarioBlock:SetHeight(scenarioBlock.height)
            self.oldHeight = GW.RoundInt(self:GetHeight())
            self:SetHeight(scenarioBlock.height)
            timerBlock.timer:Hide()

            GW.TerminateScenarioWidgetTimer()

            return
        end
    end

    local _, _, numStages = C_Scenario.GetInfo()
    if (numStages == 0 or IsOnGroundFloorInJailersTower())  then
        local name, instanceType, _, difficultyName, _ = GetInstanceInfo()
        if instanceType == "raid" then
            compassData.TITLE = name
            compassData.DESC = difficultyName
            GW.AddTrackerNotification(compassData)
            scenarioBlock.height = scenarioBlock.height + 5
        else
            GW.RemoveTrackerNotificationOfType("SCENARIO")
            GW.RemoveTrackerNotificationOfType("TORGHAST")
            scenarioBlock:Hide()
        end
        GW.CombatQueue_Queue(nil, UpdateQuestItem, {scenarioBlock})
        if scenarioBlock.hasItem then
            GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GW.updateQuestItemPositions, {scenarioBlock.actionButton, scenarioBlock.height, "SCENARIO", scenarioBlock})
        end
        for i = scenarioBlock.numObjectives + 1, 20 do
            if _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i] then
                _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
            end
        end

        scenarioBlock:SetHeight(scenarioBlock.height)

        self.oldHeight = GW.RoundInt(self:GetHeight())
        self:SetHeight(scenarioBlock.height)

        timerBlock.timer:Hide()

        GW.TerminateScenarioWidgetTimer()

        return
    end

    local stageName, stageDescription, numCriteria, _, _, _, _, _, _, questID = C_Scenario.GetStepInfo()

    local _, _, difficultyID, difficultyName = GetInstanceInfo()
    local isMythicKeystone = difficultyID == 8
    if stageDescription == nil then
        stageDescription = ""
    end
    if stageName == nil then
        stageName = ""
    end
    if difficultyName then
        local level = C_ChallengeMode.GetActiveKeystoneInfo()
        if level > 0 then
            compassData.TITLE = stageName .. " |cFFFFFFFF +" .. level .. " " .. difficultyName .. "|r"
        else
            compassData.TITLE = stageName .. " |cFFFFFFFF " .. difficultyName .. "|r"
        end
        compassData.DESC = stageDescription .. " "
    end

    if IsInJailersTower() then
        local floor = ""
        if event == "JAILERS_TOWER_LEVEL_UPDATE" then
            local level, type, textureKit = ...
            self.jailersTowerLevelUpdateInfo = {level = level, type = type, textureKit = textureKit}
        end
        local widgetInfo = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(3302)
        if widgetInfo then floor = widgetInfo.headerText or "" end

        if self.jailersTowerLevelUpdateInfo ~= nil and self.jailersTowerLevelUpdateInfo.type ~= nil then
            local typeString = C_ScenarioInfo.GetJailersTowerTypeString(self.jailersTowerLevelUpdateInfo.type)
            if typeString then
                compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. " - " .. typeString .. "|r"
            else
                compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. "|r"
            end
        else
            compassData.TITLE = difficultyName .. " |cFFFFFFFF " .. floor .. "|r"
        end

        compassData.COLOR = TRACKER_TYPE_COLOR.TORGHAST
        compassData.TYPE = "TORGHAST"
    end

    -- check for active delves
    local delvesWidgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183)
    if delvesWidgetInfo and delvesWidgetInfo.frameTextureKit and delvesWidgetInfo.frameTextureKit == "delves-scenario" then
        local tierLevel = delvesWidgetInfo.tierText or ""

        if GwObjectivesNotification then
            GwObjectivesNotification.iconFrame.tooltipSpellID = delvesWidgetInfo.tierTooltipSpellID
        end

        compassData.TITLE = difficultyName .. " |cFFFFFFFF(" .. tierLevel .. ")|r - " .. delvesWidgetInfo.headerText

        scenarioBlock.delvesFrame:Show()
        scenarioBlock.delvesFrame.reward:Show()

        local id = 1
        for _, spellInfo in ipairs(delvesWidgetInfo.spells) do
            if spellInfo.shownState ~= Enum.WidgetShownState.Hidden then
                local spellData = C_Spell.GetSpellInfo(spellInfo.spellID)

                SetPortraitToTexture(scenarioBlock.delvesFrame.spell[id].icon, spellData.iconID)
                scenarioBlock.delvesFrame.spell[id].icon:SetDesaturated(spellInfo.enabledState == Enum.WidgetEnabledState.Disabled)

                scenarioBlock.delvesFrame.spell[id].spellID = spellData.spellID
                scenarioBlock.delvesFrame.spell[id]:Show()

                id = id + 1
            end
        end

        for i = id, 5 do
            scenarioBlock.delvesFrame.spell[i].spellID = nil
            scenarioBlock.delvesFrame.spell[i]:Hide()
        end

        -- handle death
        if delvesWidgetInfo.currencies and #delvesWidgetInfo.currencies > 0 and delvesWidgetInfo.currencies[1].textEnabledState > 0 then
            scenarioBlock.delvesFrame.deathCounter.tooltip = delvesWidgetInfo.currencies[1].tooltip
            scenarioBlock.delvesFrame.deathCounter.counter:SetText(delvesWidgetInfo.currencies[1].text)
            scenarioBlock.delvesFrame.deathCounter.icon:SetTexture(delvesWidgetInfo.currencies[1].iconFileID)

            scenarioBlock.delvesFrame.deathCounter:Show()
        else
            scenarioBlock.delvesFrame.deathCounter:Show()
        end

        -- handle rewards
        if delvesWidgetInfo.rewardInfo.shownState ~= Enum.UIWidgetRewardShownState.Hidden then
            local rewardTooltip = (delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownEarned) and delvesWidgetInfo.rewardInfo.earnedTooltip or delvesWidgetInfo.rewardInfo.unearnedTooltip
            scenarioBlock.delvesFrame.reward.tooltip = rewardTooltip

            scenarioBlock.delvesFrame.reward.earned:SetShown(delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownEarned)
            scenarioBlock.delvesFrame.reward.unearned:SetShown(delvesWidgetInfo.rewardInfo.shownState == Enum.UIWidgetRewardShownState.ShownUnearned)

            scenarioBlock.delvesFrame.reward:Show()
        else
            scenarioBlock.delvesFrame.reward:Hide()
        end

        compassData.COLOR = TRACKER_TYPE_COLOR.DELVE
        compassData.TYPE = "DELVE"
    else
        scenarioBlock.delvesFrame:Hide()
    end

    setBlockColor(scenarioBlock, compassData.TYPE)
    scenarioBlock.Header:SetTextColor(scenarioBlock.color.r, scenarioBlock.color.g, scenarioBlock.color.b)
    scenarioBlock.hover:SetVertexColor(scenarioBlock.color.r, scenarioBlock.color.g, scenarioBlock.color.b)
    GW.AddTrackerNotification(compassData, true)

    if questID ~= nil then
        scenarioBlock.questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    end

    GW.CombatQueue_Queue(nil, UpdateQuestItem, {scenarioBlock})

    for criteriaIndex = 1, numCriteria do
        local scenarioCriteriaInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)
        if scenarioCriteriaInfo then
            local objectiveType = scenarioCriteriaInfo.isWeightedProgress and "progressbar" or "monster"

            if objectiveType == "progressbar" and not isMythicKeystone then
                scenarioCriteriaInfo.totalQuantity = 100
            end

            local mythicKeystoneCurrentValue = 0
            if isMythicKeystone then
                mythicKeystoneCurrentValue = tonumber(string.match(scenarioCriteriaInfo.quantityString, "%d+")) or 1
            end

            addObjectiveBlock(
                scenarioBlock,
                ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description, isMythicKeystone, mythicKeystoneCurrentValue, scenarioCriteriaInfo.isWeightedProgress),
                false,
                criteriaIndex,
                objectiveType,
                scenarioCriteriaInfo.quantity,
                isMythicKeystone
            )
        end
    end
    -- add special widgets here
    numCriteria = GW.addWarfrontData(scenarioBlock, numCriteria)
    numCriteria = GW.addHeroicVisionsData(scenarioBlock, numCriteria)
    numCriteria = GW.addJailersTowerData(scenarioBlock, numCriteria)

    if not showTimerAsBonus then
        numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget = GW.addEmberCourtData(scenarioBlock, numCriteria, GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEmberCourtWidget)
    end
    for id, _ in pairs(allowedWidgetUpdateIdsForTimer) do
        if not showTimerAsBonus then
            GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId = GW.addEventTimerBarByWidgetId(GwQuestTrackerTimerSavedHeight, showTimerAsBonus, isEventTimerBarByWidgetId, id)
        end
    end

    local bonusSteps = C_Scenario.GetBonusSteps() or {}
    local numCriteriaPrev = numCriteria

    for _, v in pairs(bonusSteps) do
        local bonusStepIndex = v
        local _, _, numCriteriaForStep = C_Scenario.GetStepInfo(bonusStepIndex)

        for criteriaIndex = 1, numCriteriaForStep do
            local scenarioCriteriaInfo = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
            local objectiveType = "progressbar"
            if not scenarioCriteriaInfo.isWeightedProgress then
                objectiveType = "monster"
            end
            -- timer bar
            if (scenarioCriteriaInfo.duration > 0 and scenarioCriteriaInfo.elapsed <= scenarioCriteriaInfo.duration and not (scenarioCriteriaInfo.failed or scenarioCriteriaInfo.completed)) then
                timerBlock:SetScript(
                    "OnUpdate",
                    function()
                        local scenarioCriteriaInfoByStep = C_ScenarioInfo.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex)
                        if scenarioCriteriaInfoByStep.elapsed and scenarioCriteriaInfoByStep.elapsed > 0 then
                            timerBlock.timer:SetValue(1 - (scenarioCriteriaInfoByStep.elapsed / scenarioCriteriaInfo.duration))
                            timerBlock.timerString:SetText(SecondsToClock(scenarioCriteriaInfo.duration - scenarioCriteriaInfoByStep.elapsed))
                        else
                            timerBlock:SetScript("OnUpdate", nil)
                        end
                    end
                )
                timerBlock.timer:Show()
                timerBlock.needToShowTimer = true
                GwQuestTrackerTimerSavedHeight = GwQuestTrackerTimerSavedHeight + 40
                showTimerAsBonus = true
            elseif not showTimerAsBonus then
                GwQuestTrackerTimerSavedHeight = 1
                timerBlock:SetScript("OnUpdate", nil)
                timerBlock.timer:Hide()
                addObjectiveBlock(
                    scenarioBlock,
                    ParseCriteria(scenarioCriteriaInfo.quantity, scenarioCriteriaInfo.totalQuantity, scenarioCriteriaInfo.description),
                    false,
                    numCriteriaPrev + criteriaIndex,
                    objectiveType,
                    scenarioCriteriaInfo.quantity
                )
            end
        end
        numCriteriaPrev = numCriteriaPrev + numCriteriaForStep
    end

    for i = scenarioBlock.numObjectives + 1, 20 do
        if _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i] then
            _G[scenarioBlock:GetName() .. "GwQuestObjective" .. i]:Hide()
        end
    end

    scenarioBlock.height = scenarioBlock.height + 5
    if scenarioBlock.hasItem then
        GW.CombatQueue_Queue("update_tracker_scenario_itembutton_position", GW.updateQuestItemPositions, {scenarioBlock.actionButton, scenarioBlock.height, "SCENARIO", scenarioBlock})
    end

    local intGWQuestTrackerHeight = 0

    if timerBlock.affixeFrame:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end

    if timerBlock.timer:IsShown() then
        intGWQuestTrackerHeight = intGWQuestTrackerHeight + 40
    end

    if showTimerAsBonus or isEmberCourtWidget or isEventTimerBarByWidgetId then
        timerBlock.height = GwQuestTrackerTimerSavedHeight
    end

    timerBlock:SetHeight(timerBlock.height)
    scenarioBlock:SetHeight(scenarioBlock.height - intGWQuestTrackerHeight)
    self.oldHeight = GW.RoundInt(self:GetHeight())
    self:SetHeight(scenarioBlock.height)
end
GW.updateCurrentScenario = updateCurrentScenario
GW.AddForProfiling("scenario", "updateCurrentScenario", updateCurrentScenario)

local function scenarioTimerStop(self)
    self:SetScript("OnUpdate", nil)
    self.timer:Hide()
    self.chestoverlay:Hide()
    self.deathcounter:Hide()
end
GW.AddForProfiling("scenario", "scenarioTimerStop", scenarioTimerStop)

local function scenarioAffixes(self, fakeIds)
    local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    affixes = fakeIds and #fakeIds > 0 and fakeIds or affixes

    for idx, v in pairs(affixes) do
        if idx == 1 then
            self.height = self.height + 40
        end

        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(v)
        if filedataid then
            SetPortraitToTexture(self.affixeFrame.affixes[idx].icon, filedataid)
        end
        self.affixeFrame.affixes[idx].affixID = v
        self.affixeFrame.affixes[idx]:Show()
        self.affixeFrame:Show()
        self.affixeFrame:SetHeight(40) -- needed for anchor points
    end

    if not affixes or (affixes and #affixes == 0) then
        for _, v in ipairs(self.affixeFrame.affixes) do
            v.affixID = nil
            v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
        end
        self.affixeFrame:Hide()
        self.affixeFrame:SetHeight(1) -- needed for anchor points
    end
end
GW.AddForProfiling("scenario", "scenarioAffixes", scenarioAffixes)

local function scenarioTimerUpdateDeathCounter(self)
    local count, timeLost = C_ChallengeMode.GetDeathCount()
    self.deathcounter.count = count
    self.deathcounter.timeLost = timeLost
    if (timeLost and timeLost > 0 and count and count > 0) then
        self.deathcounter.counterlabel:SetText(count)
        self.deathcounter:Show()
    else
        self.deathcounter:Hide()
    end
end
GW.AddForProfiling("scenario", "scenarioTimerUpdateDeathCounter", scenarioTimerUpdateDeathCounter)

local function scenarioTimerUpdate(self, ...)
    self.height = 1

    -- fake timer
    local fake = false

    if fake then
        self.timer:Show()
        self.needToShowTimer = true
        self.height = self.height + 50
        scenarioAffixes(self, {146})
        scenarioTimerUpdateDeathCounter(self)
        self.chestoverlay:Show()
        self.chestoverlay.chest2:Show()
        self.chestoverlay.chest3:Show()
        self.chestoverlay.timerStringChest3:Show()
        self.chestoverlay.timerStringChest2:Show()

        return
    end

    for i = 1, select("#", ...) do
        local timerID = select(i, ...)
        local _, _, wtype = GetWorldElapsedTime(timerID)
        if (wtype == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
            local mapID = C_ChallengeMode.GetActiveChallengeMapID()
            if mapID then
                local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
                local time3 = timeLimit * TIME_FOR_3
                local time2 = timeLimit * TIME_FOR_2
                --    Scenario_ChallengeMode_ShowBlock(timerID, elapsedTime, timeLimit);
                --set Chest icon
                self.chestoverlay:Show()
                self:SetScript(
                    "OnUpdate",
                    function()
                        local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                        self.timer:SetValue(1 - (elapsedTime / timeLimit))
                        self.chestoverlay.chest2:SetShown(elapsedTime < time2)
                        self.chestoverlay.chest3:SetShown(elapsedTime < time3)
                        if elapsedTime < timeLimit then
                            self.timerString:SetText(SecondsToClock(timeLimit - elapsedTime))
                            self.timerString:SetTextColor(1, 1, 1)
                        else
                            self.timerString:SetText(SecondsToClock(0))
                            self.timerString:SetTextColor(255, 0, 0)
                        end
                        if elapsedTime < time3 then
                            self.chestoverlay.timerStringChest3:SetText(SecondsToClock(time3 - elapsedTime))
                            self.chestoverlay.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                            self.chestoverlay.timerStringChest3:Show()
                            self.chestoverlay.timerStringChest2:Show()
                        elseif elapsedTime < time2 then
                            self.chestoverlay.timerStringChest2:SetText(SecondsToClock(time2 - elapsedTime))
                            self.chestoverlay.timerStringChest2:Show()
                            self.chestoverlay.timerStringChest3:Hide()
                        else
                            self.chestoverlay.timerStringChest2:Hide()
                            self.chestoverlay.timerStringChest3:Hide()
                        end
                    end
                )
                self.timer:Show()
                self.needToShowTimer = true
                self.height = self.height + 50
                scenarioAffixes(self)
                scenarioTimerUpdateDeathCounter(self)
                return
            end
        elseif (wtype == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND) then
            local _, _, _, duration = C_Scenario.GetProvingGroundsInfo()
            if (duration > 0) then
                --    Scenario_ProvingGrounds_ShowBlock(timerID, elapsedTime, duration, diffID, currWave, maxWave);
                self:SetScript(
                    "OnUpdate",
                    function()
                        local _, elapsedTime, _ = GetWorldElapsedTime(timerID)
                        self.timer:SetValue(1 - (elapsedTime / duration))
                        self.timerString:SetText(SecondsToClock(duration - elapsedTime))
                    end
                )
                self.timer:Show()
                self.needToShowTimer = true
                self.height = self.height + 40
                return
            end
        end
    end
    self.timer:Hide()
    self.chestoverlay:Hide()
    self.deathcounter:Hide()
    self:SetScript("OnUpdate", nil)
    self.needToShowTimer = false

    for _, v in ipairs(self.affixeFrame.affixes) do
        v.affixID = nil
        v.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-boss")
    end
    self.affixeFrame:Hide()
    self.affixeFrame:SetHeight(1) -- needed for anchor points
end
GW.AddForProfiling("scenario", "scenarioTimerUpdate", scenarioTimerUpdate)

local function scenarioTimerOnEvent(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD" or event == nil) then
        scenarioTimerUpdate(self, GetWorldElapsedTimers())
        scenarioTimerUpdateDeathCounter(self)
    elseif (event == "WORLD_STATE_TIMER_START") then
        local timerID = ...
        scenarioTimerUpdate(self, timerID)
    elseif (event == "WORLD_STATE_TIMER_STOP") then
        scenarioTimerStop(self)
    elseif (event == "PROVING_GROUNDS_SCORE_UPDATE") then
        local score = ...
        self.score.scoreString:SetText(score)
        self.score:Show()
        self.height = self.height + 40
    elseif (event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_MAPS_UPDATE" or event == "ZONE_CHANGED") then
        scenarioTimerUpdate(self, GetWorldElapsedTimers())
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        scenarioTimerUpdateDeathCounter(self)
    end
    self:SetHeight(self.height)

    updateCurrentScenario(GwQuesttrackerContainerScenario)
end
GW.AddForProfiling("scenario", "scenarioTimerOnEvent", scenarioTimerOnEvent)

local function UIWidgetTemplateTooltipFrameOnEnter(self)
    if self.tooltip then
        self.tooltipContainsHyperLink = false
        self.preString = nil
        self.hyperLinkString = nil
        self.postString = nil
        self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(self.tooltip)

        EmbeddedItemTooltip:SetOwner(self, "ANCHOR_LEFT")

        if self.tooltipContainsHyperLink then
            local clearTooltip = true
            if self.preString and self.preString:len() > 0 then
                EmbeddedItemTooltip:AddLine(self.preString, 1, 1, 1, true)
                clearTooltip = false
            end

            GameTooltip_ShowHyperlink(EmbeddedItemTooltip, self.hyperLinkString, 0, 0, clearTooltip)

            if self.postString and self.postString:len() > 0 then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true)
            end

            self.UpdateTooltip = self.OnEnter

            EmbeddedItemTooltip:Show()
        else
            local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip)
            if header then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true)
            end
            if nonHeader then
                GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true)
            end
            self.UpdateTooltip = nil

            EmbeddedItemTooltip:SetShown(header ~= nil)
        end
    end
end

local function LoadScenarioFrame(container)
    container:SetScript("OnEvent", updateCurrentScenario)

    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:RegisterEvent("SCENARIO_UPDATE")
    container:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
    container:RegisterEvent("LOOT_CLOSED")
    container:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    container:RegisterEvent("UPDATE_UI_WIDGET")
    container:RegisterEvent("ZONE_CHANGED_INDOORS")
    container:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    container:RegisterEvent("ZONE_CHANGED")
    container:RegisterEvent("SCENARIO_COMPLETED")
    container:RegisterEvent("SCENARIO_SPELL_UPDATE")
    container:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE")

    container.jailersTowerType = nil

    -- JailersTower hook
    -- do it only here so we are sure we do not hook more than one time
    hooksecurefunc(ScenarioObjectiveTracker, "SlideInContents", function(self)
        if self:ShouldShowCriteria() and IsInJailersTower() then
            updateCurrentScenario(container)
        end
    end)

    timerBlock = CreateFrame("Button", "GwQuestTrackerTimer", container, "GwQuesttrackerScenarioBlock")
    timerBlock.needToShowTimer = false
    timerBlock.height = timerBlock:GetHeight()
    timerBlock.timerlabel = timerBlock.timer.timerlabel
    timerBlock.timerString = timerBlock.timer.timerString
    timerBlock.timerlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    timerBlock.timerlabel:SetTextColor(1, 1, 1)
    timerBlock.timerlabel:SetShadowOffset(1, -1)
    timerBlock.timerString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    timerBlock.timerString:SetTextColor(1, 1, 1)
    timerBlock.timerString:SetShadowOffset(1, -1)
    timerBlock.chestoverlay.timerStringChest2:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    timerBlock.chestoverlay.timerStringChest2:SetTextColor(1, 1, 1)
    timerBlock.chestoverlay.timerStringChest2:SetShadowOffset(1, -1)
    timerBlock.chestoverlay.timerStringChest3:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    timerBlock.chestoverlay.timerStringChest3:SetTextColor(1, 1, 1)
    timerBlock.chestoverlay.timerStringChest3:SetShadowOffset(1, -1)
    timerBlock.chestoverlay.chest2:ClearAllPoints()
    timerBlock.chestoverlay.chest3:ClearAllPoints()
    timerBlock.chestoverlay.timerStringChest2:ClearAllPoints()
    timerBlock.chestoverlay.timerStringChest3:ClearAllPoints()
    timerBlock.chestoverlay.chest2:SetPoint("LEFT", timerBlock.timer, "LEFT", timerBlock.timer:GetWidth() * (1 - TIME_FOR_2) - 1, -6)
    timerBlock.chestoverlay.chest3:SetPoint("LEFT", timerBlock.timer, "LEFT", timerBlock.timer:GetWidth() * (1 - TIME_FOR_3) - 1, -6)
    timerBlock.chestoverlay.timerStringChest2:SetPoint("RIGHT", timerBlock.chestoverlay.chest2, "LEFT", -2, -6)
    timerBlock.chestoverlay.timerStringChest3:SetPoint("RIGHT", timerBlock.chestoverlay.chest3, "LEFT", -2, -6)
    timerBlock.deathcounter.counterlabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -2)
    timerBlock.deathcounter.counterlabel:SetTextColor(1, 1, 1)
    timerBlock.deathcounter.counterlabel:SetShadowOffset(1, -1)
    timerBlock.score.scoreString:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    for _, v in ipairs(timerBlock.affixeFrame.affixes) do
        v:SetScript(
            "OnEnter",
            function(self)
                if self.affixID then
                    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 50)
                    GameTooltip:ClearLines()
                    local name, description = C_ChallengeMode.GetAffixInfo(self.affixID)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(name, 1, 1, 1, 1, true)
                    GameTooltip:AddLine(description, nil, nil, nil, true)
                    GameTooltip:Show()
                end
            end
        )
        v:SetScript("OnLeave", GameTooltip_Hide)
    end

    timerBlock.deathcounter:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.count), 1, 1, 1)
            GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(self.timeLost)))
            GameTooltip:Show()
        end
    )
    timerBlock.deathcounter:SetScript("OnLeave", GameTooltip_Hide)

    timerBlock:SetParent(container)
    timerBlock:ClearAllPoints()
    timerBlock:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    timerBlock:RegisterEvent("PLAYER_ENTERING_WORLD")
    timerBlock:RegisterEvent("WORLD_STATE_TIMER_START")
    timerBlock:RegisterEvent("WORLD_STATE_TIMER_STOP")
    timerBlock:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE")
    timerBlock:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    timerBlock:RegisterEvent("CHALLENGE_MODE_START")
    timerBlock:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    timerBlock:RegisterEvent("ZONE_CHANGED")
    timerBlock:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")

    timerBlock:SetScript("OnEvent", scenarioTimerOnEvent)

    scenarioBlock = CreateTrackerObject("GwScenarioBlock", container)
    scenarioBlock:SetParent(container)
    scenarioBlock:SetPoint("TOPRIGHT", timerBlock, "BOTTOMRIGHT", 0, 0)
    scenarioBlock.Header:SetText("")

    scenarioBlock.actionButton = CreateFrame("Button", nil, GwQuestTracker, "GwQuestItemTemplate")
    scenarioBlock.actionButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    scenarioBlock.actionButton.NormalTexture:SetTexture(nil)
    scenarioBlock.actionButton:RegisterForClicks("AnyUp", "AnyDown")
    scenarioBlock.actionButton:SetScript("OnShow", scenarioBlock.actionButton.OnShow)
    scenarioBlock.actionButton:SetScript("OnHide", scenarioBlock.actionButton.OnHide)
    scenarioBlock.actionButton:SetScript("OnEnter", scenarioBlock.actionButton.OnEnter)
    scenarioBlock.actionButton:SetScript("OnLeave", GameTooltip_Hide)
    scenarioBlock.actionButton:SetScript("OnEvent", scenarioBlock.actionButton.OnEvent)

    setBlockColor(scenarioBlock, "SCENARIO")
    scenarioBlock.Header:SetTextColor(scenarioBlock.color.r, scenarioBlock.color.g, scenarioBlock.color.b)
    scenarioBlock.hover:SetVertexColor(scenarioBlock.color.r, scenarioBlock.color.g, scenarioBlock.color.b)

    scenarioBlock.delvesFrame:ClearAllPoints()
    scenarioBlock.delvesFrame:SetPoint("TOPRIGHT", GwObjectivesNotification, "BOTTOMRIGHT", 0, 35)

    for _, v in ipairs(scenarioBlock.delvesFrame.spell) do
        v:SetScript(
            "OnEnter",
            function(self)
                if self.spellID then
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:SetSpellByID(self.spellID)
                    GameTooltip:Show()
                end
            end
        )
        v:SetScript("OnLeave", GameTooltip_Hide)
    end

    scenarioBlock.delvesFrame.reward:SetScript("OnEnter", UIWidgetTemplateTooltipFrameOnEnter)
    scenarioBlock.delvesFrame.reward:SetScript("OnLeave", function()
        UIWidgetTemplateTooltipFrameMixin:OnLeave()
    end)

    scenarioBlock.delvesFrame.deathCounter:SetScript("OnEnter", UIWidgetTemplateTooltipFrameOnEnter)
    scenarioBlock.delvesFrame.deathCounter:SetScript("OnLeave", function()
        UIWidgetTemplateTooltipFrameMixin:OnLeave()
    end)
    scenarioBlock.delvesFrame.deathCounter.counter:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    C_Timer.After(0.8, function() updateCurrentScenario(container) end)

    scenarioTimerOnEvent(timerBlock)
end
GW.LoadScenarioFrame = LoadScenarioFrame
