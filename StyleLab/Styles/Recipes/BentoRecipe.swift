import SwiftUI

extension Recipes {
    static func bento(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let bg = d ? h("#101012") : h("#ECEEF1"), surface = d ? h("#1C1C20") : RGB.white
        var t = base(x, surface: surface)
        t.layout = .bento
        t.bentoTiles = (0..<4).map { bentoTile(x, $0) }
        t.background = solid(bg); t.backgroundText = bg.hex
        t.text = d ? .white : h("#111113")
        t.secondary = d ? h(x.boost ? "#D4D4DC" : "#A9A9B2") : h(x.boost ? "#3D3D45" : "#5B5B63")
        t.separator = d ? Color.white.opacity(0.1) : Color.black.opacity(0.08); t.separatorText = d ? "white at 0.1 opacity" : "black at 0.08 opacity"
        t.cardRadius = 28 * R; t.tileRadius = 20 * R; t.buttonRadius = 20 * R
        t.card = SurfaceStyle(radius: 28 * R, fill: .solid(surface.color), shadows: [sh(Color.black.opacity(d ? 0.4 : 0.06), 0, 1 + 3 * D, 2 + 10 * D)])
        t.tileForIndex = { _ in SurfaceStyle(radius: 16 * R, fill: .solid(A.op(d ? 0.22 : 0.12))) }
        t.tileIconColor = { _ in t.accentAdjusted.color }
        t.button = SurfaceStyle(radius: 20 * R, fill: .solid(A.color))
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(bg.op(0.94)), topBorder: t.separator)
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#3A3A40") : h("#D4D4DA")).color)
        t.depthLines = ["Tiles have a shadow: offset \(fmt(1 + 3 * D)) pt vertical, blur \(fmt(2 + 10 * D)) pt, black at \(d ? "0.4" : "0.06") opacity.",
                        "The hero tile is filled with the accent. Action tiles use four fills: the accent, \(d ? "#2C2C32" : "#161618"), \(d ? mix(h("#1C1C20"), A, 0.35).hex : mix(.white, A, 0.2).hex) and #FFD25A."]
        t.tileDesc = "square action tile, 96 pt tall, icon top left, label bottom left at 16 pt bold; fills by position: accent, near black, accent tint, amber"
        t.iconRule = "set per tile: \(ColorMath.onColor(A).hex) on the accent tile, white on the dark tile, the text color on the tint tile, black on the amber tile."
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }

    /// Fill and foreground colors of the four bento action tiles.
    static func bentoTile(_ x: Ctx, _ i: Int) -> (Color, Color) {
        let d = x.dark, A = x.A
        switch i % 4 {
        case 0: return (A.color, ColorMath.onColor(A).color)
        case 1: return ((d ? h("#2C2C32") : h("#161618")).color, .white)
        case 2: return ((d ? mix(h("#1C1C20"), A, 0.35) : mix(.white, A, 0.2)).color, (d ? RGB.white : h("#111113")).color)
        default: return (h("#FFD25A").color, .black)
        }
    }
}
