import SwiftUI

extension Recipes {
    static func skeu(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let surface = d ? h("#40444C") : h("#EEF0F3")
        var t = base(x, surface: surface)
        t.background = BackgroundSpec(fill: .gradient([(d ? h("#3A3D44") : h("#E9EBEF")).color, (d ? h("#2A2C31") : h("#CDD1D8")).color], angle: 180))
        t.backgroundText = d ? "vertical gradient #3A3D44 to #2A2C31" : "vertical gradient #E9EBEF to #CDD1D8"
        t.surfaceText = d ? "vertical gradient #4A4E57 to #363940" : "vertical gradient #FFFFFF to #E2E5EA"
        t.text = d ? h("#F2F3F5") : h("#23262C")
        t.secondary = d ? h(x.boost ? "#DDE1E8" : "#B7BCC6") : h(x.boost ? "#3B414B" : "#555B66")
        let border = d ? h("#1A1B1E") : h("#B3B8C2")
        t.separator = border.color; t.separatorText = border.hex
        t.cardRadius = 14 * R; t.tileRadius = 13 * R; t.buttonRadius = 12 * R
        t.card = SurfaceStyle(radius: 14 * R, fill: .gradient([(d ? h("#4A4E57") : RGB.white).color, (d ? h("#363940") : h("#E2E5EA")).color], angle: 180),
            borderColor: border.color, shadows: [sh(Color.black.opacity(d ? 0.5 : 0.22), 0, 1 + 3 * D, 3 + 8 * D)],
            inner: [ish(d ? Color.white.opacity(0.18) : .white, 0, 1, 0)])
        let gloss = FillSpec.gradient([mix(A, .white, 0.35).color, A.color, mix(A, .black, 0.25).color], angle: 180)
        let bb = mix(A, .black, 0.45).color
        t.tileForIndex = { _ in SurfaceStyle(radius: 13 * R, fill: gloss, borderColor: bb, shadows: [sh(Color.black.opacity(0.35), 0, 2, 4)], inner: [ish(Color.white.opacity(0.6), 0, 1, 0)]) }
        t.tileIconColor = { _ in .white }
        t.button = SurfaceStyle(radius: 12 * R, fill: gloss, borderColor: bb, shadows: [sh(Color.black.opacity(0.35), 0, 2, 4)], inner: [ish(Color.white.opacity(0.6), 0, 1, 0)])
        t.buttonGradient = gloss
        t.buttonLabel = .white
        t.buttonFill = mix(A, .black, 0.1)
        t.onAccent = .white
        t.chip = ChipSpec(fill: A.op(d ? 0.25 : 0.14), text: ColorMath.ensure(A, surface, 4.5).color, border: bb.opacity(0.5))
        t.tabFull = SurfaceStyle(radius: 0, fill: .gradient([(d ? h("#4A4E57") : h("#F4F5F7")).color, (d ? h("#2D3036") : h("#CBD0D8")).color], angle: 180),
                                 inner: [ish(d ? Color.white.opacity(0.18) : .white, 0, 1, 0)], topBorder: border.color)
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#1E2024") : h("#B9BEC8")).color, metal: true, recessed: true)
        t.depthLines = ["Surfaces are vertical metal gradients with a 1 pt border (\(border.hex)) and a 1 pt inner top highlight.",
                        "Cards have a drop shadow: offset \(fmt(1 + 3 * D)) pt vertical, blur \(fmt(3 + 8 * D)) pt, black at \(d ? "0.5" : "0.22") opacity.",
                        "Buttons and icon tiles use a glossy vertical gradient: \(mix(A, .white, 0.35).hex), \(A.hex) at 50 percent, \(mix(A, .black, 0.25).hex), with a 1 pt border (\(mix(A, .black, 0.45).hex)), a white inner top highlight at 0.6 and a drop shadow (2 pt down, blur 4, black at 0.35)."]
        t.tileDesc = "62 pt glossy bevelled square with vertical accent gradient, 1 pt dark accent border, white inner top highlight, white icon, label below at 12 pt semibold"
        t.iconRule = "white on the glossy tile, with a 1 pt text shadow."
        t.buttonExtra = "glossy vertical gradient with bevel and a 1 pt label shadow"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }
}
