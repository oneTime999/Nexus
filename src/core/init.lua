-- Nexus Core Initialization
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Import modules
local Settings = require(script.Parent.settings)
local SecuritySystem = require(script.Parent.security)
local NotificationSystem = require(script.Parent.Parent.utils.notifications)
local Utils = require(script.Parent.Parent.utils.utils)
local Animations = require(script.Parent.Parent.utils.animations)
local MainInterface = require(script.Parent.Parent.gui.main_interface)
local Components = require(script.Parent.Parent.gui.components)

-- Feature modules
local Aimbot = require(script.Parent.Parent.features.aimbot)
local ESP = require(script.Parent.Parent.features.esp)
local PlotMonitor = require(script.Parent.Parent.features.plot_monitor)
local AnimalMonitor = require(script.Parent.Parent.features.animal_monitor)
local SelfKick = require(script.Parent.Parent.features.self_kick)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local NexusCore = {}
local activeConnections = {}
local keybindConnection = nil

function NexusCore.AddAnimalMonitorCards(container)
    Components.CreateFeatureCard(container, "Best Overall", "Mostra o melhor animal do servidor (independente de raridade/mutação)", "🧠", 285, function(enabled)
        AnimalMonitor.ToggleCategory("Overall", enabled)
    end)

    Components.CreateFeatureCard(container, "Best Lucky Block", "Mostra o melhor Lucky Block (por tempo)", "🎲", 355, function(enabled)
        AnimalMonitor.ToggleCategory("LuckyBlock", enabled)
    end)

    Components.CreateFeatureCard(container, "Best Secret", "Mostra o melhor animal Secret do servidor", "🔮", 425, function(enabled)
        AnimalMonitor.ToggleCategory("Secret", enabled)
    end)

    Components.CreateFeatureCard(container, "Best Brainrot God", "Mostra o melhor Brainrot God do servidor", "👑", 495, function(enabled)
        AnimalMonitor.ToggleCategory("BrainrotGod", enabled)
    end)

    container.CanvasSize = UDim2.new(0, 0, 0, 580)
end

function NexusCore.InitializeNexus()
    -- Clean up existing GUIs
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:match("Nexus") or gui.Name:match("ModernCustomGUI") or gui.Name:match("SG_") then
            gui:Destroy()
        end
    end

    wait(0.1)

    local screenGui, mainFrame = MainInterface.CreateMainInterface()
    local minimizeBtn, settingsBtn, closeBtn = MainInterface.CreateHeader(mainFrame)

    local container = MainInterface.CreateContainer(mainFrame)
    Components.CreateStatusBar(mainFrame)

    local kickButtonGui = nil
    local isMinimized = false
    local originalSize = UDim2.new(0, 350, 0, 350)
    local minimizedSize = UDim2.new(0, 350, 0, 60)

    -- Feature cards
    Components.CreateFeatureCard(container, "Self Kick", "Sair do servidor com segurança", "🚪", 5, function(enabled)
        if enabled then
            if kickButtonGui then kickButtonGui:Destroy() end
            kickButtonGui = SelfKick.CreateKickButton()
            NotificationSystem.Create("Self Kick", "Botão de saída ativado!", "success")
        else
            if kickButtonGui then
                kickButtonGui:Destroy()
                kickButtonGui = nil
            end
            NotificationSystem.Create("Self Kick", "Botão de saída removido.", "warning")
        end
    end)

    Components.CreateFeatureCard(container, "Aimbot System", "Mira automática inteligente", "🎯", 75, function(enabled)
        Settings.Config.AimbotEnabled = enabled
        Aimbot.Setup(enabled)
    end)

    Components.CreateFeatureCard(container, "ESP Player", "Revela players invisíveis e mostra nomes", "👁", 145, function(enabled)
        Settings.Config.ESPEnabled = enabled
        ESP.Setup(enabled)
    end)

    Components.CreateFeatureCard(container, "ESP Base", "Monitora status de plots em tempo real", "🗂", 215, function(enabled)
        Settings.Config.PlotMonitorEnabled = enabled
        PlotMonitor.Setup(enabled)
    end)

    -- Add animal monitor cards
    NexusCore.AddAnimalMonitorCards(container)

    -- Minimize button functionality
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and minimizedSize or originalSize

        container.Visible = not isMinimized
        local statusBar = mainFrame:FindFirstChild("StatusBar")
        if statusBar then
            statusBar.Visible = not isMinimized
        end

        Utils.CreateTween(mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = targetSize}
        )

        minimizeBtn.Text = isMinimized and "+" or "−"

        spawn(function()
            wait(0.1)
            if isMinimized then
                Utils.CreateTween(mainFrame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Position = Utils.GetCenterPosition(350, 60)}
                )
            else
                Utils.CreateTween(mainFrame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Position = Utils.GetCenterPosition(350, 350)}
                )
            end
        end)
    end)

    -- Settings button
    settingsBtn.MouseButton1Click:Connect(function()
        NotificationSystem.Create(
            "Configurações",
            "Painel de configurações estará disponível na próxima atualização!",
            "warning",
            3
        )
    end)

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        Utils.CreateTween(mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }
        )

        spawn(function()
            wait(0.4)
            NexusCore.Cleanup()
            screenGui:Destroy()
            NotificationSystem.Create("Nexus", "Obrigado por usar o Nexus 1.1! Até mais!", "success", 4)
        end)
    end)

    Animations.ScaleIn(mainFrame, 0.6)

    spawn(function()
        wait(0.4)
        NotificationSystem.Create(
            "Bem-vindo ao Nexus 1.1 + ESP!",
            "Sistema completo carregado! Anti-invisibilidade integrado.",
            "success",
            4
        )
    end)
end

function NexusCore.Cleanup()
    -- Cleanup all connections and features
    for _, connection in pairs(activeConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    activeConnections = {}

    -- Stop all features
    if ESP then ESP.Setup(false) end
    if PlotMonitor then PlotMonitor.Setup(false) end
    if AnimalMonitor then AnimalMonitor.Stop() end
    if Aimbot then Aimbot.Setup(false) end

    if keybindConnection then
        keybindConnection:Disconnect()
    end
end

function NexusCore.SetupKeybinds()
    if keybindConnection then
        keybindConnection:Disconnect()
    end

    keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.RightControl then
            local existing = PlayerGui:FindFirstChild("NexusGUI_2.0")
            if existing then
                existing:Destroy()
                NotificationSystem.Create("Nexus", "Interface fechada!", "warning", 2)
            else
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui.Name:match("Nexus") or gui.Name:match("SG_") then
                        gui:Destroy()
                    end
                end
                wait(0.1)
                NexusCore.InitializeNexus()
            end
        elseif input.KeyCode == Enum.KeyCode.RightShift then
            NotificationSystem.Create("Quick Kick", "Saindo em 3 segundos...", "warning", 3)
            spawn(function()
                wait(3)
                SelfKick.Execute()
            end)
        elseif input.KeyCode == Enum.KeyCode.G then
            Settings.Config.ESPEnabled = not Settings.Config.ESPEnabled
            ESP.Setup(Settings.Config.ESPEnabled)
        elseif input.KeyCode == Enum.KeyCode.P then
            Settings.Config.PlotMonitorEnabled = not Settings.Config.PlotMonitorEnabled
            PlotMonitor.Setup(Settings.Config.PlotMonitorEnabled)
        end
    end)
end

function NexusCore.StartNexus()
    -- Clean up existing
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:match("Nexus") or gui.Name:match("SG_") or gui.Name:match("ModernCustomGUI") then
            gui:Destroy()
        end
    end

    wait(0.2)

    if not SecuritySystem.CheckIntegrity() then
        error("Nexus 1.1: Falha crítica na verificação de integridade!")
        return
    end

    SecuritySystem.AntiDetection()
    table.insert(activeConnections, SecuritySystem.HandleResize())
    NexusCore.SetupKeybinds()

    NexusCore.InitializeNexus()
end

-- Cleanup on player removal
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        NexusCore.Cleanup()
    end
end)

return NexusCore
