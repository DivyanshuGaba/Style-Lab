import Foundation
import Observation

struct DesignFile: Codable { var schemaVersion = 1; var design: DesignSpec }

@Observable
final class DesignStore {
    private(set) var designs: [DesignSpec] = []
    let directory: URL
    private var currentURL: URL { directory.deletingLastPathComponent().appendingPathComponent("current.json") }

    init(directory: URL? = nil) {
        if let directory { self.directory = directory } else {
            let base = (try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? FileManager.default.temporaryDirectory
            self.directory = base.appendingPathComponent("StyleLab/designs", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
        loadAll()
    }

    static func encoder() -> JSONEncoder {
        let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys]; e.dateEncodingStrategy = .iso8601; return e
    }
    static func decoder() -> JSONDecoder { let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d }

    func loadAll() {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        designs = files.filter { $0.pathExtension == "json" }.compactMap { url in
            guard let data = try? Data(contentsOf: url), let f = try? Self.decoder().decode(DesignFile.self, from: data) else { return nil }
            return f.design
        }.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func url(for id: UUID) -> URL { directory.appendingPathComponent("\(id.uuidString).json") }

    func save(_ spec: DesignSpec) {
        guard let data = try? Self.encoder().encode(DesignFile(design: spec)) else { return }
        try? data.write(to: url(for: spec.id), options: .atomic)
        if let i = designs.firstIndex(where: { $0.id == spec.id }) { designs[i] = spec } else { designs.append(spec) }
        designs.sort { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    func duplicate(_ spec: DesignSpec) -> DesignSpec {
        var c = spec; c.id = UUID(); c.name = spec.name + " copy"; c.createdAt = Date(); c.updatedAt = Date()
        save(c); return c
    }

    func rename(_ id: UUID, to name: String) {
        guard var d = designs.first(where: { $0.id == id }) else { return }
        d.name = name; d.updatedAt = Date(); save(d)
    }

    func delete(_ id: UUID) {
        try? FileManager.default.removeItem(at: url(for: id))
        designs.removeAll { $0.id == id }
    }

    func saveCurrent(_ spec: DesignSpec) {
        try? FileManager.default.createDirectory(at: currentURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? Self.encoder().encode(DesignFile(design: spec)) { try? data.write(to: currentURL, options: .atomic) }
    }

    func loadCurrent() -> DesignSpec? {
        guard let data = try? Data(contentsOf: currentURL), let f = try? Self.decoder().decode(DesignFile.self, from: data) else { return nil }
        return f.design
    }
}
