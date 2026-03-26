# Echoly

A lightweight, purely native, always-on-top floating teleprompter for macOS, built with Swift and SwiftUI.

Designed for creators, presenters, and professionals who need their script visible while recording videos, taking calls, or presenting live.

## Features

### Core
- **Always On Top** — Native floating window that stays above all apps
- **Glassmorphism UI** — Translucent blur background using macOS Visual Effects
- **Menu Bar Icon** — Show/hide Echoly from the menu bar without switching apps
- **Window Memory** — Remembers position and size between launches

### Scrolling
- **Auto Scroll** — Continuous smooth scrolling with adjustable speed
- **Manual Scroll** — Step through your script using Enter/Return key
- **Speed Presets** — Quick-apply Slow (0.5×), Normal (1.0×), or Fast (2.0×)
- **Countdown Timer** — 3-2-1 countdown before auto-scroll begins
- **Progress Bar** — Visual position indicator at the bottom
- **Reset Button** — Instantly rewind to top

### Professional
- **Cue Markers** — `[PAUSE]`, `[SLOW]`, `[CUE]` render as highlighted inline tags
- **Auto-Pause** — Scrolling stops automatically at `[PAUSE]` markers
- **Mirror Mode** — Flip text horizontally for physical teleprompter rigs
- **Stealth Mode** — Hide from Zoom, Meet, OBS, and all screen capture

### Editor & Files
- **Inline Editing** — Edit scripts directly inside the prompter
- **Drag & Drop** — Drop `.txt` or `.docx` files onto the window
- **DOCX Support** — Native Microsoft Word document parsing
- **Recent Files** — Quick access to last 5 opened scripts
- **Export to PDF** — Save your script as a formatted PDF
- **Word Count & Read Time** — Live stats in the footer

### Customization
- **Themes** — System Default, Light, or Dark
- **Font Family** — Monospaced, Serif, or Sans-serif
- **Text Alignment** — Left, Center, or Right
- **Font Size** — Adjustable on the fly
- **Line Spacing** — Fine-tune text density
- **Window Opacity** — Control transparency (30–100%)
- **High Contrast** — For bright studio environments

## Keyboard Shortcuts

| Shortcut       | Action                         |
|----------------|--------------------------------|
| `Spacebar`     | Play / Pause auto-scroll       |
| `Enter/Return` | Manual scroll (manual mode)    |
| `↑`            | Increase speed                 |
| `↓`            | Decrease speed                 |
| `⌘Z`          | Undo (edit mode)               |
| `⌘⇧Z`        | Redo (edit mode)               |

## Requirements

- macOS 11.0+
- Xcode Command Line Tools

## Build & Run

```bash
cd /path/to/Echoly
bash build_app.sh
open Echoly.app
```

## Project Structure

```
Echoly/
├── EcholyApp.swift        # App lifecycle, window config, menu bar
├── ContentView.swift      # Prompter UI, scrolling, cue system
├── SettingsView.swift     # Settings panel & window manager
├── VisualEffectView.swift # Native blur background
├── AppTheme.swift         # Theme enum
├── build_app.sh           # Compile & package script
└── README.md
```
