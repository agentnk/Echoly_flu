import SwiftUI
import AppKit

@main
struct EcholyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 350, minHeight: 400)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating // Always on top
            window.isOpaque = false
            window.backgroundColor = .clear
            window.title = "Echoly"
        }

        // Global key monitor for Play/Pause and Speed
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 49 { // Spacebar
                NotificationCenter.default.post(name: NSNotification.Name("TogglePlay"), object: nil)
                return nil // Consume event
            } else if event.keyCode == 126 { // Up arrow
                NotificationCenter.default.post(name: NSNotification.Name("SpeedUp"), object: nil)
                return nil
            } else if event.keyCode == 125 { // Down arrow
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

struct ContentView: View {
    @State private var text: String = """
    Welcome to Echoly!
    Your Native Floating Teleprompter.
    
    This window stays on top of 
    everything else so you can read
    while looking at the camera.
    
    Open a text file to begin.
    Use the Play button or Spacebar
    to start scrolling.
    
    Use Up/Down arrows to change speed.
    """
    @State private var fontSize: CGFloat = 32
    @State private var speed: CGFloat = 1.0
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            // macOS Titlebar area proxy
            Spacer().frame(height: 28) 

            // Toolbar
            HStack {
                Button(action: openFile) { 
                    Image(systemName: "folder")
                }
                .help("Open File")
                
                Spacer()
                
                Button(action: togglePlay) { 
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill") 
                        .foregroundColor(isPlaying ? .red : .primary)
                }
                .help("Play/Pause (Spacebar)")
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { if fontSize > 12 { fontSize -= 2 } }) { Text("A-") }
                    Button(action: { if fontSize < 120 { fontSize += 2 } }) { Text("A+") }
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Divider()

            // Main Prompter View
            GeometryReader { geo in
                Text(text)
                    .font(.system(size: fontSize, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineSpacing(8)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .offset(y: max(0, geo.size.height * 0.45) - scrollPosition)
            }
            .clipped()
        }
        .edgesIgnoringSafeArea(.top)
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
        panel.allowedContentTypes = [.plainText]
        if panel.runModal() == .OK {
            if let url = panel.url, let content = try? String(contentsOf: url, encoding: .utf8) {
                self.text = content
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
