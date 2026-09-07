---@class GW2
local GW = select(2, ...)
local ET = GW.EventTracker

-- tracker type "weekly": icon, label and a completed / not completed sub line, no timer
-- args: questIDs (list, storyline map or function) and/or questProgress (list or function),
--       checkAllCompleted, completedText, notCompletedText, hasWeeklyReward, onClick
ET.types.weekly = {
    init = function(self)
        ET.CreateRow(self)

        self:SetScript("OnMouseDown", function()
            if self.args.onClick then
                self.args:onClick()
            end
        end)
    end,
    setup = function(self)
        ET.SetupRow(self)
        self.timerText:SetText("")
        self.progress:Hide()
    end,
    ticker = {
        interval = 2,
        dateUpdater = function(self)
            local args = self.args

            -- progress list without quest ids: done when every entry with a quest is done
            if args.questProgress and not args.questIDs then
                local questProgress = args.questProgress
                if type(questProgress) == "function" then
                    questProgress = questProgress(args)
                end

                if questProgress then
                    local allCompleted = true
                    for _, data in ipairs(questProgress) do
                        if not (data.questID and ET.IsAnyQuestCompleted(data.questID)) then
                            allCompleted = false
                            break
                        end
                    end
                    self.isCompleted = allCompleted
                end
                return
            end

            if not args.questIDs then
                return
            end

            local questIDs = type(args.questIDs) == "function" and args:questIDs() or args.questIDs
            if type(questIDs) ~= "table" then
                return
            end

            -- storyline map: done when every storyline has a completed quest
            if type(next(questIDs)) ~= "number" then
                for _, storylineQuests in pairs(questIDs) do
                    if not ET.IsAnyQuestCompleted(storylineQuests) then
                        self.isCompleted = false
                        return
                    end
                end
                self.isCompleted = true
                return
            end

            self.isCompleted = ET.IsQuestListCompleted(questIDs, args.checkAllCompleted)
        end,
        uiUpdater = function(self)
            self.icon:SetDesaturated(self.args.desaturate and self.isCompleted)
            ET.SetRowState(self, "neutral")
            if self.isCompleted then
                self.subText:SetText(self.args.completedText or CRITERIA_COMPLETED)
                self.subText:SetTextColor(ET.rowColors.completed:GetRGB())
            else
                self.subText:SetText(self.args.notCompletedText or CRITERIA_NOT_COMPLETED)
                self.subText:SetTextColor(ET.rowColors.open:GetRGB())
            end
        end,
    },
    tooltip = {
        onEnter = function(self)
            ET.TooltipHeader(self)
            GameTooltip:AddLine(" ")
            ET.AddLocationLines(self)
            ET.AddQuestProgressLines(self)
            ET.AddWeeklyRewardLine(self)
            ET.AddClickHelpLine(self)
            GameTooltip:Show()
        end,
    },
}
