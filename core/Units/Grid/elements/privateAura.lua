---@class GW2
local GW = select(2, ...)

function GW.Construct_PrivateAura(frame)
    if not GW.Retail then return end
    return CreateFrame('Frame', '$parentPrivateAuras', frame.RaisedElementParent)
end

function GW.UpdatePrivateAurasSettings(frame)
    if not GW.Retail then return end

    frame.PrivateAuras:SetFrameLevel(frame.RaisedElementParent.PrivateAurasLevel)
    frame.PrivateAuras:ClearAllPoints()
    frame.PrivateAuras:SetPoint("CENTER", frame)
    frame.PrivateAuras:SetSize(frame:GetSize())
    frame.PrivateAuras.disableCooldown = false
    frame.PrivateAuras.disableCooldownText = false
    frame.PrivateAuras.initialAnchor = "CENTER"
    frame.PrivateAuras.borderScale = 1
    frame.PrivateAuras.size = 15
end
