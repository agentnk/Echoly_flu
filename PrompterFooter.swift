import SwiftUI

struct PrompterFooter: View {
    let wordCount: Int
    let estimatedReadTime: String
    let progress: Double
    var isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(isPlaying ? Color.red : Color.orange)
                    .frame(width: 8, height: 8)
                Text(isPlaying ? "PLAYING" : "PAUSED")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .tracking(1.0)
            }
            
            // Custom Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.primary.opacity(0.2))
                        .frame(width: max(0, geo.size.width * progress), height: 4)
                    
                    // The thumb
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary)
                        .frame(width: 5, height: 12)
                        .offset(x: max(0, min(geo.size.width - 5, geo.size.width * progress - 2)))
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 12)
            
            // Right Metrics
            HStack(spacing: 16) {
                Text("0:00 / \(estimatedReadTime)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text(String(format: "SLIDE %.0f/%.0f", min(progress * 100, 100), 100))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 75, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
