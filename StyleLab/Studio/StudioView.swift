import SwiftUI
import Photos

enum StudioTab: String, CaseIterable, Identifiable {
    case style = "Style", color = "Color", shape = "Shape", type = "Type", icons = "Icons", layout = "Layout", check = "Check"
    var id: String { rawValue }
}

struct StudioView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var hsc
    @Environment(\.accessibilityReduceTransparency) private var reduceT
    @Environment(\.colorSchemeContrast) private var contrast
    @State private var tab: StudioTab = .style
    @State private var screen: SampleScreen = .home
    @State private var saved = false
    @State private var fullscreen = false
    @State private var editing = false
    @State private var detent = 1          // 0 peek, 1 normal, 2 full
    @State private var confirmResetAll = false
    @State private var confirmDelete = false
    @State private var downloading: (Int, Int)?
    @State private var shareItems: [ScreenDownloader.Item] = []
    @State private var shareURLs: [URL] = []
    @State private var showShareAll = false
    @State private var renaming = false
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            Group {
                if editing || fullscreen {
                    Color.clear      // nothing redraws underneath a full screen cover while you edit
                } else if hsc == .regular {
                    HStack(spacing: 0) { previewArea.frame(maxWidth: .infinity); Divider(); panelContent(bottomInset: 110).background(Color(.systemGroupedBackground)).frame(width: 420) }
                } else {
                    GeometryReader { g in
                        let total = g.size.height
                        let heights: [CGFloat] = [150, total * 0.54, total]
                        ZStack(alignment: .bottom) {
                            VStack(spacing: 0) {
                                previewArea.frame(height: max(total - heights[detent], 0)).clipped()
                                    .opacity(detent == 2 ? 0 : 1)
                                    .allowsHitTesting(detent != 2)
                                Spacer(minLength: 0)
                            }
                            // The panel owns its own drag state, so sliding it never redraws the rest of Studio.
                            SlidingPanel(total: total, heights: heights, detent: $detent) {
                                panelContent(bottomInset: (total - heights[detent]) + 110)
                            }
                        }
                    }
                }
            }
            .background { StudioCanvas() }
            .confirmationDialog("Reset all tuning?", isPresented: $confirmResetAll, titleVisibility: .visible) {
                Button("Reset all tuning", role: .destructive) { model.update { $0.resetTuning() }; Haptics.success() }
                Button("Cancel", role: .cancel) {}
            } message: { Text("Accent, roundness, depth, contrast, type, icons, density and tab bar return to defaults. Style and mode stay.") }
            .overlay {
                if let d = downloading {
                    VStack(spacing: 10) {
                        ProgressView(value: Double(d.0), total: Double(max(d.1, 1)))
                        Text("Rendering screen \(min(d.0 + 1, d.1)) of \(d.1)").font(.subheadline.weight(.semibold))
                    }
                    .padding(20).frame(width: 240).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(radius: 16)
                }
            }
            .sheet(isPresented: $showShareAll) { ShareAllSheet(items: shareItems, urls: shareURLs) }
            .fullScreenCover(isPresented: $fullscreen) { FullscreenPreview(screen: screen) }
            .fullScreenCover(isPresented: $editing) { LayoutEditorView(screen: screen) }
            .onChange(of: model.requestedScreen) { _, new in
                guard let new else { return }
                screen = new; model.requestedScreen = nil
                if new == .imported { editing = true }
            }
            .onAppear { if let r = model.requestedScreen { screen = r; model.requestedScreen = nil; if r == .imported { editing = true } } }
            .sheet(isPresented: Binding(get: { model.tab == .studio && !model.isSavedProject }, set: { _ in })) { ProjectNameSheet() }
            .alert("Rename project", isPresented: $renaming) {
                TextField("Project name", text: $newName)
                Button("Save") { model.renameProject(newName) }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Delete this project?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete project", role: .destructive) { model.deleteProject() }
                Button("Cancel", role: .cancel) {}
            } message: { Text("\"\(model.spec.name)\" is removed from your Library. This cannot be undone.") }
            .navigationTitle(model.spec.name).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { model.tab = .gallery } label: { Label("Gallery", systemImage: "chevron.left") }
                    Button { model.undo() } label: { Label("Undo", systemImage: "arrow.uturn.backward") }.disabled(!model.canUndo)
                    Button { model.redo() } label: { Label("Redo", systemImage: "arrow.uturn.forward") }.disabled(!model.canRedo)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button { model.saveProject() } label: { Label("Save to Library", systemImage: "square.and.arrow.down") }
                        Button { newName = model.spec.name; renaming = true } label: { Label("Rename project", systemImage: "pencil") }
                        Button { model.toggleCompare() } label: { Label(model.spec.compareStyle == nil ? "Compare styles" : "Stop comparing", systemImage: "square.split.2x1") }
                        Button { model.duplicateProject() } label: { Label("Duplicate project", systemImage: "plus.square.on.square") }
                        Divider()
                        Button(role: .destructive) { confirmDelete = true } label: { Label("Delete project", systemImage: "trash") }
                    } label: { Label("Project", systemImage: "ellipsis.circle") }
                    Button { model.exportSpec = model.spec } label: { Text("Export") }.buttonStyle(ChromePrimaryStyle(compact: true))
                }
            }
        }
    }

    private var previewArea: some View {
        VStack(spacing: 8) {
            HStack {
                ScreenPickerMenu(screen: $screen, app: model.spec.app, onPickApp: { a in model.update { $0.app = a; $0.screens = Array(a.screens.prefix(2)) }; screen = a.mainScreen })
                Spacer()
                Button { editing = true; Haptics.impact() } label: { Label("Edit", systemImage: "hand.draw").frame(minHeight: 36) }
                    .buttonStyle(ChromePrimaryStyle(compact: true)).accessibilityLabel("Edit layout")
                Menu {
                    Button { downloadAll() } label: { Label("Download all \(model.spec.app.screens.count) screens", systemImage: "square.and.arrow.down.on.square") }
                    Button { shareAll() } label: { Label("Share or save all as files", systemImage: "square.and.arrow.up") }
                    Divider()
                    Button { capture() } label: { Label("Save this screen to Photos", systemImage: "camera") }
                } label: {
                    Image(systemName: saved ? "checkmark" : "arrow.down.to.line").frame(width: 36, height: 36)
                        .foregroundStyle(Chrome.indigo)
                        .background(Chrome.indigo.opacity(0.11), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .frame(minHeight: 44)
                }.accessibilityLabel("Download screens")
                Button { model.update { $0.hideDetails.toggle() }; Haptics.select() } label: {
                    Image(systemName: "text.badge.xmark").frame(width: 36, height: 36)
                        .foregroundStyle(model.spec.hideDetails ? Color.white : Chrome.indigo)
                        .background(model.spec.hideDetails ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color.clear), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(ChromeIconStyle()).accessibilityLabel("Hide details, show empty tiles").accessibilityValue(model.spec.hideDetails ? "On" : "Off")
                Button { confirmResetAll = true } label: { Image(systemName: "arrow.counterclockwise").frame(width: 36, height: 36) }
                    .buttonStyle(ChromeIconStyle()).accessibilityLabel("Reset all tuning")
            }.padding(.horizontal).padding(.top, 8)
            if let second = model.spec.compareStyle {
                compareView(second)
            } else {
                PreviewCanvas(spec: model.spec, screen: screen, framed: true).padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture { fullscreen = true; Haptics.impact() }
                    .accessibilityHint("Double tap to maximize")
                HStack(spacing: 6) {
                    Circle().fill(RGB(hex: model.spec.accentHex).color).frame(width: 10, height: 10)
                    Text("\(StyleCatalog.info(model.spec.style).name)  \u{00B7}  \(model.spec.mode.title)  \u{00B7}  \(model.spec.app.shortTitle)\(model.isSavedProject ? "  \u{00B7}  Saved" : "")")
                        .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                }.padding(.bottom, 10)
            }
        }
    }

    @ViewBuilder private func compareView(_ second: StyleID) -> some View {
        let a = model.spec, b = model.spec.with(style: second)
        VStack(spacing: 4) {
            Menu {
                ForEach(StyleID.allCases.filter { $0 != a.style }) { s in Button(StyleCatalog.info(s).name) { model.update { $0.compareStyle = s } } }
            } label: { Label("Compare with: \(StyleCatalog.info(second).name)", systemImage: "chevron.up.chevron.down").font(.subheadline) }
            if hsc == .regular {
                HStack { PreviewCanvas(spec: a, screen: screen, framed: true); PreviewCanvas(spec: b, screen: screen, framed: true) }.padding(.horizontal).padding(.bottom, 8)
            } else {
                TabView {
                    PreviewCanvas(spec: a, screen: screen, framed: true).padding(.bottom, 30)
                    PreviewCanvas(spec: b, screen: screen, framed: true).padding(.bottom, 30)
                }.tabViewStyle(.page)
            }
        }
    }

    /// The tab chips and the controls. Dragging happens only on the handle above, never on the chips.
    private func panelContent(bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(StudioTab.allCases) { t in
                        Button { tab = t; Haptics.select() } label: {
                            Text(t.rawValue).font(.subheadline.weight(tab == t ? .semibold : .regular)).foregroundStyle(tab == t ? Color.white : Color.primary)
                                .padding(.horizontal, 14).frame(minHeight: 36)
                                .background { if tab == t { Capsule().fill(Chrome.gradient) } }
                                .frame(minHeight: 44)
                        }.buttonStyle(.plain).accessibilityAddTraits(tab == t ? .isSelected : [])
                    }
                }.padding(.horizontal)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if tab != .check { SuggestionsCard() }
                    if tab != .style { TabResetButton(tab: tab) }
                    switch tab {
                    case .style: StyleControls()
                    case .color: ColorControls()
                    case .shape: ShapeControls()
                    case .type: TypeControls()
                    case .icons: IconControls()
                    case .layout: LayoutControls()
                    case .check: CheckControls()
                    }
                }.padding()
            }
            .contentMargins(.bottom, bottomInset, for: .scrollContent)
        }
    }

    /// One tap: renders every screen of the sample app and saves them all to Photos.
    private func downloadAll() {
        guard downloading == nil else { return }
        let spec = model.spec
        Haptics.impact()
        downloading = (0, spec.app.screens.count)
        Task {
            let items = await ScreenDownloader.renderAll(spec: spec) { i, n in downloading = (i, n) }
            let ok = await ScreenDownloader.saveToPhotos(items.map(\.image))
            downloading = nil
            if ok { Haptics.success(); model.showNotice("Saved \(items.count) \(spec.app.shortTitle) screens to Photos.") }
            else { model.showNotice("Photos access is needed. Use Share or save all as files instead.") }
        }
    }

    private func shareAll() {
        guard downloading == nil else { return }
        let spec = model.spec
        downloading = (0, spec.app.screens.count)
        Task {
            let items = await ScreenDownloader.renderAll(spec: spec) { i, n in downloading = (i, n) }
            shareItems = items
            shareURLs = ScreenDownloader.writeFiles(items, id: spec.id)
            downloading = nil
            showShareAll = true
        }
    }

    private func capture() {
        let spec = model.spec, scr = screen
        if let img = ScreenshotRenderer.image(spec: spec, screen: scr) {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            Haptics.success(); saved = true
            Task { try? await Task.sleep(for: .seconds(2)); saved = false }
        }
    }
}

struct SuggestionsCard: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let list = SuggestionEngine.suggestions(for: model.spec)
        VStack(alignment: .leading, spacing: 10) {
            Label("Suggestions", systemImage: "lightbulb").font(.headline)
            if list.isEmpty {
                Text("Nothing to flag. This design passes all checks.").font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(list) { s in
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.title).font(.subheadline.weight(.semibold))
                    Text(s.reasoning).font(.footnote).foregroundStyle(.secondary)
                    ForEach(s.actions, id: \.label) { a in
                        Button(a.label) { model.apply(a) }.buttonStyle(ChromeSecondaryStyle()).frame(minHeight: 44)
                    }
                }
                if s.id != list.last?.id { Divider() }
            }
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading)
        .chromeCard()
    }
}

func sectionBox<C: View>(_ title: String? = nil, @ViewBuilder _ content: () -> C) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        if let title { Text(title).font(.headline) }
        content()
    }
    .padding().frame(maxWidth: .infinity, alignment: .leading)
    .chromeCard()
}

extension DesignSpec {
    /// Puts only the settings of one Studio tab back to their defaults.
    mutating func reset(_ tab: StudioTab) {
        let d = DesignSpec()
        switch tab {
        case .style: break
        case .color: accentHex = d.accentHex
        case .shape: radiusScale = d.radiusScale; depth = d.depth
        case .type: typeface = d.typeface
        case .icons: iconWeight = d.iconWeight
        case .layout: density = d.density; tabBar = d.tabBar
        case .check: boostContrast = d.boostContrast
        }
    }
    func isModified(in tab: StudioTab) -> Bool { var c = self; c.reset(tab); return c != self }
}

struct TabResetButton: View {
    @Environment(AppModel.self) private var model
    let tab: StudioTab
    var body: some View {
        let changed = model.spec.isModified(in: tab)
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { model.update { $0.reset(tab) } }
            Haptics.select()
        } label: {
            Label("Reset \(tab.rawValue.lowercased()) settings", systemImage: "arrow.uturn.backward.circle")
                .frame(maxWidth: .infinity).frame(minHeight: 44)
        }
        .buttonStyle(ChromeSecondaryStyle())
        .disabled(!changed).opacity(changed ? 1 : 0.45)
        .accessibilityHint(changed ? "Restores the defaults for this tab only" : "Nothing changed in this tab")
    }
}

struct FullscreenPreview: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State var screen: SampleScreen
    @State private var zoom: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero

    init(screen: SampleScreen) { _screen = State(initialValue: screen) }

    var body: some View {
        ZStack {
            StudioCanvas()
            VStack(spacing: 10) {
                HStack {
                    ScreenPickerMenu(screen: $screen, app: model.spec.app)
                    Spacer()
                    if zoom != 1 {
                        Button { withAnimation(.spring) { zoom = 1; baseZoom = 1; offset = .zero; baseOffset = .zero } } label: { Text("Fit").frame(minHeight: 36) }.buttonStyle(ChromeSecondaryStyle())
                    }
                    Button { dismiss() } label: { Image(systemName: "arrow.down.right.and.arrow.up.left").frame(width: 36, height: 36) }
                        .buttonStyle(ChromeIconStyle()).accessibilityLabel("Close full screen")
                }.padding(.horizontal)
                PreviewCanvas(spec: model.spec, screen: screen, framed: true)
                    .scaleEffect(zoom).offset(offset)
                    .gesture(MagnifyGesture().onChanged { zoom = max(1, min(4, baseZoom * $0.magnification)) }.onEnded { _ in baseZoom = zoom; if zoom == 1 { offset = .zero; baseOffset = .zero } })
                    .simultaneousGesture(DragGesture().onChanged { if zoom > 1 { offset = CGSize(width: baseOffset.width + $0.translation.width, height: baseOffset.height + $0.translation.height) } }.onEnded { _ in baseOffset = offset })
                    .onTapGesture(count: 2) { withAnimation(.spring) { zoom = zoom > 1 ? 1 : 2; baseZoom = zoom; if zoom == 1 { offset = .zero; baseOffset = .zero } } }
                    .padding(.horizontal, 8)
                    .clipped()
                Text("Pinch or double tap to zoom").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}


/// A bottom sheet that slides between three heights. Its drag state is private so only this view updates while dragging.
struct SlidingPanel<Content: View>: View {
    let total: CGFloat
    let heights: [CGFloat]
    @Binding var detent: Int
    private let content: Content
    @State private var drag: CGFloat = 0

    init(total: CGFloat, heights: [CGFloat], detent: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.total = total; self.heights = heights; self._detent = detent; self.content = content()
    }

    var body: some View {
        let h = min(max(heights[detent] - drag, heights[0]), heights[2])
        VStack(spacing: 0) {
            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 44, height: 5)
                .frame(maxWidth: .infinity).frame(height: 36)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.interpolatingSpring(stiffness: 260, damping: 28)) { detent = detent == 2 ? 1 : 2 }
                    Haptics.impact()
                }
                .gesture(DragGesture(minimumDistance: 2)
                    .onChanged { drag = $0.translation.height }
                    .onEnded { v in
                        let target = heights[detent] - v.predictedEndTranslation.height * 0.5
                        let nearest = heights.indices.min { abs(heights[$0] - target) < abs(heights[$1] - target) } ?? 1
                        let changed = nearest != detent
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 28)) { detent = nearest; drag = 0 }
                        if changed { Haptics.impact() }
                    })
                .accessibilityLabel("Resize controls panel").accessibilityAddTraits(.isButton)
            content
        }
        .frame(height: total)
        .background(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
            .fill(Color(.systemGroupedBackground)).ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            LinearGradient(colors: [.black.opacity(0), .black.opacity(0.10)], startPoint: .top, endPoint: .bottom)
                .frame(height: 18).offset(y: -18).allowsHitTesting(false)
        }
        .offset(y: total - h)
    }
}


/// Shown in Studio before any edit so every project has a name and is kept in the Library.
struct ProjectNameSheet: View {
    @Environment(AppModel.self) private var model
    @State private var name = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "folder.badge.plus").font(.system(size: 40)).foregroundStyle(Chrome.gradient)
                Text("Name your project").font(.system(.title2, design: .rounded, weight: .bold))
                Text("Your edits are saved to the Library under this name, so you can come back and keep editing any time.")
                    .font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label(StyleCatalog.info(model.spec.style).name, systemImage: "paintpalette")
                    Label(model.spec.app.shortTitle, systemImage: model.spec.app.icon)
                }.font(.caption.weight(.semibold)).foregroundStyle(Chrome.indigo)
                TextField("Project name", text: $name).textFieldStyle(.roundedBorder).frame(minHeight: 48).focused($focused).submitLabel(.done)
                    .onSubmit { create() }
                Button { create() } label: { Text("Create project").frame(maxWidth: .infinity).frame(minHeight: 48) }
                    .buttonStyle(ChromePrimaryStyle())
                Button { model.tab = .gallery } label: { Text("Back to Gallery").frame(maxWidth: .infinity).frame(minHeight: 44) }
                    .buttonStyle(ChromeSecondaryStyle())
                Spacer()
            }
            .padding(20)
            .chromeBackground()
            .onAppear { name = model.suggestedProjectName(); focused = true }
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled()
    }

    private func create() { model.createProject(name: name) }
}
