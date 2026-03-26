# Echoly

A lightweight, purely native, always-on-top floating teleprompter for macOS, built with Swift and SwiftUI.

Echoly is designed for creators, presenters, and professionals who need to keep their script or notes visible on screen while recording videos or taking video calls. It floats seamlessly above all other windows and offers advanced control over scrolling, styling, and presence.

## Core Features

- **Natively Floating:** The prompter window continuously stays above all other applications natively using AppKit's `.floating` window level.
- **Stealth Mode (Screen Share Isolation):** Hide the teleprompter entirely from Zoom, Google Meet, or OBS screen captures simply by enabling the "Hide app from screen sharing" option in Settings.
- **Glassmorphism UI:** Built using macOS native Visual Effect views for a beautifully blurred, translucent background.
- **Script Support:** Load scripts securely and natively from standard `.txt` files or directly parse Microsoft Word `.docx` documents instantly across the app.

## Advanced Controls

- **Auto Continuous Scrolling:** Pixel-perfect smooth scrolling engine using internal Timers.
- **Manual Stepped Scrolling:** Need precision? Switch to Manual mode and use your `Enter` or `Return` keys to discrete jump text by customizable increments (1, 3, or 5 lines).
- **Customizable Typography:** Adjust text size on the fly for perfect readability and tweak global Line Spacing via Settings.
- **Theming & Preferences:** Choose between Light, Dark, or System Default themes. Settings are durably persisted across sessions so Echoly remembers your workflow.

## Keyboard Shortcuts

- **Spacebar**: Play/Pause continuous scrolling (Auto mode only).
- **Enter/Return**: Manually scroll down (Manual mode only).
- **Up Arrow**: Increase the continuous scroll speed.
- **Down Arrow**: Decrease the continuous scroll speed.

## Prerequisites

- macOS 11.0 (Big Sur) or newer.
- Swift compiler (included with Xcode Command Line Tools).

## How to Build and Run

1. Clone or download this project folder.
2. Open your Terminal and navigate to the project directory:
   ```bash
   cd /path/to/Echoly
   ```
3. Run the provided build script:
   ```bash
   bash build_app.sh
   ```
4. The script cleanly compiles the domain-separated Swift files and packages an `Echoly.app` bundle right in the project folder.
5. Double click `Echoly.app` or run `open Echoly.app` in your terminal to launch the teleprompter!

## Usage Guide

1. Launch **Echoly**.
2. Click the **Folder Icon** to load your `.txt` or `.docx` script.
3. Click the **Gear Icon** to customize your theme, line spacing, layout, and stealth configurations. Be sure to hit `Save`.
4. Position the window just beneath your webcam!
5. Depending on your Settings, use `Spacebar` to auto-scroll or `Return` to jump lines manually. Enjoy!
