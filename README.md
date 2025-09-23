# Nexus 1.1 - Advanced Game Utility Hub

Nexus is a comprehensive utility script for Roblox games, featuring advanced ESP systems, aimbot functionality, plot monitoring, and animal tracking capabilities.

## ⚡ Features

### Core Features
- **ESP Player System**: Reveals invisible players and displays names with distance information
- **Advanced Aimbot**: Multi-platform targeting system with intelligent closest-player detection
- **Plot Monitor (ESP Base)**: Real-time plot status monitoring with lock/unlock detection
- **Self-Kick System**: Safe server disconnection with custom messages

### Animal Monitor System
- **Best Overall**: Displays the best animal on the server (regardless of rarity/mutation)
- **Best Lucky Block**: Shows the best Lucky Block animals (by time)
- **Best Secret**: Tracks the best Secret animals
- **Best Brainrot God**: Monitors the best Brainrot God animals
- **Multi-category ESP**: Real-time overlays for each category

### User Interface
- Modern dark theme with smooth animations
- Draggable and resizable interface
- Mobile, PC, and Console compatibility
- Real-time notifications system
- Customizable settings

## 🚀 Installation

### Method 1: Direct Execution
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/doone99/Nexus/main/src/main.lua"))()
```

### Method 2: Manual Installation
1. Download all files from the repository
2. Place them in your executor's script folder maintaining the directory structure
3. Execute `main.lua`

## 🎮 Controls & Keybinds

- **Right Control**: Toggle main interface
- **Right Shift**: Quick kick (3-second countdown)
- **G**: Toggle ESP Player system
- **P**: Toggle Plot Monitor

## 📁 File Structure

```
Nexus/
├── src/
│   ├── core/
│   │   ├── init.lua         # Main initialization
│   │   ├── settings.lua     # Configuration & themes
│   │   └── security.lua     # Security & anti-detection
│   ├── utils/
│   │   ├── utils.lua        # Utility functions
│   │   ├── animations.lua   # Animation system
│   │   └── notifications.lua # Notification system
│   ├── gui/
│   │   ├── main_interface.lua # Main GUI components
│   │   └── components.lua     # Reusable GUI elements
│   ├── features/
│   │   ├── aimbot.lua       # Aimbot system
│   │   ├── esp.lua          # ESP functionality
│   │   ├── plot_monitor.lua # Plot monitoring
│   │   ├── animal_monitor.lua # Animal tracking
│   │   └── self_kick.lua    # Self-kick feature
│   └── main.lua             # Entry point
├── README.md
├── LICENSE
└── .gitignore
```

## 🛠️ Development

### Adding New Features
1. Create a new file in `src/features/`
2. Follow the existing module pattern
3. Import and integrate in `src/core/init.lua`
4. Add UI components as needed

### Modifying Themes
Edit the `Theme` table in `src/core/settings.lua` to customize colors and styling.

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes following the existing code style
4. Test thoroughly
5. Submit a pull request

## ⚠️ Important Notes

- This script is for educational purposes
- Use responsibly and respect game rules
- Some features may not work in all games
- Always test in a safe environment first

## 🔧 Compatibility

### Platforms
- ✅ PC (Windows/Mac/Linux)
- ✅ Mobile (Android/iOS)
- ✅ Console (Xbox)

### Executors
- Synapse X
- Krnl
- Script-Ware
- Fluxus
- Other Lua executors

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Credits

- **Author**: do_one99
- **Version**: 1.1
- **Last Updated**: 2024

## 🐛 Bug Reports

If you encounter any issues:
1. Check the console for error messages
2. Verify you're using the latest version
3. Open an issue on GitHub with details

## 🔄 Updates

Stay updated with the latest features and fixes by watching this repository or checking the releases page.

---

**Disclaimer**: This software is provided as-is. Use at your own risk and discretion.
