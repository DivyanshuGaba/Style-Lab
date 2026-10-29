import SwiftUI

extension Recipes {
    static func glass(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D, c = x.c
        let dk = 0.1 + 0.3 * c
        let stop0 = d ? h("#1B1038") : mix(A, .black, dk)
        let stop1 = d ? mix(h("#1B1038"), A, 0.5) : mix(mix(A, h("#FF4FD8"), 0.6), .black, dk)
        let stop2 = d ? h("#0E3B4A") : mix(mix(A, h("#22D3EE"), 0.7), .black, dk)
        let est = mix(stop1, .white, 0.12)
        var t = base(x, surface: est)
        t.estimated = true
        t.background = BackgroundSpec(
            fill: .linear([.init(color: stop0.color, location: 0), .init(color: stop1.color, location: 0.6), .init(color: stop2.color, location: 1)], angle: 135),
            blobs: [Blob(color: .white, diameter: 260, opacity: 0.18, alignment: .topTrailing, dx: 60, dy: -40),
                    Blob(color: mix(A, h("#22D3EE"), 0.6).color, diameter: 300, opacity: 0.35, alignment: .bottomLeading, dx: -70, dy: 60)])
        t.backgroundText = "a 135 degree gradient from \(stop0.hex) through \(stop1.hex) to \(stop2.hex), plus a white glow top right and a cyan glow lower left"
        t.surfaceText = "\(est.hex) (estimated, translucent frosted panel)"
        t.text = .white
        t.secondary = h(x.boost ? "#FFFFFF" : "#EAF0FF")
        t.positive = .white
        t.separator = Color.white.opacity(0.3); t.separatorText = "white at 0.3 opacity"
        let fillO = 0.12 + 0.1 * D + 0.14 * c, blur = 8 + 16 * D
        t.cardRadius = 20 * R; t.tileRadius = 16 * R; t.buttonRadius = 16 * R
        t.card = SurfaceStyle(radius: 20 * R, fill: .solid(x.solid ? est.color : Color.white.opacity(fillO)), material: x.solid ? nil : material(blur),
                              borderColor: Color.white.opacity(0.32), shadows: [sh(Color.black.opacity(0.2), 0, 8 * D + 2, 32 * D + 4)])
        let tileO = 0.2 + 0.12 * c
        t.tileForIndex = { _ in SurfaceStyle(radius: 16 * R, fill: .solid(x.solid ? est.color : Color.white.opacity(tileO)), borderColor: Color.white.opacity(0.4)) }
        t.tileIconColor = { _ in .white }
        t.buttonFill = .white
        t.buttonLabel = mix(A, .black, 0.45)
        t.button = SurfaceStyle(radius: 16 * R, fill: .solid(Color.white))
        t.chip = ChipSpec(fill: Color.white.opacity(0.25), text: .white)
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(x.solid ? est.color : Color.white.opacity(0.16)), material: x.solid ? nil : .ultraThinMaterial, topBorder: Color.white.opacity(0.3))
        t.tabActive = .white
        t.toggle = ToggleSpec(on: mix(A, .black, 0.2).color, off: Color.white.opacity(0.3))
        t.wording["fillOpacity"] = fmt(fillO); t.wording["blur"] = fmt(blur)
        t.depthLines = ["Cards are white at \(fmt(fillO)) opacity with a \(fmt(blur)) pt background blur and a 1 pt white border at 0.32 opacity.",
                        "Cards have a drop shadow: offset \(fmt(8 * D + 2)) pt vertical, blur \(fmt(32 * D + 4)) pt, black at 0.2 opacity.",
                        "Icon tiles are white at \(fmt(tileO)) opacity with a 1 pt white border at 0.4 opacity."]
        t.tileDesc = "62 pt frosted rounded square, white fill at \(fmt(tileO)) opacity, 1 pt translucent white border, white icon, label below at 12 pt semibold"
        t.iconRule = "white."
        t.buttonExtra = "white fill with a dark tinted label (\(t.buttonLabel.hex))"
        t.fallbackSentence = "With Reduce Transparency on, replace frosted panels with a solid fill of \(est.hex)."
        finish(&t); return t
    }
}
