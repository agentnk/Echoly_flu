import SwiftUI
import AppKit

struct ContentView: View {
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    @AppStorage("windowOpacity") private var windowOpacity: Double = 1.0
    @AppStorage("mirrorMode") private var mirrorMode: Bool = false
    @AppStorage("recentFiles") private var recentFilesData: String = ""
    @AppStorage("fontFamily") private var fontFamily: Int = 0 // 0=mono, 1=serif, 2=sans
    @AppStorage("textAlignment") private var textAlignment: Int = 0 // 0=left, 1=center, 2=right
    @AppStorage("highContrast") private var highContrast: Bool = false
    
    @State private var text: String = "Welcome to Echoly.\n\nDrop a file here, or tap the folder icon to open one.\n\nUse [PAUSE] markers in your script for auto-pause.\nUse [SLOW] to slow down, and [CUE] to highlight a cue point."
    @State private var fontSize: CGFloat = 28
    @State private var speed: CGFloat = 1.0
    @State private var baseSpeed: CGFloat = 1.0 // stored to restore after [SLOW]
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
    @State private var cueFlash: Bool = false // for [CUE] highlight pulse
    
    var theme: AppTheme { AppTheme(rawValue: themePreference) ?? .system }
    
    var progress: Double {
        guard textHeight > 0 else { return 0 }
        let maxScroll = max(textHeight - containerHeight * 0.55, 1)
        return min(scrollPosition / maxScroll, 1.0)
    }
    
    var fontDesign: Font.Design {
        switch fontFamily {
        case 1: return .serif
        case 2: return .default // sans-serif
        default: return .monospaced
        }
    }
    
    var alignment: TextAlignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    var frameAlignment: Alignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 28)
            
            // Toolbar
            PrompterToolbar(
                isPlaying: isPlaying,
                speed: speed,
                fontSize: $fontSize,
                isEditing: $isEditing,
                openFileAction: openFile,
                resetScrollAction: resetScroll,
                startWithCountdownAction: startWithCountdown,
                manualScrollAction: manualScroll
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            
            Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 1)

            // Main Prompter
            ZStack {
                GeometryReader { geo in
                    Group {
                        if isEditing {
                            TextEditor(text: $text)
                                .font(.system(size: fontSize, weight: .light, design: fontDesign))
                                .lineSpacing(lineSpace)
                                .padding(.horizontal, 20)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        } else {
                            cueRenderedText()
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: frameAlignment)
                                .background(GeometryReader { textGeo in
                                    Color.clear
                                        .onAppear { textHeight = textGeo.size.height }
                                        .onChange(of: text) { textHeight = textGeo.size.height }
                                        .onChange(of: textGeo.size) { textHeight = textGeo.size.height }
                                })
                                .offset(y: max(0, geo.size.height * 0.4) - scrollPosition)
                                .scaleEffect(x: mirrorMode ? -1 : 1, y: 1)
                                .overlay(
                                    cueFlash
                                        ? Color.orange.opacity(0.08).allowsHitTesting(false)
                                        : Color.clear.allowsHitTesting(false)
                                )
                        }
                    }
                    .onAppear { containerHeight = geo.size.height }
                }
                .clipped()
                
                if showCountdown {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    Text("\(countdownValue)")
                        .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if isTargeted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .background(Color.primary.opacity(0.03))
                        .padding(6)
                }
            }
            
            // Progress bar
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
            
            // Footer
            let wordCount = ScriptParser.wordCount(for: text)
            PrompterFooter(
                wordCount: wordCount,
                estimatedReadTime: ScriptParser.estimatedReadTime(wordCount: wordCount),
                progress: progress
            )
        }
        .opacity(windowOpacity)
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(highContrast ? .dark : theme.colorScheme)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onChange(of: hideFromScreenSharing) { _, newValue in
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplySpeedPreset"))) { notif in
            if let spd = notif.object as? Double {
                speed = CGFloat(spd)
                baseSpeed = CGFloat(spd)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ExportPDF"))) { _ in
            PDFExporter.exportPDF(text: text, fontSize: fontSize)
        }
        .onChange(of: scrollMode) { _, newMode in
            if newMode == 1 && isPlaying { togglePlay() }
        }
    }
    
    // MARK: - Cue Rendered Text
    
    @ViewBuilder
    func cueRenderedText() -> some View {
        let segs = ScriptParser.textSegments(from: text)
        if segs.count <= 1 {
            Text(text)
                .font(.system(size: fontSize, weight: .light, design: fontDesign))
                .foregroundColor(highContrast ? .white : .primary.opacity(0.85))
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        } else {
            let attr = ScriptParser.buildAttributedString(from: segs, fontSize: fontSize, fontDesign: fontDesign, highContrast: highContrast)
            Text(attr)
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        }
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
        return DocumentHandler.handleDrop(providers: providers) { url in
            if let u = url { self.loadFile(from: u) }
        }
    }
    
    func loadFile(from url: URL) {
        if let newText = DocumentHandler.loadText(from: url) {
            self.text = newText
            scrollPosition = 0; isPlaying = false; timer?.invalidate(); timer = nil
            recentFilesData = DocumentHandler.addRecentFile(url.path, to: recentFilesData)
        }
    }
    
    func openFile() {
        DocumentHandler.openFile { url in
            if let u = url { self.loadFile(from: u) }
        }
    }
    
    // MARK: - Auto-scroll with cue detection
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            baseSpeed = speed // snapshot current speed as base
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                scrollPosition += speed
                checkForCuePause()
            }
        } else {
            timer?.invalidate(); timer = nil
            speed = baseSpeed // restore base speed on pause
        }
    }
    
    func checkForCuePause() {
        let approxCharPerPixel = Double(text.count) / max(textHeight, 1)
        let currentCharIndex = Int(scrollPosition * approxCharPerPixel)
        
        let searchRange = max(0, currentCharIndex - 3)...min(text.count, currentCharIndex + 10)
        let startIdx = text.index(text.startIndex, offsetBy: max(0, searchRange.lowerBound), limitedBy: text.endIndex) ?? text.startIndex
        let endIdx = text.index(text.startIndex, offsetBy: min(text.count, searchRange.upperBound), limitedBy: text.endIndex) ?? text.endIndex
        let window = String(text[startIdx..<endIdx])
        
        if window.localizedCaseInsensitiveContains("[PAUSE]") {
            togglePlay()
        } else if window.localizedCaseInsensitiveContains("[SLOW]") {
            if speed > baseSpeed * 0.6 {
                speed = max(0.3, baseSpeed * 0.5)
            }
        } else if window.localizedCaseInsensitiveContains("[CUE]") {
            speed = baseSpeed
            withAnimation(.easeInOut(duration: 0.15)) { cueFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.4)) { cueFlash = false }
            }
        }
    }
}
