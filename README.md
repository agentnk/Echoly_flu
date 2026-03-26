# Echoly

A lightweight, purely native, always-on-top floating teleprompter for macOS, built with Swift and SwiftUI.

Designed for creators, presenters, and professionals who need their script visible while recording videos, taking video calls, or presenting. Echoly floats seamlessly above all windows with advanced scrolling, styling, and privacy controls.

## Features

### Core
- **Always On Top** — Natively floating window that stays above all apps.
- **Glassmorphism UI** — macOS native translucent blur background.
- **Mirror / Flip Mode** — Horizontally flip text for physical teleprompter rigs (beam splitter glass).
- **Stealth Mode** — Hide from Zoom, Google Meet, OBS, and all screen capture software.

### Scrolling
- **Auto Scroll** — Continuous pixel-perfect smooth scrolling with adjustable speed.
- **Manual Scroll** — Step through your script line-by-line using Enter/Return key.
- **Countdown Timer** — 3-2-1 countdown before auto-scrolling begins.
- **Speed Indicator** — Live display of current scroll speed in the toolbar.
- **Progress Bar** — Thin bar at the bottom showing how far through the script you are.
- **Reset Button** — Instantly rewind to the top of your script.

### Editor
- **Inline Editing** — Edit your script directly inside the prompter without an external editor.
- **Drag & Drop** — Drop `.txt` or `.docx` files directly onto the window to load them.
- **DOCX Support** — Natively parse Microsoft Word documents using macOS text engine.
- **Recent Files** — Quick access to your last 5 opened scripts from Settings.

### Customization
- **Themes** — Switch between System Default, Light, and Dark modes.
- **Font Size** — Adjust text size on the fly with A-/A+ buttons.
- **Line Spacing** — Fine-tune text density via slider.
- **Window Opacity** — Control the transparency of the entire window.
- **Persistent Settings** — All preferences are saved across sessions.

## Keyboard Shortcuts

| Shortcut         | Action                              |
|------------------|-------------------------------------|
| `Spacebar`       | Play/Pause auto-scroll              |
| `Enter/Return`   | Manual scroll (in manual mode)      |
| `Up Arrow`       | Increase scroll speed               |
| `Down Arrow`     | Decrease scroll speed               |

## Prerequisites

- macOS 11.0 (Big Sur) or newer
- Swift compiler (included with Xcode Command Line Tools)

## Build & Run

```bash
cd /path/to/Echoly
bash build_app.sh
open Echoly.app
```

## Project Structure

```
Echoly/
├── EcholyApp.swift        # App lifecycle & window config
├── ContentView.swift      # Main prompter interface
├── SettingsView.swift     # Settings panel & window manager
├── VisualEffectView.swift # Native blur background
├── AppTheme.swift         # Theme enum
├── build_app.sh           # Compile & package script
├── make_app_icon.sh       # Icon generator script
└── README.md
```
