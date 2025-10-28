# XP Tracker - Classic MoP

## What this addon does

**XP Tracker - Classic MoP** displays your current experience rate (XP per hour), estimated time to the next level, session duration, and other helpful stats directly on your screen. It provides pause/reset controls, a configuration panel with color and alignment options, and automatically saves settings between sessions. Works across multiple World of Warcraft versions.

## 🌍 Multilingual Support

This addon is available in multiple languages and automatically detects your game client language!

🇬🇧 English | 🇫🇷 Français | 🇩🇪 Deutsch | 🇪🇸 Español | 🇮🇹 Italiano <br>
🇵🇹 Português | 🇷🇺 Русский | 🇰🇷 한국어 | 🇨🇳 简体中文 | 🇹🇼 繁體中文

---

## Settings Persistence

### How It Works

All your settings (colors, alignment) are **automatically saved** in the global variable `XPTrackerSettings`.

### Save File Location

Settings are stored in:
```
World of Warcraft/_classic_/WTF/Account/[YOUR_ACCOUNT]/SavedVariables/XPTracker.lua
```

### ⚠️ IMPORTANT: For Settings to Be Saved

WoW saves variables **ONLY** when you logout properly:

✅ **YES - Saves settings:**
- Click "Logout" in System menu
- Use `/logout` or `/exit` command
- Quit via the game's "Exit" button

❌ **NO - Does NOT save:**
- Closing WoW with Alt+F4
- Game crash
- Killing process (Task Manager)
- Power outage

### Check Your Settings

Use the debug command to see your current settings:
```
/xpt debug
```

### Available Commands

```
/xpt config      - Open configuration panel
/xpt debug       - Display current settings
/xpt reset       - Reset XP statistics
/xpt pause       - Pause tracking
/xpt start       - Resume tracking
/xpt hide        - Hide addon
/xpt show        - Show addon
```

## Reset All Settings

### Option 1: Via Interface
1. `/xpt config`
2. Click the "Reset to Defaults" button

### Option 2: Manually
1. Close WoW completely
2. Delete the file: `WTF/Account/[YOUR_ACCOUNT]/SavedVariables/XPTracker.lua`
3. Restart WoW

## Saved Settings

- **Text alignment**: LEFT, CENTER, or RIGHT
- **7 customizable colors**:
  - "XP/h:" label
  - XP/h value
  - "Level X:" label
  - Time remaining value
  - "Time:" label
  - Session time value
  - "Max level reached" text

## Features

### Main Display
- **XP/h Rate** - Real-time experience per hour calculation
- **Time to Next Level** - Estimated time remaining
- **Session Time** - Total tracking time
- **Dynamic Level Detection** - Works with all WoW versions (Classic, TBC, WotLK, Retail, etc.)

### Control Buttons
- **⏸️ Pause/▶️ Play** - Pause/resume tracking
- **⏹️ Reset** - Reset session statistics
- **⚙️ Config** - Open configuration panel

### Configuration Panel
- **Text Alignment** - Left, Center, or Right
- **Color Customization** - 7 independent color pickers
  - Labels (XP/h, Level, Time)
  - Values (rates, durations)
  - Max level message
- **Real-time Preview** - See changes instantly
- **Reset to Defaults** - One-click restore

### Auto-Reset Features
- Automatically resets on level up
- Asks for confirmation when entering/exiting dungeons

## Troubleshooting

If you encounter problems:
1. Check with `/xpt debug`
2. Try `/reload` to reload the interface
3. Verify the TOC file contains: `## SavedVariables: XPTrackerSettings`
4. Check that Config.lua is loaded with `/xpt config`

## Share Your Settings

To copy your settings to another character:
1. Copy the file `WTF/Account/[ACCOUNT]/SavedVariables/XPTracker.lua`
2. Paste it in `WTF/Account/[ACCOUNT]/[SERVER]/[CHARACTER]/SavedVariables/`

Or copy directly for all characters:
- The file in `Account/[ACCOUNT]/SavedVariables/` applies to ALL characters

## Credits

**Author:** [@vlldnt](https://github.com/vlldnt)
**Version:** 1.0
