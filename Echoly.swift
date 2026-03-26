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
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 49 { 
                NotificationCenter.default.post(name: NSNotification.Name("TogglePlay"), object: nil)
                return nil 
            } else if event.keyCode == 126 { 
                NotificationCenter.default.post(name: NSNotification.Name("SpeedUp"), object: nil)
                return nil
            } else if event.keyCode == 125 { 
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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings").font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Display Theme").font(.subheadline).bold()
                Picker("Theme", selection: $themePreference) {
                    Text("System Default").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(RadioGroupPickerStyle())
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Line Spacing: \(Int(lineSpace))").font(.subheadline).bold()
                Slider(value: $lineSpace, in: 0...40, step: 2)
            }
            
            HStack {
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 320)
    }
}

struct ContentView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    
    @State private var text: String = "Welcome to Echoly!\n\nOpen a .txt or .docx file to begin.\n\nUse the Gear icon to access Settings."
    @State private var fontSize: CGFloat = 32
    @State private var speed: CGFloat = 1.0
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var showingSettings = false
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
                
                Button(action: togglePlay) { 
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill") 
                        .foregroundColor(isPlaying ? .red : .primary)
                }
                .help("Play/Pause (Spacebar)")
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Button(action: { if fontSize > 12 { fontSize -= 2 } }) { Text("A-") }
                        Button(action: { if fontSize < 120 { fontSize += 2 } }) { Text("A+") }
                    }
                    
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .help("Settings")
                    .popover(isPresented: $showingSettings) {
                        SettingsView()
                    }
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TogglePlay"))) { _ in
            togglePlay()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedUp"))) { _ in
            speed += 0.5
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedDown"))) { _ in
            speed = max(0.5, speed - 0.5)
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
