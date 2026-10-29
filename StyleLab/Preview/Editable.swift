import SwiftUI
import Observation

struct ScreenEditEnv { var screen = ""; var edits: [String: ElementEdit] = [:] }

private struct ScreenEditKey: EnvironmentKey { static let defaultValue = ScreenEditEnv() }
private struct PreviewScaleKey: EnvironmentKey { static let defaultValue: CGFloat = 1 }
private struct EditorKey: EnvironmentKey { static let defaultValue: EditorContext? = nil }
private struct HideDetailsKey: EnvironmentKey { static let defaultValue = false }

extension EnvironmentValues {
    var screenEdit: ScreenEditEnv { get { self[ScreenEditKey.self] } set { self[ScreenEditKey.self] = newValue } }
    var previewScale: CGFloat { get { self[PreviewScaleKey.self] } set { self[PreviewScaleKey.self] = newValue } }
    var editor: EditorContext? { get { self[EditorKey.self] } set { self[EditorKey.self] = newValue } }
    /// When true the sample screens show only empty tiles.
    var hideDetails: Bool { get { self[HideDetailsKey.self] } set { self[HideDetailsKey.self] = newValue } }
}

/// Where one editable part ended up on the 390 by 844 canvas.
struct ElementFrame: Equatable {
    var name: String
    var kind: ElementKind
    var rect: CGRect
}

struct ElementFramesKey: PreferenceKey {
    static var defaultValue: [String: ElementFrame] = [:]
    static func reduce(value: inout [String: ElementFrame], nextValue: () -> [String: ElementFrame]) { value.merge(nextValue()) { $1 } }
}

/// Collects the frames of every part when a screen is rendered for export.
final class FrameSink { var frames: [String: ElementFrame] = [:] }
private struct FrameSinkKey: EnvironmentKey { static let defaultValue: FrameSink? = nil }
extension EnvironmentValues { var frameSink: FrameSink? { get { self[FrameSinkKey.self] } set { self[FrameSinkKey.self] = newValue } } }

struct Guide: Identifiable, Equatable {
    let vertical: Bool
    let pos: CGFloat
    var id: String { "\(vertical)-\(pos)" }
}

struct LiveEdit { var dx: Double; var dy: Double; var scale: Double }

/// Holds the in-progress position or size of one element while a finger or slider is moving it.
/// Only that element observes it, so everything else on screen stays still.
@Observable final class LiveBox { var value: LiveEdit? }

struct ElementMeta { var name: String; var kind: ElementKind }

struct LayerItem: Identifiable {
    var id: String { key }
    let key: String
    let meta: ElementMeta
    let rect: CGRect
    let edited: Bool
    let hidden: Bool
}

/// Drives the layout editor: which element is selected and how edits are written to the design.
@Observable @MainActor
final class EditorContext {
    var selection: String?
    var selName = ""
    var selKind: ElementKind = .card
    var screen: SampleScreen
    let model: AppModel
    /// Prefix of this screen's edit keys, which depends on the sample app.
    var screenKey: String { screen.editKey(model.spec.app) }
    var guides: [Guide] = []
    var autoAlign = true
    var cutMode = false
    /// Faint outlines around every part. On for the built in samples as before, off for imported screenshots.
    var showOutlines: Bool
    @ObservationIgnored var rects: [String: CGRect] = [:]
    @ObservationIgnored var metas: [String: ElementMeta] = [:]
    @ObservationIgnored private var boxes: [String: LiveBox] = [:]
    @ObservationIgnored var dragKey: String?
    @ObservationIgnored var dragStartRect = CGRect.zero
    @ObservationIgnored var snapX: CGFloat?
    @ObservationIgnored var snapY: CGFloat?
    @ObservationIgnored var atHome = false
    @ObservationIgnored var scaleSnapped = false

    init(model: AppModel, screen: SampleScreen) { self.model = model; self.screen = screen; self.showOutlines = screen != .imported }

    func box(_ key: String) -> LiveBox {
        if let b = boxes[key] { return b }
        let b = LiveBox(); boxes[key] = b; return b
    }

    func register(_ key: String, _ name: String, _ kind: ElementKind, _ rect: CGRect) {
        metas[key] = ElementMeta(name: name, kind: kind); rects[key] = rect
    }

    func beginDrag(_ key: String) {
        guard dragKey != key else { return }
        dragKey = key; dragStartRect = rects[key] ?? .zero
        snapX = nil; snapY = nil; atHome = false
    }

    func endDrag() {
        dragKey = nil
        if !guides.isEmpty { guides = [] }
    }

    private func related(_ a: String, _ b: String) -> Bool {
        let x = a.split(separator: "/").last.map(String.init) ?? a, y = b.split(separator: "/").last.map(String.init) ?? b
        return x == y || x.hasPrefix(y + ".") || y.hasPrefix(x + ".")
    }

    /// Applies auto alignment to a drag and returns the offset to use. Shows guides and ticks when something snaps.
    func snappedOffset(key: String, start: CGSize, delta: CGSize, haptics: Bool = true) -> CGSize {
        var ddx = delta.width, ddy = delta.height
        var found: [Guide] = []
        var newX: CGFloat?, newY: CGFloat?
        if autoAlign, dragStartRect != .zero {
            let r = dragStartRect.offsetBy(dx: ddx, dy: ddy)
            var xT: [CGFloat] = [20, 195, 370], yT: [CGFloat] = [422]
            for (k, o) in rects where k != key && !related(k, key) && o.width > 1 {
                xT += [o.minX, o.midX, o.maxX]; yT += [o.minY, o.midY, o.maxY]
            }
            var bx: (d: CGFloat, t: CGFloat)?, by: (d: CGFloat, t: CGFloat)?
            for edge in [r.minX, r.midX, r.maxX] { for t in xT { let d = t - edge; if abs(d) < 5, abs(d) < abs(bx?.d ?? 99) { bx = (d, t) } } }
            for edge in [r.minY, r.midY, r.maxY] { for t in yT { let d = t - edge; if abs(d) < 5, abs(d) < abs(by?.d ?? 99) { by = (d, t) } } }
            if let bx { ddx += bx.d; newX = bx.t; found.append(Guide(vertical: true, pos: bx.t)) }
            if let by { ddy += by.d; newY = by.t; found.append(Guide(vertical: false, pos: by.t)) }
        }
        var nx = start.width + ddx, ny = start.height + ddy
        let home = abs(nx) < 4 && abs(ny) < 4 && (start.width != 0 || start.height != 0 || dragStartRect != .zero)
        if home { nx = 0; ny = 0 }
        if haptics {
            if (newX != nil && newX != snapX) || (newY != nil && newY != snapY) || (home && !atHome) { Haptics.snap() }
            snapX = newX; snapY = newY; atHome = home
            if guides != found { guides = found }
        }
        return CGSize(width: nx.rounded(), height: ny.rounded())
    }

    func select(_ key: String, _ name: String, _ kind: ElementKind) {
        guard selection != key else { return }
        selection = key; selName = name; selKind = kind
        Haptics.select()
    }

    func select(key: String) {
        guard let m = metas[key] else { return }
        select(key, m.name, m.kind)
    }

    /// The element that contains the selected one, for when a small part is hard to tap.
    var parentKey: String? {
        guard let k = selection, let slash = k.firstIndex(of: "/") else { return nil }
        let scr = k[..<slash], rest = k[k.index(after: slash)...]
        guard let dot = rest.lastIndex(of: ".") else { return nil }
        let p = "\(scr)/\(rest[..<dot])"
        return metas[p] != nil ? p : nil
    }

    func selectParent() { if let p = parentKey { select(key: p) } }

    /// Every editable element on the current screen, top to bottom, for the layers list.
    var layers: [LayerItem] {
        let prefix = screenKey + "/"
        return metas.compactMap { (k, m) -> LayerItem? in
            guard k.hasPrefix(prefix) || k.hasPrefix("all/"), let r = rects[k] else { return nil }
            let e = model.spec.edits[k]
            return LayerItem(key: k, meta: m, rect: r, edited: e != nil, hidden: e?.hidden ?? false)
        }.sorted { ($0.rect.minY, $0.rect.minX) < ($1.rect.minY, $1.rect.minX) }
    }

    func edit(_ key: String, _ name: String, _ kind: ElementKind, coalesce: String? = nil, _ change: @escaping (inout ElementEdit) -> Void) {
        let scr = String(key.split(separator: "/").first ?? Substring(screen.rawValue))
        model.update(key: coalesce) { spec in
            var e = spec.edits[key] ?? ElementEdit(screen: scr, name: name, kind: kind)
            change(&e)
            if e.isDefault { spec.edits[key] = nil } else { spec.edits[key] = e }
        }
    }

    func editSelected(coalesce: String? = nil, _ change: @escaping (inout ElementEdit) -> Void) {
        guard let k = selection else { return }
        edit(k, selName, selKind, coalesce: coalesce, change)
    }

    var selectedEdit: ElementEdit { selection.flatMap { model.spec.edits[$0] } ?? ElementEdit() }

    var editCountThisScreen: Int { model.spec.edits.keys.filter { $0.hasPrefix(screenKey + "/") }.count }

    /// Draws a box on an imported screenshot and turns what is inside into its own layer.
    func cut(rect: CGRect) {
        guard rect.width >= 6, rect.height >= 6 else { return }
        if let key = model.cutOut(rectPt: rect) {
            selection = key; selName = "Cut out piece"; selKind = .image
            cutMode = false
        } else { Haptics.snap() }
    }

    /// The imported layer behind the selected element, if it is one.
    var selectedImport: (ImportedScreen, ImportedElement)? {
        guard let k = selection, k.hasPrefix("imported/") else { return nil }
        let rest = k.dropFirst("imported/".count)
        guard let dot = rest.firstIndex(of: ".") else { return nil }
        let key6 = String(rest[..<dot]), elID = String(rest[rest.index(after: dot)...])
        guard let imp = model.spec.imports.first(where: { $0.key == key6 }), let el = imp.elements.first(where: { $0.id == elID }) else { return nil }
        return (imp, el)
    }

    func resetScreen() {
        let prefix = screenKey + "/"
        model.update { s in s.edits = s.edits.filter { !$0.key.hasPrefix(prefix) } }
        selection = nil
    }
}

/// Wraps one part of a sample screen so the person can move, resize and restyle it.
/// While a finger or slider is active, the change lives in a LiveBox and only this element redraws.
struct Editable<Content: View>: View {
    let id: String
    let name: String
    let kind: ElementKind
    var shared = false          // edit applies on every screen (for example the tab bar)
    var selectable = true       // large backdrops ignore taps so they never steal selection from what is on top
    var keepWhenHidden = false  // parts that draw their own empty look when details are hidden
    @ViewBuilder var content: (ElementEdit) -> Content

    @Environment(\.screenEdit) private var env
    @Environment(\.editor) private var editor
    @Environment(\.previewScale) private var pscale
    @Environment(\.hideDetails) private var hideDetails
    @State private var size: CGSize = .zero

    var body: some View {
        let key = (shared ? "all" : env.screen) + "/" + id
        let e = env.edits[key] ?? ElementEdit()
        if e.hidden && editor == nil {
            EmptyView()
        } else {
            let box = editor?.box(key)
            let live = box?.value
            let selected = editor?.selection == key
            // With details hidden, text, icons and pictures stay in the layout but are not drawn.
            let hidden = hideDetails && !keepWhenHidden && (kind == .text || kind == .glyph || kind == .image)
            let dx = live?.dx ?? e.dx, dy = live?.dy ?? e.dy, sc = live?.scale ?? e.scale
            let unit = 1 / max(pscale * sc, 0.05)
            // Small things get a bigger invisible touch area so they are easy to grab.
            let hitPad = env.screen == "imported"
                ? min(5, max(0, (28 - min(size.width, size.height)) / 2))
                : min(14, max(0, (44 / max(pscale * sc, 0.05) - min(size.width, size.height)) / 2))
            content(e)
                .background(GeometryReader { g in
                    let f = g.frame(in: .named("sample"))
                    let vw = g.size.width * sc, vh = g.size.height * sc
                    Color.clear
                        .preference(key: ElementFramesKey.self, value: [key: ElementFrame(name: name, kind: kind, rect: CGRect(x: f.midX - vw / 2 + dx * 0, y: f.midY - vh / 2, width: vw, height: vh))])
                        .onAppear { size = g.size; report(key, f, g.size, sc) }
                        .onChange(of: g.size) { _, n in size = n; report(key, f, n, sc) }
                        .onChange(of: f) { _, nf in report(key, nf, g.size, sc) }
                        .onChange(of: sc) { _, ns in report(key, f, g.size, ns) }
                })
                .overlay {
                    if editor != nil {
                        ZStack(alignment: .bottomTrailing) {
                            if selected {
                                RoundedRectangle(cornerRadius: 6 * unit)
                                    .strokeBorder(Chrome.indigo, style: StrokeStyle(lineWidth: 2 * unit, dash: [6 * unit, 4 * unit]))
                                    .allowsHitTesting(false)
                                resizeHandle(key: key, e: e, unit: unit)
                            } else if editor?.showOutlines == true {
                                RoundedRectangle(cornerRadius: 6 * unit).strokeBorder(Chrome.indigo.opacity(0.22), lineWidth: 1 * unit).allowsHitTesting(false)
                            }
                        }
                    }
                }
                .scaleEffect(sc)
                .offset(x: dx, y: dy)
                .opacity(hidden ? 0 : (e.hidden ? 0.25 : 1))
                .zIndex(selected ? 10 : 0)
                .modifier(EditGestures(editor: editor, key: key, name: name, kind: kind, e: e, pscale: pscale, box: box, hitPad: hitPad, enabled: (selectable || selected) && !hidden))
        }
    }

    private func report(_ key: String, _ f: CGRect, _ s: CGSize, _ sc: Double) {
        guard let editor else { return }
        let w = s.width * sc, h = s.height * sc
        editor.register(key, name, kind, CGRect(x: f.midX - w / 2, y: f.midY - h / 2, width: w, height: h))
    }

    private func resizeHandle(key: String, e: ElementEdit, unit: CGFloat) -> some View {
        Circle().fill(Chrome.indigo)
            .overlay(Image(systemName: "arrow.up.left.and.arrow.down.right").font(.system(size: 11 * unit, weight: .bold)).foregroundStyle(.white))
            .frame(width: 26 * unit, height: 26 * unit)
            .padding(-10 * unit)
            .contentShape(Circle().inset(by: -12 * unit))
            .offset(x: 6 * unit, y: 6 * unit)
            .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global)
                .onChanged { v in
                    guard let editor else { return }
                    let ns = newScale(e.scale, v.translation)
                    if ns == 1 && !editor.scaleSnapped { Haptics.snap() }
                    editor.scaleSnapped = ns == 1
                    editor.box(key).value = LiveEdit(dx: e.dx, dy: e.dy, scale: ns)
                }
                .onEnded { v in
                    guard let editor else { return }
                    let ns = newScale(e.scale, v.translation)
                    editor.edit(key, name, kind) { $0.scale = ns }
                    editor.scaleSnapped = false
                    editor.box(key).value = nil
                })
    }

    private func newScale(_ start: Double, _ t: CGSize) -> Double {
        let delta = (t.width + t.height) / max(pscale, 0.05)
        let v = min(3, max(0.3, start * (1 + delta / max(size.width + size.height, 40))))
        return abs(v - 1) < 0.04 ? 1 : (v * 100).rounded() / 100
    }
}

private struct EditGestures: ViewModifier {
    let editor: EditorContext?
    let key: String, name: String
    let kind: ElementKind
    let e: ElementEdit
    let pscale: CGFloat
    let box: LiveBox?
    let hitPad: CGFloat
    let enabled: Bool

    func body(content: Content) -> some View {
        if let editor, let box, enabled {
            content
                .contentShape(Rectangle().inset(by: -hitPad))
                .onTapGesture { editor.select(key, name, kind) }
                .gesture(DragGesture(minimumDistance: 3, coordinateSpace: .global)
                    .onChanged { v in
                        editor.select(key, name, kind)
                        editor.beginDrag(key)
                        let d = CGSize(width: v.translation.width / max(pscale, 0.05), height: v.translation.height / max(pscale, 0.05))
                        let o = editor.snappedOffset(key: key, start: CGSize(width: e.dx, height: e.dy), delta: d)
                        box.value = LiveEdit(dx: o.width, dy: o.height, scale: box.value?.scale ?? e.scale)
                    }
                    .onEnded { v in
                        let d = CGSize(width: v.translation.width / max(pscale, 0.05), height: v.translation.height / max(pscale, 0.05))
                        let o = editor.snappedOffset(key: key, start: CGSize(width: e.dx, height: e.dy), delta: d, haptics: false)
                        editor.edit(key, name, kind) { $0.dx = o.width; $0.dy = o.height }
                        editor.endDrag()
                        box.value = nil
                    })
        } else {
            content
        }
    }
}
