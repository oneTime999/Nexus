-- Utils.lua - Módulo de funções utilitárias
-- Funções auxiliares usadas em todo o projeto

local Services = require(script.Parent.Services)
local Utils = {}

-- Função para calcular distância entre duas posições
function Utils.getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Função para encontrar o player mais próximo
function Utils.getClosestPlayer()
    local localCharacter = Services.LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local localPosition = localCharacter.HumanoidRootPart.Position
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.LocalPlayer and player.Character then
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

-- Função para formatar data/hora atual
function Utils.getCurrentTimeString()
    return os.date("%d/%m/%Y às %H:%M:%S")
end

-- Função para obter JobId do jogo
function Utils.getJobId()
    return game.JobId or "N/A"
end

return Utils
