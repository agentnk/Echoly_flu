import SwiftUI
import AppKit

struct AboutView: View {
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.alignleft")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.primary.opacity(0.8))
                
            VStack(spacing: 6) {
                Text("Echoly")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    
                Text("Version \(version) (Build \(build))")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
