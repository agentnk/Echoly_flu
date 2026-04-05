# Echoly

A professional-grade, native macOS teleprompter designed for creators, built with Swift and SwiftUI.

Echoly is a lightweight, always-on-top floating teleprompter that helps you deliver flawless presentations, record videos, or host live calls with confidence. It features a modernized, web-inspired interface with high-performance rendering and professional cue management.

## Key Features

### 🎨 Modernized UI & Experience
- **Active Focus Mask** — A dynamic linear gradient that fades non-active text, keeping your eyes focused on the current script segment.
- **Reading Zone Indicators** — Built-in side markers to help you maintain consistent eye-tracking during long scripts.
- **Glassmorphism Design** — A native macOS translucent blur background that adapts to your theme and environment.
- **Always-On-Top** — Stays pinned above all other applications, including Zoom, Meet, and OBS.
- **Stealth Mode** — Automatically hides the prompter window from all screen capture and screen sharing software.

### 📜 Intelligent Scrolling
- **Smooth Auto-Scroll** — Fluid, jitter-free scrolling with granular speed control.
- **Manual Advance** — Step through your script line-by-line using the `Enter/Return` key.
- **Speed Presets** — Save and quickly apply your favorite scrolling speeds for different script types.
- **Countdown Timer** — Customizable 3-2-1 visual countdown before scrolling begins.

### 🎭 Professional Cue System
- **Inline Cue Tags** — Automatically detects and highlights `[PAUSE]`, `[SLOW]`, and `[CUE]` tags.
- **Dynamic Events** — Cues trigger real-time events:
    - `[PAUSE]` — Instantly stops the auto-scroll.
    - `[SLOW]` — Temporarily reduces scroll speed by 50%.
    - `[CUE]` — Restores speed and triggers a brief visual flash alert.

### ⚙️ Full Customization
- **Typography** — Choose between Monospaced, Serif, and Sans-Serif fonts with adjustable size and line spacing.
- **Appearance** — Native Light, Dark, and High-Contrast modes.
- **Window Control** — Adjust window opacity (30% to 100%) and flip text horizontally for mirror-rig setups.

### 📂 File Management
- **Universal Drop** — Drag and drop `.txt` or `.docx` files directly onto the window.
- **Recent Scripts** — Quick access to your last 5 opened scripts from the menu bar or settings.
- **PDF Export** — Export your finalized script into a professionally formatted PDF.

---

## Keyboard Shortcuts

| Shortcut       | Action                         |
|----------------|--------------------------------|
| `Spacebar`     | Play / Pause auto-scroll       |
| `Enter/Return` | Manual scroll (Manual mode)    |
| `↑`            | Increase speed                 |
| `↓`            | Decrease speed                 |
| `⌘Z` / `⌘⇧Z`   | Undo / Redo (Editor mode)      |

---

## Build & Installation

To build Echoly from source, ensure you have **Xcode Command Line Tools** installed.

```bash
git clone https://github.com/yourusername/Echoly.git
cd Echoly
bash build_app.sh
open Echoly.app
```

---

## Project Structure

```text
Echoly/
├── EcholyApp.swift         # App lifecycle, window configuration, and global hotkeys
├── ContentView.swift       # Primary prompter view, UI layout, and focus mask
├── PrompterViewModel.swift # Encapsulated MVVM logic handling timers, states, and scroll behaviors
├── ScriptParser.swift      # Regex parser for cue tags and attributed text segments
├── DocumentHandler.swift   # File I/O for .txt and .docx (Microsoft Word) support
├── PDFExporter.swift       # Native Quartz rendering for script-to-PDF export
├── SettingsView.swift      # Settings panel, speed preset manager, and window manager
├── AppTheme.swift          # Centralized theme enum and color scheme definitions
├── PrompterToolbar.swift   # Top toolbar with playback controls and font size picker
├── PrompterFooter.swift    # Recording-style footer with word count and progress bar
├── build_app.sh            # Automated build and packaging script
└── README.md
```
