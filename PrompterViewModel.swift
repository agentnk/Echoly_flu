import SwiftUI
import Combine

class PrompterViewModel: ObservableObject {
    @Published var text: String = "Welcome to Echoly\n\nStart your speech here. Adjust the scroll speed and font size using the toolbar above.\n\nYou can use [PAUSE], [SLOW], or [CUE] markers in your text for automatic control."
    @Published var speed: CGFloat = 1.0
    @Published var baseSpeed: CGFloat = 1.0
    @Published var isPlaying: Bool = false
    @Published var scrollPosition: CGFloat = 0
    @Published var showCountdown: Bool = false
    @Published var countdownValue: Int = 3
    @Published var textHeight: CGFloat = 0
    @Published var containerHeight: CGFloat = 0
    @Published var cueFlash: Bool = false
    
    private var timer: Timer?
    private var countdownTimer: Timer?
    
    var progress: Double {
        guard textHeight > 0 else { return 0 }
        let maxScroll = max(textHeight - containerHeight * 0.55, 1)
        return min(scrollPosition / maxScroll, 1.0)
    }
    
    func startWithCountdown() {
        if isPlaying { 
            togglePlay()
            return 
        }
        showCountdown = true
        countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else {
                t.invalidate()
                return
            }
            self.countdownValue -= 1
            if self.countdownValue <= 0 {
                t.invalidate()
                self.countdownTimer = nil
                self.showCountdown = false
                self.togglePlay()
            }
        }
    }
    
    func resetScroll() {
        if isPlaying { togglePlay() }
        withAnimation(.easeOut(duration: 0.3)) { self.scrollPosition = 0 }
    }
    
    func manualScroll(fontSize: CGFloat, lineSpace: Double, linesPerScroll: Int) {
        let jump = (fontSize * 1.25 + CGFloat(lineSpace)) * CGFloat(linesPerScroll)
        withAnimation(.easeInOut(duration: 0.25)) { self.scrollPosition += jump }
    }
    
    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            baseSpeed = speed // snapshot current speed as base
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.scrollPosition += self.speed
                self.checkForCuePause()
            }
        } else {
            timer?.invalidate()
            timer = nil
            speed = baseSpeed // restore base speed on pause
        }
    }
    
    private func checkForCuePause() {
        guard !text.isEmpty else { return }
        
        let ratio = scrollPosition / max(textHeight, 1)
        let currentCharIndex = Int(CGFloat(text.count) * ratio)
        
        // Search in a small window around current scroll position
        let lookAhead = 15
        let start = max(0, currentCharIndex - 5)
        let end = min(text.count, currentCharIndex + lookAhead)
        
        let startIdx = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex) ?? text.startIndex
        let endIdx = text.index(text.startIndex, offsetBy: end, limitedBy: text.endIndex) ?? text.endIndex
        let window = String(text[startIdx..<endIdx])
        
        if window.localizedCaseInsensitiveContains("[PAUSE]") {
            togglePlay()
        } else if window.localizedCaseInsensitiveContains("[SLOW]") {
            if speed > baseSpeed * 0.6 {
                speed = max(0.3, baseSpeed * 0.5)
            }
        } else if window.localizedCaseInsensitiveContains("[CUE]") {
            if !cueFlash {
                speed = baseSpeed
                withAnimation(.easeInOut(duration: 0.15)) { self.cueFlash = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.4)) { self.cueFlash = false }
                }
            }
        }
    }
    
    func loadText(_ newText: String) {
        self.text = newText
        self.scrollPosition = 0
        if self.isPlaying {
            self.togglePlay()
        }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: - Formatting Helpers
    
    func fontDesign(for fontFamily: Int) -> Font.Design {
        switch fontFamily {
        case 1: return .serif
        case 2: return .default
        default: return .monospaced
        }
    }
    
    func alignment(for textAlignment: Int) -> TextAlignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
    
    func frameAlignment(for textAlignment: Int) -> Alignment {
        switch textAlignment {
        case 1: return .center
        case 2: return .trailing
        default: return .leading
        }
    }
}
