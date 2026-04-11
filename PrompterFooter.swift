import SwiftUI

struct PrompterFooter: View {
    let wordCount: Int
    let estimatedReadTime: String
    let progress: Double
    var isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            // Status Indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(isPlaying ? Color.red : Color.orange)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(isPlaying ? Color.red.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 4)
                            .scaleEffect(isPlaying ? 1.2 : 1.0)
                    )
                    .animation(isPlaying ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPlaying)
                
                Text(isPlaying ? "LIVE" : "READY")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.0)
            }
            .frame(width: 80, alignment: .leading)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.05))
                        .frame(height: 6)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.echolyIndigo.opacity(0.7), .echolyIndigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * progress), height: 6)
                        .shadow(color: .echolyIndigo.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Handle
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.15), radius: 2)
                        .offset(x: max(0, min(geo.size.width - 12, geo.size.width * progress - 6)))
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 20)
            
            // Stats
            HStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(wordCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Text("WORDS")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text(estimatedReadTime)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Text("EST. TIME")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                
                Text("\(Int(min(progress * 100, 100)))%")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.echolyIndigo)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.white.opacity(0.1)), alignment: .top)
        )
    }
}
