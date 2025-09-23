-- Security System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Utils = require(script.Parent.Parent.utils.utils)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SecuritySystem = {}

function SecuritySystem.CheckIntegrity()
    local requiredServices = {
        Players, ReplicatedStorage, UserInputService,
        TweenService, RunService, HttpService
    }

    for _, service in pairs(requiredServices) do
        if not service then
            warn("Nexus: Serviço crítico não encontrado!")
            return false
        end
    end

    if not LocalPlayer or not PlayerGui then
        warn("Nexus: Player local ou PlayerGui não encontrado!")
        return false
    end

    return true
end

function SecuritySystem.AntiDetection()
    spawn(function()
        while wait(5) do
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui.Name:match("Nexus") then
                    gui.Name = "SG_" .. HttpService:GenerateGUID(false):sub(1, 8)
                end
            end
        end
    end)
end

function SecuritySystem.HandleResize()
    local connection
    connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local existing = PlayerGui:FindFirstChild("NexusGUI_2.0")
        if existing and existing:FindFirstChild("MainFrame") then
            local mainFrame = existing.MainFrame
            local isMinimized = mainFrame.Size.Y.Offset == 60

            if isMinimized then
                mainFrame.Position = Utils.GetCenterPosition(350, 60)
            else
                mainFrame.Position = Utils.GetCenterPosition(350, 350)
            end
        end
    end)

    return connection
end

return SecuritySystem
