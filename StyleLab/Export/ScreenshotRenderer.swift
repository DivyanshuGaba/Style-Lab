import SwiftUI

enum ScreenshotRenderer {
    @MainActor
    static func image(spec: DesignSpec, screen: SampleScreen) -> UIImage? {
        let view = ZStack {
            Color(red: 0.85, green: 0.86, blue: 0.88)
            SampleScreenView(spec: spec, screen: screen)
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .padding(28)
        }
        .frame(width: 390 + 56, height: 844 + 56)
        let r = ImageRenderer(content: view)
        r.scale = 3
        return r.uiImage
    }

    @MainActor
    static func pngs(spec: DesignSpec, screens: [SampleScreen]) -> [(String, Data)] {
        let slug = HandoffWriter.slug(spec.name)
        var out: [(String, Data)] = []
        for s in screens {
            if s == .imported {
                for (i, imp) in spec.imports.enumerated() {
                    var sp = spec; sp.currentImport = imp.id
                    if let d = image(spec: sp, screen: .imported)?.pngData() { out.append(("\(slug)-import-\(i + 1).png", d)) }
                }
            } else if let d = image(spec: spec, screen: s)?.pngData() {
                out.append(("\(slug)-\(s.rawValue).png", d))
            }
        }
        return out
    }
}
