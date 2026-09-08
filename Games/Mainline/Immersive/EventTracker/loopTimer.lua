---@class GW2
local GW = select(2, ...)
local L = GW.L
local ET = GW.EventTracker

-- tracker type "loopTimer": events that run on a fixed schedule (startTimestamp + n * interval,
-- active for duration) or, with args.dateUpdater, on a custom schedule source
-- args: startTimestamp, interval, duration, questIDs, checkAllCompleted, runningText,
--       runningTextUpdater, filter, hasWeeklyReward, onClick, dateUpdater
ET.types.loopTimer = {
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
        self.progress:Show()
    end,
    ticker = {
        interval = 0.3,
        dateUpdater = function(self)
            local args = self.args
            if args.dateUpdater then
                args.dateUpdater(self)
                return
            end

            self.isCompleted = type(args.questIDs) == "table" and ET.IsQuestListCompleted(args.questIDs, args.checkAllCompleted) or false

            local timeSinceStart = GetServerTime() - args.startTimestamp
            self.timeOver = timeSinceStart % args.interval
            self.nextEventIndex = floor(timeSinceStart / args.interval) + 1
            self.nextEventTimestamp = args.startTimestamp + args.interval * self.nextEventIndex

            if self.timeOver < args.duration then
                self.timeLeft = args.duration - self.timeOver
                self.isRunning = true
            else
                self.timeLeft = args.interval - self.timeOver
                self.isRunning = false
            end
        end,
        uiUpdater = function(self)
            self.icon:SetDesaturated(self.args.desaturate and self.isCompleted)
            self.timerText:SetText(ET.SecondToTime(self.timeLeft))

            if self.isRunning then
                -- time left of the running event, the sub line names the state (or the location)
                ET.SetRowState(self, "running")
                self.progress:SetValue(self.args.duration > 0 and self.timeOver / self.args.duration or 0)
                if self.args.runningTextUpdater then
                    self.subText:SetText(self.args:runningTextUpdater())
                else
                    self.subText:SetText(self.args.runningText)
                end
            else
                -- time until the next start, the line fills up towards it
                ET.SetRowState(self, "neutral")
                self.progress:SetValue(self.args.interval > 0 and 1 - (self.timeLeft / self.args.interval) or 0)
                self.subText:SetText(self.args.location)
            end
        end,
        alert = function(self)
            local args = self.args
            if not args.alertSecond or self.isRunning then
                return
            end

            -- no known next event (e.g. the scheduler has no data yet): nothing to announce
            if not self.nextEventIndex or not self.timeLeft or self.timeLeft <= 0 then
                return
            end

            args.alertCache = args.alertCache or {}
            if args.alertCache[self.nextEventIndex] then
                return
            end

            if args.stopAlertIfCompleted and self.isCompleted then
                return
            end

            if args.filter and not args:filter() then
                return
            end

            if self.timeLeft <= args.alertSecond then
                args.alertCache[self.nextEventIndex] = true
                local eventIconString = GW.GetIconString(args.icon, 16, 16)
                local eventName = ET.StringByTemplate(args.eventName, "warning")
                local remainTime = ET.StringByTemplate(ET.SecondToTime(self.timeLeft), "warning")
                GW.Notice(format(L["%s will start in %s!"], eventIconString .. " " .. eventName, remainTime))
                if args.flashTaskbar then
                    FlashClientIcon()
                end
            end
        end
    },
    tooltip = {
        onEnter = function(self)
            ET.TooltipHeader(self)

            GameTooltip:AddLine(" ")
            ET.AddLocationLines(self)

            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(L["Interval"] .. ":", ET.SecondToTime(self.args.interval), 1, 1, 1)
            GameTooltip:AddDoubleLine(AUCTION_DURATION .. ":", ET.SecondToTime(self.args.duration), 1, 1, 1)
            if self.nextEventTimestamp then
                GameTooltip:AddDoubleLine(L["Next Event"] .. ":", date(L["TimeStamp m/d h:m:s"], self.nextEventTimestamp), 1, 1, 1)
            end

            GameTooltip:AddLine(" ")
            if self.isRunning then
                GameTooltip:AddDoubleLine(STATUS .. ":", ET.StringByTemplate(self.args.runningText, "success"), 1, 1, 1)
            else
                GameTooltip:AddDoubleLine(STATUS .. ":", ET.StringByTemplate(QUEUED_STATUS_WAITING, "greyLight"), 1, 1, 1)
            end

            ET.AddQuestProgressLines(self)
            ET.AddWeeklyRewardLine(self)
            ET.AddClickHelpLine(self)

            GameTooltip:Show()
        end,
    },
}
