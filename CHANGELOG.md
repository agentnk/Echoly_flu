# Changelog

All notable changes to the **Echoly** project will be documented in this file.

## [2.0.0] - 2026-03-30
### Added
- **UI Modernization**: Complete redesign inspired by professional web-based teleprompter tools.
- **Active Focus Mask**: Implemented a dynamic linear gradient overlay to highlight the active reading area and fade inactive text.
- **Reading Zone Indicators**: Added subtle side markers to guide eyes towards the optimal reading horizontal plane.
- **Enhanced Progress Bar**: Integrated a real-time progress indicator in the recording-style footer.
- **File Name Display**: Current script filename is now displayed in the prompter header for better multi-script tracking.
### Changed
- **Refined Toolbar**: Grouped font controls, playback buttons, and script actions into a more structured and modern layout.
- **Recording-style Footer**: Redesigned the footer with live word count, estimated read time, and scrolling stats.
- **Bold Typography**: Switched the default prompter text to bold for maximum legibility in studio environments.

## [1.2.0] - 2026-03-26
### Added
- **Professional Cue System**: Support for `[PAUSE]`, `[SLOW]`, and `[CUE]` inline tags.
- **Advanced Regex Parsing**: Implemented `ScriptParser` to dynamically detect and handle cue-triggered events (auto-pausing, speed modulation).
- **Microsoft Word (.docx) Support**: Added native parsing for `.docx` files via `DocumentHandler`.
- **Keyboard Global Monitors**: Added system-wide hotkeys for Play/Pause and manual advance.
- **Recent Files**: Remembers and lists the last 5 scripts for quick loading.

## [1.1.0] - 2024-03-24
### Added
- **PDF Export**: Integrated Quartz-based PDF rendering to save prompter scripts as portable documents.
- **Custom Themes**: Added Light, Dark, and High-Contrast presets.
- **Window Persistence**: App now remembers its position, size, and preferences between launches.
- **Always-On-Top Toggle**: Ability to pin the prompter above all other apps.

## [1.0.0] - 2024-03-24
### Added
- **Initial Release**: Lightweight, native macOS floating prompter.
- **Basic Scrolling**: Automatic and manual scrolling with adjustable speed.
- **Stealth Mode**: Foundational support for hiding the window from screen capture software.
- **SwiftUI Core**: Built using pure SwiftUI and AppKit for maximum performance and native look-and-feel.

---

[2.0.0]: https://github.com/yourusername/Echoly/releases/tag/v2.0.0
[1.2.0]: https://github.com/yourusername/Echoly/releases/tag/v1.2.0
[1.1.0]: https://github.com/yourusername/Echoly/releases/tag/v1.1.0
[1.0.0]: https://github.com/yourusername/Echoly/releases/tag/v1.0.0
