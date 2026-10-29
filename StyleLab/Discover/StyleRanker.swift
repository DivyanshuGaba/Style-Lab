import Foundation

struct StyleScore: Identifiable, Equatable {
    var id: StyleID { style }
    let style: StyleID
    let score: Double
    let reasons: [String]
    let percent: Int
    let mismatch: String
}

enum StyleRanker {
    static func rank(_ b: Brief) -> [StyleScore] {
        let scored: [(Int, StyleScore)] = StyleCatalog.all.enumerated().map { idx, s in
            var score = 0.0
            var reasons: [String] = []
            var gaps: [(Double, String)] = []
            let r = s.ratings

            if s.categories.contains(b.category) { score += 3; reasons.append("suits \(b.category.rawValue) apps") }
            else { gaps.append((3, "not a typical fit for \(b.category.rawValue) apps")) }

            if let i = s.moods.firstIndex(of: b.mood) {
                score += i == 0 ? 3 : 2; reasons.append("feels \(b.mood.rawValue)")
                if i > 0 { gaps.append((1, "only a secondary match for a \(b.mood.rawValue) feel")) }
            } else { gaps.append((3, "does not naturally feel \(b.mood.rawValue)")) }

            if b.context == .legible {
                let v = Double(r.textLegibility + r.accessibility - 6) * 1.2
                score += v
                if v >= 1.2 { reasons.append("reads well in bright light") }
                if v < 0 { gaps.append((-v, "weak legibility for many ages and bright light")) }
            }
            if b.context == .night {
                if s.nightFriendly { score += 2.5; reasons.append("looks best in the dark") }
                else { gaps.append((2.5, "not built for dark use")) }
            }
            if b.effort == .simple {
                let v = Double(r.ease - 3) * 1.2 + Double(r.performance - 3) * 0.4
                score += v
                if r.ease >= 4 { reasons.append("quick to build") }
                if v < 0 { gaps.append((-v, "costly to build and maintain")) }
            } else {
                score += Double(r.richness - 3)
                if r.richness == 5 { reasons.append("rich and layered") }
                if r.richness < 3 { gaps.append((Double(3 - r.richness), "not very rich or layered")) }
            }
            let pct = max(5, min(99, Int((score / 10 * 100).rounded())))
            let mismatch = gaps.max { $0.0 < $1.0 }?.1 ?? "no big mismatch, it just scored lower"
            return (idx, StyleScore(style: s.id, score: score, reasons: reasons, percent: pct, mismatch: mismatch))
        }
        return scored.sorted { $0.1.score != $1.1.score ? $0.1.score > $1.1.score : $0.0 < $1.0 }.map { $0.1 }
    }

    static func briefSentence(_ b: Brief) -> String {
        let mood: String
        switch b.mood {
        case .calm: mood = "calm"; case .premium: mood = "premium"; case .playful: mood = "playful"
        case .bold: mood = "bold"; case .tech: mood = "technical"
        }
        let ctx: String
        switch b.context {
        case .legible: ctx = "used by many ages, often outdoors"
        case .mixed: ctx = "used in normal conditions"
        case .night: ctx = "used mostly at night"
        }
        let eff = b.effort == .simple ? "quick to build" : "polished and rich"
        return "For a \(mood) \(b.category.rawValue) app \(ctx), where you want it \(eff)"
    }
}

enum CategoryGuesser {
    static func guess(_ text: String) -> AppCategory {
        let s = text.lowercased()
        let map: [(AppCategory, [String])] = [
            (.finance, ["money", "budget", "bank", "pay"]),
            (.social, ["friends", "chat", "share", "feed"]),
            (.wellness, ["sleep", "meditate", "health", "fitness"]),
            (.games, ["game", "play", "level", "draw", "create"]),
            (.shopping, ["shop", "store", "buy", "cart"]),
            (.education, ["learn", "course", "study", "kids"]),
            (.media, ["music", "video", "podcast", "read"]),
            (.travel, ["trip", "flight", "hotel", "map"]),
            (.productivity, ["task", "notes", "calendar", "team"]),
        ]
        for (cat, words) in map where words.contains(where: { s.contains($0) }) { return cat }
        return .utility
    }
}
