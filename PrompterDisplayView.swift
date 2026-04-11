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
                    TextEditor(text: $viewModel.text)
                        .font(.system(size: fontSize, weight: .bold, design: fontDesign))
                        .lineSpacing(lineSpace)
                        .padding(.horizontal, 40)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                } else {
                    cueRenderedText()
                        .padding(.horizontal, 40)
                        .frame(maxWidth: .infinity, alignment: frameAlignment)
                        .background(GeometryReader { textGeo in
                            Color.clear
                                .onAppear { viewModel.textHeight = textGeo.size.height }
                                .onChange(of: viewModel.text) { viewModel.textHeight = textGeo.size.height }
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
                                    .init(color: .clear, location: 0.1),
                                    .init(color: .black, location: 0.35),
                                    .init(color: .black, location: 0.45),
                                    .init(color: .black.opacity(0.2), location: 0.46),
                                    .init(color: .black.opacity(0.1), location: 1.0)
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
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.primary.opacity(0.15))
                        .frame(width: 4, height: 40)
                    Spacer()
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.primary.opacity(0.15))
                        .frame(width: 4, height: 40)
                }
                .padding(.horizontal, 6)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.4)
            }
        }
    }
    
    @ViewBuilder
    private func cueRenderedText() -> some View {
        let segs = ScriptParser.textSegments(from: viewModel.text)
        if segs.count <= 1 {
            Text(viewModel.text)
                .font(.system(size: fontSize, weight: .bold, design: fontDesign))
                .foregroundColor(highContrast ? .white : .primary.opacity(0.85))
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        } else {
            let attr = ScriptParser.buildAttributedString(from: segs, fontSize: fontSize, fontDesign: fontDesign, highContrast: highContrast)
            Text(attr)
                .lineSpacing(lineSpace)
                .multilineTextAlignment(alignment)
        }
    }
}
