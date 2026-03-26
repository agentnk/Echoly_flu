import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum AppTheme: Int {
    case system = 0
    case light = 1
    case dark = 2
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@main
struct EcholyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 450)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating 
            window.isOpaque = false
            window.backgroundColor = .clear
            window.title = "Echoly"
            
            // Screen sharing check
            let hide = UserDefaults.standard.bool(forKey: "hideFromScreenSharing")
            window.sharingType = hide ? .none : .readOnly
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 36 { // Enter / Return
                NotificationCenter.default.post(name: NSNotification.Name("ManualScroll"), object: nil)
                return nil
            } else if event.keyCode == 49 { // Spacebar
                NotificationCenter.default.post(name: NSNotification.Name("TogglePlay"), object: nil)
                return nil 
            } else if event.keyCode == 126 { // Up
                NotificationCenter.default.post(name: NSNotification.Name("SpeedUp"), object: nil)
                return nil
            } else if event.keyCode == 125 { // Down
                NotificationCenter.default.post(name: NSNotification.Name("SpeedDown"), object: nil)
                return nil
            }
            return event
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

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

struct ContentView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    
    @State private var text: String = "Welcome to Echoly!\n\nOpen a .txt or .docx file to begin.\n\nUse the Gear icon to access Settings."
    @State private var fontSize: CGFloat = 32
    @State private var speed: CGFloat = 1.0
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var timer: Timer?
    
    var theme: AppTheme { AppTheme(rawValue: themePreference) ?? .system }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 28) 

            HStack {
                Button(action: openFile) { 
                    Image(systemName: "folder")
                }
                .help("Open File (.txt or .docx)")
                
                Spacer()
                
                if scrollMode == 0 {
                    Button(action: togglePlay) { 
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill") 
                            .foregroundColor(isPlaying ? .red : .primary)
                    }
                    .help("Play/Pause (Spacebar)")
                } else {
                    Button(action: manualScroll) { 
                        Image(systemName: "arrow.down") 
                    }
                    .help("Scroll Down (Enter/Return)")
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Button(action: { if fontSize > 12 { fontSize -= 2 } }) { Text("A-") }
                        Button(action: { if fontSize < 120 { fontSize += 2 } }) { Text("A+") }
                    }
                    
                    Button(action: { SettingsWindowManager.show() }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .help("Settings")
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Divider()

            GeometryReader { geo in
                Text(text)
                    .font(.system(size: fontSize, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineSpacing(lineSpace)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .offset(y: max(0, geo.size.height * 0.45) - scrollPosition)
            }
            .clipped()
        }
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(theme.colorScheme)
        .onChange(of: hideFromScreenSharing) { newValue in
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Echoly" }) {
                window.sharingType = newValue ? .none : .readOnly
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ManualScroll"))) { _ in
            if scrollMode == 1 { manualScroll() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TogglePlay"))) { _ in
            if scrollMode == 0 { togglePlay() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedUp"))) { _ in
            if scrollMode == 0 { speed += 0.5 }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedDown"))) { _ in
            if scrollMode == 0 { speed = max(0.5, speed - 0.5) }
        }
    }
    
    func manualScroll() {
        let jump = (fontSize * 1.25 + CGFloat(lineSpace)) * CGFloat(linesPerScroll)
        withAnimation(.easeInOut(duration: 0.25)) {
            scrollPosition += jump
        }
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "docx") ?? .data]
        if panel.runModal() == .OK {
            if let url = panel.url {
                if url.pathExtension.lowercased() == "docx" {
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.officeOpenXML
                    ]
                    if let attrString = try? NSAttributedString(url: url, options: options, documentAttributes: nil) {
                        self.text = attrString.string
                    }
                } else {
                    if let content = try? String(contentsOf: url, encoding: .utf8) {
                        self.text = content
                    }
                }
                self.scrollPosition = 0
                self.isPlaying = false
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                scrollPosition += speed
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
}
