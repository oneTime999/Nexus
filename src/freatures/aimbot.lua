-- Aimbot System
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(script.Parent.Parent.utils.utils)
local NotificationSystem = require(script.Parent.Parent.utils.notifications)
local Settings = require(script.Parent.Parent.core.settings)

local LocalPlayer = Players.LocalPlayer

local Aimbot = {}
local activeConnections = {}

function Aimbot.ExecuteRemoteOnClosest()
    if not Settings.Config.AimbotEnabled then return end

    local closestPlayer = Utils.GetClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("UpperTorso") then
        local playerName = closestPlayer.Name

        local args = {
            [1] = Vector3.new(0, 0, 0),
            [2] = game:GetService("Players")[playerName].Character.UpperTorso
        }

        local success, errorMsg = pcall(function()
            game:GetService("ReplicatedStorage").Packages.Net:FindFirstChild("RE/UseItem"):FireServer(unpack(args))
        end)

        if not success then
            warn("Nexus Aimbot Error: " .. tostring(errorMsg))
        end
    end
end

function Aimbot.Setup(enabled)
    for _, connection in pairs(activeConnections) do
        if connection then connection:Disconnect() end
    end
    activeConnections = {}

    if enabled then
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local isPC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

        if isMobile then
            if UserInputService.TouchTap then
                activeConnections[#activeConnections + 1] = UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
                    if not gameProcessed and Settings.Config.AimbotEnabled then
                        Aimbot.ExecuteRemoteOnClosest()
                    end
                end)
            end

            activeConnections[#activeConnections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end

                if input.UserInputType == Enum.UserInputType.Touch and Settings.Config.AimbotEnabled then
                    Aimbot.ExecuteRemoteOnClosest()
                end
            end)

            NotificationSystem.Create("Aimbot Mobile", "Sistema ativado para dispositivos móveis! Toque na tela para usar.", "success", 4)

        elseif isPC then
            local mouse = LocalPlayer:GetMouse()

            if mouse and mouse.Button1Down then
                local success, connection = pcall(function()
                    return mouse.Button1Down:Connect(function()
                        if Settings.Config.AimbotEnabled then
                            Aimbot.ExecuteRemoteOnClosest()
                        end
                    end)
                end)

                if success and connection then
                    activeConnections[#activeConnections + 1] = connection
                end
            end

            activeConnections[#activeConnections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end

                if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Config.AimbotEnabled then
                    Aimbot.ExecuteRemoteOnClosest()
                end
            end)

            NotificationSystem.Create("Aimbot PC", "Sistema ativado para PC! Clique com o botão esquerdo para usar.", "success", 4)

        else
            local mouse = LocalPlayer:GetMouse()
            if mouse and mouse.Button1Down then
                local success, connection = pcall(function()
                    return mouse.Button1Down:Connect(function()
                        if Settings.Config.AimbotEnabled then
                            Aimbot.ExecuteRemoteOnClosest()
                        end
                    end)
                end)

                if success and connection then
                    activeConnections[#activeConnections + 1] = connection
                end
            end

            activeConnections[#activeConnections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or not Settings.Config.AimbotEnabled then return end

                local validInputTypes = {
                    Enum.UserInputType.MouseButton1,
                    Enum.UserInputType.Touch,
                }

                local validKeyCodes = {
                    Enum.KeyCode.ButtonX,
                    Enum.KeyCode.ButtonA,
                    Enum.KeyCode.ButtonR2,
                }

                for _, inputType in pairs(validInputTypes) do
                    if input.UserInputType == inputType then
                        Aimbot.ExecuteRemoteOnClosest()
                        return
                    end
                end

                for _, keyCode in pairs(validKeyCodes) do
                    if input.KeyCode == keyCode then
                        Aimbot.ExecuteRemoteOnClosest()
                        return
                    end
                end
            end)

            NotificationSystem.Create("Aimbot Universal", "Sistema ativado em modo universal!", "success", 4)
        end

    else
        NotificationSystem.Create("Aimbot", "System deactivated.", "warning")
    end
end

return Aimbot
