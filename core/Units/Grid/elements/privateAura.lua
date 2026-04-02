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
    frame.PrivateAuras:SetPoint("LEFT", frame, "LEFT", 2, 0)
    frame.PrivateAuras:SetSize(frame:GetSize())
    frame.PrivateAuras.disableCooldown = false
    frame.PrivateAuras.disableCooldownText = true
    frame.PrivateAuras.initialAnchor = "BOTTOMLEFT"
    frame.PrivateAuras.borderScale = 1
    frame.PrivateAuras.size = 12

    if frame.showPrivateAuras then
        frame:EnableElement("PrivateAuras")
    else
        frame:DisableElement("PrivateAuras")
    end
end
