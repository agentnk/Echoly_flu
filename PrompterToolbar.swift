import SwiftUI

struct PrompterToolbar: View {
    @AppStorage("scrollMode") private var scrollMode: Int = 0 
    
    var isPlaying: Bool
    var speed: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var isEditing: Bool
    
    let openFileAction: () -> Void
    let resetScrollAction: () -> Void
    let startWithCountdownAction: () -> Void
    let manualScrollAction: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            toolbarButton("folder", action: openFileAction, help: "Open")
            toolbarButton("arrow.counterclockwise", action: resetScrollAction, help: "Reset")
            
            Spacer()
            
            if scrollMode == 0 {
                toolbarButton(
                    isPlaying ? "pause" : "play",
                    action: startWithCountdownAction,
                    help: "Play / Pause",
                    tint: isPlaying ? .red.opacity(0.8) : nil
                )
                Text("\(String(format: "%.1f", speed))×")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.6))
            } else {
                toolbarButton("chevron.down", action: manualScrollAction, help: "Next")
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
    }
    
    @ViewBuilder
    private func toolbarButton(_ icon: String, action: @escaping () -> Void, help: String, tint: Color? = nil) -> some View {
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
}
