import SwiftUI

enum ElementKind: String, Codable, Sendable { case text, icon, glyph, card, button, chip, row, shape, image, control }

enum ElementWeight: String, Codable, CaseIterable, Sendable {
    case light, regular, bold, heavy
    var font: Font.Weight { switch self { case .light: .light; case .regular: .regular; case .bold: .bold; case .heavy: .heavy } }
    var title: String { rawValue.capitalized }
}

/// What the person changed on one element of a sample screen, relative to its default look.
struct ElementEdit: Codable, Equatable, Sendable {
    var screen: String = ""
    var name: String = ""
    var kind: ElementKind = .card
    var dx: Double = 0
    var dy: Double = 0
    var scale: Double = 1
    var weight: ElementWeight? = nil
    var fgHex: String? = nil
    var bgHex: String? = nil
    var bgHidden: Bool = false
    var text: String? = nil
    var icon: String? = nil
    var radius: Double? = nil
    var badge: Int? = nil
    var hidden: Bool = false

    var isDefault: Bool {
        dx == 0 && dy == 0 && scale == 1 && weight == nil && fgHex == nil && bgHex == nil && !bgHidden && text == nil && icon == nil && radius == nil && badge == nil && !hidden
    }
}

extension ElementEdit {
    func fg(_ d: Color) -> Color { fgHex.map { RGB(hex: $0).color } ?? d }
    func w(_ d: Font.Weight) -> Font.Weight { weight?.font ?? d }
    /// The surface to draw, or nil when the person removed the background.
    func surface(_ base: SurfaceStyle) -> SurfaceStyle? {
        if bgHidden { return nil }
        guard let b = bgHex else { return base }
        var c = base
        c.fill = .solid(RGB(hex: b).color); c.material = nil; c.hairlines = nil
        return c
    }
}

extension View {
    @ViewBuilder func optSurface(_ s: SurfaceStyle?) -> some View {
        if let s { self.surface(s) } else { self }
    }
}
