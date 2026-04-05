import SwiftUI
import AppKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.12),
                    Color(red: 0.10, green: 0.08, blue: 0.18)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────
                VStack(spacing: 16) {
                    // App icon placeholder with gradient ring
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.45, green: 0.30, blue: 0.90),
                                        Color(red: 0.20, green: 0.55, blue: 1.00)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)
                            .shadow(color: Color(red: 0.45, green: 0.30, blue: 0.90).opacity(0.6), radius: 20, x: 0, y: 8)

                        Image(systemName: "text.alignleft")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 36)

                    VStack(spacing: 6) {
                        Text("Echoly")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Version \(version) (Build \(build))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // ── Description ─────────────────────────────────────────
                Text("A professional-grade, native macOS teleprompter\ndesigned for creators — built with Swift & SwiftUI.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                // ── Features grid ────────────────────────────────────────
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    FeaturePill(icon: "eye",               label: "Focus Mask")
                    FeaturePill(icon: "arrow.up.arrow.down", label: "Smart Scroll")
                    FeaturePill(icon: "tag",               label: "Cue System")
                    FeaturePill(icon: "paintbrush",        label: "Themes")
                    FeaturePill(icon: "doc.text",          label: "PDF Export")
                    FeaturePill(icon: "video.slash",       label: "Stealth Mode")
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // ── Footer ──────────────────────────────────────────────
                VStack(spacing: 4) {
                    Text("© 2025 Echoly. Made with ♥ for creators.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.30))
                }
                .padding(.bottom, 24)

                // ── Close button ─────────────────────────────────────────
                Button(action: { dismiss() }) {
                    Text("Close")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.45, green: 0.30, blue: 0.90),
                                    Color(red: 0.20, green: 0.55, blue: 1.00)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 340, height: 460)
    }
}

// MARK: - Feature Pill

private struct FeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.55, green: 0.42, blue: 1.00))
                .frame(width: 18)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
