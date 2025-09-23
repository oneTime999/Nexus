-- Animal Monitor System
local RunService = game:GetService("RunService")
local NotificationSystem = require(script.Parent.Parent.utils.notifications)

local AnimalMonitor = {}

local ANIMAL_CONFIG = {
    UpdateInterval = 1,
    MaxDistance = 1000,
    EnabledCategories = {
        Brainrot = false,
        LuckyBlock = false,
        Secret = false,
        BrainrotGod = false,
        Overall = false
    }
}

local AnimalConnections = {}
local AnimalGUIs = {}
local LastUpdate = 0

local function extractGenerationNumber(texto)
    if not texto then return 0 end

    local numero, sufixo = string.match(texto, "(%d*%.?%d+)([KMBTkmbt]?)")
    if numero then
        local valor = tonumber(numero) or 0
        if sufixo then
            sufixo = string.upper(sufixo)
            if sufixo == "K" then valor = valor * 1000
            elseif sufixo == "M" then valor = valor * 1000000
            elseif sufixo == "B" then valor = valor * 1000000000
            elseif sufixo == "T" then valor = valor * 1000000000000
            end
        end
        return valor
    end

    return tonumber(texto) or 0
end

local function extractTimeMinutes(texto)
    if not texto then return 0 end

    local minutos = 0

    local horas = string.match(texto, "(%d+)h")
    local mins = string.match(texto, "(%d+)m")

    if horas then
        minutos = minutos + (tonumber(horas) * 60)
    end

    if mins then
        minutos = minutos + tonumber(mins)
    end

    if minutos == 0 then
        local numero = string.match(texto, "(%d+)")
        if numero then
            minutos = tonumber(numero) or 0
        end
    end

    return minutos
end

local function getTextFromObject(objeto)
    if not objeto then return "N/A" end

    if objeto:IsA("TextLabel") or objeto:IsA("TextButton") or objeto:IsA("TextBox") then
        return objeto.Text or "N/A"
    end

    if objeto:IsA("StringValue") then
        return objeto.Value or "N/A"
    end

    if objeto:IsA("IntValue") or objeto:IsA("NumberValue") then
        return tostring(objeto.Value) or "N/A"
    end

    local sucesso, resultado = pcall(function()
        return objeto.Text
    end)
    if sucesso and resultado then
        return resultado
    end

    sucesso, resultado = pcall(function()
        return tostring(objeto.Value)
    end)
    if sucesso and resultado then
        return resultado
    end

    return "N/A"
end

local function checkMutation(mutationObj)
    if not mutationObj then return "N/A" end

    local textoMutacao = getTextFromObject(mutationObj)
    local isVisible = mutationObj.Visible

    if string.upper(textoMutacao) == "GOLD" and not isVisible then
        return "Normal"
    elseif string.upper(textoMutacao) == "GOLD" and isVisible then
        return "Gold"
    else
        return textoMutacao
    end
end

local function determineCategory(displayName, generation, rarity)
    local nome = string.lower(displayName or "")
    local raridade = string.lower(rarity or "")
    local generation = string.lower(generation or "")

    if (nome:match("lucky") and nome:match("block")) or (raridade:match("lucky") and raridade:match("block")) then
        return "LuckyBlock"
    end

    if string.lower(rarity) == "secret" then
        return "Secret"
    end

    if string.lower(rarity) == "brainrot god" then
        return "BrainrotGod"
    end

    if generation:match("%d+h") or generation:match("%d+m") or generation:match("hora") or generation:match("min") then
        return "LuckyBlock"
    end

    return "Brainrot"
end

local function findAllAnimalOverheads(parent)
    local overheads = {}

    for _, child in pairs(parent:GetChildren()) do
        if child.Name == "AnimalOverhead" then
            table.insert(overheads, child)
        end

        local subOverheads = findAllAnimalOverheads(child)
        for _, overhead in pairs(subOverheads) do
            table.insert(overheads, overhead)
        end
    end

    return overheads
end

local function collectAnimalsByCategory()
    local categories = {
        Brainrot = {},
        LuckyBlock = {},
        Secret = {},
        BrainrotGod = {},
        Overall = {}
    }

    local todosOverheads = findAllAnimalOverheads(workspace)

    for _, animalOverhead in pairs(todosOverheads) do
        local displayName = getTextFromObject(animalOverhead:FindFirstChild("DisplayName"))
        local generation = getTextFromObject(animalOverhead:FindFirstChild("Generation"))
        local mutationObj = animalOverhead:FindFirstChild("Mutation")
        local mutation = checkMutation(mutationObj)
        local rarity = getTextFromObject(animalOverhead:FindFirstChild("Rarity"))

        if displayName ~= "N/A" then
            local category = determineCategory(displayName, generation, rarity)

            local animal = {
                overhead = animalOverhead,
                displayName = displayName,
                generation = generation,
                mutation = mutation,
                rarity = rarity,
                category = category
            }

            if category == "LuckyBlock" then
                animal.compareValue = extractTimeMinutes(generation)
            else
                animal.compareValue = extractGenerationNumber(generation)
            end

            if animal.compareValue > 0 then
                table.insert(categories[category], animal)

                if categories.Overall then
                    table.insert(categories.Overall, animal)
                end
            end
        end
    end

    return categories
end

local function findBasePart(animalOverhead)
    local current = animalOverhead.Parent

    for i = 1, 5 do
        if not current then break end

        if current:IsA("BasePart") then
            return current
        end

        for _, child in pairs(current:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            end
        end

        current = current.Parent
    end

    local tempPart = Instance.new("Part")
    tempPart.Name = "TempAnchor_" .. math.random(1000, 9999)
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Transparency = 1
    tempPart.Position = Vector3.new(0, 50, 0)
    tempPart.Parent = workspace

    return tempPart
end

local function createCategoryGUI(bestAnimal, category)
    local guiName = "BestAnimal_" .. category .. "_GUI"

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == guiName then
            obj:Destroy()
        end
    end

    local anchorPart = findBasePart(bestAnimal.overhead)
    if not anchorPart then return end

    local existing = anchorPart:FindFirstChild(guiName)
    if existing then
        existing:Destroy()
    end

    local configs = {
        Brainrot = {
            title = "ESP Best Brainrot",
            borderColor = Color3.fromRGB(0, 255, 0),
            titleColor = Color3.fromRGB(0, 255, 0),
            offset = Vector3.new(0, 15, 0)
        },

        LuckyBlock = {
            title = "🎲 MELHOR LUCKY BLOCK",
            borderColor = Color3.fromRGB(255, 215, 0),
            titleColor = Color3.fromRGB(255, 215, 0),
            offset = Vector3.new(5, 15, 0)
        },

        Secret = {
            title = "ESP Best Secret",
            borderColor = Color3.fromRGB(128, 0, 128),
            titleColor = Color3.fromRGB(128, 0, 128),
            offset = Vector3.new(-5, 15, 0)
        },

        BrainrotGod = {
            title = "ESP Best Brainrot God",
            borderColor = Color3.fromRGB(255, 0, 0),
            titleColor = Color3.fromRGB(255, 0, 0),
            offset = Vector3.new(0, 20, 0)
        },

        Overall = {
            title = "ESP Best Brainrot",
            borderColor = Color3.fromRGB(88, 166, 255),
            titleColor = Color3.fromRGB(88, 166, 255),
            offset = Vector3.new(0, 22, 0)
        }
    }

    local config = configs[category]
    if not config then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = guiName
    billboard.Size = UDim2.new(22, 0, 18, 0)
    billboard.StudsOffset = config.offset
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ANIMAL_CONFIG.MaxDistance
    billboard.LightInfluence = 0
    billboard.Parent = anchorPart

    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    bgFrame.BackgroundTransparency = 0.1
    bgFrame.BorderSizePixel = 3
    bgFrame.BorderColor3 = config.borderColor
    bgFrame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = bgFrame

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -10, 0.18, 0)
    headerLabel.Position = UDim2.new(0, 5, 0, 2)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = config.title
    headerLabel.TextColor3 = config.titleColor
    headerLabel.TextScaled = true
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.TextStrokeTransparency = 0
    headerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    headerLabel.Parent = bgFrame

    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(0.9, 0, 0.02, 0)
    separator.Position = UDim2.new(0.05, 0, 0.20, 0)
    separator.BackgroundColor3 = config.borderColor
    separator.BorderSizePixel = 0
    separator.Parent = bgFrame

    local separatorCorner = Instance.new("UICorner")
    separatorCorner.CornerRadius = UDim.new(0, 1)
    separatorCorner.Parent = separator

    local function createLabel(posY, texto, cor)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0.15, 0)
        label.Position = UDim2.new(0, 5, posY, 0)
        label.BackgroundTransparency = 1
        label.Text = texto
        label.TextColor3 = cor
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = bgFrame
    end

    createLabel(0.25, "🔥 " .. bestAnimal.displayName, Color3.fromRGB(255, 255, 255))

    local textoGeracao = category == "LuckyBlock" and "⏰ " .. bestAnimal.generation or "🧬 " .. bestAnimal.generation
    createLabel(0.42, textoGeracao, Color3.fromRGB(0, 255, 100))

    local mutationColor = bestAnimal.mutation == "Gold" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 165, 0)
    createLabel(0.59, "🔬 " .. bestAnimal.mutation, mutationColor)

    createLabel(0.76, "💎 " .. bestAnimal.rarity, Color3.fromRGB(150, 100, 255))

    local footerLabel = Instance.new("TextLabel")
    footerLabel.Size = UDim2.new(1, -10, 0.08, 0)
    footerLabel.Position = UDim2.new(0, 5, 0.92, 0)
    footerLabel.BackgroundTransparency = 1
    footerLabel.Text = os.date("%H:%M:%S")
    footerLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    footerLabel.TextScaled = true
    footerLabel.Font = Enum.Font.Gotham
    footerLabel.TextXAlignment = Enum.TextXAlignment.Center
    footerLabel.Parent = bgFrame

    AnimalGUIs[category] = billboard
    return billboard
end

function AnimalMonitor.UpdateAll()
    local agora = tick()
    if agora - LastUpdate < ANIMAL_CONFIG.UpdateInterval then
        return
    end
    LastUpdate = agora

    local categories = collectAnimalsByCategory()

    for category, animais in pairs(categories) do
        if ANIMAL_CONFIG.EnabledCategories[category] and #animais > 0 then
            local melhor = animais[1]
            for _, animal in pairs(animais) do
                if animal.compareValue > melhor.compareValue then
                    melhor = animal
                end
            end

            createCategoryGUI(melhor, category)
        else
            if AnimalGUIs[category] then
                AnimalGUIs[category] = nil
        end

        local guiName = "BestAnimal_" .. category .. "_GUI"
        for _, obj in pairs(workspace:GetChildren()) do
            if obj and obj.Name == guiName then
                pcall(function() obj:Destroy() end)
            end
        end

        local anyEnabled = false
        for _, v in pairs(ANIMAL_CONFIG.EnabledCategories) do
            if v then
                anyEnabled = true
                break
            end
        end

        if not anyEnabled then
            AnimalMonitor.Stop()
            return
        end

        if enabled and next(AnimalConnections) == nil then
            AnimalMonitor.Start()
        end
    end
end

function AnimalMonitor.Toggle(enabled)
    if enabled then
        AnimalMonitor.Start()
    else
        AnimalMonitor.Stop()
    end
end

_G.StopAnimalMonitor = AnimalMonitor.Stop
_G.AnimalMonitorSystem = AnimalMonitor

return AnimalMonitor]:Destroy()
                AnimalGUIs[category] = nil
            end
        end
    end
end

function AnimalMonitor.Start()
    AnimalMonitor.Stop()

    AnimalConnections.Main = RunService.Heartbeat:Connect(function()
        pcall(AnimalMonitor.UpdateAll)
    end)

    pcall(AnimalMonitor.UpdateAll)

    if NotificationSystem and NotificationSystem.Create then
        NotificationSystem.Create("Animal Monitor", "Sistema de monitoramento multi-category ativado!", "success", 4)
    end
end

function AnimalMonitor.Stop()
    for _, connection in pairs(AnimalConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    AnimalConnections = {}

    for category, gui in pairs(AnimalGUIs) do
        if gui then
            gui:Destroy()
        end
    end
    AnimalGUIs = {}

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:match("BestAnimal_") and obj.Name:match("_GUI") then
            obj:Destroy()
        end
    end

    if NotificationSystem and NotificationSystem.Create then
        NotificationSystem.Create("Animal Monitor", "System deactivated.", "warning")
    end
end

function AnimalMonitor.ToggleCategory(category, enabled)
    if ANIMAL_CONFIG.EnabledCategories[category] ~= nil then
        ANIMAL_CONFIG.EnabledCategories[category] = enabled

        if not enabled and AnimalGUIs[category] then
            pcall(function()
                AnimalGUIs[category]:Destroy()
            end)
            AnimalGUIs[category
