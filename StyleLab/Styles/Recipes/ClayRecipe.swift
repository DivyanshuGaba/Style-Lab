import SwiftUI

extension Recipes {
    static func clay(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let bg = d ? mix(h("#14101F"), A, 0.2) : mix(.white, A, 0.14)
        let surface = d ? mix(h("#2A2147"), A, 0.15) : RGB.white
        var t = base(x, surface: surface)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.headingDesign = .rounded; t.bodyDesign = .rounded; t.typefaceName = "SF Rounded"
        t.text = d ? h("#F4EEFF") : h("#2E2250")
        t.secondary = d ? h(x.boost ? "#EDE6FF" : "#CFC3EE") : h(x.boost ? "#3F3366" : "#5B4F82")
        t.separator = A.op(0.18); t.separatorText = "accent at 0.18 opacity"
        t.cardRadius = 32 * R; t.tileRadius = 24 * R; t.buttonRadius = 24 * R
        let yo = 6 * D + 2
        t.card = SurfaceStyle(radius: 32 * R, fill: .solid(surface.color),
            shadows: [sh(A.op(d ? 0.35 : 0.28), 0, 10 * D + 4, 24 * D + 8)],
            inner: [ish(A.op(0.18), 0, -yo, 12 * D + 4), ish(Color.white.opacity(d ? 0.12 : 0.95), 0, yo, 10 * D + 4)])
        let pastel = [h("#FFB7A8"), h("#FFE08A"), h("#A8E6CF"), h("#B8C4FF")]
        t.tileForIndex = { i in SurfaceStyle(radius: 24 * R, fill: .solid(pastel[i % 4].color), shadows: [sh(A.op(0.25), 0, 6, 14)],
                                             inner: [ish(Color.black.opacity(0.12), 0, -4, 8), ish(Color.white.opacity(0.7), 0, 4, 8)]) }
        t.tileIconColor = { _ in h("#3B2A5A").color }
        t.button = SurfaceStyle(radius: 24 * R, fill: .solid(A.color), shadows: [sh(A.op(0.35), 0, 8, 16)],
                                inner: [ish(Color.black.opacity(0.18), 0, -4, 8), ish(Color.white.opacity(0.35), 0, 4, 8)])
        t.floatingTab = true
        var tab = t.card; tab.radius = 34 * R; t.tabFloating = tab
        t.tabFull = tab; t.tabFull.radius = 0
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#4A3F6B") : h("#D8D0EE")).color, recessed: true)
        t.depthLines = ["Cards have a colored outer shadow: offset \(fmt(10 * D + 4)) pt, blur \(fmt(24 * D + 8)) pt, accent at \(d ? "0.35" : "0.28") opacity.",
                        "Cards have an inner bottom shade (accent at 0.18, \(fmt(yo)) pt, blur \(fmt(12 * D + 4)) pt) and an inner top highlight (white at \(d ? "0.12" : "0.95"), \(fmt(yo)) pt, blur \(fmt(10 * D + 4)) pt).",
                        "Icon tiles use pastel fills #FFB7A8, #FFE08A, #A8E6CF, #B8C4FF in rotation, with inner shadows and a soft accent glow."]
        t.tileDesc = "62 pt very round pastel square (colors rotate), dark purple icon (#3B2A5A), inner highlight and shade, label below at 12 pt semibold"
        t.iconRule = "dark purple #3B2A5A on the pastel tile."
        t.buttonExtra = "puffy, with inner highlight and shade and a colored outer shadow"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed. Keep spacing generous."
        finish(&t); return t
    }
}
