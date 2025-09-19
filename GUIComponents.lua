-- GUIComponents.lua - Componentes específicos da GUI

local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)
local KickSystem = require(script.Parent.KickSystem)
local KickGUI = require(script.Parent.KickGUI)

local TweenService = Services.TweenService

local GUIComponents = {}

-- Variáveis de estado
local toggle1State = false
local toggle2State = false
local isMinimized = false

-- Função para criar header
function GUIComponents.createHeader(mainFrame)
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

    -- Ícone do título
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Size = UDim2.new(0, 35, 0, 35)
    titleIcon.Position = UDim2.new(0, 18, 0.5, -17.5)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "⚡"
    titleIcon.TextColor3 = Color3.fromRGB(120, 180, 255)
    titleIcon.TextScaled = true
    titleIcon.Font = Enum.Font.GothamBold
    titleIcon.Parent = headerFrame

    -- Título
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

    -- Subtítulo
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
    GUIComponents.createControlButtons(headerFrame, mainFrame)
    
    return headerFrame
end

-- Função para criar botões de controle
function GUIComponents.createControlButtons(headerFrame, mainFrame)
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

    -- Eventos dos botões
    GUIComponents.setupControlEvents(minimizeButton, closeMainButton, mainFrame)
end

-- Função para configurar eventos dos botões
function GUIComponents.setupControlEvents(minimizeButton, closeMainButton, mainFrame)
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
        GUIComponents.closeMainGUI(mainFrame)
    end)
end

-- Função para fechar GUI principal
function GUIComponents.closeMainGUI(mainFrame)
    local closeTween = TweenService:Create(mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}
    )
    closeTween:Play()
    
    closeTween.Completed:Connect(function()
        KickGUI.removeKickMeGUI()
        KickSystem.disconnectClickSystem()
        
        if mainFrame.Parent then
            mainFrame.Parent:Destroy()
        end
    end)
end

return GUIComponents
