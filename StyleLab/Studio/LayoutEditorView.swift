import SwiftUI

struct ScreenPickerMenu: View {
    @Binding var screen: SampleScreen
    var app: SampleApp = .wallet
    var onPickApp: ((SampleApp) -> Void)? = nil
    var showImports = true
    @Environment(AppModel.self) private var model
    var body: some View {
        Menu {
            if let onPickApp {
                Menu {
                    ForEach(SampleApp.allCases) { a in
                        Button { onPickApp(a); Haptics.select() } label: { Label(a.title, systemImage: a.icon) }
                    }
                } label: { Label("Sample app: \(app.shortTitle)", systemImage: app.icon) }
            }
            if showImports { Section("Imported") {
                ForEach(model.spec.imports) { imp in
                    Button { model.update { $0.currentImport = imp.id }; screen = .imported; Haptics.select() } label: { Label(imp.name, systemImage: "photo.on.rectangle") }
                }
                Button { model.showImport = true } label: { Label("Import screenshot", systemImage: "square.and.arrow.down") }
            } }
            Section(app.shortTitle) {
                ForEach(app.screens, id: \.self) { s in
                    Button { screen = s; Haptics.select() } label: { Label(s.title, systemImage: s.icon) }
                }
            }
            Menu {
                ForEach(SampleScreen.groups, id: \.self) { g in
                    Section(g) {
                        ForEach(SampleScreen.allCases.filter { $0.group == g && !app.screens.contains($0) }, id: \.self) { s in
                            Button { screen = s; Haptics.select() } label: { Label(s.title, systemImage: s.icon) }
                        }
                    }
                }
            } label: { Label("More screens", systemImage: "square.grid.2x2") }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: screen.icon)
                Text(screen.title).lineLimit(1)
                Image(systemName: "chevron.up.chevron.down").font(.caption2)
            }
            .fixedSize()
            .font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
            .padding(.horizontal, 12).frame(minHeight: 36)
            .background(Capsule().fill(.thinMaterial))
            .frame(minHeight: 44)
        }
        .accessibilityLabel("Screen: \(screen.title)")
    }
}

/// Master editor: drag, resize and restyle any element of the sample screens.
struct LayoutEditorView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var screen: SampleScreen
    @State private var ctx: EditorContext?
    @State private var confirmAll = false
    @State private var zoom: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var pan: CGSize = .zero
    @State private var basePan: CGSize = .zero

    init(screen: SampleScreen) { _screen = State(initialValue: screen) }

    var body: some View {
        ZStack {
            StudioCanvas()
            VStack(spacing: 6) {
                topBar
                if let ctx {
                    canvas(ctx)
                    EditorInspector(ctx: ctx)
                }
            }
        }
        .confirmationDialog("Reset all layout edits?", isPresented: $confirmAll, titleVisibility: .visible) {
            Button("Reset all layout edits", role: .destructive) { model.resetAllEdits(); ctx?.selection = nil; Haptics.success() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Every moved, resized or restyled element on every screen goes back to its original look.") }
        .onAppear { if ctx == nil { ctx = EditorContext(model: model, screen: screen) } }
        .onChange(of: screen) { _, new in ctx?.screen = new; ctx?.selection = nil; ctx?.showOutlines = new != .imported; ctx?.cutMode = false; resetZoom() }
    }

    private func resetZoom() { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { zoom = 1; baseZoom = 1; pan = .zero; basePan = .zero } }

    private func canvas(_ ctx: EditorContext) -> some View {
        GeometryReader { g in
            PreviewCanvas(spec: model.spec, screen: screen, framed: true, zoom: zoom)
                .environment(\.editor, ctx)
                .offset(pan)
                .frame(width: g.size.width, height: g.size.height)
                .clipped()
                .contentShape(Rectangle())
                .onTapGesture { ctx.selection = nil }
                .gesture(DragGesture(minimumDistance: 8)
                    .onChanged { v in
                        guard zoom > 1 else { return }
                        let mx = g.size.width * (zoom - 1) / 2 + 40, my = g.size.height * (zoom - 1) / 2 + 40
                        pan = CGSize(width: min(max(basePan.width + v.translation.width, -mx), mx), height: min(max(basePan.height + v.translation.height, -my), my))
                    }
                    .onEnded { _ in basePan = pan })
                .simultaneousGesture(MagnifyGesture()
                    .onChanged { zoom = min(4, max(1, baseZoom * $0.magnification)) }
                    .onEnded { _ in baseZoom = zoom; if zoom <= 1.01 { resetZoom() } })
                .overlay(alignment: .bottomTrailing) { zoomControls }
                .overlay(alignment: .topLeading) { hint }
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder private var hint: some View {
        if ctx?.cutMode == true {
            Text("Drag a box around anything to cut it out as its own layer").font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 6)
                .background(Chrome.gradient, in: Capsule()).foregroundStyle(.white).padding(8).allowsHitTesting(false)
        } else if zoom > 1 {
            Text("Drag empty space to pan").font(.caption2.weight(.semibold)).padding(.horizontal, 8).padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule()).padding(8).allowsHitTesting(false)
        }
    }

    private var zoomControls: some View {
        HStack(spacing: 2) {
            Button { setZoom(zoom - 0.5) } label: { Image(systemName: "minus").frame(width: 36, height: 36) }.disabled(zoom <= 1)
            Text("\(Int((zoom * 100).rounded()))%").font(.caption.monospacedDigit().weight(.semibold)).frame(width: 42)
            Button { setZoom(zoom + 0.5) } label: { Image(systemName: "plus").frame(width: 36, height: 36) }.disabled(zoom >= 4)
        }
        .foregroundStyle(Chrome.indigo)
        .background(.thinMaterial, in: Capsule()).padding(8)
        .accessibilityElement(children: .contain).accessibilityLabel("Zoom")
    }

    private func setZoom(_ z: CGFloat) {
        let nz = min(4, max(1, z))
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { zoom = nz; baseZoom = nz; if nz == 1 { pan = .zero; basePan = .zero } }
        Haptics.select()
    }

    private var topBar: some View {
        HStack(spacing: 8) {
            Button { dismiss() } label: { Text("Done").frame(minHeight: 36) }.buttonStyle(ChromePrimaryStyle(compact: true))
            Button { model.undo() } label: { Image(systemName: "arrow.uturn.backward").frame(width: 36, height: 36) }.buttonStyle(ChromeIconStyle()).disabled(!model.canUndo).accessibilityLabel("Undo")
            Button { model.redo() } label: { Image(systemName: "arrow.uturn.forward").frame(width: 36, height: 36) }.buttonStyle(ChromeIconStyle()).disabled(!model.canRedo).accessibilityLabel("Redo")
            if let ctx, screen == .imported {
                Button { ctx.cutMode.toggle(); ctx.selection = nil; Haptics.select() } label: {
                    Image(systemName: "scissors").frame(width: 36, height: 36)
                        .foregroundStyle(ctx.cutMode ? Color.white : Chrome.indigo)
                        .background(ctx.cutMode ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color.clear), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }.buttonStyle(ChromeIconStyle()).accessibilityLabel("Cut out an area").accessibilityValue(ctx.cutMode ? "On" : "Off")
            }
            Spacer(minLength: 4)
            ScreenPickerMenu(screen: $screen, app: model.spec.app)
            if let ctx {
                Menu {
                    Toggle(isOn: Binding(get: { ctx.autoAlign }, set: { ctx.autoAlign = $0; Haptics.select() })) { Label("Auto align", systemImage: "rectangle.split.2x2") }
                    Toggle(isOn: Binding(get: { ctx.showOutlines }, set: { ctx.showOutlines = $0; Haptics.select() })) { Label("Show outlines of all parts", systemImage: "square.dashed") }
                    Divider()
                    Button { ctx.resetScreen(); Haptics.success() } label: { Label("Reset edits on this screen", systemImage: "arrow.counterclockwise") }
                        .disabled(ctx.editCountThisScreen == 0)
                    Button(role: .destructive) { confirmAll = true } label: { Label("Reset all layout edits", systemImage: "trash") }
                        .disabled(model.spec.edits.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle").frame(width: 36, height: 36)
                        .foregroundStyle(Chrome.indigo)
                        .background(Chrome.indigo.opacity(0.11), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .frame(minHeight: 44)
                }.accessibilityLabel("More editor options")
            }
        }
        .padding(.horizontal, 12).padding(.top, 6)
    }
}

/// The element panel. Small by default so the canvas stays big, and it grows when you need every option.
struct EditorInspector: View {
    @Environment(AppModel.self) private var model
    let ctx: EditorContext
    @State private var full = false
    @State private var pickIcon = false
    @State private var showLayers = false

    private func bind<V>(_ get: @escaping (ElementEdit) -> V, key: String? = nil, _ set: @escaping (inout ElementEdit, V) -> Void) -> Binding<V> {
        Binding(get: { get(ctx.selectedEdit) }, set: { v in ctx.editSelected(coalesce: key) { set(&$0, v) } })
    }

    private var hasText: Bool {
        switch ctx.selKind {
        case .text, .button, .chip, .icon, .glyph, .row: true
        case .shape, .image, .control: false
        case .card: ["Search", "Message", "Product", "Action tile"].contains { ctx.selName.hasPrefix($0) }
        }
    }
    private var hasWeight: Bool { [.shape, .image, .control].contains(ctx.selKind) ? false : (ctx.selKind != .card || hasText) }
    private var hasBackground: Bool { ![.text, .glyph, .row, .image, .control].contains(ctx.selKind) }
    private var hasBadge: Bool { ctx.selKind == .icon || ctx.selKind == .glyph }
    private var hasIcon: Bool { ctx.selKind == .icon || ctx.selKind == .glyph }
    private var hasColor: Bool { ctx.selKind == .control ? ctx.selName.hasPrefix("Progress bar") : (ctx.selKind != .shape && (ctx.selKind != .card || ctx.selName.hasPrefix("Search"))) }
    private var colorTitle: String {
        ctx.selKind == .icon || ctx.selKind == .glyph ? "Icon color" : (ctx.selKind == .image ? "Tint color (single color icons)" : "Text color")
    }

    private var height: CGFloat { ctx.selection == nil ? 150 : (full ? 420 : 250) }

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 44, height: 5)
                .frame(maxWidth: .infinity).frame(height: 24).contentShape(Rectangle())
                .onTapGesture { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { full.toggle() } }
                .gesture(DragGesture(minimumDistance: 8).onEnded { v in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { full = v.translation.height < 0 }
                })
                .accessibilityLabel(full ? "Show fewer options" : "Show all options").accessibilityAddTraits(.isButton)
            header.padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if ctx.selection == nil { empty } else if full { fullControls } else { quickControls }
                }
                .padding(.horizontal).padding(.top, 6).padding(.bottom, 24)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: height)
        .background(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous).fill(Color(.systemGroupedBackground)).ignoresSafeArea(edges: .bottom))
        .sheet(isPresented: $pickIcon) { IconPickerView(current: ctx.selectedEdit.icon) { name in ctx.editSelected { $0.icon = name } } }
        .sheet(isPresented: $showLayers) { LayersSheet(ctx: ctx) }
        .onChange(of: ctx.selection) { _, new in if new == nil { full = false } }
    }

    // MARK: header

    @ViewBuilder private var header: some View {
        let e = ctx.selectedEdit
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text(ctx.selection == nil ? "Master edit" : ctx.selName).font(.subheadline.weight(.bold)).lineLimit(1)
                Text(ctx.selection == nil ? "Tap a part to select it" : ctx.selKind.rawValue.capitalized).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Button { showLayers = true } label: { Image(systemName: "list.bullet.indent").frame(width: 38, height: 34) }
                .buttonStyle(ChromeIconStyle()).accessibilityLabel("Layers")
            if ctx.selection != nil {
                Button { ctx.selectParent() } label: { Image(systemName: "arrow.up.to.line").frame(width: 38, height: 34) }
                    .buttonStyle(ChromeIconStyle()).disabled(ctx.parentKey == nil).accessibilityLabel("Select the part that contains this")
                Button { ctx.editSelected { $0.hidden.toggle() } } label: { Image(systemName: e.hidden ? "eye.slash" : "eye").frame(width: 38, height: 34) }
                    .buttonStyle(ChromeIconStyle()).accessibilityLabel(e.hidden ? "Show element" : "Hide element")
                Button { ctx.editSelected { $0 = ElementEdit(screen: $0.screen, name: $0.name, kind: $0.kind) } } label: { Image(systemName: "arrow.uturn.backward").frame(width: 38, height: 34) }
                    .buttonStyle(ChromeIconStyle()).disabled(e.isDefault).accessibilityLabel("Reset this element")
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { full.toggle() } } label: { Image(systemName: full ? "chevron.down" : "slider.horizontal.3").frame(width: 38, height: 34) }
                    .buttonStyle(ChromeIconStyle()).accessibilityLabel(full ? "Fewer options" : "More options")
                Button { ctx.selection = nil } label: { Image(systemName: "xmark").frame(width: 38, height: 34) }
                    .buttonStyle(ChromeIconStyle()).accessibilityLabel("Deselect")
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Drag a part to move it. Drag its round handle to resize. Pinch the screen to zoom. Use the layers button if a part is hard to tap.")
                .font(.footnote).foregroundStyle(.secondary)
            if ctx.screen != .imported {
                let key = ctx.screenKey + "/background"
                ColorRow(title: "Screen background color", hex: Binding(get: { model.spec.edits[key]?.bgHex }, set: { v in ctx.edit(key, "Screen background", .shape) { $0.bgHex = v } }))
            }
        }
    }

    // MARK: compact controls

    @ViewBuilder private var quickControls: some View {
        SizeSlider(ctx: ctx)
        if hasWeight { weightPicker }
        if hasColor { ColorRow(title: colorTitle, hex: bind({ $0.fgHex }) { $0.fgHex = $1 }) }
        if hasBackground && !ctx.selectedEdit.bgHidden && !hasColor { ColorRow(title: ctx.selKind == .shape ? "Fill color" : "Background color", hex: bind({ $0.bgHex }) { $0.bgHex = $1 }) }
        if hasIcon {
            Button { pickIcon = true } label: { Label(ctx.selectedEdit.icon == nil ? "Change icon" : ctx.selectedEdit.icon ?? "", systemImage: "square.grid.2x2").frame(maxWidth: .infinity).frame(minHeight: 44) }
                .buttonStyle(ChromeSecondaryStyle())
        }
        if ctx.selKind == .image, let (imp, el) = ctx.selectedImport {
            Button { model.cutOutSubject(importID: imp.id, elementID: el.id) } label: { Label("Remove background (on device AI)", systemImage: "person.crop.rectangle").frame(maxWidth: .infinity).frame(minHeight: 44) }
                .buttonStyle(ChromeSecondaryStyle())
        }
        Text("Tap the sliders button above for text, background, number badge and exact position.").font(.caption).foregroundStyle(.secondary)
    }

    private var weightPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Weight").font(.caption).foregroundStyle(.secondary)
            Picker("Weight", selection: bind({ $0.weight }) { $0.weight = $1 }) {
                Text("Auto").tag(ElementWeight?.none)
                ForEach(ElementWeight.allCases, id: \.self) { Text($0.title).tag(ElementWeight?.some($0)) }
            }.pickerStyle(.segmented)
        }
    }

    // MARK: all controls

    @ViewBuilder private var fullControls: some View {
        let e = ctx.selectedEdit
        if hasText {
            TextField("Text", text: bind({ $0.text ?? "" }, key: "text") { $0.text = $1.isEmpty ? nil : $1 })
                .textFieldStyle(.roundedBorder).frame(minHeight: 44)
        }
        if hasIcon {
            Button { pickIcon = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: e.icon ?? "square.grid.2x2").font(.title3).frame(width: 30)
                    Text(e.icon == nil ? "Change icon" : e.icon ?? "").lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right").font(.footnote)
                }.frame(minHeight: 44)
            }.buttonStyle(ChromeSecondaryStyle())
        }
        if ctx.selKind == .image, let (imp, el) = ctx.selectedImport {
            Button { model.cutOutSubject(importID: imp.id, elementID: el.id) } label: { Label("Remove background (on device AI)", systemImage: "person.crop.rectangle").frame(maxWidth: .infinity).frame(minHeight: 44) }
                .buttonStyle(ChromeSecondaryStyle())
        }
        SizeSlider(ctx: ctx)
        if hasWeight { weightPicker }
        if hasColor { ColorRow(title: colorTitle, hex: bind({ $0.fgHex }) { $0.fgHex = $1 }) }
        if ctx.selKind == .shape {
            VStack(alignment: .leading, spacing: 2) {
                HStack { Text("Corner radius").font(.caption).foregroundStyle(.secondary); Spacer(); Text(e.radius.map { "\(fmt($0)) pt" } ?? "Original").font(.caption.monospacedDigit()).foregroundStyle(.secondary) }
                Slider(value: bind({ $0.radius ?? 12 }, key: "radius-" + (ctx.selection ?? "")) { $0.radius = ($1 * 10).rounded() / 10 }, in: 0...80).frame(minHeight: 36)
            }
        }
        if hasBackground {
            Toggle(ctx.selKind == .icon ? "Show icon background" : (ctx.selKind == .shape ? "Show shape" : "Show background"), isOn: bind({ !$0.bgHidden }) { $0.bgHidden = !$1 }).frame(minHeight: 40)
            if !e.bgHidden { ColorRow(title: ctx.selKind == .shape ? "Fill color" : "Background color", hex: bind({ $0.bgHex }) { $0.bgHex = $1 }) }
        }
        if hasBadge {
            Toggle("Number on icon", isOn: bind({ $0.badge != nil }) { $0.badge = $1 ? ($0.badge ?? 3) : nil }).frame(minHeight: 40)
            if let b = e.badge { Stepper("Number: \(b)", value: bind({ $0.badge ?? 0 }) { $0.badge = $1 }, in: 0...999).frame(minHeight: 40) }
        }
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Position").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("x \(fmt(e.dx))  y \(fmt(e.dy))").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                nudge("arrow.left", -1, 0); nudge("arrow.right", 1, 0); nudge("arrow.up", 0, -1); nudge("arrow.down", 0, 1)
                Button { ctx.editSelected { $0.dx = 0; $0.dy = 0 } } label: { Text("Reset position").frame(maxWidth: .infinity).frame(minHeight: 36) }
                    .buttonStyle(ChromeSecondaryStyle()).disabled(e.dx == 0 && e.dy == 0)
            }
        }
    }

    private func nudge(_ icon: String, _ x: Double, _ y: Double) -> some View {
        Button {
            let cur = ctx.selectedEdit
            if Int(cur.dx + x) == 0 && Int(cur.dy + y) == 0 { Haptics.snap() } else { Haptics.select() }
            ctx.editSelected(coalesce: "nudge") { $0.dx += x; $0.dy += y }
        } label: { Image(systemName: icon).frame(width: 40, height: 36) }
            .buttonStyle(ChromeIconStyle())
    }
}

/// Size slider that previews live on the one element and saves once when you let go.
struct SizeSlider: View {
    let ctx: EditorContext
    var body: some View {
        let key = ctx.selection ?? ""
        let box = ctx.box(key)
        let e = ctx.selectedEdit
        let current = box.value?.scale ?? e.scale
        VStack(alignment: .leading, spacing: 2) {
            HStack { Text("Size").font(.caption).foregroundStyle(.secondary); Spacer(); Text("\(String(format: "%.2f", current))x").font(.caption.monospacedDigit()).foregroundStyle(.secondary) }
            Slider(value: Binding(get: { current }, set: { v in
                var nv = (v * 100).rounded() / 100
                if abs(v - 1) < 0.03 { nv = 1; if (box.value?.scale ?? e.scale) != 1 { Haptics.snap() } }
                box.value = LiveEdit(dx: box.value?.dx ?? e.dx, dy: box.value?.dy ?? e.dy, scale: nv)
            }), in: 0.3...3) { editing in
                if !editing, let v = box.value {
                    ctx.editSelected { $0.scale = v.scale }
                    box.value = nil
                }
            }
            .frame(minHeight: 36)
        }
    }
}

/// Every editable part of the screen as a list, for selecting things that are tiny or hidden behind others.
struct LayersSheet: View {
    let ctx: EditorContext
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(ctx.layers) { item in
                Button { ctx.select(key: item.key); dismiss() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: icon(item.meta.kind)).frame(width: 26).foregroundStyle(Chrome.indigo)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.meta.name).font(.subheadline.weight(.semibold)).foregroundStyle(.primary).lineLimit(1)
                            Text("\(item.meta.kind.rawValue.capitalized), \(Int(item.rect.width)) by \(Int(item.rect.height)) pt").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if item.hidden { Image(systemName: "eye.slash").foregroundStyle(.secondary) }
                        if item.edited { Circle().fill(Chrome.indigo).frame(width: 8, height: 8).accessibilityLabel("Edited") }
                        if ctx.selection == item.key { Image(systemName: "checkmark").foregroundStyle(Chrome.indigo) }
                    }.frame(minHeight: 44)
                }
            }
            .navigationTitle("Layers").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
            .overlay { if ctx.layers.isEmpty { Text("Nothing to edit on this screen yet.").foregroundStyle(.secondary) } }
        }
        .presentationDetents([.medium, .large])
    }
    private func icon(_ k: ElementKind) -> String {
        switch k {
        case .text: "textformat"; case .icon, .glyph: "star.square"; case .card: "rectangle"; case .button: "capsule"
        case .chip: "tag"; case .row: "list.bullet"; case .shape: "square"; case .image: "photo"; case .control: "switch.2"
        }
    }
}

struct ColorRow: View {
    let title: String
    @Binding var hex: String?
    private let swatches = Palette.accents + ["#FFFFFF", "#000000", "#8E8E93", "#FFD93D", "#34C759"]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Button { hex = nil } label: {
                        Image(systemName: "nosign").frame(width: 34, height: 34)
                            .overlay(Circle().stroke(Color.primary, lineWidth: hex == nil ? 2 : 0).padding(-2))
                            .frame(minWidth: 44, minHeight: 44)
                    }.buttonStyle(.plain).accessibilityLabel("Default color")
                    ForEach(swatches, id: \.self) { s in
                        Button { hex = s; Haptics.select() } label: {
                            Circle().fill(RGB(hex: s).color).frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                                .overlay(Circle().stroke(Color.primary, lineWidth: hex?.uppercased() == s ? 2.5 : 0).padding(-3))
                                .frame(minWidth: 44, minHeight: 44)
                        }.buttonStyle(.plain).accessibilityLabel("Color \(s)")
                    }
                    ColorPicker("Custom", selection: Binding(
                        get: { RGB(hex: hex ?? "#2F6BFF").color },
                        set: { c in
                            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                            UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
                            hex = RGB(r: Double(r) * 255, g: Double(g) * 255, b: Double(b) * 255).hex
                        }), supportsOpacity: false).labelsHidden().frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }
}
