import SwiftUI

extension Recipes {
    static func aurora(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D, c = x.c
        let est = d ? h("#151A33") : RGB.white
        var t = base(x, surface: est)
        t.estimated = true
        let bg = d ? h("#080B18") : h("#F6F4FF")
        let pink = mix(A, h("#FF4FD8"), 0.7), cyan = mix(A, h("#22D3EE"), 0.7)
        t.background = BackgroundSpec(fill: .solid(bg.color), blobs: [
            Blob(color: A.color, diameter: 300, opacity: d ? 0.55 : 0.35, alignment: .topLeading, dx: -70, dy: -50),
            Blob(color: pink.color, diameter: 280, opacity: d ? 0.45 : 0.3, alignment: .trailing, dx: 90),
            Blob(color: cyan.color, diameter: 320, opacity: d ? 0.4 : 0.3, alignment: .bottomLeading, dx: -80, dy: 80)])
        t.backgroundText = "\(bg.hex) with three blurred glows (accent, pink blend, cyan blend)"
        t.surfaceText = "\(est.hex) (estimated, faint translucent panel)"
        t.text = d ? h("#F3F5FF") : h("#1B1740")
        t.secondary = d ? h(x.boost ? "#DCE1F5" : "#B6BEDB") : h(x.boost ? "#3B3566" : "#575185")
        t.separator = Color.white.opacity(d ? 0.14 : 0.9); t.separatorText = "white at \(d ? "0.14" : "0.9") opacity"
        t.cardRadius = 22 * R; t.tileRadius = 17 * R; t.buttonRadius = 18 * R
        let fillO = d ? 0.06 + 0.08 * c : 0.6 + 0.25 * c
        t.card = SurfaceStyle(radius: 22 * R, fill: .solid(x.solid ? est.color : Color.white.opacity(fillO)), material: x.solid ? nil : (d ? .ultraThinMaterial : .thinMaterial),
            borderColor: Color.white.opacity(d ? 0.14 : 0.95), shadows: [sh(d ? Color.black.opacity(0.4) : A.op(0.18), 0, 6 * D, 30 * D)])
        let g = mix(A, h("#FF4FD8"), 0.6)
        t.tileForIndex = { _ in SurfaceStyle(radius: 17 * R, fill: .gradient([A.color, g.color], angle: 135), shadows: [sh(A.op(0.45), 0, 6 * D, 16 * D)]) }
        let ic = ColorMath.onColor(mix(A, h("#FF4FD8"), 0.3)).color
        t.tileIconColor = { _ in ic }
        t.button = SurfaceStyle(radius: 18 * R, fill: .gradient([A.color, g.color], angle: 90), shadows: [sh(A.op(0.4), 0, 8, 22)])
        t.buttonGradient = .gradient([A.color, g.color], angle: 90)
        t.buttonLabel = ColorMath.onColor(mix(A, g, 0.5)); t.onAccent = t.buttonLabel
        t.buttonFill = mix(A, g, 0.5)
        if !x.boost {
            let tgt: RGB = d ? .white : .black, k = d ? 0.35 : 0.2
            t.amountGradient = [mix(A, tgt, k).color, mix(pink, tgt, d ? 0.3 : 0.2).color]
        }
        t.chip = ChipSpec(fill: A.op(d ? 0.2 : 0.14), text: ColorMath.ensure(A, est, 4.5).color)
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(x.solid ? est.color : Color.white.opacity(d ? 0.06 : 0.6)), material: x.solid ? nil : .ultraThinMaterial, topBorder: Color.white.opacity(d ? 0.14 : 0.95))
        t.toggle = ToggleSpec(on: A.color, off: d ? Color.white.opacity(0.2) : h("#575185").op(0.25))
        t.wording["fillOpacity"] = fmt(fillO)
        t.depthLines = ["Cards are white at \(fmt(fillO)) opacity with an 18 pt blur and a 1 pt white border at \(d ? "0.14" : "0.95") opacity.",
                        "Cards have a shadow: offset \(fmt(6 * D)) pt vertical, blur \(fmt(30 * D)) pt, \(d ? "black at 0.4" : "accent at 0.18") opacity.",
                        "Icon tiles are a 135 degree gradient from \(A.hex) to \(g.hex) with a glow (accent at 0.45, \(fmt(6 * D)) pt down, blur \(fmt(16 * D)) pt).",
                        x.boost ? "The large amount uses solid text color because Boost contrast is on." : "The large amount uses a horizontal gradient text fill from \(t.amountGradient == nil ? "" : "the accent") to the pink blend."]
        t.tileDesc = "62 pt gradient rounded square (accent to pink blend at 135 degrees) with a soft glow, high contrast icon, label below at 12 pt semibold"
        t.iconRule = "black or white, whichever contrasts more with the gradient (\(ColorMath.onColor(mix(A, h("#FF4FD8"), 0.3)).hex) here)."
        t.buttonExtra = "horizontal gradient from the accent to the pink blend with a glow"
        t.fallbackSentence = "With Reduce Transparency on, replace panels with a solid fill of \(est.hex). Pause any animated gradient under Reduce Motion."
        finish(&t); return t
    }
}
