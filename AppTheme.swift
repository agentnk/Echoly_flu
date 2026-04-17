import SwiftUI

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

extension Color {
    static let echolyIndigo = Color(red: 0.35, green: 0.34, blue: 0.84)
    static let surfaceGlass = Color.primary.opacity(0.06)
    static let borderGlass = Color.primary.opacity(0.08)
    static let textSecondary = Color.secondary.opacity(0.8)
    
    static func adaptiveGray(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? Color(white: 0.15) : Color(white: 0.95)
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { }
}

