-- Animation System
-- src/utils/animations.lua

local TweenService = game:GetService("TweenService")

local Animations = {}

function Animations.CreateTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function Animations.FadeIn(object, duration)
    object.BackgroundTransparency = 1
    return Animations.CreateTween(object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
end

function Animations.SlideIn(object, duration)
    local originalPos = object.Position
    object.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, -1, 0)
    return Animations.CreateTween(object,
        TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = originalPos}
    )
end

function Animations.ScaleIn(object, duration)
    local originalSize = object.Size
    object.Size = UDim2.new(0, 0, 0, 0)
    return Animations.CreateTween(object,
        TweenInfo.new(duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = originalSize}
    )
end

return Animations
