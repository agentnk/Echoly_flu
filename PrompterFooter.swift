import SwiftUI

struct PrompterFooter: View {
    let wordCount: Int
    let estimatedReadTime: String
    let progress: Double
    
    var body: some View {
        HStack {
            Text("\(wordCount) words · \(estimatedReadTime)")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.4))
            Spacer()
            Text("\(Int(progress * 100))%")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
