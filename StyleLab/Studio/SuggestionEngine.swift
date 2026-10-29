import Foundation

enum SuggestionAction: Equatable {
    case boostContrast
    case switchStyle(StyleID)
    case setAccent(String)
    case setMode(AppearanceMode)
    case compare(StyleID)
    case setDepth(Double)
    case setRadius(Double)

    var label: String {
        switch self {
        case .boostContrast: "Boost contrast"
        case .switchStyle(let s): "Switch to \(StyleCatalog.info(s).name)"
        case .setAccent: "Pick a stronger accent"
        case .setMode(let m): "Switch to \(m.title.lowercased()) mode"
        case .compare(let s): "Compare with \(StyleCatalog.info(s).name)"
        case .setDepth(let d): "Set depth to \(Int(d * 100)) percent"
        case .setRadius(let r): "Set roundness to \(fmt(r))x"
        }
    }

    func apply(to spec: inout DesignSpec) {
        switch self {
        case .boostContrast: spec.boostContrast = true
        case .switchStyle(let s): spec.style = s
        case .setAccent(let hex): spec.accentHex = hex
        case .setMode(let m): spec.mode = m
        case .compare(let s): spec.compareStyle = s
        case .setDepth(let d): spec.depth = d
        case .setRadius(let r): spec.radiusScale = r
        }
    }
}

struct Suggestion: Identifiable, Equatable {
    let id: String
    let title: String
    let reasoning: String
    let actions: [SuggestionAction]
}

enum SuggestionEngine {
    static func suggestions(for spec: DesignSpec) -> [Suggestion] {
        var out: [Suggestion] = []
        let t = StyleTokens.make(spec)
        let info = StyleCatalog.info(spec.style)
        let b = spec.brief

        // Contrast
        let rows = t.contrastRows
        if let bad = [rows[0], rows[1], rows[3]].first(where: { !$0.passes }) {
            let name = bad.title.replacingOccurrences(of: " on surface", with: "").replacingOccurrences(of: " on accent", with: "")
            let ratio = String(format: "%.1f", bad.ratio)
            if !spec.boostContrast {
                out.append(Suggestion(id: "contrast", title: "\(name) is \(ratio):1, below 4.5:1",
                    reasoning: "Low contrast is hard to read outdoors and for many users. Boosting contrast strengthens text and borders.", actions: [.boostContrast]))
            } else {
                let safer = saferStyle(spec)
                out.append(Suggestion(id: "contrast", title: "\(name) is \(ratio):1, below 4.5:1",
                    reasoning: "Boost contrast is already on and this style still falls short.", actions: [.switchStyle(safer)]))
            }
        }
        if !rows[2].passes {
            let current = ColorMath.parse(spec.accentHex) ?? .black
            let passing = Palette.accents.filter { ColorMath.contrast(RGB(hex: $0), t.surfaceEstimate) >= 3 }
            let nearest = passing.min { dist(RGB(hex: $0), current) < dist(RGB(hex: $1), current) }
            out.append(Suggestion(id: "accent", title: "Your accent is too light for icons on this background",
                reasoning: "The preview adjusts icons automatically, the export records both values.",
                actions: nearest.map { [.setAccent($0)] } ?? []))
        }
        // Night
        if spec.mode == .light, (info.nightFriendly && spec.style != .oled) || b.context == .night {
            out.append(Suggestion(id: "night", title: "This style looks best in dark mode",
                reasoning: b.context == .night ? "Your brief says the app is used mostly at night." : "\(info.name) is designed around dark surfaces.",
                actions: [.setMode(.dark)]))
        }
        if spec.style == .neu && b.context == .legible {
            out.append(Suggestion(id: "neu", title: "Neumorphism struggles in bright light",
                reasoning: "Soft shadows nearly vanish outdoors. Clay or iOS Clean keep the friendly feel with clearer edges.",
                actions: [.compare(.clay), .compare(.ios)]))
        }
        if [.liquid, .glass, .aurora].contains(spec.style) && spec.depth > 0.8 {
            out.append(Suggestion(id: "blur", title: "Heavy blur can hurt legibility",
                reasoning: "Strong blur and glass lower text contrast and cost performance.", actions: [.setDepth(0.5)]))
        }
        if b.mood == .playful && spec.radiusScale < 0.7 {
            out.append(Suggestion(id: "radius", title: "Corners feel too sharp for a playful app",
                reasoning: "Rounder corners read as friendlier.", actions: [.setRadius(1.2)]))
        } else if b.mood == .calm && spec.style == .brutal {
            out.append(Suggestion(id: "loud", title: "Corners and outlines feel too loud for a calm app",
                reasoning: "Neo Brutalism is meant to shout. iOS Clean is calmer.", actions: [.switchStyle(.ios)]))
        }
        if b.effort == .simple && info.ratings.ease <= 2 {
            let alts = StyleRanker.rank(b).filter { $0.style != spec.style }
                .sorted { StyleCatalog.info($0.style).ratings.ease > StyleCatalog.info($1.style).ratings.ease }
            let simple = alts.filter { StyleCatalog.info($0.style).categories.contains(b.category) }
            let pick = (simple.isEmpty ? alts : simple).prefix(3).map { SuggestionAction.switchStyle($0.style) }
            out.append(Suggestion(id: "cost", title: "This style is costly to build and maintain",
                reasoning: "Your brief asks for something quick and simple. These are easier to build.", actions: Array(pick)))
        }
        if (spec.typeface == .mono || spec.typeface == .serif) && b.context == .legible {
            out.append(Suggestion(id: "type", title: "Large text sizes matter more than usual with this typeface",
                reasoning: "Mono and serif faces are harder to read at small sizes outdoors.", actions: []))
        }
        return out
    }

    static func saferStyle(_ spec: DesignSpec) -> StyleID {
        let ranked = StyleRanker.rank(spec.brief)
        let best = ranked.filter { $0.style != spec.style }
            .max { a, b in
                let ra = StyleCatalog.info(a.style).ratings.accessibility, rb = StyleCatalog.info(b.style).ratings.accessibility
                return ra != rb ? ra < rb : a.score < b.score
            }
        return best?.style ?? .ios
    }

    private static func dist(_ a: RGB, _ b: RGB) -> Double { abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b) }
}
