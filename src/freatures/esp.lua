-- ESP System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NotificationSystem = require(script.Parent.Parent.utils.notifications)
local Settings = require(script.Parent.Parent.core.settings)

local LocalPlayer = Players.LocalPlayer

local ESP = {}
local PlayerTexts = {}
local ESPConnections = {}

local ESPConfig = {
    VisibleColor = Color3.fromRGB(0, 255, 0),
    TeamColor = Color3.fromRGB(0, 100, 255),
    MaxDistance = 2000,
    ShowDistance = true,
    HighlightVisible = true
}

function ESP.CreateDrawingTexts()
    local texts = {}

    if Drawing then
        local success1, nameText = pcall(function()
            local text = Drawing.new("Text")
            text.Visible = false
            text.Center = true
            text.Outline = true
            text.OutlineColor = Color3.new(0, 0, 0)
            text.Color = Color3.new(1, 1, 1)
            text.Size = 18
            text.Font = Drawing.Fonts and Drawing.Fonts.UI or 2
            text.Text = ""
            return text
        end)

        if success1 and nameText then
            texts.name = nameText
        end

        local success2, distText = pcall(function()
            local text = Drawing.new("Text")
            text.Visible = false
            text.Center = true
            text.Outline = true
            text.OutlineColor = Color3.new(0, 0, 0)
            text.Color = Color3.new(0.8, 0.8, 0.8)
            text.Size = 14
            text.Font = Drawing.Fonts and Drawing.Fonts.UI or 2
            text.Text = ""
            return text
        end)

        if success2 and distText then
            texts.info = distText
        end
    end

    return texts
end

function ESP.UpdateDrawingTexts(player, character, texts)
    if not texts or not character or not texts.name then
        return false
    end

    local head = character:FindFirstChild("Head")
    if not head then return false end

    local camera = workspace.CurrentCamera
    if not camera then return false end

    local success, result = pcall(function()
        local headPos = head.Position + Vector3.new(0, 2, 0)
        local screenPos, onScreen = camera:WorldToViewportPoint(headPos)

        if onScreen and screenPos.Z > 0 then
            local isTeammate = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)

            texts.name.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
            texts.name.Text = player.Name or "Unknown"
            texts.name.Color = isTeammate and ESPConfig.TeamColor or ESPConfig.VisibleColor
            texts.name.Visible = Settings.Config.ESPEnabled

            if texts.info and ESPConfig.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                texts.info.Position = Vector2.new(screenPos.X, screenPos.Y - 8)
                texts.info.Text = string.format("%.0fm", distance)
                texts.info.Visible = Settings.Config.ESPEnabled
            end

            return true
        else
            texts.name.Visible = false
            if texts.info then texts.info.Visible = false end
            return false
        end
    end)

    return success and result
end

function ESP.CreateBillboardText(character)
    if not character or not character:FindFirstChild("Head") then return nil end

    local head = character.Head
    local existingBillboard = head:FindFirstChild("ESPNameTag")
    if existingBillboard then
        existingBillboard:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPNameTag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESPConfig.MaxDistance
    billboard.LightInfluence = 0
    billboard.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = character.Parent.Name or "Player"
    nameLabel.TextColor3 = ESPConfig.VisibleColor
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = frame

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = frame

    return {
        billboard = billboard,
        nameLabel = nameLabel,
        distanceLabel = distanceLabel
    }
end

function ESP.UpdateBillboardText(player, character, billboardData)
    if not billboardData or not character then return false end

    local success = pcall(function()
        local isTeammate = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
        local color = isTeammate and ESPConfig.TeamColor or ESPConfig.VisibleColor

        billboardData.nameLabel.TextColor3 = color
        billboardData.nameLabel.Text = player.Name or "Player"

        if ESPConfig.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local head = character:FindFirstChild("Head")
            if head then
                local distance = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                billboardData.distanceLabel.Text = string.format("%.0fm", distance)
                billboardData.distanceLabel.Visible = true
            end
        else
            billboardData.distanceLabel.Visible = false
        end

        billboardData.billboard.Enabled = Settings.Config.ESPEnabled
    end)

    return success
end

function ESP.RevealPlayer(character)
    if not character or not character.Parent then return end

    pcall(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if part.Transparency >= 1 then
                    part.Transparency = 0
                elseif part.Transparency >= 0.9 then
                    part.Transparency = 0
                end
            end
        end

        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle.Transparency >= 0.9 then
                    handle.Transparency = 0
                end
            end
        end

        local forceField = character:FindFirstChild("ForceField")
        if forceField then
            forceField:Destroy()
        end
    end)
end

function ESP.ProcessPlayer(player)
    if not player or player == LocalPlayer then return end

    local character = player.Character
    if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then
        if PlayerTexts[player] then
            if PlayerTexts[player].drawingTexts then
                pcall(function()
                    if PlayerTexts[player].drawingTexts.name then
                        PlayerTexts[player].drawingTexts.name.Visible = false
                    end
                    if PlayerTexts[player].drawingTexts.info then
                        PlayerTexts[player].drawingTexts.info.Visible = false
                    end
                end)
            end
            if PlayerTexts[player].billboardData then
                pcall(function()
                    PlayerTexts[player].billboardData.billboard.Enabled = false
                end)
            end
        end
        return
    end

    local tooFar = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        tooFar = distance > ESPConfig.MaxDistance
    end

    if tooFar then
        if PlayerTexts[player] then
            if PlayerTexts[player].drawingTexts then
                pcall(function()
                    if PlayerTexts[player].drawingTexts.name then
                        PlayerTexts[player].drawingTexts.name.Visible = false
                    end
                    if PlayerTexts[player].drawingTexts.info then
                        PlayerTexts[player].drawingTexts.info.Visible = false
                    end
                end)
            end
            if PlayerTexts[player].billboardData then
                pcall(function()
                    PlayerTexts[player].billboardData.billboard.Enabled = false
                end)
            end
        end
        return
    end

    ESP.RevealPlayer(character)

    if not PlayerTexts[player] then
        PlayerTexts[player] = {}
    end

    if Drawing then
        if not PlayerTexts[player].drawingTexts then
            PlayerTexts[player].drawingTexts = ESP.CreateDrawingTexts()
        end

        if PlayerTexts[player].drawingTexts and PlayerTexts[player].drawingTexts.name then
            ESP.UpdateDrawingTexts(player, character, PlayerTexts[player].drawingTexts)
        else
            if not PlayerTexts[player].billboardData then
                PlayerTexts[player].billboardData = ESP.CreateBillboardText(character)
            end
            if PlayerTexts[player].billboardData then
                ESP.UpdateBillboardText(player, character, PlayerTexts[player].billboardData)
            end
        end
    else
        if not PlayerTexts[player].billboardData then
            PlayerTexts[player].billboardData = ESP.CreateBillboardText(character)
        end
        if PlayerTexts[player].billboardData then
            ESP.UpdateBillboardText(player, character, PlayerTexts[player].billboardData)
        end
    end

    if ESPConfig.HighlightVisible then
        pcall(function()
            local isTeammate = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)

            local highlight = character:FindFirstChild("AntiInvisHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "AntiInvisHighlight"
                highlight.Parent = character
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end

            local color = isTeammate and ESPConfig.TeamColor or ESPConfig.VisibleColor
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Enabled = Settings.Config.ESPEnabled
        end)
    end
end

function ESP.CleanupPlayer(player)
    if PlayerTexts[player] then
        if PlayerTexts[player].drawingTexts then
            pcall(function()
                if PlayerTexts[player].drawingTexts.name then
                    PlayerTexts[player].drawingTexts.name:Remove()
                end
                if PlayerTexts[player].drawingTexts.info then
                    PlayerTexts[player].drawingTexts.info:Remove()
                end
            end)
        end

        if PlayerTexts[player].billboardData then
            pcall(function()
                if PlayerTexts[player].billboardData.billboard then
                    PlayerTexts[player].billboardData.billboard:Destroy()
                end
            end)
        end

        PlayerTexts[player] = nil
    end

    if ESPConnections[player] then
        ESPConnections[player]:Disconnect()
        ESPConnections[player] = nil
    end
end

function ESP.Setup(enabled)
    for _, connection in pairs(ESPConnections) do
        if connection then connection:Disconnect() end
    end
    ESPConnections = {}

    if enabled then
        local mainConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Config.ESPEnabled then return end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        ESP.ProcessPlayer(player)
                    end)
                end
            end
        end)

        ESPConnections["Main"] = mainConnection

        ESPConnections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                ESPConnections[player] = player.CharacterAdded:Connect(function()
                    wait(1)
                end)
            end
        end)

        ESPConnections["PlayerRemoving"] = Players.PlayerRemoving:Connect(ESP.CleanupPlayer)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESPConnections[player] = player.CharacterAdded:Connect(function()
                    wait(1)
                end)
            end
        end

        NotificationSystem.Create("ESP Player", "System activated! Invisible players will be revealed and names displayed.", "success", 4)

    else
        for player, data in pairs(PlayerTexts) do
            if data.drawingTexts then
                pcall(function()
                    if data.drawingTexts.name then data.drawingTexts.name.Visible = false end
                    if data.drawingTexts.info then data.drawingTexts.info.Visible = false end
                end)
            end
            if data.billboardData then
                pcall(function()
                    data.billboardData.billboard.Enabled = false
                end)
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("AntiInvisHighlight")
                if highlight then highlight:Destroy() end
            end
        end

        NotificationSystem.Create("ESP Player", "System deactivated.", "warning")
    end
end

return ESP
