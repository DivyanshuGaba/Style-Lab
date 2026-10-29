import SwiftUI

extension Recipes {
    static func oled(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let bg = d ? h("#000000") : RGB.white, surface = d ? h("#0F0F11") : h("#F4F4F5")
        let border = d ? h(x.boost ? "#3A3A40" : "#26262B") : h(x.boost ? "#C4C4CA" : "#E4E4E7")
        var t = base(x, surface: surface)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.text = d ? .white : h("#09090B")
        t.secondary = d ? h(x.boost ? "#CFCFD4" : "#A0A0A8") : h(x.boost ? "#3F3F46" : "#52525B")
        t.separator = border.color; t.separatorText = border.hex
        t.cardRadius = 18 * R; t.tileRadius = 14 * R; t.buttonRadius = 14 * R
        t.card = SurfaceStyle(radius: 18 * R, fill: .solid(surface.color), borderColor: border.color, shadows: d ? [sh(A.op(0.14), 0, 0, 26 * D)] : [])
        t.tileForIndex = { _ in SurfaceStyle(radius: 14 * R, fill: .solid(A.op(d ? 0.16 : 0.1)), borderColor: A.op(0.4)) }
        t.tileIconColor = { _ in t.accentAdjusted.color }
        t.button = SurfaceStyle(radius: 14 * R, fill: .solid(A.color))
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(bg.color), topBorder: border.color)
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#2A2A2F") : h("#D4D4D8")).color)
        t.depthLines = d ? ["Cards have a 1 pt border in \(border.hex) and a very faint accent glow (accent at 0.14 opacity, blur \(fmt(26 * D)) pt). No other shadows."]
                         : ["Cards have a 1 pt border in \(border.hex). There are no shadows in light mode."]
        t.depthLines.append("Icon tiles are filled with the accent at \(d ? "0.16" : "0.1") opacity and have a 1 pt border in the accent at 0.4 opacity.")
        t.tileDesc = "62 pt rounded square, accent tint fill, thin accent border, icon centered, label below at 12 pt semibold"
        t.iconRule = "the adjusted accent (\(t.accentAdjusted.hex) here), which is guaranteed to have at least 3:1 contrast with the surface."
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }
}
