-- KickGUI.lua - Interface do Sistema de Kick

local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)
local KickSystem = require(script.Parent.KickSystem)

local TweenService = Services.TweenService
local LocalPlayer = Services.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local KickGUI = {}

-- Variável de controle
local kickScreenGui = nil

-- Função para criar GUI do Kick Me
function KickGUI.createKickMeGUI()
    if kickScreenGui then return end
    
    kickScreenGui = Instance.new("ScreenGui")
    kickScreenGui.Name = "KickExecutorUI"
    kickScreenGui.ResetOnSpawn = false
    kickScreenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainButton"
    mainFrame.Size = UDim2.new(0, 180, 0, 55)
    mainFrame.Position = UDim2.new(0, 50, 0, 200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = kickScreenGui

    Utils.createCorner(mainFrame, 18)

    -- Gradiente estático
    Utils.createGradient(mainFrame, ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(20, 20, 35))
    }, 45)

    Utils.createStroke(mainFrame, Color3.fromRGB(80, 140, 255), 2)

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
    Utils.createCorner(closeButton, 999)

    -- Botão de clique invisível
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, -42, 1, 0)
    clickButton.Position = UDim2.new(0, 0, 0, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = mainFrame

    -- Eventos
    clickButton.MouseButton1Click:Connect(KickSystem.kickPlayer)
    closeButton.MouseButton1Click:Connect(function()
        KickGUI.removeKickMeGUI()
    end)

    -- Animação de aparição
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local appearTween = TweenService:Create(mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 180, 0, 55)}
    )
    appearTween:Play()
end

-- Função para remover GUI do Kick Me
function KickGUI.removeKickMeGUI()
    if kickScreenGui then
        kickScreenGui:Destroy()
        kickScreenGui = nil
    end
end

return KickGUI
