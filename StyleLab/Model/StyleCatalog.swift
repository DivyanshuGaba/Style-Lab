import Foundation

struct Ratings: Equatable, Sendable {
    var iconClarity, textLegibility, richness, accessibility, ease, performance: Int
    init(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int) {
        iconClarity = a; textLegibility = b; richness = c; accessibility = d; ease = e; performance = f
    }
    static let labels = ["Icon clarity", "Text legibility", "Richness", "Accessibility safety", "Ease to build", "Performance"]
    var all: [Int] { [iconClarity, textLegibility, richness, accessibility, ease, performance] }
}

struct StyleInfo: Identifiable, Sendable {
    let id: StyleID
    let name, shortLabel, tagline, bestFor, watchOut: String
    let tips: [String]
    let ratings: Ratings
    let categories: [AppCategory]
    let moods: [Mood]
    let nightFriendly: Bool
    let handoffWording, swiftUINotes: String
}

enum StyleCatalog {
    static func info(_ id: StyleID) -> StyleInfo { all.first { $0.id == id } ?? all[0] }

    static let all: [StyleInfo] = [
        StyleInfo(id: .ios, name: "iOS Clean", shortLabel: "Clean",
            tagline: "Flat surfaces, grouped lists and tinted icon tiles, the look people already know.",
            bestFor: "utilities, finance and anything that should feel instantly familiar.",
            watchOut: "can feel generic, richness has to come from color, content and motion.",
            tips: ["Use tinted icon tiles so actions are easy to spot.", "Keep one accent for actions only.", "Prefer grouped lists over loose floating cards."],
            ratings: Ratings(4, 5, 2, 5, 5, 5), categories: [.utility, .finance, .productivity, .education], moods: [.calm], nightFriendly: false,
            handoffWording: "Cards are solid white (or #1C1C1E in dark) with a soft shadow and {cardRadius} pt corners. Icon tiles are tinted with the accent at low opacity. Lists are grouped with hairline separators.",
            swiftUINotes: "Use the system List with the insetGrouped style where possible, SF Symbols with the palette rendering mode, and a standard TabView. Use semantic colors that adapt to dark mode."),
        StyleInfo(id: .liquid, name: "Liquid Glass", shortLabel: "Glass",
            tagline: "Translucent glass with bright edges and floating capsule controls, as introduced with iOS 26.",
            bestFor: "media, social and premium dashboards on current iOS.",
            watchOut: "text over busy content loses contrast, prefer system materials over hand built blur.",
            tips: ["Put text on the more opaque glass tier.", "Keep floating bars short so content stays visible.", "Test over your busiest and plainest backgrounds."],
            ratings: Ratings(3, 3, 5, 3, 3, 3), categories: [.social, .wellness, .finance, .travel], moods: [.premium, .calm], nightFriendly: true,
            handoffWording: "Cards are frosted glass: white at {fillOpacity} opacity over a blurred, colorful backdrop, a 1 pt white edge, a bright inner top highlight, and a soft drop shadow. Controls float and are capsule shaped. The tab bar is a floating glass capsule.",
            swiftUINotes: "On iOS 26 and later use the native glass effect APIs and the system tab bar. For earlier versions use ultraThinMaterial with a white overlay stroke and a highlight gradient. Test text over the busiest background and keep text on the more opaque layer."),
        StyleInfo(id: .glass, name: "Glassmorphism", shortLabel: "Frosted",
            tagline: "Frosted panels floating over a vivid gradient.",
            bestFor: "hero screens, music, weather and onboarding.",
            watchOut: "contrast shifts with the background and blur is costly on older devices.",
            tips: ["Add a dark scrim behind text.", "Limit blur to two or three panels per screen.", "Fall back to solid fills when Reduce Transparency is on."],
            ratings: Ratings(3, 2, 5, 2, 3, 2), categories: [.social, .wellness, .travel, .games], moods: [.premium, .playful], nightFriendly: true,
            handoffWording: "Cards are frosted panels over a vivid gradient: white at {fillOpacity} opacity with a {blur} pt blur and a 1 pt translucent white border. Text is white.",
            swiftUINotes: "Use Material backgrounds or a blurred overlay, always with a darkening scrim behind text. Provide a solid fallback when Reduce Transparency is enabled. Limit the number of blurred layers per screen to protect performance."),
        StyleInfo(id: .neu, name: "Neumorphism", shortLabel: "Soft",
            tagline: "Soft extruded surfaces made from a paired light and dark shadow.",
            bestFor: "calm controls such as smart home dials, meditation and focus timers.",
            watchOut: "low contrast and weak edges make states and buttons hard to see.",
            tips: ["Never rely on shadow alone for state, add color or a label.", "Use it for a few key controls, not whole screens.", "Darken text more than feels necessary."],
            ratings: Ratings(2, 2, 4, 1, 3, 4), categories: [.wellness, .utility, .productivity], moods: [.calm, .tech], nightFriendly: false,
            handoffWording: "Everything shares one background color and is raised or pressed using a light shadow top left and a dark shadow bottom right ({dist} pt offset, {blur} pt blur). Icon tiles are pressed in (inset). State is also shown by color, never by shadow alone.",
            swiftUINotes: "Implement with two stacked shadows (one white or light, one dark) and an inset variant by overlaying a stroked shape with gradient masks. Use it on a small number of controls. Always pair state changes with color or text changes."),
        StyleInfo(id: .clay, name: "Claymorphism", shortLabel: "Puffy",
            tagline: "Puffy, rounded, toy like shapes with soft inner shadows.",
            bestFor: "kids, wellness, onboarding and friendly consumer apps.",
            watchOut: "needs generous spacing and can look childish for serious tasks.",
            tips: ["Keep the big radii consistent.", "Pair pastel fills with dark text.", "Use one puffy hero element and keep the rest quieter."],
            ratings: Ratings(4, 4, 5, 3, 2, 3), categories: [.wellness, .games, .education, .social, .shopping], moods: [.playful], nightFriendly: false,
            handoffWording: "Shapes are puffy and very round ({cardRadius} pt). Each has an inner highlight on top, an inner shade on the bottom, and a colored outer shadow. Icon tiles are pastel and rotate through four colors.",
            swiftUINotes: "Layer three shadows (outer colored, inner top light, inner bottom shade). Use large continuous corner radii (RoundedRectangle with style .continuous) and Font.Design.rounded."),
        StyleInfo(id: .brutal, name: "Neo Brutalism", shortLabel: "Loud",
            tagline: "Thick outlines, hard offset shadows and flat, loud color.",
            bestFor: "creative tools, youth brands and games that want attitude.",
            watchOut: "loud at scale, long reading screens feel heavy.",
            tips: ["Keep border thickness identical everywhere.", "Limit the palette to three or four colors.", "Set long text in a calmer type."],
            ratings: Ratings(5, 5, 3, 4, 4, 5), categories: [.games, .social, .utility, .shopping], moods: [.bold, .playful], nightFriendly: false,
            handoffWording: "Every element has a {w} pt solid {lineColor} outline and a hard offset shadow of {o} pt with no blur. Fills are flat and saturated. Labels are uppercase. Corners are nearly square ({cardRadius} pt).",
            swiftUINotes: "Draw each element with a stroke and an offset duplicate shape behind it for the hard shadow. Keep stroke width in one design token. Use heavy font weights and uppercase labels sparingly."),
        StyleInfo(id: .skeu, name: "Skeuomorphism", shortLabel: "Tactile",
            tagline: "Real world materials: bevels, gloss and physical switches.",
            bestFor: "music, camera and instrument tools where the touch feel is the product.",
            watchOut: "highest build cost and it dates quickly.",
            tips: ["Put texture on controls, not on text areas.", "Keep one consistent light direction.", "Draw with gradients and shadows instead of image files."],
            ratings: Ratings(5, 4, 5, 4, 1, 3), categories: [.games, .utility, .media], moods: [.premium, .bold], nightFriendly: false,
            handoffWording: "Controls look like physical objects: glossy gradient buttons with a bevel, a light inner top edge, and a small drop shadow. Surfaces are subtle metal gradients with thin borders. Switches have a metallic knob in a recessed track.",
            swiftUINotes: "Build with LinearGradient fills, inner highlight strokes, and subtle shadows rather than image assets. Keep one global light direction constant. Make custom switch and button styles with ButtonStyle and ToggleStyle."),
        StyleInfo(id: .aurora, name: "Aurora Gradient", shortLabel: "Glow",
            tagline: "A dark canvas with blurred color glows and gradient accents.",
            bestFor: "wellness, AI and creative apps that want atmosphere.",
            watchOut: "gradient text and glow can hurt legibility and battery.",
            tips: ["Use solid text where the gradient changes.", "Keep glows behind content, not on it.", "Respect Reduce Motion for animated gradients."],
            ratings: Ratings(3, 3, 5, 3, 3, 2), categories: [.wellness, .social, .games, .travel], moods: [.premium, .tech], nightFriendly: true,
            handoffWording: "The background is dark with blurred glows in the accent and neighboring hues. Cards are faint translucent panels with a thin light border. Accents and the large amount use gradients. Icon tiles are gradient fills with a soft glow.",
            swiftUINotes: "Draw blurred circles behind content in a ZStack with a large blur radius, with drawingGroup for performance. Use gradient fills for accents. Do not apply gradient text where contrast matters. Pause any animation under Reduce Motion."),
        StyleInfo(id: .oled, name: "Dark OLED", shortLabel: "Black",
            tagline: "True black surfaces, hairline borders and a single accent.",
            bestFor: "night use, finance, media and reading apps.",
            watchOut: "can feel stark, pure white on pure black tires some eyes.",
            tips: ["Use off white text for long reading.", "Separate layers with 1 point borders.", "Reserve color for status and actions."],
            ratings: Ratings(4, 5, 3, 5, 5, 5), categories: [.finance, .utility, .media, .productivity], moods: [.calm, .premium], nightFriendly: true,
            handoffWording: "The background is pure black. Cards are near black with a 1 pt hairline border and, in dark mode, a very faint accent glow. Color is reserved for actions and status.",
            swiftUINotes: "Use true black backgrounds in dark mode. Prefer 1 pt strokes for separation instead of shadows. Use off white (not pure white) for long body text."),
        StyleInfo(id: .bento, name: "Bento Grid", shortLabel: "Tiles",
            tagline: "Rounded tiles of different sizes that pack information tightly.",
            bestFor: "dashboards, home screens and feature overviews.",
            watchOut: "too many tile sizes feels chaotic.",
            tips: ["Use two tile sizes plus one hero tile.", "Give each tile one job.", "Color only the tiles that need attention."],
            ratings: Ratings(4, 4, 4, 4, 3, 5), categories: [.utility, .finance, .social, .productivity, .shopping], moods: [.calm, .tech], nightFriendly: false,
            handoffWording: "The home screen is a grid of rounded tiles of different sizes with a 12 pt gap. A wide hero tile uses the accent color. Four square action tiles use different fills. Each tile has one job.",
            swiftUINotes: "Use a Grid or LazyVGrid with explicit row and column spans. Keep all tiles on one corner radius token. Color only attention tiles."),
        StyleInfo(id: .mono, name: "Minimal Editorial", shortLabel: "Type",
            tagline: "Type led pages with hairline rules and almost no color.",
            bestFor: "reading, journaling and banking for calm audiences.",
            watchOut: "icons and actions can disappear without color or fill.",
            tips: ["Make the one primary button solid.", "Build hierarchy from weight and size.", "Keep icon strokes at 1.5 points or thicker."],
            ratings: Ratings(3, 5, 2, 4, 5, 5), categories: [.finance, .wellness, .education, .media], moods: [.calm, .premium], nightFriendly: false,
            handoffWording: "There are no filled cards. Sections are separated by 1 pt hairlines. Headings and large numbers use a serif face. Icons are thin outlines inside 1 pt circles. The only solid element is the primary button. Accent color is used sparingly.",
            swiftUINotes: "Rely on typography: Font.Design.serif for display text, thin stroke icons, and Divider based sections. Keep a single solid primary button per screen."),
        StyleInfo(id: .neon, name: "Cyber Neon", shortLabel: "Neon",
            tagline: "A dark base with glowing outlines and monospaced type.",
            bestFor: "gaming, crypto, developer tools and nightlife.",
            watchOut: "glow bleeds, and thin glowing text is tiring to read.",
            tips: ["Glow edges and icons, never paragraphs.", "Pick one neon hue plus a warning color.", "Keep body text near white."],
            ratings: Ratings(4, 3, 4, 2, 3, 4), categories: [.games, .utility, .finance], moods: [.tech, .bold], nightFriendly: true,
            handoffWording: "The background is near black. Cards and icon tiles have a 1 pt glowing outline in the accent color with an outer glow of {glowBlur} pt. Text is monospaced and uppercase for labels. Buttons glow.",
            swiftUINotes: "Use monospaced fonts, stroke borders in the accent color, and layered shadows with the same color for glow. Limit glow to edges and icons, not paragraphs. Use blendMode sparingly."),
    ]
}
