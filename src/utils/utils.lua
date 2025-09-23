-- Utility Functions
-- src/utils/utils.lua

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Utils = {}

function Utils.GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utils.GetClosestPlayer()
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local localPosition = localCharacter.HumanoidRootPart.Position
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = Utils.GetDistance(localPosition, player.Character.HumanoidRootPart.Position)
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

function Utils.CreateTween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function Utils.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Nexus Error: " .. tostring(result))
    end
    return success, result
end

function Utils.GetCenterPosition(width, height)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local x = (screenSize.X - width) / 2
    local y = (screenSize.Y - height) / 2
    return UDim2.new(0, x, 0, y)
end

return Utils
