import SwiftUI

extension Recipes {
    static func liquid(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D, c = x.c
        let est = d ? h("#1B2547") : mix(.white, A, 0.12)
        var t = base(x, surface: est)
        t.estimated = true
        let stops: [Color] = d ? [h("#0B1226").color, mix(h("#0B1226"), A, 0.45).color, h("#1A0F2E").color]
                               : [mix(.white, A, 0.16).color, mix(.white, A, 0.4).color, mix(.white, h("#FF9ACB"), 0.35).color]
        t.background = BackgroundSpec(
            fill: .linear([.init(color: stops[0], location: 0), .init(color: stops[1], location: d ? 0.55 : 0.6), .init(color: stops[2], location: 1)], angle: 160),
            blobs: [Blob(color: A.color, diameter: 320, opacity: d ? 0.5 : 0.4, alignment: .topLeading, dx: -80, dy: -60),
                    Blob(color: mix(A, h("#FF6FB5"), 0.7).color, diameter: 300, opacity: d ? 0.4 : 0.35, alignment: .trailing, dx: 100),
                    Blob(color: mix(A, h("#33D1FF"), 0.7).color, diameter: 320, opacity: d ? 0.4 : 0.3, alignment: .bottomLeading, dx: -80, dy: 80)])
        t.backgroundText = "a 160 degree gradient with three blurred color glows"
        t.surfaceText = "\(est.hex) (estimated, translucent glass)"
        t.text = d ? .white : h("#0B1B33")
        t.secondary = d ? h(x.boost ? "#EAF0FF" : "#C9D3EA") : h(x.boost ? "#1F2B40" : "#3C4A63")
        let fillO = d ? 0.10 + 0.12 * c : 0.42 + 0.28 * c
        let blur = 10 + 30 * D
        t.separator = Color.white.opacity(d ? 0.2 : 0.6); t.separatorText = "white at \(d ? "0.2" : "0.6") opacity"
        t.cardRadius = 28 * R; t.tileRadius = 26 * R; t.buttonRadius = 999
        let edge = Color.white.opacity(d ? 0.24 : 0.75)
        func glass(_ radius: CGFloat, _ opacity: Double) -> SurfaceStyle {
            SurfaceStyle(radius: radius,
                fill: .solid(x.solid ? est.color : Color.white.opacity(opacity)),
                material: x.solid ? nil : material(blur), borderColor: edge,
                shadows: [sh(h("#0A1432").op(d ? 0.4 : 0.14), 0, 10 * D + 2, 30 * D + 6)],
                inner: [ish(Color.white.opacity(d ? 0.3 : 0.9), 0, 1, 0)])
        }
        t.card = glass(28 * R, fillO)
        let tileO = d ? 0.14 + 0.1 * c : 0.6 + 0.2 * c
        t.tileForIndex = { _ in
            var s = glass(26 * R, tileO); s.shadows = []; s.material = nil
            s.fill = .solid(x.solid ? est.color : Color.white.opacity(tileO)); return s }
        let ic = d ? Color.white : mix(A, .black, 0.4).color
        t.tileIconColor = { _ in ic }
        t.button = SurfaceStyle(radius: 999, fill: .solid(A.color), shadows: [sh(A.op(0.4), 0, 6, 18)], inner: [ish(Color.white.opacity(0.4), 0, 1, 0)])
        t.floatingTab = true
        t.tabFloating = glass(34, fillO)
        t.tabFull = glass(0, fillO)
        t.chip = ChipSpec(fill: Color.white.opacity(d ? 0.18 : 0.5), text: ColorMath.ensure(A, est, 4.5).color)
        t.toggle = ToggleSpec(on: A.color, off: d ? Color.white.opacity(0.25) : h("#0B1B33").op(0.2))
        t.wording["fillOpacity"] = fmt(fillO); t.wording["blur"] = fmt(blur)
        t.depthLines = ["Cards are white at \(fmt(fillO)) opacity over a background blur of about \(fmt(blur)) pt with boosted saturation (1.8).",
                        "Cards have a 1 pt white border at \(d ? "0.24" : "0.75") opacity and an inner top highlight of white at \(d ? "0.3" : "0.9") opacity.",
                        "Cards have a drop shadow: offset \(fmt(10 * D + 2)) pt vertical, blur \(fmt(30 * D + 6)) pt, #0A1432 at \(d ? "0.4" : "0.14") opacity.",
                        "Three blurred glows sit behind the content: the accent, a pink blend and a cyan blend."]
        t.tileDesc = "62 pt glass rounded square, white fill at \(fmt(tileO)) opacity, 1 pt white border, icon centered, label below at 12 pt semibold"
        t.iconRule = d ? "white." : "the accent mixed 40 percent toward black (\(mix(A, .black, 0.4).hex) here)."
        t.buttonExtra = "capsule shaped with an inner top highlight and a soft accent glow (blur 18 pt, 6 pt down, accent at 0.4)"
        t.fallbackSentence = "With Reduce Transparency on, replace glass with a solid fill of \(est.hex)."
        finish(&t); return t
    }
}
