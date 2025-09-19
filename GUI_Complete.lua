-- GUI_Complete.lua - Sistema completo da interface gráfica

local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)
local KickSystem = require(script.Parent.KickSystem)
local KickGUI = require(script.Parent.KickGUI)

local TweenService = Services.TweenService
local LocalPlayer = Services.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI = {}

-- Variáveis de estado
local mainScreenGui = nil
local toggle1State = false
local toggle2State = false
local isMinimized = false

-- Função para criar toggle estável
local function createStableToggle(container, name, description, yPos, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 65)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = container

    Utils.createCorner(toggleFrame, 12)
    
    Utils.createGradient(toggleFrame, ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(25, 25, 40))
    }, 45)

    Utils.createStroke(toggleFrame, Color3.fromRGB(60, 60, 85), 1)

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -110, 0, 25)
    toggleLabel.Position = UDim2.new(0, 15, 0, 10)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 16
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame

    local toggleDescription = Instance.new("TextLabel")
    toggleDescription.Size = UDim2.new(1, -110, 0, 20)
    toggleDescription.Position = UDim2.new(0, 15, 0, 35)
    toggleDescription.BackgroundTransparency = 1
    toggleDescription.Text = description
    toggleDescription.TextColor3 = Color3.fromRGB(180, 180, 200)
    toggleDescription.TextSize = 12
    toggleDescription.Font = Enum.Font.Gotham
    toggleDescription.TextXAlignment = Enum.TextXAlignment.Left
    toggleDescription.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 65, 0, 28)
    toggleButton.Position = UDim2.new(1, -78, 0.5, -14)
    toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame

    Utils.createCorner(toggleButton, 14)

    toggleButton.MouseButton1Click:Connect(function()
        callback(toggleButton)
    end)

    return toggleButton
end

-- Função para criar header
function GUI.createHeader(mainFrame)
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 55)
    headerFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame

    Utils.createCorner(headerFrame, 18)
    
    Utils.createGradient(headerFrame, ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 35, 60)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(25, 25, 40))
    }, 90)

    -- Linha separadora
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -30, 0, 2)
    separator.Position = UDim2.new(0, 15, 1, -2)
    separator.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    separator.BorderSizePixel = 0
    separator.Parent = headerFrame
    Utils.createCorner(separator, 999)

    -- Elementos do header
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Size = UDim2.new(0, 35, 0, 35)
    titleIcon.Position = UDim2.new(0, 18, 0.5, -17.5)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "⚡"
    titleIcon.TextColor3 = Color3.fromRGB(120, 180, 255)
    titleIcon.TextScaled = true
    titleIcon.Font = Enum.Font.GothamBold
    titleIcon.Parent = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -140, 0, 25)
    titleLabel.Position = UDim2.new(0, 60, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "NEXUS 1.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -140, 0, 15)
    subtitleLabel.Position = UDim2.new(0, 60, 0, 32)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Feito por do_one99"
    subtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    subtitleLabel.TextSize = 12
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = headerFrame

    -- Botões de controle
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 26, 0, 26)
    minimizeButton.Position = UDim2.new(1, -70, 0.5, -13)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = headerFrame
    Utils.createCorner(minimizeButton, 999)

    local closeMainButton = Instance.new("TextButton")
    closeMainButton.Size = UDim2.new(0, 26, 0, 26)
    closeMainButton.Position = UDim2.new(1, -38, 0.5, -13)
    closeMainButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeMainButton.BorderSizePixel = 0
    closeMainButton.Text = "×"
    closeMainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeMainButton.TextScaled = true
    closeMainButton.Font = Enum.Font.GothamBold
    closeMainButton.Parent = headerFrame
    Utils.createCorner(closeMainButton, 999)

    return minimizeButton, closeMainButton
end

-- Função para criar container de toggles
function GUI.createContainer(mainFrame)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -25, 1, -80)
    container.Position = UDim2.new(0, 12.5, 0, 68)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    -- Toggle 1: Kick Button
    local toggle1Button = createStableToggle(container, "Kick Button", "Exibe interface para self-kick", 15, function(button)
        toggle1State = not toggle1State
        
        local targetColor = toggle1State and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
        local colorTween = TweenService:Create(button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        )
        colorTween:Play()
        
        button.Text = toggle1State and "ON" or "OFF"
        
        if toggle1State then
            KickGUI.createKickMeGUI()
        else
            KickGUI.removeKickMeGUI()
        end
    end)

    -- Toggle 2: Aimbot
    local toggle2Button = createStableToggle(container, "Aimbot", "Sistema de mira automática", 90, function(button)
        toggle2State = not toggle2State
        _G.KickPlayerEnabled = toggle2State
        
        local targetColor = toggle2State and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
        local colorTween = TweenService:Create(button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        )
        colorTween:Play()
        
        button.Text = toggle2State and "ON" or "OFF"
        
        if toggle2State then
            KickSystem.setupClickSystem()
        else
            KickSystem.disconnectClickSystem()
        end
    end)

    return container
end

-- Função para criar status bar
function GUI.createStatusBar(mainFrame)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 22)
    statusBar.Position = UDim2.new(0, 0, 1, -22)
    statusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = mainFrame

    Utils.createCorner(statusBar, 11)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Nexus 1.0 • Feito por do_one99"
    statusText.TextColor3 = Color3.fromRGB(120, 180, 255)
    statusText.TextSize = 10
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar

    return statusBar
end

-- Função para animar abertura
function GUI.animateOpening(mainFrame)
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local openTween = TweenService:Create(mainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 400, 0, 270)}
    )
    openTween:Play()
end

-- Função para configurar eventos de controle
function GUI.setupControlEvents(minimizeButton, closeMainButton, mainFrame)
    -- Sistema de minimizar
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        local targetSize = isMinimized and UDim2.new(0, 400, 0, 55) or UDim2.new(0, 400, 0, 270)
        local tween = TweenService:Create(mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = targetSize}
        )
        tween:Play()
        
        local container = mainFrame:FindFirstChild("Container")
        if container then
            container.Visible = not isMinimized
        end
        minimizeButton.Text = isMinimized and "+" or "-"
    end)

    -- Fechar GUI principal
    closeMainButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        closeTween:Play()
        
        closeTween.Completed:Connect(function()
            KickGUI.removeKickMeGUI()
            KickSystem.disconnectClickSystem()
            
            if mainScreenGui then
                mainScreenGui:Destroy()
                mainScreenGui = nil
            end
        end)
    end)
end

-- Função principal para criar GUI
function GUI.createMainGUI()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "ModernCustomGUI"
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.Parent = playerGui

    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 270)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = mainScreenGui

    Utils.createCorner(mainFrame, 18)
    
    Utils.createGradient(mainFrame, ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(25, 25, 42)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(18, 18, 30))
    }, 135)

    Utils.createStroke(mainFrame, Color3.fromRGB(100, 150, 255), 2.5)

    -- Criar componentes
    local minimizeButton, closeMainButton = GUI.createHeader(mainFrame)
    GUI.createContainer(mainFrame)
    GUI.createStatusBar(mainFrame)
    
    -- Configurar eventos
    GUI.setupControlEvents(minimizeButton, closeMainButton, mainFrame)
    
    -- Animar abertura
    GUI.animateOpening(mainFrame)
end

return GUI
