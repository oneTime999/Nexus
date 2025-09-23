-- Notification System
-- src/utils/notifications.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- We need to get the theme, but we'll use a fallback to avoid circular dependencies
local function getCurrentTheme()
    -- Fallback theme if Settings module isn't available
    local fallbackTheme = {
        Secondary = Color3.fromRGB(28, 28, 42),
        Success = Color3.fromRGB(46, 204, 113),
        Danger = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15),
        Accent = Color3.fromRGB(88, 166, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200)
    }
    
    -- Try to get actual theme from Settings if available
    local success, Settings = pcall(require, script.Parent.Parent.core.settings)
    if success and Settings.GetCurrentTheme then
        return Settings.GetCurrentTheme()
    else
        return fallbackTheme
    end
end

local function createTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

local NotificationSystem = {}

function NotificationSystem.Create(title, message, type, duration)
    local CurrentTheme = getCurrentTheme()
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "NexusNotification"
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
    notifGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 90)
    frame.Position = UDim2.new(1, -20, 0, 100)
    frame.BackgroundColor3 = CurrentTheme.Secondary
    frame.BorderSizePixel = 0
    frame.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = type == "success" and CurrentTheme.Success or
                   type == "error" and CurrentTheme.Danger or
                   type == "warning" and CurrentTheme.Warning or
                   CurrentTheme.Accent
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = CurrentTheme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 45)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = CurrentTheme.TextSecondary
    messageLabel.TextSize = 13
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame

    createTween(frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -370, 0, 100)}
    )

    game:GetService("Debris"):AddItem(notifGui, duration or 4)

    spawn(function()
        wait(duration or 3.5)
        if notifGui and notifGui.Parent then
            createTween(frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 20, 0, 100)}
            )
        end
    end)
end

return NotificationSystem
