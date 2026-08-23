---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- EVOKER (essence, augmentation Ebon Might)
if GW.myClassID ~= GW.Enum.ClassIndex.Evoker or not GW.Retail then return end

-- UnitPartialPower reports the recharge progress of the next point as 0..1000
local ESSENCE_PARTIAL_RESOLUTION = 1000

local function SetEssenceFull(point, playFlash)
    point.EssenceFilling:Hide()
    point.EssenceDepleting:Hide()
    point.EssenceFull:Show()
    if playFlash then
        point.EssenceFull.FlashAnim:Restart()
    end
end

local function SetEssenceEmpty(point)
    if point.EssenceFull:IsShown() or point.EssenceFilling:IsShown() then
        point.EssenceFull:Hide()
        point.EssenceFilling:Hide()
        point.EssenceDepleting:Show() -- plays its fade and hides itself
    end
end

local function SetEssenceFilling(point, duration, elapsed)
    point.EssenceFull:Hide()
    point.EssenceDepleting:Hide()
    local wasFilling = point.EssenceFilling:IsShown()
    point.EssenceFilling:Show()
    if elapsed then
        point.EssenceFilling.Swipe:SetCooldown(GetTime() - elapsed, duration)
    elseif not wasFilling or point.gwSwipeDuration ~= duration then
        point.EssenceFilling.Swipe:SetCooldown(GetTime(), duration)
    end
    point.gwSwipeDuration = duration
end

local function powerEssence(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and event ~= "UNIT_POWER_POINT_CHARGE" and pType ~= "ESSENCE" then
        return
    end

    local pwrMax = UnitPowerMax("player", Enum.PowerType.Essence)
    local pwr = UnitPower("player", Enum.PowerType.Essence)
    self.gwPower = pwr

    local essenceSlots = min(max(pwrMax, 0), 6)
    if essenceSlots > 0 then
        local essenceWidth = essenceSlots * 32
        self.evoker:SetWidth(essenceWidth)
        self:SetWidth(essenceWidth)
        CP.SetClassPowerAnchor(self.evoker, self, "LEFT")
    end

    for i = 1, 6 do
        self.evoker["essence" .. i]:SetShown(i <= pwrMax)
    end

    for i = 1, min(pwr, 6) do
        local point = self.evoker["essence" .. i]
        SetEssenceFull(point, point.EssenceFilling:IsShown())
    end
    for i = pwr + 2, 6 do
        SetEssenceEmpty(self.evoker["essence" .. i])
    end

    if pwr < pwrMax and self.evoker["essence" .. pwr + 1] then
        local peace = GetPowerRegenForPowerType(Enum.PowerType.Essence)
        if GW.IsSecretValue(peace) then return end
        if (peace == nil or peace == 0) then
            peace = 0.2
        end
        local duration = 1 / peace
        local partial = UnitPartialPower("player", Enum.PowerType.Essence)
        local elapsed
        if GW.NotSecretValue(partial) and partial then
            elapsed = (partial / ESSENCE_PARTIAL_RESOLUTION) * duration
        end
        SetEssenceFilling(self.evoker["essence" .. pwr + 1], duration, elapsed)
    end
end

-- this needs also the essence bar

-- Ebon Might Spell that applies Aura on Self
local EBON_MIGHT_SELF_AURA_SPELL_ID = 395296

local function setEvoker(f)
    CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
    f.barType = "essence"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.evoker:SetWidth(6 * 32)
    f:SetWidth(f.evoker:GetWidth())
    f:SetHeight(32)
    CP.SetClassPowerAnchor(f.evoker, f, "LEFT")
    f.evoker:Show()

    f:SetScript("OnEvent", powerEssence)
    powerEssence(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    f:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")

    if GW.myspec == 3 then
        local tracker = CP.EnableAuraTracker(f, "EvokerEbonMight", {
            unit = "player",
            filter = "HELPFUL",
            spellIDs = { [EBON_MIGHT_SELF_AURA_SPELL_ID] = true },
            width = 115,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "agu", "furyspark", false, true) end,
        })
        CP.SetClassPowerCustomResourceBarAnchor(tracker, f.gwMover, f, 0, 0, 2, 4)
    end
    return true
end

CP.setups[GW.Enum.ClassIndex.Evoker] = setEvoker
