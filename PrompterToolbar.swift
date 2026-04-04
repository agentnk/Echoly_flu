import SwiftUI

struct PrompterToolbar: View {
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    @AppStorage("themePreference") private var themePreference: Int = 0
    
    var isPlaying: Bool
    var speed: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var isEditing: Bool
    
    let openFileAction: () -> Void
    let resetScrollAction: () -> Void
    let startWithCountdownAction: () -> Void
    let manualScrollAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 14))
                        .padding(4)
                        .background(Color.primary)
                        .foregroundColor(Color(NSColor.windowBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("ECHOLY")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(1.0)
                }
                
                Button(action: openFileAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 13))
                        Text("Open")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            HStack(spacing: 18) {
                Button(action: resetScrollAction) {
                    Image(systemName: "backward.end.alt.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if scrollMode == 0 { startWithCountdownAction() } else { manualScrollAction() }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 32, height: 32)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(NSColor.windowBackgroundColor))
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: { manualScrollAction() }) {
                    Image(systemName: "forward.end.alt.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Button(action: { if fontSize > 12 { fontSize -= 2 } }) {
                        Text("A-")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(Int(fontSize))pt")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .frame(minWidth: 42, alignment: .center)
                    
                    Button(action: { if fontSize < 120 { fontSize += 2 } }) {
                        Text("A+")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .buttonStyle(.plain)
                }
                .foregroundColor(.primary)
                
                Divider().frame(height: 16)
                
                Button(action: {
                    themePreference = themePreference == 2 ? 1 : 2 // Toggle Dark/Light
                }) {
                    Image(systemName: themePreference == 2 ? "circle.lefthalf.filled" : "circle.righthalf.filled")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                
                Button(action: { SettingsWindowManager.show() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
            }
        }
    }
}
