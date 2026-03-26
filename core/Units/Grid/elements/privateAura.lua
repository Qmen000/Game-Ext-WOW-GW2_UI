---@class GW2
local GW = select(2, ...)

function GW.Construct_PrivateAura(frame)
    if not GW.Retail then return end
    return CreateFrame('Frame', '$parentPrivateAuras', frame.RaisedElementParent)
end

function GW.UpdatePrivateAurasSettings(frame)
    if not GW.Retail then return end

    frame.PrivateAuras:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 5)
    frame.PrivateAuras:ClearAllPoints()
    frame.PrivateAuras:SetPoint("CENTER", frame)
    frame.PrivateAuras:SetSize(frame:GetSize())
    frame.disableCooldown = false
    frame.disableCooldownText = false
    frame.size = 15
end
