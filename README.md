# Echoly

A lightweight, purely native, always-on-top floating teleprompter for macOS, built with Swift and SwiftUI.

Echoly is designed for creators, presenters, and professionals who need to keep their script or notes visible on screen while recording videos or taking video calls. It floats seamlessly above all other windows and offers smooth continuous scrolling.

## Features

- **Always On Top:** The prompter window continuously stays above all other applications.
- **Native Look & Feel:** Uses macOS native Visual Effect views for a beautifully blurred, translucent background.
- **Continuous Scrolling:** Pixel-perfect smooth scrolling engine.
- **Customizable Font Size:** Adjust text size on the fly for perfect readability at a distance.
- **Plain Text Support:** Easily load your scripts from standard `.txt` files.

## Keyboard Shortcuts

- **Spacebar**: Play/Pause scrolling.
- **Up Arrow**: Increase the scroll speed.
- **Down Arrow**: Decrease the scroll speed.

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
4. The script compiles the application and generates an `Echoly.app` bundle in the same folder.
5. Double click `Echoly.app` or run `open Echoly.app` in your terminal to launch the teleprompter!

## How to Use

1. Launch **Echoly**.
2. Click the **Folder Icon** in the top left to select your `.txt` script.
3. Position the window wherever you want on your screen (e.g., just beneath your webcam).
4. Use the `A+` and `A-` buttons to adjust the text size.
5. Press the **Play Icon** or hit the **Spacebar** to begin scrolling!
