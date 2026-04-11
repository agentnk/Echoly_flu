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
            filenameHeader
            
            // Main Prompter
            ZStack {
                PrompterDisplayView(
                    viewModel: viewModel,
                    fontSize: fontSize,
                    lineSpace: lineSpace,
                    fontDesign: viewModel.fontDesign(for: fontFamily),
                    alignment: viewModel.alignment(for: textAlignment),
                    frameAlignment: viewModel.frameAlignment(for: textAlignment),
                    highContrast: highContrast,
                    mirrorMode: mirrorMode,
                    isEditing: $isEditing
                )
                .clipped()
                
                if viewModel.showCountdown {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    Text("\(viewModel.countdownValue)")
                        .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if isTargeted {
                    dropZoneOverlay
                }
            }
            
            Divider().background(Color.primary.opacity(0.08))
            
            // Footer
            footerView
        }
        .opacity(windowOpacity)
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(highContrast ? .dark : theme.colorScheme)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onChange(of: hideFromScreenSharing) { _, newValue in
            updateScreenSharing(hide: newValue)
        }
        .onChange(of: scrollMode) { _, newMode in
            if newMode == 1 && viewModel.isPlaying { viewModel.togglePlay() }
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
    }
    
    // MARK: - Components
    
    private var filenameHeader: some View {
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
    }
    
    private var footerView: some View {
        let wordCount = ScriptParser.wordCount(for: viewModel.text)
        return PrompterFooter(
            wordCount: wordCount,
            estimatedReadTime: ScriptParser.estimatedReadTime(wordCount: wordCount),
            progress: viewModel.progress,
            isPlaying: viewModel.isPlaying
        )
        .padding(.bottom, 12)
    }
    
    private var dropZoneOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.primary.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            .background(Color.primary.opacity(0.03))
            .padding(6)
    }
    
    // MARK: - Helper Actions
    
    private func updateScreenSharing(hide: Bool) {
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Echoly" }) {
            window.sharingType = hide ? .none : .readOnly
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
