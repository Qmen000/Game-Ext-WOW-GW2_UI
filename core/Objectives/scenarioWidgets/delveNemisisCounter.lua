---@class GW2
local GW = select(2, ...)

local eventFrame = CreateFrame("Frame")
local CURRENCY_AFFIX_ACTIVE = 3103
local CURRENCY_AFFIX_MAXIMUM = 3104

local function OnEvent(self, event, ...)
    local currencyID = ...
    if event == "CURRENCY_DISPLAY_UPDATE" and currencyID and (currencyID == CURRENCY_AFFIX_ACTIVE or currencyID == CURRENCY_AFFIX_MAXIMUM) then
        GW.RequestNemesisCounterUpdate(self.spellFrame)
    end
end
eventFrame:SetScript("OnEvent", OnEvent)

local function UpdateCounter(spellFrame)
    if not spellFrame or not spellFrame.notification or not spellFrame.notification.Text then
        GW.StopNemesisCounter()
        return
    end

    local info, current, max

    info = C_CurrencyInfo.GetCurrencyInfo(CURRENCY_AFFIX_ACTIVE)
    if info then
        current = info.quantity
    end

    info = C_CurrencyInfo.GetCurrencyInfo(CURRENCY_AFFIX_MAXIMUM)
    if info then
        max = info.quantity
    end

    if current and max and max > 0 then
        if current <= 0 then
            spellFrame.notification.Text:SetText("")
            spellFrame.notification.Tick:Show()
        else
            spellFrame.notification.Text:SetText(current)
            spellFrame.notification.Text:SetTextColor(1, 1, 1, 1)
            spellFrame.notification.Tick:Hide()
        end
        eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
        spellFrame.notification:Show()
    else
        GW.StopNemesisCounter()
    end
end

function GW.RequestNemesisCounterUpdate(spellFrame)
    if not spellFrame then
        GW.StopNemesisCounter()
        return
    end

    if eventFrame.pendingTimer then
        eventFrame.pendingTimer:Cancel()
        eventFrame.pendingTimer = nil
    end

    eventFrame.spellFrame = spellFrame

    eventFrame.pendingTimer = C_Timer.NewTimer(1, function()
        eventFrame.pendingTimer = nil
        UpdateCounter(eventFrame.spellFrame)
    end)
end

function GW.StopNemesisCounter()
    if eventFrame.pendingTimer then
        eventFrame.pendingTimer:Cancel()
        eventFrame.pendingTimer = nil
    end

    if eventFrame.spellFrame then
        eventFrame.spellFrame.notification.Text:SetText("")
        if eventFrame.spellFrame.notification.Tick then
            eventFrame.spellFrame.notification.Tick:Hide()
        end
        eventFrame.spellFrame.notification:Hide()
    end

    eventFrame.spellFrame = nil
    eventFrame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
end
