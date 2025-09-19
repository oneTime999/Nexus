-- KickSystem.lua - Módulo para sistema de kick/saída do jogo
-- Responsável por criar e gerenciar a interface de kick

local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)
local KickSystem = {}

-- Criar GUI do sistema de kick
function KickSystem.createKickGUI()
    local kickScreenGui = Instance.new("ScreenGui")
    kickScreenGui.Name = "KickExecutorUI"
    kickScreenGui.ResetOnSpawn = false
    kickScreenGui.Parent = Services.playerGui

    -- Frame principal do botão kick
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainButton"
    mainFrame.Size = UDim2.new(0, 180, 0, 55)
    mainFrame.Position = UDim2.new(0, 50, 0, 200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = kickScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = mainFrame

    -- Gradiente
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(20, 20, 35))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    -- Borda
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 140, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- Texto do botão
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, -50, 1, 0)
    buttonText.Position = UDim2.new(0, 12, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = "⚡ Kick Me"
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextScaled = true
    buttonText.Font = Enum.Font.GothamBold
    buttonText.Parent = mainFrame

    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -38, 0.5, -16)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton

    -- Botão invisível para capturar cliques
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, -42, 1, 0)
    clickButton.Position = UDim2.new(0, 0, 0, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = mainFrame

    -- Eventos
    clickButton.MouseButton1Click:Connect(function()
        KickSystem.kickPlayer()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        kickScreenGui:Destroy()
    end)

    -- Animação de aparição
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local appearTween = Services.TweenService:Create(mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 180, 0, 55)}
    )
    appearTween:Play()

    return kickScreenGui
end

-- Função para kickar o player (sair do jogo)
function KickSystem.kickPlayer()
    pcall(function()
        local kickTime = Utils.getCurrentTimeString()
        local jobId = Utils.getJobId()
        
        local kickMessage = string.format(
            "Horário: %s (Brasília)\nJobID: %s",
            kickTime,
            jobId
        )
        
        Services.LocalPlayer:Kick(kickMessage)
    end)
end

-- Remover GUI do kick
function KickSystem.removeKickGUI(kickScreenGui)
    if kickScreenGui then
        kickScreenGui:Destroy()
    end
end

return KickSystem
