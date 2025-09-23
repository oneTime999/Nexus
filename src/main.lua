-- Nexus Main Entry Point - VERSÃO CORRIGIDA
-- Este é o arquivo principal que deve ser executado para iniciar o Nexus

-- Aguarda o jogo carregar completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

wait(2) -- Aguarda estabilização

-- Função para carregar módulos com segurança
local function safeRequire(modulePath, fallback)
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    if success then
        return result
    else
        warn("Nexus: Falha ao carregar módulo " .. tostring(modulePath) .. " - " .. tostring(result))
        return fallback
    end
end

-- Carrega o sistema de notificações primeiro (não depende de outros módulos)
local NotificationSystem = safeRequire(script.utils.notifications, {
    Create = function(title, msg, type, duration)
        print("[Nexus] " .. title .. ": " .. msg)
    end
})

-- Carrega o núcleo principal
local NexusCore = safeRequire(script.core.init)

if not NexusCore then
    warn("Nexus 1.1: ERRO CRÍTICO - Não foi possível carregar o núcleo principal!")
    
    spawn(function()
        wait(1)
        if NotificationSystem and NotificationSystem.Create then
            NotificationSystem.Create(
                "Erro Crítico",
                "Falha na inicialização do Nexus 1.1. Módulo principal não encontrado.",
                "error",
                8
            )
        end
    end)
    return
end

-- Verifica se a função StartNexus existe
if not NexusCore.StartNexus then
    warn("Nexus 1.1: ERRO - Função StartNexus não encontrada no núcleo!")
    
    spawn(function()
        wait(1)
        NotificationSystem.Create(
            "Erro de Configuração",
            "Função de inicialização não encontrada. Verifique a instalação.",
            "error",
            8
        )
    end)
    return
end

-- Tenta inicializar o Nexus com tratamento de erro robusto
local success, errorMsg = pcall(function()
    NexusCore.StartNexus()
end)

if not success then
    local errorString = tostring(errorMsg)
    warn("Nexus 1.1 Error: " .. errorString)
    
    -- Análise específica de erros comuns
    if errorString:find("HTTP 404") or errorString:find("not found") then
        spawn(function()
            wait(1)
            NotificationSystem.Create(
                "Erro 404",
                "Arquivo não encontrado. Verifique se todos os módulos estão no GitHub.",
                "error",
                10
            )
        end)
    elseif errorString:find("attempt to index") then
        spawn(function()
            wait(1)
            NotificationSystem.Create(
                "Erro de Dependência",
                "Módulo ausente ou corrompido. Recarregue o script.",
                "error",
                10
            )
        end)
    else
        spawn(function()
            wait(1)
            NotificationSystem.Create(
                "Erro Desconhecido",
                "Falha na inicialização: " .. errorString:sub(1, 50) .. "...",
                "error",
                10
            )
        end)
    end
else
    -- Sucesso na inicialização
    spawn(function()
        wait(1)
        NotificationSystem.Create(
            "Nexus 1.1",
            "Sistema carregado com sucesso! Use Ctrl Direito para abrir.",
            "success",
            5
        )
    end)
end
