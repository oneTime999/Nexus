local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NexusLibrary = {}

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
        Text = "_",
        TextColor3 = theme.text,
        TextSize = 16
    })
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton
    
    minimizeButton.MouseButton1Click:Connect(function()
        mainWindow.Visible = false
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
    
    -- Tab container
    local tabFrame = createFrame(mainWindow, {
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = theme.secondary,
        BorderSizePixel = 0
    })
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabFrame
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
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
        
        return Tab
    end
    
    -- Keybind to toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    
    return Window
end

return NexusLibrary
