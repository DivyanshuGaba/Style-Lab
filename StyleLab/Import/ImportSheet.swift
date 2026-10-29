import SwiftUI
import PhotosUI

struct ImportSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var picked: PhotosPickerItem?
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled").font(.system(size: 40)).foregroundStyle(Chrome.gradient)
                        Text("Turn a screenshot into an editable screen").font(.system(.title3, design: .rounded, weight: .bold))
                        Text("Pick a screenshot of an existing app. Style Lab reads it on your iPhone, finds the text, cards, buttons and icons, and rebuilds them as parts you can move, resize, recolor and rewrite. Nothing leaves your device.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    PhotosPicker(selection: $picked, matching: .images) {
                        Label(busy ? "Reading screenshot" : "Choose a screenshot", systemImage: "photo").frame(maxWidth: .infinity).frame(minHeight: 48)
                    }
                    .buttonStyle(ChromePrimaryStyle()).disabled(busy)
                    if busy { HStack { ProgressView(); Text("Finding text, shapes and icons").font(.subheadline).foregroundStyle(.secondary) } }
                    if let error { Label(error, systemImage: "exclamationmark.triangle").font(.subheadline).foregroundStyle(.orange) }
                    Text("Tips: full screen screenshots work best. Photos and complex artwork stay in the background layer, while text, flat cards and small icons become separate parts.")
                        .font(.footnote).foregroundStyle(.secondary)

                    if !model.spec.imports.isEmpty {
                        Text("Your imports").font(.headline).padding(.top, 8)
                        ForEach(model.spec.imports) { imp in
                            HStack(spacing: 12) {
                                if let img = ImportStore.image(imp.id, imp.plateFile) {
                                    Image(uiImage: img).resizable().scaledToFill().frame(width: 44, height: 80).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(imp.name).font(.subheadline.weight(.semibold))
                                    Text("\(imp.elements.filter { $0.kind == .text }.count) text, \(imp.elements.filter { $0.kind == .shape }.count) shapes, \(imp.elements.filter { $0.kind == .image }.count) icons")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button { model.update { $0.currentImport = imp.id }; model.requestedScreen = .imported; model.tab = .studio; dismiss() } label: { Text("Open").frame(minHeight: 36) }
                                    .buttonStyle(ChromeSecondaryStyle())
                                Button(role: .destructive) { model.deleteImport(imp.id) } label: { Image(systemName: "trash").frame(width: 36, height: 36) }
                                    .buttonStyle(ChromeIconStyle()).accessibilityLabel("Delete import")
                            }
                            .padding(10).chromeCard(radius: 16)
                        }
                    }
                }
                .padding()
            }
            .chromeBackground()
            .navigationTitle("Import screenshot").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
            .onChange(of: picked) { _, item in
                guard let item else { return }
                Task { await load(item) }
            }
        }
        .presentationDetents([.large])
    }

    private func load(_ item: PhotosPickerItem) async {
        busy = true; error = nil
        defer { busy = false; picked = nil }
        guard let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else {
            error = "That image could not be opened."; return
        }
        let name = "Imported screen \(model.spec.imports.count + 1)"
        do {
            let result = try await Task.detached(priority: .userInitiated) { try ImportEngine.analyze(img, name: name) }.value
            if result.screen.elements.isEmpty {
                error = "No text or shapes were found. Try a clearer, full screen screenshot."; return
            }
            model.addImport(result)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
