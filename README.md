# Linux Clipboard Manager
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)
![Version](https://img.shields.io/badge/version-0.1.1-green.svg)

A lightweight, GUI-based clipboard manager for Linux that simulates Windows 11's clipboard history functionality (Win + V). Store, view, and reuse your last 25 clipboard entries with ease.

![Clipboard Manager Main Interface](./docs/images/main-interface.png)
> [!NOTE]
> Screenshot placeholder: Add screenshot of main interface

## Features

- 📋 Stores last 25 clipboard entries (configurable)
- 🕒 Timestamps for each clipboard entry
- 🔄 Real-time clipboard monitoring
- 🖥️ GUI interface using Zenity
- 💾 Persistent storage using SQLite
- 🔒 Thread-safe operations
- 🗑️ Easy cleanup of clipboard history
- 🎯 System tray integration (optional)

## Installation

### Prerequisites

The script will automatically check and install these dependencies if missing:
- zenity
- xclip
- sqlite3
- yad (optional, for system tray icon)

### Quick Install 

## Licensing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third Party Software
This project uses several open-source components:
- SQLite (Public Domain)
- Zenity (LGPL-2.1+)
- XClip (GPL-2.0)
- YAD (GPL-3.0, optional dependency)

For full license texts and details, see [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)

## Keyboard Shortcuts Setup

### Pop!_OS
1. Open Settings
2. Navigate to "Keyboard"
3. Scroll to bottom and click "View and Customize Shortcuts"
4. Click "+" at bottom to add custom shortcut
5. Fill in:
   - Name: "Clipboard Manager"
   - Command: `/path/to/clipboard_manager.sh --show-history`
   - Shortcut: Press "Win + V" (or your preferred combination)

### Ubuntu
1. Open Settings
2. Go to "Keyboard"
3. Scroll to "Keyboard Shortcuts"
4. Click "+" under "Custom Shortcuts"
5. Fill in:
   - Name: "Clipboard Manager"
   - Command: `/path/to/clipboard_manager.sh --show-history`
   - Click "Set Shortcut" and press "Win + V" (or your preferred combination)

> **Note**: Replace `/path/to/` with the actual path where you installed the script. If you installed it system-wide, the path would be `/usr/local/bin/clipboard-manager`

### Command Line Setup (Alternative)
You can also set up the keyboard shortcut via terminal: