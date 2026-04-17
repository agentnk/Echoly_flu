# Echoly

A professional-grade, native macOS teleprompter designed for creators, built with Swift and SwiftUI.

Echoly is a lightweight, always-on-top floating teleprompter that helps you deliver flawless presentations, record videos, or host live calls with confidence. It features a premium, glassmorphic interface with high-performance rendering and professional rich text support.

## Key Features

### 🎨 Premium UI & Experience
- **Rich Text Support (RTF/RTFD)** — Apply Bold, Italic, and color highlights to your scripts. Echoly preserves formatting during playback and PDF export.
- **Active Focus Mask** — A natural linear gradient that fades non-active text, keeping your eyes locked on the current script segment.
- **Deep Glassmorphism** — Integrates native macOS material effects (`NSVisualEffectView`) for a translucent background that adapts beautifully to your environment.
- **Compact Mode** — A distraction-free experience where the toolbar and footer smoothly fade out during playback to maximize focus.
- **Reading Zone Indicators** — Elegant, blurred side markers to help you maintain consistent eye-tracking.
- **Indigo Design System** — A curated, modern color palette and typography stack designed for professional studio environments.

### 📜 Intelligent Scrolling
- **Smooth Auto-Scroll** — Fluid, jitter-free scrolling with granular speed control.
- **Manual Advance** — Step through your script line-by-line using the `Enter/Return` key.
- **Countdown Timer** — Sophisticated 3-2-1 visual countdown with scale animations before scrolling begins.
- **Stealth Mode** — Automatically hides the prompter window from all screen capture and screen sharing software.

### 🎭 Professional Cue System
- **Inline Cue Tags** — Automatically detects and highlights `[PAUSE]`, `[SLOW]`, and `[CUE]` tags, even within formatted rich text.
- **Dynamic Events** — Cues trigger real-time events:
    - `[PAUSE]` — Instantly stops the auto-scroll.
    - `[SLOW]` — Temporarily reduces scroll speed by 50%.
    - `[CUE]` — Restores speed and triggers a brief visual flash alert.

### ⚙️ Full Customization
- **Typography** — Choose between Monospaced, Serif, and Sans-Serif fonts with adjustable size and line spacing.
- **Appearance** — Native Light, Dark, and High-Contrast modes with fluid transitions.
- **Window Control** — Adjust window opacity (30% to 100%) and flip text horizontally for mirror-rig setups.

---

## Keyboard Shortcuts

| Shortcut       | Action                         |
|----------------|--------------------------------|
| `Spacebar`     | Play / Pause auto-scroll       |
| `Enter/Return` | Manual scroll (Manual mode)    |
| `Cmd + B`      | Toggle Bold (Editor Mode)      |
| `Cmd + I`      | Toggle Italic (Editor Mode)    |
| `↑`            | Increase speed                 |
| `↓`            | Decrease speed                 |

---

## Project Structure

```text
Echoly/
├── EcholyApp.swift          # App lifecycle, window configuration, and global hotkeys
├── ContentView.swift        # Primary layout and global state management
├── PrompterDisplayView.swift # Core prompter rendering, focus mask, and animations
├── PrompterViewModel.swift  # MVVM logic handling timers, states, and scroll behaviors
├── RichTextEditor.swift     # Custom SwiftUI wrapper for Rich Text editing (NSTextView)
├── ScriptParser.swift       # Regex parser for cue tags and NSAttributedString handling
├── DocumentHandler.swift    # File I/O for .txt, .docx, .rtf, and .rtfd support
├── PDFExporter.swift        # Native Quartz rendering for formatted script-to-PDF
├── SettingsView.swift       # Settings panel and speed preset manager
├── AppTheme.swift           # Design system tokens and VisualEffectView bridge
├── PrompterToolbar.swift    # Floating pill toolbar with playback and formatting controls
├── PrompterFooter.swift     # Premium glass footer with live stats
```

