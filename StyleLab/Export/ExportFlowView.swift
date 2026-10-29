import SwiftUI
import UniformTypeIdentifiers

struct FolderDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.folder] }
    var wrapper: FileWrapper
    init(files: [(String, Data)]) {
        wrapper = FileWrapper(directoryWithFileWrappers: Dictionary(uniqueKeysWithValues: files.map { ($0.0, FileWrapper(regularFileWithContents: $0.1)) }))
    }
    init(configuration: ReadConfiguration) throws { wrapper = configuration.file }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { wrapper }
}

struct ExportFlowView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var draft: DesignSpec
    @State private var options: HandoffOptions
    @State private var step = 1
    @State private var copied = false
    @State private var files: [URL] = []
    @State private var pngs: [(String, Data)] = []
    @State private var exportingFolder = false
    @State private var photosSaved = false

    init(initial: DesignSpec) {
        var d = initial
        if d.name.isEmpty || d.name == "Untitled design" {
            d.name = (d.brief.appName.isEmpty ? "" : d.brief.appName + " ") + StyleCatalog.info(d.style).name
        }
        _draft = State(initialValue: d)
        var o = HandoffOptions()
        o.screens = d.app.screens + (d.imports.isEmpty ? [] : [.imported])
        _options = State(initialValue: o)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { i in
                        Capsule().fill(i <= step ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color.secondary.opacity(0.3))).frame(height: 5)
                    }
                }.padding(.horizontal).padding(.top, 8)
                Text("Step \(step) of 3").font(.footnote).foregroundStyle(.secondary).padding(.top, 4)
                switch step {
                case 1: satisfaction
                case 2: review
                default: share
                }
            }
            .chromeBackground()
            .navigationTitle("Export").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private var satisfaction: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: "hand.thumbsup.fill").font(.title).foregroundStyle(.white).frame(width: 56, height: 56)
                    .background(Chrome.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text("Are you happy with this design?").font(.system(.title2, design: .rounded, weight: .bold))
                HStack {
                    Button { step = 2 } label: { Text("Yes, export").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromePrimaryStyle())
                    Button { dismiss() } label: { Text("Not yet, keep editing").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromeSecondaryStyle())
                }
                Text("Design name").font(.headline)
                TextField("Design name", text: $draft.name).textFieldStyle(.roundedBorder).frame(minHeight: 44)
                Text("Anything still bothering you?").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                    ForEach(SatisfactionFlag.allCases, id: \.self) { f in
                        let on = draft.satisfaction.contains(f)
                        Button { if on { draft.satisfaction.removeAll { $0 == f } } else { draft.satisfaction.append(f) }; Haptics.select() } label: {
                            HStack(spacing: 4) { if on { Image(systemName: "checkmark") }; Text(f.chipTitle) }
                                .font(.subheadline).frame(maxWidth: .infinity, minHeight: 44)
                                .background(Capsule().fill(on ? Color.accentColor.opacity(0.2) : Color(.secondarySystemGroupedBackground)))
                        }.buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                Text("Anything else Claude Code should know?").font(.headline)
                TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(3...8).textFieldStyle(.roundedBorder)
            }.padding()
        }
    }

    private var review: some View {
        VStack(spacing: 0) {
            ScrollView {
                sectionBox("Include sections") {
                    Toggle("Colors, shape, type and icons", isOn: $options.tokens)
                    Toggle("Components and bottom bar", isOn: $options.components)
                    Toggle("Light and dark values", isOn: $options.appearance)
                    if draft.hideDetails {
                        Label("Details are hidden, so the text covers design values only and nothing about screen content.", systemImage: "text.badge.xmark")
                            .font(.footnote).foregroundStyle(.secondary)
                    } else {
                        Toggle("Screen by screen description", isOn: $options.describeScreens)
                        if !draft.imports.isEmpty { Toggle("Imported screens", isOn: $options.imports) }
                    }
                    Toggle("Contrast measurements", isOn: $options.accessibility)
                    Toggle("JSON block", isOn: $options.json)
                    Toggle("Include screenshots", isOn: $options.includeScreenshots)
                    Text("The description covers every screen of the \(draft.app.shortTitle) sample. Choose which screenshots to include as pictures.").font(.caption).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 6)], spacing: 6) {
                        ForEach(draft.app.screens + (draft.imports.isEmpty ? [] : [.imported]), id: \.self) { s in
                            let on = options.screens.contains(s)
                            Button {
                                if on { if options.screens.count > 1 { options.screens.removeAll { $0 == s } } } else { options.screens.append(s) }
                                options.screens.sort { (draft.app.screens.firstIndex(of: $0) ?? 999) < (draft.app.screens.firstIndex(of: $1) ?? 999) }
                            } label: {
                                HStack(spacing: 4) { Image(systemName: on ? "checkmark" : s.icon).font(.caption2); Text(s.title).font(.caption.weight(.semibold)).lineLimit(1) }
                                    .frame(maxWidth: .infinity, minHeight: 36)
                                    .foregroundStyle(on ? Color.white : Color.primary)
                                    .background(Capsule().fill(on ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color.primary.opacity(0.07))))
                            }.buttonStyle(.plain)
                        }
                    }
                }.padding()
                Text(HandoffWriter.markdown(spec: exportSpec, options: options)).font(.system(size: 12, design: .monospaced)).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
            }
            Button { goShare() } label: { Text("Continue").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromePrimaryStyle()).padding()
        }
    }

    private var share: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 54)).foregroundStyle(Chrome.gradient)
                        .symbolEffect(.bounce, options: .nonRepeating)
                    Text("Handoff ready").font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Saved to your Library as \(draft.name).").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(.vertical, 8)
                Button { UIPasteboard.general.string = HandoffWriter.markdown(spec: exportSpec, options: options); withAnimation(.spring) { copied = true }; Haptics.success() } label: {
                    Label("Copy for Claude Code", systemImage: "doc.on.doc").frame(maxWidth: .infinity).frame(minHeight: 44)
                }.buttonStyle(ChromePrimaryStyle())
                if copied { Label("Copied. Now attach your screenshot in the same message.", systemImage: "checkmark.circle.fill").font(.subheadline.weight(.semibold)).foregroundStyle(.green).transition(.move(edge: .top).combined(with: .opacity)) }
                ShareLink(items: files) { Label("Share", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromeSecondaryStyle())
                Button { exportingFolder = true } label: { Label("Save to Files", systemImage: "folder").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromeSecondaryStyle())
                Button {
                    for p in pngs { if let i = UIImage(data: p.1) { UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil) } }
                    photosSaved = true; Haptics.success()
                } label: { Label(photosSaved ? "Saved to Photos" : "Save screenshots to Photos", systemImage: "photo").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromeSecondaryStyle()).disabled(pngs.isEmpty)
                Text("Send the text and the screenshot to Claude Code together. The text says what to build and the exact values, the screenshot shows the intended look.")
                    .font(.footnote).foregroundStyle(.secondary).padding(.top, 8)
                if let first = pngs.first, let img = UIImage(data: first.1) {
                    Image(uiImage: img).resizable().scaledToFit().frame(maxHeight: 340).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 14, y: 8).frame(maxWidth: .infinity)
                }
            }.padding()
        }
        .fileExporter(isPresented: $exportingFolder, document: FolderDocument(files: allFiles()), contentType: .folder, defaultFilename: HandoffWriter.slug(draft.name)) { _ in }
    }

    private var exportSpec: DesignSpec { var d = draft; d.screens = options.screens; return d }

    private func allFiles() -> [(String, Data)] {
        let slug = HandoffWriter.slug(draft.name)
        var out: [(String, Data)] = [("\(slug)-handoff.md", Data(HandoffWriter.markdown(spec: exportSpec, options: options).utf8)),
                                     ("\(slug)-design.json", HandoffWriter.json(spec: exportSpec))]
        out += pngs
        for (i, imp) in draft.imports.enumerated() where options.screens.contains(.imported) {
            if let d = ImportStore.data(imp.id, imp.originalFile) { out.append(("\(slug)-import-\(i + 1)-original.jpg", d)) }
        }
        return out
    }

    private func goShare() {
        draft.updatedAt = Date()
        model.store.save(draft)
        if draft.id == model.spec.id {
            let d = draft
            model.update { $0.name = d.name; $0.notes = d.notes; $0.satisfaction = d.satisfaction }
        }
        pngs = options.includeScreenshots ? ScreenshotRenderer.pngs(spec: exportSpec, screens: options.screens) : []
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("handoff-\(draft.id.uuidString)", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        files = allFiles().compactMap { f in
            let u = dir.appendingPathComponent(f.0)
            return (try? f.1.write(to: u)) != nil ? u : nil
        }
        Haptics.success()
        step = 3
    }
}
