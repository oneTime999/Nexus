-- Utils.lua - Funções utilitárias

local Services = require(script.Parent.Services)
local Players = Services.Players
local LocalPlayer = Services.LocalPlayer

local Utils = {}

-- Função para calcular distância
function Utils.getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Função para encontrar player mais próximo
function Utils.getClosestPlayer()
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local localPosition = localCharacter.HumanoidRootPart.Position
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if character:FindFirstChild("HumanoidRootPart") then
                local distance = Utils.getDistance(localPosition, character.HumanoidRootPart.Position)
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Função para criar cantos arredondados
function Utils.createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

-- Função para criar gradiente
function Utils.createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colors
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

-- Função para criar stroke
function Utils.createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

return Utils
