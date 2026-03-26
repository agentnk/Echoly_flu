import SwiftUI
import AppKit

struct SettingsView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    
    @State private var draftThemePreference: Int = 0
    @State private var draftLineSpace: Double = 8.0
    @State private var draftScrollMode: Int = 0 
    @State private var draftLinesPerScroll: Int = 1
    @State private var draftHideFromScreenSharing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Theme").font(.subheadline).bold()
                Picker("Theme", selection: $draftThemePreference) {
                    Text("System Default").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(RadioGroupPickerStyle())
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Line Spacing: \(Int(draftLineSpace))").font(.subheadline).bold()
                Slider(value: $draftLineSpace, in: 0...40, step: 2)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Controls").font(.subheadline).bold()
                
                Picker("Line Scroll Mode", selection: $draftScrollMode) {
                    Text("Auto scroll").tag(0)
                    Text("Manual scrolling (Enter / Return)").tag(1)
                }
                .labelsHidden()
                
                Picker("Lines per one scroll", selection: $draftLinesPerScroll) {
                    Text("1 Line").tag(1)
                    Text("3 Lines").tag(3)
                    Text("5 Lines").tag(5)
                }
                .labelsHidden()
            }
            
            Divider()
            
            Toggle("Hide app from screen sharing", isOn: $draftHideFromScreenSharing)
                .font(.subheadline).bold()
                .help("Checking this ensures the teleprompter window is invisible in Zoom/Google Meet/etc.")
            
            Divider()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    SettingsWindowManager.sharedWindow?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    themePreference = draftThemePreference
                    lineSpace = draftLineSpace
                    scrollMode = draftScrollMode
                    linesPerScroll = draftLinesPerScroll
                    hideFromScreenSharing = draftHideFromScreenSharing
                    
                    SettingsWindowManager.sharedWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 350)
        .onAppear {
            draftThemePreference = themePreference
            draftLineSpace = lineSpace
            draftScrollMode = scrollMode
            draftLinesPerScroll = linesPerScroll
            draftHideFromScreenSharing = hideFromScreenSharing
        }
    }
}

class SettingsWindowManager {
    static var sharedWindow: NSWindow?
    
    static func show() {
        if sharedWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Echoly Settings"
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
