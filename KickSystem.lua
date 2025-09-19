-- KickSystem.lua - Sistema de Kick e Aimbot

local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)

local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer

local KickSystem = {}

-- Variáveis de controle
local kickConnections = {}

-- Função principal do remote
function KickSystem.executeRemoteOnClosestPlayer()
    if not _G.KickPlayerEnabled then return end
    
    local closestPlayer = Utils.getClosestPlayer()
    if closestPlayer then
        local playerName = closestPlayer.Name
        
        local args = {
            [1] = Vector3.new(0, 0, 0),
            [2] = game:GetService("Players")[playerName].Character.UpperTorso
        }
        
        pcall(function()
            ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem"):FireServer(unpack(args))
        end)
    end
end

-- Função para configurar sistema de clique
function KickSystem.setupClickSystem()
    for _, connection in pairs(kickConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    kickConnections = {}
    
    if not _G.KickPlayerEnabled then return end
    
    local mouse = LocalPlayer:GetMouse()
    kickConnections[1] = mouse.Button1Down:Connect(function()
        if _G.KickPlayerEnabled then
            KickSystem.executeRemoteOnClosestPlayer()
        end
    end)
end

-- Função para desconectar sistema de clique
function KickSystem.disconnectClickSystem()
    for _, connection in pairs(kickConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    kickConnections = {}
end

-- Função kick player (self-kick)
function KickSystem.kickPlayer()
    pcall(function()
        local kickTime = os.date("%d/%m/%Y às %H:%M:%S")
        local jobId = game.JobId
        
        local kickMessage = string.format(
            "Horário: %s (Brasília)\nJobID: %s",
            kickTime,
            jobId
        )
        
        LocalPlayer:Kick(kickMessage)
    end)
end

return KickSystem
