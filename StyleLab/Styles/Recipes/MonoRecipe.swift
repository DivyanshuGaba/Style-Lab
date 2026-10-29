import SwiftUI

extension Recipes {
    static func mono(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R
        let bg = d ? h("#0C0C0C") : RGB.white
        var t = base(x, surface: bg)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.text = d ? h("#F5F5F5") : h("#111111")
        t.secondary = d ? h(x.boost ? "#D0D0D0" : "#A8A8A8") : h(x.boost ? "#3A3A3A" : "#5E5E5E")
        let line = x.boost ? t.text : (d ? h("#2C2C2C") : h("#DADADA"))
        t.separator = line.color; t.separatorText = line.hex
        t.cardRadius = 0; t.tileRadius = 999; t.buttonRadius = 3 * R
        t.headingDesign = .serif; t.bodyDesign = .default
        t.headingWeight = .semibold; t.amountWeight = .regular
        t.upperLabels = true; t.labelTracking = 1.1
        t.typefaceName = "New York (serif) for headings and the large amount, SF for body"
        t.typeRules = "Labels are uppercase, 11 pt, with 0.1 em tracking."
        t.card = SurfaceStyle(radius: 0, hairlines: line.color)
        let tc = t.text.color
        t.tileForIndex = { _ in SurfaceStyle(radius: 999, borderColor: tc) }
        t.tileIconColor = { _ in tc }
        t.button = SurfaceStyle(radius: 3 * R, fill: .solid(tc))
        t.buttonFill = t.text; t.buttonLabel = bg; t.onAccent = bg
        let ac = ColorMath.ensure(A, bg, 4.5).color
        t.chip = ChipSpec(fill: .clear, text: ac, border: ac, borderWidth: 1)
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(bg.color), topBorder: line.color)
        t.toggle = ToggleSpec(on: tc, off: (d ? h("#333333") : h("#D6D6D6")).color)
        t.depthLines = ["There are no filled cards and no shadows. Each block has a 1 pt hairline above and below in \(line.hex).",
                        "Icon tiles have no fill: a 1 pt outline circle in the text color with the icon inside.",
                        "Accent color appears only in chips, the active tab and links."]
        t.tileDesc = "62 pt circle with a 1 pt outline in the text color, no fill, icon in the text color, label below at 11 pt uppercase"
        t.iconRule = "the text color (\(t.text.hex) here)."
        t.buttonExtra = "filled with the text color, label in the background color"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }
}
