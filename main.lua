-- GUI Nexus 1.0 - Arquivo Principal
-- Feito por do_one99

-- Importar módulos
local Services = require(script.Services)
local Utils = require(script.Utils)
local GUI = require(script.GUI)
local KickSystem = require(script.KickSystem)
local AimbotSystem = require(script.AimbotSystem)

-- Variáveis globais
_G.KickPlayerEnabled = _G.KickPlayerEnabled or false
local kickConnections = {}
local kickScreenGui = nil
local mainScreenGui = nil

-- Estados dos toggles
local toggle1State = false
local toggle2State = false

-- Função principal de inicialização
local function initializeNexus()
    -- Limpar GUI existente se houver
    if Services.playerGui:FindFirstChild("ModernCustomGUI") then
        Services.playerGui:FindFirstChild("ModernCustomGUI"):Destroy()
    end
    
    wait(0.3)
    
    -- Criar GUI principal
    mainScreenGui = GUI.createMainGUI()
    
    -- Configurar eventos dos toggles
    setupToggleEvents()
end

-- Configurar eventos dos toggles
function setupToggleEvents()
    local container = mainScreenGui.MainFrame.Container
    
    -- Toggle 1: Kick Button
    local toggle1Button = GUI.createToggle(
        container,
        "Kick Button",
        "Exibe interface para self-kick",
        15,
        function(button)
            toggle1State = not toggle1State
            GUI.animateToggle(button, toggle1State)
            
            if toggle1State then
                kickScreenGui = KickSystem.createKickGUI()
            else
                KickSystem.removeKickGUI(kickScreenGui)
                kickScreenGui = nil
            end
        end
    )
    
    -- Toggle 2: Aimbot
    local toggle2Button = GUI.createToggle(
        container,
        "Aimbot",
        "Sistema de mira automática",
        90,
        function(button)
            toggle2State = not toggle2State
            _G.KickPlayerEnabled = toggle2State
            GUI.animateToggle(button, toggle2State)
            
            if toggle2State then
                kickConnections = AimbotSystem.setupClickSystem()
            else
                AimbotSystem.cleanupConnections(kickConnections)
                kickConnections = {}
            end
        end
    )
    
    -- Eventos de controle da janela
    GUI.setupWindowControls(mainScreenGui, function()
        -- Callback de fechamento
        KickSystem.removeKickGUI(kickScreenGui)
        AimbotSystem.cleanupConnections(kickConnections)
        kickConnections = {}
        mainScreenGui = nil
    end)
end

-- Inicializar o sistema
initializeNexus()
