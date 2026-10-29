import SwiftUI

/// Renders the 390 by 844 sample at its natural size.
struct SampleScreenView: View {
    let spec: DesignSpec
    let screen: SampleScreen
    var reduceTransparency = false
    var increaseContrast = false
    @Environment(\.frameSink) private var sink
    var body: some View {
        let t = StyleTokens.make(spec, reduceTransparency: reduceTransparency, increaseContrast: increaseContrast)
        let def = AppContent.def(screen, spec.app)
        ZStack {
            if screen == .imported {
                if let imp = spec.activeImport { ImportedCanvas(imp: imp) }
                else { Color(.systemBackground); Text("Import a screenshot to edit it here.").font(.subheadline).foregroundStyle(.secondary) }
            } else {
                BackgroundView(spec: t.background)
                if let bg = spec.edits[screen.editKey(spec.app) + "/background"]?.bgHex { RGB(hex: bg).color }
                if screen == .home && t.layout == .bento && spec.app == .wallet { BentoHomeScreen(t: t, def: def) } else { BlockScreen(t: t, def: def, screen: screen) }
            }
        }
        .environment(\.screenEdit, ScreenEditEnv(screen: screen.editKey(spec.app), edits: spec.edits))
        .environment(\.hideDetails, spec.hideDetails)
        .coordinateSpace(name: "sample")
        .onPreferenceChange(ElementFramesKey.self) { sink?.frames = $0 }
        .overlay { GuideOverlay() }
        .frame(width: 390, height: 844)
        .clipped()
        .overlay { if screen == .imported { CutOverlay() } }
        .environment(\.colorScheme, spec.mode == .dark ? .dark : .light)
    }
}

/// Scales the sample to fit the space it is given.
struct PreviewCanvas: View {
    let spec: DesignSpec
    var screen: SampleScreen = .home
    var framed = false
    var zoom: CGFloat = 1
    @Environment(\.accessibilityReduceTransparency) private var reduceT
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        GeometryReader { g in
            let inset: CGFloat = framed ? 6 : 0
            let sc = max(min((g.size.width - inset * 2) / 390, (g.size.height - inset * 2) / 844), 0.01) * zoom
            SampleScreenView(spec: spec, screen: screen, reduceTransparency: reduceT, increaseContrast: contrast == .increased)
                .frame(width: 390, height: 844)
                .id("\(spec.style.rawValue)-\(spec.mode.rawValue)-\(screen.rawValue)")
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.28), value: spec.style)
                .animation(.easeInOut(duration: 0.28), value: spec.mode)
                .environment(\.previewScale, sc)
                .scaleEffect(sc, anchor: .center)
                .frame(width: 390 * sc, height: 844 * sc)
                .clipShape(RoundedRectangle(cornerRadius: 40 * sc, style: .continuous))
                .padding(inset)
                .background(framed ? RoundedRectangle(cornerRadius: 40 * sc + inset, style: .continuous).fill(h("#0E1014").color) : nil)
                .shadow(color: .black.opacity(framed ? 0.25 : 0), radius: 14, y: 6)
                .frame(width: g.size.width, height: g.size.height)
        }
        .aspectRatio(390.0 / 844.0, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Preview of \(StyleCatalog.info(spec.style).name) in \(spec.mode.title) mode")
    }
}

/// Pink alignment lines shown while dragging in the layout editor.
struct GuideOverlay: View {
    @Environment(\.editor) private var editor
    @Environment(\.previewScale) private var pscale
    var body: some View {
        if let editor, !editor.guides.isEmpty {
            ZStack {
                ForEach(editor.guides) { g in
                    Path { p in
                        if g.vertical { p.move(to: CGPoint(x: g.pos, y: 0)); p.addLine(to: CGPoint(x: g.pos, y: 844)) }
                        else { p.move(to: CGPoint(x: 0, y: g.pos)); p.addLine(to: CGPoint(x: 390, y: g.pos)) }
                    }
                    .stroke(Color(red: 1, green: 0.2, blue: 0.55), style: StrokeStyle(lineWidth: 1.2 / max(pscale, 0.05), dash: [5 / max(pscale, 0.05), 3 / max(pscale, 0.05)]))
                }
            }
            .allowsHitTesting(false)
        }
    }
}

/// Lets the person draw a box around anything in an imported screenshot to cut it out as a layer.
struct CutOverlay: View {
    @Environment(\.editor) private var editor
    @Environment(\.previewScale) private var pscale
    @State private var start: CGPoint?
    @State private var current: CGPoint?

    private var rect: CGRect? {
        guard let a = start, let b = current else { return nil }
        return CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x - b.x), height: abs(a.y - b.y))
    }

    var body: some View {
        if let editor, editor.cutMode {
            ZStack(alignment: .topLeading) {
                Color.black.opacity(0.08)
                if let r = rect {
                    Rectangle().fill(Color(red: 1, green: 0.2, blue: 0.55).opacity(0.15)).frame(width: r.width, height: r.height).offset(x: r.minX, y: r.minY)
                    Rectangle().stroke(Color(red: 1, green: 0.2, blue: 0.55), style: StrokeStyle(lineWidth: 2 / max(pscale, 0.05), dash: [6 / max(pscale, 0.05), 4 / max(pscale, 0.05)]))
                        .frame(width: r.width, height: r.height).offset(x: r.minX, y: r.minY)
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 4)
                .onChanged { v in start = start ?? v.startLocation; current = v.location }
                .onEnded { _ in
                    let r = rect; start = nil; current = nil
                    if let r { editor.cut(rect: r) }
                })
        }
    }
}
