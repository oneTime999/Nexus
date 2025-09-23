-- Theme System
-- src/gui/themes.lua

local Themes = {}

Themes.Dark = {
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

Themes.Light = {
    Background = Color3.fromRGB(245, 245, 250),
    Secondary = Color3.fromRGB(235, 235, 245),
    Tertiary = Color3.fromRGB(220, 220, 235),
    Accent = Color3.fromRGB(66, 133, 244),
    AccentHover = Color3.fromRGB(86, 153, 255),
    Success = Color3.fromRGB(34, 139, 34),
    Danger = Color3.fromRGB(220, 53, 69),
    Warning = Color3.fromRGB(255, 193, 7),
    Text = Color3.fromRGB(33, 37, 41),
    TextSecondary = Color3.fromRGB(108, 117, 125),
    Border = Color3.fromRGB(200, 200, 210)
}

Themes.Neon = {
    Background = Color3.fromRGB(10, 10, 15),
    Secondary = Color3.fromRGB(15, 15, 25),
    Tertiary = Color3.fromRGB(20, 20, 35),
    Accent = Color3.fromRGB(0, 255, 255),
    AccentHover = Color3.fromRGB(50, 255, 255),
    Success = Color3.fromRGB(0, 255, 127),
    Danger = Color3.fromRGB(255, 20, 147),
    Warning = Color3.fromRGB(255, 215, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 255, 255),
    Border = Color3.fromRGB(0, 255, 255)
}

Themes.Purple = {
    Background = Color3.fromRGB(25, 15, 35),
    Secondary = Color3.fromRGB(35, 25, 45),
    Tertiary = Color3.fromRGB(45, 35, 55),
    Accent = Color3.fromRGB(147, 112, 219),
    AccentHover = Color3.fromRGB(167, 132, 239),
    Success = Color3.fromRGB(102, 187, 106),
    Danger = Color3.fromRGB(239, 83, 80),
    Warning = Color3.fromRGB(255, 183, 77),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(190, 190, 210),
    Border = Color3.fromRGB(147, 112, 219)
}

-- Function to get theme by name
function Themes.GetTheme(themeName)
    return Themes[themeName] or Themes.Dark
end

-- Function to get all available theme names
function Themes.GetAvailableThemes()
    return {"Dark", "Light", "Neon", "Purple"}
end

-- Function to validate if theme exists
function Themes.ThemeExists(themeName)
    return Themes[themeName] ~= nil
end

return Themes
