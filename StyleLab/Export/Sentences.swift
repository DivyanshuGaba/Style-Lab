import Foundation

enum Sentences {
    static func mood(_ m: Mood) -> String {
        switch m {
        case .calm: "Calm and trustworthy. Nothing should shout."
        case .premium: "Premium and rich. It should feel layered and high quality."
        case .playful: "Friendly and playful. Warm, approachable, a little fun."
        case .bold: "Bold and loud. Strong contrast and attitude."
        case .tech: "Technical and futuristic. Precise, glowing, dense with information."
        }
    }
    static func context(_ c: UsageContext) -> String {
        switch c {
        case .legible: "Used by people of many ages, often outdoors in bright light. Prioritize legibility and large, clear controls."
        case .mixed: "Used in normal conditions by a mixed audience."
        case .night: "Used mostly at night or in dark mode. Dark mode is the primary appearance."
        }
    }
    static func effort(_ e: BuildEffort) -> String {
        switch e {
        case .simple: "Keep it fast and simple to build and maintain."
        case .rich: "Happy to invest effort for a richer, more polished result."
        }
    }
    static func flag(_ f: SatisfactionFlag) -> String {
        switch f {
        case .tooFlat: "The design feels too flat. Add depth or layering."
        case .tooBusy: "The design feels too busy. Simplify."
        case .lowContrast: "Contrast feels too low. Strengthen text and borders."
        case .tooPlayful: "It feels too playful for the app."
        case .tooSerious: "It feels too serious for the app."
        case .iconsHardToSee: "Icons are hard to see. Make them larger, heavier or higher contrast."
        case .wantsMoreColor: "The person wants more color."
        case .wantsLessColor: "The person wants less color."
        }
    }
    static func list(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        default: return items.dropLast().joined(separator: ", ") + " and " + items.last!
        }
    }
}
