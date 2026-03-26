import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    @AppStorage("windowOpacity") private var windowOpacity: Double = 1.0
    @AppStorage("mirrorMode") private var mirrorMode: Bool = false
    @AppStorage("recentFiles") private var recentFilesData: String = ""
    @AppStorage("fontFamily") private var fontFamily: Int = 0
    @AppStorage("textAlignment") private var textAlignment: Int = 0
    @AppStorage("highContrast") private var highContrast: Bool = false
    @AppStorage("speedPresets") private var speedPresetsData: String = "Slow:0.5|||Normal:1.0|||Fast:2.0"
    
    @State private var draftTheme: Int = 0
    @State private var draftLineSpace: Double = 8.0
    @State private var draftScrollMode: Int = 0 
    @State private var draftLinesPerScroll: Int = 1
    @State private var draftHideSharing: Bool = false
    @State private var draftOpacity: Double = 1.0
    @State private var draftMirror: Bool = false
    @State private var draftFontFamily: Int = 0
    @State private var draftAlignment: Int = 0
    @State private var draftHighContrast: Bool = false
    @State private var editablePresets: [(name: String, speed: Double)] = []
    @State private var newPresetName: String = ""
    @State private var newPresetSpeed: String = ""
    
    var recentFiles: [String] {
        recentFilesData.isEmpty ? [] : recentFilesData.components(separatedBy: "|||")
    }
    
    var speedPresets: [(name: String, speed: Double)] {
        speedPresetsData.components(separatedBy: "|||").compactMap { entry in
            let parts = entry.components(separatedBy: ":")
            guard parts.count == 2, let spd = Double(parts[1]) else { return nil }
            return (parts[0], spd)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Display
                settingsSection("Display") {
                    Picker("", selection: $draftTheme) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    .labelsHidden()
                    
                    settingsRow("Opacity", value: "\(Int(draftOpacity * 100))%")
                    Slider(value: $draftOpacity, in: 0.3...1.0, step: 0.05)
                    
                    Toggle("Mirror text", isOn: $draftMirror).font(.system(size: 12))
                    Toggle("High contrast", isOn: $draftHighContrast).font(.system(size: 12))
                }
                
                // Typography
                settingsSection("Typography") {
                    Picker("Font", selection: $draftFontFamily) {
                        Text("Monospaced").tag(0)
                        Text("Serif").tag(1)
                        Text("Sans-serif").tag(2)
                    }
                    .labelsHidden()
                    
                    Picker("Alignment", selection: $draftAlignment) {
                        Image(systemName: "text.alignleft").tag(0)
                        Image(systemName: "text.aligncenter").tag(1)
                        Image(systemName: "text.alignright").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    settingsRow("Line Spacing", value: "\(Int(draftLineSpace))")
                    Slider(value: $draftLineSpace, in: 0...40, step: 2)
                }
                
                // Controls
                settingsSection("Controls") {
                    Picker("", selection: $draftScrollMode) {
                        Text("Auto scroll").tag(0)
                        Text("Manual (Enter)").tag(1)
                    }
                    .labelsHidden()
                    
                    Picker("", selection: $draftLinesPerScroll) {
                        Text("1 line").tag(1)
                        Text("3 lines").tag(3)
                        Text("5 lines").tag(5)
                    }
                    .labelsHidden()
                }
                
                // Speed Presets
                settingsSection("Speed Presets") {
                    ForEach(editablePresets.indices, id: \.self) { i in
                        HStack(spacing: 6) {
                            Button(action: {
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("ApplySpeedPreset"),
                                    object: editablePresets[i].speed
                                )
                                SettingsWindowManager.sharedWindow?.close()
                            }) {
                                HStack {
                                    Text(editablePresets[i].name).font(.system(size: 12))
                                    Spacer()
                                    Text("\(String(format: "%.1f", editablePresets[i].speed))×")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            Button(action: { editablePresets.remove(at: i) }) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 10))
                                    .foregroundColor(.red.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    // Add new preset row
                    HStack(spacing: 6) {
                        TextField("Name", text: $newPresetName)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(width: 90)
                        TextField("Speed", text: $newPresetSpeed)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(width: 50)
                        Button(action: addPreset) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 13))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(newPresetName.isEmpty || Double(newPresetSpeed) == nil)
                    }
                }
                
                // Privacy
                settingsSection("Privacy") {
                    Toggle("Hide from screen sharing", isOn: $draftHideSharing)
                        .font(.system(size: 12))
                }
                
                // Export
                settingsSection("Export") {
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("ExportPDF"), object: nil)
                        SettingsWindowManager.sharedWindow?.close()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.doc").font(.system(size: 10))
                            Text("Export as PDF").font(.system(size: 12))
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Recent Files
                if !recentFiles.isEmpty {
                    settingsSection("Recent") {
                        ForEach(recentFiles, id: \.self) { path in
                            Button(action: {
                                NotificationCenter.default.post(name: NSNotification.Name("OpenRecentFile"), object: path)
                                SettingsWindowManager.sharedWindow?.close()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc").font(.system(size: 10)).foregroundColor(.secondary)
                                    Text(URL(fileURLWithPath: path).lastPathComponent)
                                        .font(.system(size: 12)).lineLimit(1).truncationMode(.middle)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Actions
                HStack {
                    Spacer()
                    Button("Cancel") { SettingsWindowManager.sharedWindow?.close() }
                        .keyboardShortcut(.cancelAction)
                    Button("Save") {
                        themePreference = draftTheme
                        lineSpace = draftLineSpace
                        scrollMode = draftScrollMode
                        linesPerScroll = draftLinesPerScroll
                        hideFromScreenSharing = draftHideSharing
                        windowOpacity = draftOpacity
                        mirrorMode = draftMirror
                        fontFamily = draftFontFamily
                        textAlignment = draftAlignment
                        highContrast = draftHighContrast
                        // Persist edited speed presets
                        speedPresetsData = editablePresets
                            .map { "\($0.name):\(String(format: "%.1f", $0.speed))" }
                            .joined(separator: "|||")
                        SettingsWindowManager.sharedWindow?.close()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(20)
        }
        .frame(width: 320, height: 560)
        .onAppear {
            draftTheme = themePreference
            draftLineSpace = lineSpace
            draftScrollMode = scrollMode
            draftLinesPerScroll = linesPerScroll
            draftHideSharing = hideFromScreenSharing
            draftOpacity = windowOpacity
            draftMirror = mirrorMode
            draftFontFamily = fontFamily
            draftAlignment = textAlignment
            draftHighContrast = highContrast
            editablePresets = speedPresets
        }
    }
    
    // MARK: - Helpers
    
    func addPreset() {
        guard !newPresetName.isEmpty, let spd = Double(newPresetSpeed) else { return }
        editablePresets.append((name: newPresetName, speed: spd))
        newPresetName = ""
        newPresetSpeed = ""
    }
    
    @ViewBuilder
    func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
                .tracking(1.2)
            content()
        }
    }
    
    @ViewBuilder
    func settingsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12))
            Spacer()
            Text(value).font(.system(size: 11, design: .monospaced)).foregroundColor(.secondary)
        }
    }
}

class SettingsWindowManager {
    static var sharedWindow: NSWindow?
    
    static func show() {
        if sharedWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 560),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Settings"
            window.contentView = NSHostingView(rootView: SettingsView())
            window.center()
            window.isReleasedWhenClosed = false
            window.level = .floating
            sharedWindow = window
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
                sharedWindow = nil
            }
        }
        sharedWindow?.makeKeyAndOrderFront(nil)
    }
}
