import SwiftUI

struct PrompterToolbar: View {
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("themePreference") private var themePreference: Int = 0
    
    @Environment(\.colorScheme) var scheme
    
    var isPlaying: Bool
    var speed: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var isEditing: Bool
    
    let openFileAction: () -> Void
    let resetScrollAction: () -> Void
    let startWithCountdownAction: () -> Void
    let manualScrollAction: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Branding
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars.inverse")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.echolyIndigo)
                    .padding(6)
                    .background(Color.echolyIndigo.opacity(0.12))
                    .clipShape(Circle())
                
                Text("ECHOLY")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(.primary.opacity(0.9))
            }
            .padding(.trailing, 8)
            
            // File Actions
            ToolbarButton(systemName: "folder.fill", label: "Import", action: openFileAction)
            
            Spacer()
            
            // Playback Controls
            HStack(spacing: 12) {
                Button(action: resetScrollAction) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Reset Scroll")
                
                Button(action: {
                    if scrollMode == 0 { startWithCountdownAction() } else { manualScrollAction() }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.echolyIndigo)
                            .frame(width: 42, height: 42)
                            .shadow(color: .echolyIndigo.opacity(0.3), radius: 6, y: 3)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: isPlaying ? 0 : 1)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .help(isPlaying ? "Pause" : "Play")
                
                Button(action: { manualScrollAction() }) {
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Manual Advance")
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Formatting & Settings
            HStack(spacing: 12) {
                HStack(spacing: 0) {
                    Button(action: { if fontSize > 12 { fontSize -= 2 } }) {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .frame(width: 28)
                    
                    Button(action: { if fontSize < 120 { fontSize += 2 } }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 4)
                .background(Color.adaptiveGray(scheme).opacity(0.5))
                .clipShape(Capsule())
                
                ToolbarButton(systemName: themePreference == 2 ? "sun.max.fill" : "moon.fill", action: {
                    themePreference = themePreference == 2 ? 1 : 2
                })
                
                ToolbarButton(systemName: "slider.horizontal.3", action: { SettingsWindowManager.show() })
                    .help("Settings")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
        )
    }
}

// MARK: - Subviews & Styles

struct ToolbarButton: View {
    let systemName: String
    var label: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .medium))
                if let label = label {
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.04))
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
