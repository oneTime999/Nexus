-- GUI Nexus 1.0 - Versão Moderna ESTÁVEL
-- Arquivo Principal - main.lua

-- Importar módulos
local Services = require(script.Parent.Services)
local Utils = require(script.Parent.Utils)
local KickSystem = require(script.Parent.KickSystem)
local GUI = require(script.Parent.GUI)

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variáveis de controle globais
_G.KickPlayerEnabled = _G.KickPlayerEnabled or false

-- Limpar GUI existente
if playerGui:FindFirstChild("ModernCustomGUI") then
    playerGui:FindFirstChild("ModernCustomGUI"):Destroy()
end

wait(0.3)

-- Inicializar GUI principal
GUI.createMainGUI()

print("Nexus 1.0 carregado com sucesso!")
