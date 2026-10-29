import SwiftUI
import Observation

enum AppTab: Hashable { case discover, gallery, studio, library }
enum GallerySort: String, CaseIterable { case fit = "Fit", name = "Name", accessibility = "Accessibility", richness = "Richness" }

@Observable @MainActor
final class AppModel {
    var spec: DesignSpec
    let store: DesignStore
    var tab: AppTab = .discover
    var briefDone: Bool { didSet { UserDefaults.standard.set(briefDone, forKey: "briefDone") } }
    var gallerySort: GallerySort = .name
    var exportSpec: DesignSpec?
    var detailStyle: StyleID?
    var showImport = false
    var galleryScreen: SampleScreen = .home
    var galleryApp: SampleApp = .wallet
    var notice: String?
    var requestedScreen: SampleScreen?
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    @ObservationIgnored private var undoStack: [DesignSpec] = []
    @ObservationIgnored private var redoStack: [DesignSpec] = []
    @ObservationIgnored private var lastKey: String?
    @ObservationIgnored private var lastTime = Date.distantPast
    @ObservationIgnored private var saveTask: Task<Void, Never>?

    init(store: DesignStore = DesignStore()) {
        self.store = store
        self.spec = store.loadCurrent() ?? DesignSpec()
        self.briefDone = UserDefaults.standard.bool(forKey: "briefDone")
    }

    var ranking: [StyleScore] { StyleRanker.rank(spec.brief) }
    func percent(for style: StyleID) -> Int? {
        briefDone ? ranking.first { $0.style == style }?.percent : nil
    }

    func update(key: String? = nil, _ change: (inout DesignSpec) -> Void) {
        let now = Date()
        var new = spec
        change(&new)
        guard new != spec else { return }
        if !(key != nil && key == lastKey && now.timeIntervalSince(lastTime) < 1.0) {
            undoStack.append(spec)
            if undoStack.count > 100 { undoStack.removeFirst() }
        }
        redoStack.removeAll()
        new.updatedAt = now
        spec = new
        lastKey = key; lastTime = now
        scheduleSave()
    }

    func binding<V>(_ kp: WritableKeyPath<DesignSpec, V>, key: String? = nil) -> Binding<V> {
        Binding(get: { self.spec[keyPath: kp] }, set: { v in self.update(key: key) { $0[keyPath: kp] = v } })
    }

    func undo() {
        guard let prev = undoStack.popLast() else { return }
        redoStack.append(spec); spec = prev; lastKey = nil; scheduleSave()
    }
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(spec); spec = next; lastKey = nil; scheduleSave()
    }

    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            self.store.saveCurrent(self.spec)
            // A named project is kept up to date in the Library as you edit.
            if self.isSavedProject { self.store.save(self.spec) }
        }
    }

    // MARK: projects

    /// True once the open design has a name and lives in the Library.
    var isSavedProject: Bool { store.designs.contains { $0.id == spec.id } }

    func suggestedProjectName() -> String {
        if spec.name != "Untitled design" && !spec.name.isEmpty { return spec.name }
        let base = spec.brief.appName.isEmpty ? spec.app.shortTitle : spec.brief.appName
        return base + " " + StyleCatalog.info(spec.style).name
    }

    func createProject(name: String) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        spec.name = n.isEmpty ? suggestedProjectName() : n
        spec.updatedAt = Date()
        store.save(spec); store.saveCurrent(spec)
        Haptics.success()
    }

    func saveProject() {
        spec.updatedAt = Date()
        store.save(spec); store.saveCurrent(spec)
        Haptics.success()
        showNotice("Saved to your Library.")
    }

    func renameProject(_ name: String) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        update { $0.name = n }
        if isSavedProject { store.save(spec) }
    }

    /// Renames any saved design, including the one open in Studio.
    func renameDesign(_ id: UUID, to name: String) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        if id == spec.id { renameProject(n) } else { store.rename(id, to: n) }
        Haptics.success()
    }

    func duplicateProject() {
        let copy = store.duplicate(spec)
        open(copy)
        showNotice("Duplicated. You are editing the copy.")
    }

    /// Removes the open project from the Library and starts over from the Gallery.
    func deleteProject() {
        let id = spec.id
        let importIDs = spec.imports.map(\.id)
        store.delete(id)
        for imp in importIDs where !store.designs.contains(where: { d in d.imports.contains { $0.id == imp } }) { ImportStore.delete(imp) }
        var fresh = DesignSpec(); fresh.brief = spec.brief
        spec = fresh
        undoStack = []; redoStack = []; lastKey = nil
        scheduleSave()
        tab = .gallery
        showNotice("Project deleted.")
    }

    func apply(_ action: SuggestionAction) {
        update { action.apply(to: &$0) }
        Haptics.select()
    }

    /// Switches the style of the project that is open in Studio.
    func useStyle(_ style: StyleID, openStudio: Bool = true) {
        update { $0.style = style; if $0.compareStyle == style { $0.compareStyle = nil } }
        Haptics.impact()
        if openStudio { tab = .studio }
    }

    /// Starts a fresh project from a style. If the open design was changed, it is saved to the Library first
    /// so nothing is lost and the new project never inherits its edits.
    func startProject(style: StyleID, mode: AppearanceMode? = nil, app: SampleApp? = nil) {
        var savedPrevious = false
        if spec.hasCustomizations && !isSavedProject {
            var old = spec
            if old.name == "Untitled design" { old.name = StyleCatalog.info(old.style).name + " design" }
            old.updatedAt = Date()
            store.save(old); savedPrevious = true
        }
        var new = DesignSpec()
        new.brief = spec.brief
        new.style = style
        new.app = app ?? spec.app
        new.screens = Array(new.app.screens.prefix(2))
        new.mode = mode ?? (spec.brief.context == .night ? .dark : .light)
        let base = new.brief.appName.isEmpty ? "" : new.brief.appName + " "
        new.name = base + StyleCatalog.info(style).name
        spec = new
        undoStack = []; redoStack = []; lastKey = nil
        scheduleSave()
        Haptics.impact()
        tab = .studio
        if savedPrevious { showNotice("Your previous design was saved to the Library.") }
    }

    func showNotice(_ text: String) {
        notice = text
        Task { try? await Task.sleep(for: .seconds(3)); if notice == text { notice = nil } }
    }

    func resetAllEdits() { update { $0.edits = [:] } }

    func finishBrief(_ brief: Brief) {
        update { $0.brief = brief }
        briefDone = true
        gallerySort = .fit
    }

    func openInStudio(style: StyleID) { startProject(style: style) }

    func open(_ design: DesignSpec) {
        spec = design; undoStack = []; redoStack = []; scheduleSave(); tab = .studio
    }

    func newDesign() {
        spec = DesignSpec(); undoStack = []; redoStack = []; briefDone = false; scheduleSave(); tab = .discover
    }

    /// Stores a finished import and sends the person to the editor with it open.
    func addImport(_ r: ImportResult) {
        let id = r.screen.id
        ImportStore.write(r.plate, id: id, file: r.screen.plateFile)
        ImportStore.write(r.original, id: id, file: r.screen.originalFile)
        for c in r.crops { ImportStore.write(c.data, id: id, file: c.file) }
        update {
            $0.imports.append(r.screen); $0.currentImport = id
            if !$0.screens.contains(.imported) { $0.screens.append(.imported) }
        }
        Haptics.success()
        showImport = false
        tab = .studio
        requestedScreen = .imported
    }

    func deleteImport(_ id: UUID) {
        let prefix = "imported/" + String(id.uuidString.prefix(6)) + "."
        update { s in
            s.imports.removeAll { $0.id == id }
            s.edits = s.edits.filter { !$0.key.hasPrefix(prefix) }
            if s.currentImport == id { s.currentImport = s.imports.first?.id }
            if s.imports.isEmpty { s.screens.removeAll { $0 == .imported } }
        }
        ImportStore.delete(id)
    }

    /// Cuts a rectangle out of the imported screenshot into its own movable layer. Returns the new layer's edit key.
    @discardableResult
    func cutOut(rectPt: CGRect) -> String? {
        guard let imp = spec.activeImport, let plate = ImportStore.data(imp.id, imp.plateFile),
              let res = ImportEngine.cutRegion(plate: plate, screen: imp, rectPt: rectPt) else { return nil }
        // New file names keep older versions on disk, so undo still shows the right picture.
        let plateFile = "plate-" + String(UUID().uuidString.prefix(8)) + ".jpg"
        ImportStore.write(res.newPlate, id: imp.id, file: plateFile)
        ImportStore.write(res.crop, id: imp.id, file: res.element.file)
        update { s in
            if let i = s.imports.firstIndex(where: { $0.id == imp.id }) { s.imports[i].plateFile = plateFile; s.imports[i].elements.append(res.element) }
        }
        Haptics.success()
        return imp.editKey(res.element)
    }

    /// Removes the background of a picture layer with Apple's on device subject segmentation.
    func cutOutSubject(importID: UUID, elementID: String) {
        guard let imp = spec.imports.first(where: { $0.id == importID }), let el = imp.elements.first(where: { $0.id == elementID }),
              let data = ImportStore.data(importID, el.file), let out = ImportEngine.cutOutSubject(data) else {
            showNotice("No clear subject was found in that picture."); return
        }
        let file = "cut-" + String(UUID().uuidString.prefix(8)) + ".png"
        ImportStore.write(out, id: importID, file: file)
        update { s in
            if let i = s.imports.firstIndex(where: { $0.id == importID }), let j = s.imports[i].elements.firstIndex(where: { $0.id == elementID }) { s.imports[i].elements[j].file = file }
        }
        Haptics.success()
        showNotice("Background removed.")
    }

    func toggleCompare() {
        update { s in
            if s.compareStyle == nil {
                s.compareStyle = StyleID.allCases.first { $0 != s.style }
            } else { s.compareStyle = nil }
        }
    }
}

enum Haptics {
    static func impact() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
    /// A firm tick when something snaps into place or reaches its default value.
    static func snap() { UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9) }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

extension Color {
    static let canvas = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.102, green: 0.11, blue: 0.125, alpha: 1) : UIColor(red: 0.91, green: 0.922, blue: 0.941, alpha: 1) })
}

extension DesignSpec {
    func with(style: StyleID) -> DesignSpec { var c = self; c.style = style; c.compareStyle = nil; return c }
}
