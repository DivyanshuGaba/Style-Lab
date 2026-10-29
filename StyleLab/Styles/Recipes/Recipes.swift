import SwiftUI

/// Shared scaffolding for the 12 style recipes. Every number in the recipe files comes from section 6 of the spec.
enum Recipes {
    static func base(_ x: Ctx, surface: RGB) -> StyleTokens {
        var t = StyleTokens(style: x.spec.style, mode: x.spec.mode, accent: x.A, boost: x.boost)
        t.surfaceEstimate = surface
        t.surfaceText = surface.hex
        t.accentAdjusted = ColorMath.ensure(x.A, surface, 3)
        t.onAccent = ColorMath.onColor(x.A)
        t.buttonLabel = t.onAccent
        t.positive = x.dark ? h("#5BE08C") : h("#12794A")
        t.tabActive = t.accentAdjusted.color
        t.chip = ChipSpec(fill: x.A.op(0.16), text: ColorMath.ensure(x.A, surface, 4.5).color)
        t.toggle = ToggleSpec(on: x.A.color, off: .gray)
        t.wording["cardRadius"] = fmt(18 * x.R)
        return t
    }

    static func solid(_ c: RGB) -> BackgroundSpec { BackgroundSpec(fill: .solid(c.color)) }

    static func finish(_ t: inout StyleTokens) {
        if t.tabFloating.radius == 0 {
            var f = t.card
            f.radius = 34
            if f.hairlines != nil { f = SurfaceStyle(radius: 34, fill: .solid(t.surfaceEstimate.color), borderColor: t.separator) }
            t.tabFloating = f
        }
        t.tabRadius = t.tabFull.radius
    }

    static func sh(_ c: Color, _ x: CGFloat, _ y: CGFloat, _ blur: CGFloat) -> Shadow { Shadow(color: c, x: x, y: y, blur: blur) }
    static func ish(_ c: Color, _ x: CGFloat, _ y: CGFloat, _ blur: CGFloat) -> InnerShadow { InnerShadow(color: c, x: x, y: y, blur: blur) }

    static func material(_ blurRadius: CGFloat) -> Material {
        blurRadius < 17 ? .ultraThinMaterial : (blurRadius < 30 ? .thinMaterial : .regularMaterial)
    }
}
