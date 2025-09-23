-- GUI Components
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Utils = require(script.Parent.Parent.utils.utils)
local Settings = require(script.Parent.Parent.core.settings)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentTheme = Settings.GetCurrentTheme()

local GUI = {}

function GUI.CreateFeatureCard(parent, name, description, icon, yPos, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -20, 0, 65)
    card.Position = UDim2.new(0, 10, 0, yPos)
    card.BackgroundColor3 = CurrentTheme.Secondary
    card.BackgroundTransparency = 0.75
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = CurrentTheme.Border
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.6
    cardStroke.Parent = card

    local featureIcon = Instance.new("TextLabel")
    featureIcon.Size = UDim2.new(0, 30, 0, 30)
    featureIcon.Position = UDim2.new(0, 10, 0, 17.5)
    featureIcon.BackgroundTransparency = 1
    featureIcon.Text = icon
    featureIcon.TextColor3 = CurrentTheme.Accent
    featureIcon.TextScaled = true
    featureIcon.Font = Enum.Font.GothamBold
    featureIcon.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 180, 0, 20)
    nameLabel.Position = UDim2.new(0, 50, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = CurrentTheme.Text
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0, 180, 0, 18)
    descLabel.Position = UDim2.new(0, 50, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = CurrentTheme.TextSecondary
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 45, 0, 22)
    toggleFrame.Position = UDim2.new(1, -55, 0.5, -11)
    toggleFrame.BackgroundColor3 = CurrentTheme.Tertiary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = card

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleFrame

    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 18, 0, 18)
    toggleButton.Position = UDim2.new(0, 2, 0.5, -9)
    toggleButton.BackgroundColor3 = CurrentTheme.Text
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame

    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(1, 0)
    toggleBtnCorner.Parent = toggleButton

    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = card

    local isEnabled = false

    clickButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled

        local frameColor = isEnabled and CurrentTheme.Success or CurrentTheme.Tertiary
        local buttonPos = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)

        Utils.CreateTween(toggleFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = frameColor}
        )

        Utils.CreateTween(toggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {Position = buttonPos}
        )

        Utils.CreateTween(cardStroke,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {Color = isEnabled and CurrentTheme.Success or CurrentTheme.Border}
        )

        callback(isEnabled)
    end)

    return card
end

function GUI.CreateStatusBar(parent)
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 1, -30)
    statusBar.BackgroundColor3 = CurrentTheme.Tertiary
    statusBar.BackgroundTransparency = 0.75
    statusBar.BorderSizePixel = 0
    statusBar.Parent = parent

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 16)
    statusCorner.Parent = statusBar

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0.6, 0, 1, 0)
    statusText.Position = UDim2.new(0, 15, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Nexus 1.1 Premium"
    statusText.TextColor3 = CurrentTheme.Accent
    statusText.TextSize = 10
    statusText.Font = Enum.Font.GothamBold
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar

    local playerCount = Instance.new("TextLabel")
    playerCount.Size = UDim2.new(0.4, -15, 1, 0)
    playerCount.Position = UDim2.new(0.6, 0, 0, 0)
    playerCount.BackgroundTransparency = 1
    playerCount.Text = "Players: " .. #Players:GetPlayers()
    playerCount.TextColor3 = CurrentTheme.TextSecondary
    playerCount.TextSize = 10
    playerCount.Font = Enum.Font.Gotham
    playerCount.TextXAlignment = Enum.TextXAlignment.Right
    playerCount.Parent = statusBar

    Players.PlayerAdded:Connect(function()
        playerCount.Text = "Players: " .. #Players:GetPlayers()
    end)

    Players.PlayerRemoving:Connect(function()
        wait()
        playerCount.Text = "Players: " .. #Players:GetPlayers()
    end)

    return statusBar
end

function GUI.CreateHeaderButtons(header)
    local buttonSize = UDim2.new(0, 25, 0, 25)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = buttonSize
    closeBtn.Position = UDim2.new(1, -30, 0, 17.5)
    closeBtn.BackgroundColor3 = CurrentTheme.Danger
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = CurrentTheme.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = buttonSize
    minimizeBtn.Position = UDim2.new(1, -60, 0, 17.5)
    minimizeBtn.BackgroundColor3 = CurrentTheme.Warning
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 12
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minimizeBtn

    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = buttonSize
    settingsBtn.Position = UDim2.new(1, -90, 0, 17.5)
    settingsBtn.BackgroundColor3 = CurrentTheme.Accent
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = CurrentTheme.Text
    settingsBtn.TextSize = 12
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.Parent = header

    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(1, 0)
    setCorner.Parent = settingsBtn

    return minimizeBtn, settingsBtn, closeBtn
end

return GUI
