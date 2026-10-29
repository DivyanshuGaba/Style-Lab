import SwiftUI

struct Shadow { var color: Color; var x: CGFloat = 0; var y: CGFloat; var blur: CGFloat }
struct InnerShadow { var color: Color; var x: CGFloat = 0; var y: CGFloat; var blur: CGFloat }

enum FillSpec {
    case none
    case solid(Color)
    case linear([Gradient.Stop], angle: Double)   // CSS style: 0 = up, 90 = right, 180 = down

    var style: AnyShapeStyle {
        switch self {
        case .none: return AnyShapeStyle(Color.clear)
        case .solid(let c): return AnyShapeStyle(c)
        case .linear(let stops, let angle):
            let r = angle * .pi / 180
            return AnyShapeStyle(LinearGradient(stops: stops,
                startPoint: UnitPoint(x: 0.5 - sin(r) / 2, y: 0.5 + cos(r) / 2),
                endPoint: UnitPoint(x: 0.5 + sin(r) / 2, y: 0.5 - cos(r) / 2)))
        }
    }
    static func gradient(_ colors: [Color], angle: Double) -> FillSpec {
        let n = max(colors.count - 1, 1)
        return .linear(colors.enumerated().map { .init(color: $1, location: Double($0) / Double(n)) }, angle: angle)
    }
}

struct SurfaceStyle {
    var radius: CGFloat = 0
    var fill: FillSpec = .none
    var material: Material? = nil
    var borderColor: Color? = nil
    var borderWidth: CGFloat = 1
    var shadows: [Shadow] = []
    var inner: [InnerShadow] = []
    var hardColor: Color? = nil
    var hardOffset: CGFloat = 0
    var hairlines: Color? = nil          // editorial: rules above and below, no fill
    var topBorder: Color? = nil
    var topBorderWidth: CGFloat = 1
}

struct ToggleSpec {
    var on = Color.green, off = Color.gray
    var border: Color? = nil
    var borderWidth: CGFloat = 0
    var square = false
    var knob = Color.white
    var metal = false
    var recessed = false
    var knobBorder: Color? = nil
}

struct ChipSpec {
    var fill: Color = .clear
    var text: Color = .primary
    var border: Color? = nil
    var borderWidth: CGFloat = 1
}

struct Blob { var color: Color; var diameter: CGFloat; var opacity: Double; var alignment: Alignment; var dx: CGFloat = 0; var dy: CGFloat = 0 }
struct BackgroundSpec { var fill: FillSpec = .none; var blobs: [Blob] = [] }

enum FontRole { case largeTitle, title, section, body, caption, tabLabel, amount }
enum LayoutKind { case standard, bento }

struct StyleTokens {
    var style: StyleID
    var mode: AppearanceMode
    var accent: RGB
    var accentAdjusted: RGB
    var onAccent: RGB = .white
    var boost: Bool
    var estimated = false
    var reduceTransparency = false

    var background = BackgroundSpec()
    var backgroundText = ""
    var surfaceText = ""
    var surfaceEstimate: RGB = .white
    var text: RGB = .black
    var secondary: RGB = RGB(r: 128, g: 128, b: 128)
    var separator: Color = .gray
    var separatorText = ""
    var positive: RGB = .black
    var buttonFill: RGB
    var buttonLabel: RGB = .white

    var cardRadius: CGFloat = 18, tileRadius: CGFloat = 14, buttonRadius: CGFloat = 14, tabRadius: CGFloat = 0
    var card = SurfaceStyle()
    var tileForIndex: (Int) -> SurfaceStyle = { _ in SurfaceStyle() }
    var tileIconColor: (Int) -> Color = { _ in .primary }
    var button = SurfaceStyle()
    var buttonGradient: FillSpec? = nil
    var chip = ChipSpec()
    var tabFull = SurfaceStyle()
    var tabFloating = SurfaceStyle()
    var tabActive: Color = .accentColor
    var toggle = ToggleSpec()
    var homeIndicator = true

    var headingDesign: Font.Design = .default
    var bodyDesign: Font.Design = .default
    var headingWeight: Font.Weight = .bold
    var amountWeight: Font.Weight = .bold
    var upperLabels = false
    var labelTracking: CGFloat = 0
    var typefaceName = "SF (system default)"
    var typeRules = "No special label styling."
    var amountGradient: [Color]? = nil

    var strokeWidth: Double = 1.8
    var iconWeight: Font.Weight = .regular
    var spacing: Double = 1.0
    var margin: CGFloat { 20 * spacing }
    var gap: CGFloat { 18 * spacing }
    var rowV: CGFloat { 12 * spacing }
    var rowH: CGFloat { 16 * spacing }
    var layout: LayoutKind = .standard
    var bentoTiles: [(Color, Color)] = []
    var floatingTab = false
    /// Every design uses the same bottom bar, so these never vary with the style.
    var tabHeight: CGFloat { StandardBar.height }

    // handoff text
    var wording: [String: String] = [:]
    var depthLines: [String] = []
    var tileDesc = ""
    var iconRule = ""
    var buttonExtra = ""
    var fallbackSentence = ""

    init(style: StyleID, mode: AppearanceMode, accent: RGB, boost: Bool) {
        self.style = style; self.mode = mode; self.accent = accent; self.accentAdjusted = accent
        self.buttonFill = accent; self.boost = boost
    }

    var tabBar: SurfaceStyle { floatingTab ? tabFloating : tabFull }
    var tabBarRadius: CGFloat { floatingTab ? 34 : tabRadius }

    func font(_ role: FontRole, weight w: Font.Weight? = nil) -> Font {
        switch role {
        case .largeTitle: return .system(size: 34, weight: w ?? headingWeight, design: headingDesign)
        case .title: return .system(size: 22, weight: w ?? headingWeight, design: headingDesign)
        case .section: return .system(size: 20, weight: w ?? headingWeight, design: headingDesign)
        case .body: return .system(size: 16, weight: w ?? .regular, design: bodyDesign)
        case .caption: return .system(size: 12.5, weight: w ?? .medium, design: bodyDesign)
        case .tabLabel: return .system(size: 10, weight: w ?? .medium, design: bodyDesign)
        case .amount: return .system(size: 40, weight: w ?? amountWeight, design: headingDesign)
        }
    }

    func label(_ s: String, _ role: FontRole = .caption, weight: Font.Weight? = nil) -> Text {
        let t = Text(upperLabels ? s.uppercased() : s).font(font(role, weight: weight))
        return upperLabels ? t.tracking(labelTracking) : t
    }

    func iconFont(_ size: CGFloat) -> Font { .system(size: size, weight: iconWeight) }

    var resolvedAccentIcon: Color { accentAdjusted.color }

    // MARK: contrast table
    struct ContrastRow: Identifiable { var id: String { title }; var title: String; var ratio: Double; var target: Double
        var passes: Bool { (ratio * 10).rounded() / 10 >= target } }
    var contrastRows: [ContrastRow] {
        [ContrastRow(title: "Body text on surface", ratio: ColorMath.contrast(text, surfaceEstimate), target: 4.5),
         ContrastRow(title: "Secondary text on surface", ratio: ColorMath.contrast(secondary, surfaceEstimate), target: 4.5),
         ContrastRow(title: "Raw accent as an icon", ratio: ColorMath.contrast(accent, surfaceEstimate), target: 3),
         ContrastRow(title: "Button label on accent", ratio: ColorMath.contrast(buttonLabel, buttonFill), target: 4.5)]
    }

    static func make(_ spec: DesignSpec, reduceTransparency: Bool = false, increaseContrast: Bool = false) -> StyleTokens {
        let x = Ctx(spec: spec, solid: reduceTransparency, boost: spec.boostContrast || increaseContrast)
        var t: StyleTokens
        switch spec.style {
        case .ios: t = Recipes.ios(x)
        case .liquid: t = Recipes.liquid(x)
        case .glass: t = Recipes.glass(x)
        case .neu: t = Recipes.neu(x)
        case .clay: t = Recipes.clay(x)
        case .brutal: t = Recipes.brutal(x)
        case .skeu: t = Recipes.skeu(x)
        case .aurora: t = Recipes.aurora(x)
        case .oled: t = Recipes.oled(x)
        case .bento: t = Recipes.bento(x)
        case .mono: t = Recipes.mono(x)
        case .neon: t = Recipes.neon(x)
        }
        t.reduceTransparency = reduceTransparency
        t.applyUserSettings(spec, x)
        return t
    }

    mutating func applyUserSettings(_ spec: DesignSpec, _ x: Ctx) {
        spacing = spec.density.scale
        switch spec.typeface {
        case .styleDefault: break
        case .system: headingDesign = .default; bodyDesign = .default; typefaceName = "SF (system default)"
        case .rounded: headingDesign = .rounded; bodyDesign = .rounded; typefaceName = "SF Rounded"
        case .serif: headingDesign = .serif; bodyDesign = .serif; typefaceName = "New York (serif)"
        case .mono: headingDesign = .monospaced; bodyDesign = .monospaced; typefaceName = "SF Mono (monospaced)"
        }
        // icon stroke
        var w: Double
        switch spec.iconWeight { case .light: w = 1.4; case .regular: w = 1.8; case .bold: w = 2.4 }
        if spec.style == .brutal && spec.iconWeight != .light { w = 2.4 }
        if spec.style == .mono && spec.iconWeight == .regular { w = 1.4 }
        strokeWidth = w
        iconWeight = w <= 1.4 ? .light : (w <= 1.8 ? .regular : .semibold)
        switch spec.tabBar {
        case .styleDefault: break
        case .standard: floatingTab = false
        case .floating: floatingTab = true
        }
    }
}

struct Ctx {
    let spec: DesignSpec
    let solid: Bool
    let boost: Bool
    var dark: Bool { spec.mode == .dark }
    var A: RGB { ColorMath.parse(spec.accentHex) ?? RGB(hex: "#2F6BFF") }
    var R: CGFloat { CGFloat(spec.radiusScale) }
    var D: CGFloat { CGFloat(spec.depth) }
    var c: Double { boost ? 1 : 0 }
}

func h(_ s: String) -> RGB { RGB(hex: s) }
func mix(_ a: RGB, _ b: RGB, _ t: Double) -> RGB { ColorMath.mix(a, b, t) }
func fmt(_ v: Double) -> String {
    var s = String(format: "%.2f", v)
    while s.hasSuffix("0") { s.removeLast() }
    if s.hasSuffix(".") { s.removeLast() }
    return s == "-0" ? "0" : s
}
func fmt(_ v: CGFloat) -> String { fmt(Double(v)) }
