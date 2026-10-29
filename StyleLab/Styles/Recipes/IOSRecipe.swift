import SwiftUI

extension Recipes {
    static func ios(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let bg = d ? h("#000000") : h("#F2F2F7")
        let surface = d ? h("#1C1C1E") : RGB.white
        var t = base(x, surface: surface)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.text = d ? .white : .black
        t.secondary = d ? h(x.boost ? "#D1D1D6" : "#A1A1A6") : h(x.boost ? "#3A3A3C" : "#6C6C70")
        t.separator = d ? Color(red: 84 / 255, green: 84 / 255, blue: 88 / 255).opacity(0.65) : Color(red: 60 / 255, green: 60 / 255, blue: 67 / 255).opacity(0.18)
        t.separatorText = d ? "#545458 at 0.65 opacity" : "#3C3C43 at 0.18 opacity"
        t.cardRadius = 18 * R; t.tileRadius = 14 * R; t.buttonRadius = 14 * R
        t.card = SurfaceStyle(radius: 18 * R, fill: .solid(surface.color), shadows: [sh(Color.black.opacity(d ? 0.45 : 0.09), 0, 2 * D, 12 * D)])
        let tileFill = A.op(d ? 0.26 : 0.12)
        t.tileForIndex = { _ in SurfaceStyle(radius: 14 * R, fill: .solid(tileFill)) }
        t.tileIconColor = { _ in t.accentAdjusted.color }
        t.button = SurfaceStyle(radius: 14 * R, fill: .solid(A.color))
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid((d ? h("#1C1C1E") : h("#F9F9F9")).op(0.94)), topBorder: t.separator, topBorderWidth: 0.5)
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#39393D") : h("#E4E4E8")).color)
        t.toggle.off = (d ? h("#39393D") : h("#E4E4E8")).color
        t.depthLines = ["Cards have a soft shadow: offset 0 pt horizontal, \(fmt(2 * D)) pt vertical, blur \(fmt(12 * D)) pt, black at \(d ? "0.45" : "0.09") opacity.",
                        "Icon tiles are filled with the accent at \(d ? "0.26" : "0.12") opacity. They have no border."]
        t.tileDesc = "62 pt rounded square, accent tint fill, icon centered, label below at 12 pt semibold"
        t.iconRule = "the adjusted accent (\(t.accentAdjusted.hex) here), which is guaranteed to have at least 3:1 contrast with the surface."
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }
}
