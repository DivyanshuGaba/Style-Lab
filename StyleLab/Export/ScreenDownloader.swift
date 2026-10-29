import SwiftUI
import Photos

/// Renders every screen of the open project's sample app and saves or shares them in one go.
enum ScreenDownloader {
    struct Item { let name: String; let screen: SampleScreen; let image: UIImage }

    /// All screens of the sample app, with the current style, colors and hand edits applied.
    @MainActor
    static func renderAll(spec: DesignSpec, progress: ((Int, Int) -> Void)? = nil) async -> [Item] {
        let screens = spec.app.screens
        let slug = HandoffWriter.slug(spec.name)
        var out: [Item] = []
        for (i, s) in screens.enumerated() {
            progress?(i, screens.count)
            await Task.yield()
            if let img = ScreenshotRenderer.image(spec: spec, screen: s) {
                out.append(Item(name: "\(slug)-\(spec.app.rawValue)-\(s.rawValue).png", screen: s, image: img))
            }
        }
        progress?(screens.count, screens.count)
        return out
    }

    static func saveToPhotos(_ images: [UIImage]) async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                for i in images { PHAssetChangeRequest.creationRequestForAsset(from: i) }
            }
            return true
        } catch { return false }
    }

    /// Writes the pictures to a temporary folder so they can be shared or saved to Files.
    static func writeFiles(_ items: [Item], id: UUID) -> [URL] {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("screens-\(id.uuidString)", isDirectory: true)
        try? FileManager.default.removeItem(at: dir)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return items.compactMap { it in
            guard let data = it.image.pngData() else { return nil }
            let url = dir.appendingPathComponent(it.name)
            return (try? data.write(to: url)) != nil ? url : nil
        }
    }
}

/// Shown after "Share or save as files": all rendered screens, ready to share or save to Files.
struct ShareAllSheet: View {
    let items: [ScreenDownloader.Item]
    let urls: [URL]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("\(items.count) screens ready").font(.system(.title3, design: .rounded, weight: .bold))
                    ShareLink(items: urls) { Label("Share or save to Files", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity).frame(minHeight: 48) }
                        .buttonStyle(ChromePrimaryStyle())
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                        ForEach(items, id: \.name) { it in
                            VStack(spacing: 4) {
                                Image(uiImage: it.image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                                Text(it.screen.title).font(.caption.weight(.semibold))
                            }
                        }
                    }
                }.padding()
            }
            .chromeBackground()
            .navigationTitle("All screens").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
        .presentationDetents([.large])
    }
}
