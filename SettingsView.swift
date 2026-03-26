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
    
    @State private var draftTheme: Int = 0
    @State private var draftLineSpace: Double = 8.0
    @State private var draftScrollMode: Int = 0 
    @State private var draftLinesPerScroll: Int = 1
    @State private var draftHideSharing: Bool = false
    @State private var draftOpacity: Double = 1.0
    @State private var draftMirror: Bool = false
    
    var recentFiles: [String] {
        recentFilesData.isEmpty ? [] : recentFilesData.components(separatedBy: "|||")
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
                    
                    Toggle("Mirror text", isOn: $draftMirror)
                        .font(.system(size: 12))
                }
                
                // Typography
                settingsSection("Typography") {
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
                
                // Privacy
                settingsSection("Privacy") {
                    Toggle("Hide from screen sharing", isOn: $draftHideSharing)
                        .font(.system(size: 12))
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
                                    Image(systemName: "doc")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text(URL(fileURLWithPath: path).lastPathComponent)
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                        .truncationMode(.middle)
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
                    Button("Cancel") {
                        SettingsWindowManager.sharedWindow?.close()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Save") {
                        themePreference = draftTheme
                        lineSpace = draftLineSpace
                        scrollMode = draftScrollMode
                        linesPerScroll = draftLinesPerScroll
                        hideFromScreenSharing = draftHideSharing
                        windowOpacity = draftOpacity
                        mirrorMode = draftMirror
                        SettingsWindowManager.sharedWindow?.close()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(20)
        }
        .frame(width: 320, height: 480)
        .onAppear {
            draftTheme = themePreference
            draftLineSpace = lineSpace
            draftScrollMode = scrollMode
            draftLinesPerScroll = linesPerScroll
            draftHideSharing = hideFromScreenSharing
            draftOpacity = windowOpacity
            draftMirror = mirrorMode
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .default))
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
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

class SettingsWindowManager {
    static var sharedWindow: NSWindow?
    
    static func show() {
        if sharedWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
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
