-- Plot Monitor System
local RunService = game:GetService("RunService")
local NotificationSystem = require(script.Parent.Parent.utils.notifications)
local Settings = require(script.Parent.Parent.core.settings)

local PlotMonitor = {}
local PlotOverlays = {}
local PlotMonitorConnection = nil
local PlotDebugCount = 0

function PlotMonitor.GetAllPlots()
    local plots = {}
    local plotsFolder = workspace:FindFirstChild("Plots")

    if not plotsFolder then
        return plots
    end

    for _, child in pairs(plotsFolder:GetChildren()) do
        if child:IsA("Model") then
            table.insert(plots, child)
        end
    end

    return plots
end

function PlotMonitor.FindLockData(plot)
    local success, result = pcall(function()
        local purchases = plot:FindFirstChild("Purchases")
        if not purchases then
            return nil
        end

        local plotBlock = purchases:FindFirstChild("PlotBlock")
        if not plotBlock then
            return nil
        end

        local main = plotBlock:FindFirstChild("Main")
        if not main then
            return nil
        end

        local billboardGui = main:FindFirstChild("BillboardGui")
        if not billboardGui then
            return nil
        end

        local locked = billboardGui:FindFirstChild("Locked")
        if not locked then
            return nil
        end

        return locked.Visible
    end)

    if success and result ~= nil then
        return result
    else
        return nil
    end
end

function PlotMonitor.FindTimeData(plot)
    local success, result = pcall(function()
        local purchases = plot:FindFirstChild("Purchases")
        if not purchases then
            return nil
        end

        local plotBlock = purchases:FindFirstChild("PlotBlock")
        if not plotBlock then
            return nil
        end

        local main = plotBlock:FindFirstChild("Main")
        if not main then
            return nil
        end

        local billboardGui = main:FindFirstChild("BillboardGui")
        if not billboardGui then
            return nil
        end

        local remainingTime = billboardGui:FindFirstChild("RemainingTime")
        if not remainingTime then
            return nil
        end

        return remainingTime.Text
    end)

    if success and result then
        return result
    else
        return nil
    end
end

function PlotMonitor.ProcessTimeText(timeText)
    if not timeText or timeText == "" then
        return 0
    end

    local seconds = 0

    if timeText:find(":") then
        local min, sec = timeText:match("(%d+):(%d+)")
        if min and sec then
            seconds = (tonumber(min) or 0) * 60 + (tonumber(sec) or 0)
        end
    else
        local num = timeText:match("%d+")
        if num then
            seconds = tonumber(num) or 0
        end
    end

    return seconds
end

function PlotMonitor.FindValidPart(plot)
    if plot:IsA("BasePart") then
        return plot
    end

    for _, child in pairs(plot:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end

    for _, child in pairs(plot:GetChildren()) do
        if child:IsA("Model") or child:IsA("Folder") then
            for _, subChild in pairs(child:GetChildren()) do
                if subChild:IsA("BasePart") then
                    return subChild
                end
            end
        end
    end

    return nil
end

function PlotMonitor.CreatePlotOverlay(plot)
    local anchorPart = PlotMonitor.FindValidPart(plot)

    if not anchorPart then
        return nil
    end

    local success, overlay = pcall(function()
        local existing = anchorPart:FindFirstChild("TimeMonitorGUI")
        if existing then
            existing:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "TimeMonitorGUI"
        billboard.Size = UDim2.new(30, 0, 18, 0)
        billboard.StudsOffset = Vector3.new(0, 12, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 800
        billboard.LightInfluence = 0
        billboard.Parent = anchorPart

        local bgFrame = Instance.new("Frame")
        bgFrame.Size = UDim2.new(1, 0, 1, 0)
        bgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        bgFrame.BackgroundTransparency = 0.1
        bgFrame.BorderSizePixel = 4
        bgFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
        bgFrame.Parent = billboard

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = bgFrame

        local headerLabel = Instance.new("TextLabel")
        headerLabel.Size = UDim2.new(1, -10, 0.25, 0)
        headerLabel.Position = UDim2.new(0, 5, 0, 5)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Text = "NEXUS HUB"
        headerLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        headerLabel.TextScaled = true
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextStrokeTransparency = 0
        headerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        headerLabel.Parent = bgFrame

        local separator = Instance.new("Frame")
        separator.Size = UDim2.new(0.9, 0, 0.02, 0)
        separator.Position = UDim2.new(0.05, 0, 0.28, 0)
        separator.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        separator.BorderSizePixel = 0
        separator.Parent = bgFrame

        local separatorCorner = Instance.new("UICorner")
        separatorCorner.CornerRadius = UDim.new(0, 2)
        separatorCorner.Parent = separator

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -10, 0.35, 0)
        statusLabel.Position = UDim2.new(0, 5, 0.35, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "LOADING"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextStrokeTransparency = 0
        statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        statusLabel.Parent = bgFrame

        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(1, -10, 0.25, 0)
        timeLabel.Position = UDim2.new(0, 5, 0.72, 0)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = ""
        timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timeLabel.TextScaled = true
        timeLabel.Font = Enum.Font.GothamBold
        timeLabel.TextStrokeTransparency = 0
        timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        timeLabel.Visible = false
        timeLabel.Parent = bgFrame

        return {
            gui = billboard,
            statusLabel = statusLabel,
            timeLabel = timeLabel,
            headerLabel = headerLabel,
            plot = plot
        }
    end)

    if success and overlay then
        return overlay
    else
        warn("Nexus: Falha ao criar overlay para plot:", plot and plot.Name or "unknown")
        return nil
    end
end

function PlotMonitor.UpdatePlotOverlay(overlay)
    if not overlay or not overlay.gui or not overlay.gui.Parent then
        return false
    end

    local plot = overlay.plot
    local isLocked = PlotMonitor.FindLockData(plot)
    local timeText = PlotMonitor.FindTimeData(plot)

    if isLocked == nil then
        overlay.statusLabel.Text = "⚠ NO DATA"
        overlay.statusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
        overlay.timeLabel.Text = "Path Error"
        overlay.timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        overlay.timeLabel.Visible = true
        return true
    end

    if isLocked then
        overlay.statusLabel.Text = "🔒 LOCKED"
        overlay.statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

        if timeText then
            local seconds = PlotMonitor.ProcessTimeText(timeText)

            if seconds > 0 then
                if seconds >= 60 then
                    local min = math.floor(seconds / 60)
                    local sec = seconds % 60
                    overlay.timeLabel.Text = string.format("%d:%02d", min, sec)
                else
                    overlay.timeLabel.Text = tostring(seconds) .. "s"
                end
                overlay.timeLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            else
                overlay.timeLabel.Text = "0s"
                overlay.timeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            overlay.timeLabel.Visible = true
        else
            overlay.timeLabel.Visible = false
        end

    else
        overlay.statusLabel.Text = "🔓 UNLOCKED"
        overlay.statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        overlay.timeLabel.Visible = false
    end

    return true
end

function PlotMonitor.UpdateAllPlotOverlays()
    PlotDebugCount = PlotDebugCount + 1
    local plots = PlotMonitor.GetAllPlots()

    for _, plot in pairs(plots) do
        local plotId = plot.Name

        if not PlotOverlays[plotId] then
            PlotOverlays[plotId] = PlotMonitor.CreatePlotOverlay(plot)
        end

        if PlotOverlays[plotId] then
            local success = PlotMonitor.UpdatePlotOverlay(PlotOverlays[plotId])
            if not success then
                PlotOverlays[plotId] = PlotMonitor.CreatePlotOverlay(plot)
            end
        end
    end

    if PlotDebugCount % 300 == 0 then
        local currentPlots = {}
        for _, plot in pairs(plots) do
            currentPlots[plot.Name] = true
        end

        for plotId, overlay in pairs(PlotOverlays) do
            if not currentPlots[plotId] then
                if overlay and overlay.gui then
                    overlay.gui:Destroy()
                end
                PlotOverlays[plotId] = nil
            end
        end
    end
end

function PlotMonitor.Setup(enabled)
    if PlotMonitorConnection then
        PlotMonitorConnection:Disconnect()
        PlotMonitorConnection = nil
    end

    if enabled then
        local success = pcall(function()
            if NotificationSystem and NotificationSystem.Create then
                NotificationSystem.Create("ESP Base", "Plot monitor activated! View real-time status.", "success", 4)
            end
        end)

        if not success then
            -- Fallback notification
            print("ESP Base: Sistema ativado!")
        end

        PlotMonitorConnection = RunService.Heartbeat:Connect(function()
            if Settings.Config.PlotMonitorEnabled then
                pcall(PlotMonitor.UpdateAllPlotOverlays)
            end
        end)

        task.spawn(function()
            task.wait(1)
            pcall(PlotMonitor.UpdateAllPlotOverlays)
        end)

    else
        for plotId, overlay in pairs(PlotOverlays) do
            if overlay and overlay.gui then
                pcall(function()
                    overlay.gui:Destroy()
                end)
            end
        end

        PlotOverlays = {}
        PlotDebugCount = 0

        local success = pcall(function()
            if NotificationSystem and NotificationSystem.Create then
                NotificationSystem.Create("ESP Base", "Sistema de monitoramento desativado.", "warning")
            end
        end)

        if not success then
            print("ESP Base: System deactivated.")
        end
    end
end

return PlotMonitor
