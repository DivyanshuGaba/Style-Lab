import SwiftUI

struct SurfaceModifier: ViewModifier {
    let s: SurfaceStyle

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: s.radius, style: .continuous)
        content
            .background {
                ZStack {
                    if let hc = s.hardColor { shape.fill(hc).offset(x: s.hardOffset, y: s.hardOffset) }
                    if s.hairlines == nil {
                        shadowed(shape.fill(s.fill.style), s.shadows)
                        if let m = s.material { shape.fill(m) }
                    }
                }
            }
            .overlay { inners(shape) }
            .overlay {
                if s.hairlines == nil, let b = s.borderColor { shape.strokeBorder(b, lineWidth: s.borderWidth) }
            }
            .overlay(alignment: .top) {
                if let tb = s.topBorder { Rectangle().fill(tb).frame(height: s.topBorderWidth) }
            }
            .overlay {
                if let hl = s.hairlines {
                    VStack { Rectangle().fill(hl).frame(height: 1); Spacer(); Rectangle().fill(hl).frame(height: 1) }
                }
            }
    }

    @ViewBuilder private func shadowed<V: View>(_ v: V, _ shadows: [Shadow]) -> some View {
        shadows.reduce(AnyView(v)) { acc, sh in AnyView(acc.shadow(color: sh.color, radius: sh.blur / 2, x: sh.x, y: sh.y)) }
    }

    @ViewBuilder private func inners(_ shape: RoundedRectangle) -> some View {
        ZStack {
            ForEach(Array(s.inner.enumerated()), id: \.offset) { _, i in
                let w = max(i.blur * 2, 2)
                shape.strokeBorder(i.color, lineWidth: w).blur(radius: i.blur / 2).offset(x: i.x, y: i.y)
            }
        }
        .clipShape(shape)
        .allowsHitTesting(false)
    }
}

extension View {
    func surface(_ s: SurfaceStyle) -> some View { modifier(SurfaceModifier(s: s)) }
}

struct BackgroundView: View {
    let spec: BackgroundSpec
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .topLeading) {
                Rectangle().fill(spec.fill.style)
                ForEach(Array(spec.blobs.enumerated()), id: \.offset) { _, b in
                    // A soft radial glow looks like a blurred disc but needs no blur pass, so editing stays fast.
                    Color.clear.frame(width: b.diameter, height: b.diameter)
                        .overlay {
                            Circle().fill(RadialGradient(stops: [.init(color: b.color, location: 0), .init(color: b.color, location: 0.4), .init(color: b.color.opacity(0), location: 1)],
                                                         center: .center, startRadius: 0, endRadius: b.diameter * 0.78))
                                .frame(width: b.diameter * 1.56, height: b.diameter * 1.56)
                        }
                        .opacity(b.opacity)
                        .offset(x: b.dx, y: b.dy)
                        .frame(width: g.size.width, height: g.size.height, alignment: b.alignment)
                }
            }
            .frame(width: g.size.width, height: g.size.height)
            .clipped()
        }
    }
}

struct PreviewToggle: View {
    let tokens: StyleTokens
    @State var isOn: Bool
    @Environment(\.editor) private var editor
    var body: some View {
        let t = tokens.toggle
        let r: CGFloat = t.square ? 6 : 15.5
        Button { withAnimation(.easeOut(duration: 0.15)) { isOn.toggle() } } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: r, style: .continuous).fill(isOn ? t.on : t.off)
                    .overlay { if t.recessed { RoundedRectangle(cornerRadius: r, style: .continuous).stroke(Color.black.opacity(0.25), lineWidth: 2).blur(radius: 2).clipShape(RoundedRectangle(cornerRadius: r, style: .continuous)) } }
                    .overlay { if let b = t.border, t.borderWidth > 0 { RoundedRectangle(cornerRadius: r, style: .continuous).strokeBorder(b, lineWidth: t.borderWidth) } }
                Group {
                    if t.metal {
                        RoundedRectangle(cornerRadius: 13.5, style: .continuous).fill(LinearGradient(colors: [.white, h("#C5CAD3").color], startPoint: .top, endPoint: .bottom))
                    } else if t.square {
                        RoundedRectangle(cornerRadius: 4).fill(t.knob).overlay(RoundedRectangle(cornerRadius: 4).stroke(t.knobBorder ?? .clear, lineWidth: 2))
                    } else { Circle().fill(t.knob) }
                }
                .frame(width: 27, height: 27).padding(2).shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            }
            .frame(width: 51, height: 31)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(editor == nil)
        .accessibilityLabel("Sample toggle").accessibilityValue(isOn ? "On" : "Off")
    }
}
