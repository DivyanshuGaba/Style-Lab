import SwiftUI

struct LibraryView: View {
    @Environment(AppModel.self) private var model
    @State private var renaming: DesignSpec?
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            Group {
                if model.store.designs.isEmpty { empty } else { list }
            }
            .chromeBackground()
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { model.newDesign() } label: { Label("New design", systemImage: "plus") }
                        Button { model.showImport = true } label: { Label("Import screenshot", systemImage: "photo.on.rectangle.angled") }
                    } label: { Label("New", systemImage: "plus") }
                }
            }
            .alert("Rename design", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
                TextField("Name", text: $newName)
                Button("Save") { if let r = renaming { model.renameDesign(r.id, to: newName) }; renaming = nil }
                Button("Cancel", role: .cancel) { renaming = nil }
            }
            .onAppear { model.store.loadAll() }
        }
    }

    private var empty: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical.fill").font(.system(size: 52)).foregroundStyle(Chrome.gradient)
                .padding(24).background(Circle().fill(Chrome.indigo.opacity(0.1)))
            Text("No saved designs yet").font(.system(.title2, design: .rounded, weight: .bold))
            Text("Designs you export are saved here so you can reopen and refine them.").multilineTextAlignment(.center).foregroundStyle(.secondary).padding(.horizontal, 32)
            Button("Start with a brief") { model.newDesign() }.buttonStyle(ChromePrimaryStyle()).frame(minHeight: 44)
            Button("Browse styles") { model.tab = .gallery }.frame(minHeight: 44)
        }
    }

    private var list: some View {
        List {
            ForEach(model.store.designs) { d in
                HStack(spacing: 6) {
                    Button { model.open(d) } label: {
                        HStack(spacing: 14) {
                            PreviewCanvas(spec: d).frame(width: 56, height: 121)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(d.name).font(.system(.headline, design: .rounded)).foregroundStyle(.primary).lineLimit(2).multilineTextAlignment(.leading)
                                HStack(spacing: 6) {
                                    Text(StyleCatalog.info(d.style).name).font(.caption.weight(.semibold)).foregroundStyle(Chrome.indigo)
                                        .padding(.horizontal, 8).padding(.vertical, 3).background(Capsule().fill(Chrome.indigo.opacity(0.12)))
                                    Label(d.mode.title, systemImage: d.mode == .dark ? "moon.fill" : "sun.max.fill").font(.caption).foregroundStyle(.secondary)
                                    Circle().fill(RGB(hex: d.accentHex).color).frame(width: 10, height: 10)
                                }
                                Text(d.app.shortTitle + "  \u{00B7}  Edited " + d.updatedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableStyle())
                    Menu {
                        Button { newName = d.name; renaming = d } label: { Label("Rename", systemImage: "pencil") }
                        Button { model.open(d) } label: { Label("Open in Studio", systemImage: "slider.horizontal.3") }
                        Button { model.exportSpec = d } label: { Label("Export", systemImage: "square.and.arrow.up") }
                        Button { model.store.duplicate(d) } label: { Label("Duplicate", systemImage: "plus.square.on.square") }
                        Divider()
                        Button(role: .destructive) { model.store.delete(d.id) } label: { Label("Delete", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis.circle").font(.title3).foregroundStyle(Chrome.indigo).frame(width: 44, height: 44).contentShape(Rectangle())
                    }
                    .accessibilityLabel("Options for \(d.name)")
                }
                .padding(12).chromeCard(radius: 22)
                .listRowBackground(Color.clear).listRowSeparator(.hidden).listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .leading) {
                    Button { newName = d.name; renaming = d } label: { Label("Rename", systemImage: "pencil") }.tint(.orange)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) { model.store.delete(d.id) } label: { Label("Delete", systemImage: "trash") }
                    Button { model.store.duplicate(d) } label: { Label("Duplicate", systemImage: "plus.square.on.square") }.tint(.indigo)
                }
                .contextMenu {
                    Button { newName = d.name; renaming = d } label: { Label("Rename", systemImage: "pencil") }
                    Button { model.open(d) } label: { Label("Open in Studio", systemImage: "slider.horizontal.3") }
                    Button { model.exportSpec = d } label: { Label("Export", systemImage: "square.and.arrow.up") }
                    Button { model.update { $0.compareStyle = d.style == $0.style ? nil : d.style }; model.tab = .studio } label: { Label("Compare with current", systemImage: "square.split.2x1") }
                }
            }
        }
        .listStyle(.plain).scrollContentBackground(.hidden)
    }
}
