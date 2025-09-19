-- GUI.lua - Módulo para criação da interface gráfica
-- Responsável por criar e gerenciar todos os elementos visuais

local Services = require(script.Parent.Services)
local GUI = {}

-- Cores padrão do tema
local Colors = {
    Background = Color3.fromRGB(20, 20, 32),
    BackgroundGradient1 = Color3.fromRGB(25, 25, 42),
    BackgroundGradient2 = Color3.fromRGB(18, 18, 30),
    Header = Color3.fromRGB(28, 28, 45),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(60, 180, 60),
    Error = Color3.fromRGB(180, 60, 60),
    Warning = Color3.fromRGB(255, 180, 60),
    Close = Color3.fromRGB(255, 85, 85)
}

-- Criar GUI principal
function GUI.createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernCustomGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Services.playerGui

    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 270)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 18)
    mainCorner.Parent = mainFrame

    -- Gradiente principal
    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Colors.BackgroundGradient1),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1.0, Colors.BackgroundGradient2)
    }
    mainGradient.Rotation = 135
    mainGradient.Parent = mainFrame

    -- Borda
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 2.5
    mainStroke.Color = Colors.Accent
    mainStroke.Parent = mainFrame

    -- Criar header
    GUI.createHeader(mainFrame)
    
    -- Container dos toggles
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -25, 1, -80)
    container.Position = UDim2.new(0, 12.5, 0, 68)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    -- Status bar
    GUI.createStatusBar(mainFrame)

    -- Animação de abertura
    GUI.animateOpen(mainFrame)

    return screenGui
end

-- Criar header da GUI
function GUI.createHeader(parent)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 55)
    headerFrame.BackgroundColor3 = Colors.Header
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = parent

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 18)
    headerCorner.Parent = headerFrame

    -- Gradiente do header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 35, 60)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(25, 25, 40))
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = headerFrame

    -- Linha separadora
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -30, 0, 2)
    separator.Position = UDim2.new(0, 15, 1, -2)
    separator.BackgroundColor3 = Colors.Accent
    separator.BorderSizePixel = 0
    separator.Parent = headerFrame

    local separatorCorner = Instance.new("UICorner")
    separatorCorner.CornerRadius = UDim.new(1, 0)
    separatorCorner.Parent = separator

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
    titleLabel.TextColor3 = Colors.Text
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
    subtitleLabel.TextColor3 = Colors.TextSecondary
    subtitleLabel.TextSize = 12
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = headerFrame

    -- Botões de controle
    GUI.createControlButtons(headerFrame)
end

-- Criar botões de controle (minimizar/fechar)
function GUI.createControlButtons(parent)
    -- Botão minimizar
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 26, 0, 26)
    minimizeButton.Position = UDim2.new(1, -70, 0.5, -13)
    minimizeButton.BackgroundColor3 = Colors.Warning
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = parent

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(1, 0)
    minimizeCorner.Parent = minimizeButton

    -- Botão fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 26, 0, 26)
    closeButton.Position = UDim2.new(1, -38, 0.5, -13)
    closeButton.BackgroundColor3 = Colors.Close
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Colors.Text
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = parent
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
end

-- Criar status bar
function GUI.createStatusBar(parent)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 22)
    statusBar.Position = UDim2.new(0, 0, 1, -22)
    statusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = parent

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 11)
    statusCorner.Parent = statusBar

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
end

-- Criar toggle
function GUI.createToggle(parent, name, description, yPos, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 65)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame

    -- Gradiente do toggle
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(25, 25, 40))
    }
    toggleGradient.Rotation = 45
    toggleGradient.Parent = toggleFrame

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(60, 60, 85)
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggleFrame

    -- Label do toggle
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -110, 0, 25)
    toggleLabel.Position = UDim2.new(0, 15, 0, 10)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Colors.Text
    toggleLabel.TextSize = 16
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame

    -- Descrição do toggle
    local toggleDescription = Instance.new("TextLabel")
    toggleDescription.Size = UDim2.new(1, -110, 0, 20)
    toggleDescription.Position = UDim2.new(0, 15, 0, 35)
    toggleDescription.BackgroundTransparency = 1
    toggleDescription.Text = description
    toggleDescription.TextColor3 = Colors.TextSecondary
    toggleDescription.TextSize = 12
    toggleDescription.Font = Enum.Font.Gotham
    toggleDescription.TextXAlignment = Enum.TextXAlignment.Left
    toggleDescription.Parent = toggleFrame

    -- Botão do toggle
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 65, 0, 28)
    toggleButton.Position = UDim2.new(1, -78, 0.5, -14)
    toggleButton.BackgroundColor3 = Colors.Error
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Colors.Text
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = toggleFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 14)
    buttonCorner.Parent = toggleButton

    -- Evento do toggle
    toggleButton.MouseButton1Click:Connect(function()
        callback(toggleButton)
    end)

    return toggleButton
end

-- Animar toggle
function GUI.animateToggle(button, state)
    local targetColor = state and Colors.Success or Colors.Error
    local colorTween = Services.TweenService:Create(button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = targetColor}
    )
    colorTween:Play()
    
    button.Text = state and "ON" or "OFF"
end

-- Configurar controles da janela
function GUI.setupWindowControls(screenGui, closeCallback)
    local mainFrame = screenGui.MainFrame
    local header = mainFrame.Header
    local container = mainFrame.Container
    
    local minimizeButton = header.MinimizeButton
    local closeButton = header.CloseButton
    
    local isMinimized = false
    
    -- Sistema de minimizar
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        local targetSize = isMinimized and UDim2.new(0, 400, 0, 55) or UDim2.new(0, 400, 0, 270)
        local tween = Services.TweenService:Create(mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = targetSize}
        )
        tween:Play()
        
        container.Visible = not isMinimized
        minimizeButton.Text = isMinimized and "+" or "−"
    end)
    
    -- Sistema de fechar
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = Services.TweenService:Create(mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        closeTween:Play()
        
        closeTween.Completed:Connect(function()
            closeCallback()
            screenGui:Destroy()
        end)
    end)
end

-- Animação de abertura
function GUI.animateOpen(frame)
    frame.Size = UDim2.new(0, 0, 0, 0)
    local openTween = Services.TweenService:Create(frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 400, 0, 270)}
    )
    openTween:Play()
end

return GUI
