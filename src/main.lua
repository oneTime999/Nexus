-- Nexus Main Entry Point
-- This is the main file that should be executed to start Nexus

local NexusCore = require(script.core.init)
local NotificationSystem = require(script.utils.notifications)

-- Start Nexus with error handling
local success, errorMsg = pcall(NexusCore.StartNexus)

if not success then
    warn("Nexus 1.1 Error: " .. tostring(errorMsg))
    
    spawn(function()
        wait(1)
        NotificationSystem.Create(
            "Erro Crítico",
            "Falha na inicialização do Nexus 1.1. Verifique o console para detalhes.",
            "error",
            8
        )
    end)
end
