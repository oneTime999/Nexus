-- Nexus Settings Configuration
local Settings = {}

_G.NexusSettings = _G.NexusSettings or {
    AimbotEnabled = false,
    ESPEnabled = false,
    PlotMonitorEnabled = false,
    Version = "1.1",
    Theme = "Dark"
}

local Theme = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 28),
        Secondary = Color3.fromRGB(28, 28, 42),
        Tertiary = Color3.fromRGB(35, 35, 52),
        Accent = Color3.fromRGB(88, 166, 255),
        AccentHover = Color3.fromRGB(108, 186, 255),
        Success = Color3.fromRGB(46, 204, 113),
        Danger = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        Border = Color3.fromRGB(55, 55, 75)
    }
}

Settings.GetCurrentTheme = function()
    return Theme[_G.NexusSettings.Theme] or Theme.Dark
end

Settings.Theme = Theme
Settings.Config = _G.NexusSettings

return Settings
