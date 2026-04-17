import SwiftUI

struct PrompterDisplayView: View {
    @ObservedObject var viewModel: PrompterViewModel
    var fontSize: CGFloat
    var lineSpace: Double
    var fontDesign: Font.Design
    var alignment: TextAlignment
    var frameAlignment: Alignment
    var highContrast: Bool
    var mirrorMode: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        GeometryReader { geo in
            Group {
                if isEditing {
                    RichTextEditor(attributedText: $viewModel.attributedText, fontSize: fontSize, fontDesign: fontDesign)
                        .padding(.horizontal, 40)
                        .background(Color.clear)
                } else {
                    cueRenderedText()
                        .padding(.horizontal, 40)
                        .frame(maxWidth: .infinity, alignment: frameAlignment)
                        .background(GeometryReader { textGeo in
                            Color.clear
                                .onAppear { viewModel.textHeight = textGeo.size.height }
                                .onChange(of: viewModel.attributedText) { _ in viewModel.textHeight = textGeo.size.height }
                                .onChange(of: textGeo.size) { viewModel.textHeight = textGeo.size.height }
                        })
                        .offset(y: max(0, geo.size.height * 0.4) - viewModel.scrollPosition)
                        .scaleEffect(x: mirrorMode ? -1 : 1, y: 1)
                        .overlay(
                            viewModel.cueFlash
                                ? Color.orange.opacity(0.08).allowsHitTesting(false)
                                : Color.clear.allowsHitTesting(false)
                        )
                        // Active Focus Mask
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black.opacity(0.1), location: 0.15),
                                    .init(color: .black, location: 0.38),
                                    .init(color: .black, location: 0.42),
                                    .init(color: .black.opacity(0.3), location: 0.48),
                                    .init(color: .black.opacity(0.05), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            .onAppear { viewModel.containerHeight = geo.size.height }
            
            // Reading Zone Indicators
            if !isEditing {
                HStack {
                    Capsule()
                        .fill(Color.echolyIndigo.opacity(0.4))
                        .frame(width: 3, height: 32)
                        .blur(radius: 0.5)
                    Spacer()
                    Capsule()
                        .fill(Color.echolyIndigo.opacity(0.4))
                        .frame(width: 3, height: 32)
                        .blur(radius: 0.5)
                }
                .padding(.horizontal, 4)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.4)
            }
        }
    }
    
    @ViewBuilder
    private func cueRenderedText() -> some View {
        let plain = viewModel.text
        if plain.contains("[PAUSE]") || plain.contains("[SLOW]") || plain.contains("[CUE]") {
            // If we have cues, we merge our markers with the attributed text
            let attr = ScriptParser.processRichTextCues(from: viewModel.attributedText, fontSize: fontSize, fontDesign: fontDesign, highContrast: highContrast)
            Text(attr)
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        } else {
            // Direct rendering for standard rich text
            Text(AttributedString(viewModel.attributedText))
                .font(.system(size: fontSize, weight: .bold, design: fontDesign))
                .foregroundColor(highContrast ? .white : .primary.opacity(0.85))
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        }
    }
}

