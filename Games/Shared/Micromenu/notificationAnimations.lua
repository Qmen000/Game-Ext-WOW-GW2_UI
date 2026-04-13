---@class GW2
local GW = select(2, ...)

local DEFAULT_ICON_ANIM = {
    point = {"CENTER", "CENTER", 0, 0},
    size = 30,
    blendMode = "ADD",
    vertexColor = {1, 0.84, 0.5, 1},
    fadeInDuration = 0.28,
    fadeOutDuration = 0.20,
    fromAlpha = 0,
    toAlpha = 0.62,
    scaleFrom = 0.94,
    scaleTo = 1.08,
}

local function ResolveAnimationConfig(config)
    config = config or {}
    return {
        point = config.point or DEFAULT_ICON_ANIM.point,
        size = config.size or DEFAULT_ICON_ANIM.size,
        blendMode = config.blendMode or DEFAULT_ICON_ANIM.blendMode,
        vertexColor = config.vertexColor or DEFAULT_ICON_ANIM.vertexColor,
        fadeInDuration = config.fadeInDuration or DEFAULT_ICON_ANIM.fadeInDuration,
        fadeOutDuration = config.fadeOutDuration or DEFAULT_ICON_ANIM.fadeOutDuration,
        fromAlpha = config.fromAlpha ~= nil and config.fromAlpha or DEFAULT_ICON_ANIM.fromAlpha,
        toAlpha = config.toAlpha or DEFAULT_ICON_ANIM.toAlpha,
        scaleFrom = config.scaleFrom or DEFAULT_ICON_ANIM.scaleFrom,
        scaleTo = config.scaleTo or DEFAULT_ICON_ANIM.scaleTo,
        texture = config.texture,
        onFinished = config.onFinished,
    }
end

function GW.EnsureIconNotificationAnimation(frame, config)
    if not frame then
        return nil, nil
    end

    local resolved = ResolveAnimationConfig(config)
    local tex = frame.GwIconNotificationPulse
    if not tex then
        tex = frame:CreateTexture(nil, "OVERLAY")
        frame.GwIconNotificationPulse = tex
    end

    tex:ClearAllPoints()
    tex:SetPoint(resolved.point[1], frame, resolved.point[2], resolved.point[3], resolved.point[4])
    tex:SetSize(resolved.size, resolved.size)
    tex:SetBlendMode(resolved.blendMode)
    tex:SetVertexColor(unpack(resolved.vertexColor))
    tex:SetTexture(resolved.texture or (frame.GetNormalTexture and frame:GetNormalTexture() and frame:GetNormalTexture():GetTexture()) or "")
    tex:SetAlpha(0)

    local anim = frame.GwIconNotificationPulseAnim
    if not anim then
        anim = tex:CreateAnimationGroup()
        frame.GwIconNotificationPulseAnim = anim
        frame.GwIconNotificationPulseScaleIn = anim:CreateAnimation("Scale")
        frame.GwIconNotificationPulseAlphaIn = anim:CreateAnimation("Alpha")
        frame.GwIconNotificationPulseScaleOut = anim:CreateAnimation("Scale")
        frame.GwIconNotificationPulseAlphaOut = anim:CreateAnimation("Alpha")
    end

    local scaleIn = frame.GwIconNotificationPulseScaleIn
    scaleIn:SetOrder(1)
    scaleIn:SetDuration(resolved.fadeInDuration)
    scaleIn:SetSmoothing("OUT")
    scaleIn:SetScaleFrom(resolved.scaleFrom, resolved.scaleFrom)
    scaleIn:SetScaleTo(resolved.scaleTo, resolved.scaleTo)
    scaleIn:SetOrigin("CENTER", 0, 0)

    local alphaIn = frame.GwIconNotificationPulseAlphaIn
    alphaIn:SetOrder(1)
    alphaIn:SetDuration(resolved.fadeInDuration)
    alphaIn:SetSmoothing("OUT")
    alphaIn:SetFromAlpha(resolved.fromAlpha)
    alphaIn:SetToAlpha(resolved.toAlpha)

    local scaleOut = frame.GwIconNotificationPulseScaleOut
    scaleOut:SetOrder(2)
    scaleOut:SetDuration(resolved.fadeOutDuration)
    scaleOut:SetSmoothing("IN")
    scaleOut:SetScaleFrom(resolved.scaleTo, resolved.scaleTo)
    scaleOut:SetScaleTo(1, 1)
    scaleOut:SetOrigin("CENTER", 0, 0)

    local alphaOut = frame.GwIconNotificationPulseAlphaOut
    alphaOut:SetOrder(2)
    alphaOut:SetDuration(resolved.fadeOutDuration)
    alphaOut:SetSmoothing("IN")
    alphaOut:SetFromAlpha(resolved.toAlpha)
    alphaOut:SetToAlpha(0)

    anim:SetScript("OnFinished", function()
        tex:Hide()
        tex:SetAlpha(0)
        tex:SetScale(1)
        if resolved.onFinished then
            resolved.onFinished(frame, tex)
        end
    end)

    return tex, anim
end

function GW.StopIconNotificationAnimation(frame)
    if not frame then
        return
    end
    if frame.GwIconNotificationPulseAnim then
        frame.GwIconNotificationPulseAnim:Stop()
    end
    if frame.GwIconNotificationPulse then
        frame.GwIconNotificationPulse:Hide()
        frame.GwIconNotificationPulse:SetAlpha(0)
        frame.GwIconNotificationPulse:SetScale(1)
    end
end

function GW.PlayIconNotificationAnimation(frame, config)
    local tex, anim = GW.EnsureIconNotificationAnimation(frame, config)
    if not tex or not anim then
        return
    end

    tex:Show()
    anim:Stop()
    anim:Play()
end
