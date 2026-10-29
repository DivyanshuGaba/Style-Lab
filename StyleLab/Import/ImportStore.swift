import UIKit

/// Files for imported screens live in Application Support so designs stay small.
enum ImportStore {
    static var root: URL {
        let base = (try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("StyleLab/imports", isDirectory: true)
    }
    static func dir(_ id: UUID) -> URL { root.appendingPathComponent(id.uuidString, isDirectory: true) }

    private static let cache = NSCache<NSString, UIImage>()

    static func write(_ data: Data, id: UUID, file: String) {
        try? FileManager.default.createDirectory(at: dir(id), withIntermediateDirectories: true)
        try? data.write(to: dir(id).appendingPathComponent(file), options: .atomic)
    }
    static func data(_ id: UUID, _ file: String) -> Data? { try? Data(contentsOf: dir(id).appendingPathComponent(file)) }
    static func image(_ id: UUID, _ file: String) -> UIImage? {
        let k = "\(id.uuidString)/\(file)" as NSString
        if let c = cache.object(forKey: k) { return c }
        guard let d = data(id, file), let i = UIImage(data: d) else { return nil }
        cache.setObject(i, forKey: k); return i
    }
    static func delete(_ id: UUID) { try? FileManager.default.removeItem(at: dir(id)) }
}
