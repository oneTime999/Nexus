-- GUI.lua - Sistema de Interface Gráfica

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

-- Função para criar toggle
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

-- Função para criar GUI principal
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

    -- Carregar componentes
    GUI.createHeader(mainFrame)
    GUI.createContainer(mainFrame)
    GUI.createStatusBar(mainFrame)
    GUI.animateOpening(mainFrame)
end

-- Continua no próximo arquivo devido ao tamanho...

return GUI
