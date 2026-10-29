import SwiftUI

extension Recipes {
    static func neu(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let B = d ? h("#272B33") : h("#E4E8EF"), H = d ? h("#31363F") : RGB.white, S = d ? h("#1C1F25") : h("#B7BECC")
        let dist = 3 + 10 * D, blur = 6 + 20 * D
        var t = base(x, surface: B)
        t.accentAdjusted = ColorMath.ensure(A, B, x.boost ? 4.5 : 3.5)
        t.tabActive = t.accentAdjusted.color
        t.background = solid(B); t.backgroundText = B.hex
        t.text = d ? h("#E8ECF4") : h("#2B3340")
        t.secondary = d ? h(x.boost ? "#C9D1DE" : "#A3ACBC") : h(x.boost ? "#38414F" : "#566174")
        t.separator = S.op(0.5); t.separatorText = "\(S.hex) at 0.5 opacity"
        t.cardRadius = 24 * R; t.tileRadius = 18 * R; t.buttonRadius = 18 * R
        let dual = [sh(S.color, dist, dist, blur), sh(H.color, -dist, -dist, blur)]
        t.card = SurfaceStyle(radius: 24 * R, fill: .solid(B.color), shadows: dual)
        let ic = ColorMath.ensure(A, B, x.boost ? 4.5 : 3.5).color
        t.tileForIndex = { _ in SurfaceStyle(radius: 18 * R, fill: .solid(B.color), inner: [ish(S.color, -dist / 2, -dist / 2, blur / 2), ish(H.color, dist / 2, dist / 2, blur / 2)]) }
        t.tileIconColor = { _ in ic }
        t.button = SurfaceStyle(radius: 18 * R, fill: .solid(A.color), shadows: dual)
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(B.color), shadows: [sh(S.color, 0, -4, 8 + 10 * D)])
        t.chip = ChipSpec(fill: .clear, text: ColorMath.ensure(A, B, 4.5).color, border: ColorMath.ensure(A, B, 4.5).color, borderWidth: 1)
        t.toggle = ToggleSpec(on: A.color, off: B.color, recessed: true)
        t.wording["dist"] = fmt(dist); t.wording["blur"] = fmt(blur)
        t.depthLines = ["Every raised surface uses two shadows: a dark one (\(S.hex)) offset \(fmt(dist)) pt right and down, and a light one (\(H.hex)) offset \(fmt(dist)) pt left and up, both with \(fmt(blur)) pt blur.",
                        "Icon tiles and toggle tracks are pressed in: inset shadows at half the offset (\(fmt(dist / 2)) pt) and half the blur (\(fmt(blur / 2)) pt).",
                        "State is never shown by shadow alone. Add a color or label change."]
        t.tileDesc = "62 pt pressed in rounded square on the base color \(B.hex) with inset shadows, accent colored icon, label below at 12 pt semibold"
        t.iconRule = "the accent adjusted to at least \(x.boost ? "4.5" : "3.5"):1 on the base color (\(ColorMath.ensure(A, B, x.boost ? 4.5 : 3.5).hex) here)."
        t.buttonExtra = "accent fill with the same dual shadows"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed. Keep a visible color or text change for every state."
        finish(&t); return t
    }
}
