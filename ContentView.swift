import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = PrompterViewModel()
    
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("lineSpace") private var lineSpace: Double = 8.0
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("linesPerScroll") private var linesPerScroll: Int = 1
    @AppStorage("windowOpacity") private var windowOpacity: Double = 1.0
    @AppStorage("mirrorMode") private var mirrorMode: Bool = false
    @AppStorage("recentFiles") private var recentFilesData: String = ""
    @AppStorage("fontFamily") private var fontFamily: Int = 0 
    @AppStorage("textAlignment") private var textAlignment: Int = 0 
    @AppStorage("highContrast") private var highContrast: Bool = false
    @AppStorage("hideFromScreenSharing") private var hideFromScreenSharing: Bool = false
    
    @State private var fontSize: CGFloat = 48
    @State private var isEditing = false
    @State private var isTargeted = false
    
    var theme: AppTheme { AppTheme(rawValue: themePreference) ?? .system }
    
    var fontDesign: Font.Design {
        switch fontFamily {
        case 1: return .serif
        case 2: return .default
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
    
    var currentFileName: String {
        if let firstPath = recentFilesData.components(separatedBy: "|||").first, !firstPath.isEmpty {
            return URL(fileURLWithPath: firstPath).lastPathComponent
        }
        return "demo-speech.txt"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 12)
            
            // Toolbar
            PrompterToolbar(
                isPlaying: viewModel.isPlaying,
                speed: viewModel.speed,
                fontSize: $fontSize,
                isEditing: $isEditing,
                openFileAction: openFile,
                resetScrollAction: viewModel.resetScroll,
                startWithCountdownAction: viewModel.startWithCountdown,
                manualScrollAction: {
                    viewModel.manualScroll(fontSize: fontSize, lineSpace: lineSpace, linesPerScroll: linesPerScroll)
                }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .padding(.top, 20)
            
            Divider().background(Color.primary.opacity(0.08))
            
            // Filename header
            HStack(spacing: 6) {
                Image(systemName: "doc.text")
                    .font(.system(size: 10))
                Text(currentFileName)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                Spacer()
            }
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            // Main Prompter
            ZStack {
                GeometryReader { geo in
                    Group {
                        if isEditing {
                            TextEditor(text: $viewModel.text)
                                .font(.system(size: fontSize, weight: .bold, design: fontDesign))
                                .lineSpacing(lineSpace)
                                .padding(.horizontal, 40)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        } else {
                            cueRenderedText()
                                .padding(.horizontal, 40)
                                .frame(maxWidth: .infinity, alignment: frameAlignment)
                                .background(GeometryReader { textGeo in
                                    Color.clear
                                        .onAppear { viewModel.textHeight = textGeo.size.height }
                                        .onChange(of: viewModel.text) { viewModel.textHeight = textGeo.size.height }
                                        .onChange(of: textGeo.size) { viewModel.textHeight = textGeo.size.height }
                                })
                                .offset(y: max(0, geo.size.height * 0.4) - viewModel.scrollPosition)
                                .scaleEffect(x: mirrorMode ? -1 : 1, y: 1)
                                .overlay(
                                    viewModel.cueFlash
                                        ? Color.orange.opacity(0.08).allowsHitTesting(false)
                                        : Color.clear.allowsHitTesting(false)
                                )
                                // Active Focus Mask
                                .mask(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .clear, location: 0.0),
                                            .init(color: .clear, location: 0.1),
                                            .init(color: .black, location: 0.35),
                                            .init(color: .black, location: 0.45),
                                            .init(color: .black.opacity(0.2), location: 0.46),
                                            .init(color: .black.opacity(0.1), location: 1.0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                    .onAppear { viewModel.containerHeight = geo.size.height }
                    
                    // Reading Zone Indicators
                    if !isEditing {
                        HStack {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.primary.opacity(0.15))
                                .frame(width: 4, height: 40)
                            Spacer()
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.primary.opacity(0.15))
                                .frame(width: 4, height: 40)
                        }
                        .padding(.horizontal, 6)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.4)
                    }
                }
                .clipped()
                
                if viewModel.showCountdown {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    Text("\(viewModel.countdownValue)")
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
            
            Divider().background(Color.primary.opacity(0.08))
            
            // Footer
            let wordCount = ScriptParser.wordCount(for: viewModel.text)
            PrompterFooter(
                wordCount: wordCount,
                estimatedReadTime: ScriptParser.estimatedReadTime(wordCount: wordCount),
                progress: viewModel.progress,
                isPlaying: viewModel.isPlaying
            )
            .padding(.bottom, 12)
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
            if scrollMode == 1 && !isEditing {
               viewModel.manualScroll(fontSize: fontSize, lineSpace: lineSpace, linesPerScroll: linesPerScroll)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TogglePlay"))) { _ in
            if scrollMode == 0 && !isEditing { viewModel.startWithCountdown() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedUp"))) { _ in
            if scrollMode == 0 { viewModel.speed = min(5.0, viewModel.speed + 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SpeedDown"))) { _ in
            if scrollMode == 0 { viewModel.speed = max(0.5, viewModel.speed - 0.5) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenRecentFile"))) { notif in
            if let path = notif.object as? String { loadFile(from: URL(fileURLWithPath: path)) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ApplySpeedPreset"))) { notif in
            if let spd = notif.object as? Double {
                viewModel.speed = CGFloat(spd)
                viewModel.baseSpeed = CGFloat(spd)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ExportPDF"))) { _ in
            PDFExporter.exportPDF(text: viewModel.text, fontSize: fontSize)
        }
        .onChange(of: scrollMode) { _, newMode in
            if newMode == 1 && viewModel.isPlaying { viewModel.togglePlay() }
        }
    }
    
    // MARK: - Cue Rendered Text
    
    @ViewBuilder
    func cueRenderedText() -> some View {
        let segs = ScriptParser.textSegments(from: viewModel.text)
        if segs.count <= 1 {
            Text(viewModel.text)
                .font(.system(size: fontSize, weight: .bold, design: fontDesign))
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
    
    // MARK: - File Actions
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        return DocumentHandler.handleDrop(providers: providers) { url in
            if let u = url { self.loadFile(from: u) }
        }
    }
    
    func loadFile(from url: URL) {
        if let newText = DocumentHandler.loadText(from: url) {
            viewModel.loadText(newText)
            recentFilesData = DocumentHandler.addRecentFile(url.path, to: recentFilesData)
        }
    }
    
    func openFile() {
        DocumentHandler.openFile { url in
            if let u = url { self.loadFile(from: u) }
        }
    }
}
