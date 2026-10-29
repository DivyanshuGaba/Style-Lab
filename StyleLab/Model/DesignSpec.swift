import Foundation

enum StyleID: String, CaseIterable, Codable, Identifiable, Sendable {
    case ios, liquid, glass, neu, clay, brutal, skeu, aurora, oled, bento, mono, neon
    var id: String { rawValue }
}

enum AppearanceMode: String, Codable, Sendable { case light, dark
    var opposite: AppearanceMode { self == .light ? .dark : .light }
    var title: String { self == .light ? "Light" : "Dark" }
}

enum SampleScreen: String, Codable, CaseIterable, Sendable {
    case home, settings, sales, repair, inventory, friends, contacts, messages, chat, orders, customers, invoices
    case analytics, calendar, tasks, wallet, profile, notifications, explore, shop, cart, workouts, music, trips
    case courses, support, appointments, team, expenses
    /// A screenshot the person imported. Not part of allCases because it is not a built in sample.
    case imported

    static var allCases: [SampleScreen] {
        [.home, .settings, .sales, .repair, .inventory, .friends, .contacts, .messages, .chat, .orders, .customers, .invoices,
         .analytics, .calendar, .tasks, .wallet, .profile, .notifications, .explore, .shop, .cart, .workouts, .music, .trips,
         .courses, .support, .appointments, .team, .expenses]
    }
}

enum AppCategory: String, Codable, CaseIterable, Sendable {
    case finance, social, wellness, games, utility, shopping, education, media, travel, productivity
    var title: String { rawValue.capitalized }
}
enum Mood: String, Codable, CaseIterable, Sendable { case calm, premium, playful, bold, tech }
enum UsageContext: String, Codable, CaseIterable, Sendable { case legible, mixed, night }
enum BuildEffort: String, Codable, CaseIterable, Sendable { case simple, rich }

enum Typeface: String, Codable, CaseIterable, Sendable { case styleDefault, system, rounded, serif, mono
    var title: String {
        switch self {
        case .styleDefault: "Style default"
        case .system: "System"
        case .rounded: "Rounded"
        case .serif: "Serif"
        case .mono: "Mono"
        }
    }
}
enum IconWeight: String, Codable, CaseIterable, Sendable { case light, regular, bold
    var title: String { rawValue.capitalized }
}
enum Density: String, Codable, CaseIterable, Sendable { case compact, regular, roomy
    var title: String { rawValue.capitalized }
    var scale: Double { switch self { case .compact: 0.85; case .regular: 1.0; case .roomy: 1.15 } }
}
enum TabBarStyle: String, Codable, CaseIterable, Sendable { case styleDefault, standard, floating
    var title: String { self == .styleDefault ? "Style default" : rawValue.capitalized }
}

enum SatisfactionFlag: String, Codable, CaseIterable, Sendable {
    case tooFlat, tooBusy, lowContrast, tooPlayful, tooSerious, iconsHardToSee, wantsMoreColor, wantsLessColor
    var chipTitle: String {
        switch self {
        case .tooFlat: "Too flat"
        case .tooBusy: "Too busy"
        case .lowContrast: "Low contrast"
        case .tooPlayful: "Too playful"
        case .tooSerious: "Too serious"
        case .iconsHardToSee: "Icons hard to see"
        case .wantsMoreColor: "Want more color"
        case .wantsLessColor: "Want less color"
        }
    }
}

struct Brief: Codable, Equatable, Sendable {
    var appName: String = ""
    var oneLiner: String = ""
    var category: AppCategory = .utility
    var mood: Mood = .calm
    var context: UsageContext = .mixed
    var effort: BuildEffort = .simple
}

struct DesignSpec: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var name: String = "Untitled design"
    var brief = Brief()
    var style: StyleID = .ios
    var compareStyle: StyleID? = nil
    var mode: AppearanceMode = .light
    var accentHex: String = "#2F6BFF"
    var radiusScale: Double = 1.0
    var depth: Double = 0.6
    var boostContrast: Bool = false
    var typeface: Typeface = .styleDefault
    var iconWeight: IconWeight = .regular
    var density: Density = .regular
    var tabBar: TabBarStyle = .styleDefault
    var screens: [SampleScreen] = [.home, .settings]
    var notes: String = ""
    var satisfaction: [SatisfactionFlag] = []
    var createdAt = Date()
    var updatedAt = Date()
    /// Per element edits made in the layout editor. Key is "screen/elementId".
    var edits: [String: ElementEdit] = [:]
    /// Screenshots imported from existing apps and turned into editable layouts.
    var imports: [ImportedScreen] = []
    var currentImport: UUID? = nil
    /// Which kind of app the sample screens show.
    var app: SampleApp = .wallet
    /// Shows only empty tiles: no names, numbers, text or icons. Used for downloads and exports that should carry design only.
    var hideDetails: Bool = false

    /// A clean spec with only a style and mode: what the Gallery shows, untouched by Studio work.
    static func pristine(style: StyleID, mode: AppearanceMode = .light, app: SampleApp = .wallet) -> DesignSpec {
        var d = DesignSpec(); d.style = style; d.mode = mode; d.app = app; return d
    }

    var withoutLayoutEdits: DesignSpec { var c = self; c.edits = [:]; c.imports = []; c.currentImport = nil; return c }

    /// True when the person has changed anything beyond picking a style and answering the brief.
    var hasCustomizations: Bool {
        let d = DesignSpec()
        return accentHex.uppercased() != d.accentHex || radiusScale != d.radiusScale || depth != d.depth || boostContrast || typeface != d.typeface
            || iconWeight != d.iconWeight || density != d.density || tabBar != d.tabBar || !edits.isEmpty || !imports.isEmpty
            || compareStyle != nil || !notes.isEmpty || !satisfaction.isEmpty || hideDetails
    }

    var activeImport: ImportedScreen? { imports.first { $0.id == currentImport } ?? imports.first }

    mutating func resetTuning() {
        radiusScale = 1.0; depth = 0.6; boostContrast = false; typeface = .styleDefault
        iconWeight = .regular; density = .regular; tabBar = .styleDefault; accentHex = "#2F6BFF"
    }
}

enum Palette {
    static let accents = ["#2F6BFF", "#0E9F8E", "#F2542D", "#8B5CF6", "#E23D7B", "#E0A100"]
}


extension DesignSpec {
    enum CodingKeys: String, CodingKey {
        case id, name, brief, style, compareStyle, mode, accentHex, radiusScale, depth, boostContrast, typeface
        case iconWeight, density, tabBar, screens, notes, satisfaction, createdAt, updatedAt, edits, imports, currentImport, app, hideDetails
    }

    /// Tolerant decoder: files saved by older versions lack newer keys.
    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? id
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? name
        brief = try c.decodeIfPresent(Brief.self, forKey: .brief) ?? brief
        style = try c.decodeIfPresent(StyleID.self, forKey: .style) ?? style
        compareStyle = try c.decodeIfPresent(StyleID.self, forKey: .compareStyle)
        mode = try c.decodeIfPresent(AppearanceMode.self, forKey: .mode) ?? mode
        accentHex = try c.decodeIfPresent(String.self, forKey: .accentHex) ?? accentHex
        radiusScale = try c.decodeIfPresent(Double.self, forKey: .radiusScale) ?? radiusScale
        depth = try c.decodeIfPresent(Double.self, forKey: .depth) ?? depth
        boostContrast = try c.decodeIfPresent(Bool.self, forKey: .boostContrast) ?? boostContrast
        typeface = try c.decodeIfPresent(Typeface.self, forKey: .typeface) ?? typeface
        iconWeight = try c.decodeIfPresent(IconWeight.self, forKey: .iconWeight) ?? iconWeight
        density = try c.decodeIfPresent(Density.self, forKey: .density) ?? density
        tabBar = try c.decodeIfPresent(TabBarStyle.self, forKey: .tabBar) ?? tabBar
        screens = try c.decodeIfPresent([SampleScreen].self, forKey: .screens) ?? screens
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? notes
        satisfaction = try c.decodeIfPresent([SatisfactionFlag].self, forKey: .satisfaction) ?? satisfaction
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? createdAt
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? updatedAt
        edits = try c.decodeIfPresent([String: ElementEdit].self, forKey: .edits) ?? [:]
        imports = try c.decodeIfPresent([ImportedScreen].self, forKey: .imports) ?? []
        currentImport = try c.decodeIfPresent(UUID.self, forKey: .currentImport)
        app = try c.decodeIfPresent(SampleApp.self, forKey: .app) ?? .wallet
        hideDetails = try c.decodeIfPresent(Bool.self, forKey: .hideDetails) ?? false
    }
}
