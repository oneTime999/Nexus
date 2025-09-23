-- Main Interface
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Utils = require(script.Parent.Parent.utils.utils)
local Settings = require(script.Parent.Parent.core.settings)
local Components = require(script.Parent.components)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentTheme = Settings.GetCurrentTheme()

local MainInterface = {}

function MainInterface.CreateMainInterface()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusGUI_2.0"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 350)
    mainFrame.Position = Utils.GetCenterPosition(350, 350)
    mainFrame.BackgroundColor3 = CurrentTheme.Background
    mainFrame.BackgroundTransparency = 0.75
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = CurrentTheme.Border
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 16)
    shadowCorner.Parent = shadow

    return screenGui, mainFrame
end

function MainInterface.CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = CurrentTheme.Secondary
    header.BackgroundTransparency = 0.75
    header.BorderSizePixel = 0
    header.Parent = parent

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header

    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -40, 0, 2)
    separator.Position = UDim2.new(0, 20, 1, -2)
    separator.BackgroundColor3 = CurrentTheme.Accent
    separator.BorderSizePixel = 0
    separator.Parent = header

    local sepCorner = Instance.new("UICorner")
    sepCorner.CornerRadius = UDim.new(1, 0)
    sepCorner.Parent = separator

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Position = UDim2.new(0, 15, 0, 12.5)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡"
    icon.TextColor3 = CurrentTheme.Accent
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 150, 0, 20)
    title.Position = UDim2.new(0, 60, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "NEXUS 1.1"
    title.TextColor3 = CurrentTheme.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isPC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

    local platformText = ""
    if isMobile then
        platformText = "By do_one99 | 📱 Mobile"
    elseif isPC then
        platformText = "By do_one99 | 🖥️ PC"
    else
        platformText = "By do_one99 | 🎮 Console"
    end

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 250, 0, 15)
    subtitle.Position = UDim2.new(0, 60, 0, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = platformText
    subtitle.TextColor3 = CurrentTheme.TextSecondary
    subtitle.TextSize = 11
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    return Components.CreateHeaderButtons(header)
end

function MainInterface.CreateContainer(parent)
    local container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -90)
    container.Position = UDim2.new(0, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = CurrentTheme.Accent
    container.ScrollBarImageTransparency = 0.3
    container.CanvasSize = UDim2.new(0, 0, 0, 580)
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.Parent = parent

    return container
end

return MainInterface
