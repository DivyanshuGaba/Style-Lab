import SwiftUI

extension Recipes {
    static func brutal(_ x: Ctx) -> StyleTokens {
        let d = x.dark, A = x.A, R = x.R, D = x.D
        let K: RGB = d ? .white : .black
        let w = 2 + 2 * D, o = 3 + 5 * D
        let bg = d ? h("#151515") : h("#FFF7D1"), surface = d ? h("#232323") : RGB.white
        var t = base(x, surface: surface)
        t.background = solid(bg); t.backgroundText = bg.hex
        t.text = K; t.secondary = d ? h("#E5E5E5") : h("#222222")
        t.separator = K.color; t.separatorText = "\(K.hex), \(fmt(w)) pt"
        t.cardRadius = 6 * R; t.tileRadius = 6 * R; t.buttonRadius = 6 * R
        t.headingWeight = .heavy; t.amountWeight = .black
        t.upperLabels = true; t.labelTracking = 0.75
        t.typefaceName = "SF with heavy weights"
        t.typeRules = "Labels are uppercase with 0.06 em tracking. Headings use heavy weight and big numbers use black weight."
        t.card = SurfaceStyle(radius: 6 * R, fill: .solid(surface.color), borderColor: K.color, borderWidth: w, hardColor: K.color, hardOffset: o)
        let fills = [h("#FF6B6B"), h("#FFD93D"), h("#6BCB77"), h("#4D96FF")]
        t.tileForIndex = { i in SurfaceStyle(radius: 6 * R, fill: .solid(fills[i % 4].color), borderColor: K.color, borderWidth: w, hardColor: K.color, hardOffset: o / 2) }
        t.tileIconColor = { _ in .black }
        t.button = SurfaceStyle(radius: 6 * R, fill: .solid(A.color), borderColor: K.color, borderWidth: w, hardColor: K.color, hardOffset: o)
        t.chip = ChipSpec(fill: h("#FFD93D").color, text: .black, border: K.color, borderWidth: 2)
        t.tabFull = SurfaceStyle(radius: 0, fill: .solid(surface.color), topBorder: K.color, topBorderWidth: w)
        t.toggle = ToggleSpec(on: A.color, off: (d ? h("#444444") : h("#DDDDDD")).color, border: K.color, borderWidth: 2, square: true, knob: .white, knobBorder: .black)
        t.wording["w"] = fmt(w); t.wording["o"] = fmt(o); t.wording["lineColor"] = d ? "white" : "black"
        t.depthLines = ["Every element has a \(fmt(w)) pt solid outline in \(K.hex).",
                        "Cards and buttons have a hard shadow offset \(fmt(o)) pt right and down, no blur, in \(K.hex). Icon tiles use half that offset (\(fmt(o / 2)) pt).",
                        "Icon tile fills rotate through #FF6B6B, #FFD93D, #6BCB77, #4D96FF. Chips are #FFD93D with black text and a 2 pt outline."]
        t.tileDesc = "62 pt near square tile with \(fmt(w)) pt outline and hard shadow, rotating flat fills, black icon, label below at 12 pt semibold uppercase"
        t.iconRule = "black on the colored tile."
        t.buttonExtra = "uppercase label with 0.05 em tracking, \(fmt(w)) pt outline and hard shadow"
        t.fallbackSentence = "This style has no transparency, so no fallback is needed."
        finish(&t); return t
    }
}
