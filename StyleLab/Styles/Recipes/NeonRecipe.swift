import SwiftUI

extension Recipes {
    static func neon(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let bg = d ? h("#07070E") : h("#EEF2FF"), surface = d ? h("#0E0E1A") : RGB.white
        let G = d ? A : ColorMath.ensure(A, .white, 3)
        var t = base(x, surface: surface)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.headingDesign = .monospaced; t.bodyDesign = .monospaced; t.typefaceName = "SF Mono (monospaced)"
        t.upperLabels = true; t.labelTracking = 0.75
        t.typeRules = "Labels are uppercase with 0.06 em tracking. All text is monospaced. Keep body text near white."
        t.text = d ? h("#EAF2FF") : h("#0A0F2C")
        t.secondary = d ? h(x.boost ? "#BAC4E3" : "#93A0C8") : h(x.boost ? "#333C5C" : "#4A5578")
        t.positive = d ? h("#39FF88") : h("#0E7A4B")
        t.separator = G.op(0.35); t.separatorText = "\(G.hex) at 0.35 opacity"
        t.cardRadius = 12 * R; t.tileRadius = 10 * R; t.buttonRadius = 10 * R
        let gb = 6 + 22 * D
        t.card = SurfaceStyle(radius: 12 * R, fill: .solid(surface.color), borderColor: G.op(d ? 0.7 : 0.55),
                              shadows: [sh(G.op(d ? 0.35 : 0.22), 0, 0, gb)], inner: [ish(G.op(0.15), 0, 0, 8 * D)])
        let tb = 4 + 10 * D
        t.tileForIndex = { _ in SurfaceStyle(radius: 10 * R, fill: .solid(G.op(0.1)), borderColor: G.color, shadows: [sh(G.op(0.4), 0, 0, tb)]) }
        let ic = d ? mix(A, .white, 0.25).color : G.color
        t.tileIconColor = { _ in ic }
        t.button = SurfaceStyle(radius: 10 * R, fill: .solid(A.color), shadows: [sh(A.op(0.6), 0, 0, 6 + 16 * D)])
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(surface.color), shadows: [sh(G.op(0.3), 0, -2, 10)], topBorder: G.op(0.6))
        t.tabActive = G.color
        t.chip = ChipSpec(fill: G.op(0.12), text: ColorMath.ensure(A, surface, 4.5).color, border: G.op(0.6))
        t.toggle = ToggleSpec(on: G.color, off: (d ? h("#1E2038") : h("#D5DAF0")).color, border: G.op(0.6), borderWidth: 1)
        t.wording["glowBlur"] = fmt(gb)
        t.depthLines = ["Cards have a 1 pt border in \(G.hex) at \(d ? "0.7" : "0.55") opacity and an outer glow: \(G.hex) at \(d ? "0.35" : "0.22") opacity, blur \(fmt(gb)) pt, plus a faint inner glow (blur \(fmt(8 * D)) pt, 0.15 opacity).",
                        "Icon tiles are filled with \(G.hex) at 0.1 opacity, with a 1 pt border in \(G.hex) and a glow of blur \(fmt(tb)) pt at 0.4 opacity.",
                        "Buttons glow: accent at 0.6 opacity, blur \(fmt(6 + 16 * D)) pt."]
        t.tileDesc = "62 pt rounded square, glow color at 0.1 opacity fill, 1 pt glowing border, glowing icon, label below at 12 pt semibold uppercase"
        t.iconRule = d ? "the accent mixed 25 percent toward white (\(mix(A, .white, 0.25).hex) here)." : "the glow color (\(G.hex) here)."
        t.buttonExtra = "uppercase label with 0.06 em tracking and a glow"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed. Limit glow to edges and icons."
        finish(&t); return t
    }
}
