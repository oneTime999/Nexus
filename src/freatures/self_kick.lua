-- Self Kick Feature
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Parent.utils.utils)
local Settings = require(script.Parent.Parent.core.settings)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentTheme = Settings.GetCurrentTheme()

local SelfKick = {}

function SelfKick.Execute()
    Utils.SafeCall(function()
        local kickTime = os.date("%d/%m/%Y às %H:%M:%S")
        local jobId = game.JobId or "N/A"

        local kickMessage = string.format(
            "NEXUS SELF-KICK\nHorário: %s (Brasília)\nJobID: %s\nObrigado por usar o Nexus!",
            kickTime,
            jobId
        )

        LocalPlayer:Kick(kickMessage)
    end)
end

function SelfKick.CreateKickButton()
    local kickGui = Instance.new("ScreenGui")
    kickGui.Name = "NexusKickButton"
    kickGui.ResetOnSpawn = false
    kickGui.IgnoreGuiInset = true
    kickGui.Parent = PlayerGui

    local kickFrame = Instance.new("Frame")
    kickFrame.Size = UDim2.new(0, 280, 0, 85)
    kickFrame.Position = UDim2.new(0, 40, 1, -125)
    kickFrame.BackgroundColor3 = CurrentTheme.Background
    kickFrame.BackgroundTransparency = 0.1
    kickFrame.BorderSizePixel = 0
    kickFrame.Active = true
    kickFrame.Draggable = true
    kickFrame.Parent = kickGui

    local kickCorner = Instance.new("UICorner")
    kickCorner.CornerRadius = UDim.new(0, 16)
    kickCorner.Parent = kickFrame

    local gradientFrame = Instance.new("Frame")
    gradientFrame.Size = UDim2.new(1, 0, 1, 0)
    gradientFrame.Position = UDim2.new(0, 0, 0, 0)
    gradientFrame.BackgroundTransparency = 1
    gradientFrame.BorderSizePixel = 0
    gradientFrame.Parent = kickFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, CurrentTheme.Danger),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 40, 40))
    }
    gradient.Rotation = 45
    gradient.Parent = gradientFrame

    local gradientCorner = Instance.new("UICorner")
    gradientCorner.CornerRadius = UDim.new(0, 16)
    gradientCorner.Parent = gradientFrame

    local strokeBorder = Instance.new("UIStroke")
    strokeBorder.Thickness = 2
    strokeBorder.Color = CurrentTheme.Danger
    strokeBorder.Transparency = 0.3
    strokeBorder.Parent = kickFrame

    local warningIcon = Instance.new("TextLabel")
    warningIcon.Size = UDim2.new(0, 35, 0, 35)
    warningIcon.Position = UDim2.new(0, 15, 0.5, -17.5)
    warningIcon.BackgroundTransparency = 1
    warningIcon.Text = "⚠"
    warningIcon.TextScaled = true
    warningIcon.Font = Enum.Font.GothamBold
    warningIcon.Parent = kickFrame

    local kickTitle = Instance.new("TextLabel")
    kickTitle.Size = UDim2.new(0, 120, 0, 22)
    kickTitle.Position = UDim2.new(0, 60, 0, 15)
    kickTitle.BackgroundTransparency = 1
    kickTitle.Text = "Kick Button"
    kickTitle.TextColor3 = CurrentTheme.Text
    kickTitle.TextSize = 14
    kickTitle.Font = Enum.Font.GothamBold
    kickTitle.TextXAlignment = Enum.TextXAlignment.Left
    kickTitle.Parent = kickFrame

    local kickDesc = Instance.new("TextLabel")
    kickDesc.Size = UDim2.new(0, 120, 0, 16)
    kickDesc.Position = UDim2.new(0, 60, 0, 38)
    kickDesc.BackgroundTransparency = 1
    kickDesc.Text = "Leave server safely"
    kickDesc.TextColor3 = CurrentTheme.TextSecondary
    kickDesc.TextSize = 11
    kickDesc.Font = Enum.Font.Gotham
    kickDesc.TextXAlignment = Enum.TextXAlignment.Left
    kickDesc.Parent = kickFrame

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0, 80, 0, 50)
    buttonContainer.Position = UDim2.new(1, -95, 0.5, -25)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = kickFrame

    local kickBtn = Instance.new("TextButton")
    kickBtn.Size = UDim2.new(0, 50, 0, 50)
    kickBtn.Position = UDim2.new(0, 15, 0, 0)
    kickBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    kickBtn.BorderSizePixel = 0
    kickBtn.Text = "Kick"
    kickBtn.TextColor3 = CurrentTheme.Text
    kickBtn.TextSize = 12
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.Parent = buttonContainer

    local kickBtnCorner = Instance.new("UICorner")
    kickBtnCorner.CornerRadius = UDim.new(0, 12)
    kickBtnCorner.Parent = kickBtn

    local kickBtnStroke = Instance.new("UIStroke")
    kickBtnStroke.Thickness = 2
    kickBtnStroke.Color = Color3.fromRGB(255, 80, 80)
    kickBtnStroke.Transparency = 0.2
    kickBtnStroke.Parent = kickBtn

    local pulseConnection
    local isHovering = false

    kickBtn.MouseEnter:Connect(function()
        isHovering = true
        Utils.CreateTween(kickBtn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}
        )
        Utils.CreateTween(kickBtnStroke,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {Transparency = 0}
        )

        pulseConnection = RunService.Heartbeat:Connect(function()
            if isHovering then
                local time = tick() * 3
                local pulse = (math.sin(time) + 1) / 2
                kickBtnStroke.Transparency = 0.3 * pulse
            end
        end)
    end)

    kickBtn.MouseLeave:Connect(function()
        isHovering = false
        if pulseConnection then
            pulseConnection:Disconnect()
        end
        Utils.CreateTween(kickBtn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}
        )
        Utils.CreateTween(kickBtnStroke,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {Transparency = 0.2}
        )
    end)

    kickBtn.MouseButton1Click:Connect(function()
        Utils.CreateTween(kickBtn,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 45, 0, 45)}
        )

        spawn(function()
            wait(0.1)
            Utils.CreateTween(kickBtn,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                {Size = UDim2.new(0, 50, 0, 50)}
            )
            wait(0.1)
            SelfKick.Execute()
        end)
    end)

    local closeKick = Instance.new("TextButton")
    closeKick.Size = UDim2.new(0, 20, 0, 20)
    closeKick.Position = UDim2.new(1, -25, 0, 5)
    closeKick.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeKick.BorderSizePixel = 0
    closeKick.Text = "×"
    closeKick.TextColor3 = CurrentTheme.Text
    closeKick.TextSize = 14
    closeKick.Font = Enum.Font.GothamBold
    closeKick.Parent = kickFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeKick

    closeKick.MouseEnter:Connect(function()
        Utils.CreateTween(closeKick,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(120, 120, 140)}
        )
    end)

    closeKick.MouseLeave:Connect(function()
        Utils.CreateTween(closeKick,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}
        )
    end)

    closeKick.MouseButton1Click:Connect(function()
        if pulseConnection then
            pulseConnection:Disconnect()
        end
        Utils.CreateTween(kickFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0, 40, 1, 20)}
        )
        spawn(function()
            wait(0.3)
            kickGui:Destroy()
        end)
    end)

    local Animations = require(script.Parent.Parent.utils.animations)
    Animations.SlideIn(kickFrame, 0.4)

    return kickGui
end

return SelfKick
