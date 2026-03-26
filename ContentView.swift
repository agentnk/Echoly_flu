import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    @AppStorage("windowOpacity") private var windowOpacity: Double = 1.0
    @AppStorage("mirrorMode") private var mirrorMode: Bool = false
    @AppStorage("recentFiles") private var recentFilesData: String = ""
    
    @State private var text: String = "Welcome to Echoly.\n\nDrop a file here, or tap the folder icon to open one."
    @State private var fontSize: CGFloat = 28
    @State private var speed: CGFloat = 1.0
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var timer: Timer?
    @State private var isEditing = false
    @State private var showCountdown = false
    @State private var countdownValue = 3
    @State private var countdownTimer: Timer?
    @State private var textHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    @State private var isTargeted = false
    @State private var toolbarHovered = false
    
    var theme: AppTheme { AppTheme(rawValue: themePreference) ?? .system }
    
    var progress: Double {
        guard textHeight > 0 else { return 0 }
        let maxScroll = max(textHeight - containerHeight * 0.55, 1)
        return min(scrollPosition / maxScroll, 1.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Invisible drag area
            Color.clear.frame(height: 28)
            
            // Minimal Toolbar
            HStack(spacing: 14) {
                toolbarButton("folder", action: openFile, help: "Open")
                toolbarButton("arrow.counterclockwise", action: resetScroll, help: "Reset")
                
                Spacer()
                
                if scrollMode == 0 {
                    toolbarButton(
                        isPlaying ? "pause" : "play",
                        action: startWithCountdown,
                        help: "Play / Pause",
                        tint: isPlaying ? .red.opacity(0.8) : nil
                    )
                    Text("\(String(format: "%.1f", speed))×")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.6))
                } else {
                    toolbarButton("chevron.down", action: manualScroll, help: "Next")
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    toolbarButton("minus", action: { if fontSize > 12 { fontSize -= 2 } }, help: "Smaller")
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(width: 20)
                    
                    toolbarButton("plus", action: { if fontSize < 120 { fontSize += 2 } }, help: "Larger")
                    
                    toolbarButton(
                        isEditing ? "pencil.slash" : "pencil",
                        action: { isEditing.toggle() },
                        help: isEditing ? "Done" : "Edit",
                        tint: isEditing ? .orange.opacity(0.7) : nil
                    )
                    
                    toolbarButton("gearshape", action: { SettingsWindowManager.show() }, help: "Settings")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            
            // Subtle separator
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 1)

            // Main Prompter
            ZStack {
                GeometryReader { geo in
                    Group {
                        if isEditing {
                            TextEditor(text: $text)
                                .font(.system(size: fontSize, weight: .light, design: .monospaced))
                                .lineSpacing(lineSpace)
                                .padding(.horizontal, 20)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        } else {
                            Text(text)
                                .font(.system(size: fontSize, weight: .light, design: .monospaced))
                                .foregroundColor(.primary.opacity(0.85))
                                .lineSpacing(lineSpace)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .background(GeometryReader { textGeo in
                                    Color.clear.onAppear {
                                        textHeight = textGeo.size.height
                                    }
                                    .onChange(of: text) { _ in
                                        textHeight = textGeo.size.height
                                    }
                                })
                                .offset(y: max(0, geo.size.height * 0.4) - scrollPosition)
                                .scaleEffect(x: mirrorMode ? -1 : 1, y: 1)
                        }
                    }
                    .onAppear { containerHeight = geo.size.height }
                }
                .clipped()
                
                // Countdown
                if showCountdown {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    Text("\(countdownValue)")
                        .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Drop overlay
                if isTargeted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .background(Color.primary.opacity(0.03))
                        .padding(6)
                }
            }
            
            // Progress — ultra-thin
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.primary.opacity(0.04)).frame(height: 2)
                    Rectangle()
                        .fill(Color.primary.opacity(0.2))
                        .frame(width: geo.size.width * progress, height: 2)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 2)
        }
        .opacity(windowOpacity)
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(theme.colorScheme)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onChange(of: hideFromScreenSharing) { newValue in
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Echoly" }) {
                window.sharingType = newValue ? .none : .readOnly
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ManualScroll"))) { _ in
            if scrollMode == 1 && !isEditing { manualScroll() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TogglePlay"))) { _ in
            if scrollMode == 0 && !isEditing { startWithCountdown() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedUp"))) { _ in
            if scrollMode == 0 { speed = min(5.0, speed + 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedDown"))) { _ in
            if scrollMode == 0 { speed = max(0.5, speed - 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenRecentFile"))) { notif in
            if let path = notif.object as? String { loadFile(from: URL(fileURLWithPath: path)) }
        }
    }
    
    // MARK: - Toolbar Button
    
    @ViewBuilder
    func toolbarButton(_ icon: String, action: @escaping () -> Void, help: String, tint: Color? = nil) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(tint ?? .primary.opacity(0.55))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
    
    // MARK: - Countdown
    
    func startWithCountdown() {
        if isPlaying { togglePlay(); return }
        showCountdown = true
        countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            countdownValue -= 1
            if countdownValue <= 0 {
                t.invalidate(); countdownTimer = nil; showCountdown = false; togglePlay()
            }
        }
    }
    
    // MARK: - Actions
    
    func resetScroll() {
        if isPlaying { togglePlay() }
        withAnimation(.easeOut(duration: 0.3)) { scrollPosition = 0 }
    }
    
    func manualScroll() {
        let jump = (fontSize * 1.25 + CGFloat(lineSpace)) * CGFloat(linesPerScroll)
        withAnimation(.easeInOut(duration: 0.25)) { scrollPosition += jump }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    let ext = url.pathExtension.lowercased()
                    if ext == "txt" || ext == "docx" { loadFile(from: url) }
                }
            }
        }
        return true
    }
    
    func loadFile(from url: URL) {
        if url.pathExtension.lowercased() == "docx" {
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.officeOpenXML
            ]
            if let a = try? NSAttributedString(url: url, options: opts, documentAttributes: nil) {
                self.text = a.string
            }
        } else {
            if let c = try? String(contentsOf: url, encoding: .utf8) { self.text = c }
        }
        scrollPosition = 0; isPlaying = false; timer?.invalidate(); timer = nil
        addRecentFile(url.path)
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "docx") ?? .data]
        if panel.runModal() == .OK, let url = panel.url { loadFile(from: url) }
    }
    
    func addRecentFile(_ path: String) {
        var files = recentFilesData.isEmpty ? [] : recentFilesData.components(separatedBy: "|||")
        files.removeAll { $0 == path }
        files.insert(path, at: 0)
        if files.count > 5 { files = Array(files.prefix(5)) }
        recentFilesData = files.joined(separator: "|||")
    }
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in scrollPosition += speed }
        } else {
            timer?.invalidate(); timer = nil
        }
    }
}
