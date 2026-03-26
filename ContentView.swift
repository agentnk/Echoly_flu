import SwiftUI
import AppKit
import UniformTypeIdentifiers

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
