import SwiftUI

struct HandoffOptions: Equatable {
    var tokens = true, components = true, appearance = true, describeScreens = true
    var accessibility = true, imports = true, json = true
    var includeScreenshots = true
    var screens: [SampleScreen] = [.home, .settings]
}

extension Color {
    /// Hex description of a Color, with opacity when not fully opaque.
    var handoffText: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let hex = RGB(r: Double(r) * 255, g: Double(g) * 255, b: Double(b) * 255).hex
        return a < 0.995 ? "\(hex) at \(fmt(Double(a))) opacity" : hex
    }
}

struct ResolvedTokens: Codable, Equatable {
    var mode: String
    var accentRaw, accentAdjusted, onAccent, background, surface, text, secondaryText, separator, positive, toggleOn, toggleOff: String
    var cardRadius, tileRadius, buttonRadius, tabBarRadius, iconStrokeWidth, spacingScale, screenMargin, blockGap, rowPaddingVertical, rowPaddingHorizontal, tabBarHeight: Double
    var typeface: String
    var contrastBodyText, contrastSecondaryText, contrastRawAccentIcon, contrastButtonLabel: Double
}

struct HandoffJSON: Codable {
    var schemaVersion: Int
    var design: DesignSpec
    var resolved: Resolved
    struct Resolved: Codable { var chosen: ResolvedTokens; var opposite: ResolvedTokens }
}

enum HandoffWriter {
    static let schemaVersion = 1

    // MARK: text hygiene (no double hyphens, no tables, no HTML)
    static func clean(_ s: String) -> String {
        var r = s.replacingOccurrences(of: "<", with: "(").replacingOccurrences(of: ">", with: ")").replacingOccurrences(of: "|", with: "/")
        while r.contains("--") { r = r.replacingOccurrences(of: "--", with: "-") }
        return r.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    static func sanitized(_ spec: DesignSpec) -> DesignSpec {
        var s = spec
        if s.hideDetails {
            // Nothing about the sample content travels with a details-hidden export.
            s.imports = []; s.currentImport = nil; s.edits = [:]; s.screens = []; s.app = .wallet
        }
        s.name = clean(s.name); s.notes = clean(s.notes)
        s.brief.appName = clean(s.brief.appName); s.brief.oneLiner = clean(s.brief.oneLiner)
        for i in s.imports.indices {
            s.imports[i].name = clean(s.imports[i].name)
            for j in s.imports[i].elements.indices { s.imports[i].elements[j].text = clean(s.imports[i].elements[j].text) }
        }
        for (k, var e) in s.edits { e.name = clean(e.name); e.text = e.text.map(clean); s.edits[k] = e }
        return s
    }

    static func resolved(_ spec: DesignSpec) -> ResolvedTokens {
        let t = StyleTokens.make(spec)
        func r2(_ v: Double) -> Double { (v * 100).rounded() / 100 }
        let rows = t.contrastRows
        return ResolvedTokens(mode: spec.mode.rawValue, accentRaw: t.accent.hex, accentAdjusted: t.accentAdjusted.hex, onAccent: t.buttonLabel.hex,
            background: t.backgroundText, surface: t.surfaceText, text: t.text.hex, secondaryText: t.secondary.hex, separator: t.separatorText,
            positive: t.positive.hex, toggleOn: t.toggle.on.handoffText, toggleOff: t.toggle.off.handoffText,
            cardRadius: r2(t.cardRadius), tileRadius: r2(t.tileRadius), buttonRadius: r2(t.buttonRadius), tabBarRadius: r2(Double(StandardBar.height / 2)),
            iconStrokeWidth: t.strokeWidth, spacingScale: t.spacing, screenMargin: r2(t.margin), blockGap: r2(t.gap),
            rowPaddingVertical: r2(t.rowV), rowPaddingHorizontal: r2(t.rowH), tabBarHeight: Double(t.tabHeight),
            typeface: t.typefaceName,
            contrastBodyText: r2(rows[0].ratio), contrastSecondaryText: r2(rows[1].ratio), contrastRawAccentIcon: r2(rows[2].ratio), contrastButtonLabel: r2(rows[3].ratio))
    }

    static func jsonObject(spec: DesignSpec) -> HandoffJSON {
        let s = sanitized(spec)
        var opp = s; opp.mode = s.mode.opposite
        return HandoffJSON(schemaVersion: schemaVersion, design: s, resolved: .init(chosen: resolved(s), opposite: resolved(opp)))
    }

    static func json(spec: DesignSpec) -> Data {
        (try? DesignStore.encoder().encode(jsonObject(spec: spec))) ?? Data()
    }

    static func importLines(_ imp: ImportedScreen, _ spec: DesignSpec) -> [String] {
        var out: [String] = ["### \(imp.name), imported from a screenshot", "Canvas \(fmt(imp.canvasW)) by \(fmt(imp.canvasH)) pt. Background color \(imp.bgHex.uppercased()). The screen is made of the parts below; text sizes and colors were read from the screenshot, so they are close estimates."]
        let ordered = imp.elements.sorted { ($0.y, $0.x) < ($1.y, $1.x) }
        for el in ordered {
            let e = spec.edits[imp.editKey(el)] ?? ElementEdit()
            if e.hidden || (e.bgHidden && el.kind == .shape) { continue }
            let sc = e.scale
            let x = el.x + e.dx - el.w * (sc - 1) / 2, y = el.y + e.dy - el.h * (sc - 1) / 2
            let pos = "at x \(fmt(x)), y \(fmt(y))"
            switch el.kind {
            case .text:
                let w = (e.weight ?? el.weight).rawValue
                out.append("- Text \"\(clean(e.text ?? el.text))\" \(pos), font size \(fmt(el.fontSize * sc)) pt, weight \(w), color \((e.fgHex ?? el.colorHex).uppercased()).")
            case .shape:
                out.append("- Shape \(pos), size \(fmt(el.w * sc)) by \(fmt(el.h * sc)) pt, fill \((e.bgHex ?? el.colorHex).uppercased()), corner radius \(fmt((e.radius ?? el.radius) * sc)) pt.")
            case .image:
                out.append("- Icon or picture \(pos), size \(fmt(el.w * sc)) by \(fmt(el.h * sc)) pt\(e.fgHex.map { ", tinted " + $0.uppercased() } ?? "").")
            }
        }
        return out
    }

    static func slug(_ name: String) -> String {
        let allowed = name.lowercased().map { $0.isLetter || $0.isNumber ? String($0) : "-" }.joined()
        var s = allowed
        while s.contains("--") { s = s.replacingOccurrences(of: "--", with: "-") }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return s.isEmpty ? "design" : s
    }

    /// The bottom bar is the same in every design, so it is always described the same way.
    static func standardBarLines(_ spec: DesignSpec, _ t: StyleTokens) -> [String] {
        let dark = spec.mode == .dark
        let ink = dark ? "white" : "black"
        return [
            "- Bottom bar (identical in every design): a floating liquid glass tab bar, like the one in iOS 26 and later. It is a full capsule, \(Int(StandardBar.height)) pt tall, inset \(Int(StandardBar.sideInset)) pt from the left and right edges and \(Int(StandardBar.bottomInset)) pt above the bottom edge, with four evenly spaced items.",
            "- Bottom bar background: the system ultra thin material (the native liquid glass effect on iOS 26 and later), a 1 pt border in white at \(fmt(StandardBar.borderOpacity(dark: dark))) opacity and a soft shadow (black at \(fmt(StandardBar.shadowOpacity)) opacity, blur \(Int(StandardBar.shadowBlur)) pt, \(Int(StandardBar.shadowY)) pt down). With Reduce Transparency on, the fill is solid \(StandardBar.solidHex(dark: dark)).",
            "- Bottom bar items: each item stacks a \(Int(StandardBar.iconSize)) pt SF Symbol above a \(Int(StandardBar.labelSize)) pt medium label. The selected item sits on an inner rounded pill inset \(Int(StandardBar.pillInset)) pt from the bar (\(ink) at \(fmt(StandardBar.pillOpacity(dark: dark))) opacity) and is drawn in the accent color \(t.accentAdjusted.hex). Unselected items are \(ink) at \(fmt(StandardBar.idleOpacity(dark: dark))) opacity."
        ]
    }

    /// How the style behaves in light and dark mode, described without instructions.
    static func modeBehavior(_ s: StyleID) -> String {
        switch s {
        case .ios: "Backgrounds and text follow the iOS semantic colors: black and white surfaces in dark mode, light grey and white in light mode. The accent is the same in both modes."
        case .liquid: "Dark mode is a deep navy gradient with brighter glass fills. Light mode is a pale tinted gradient with more opaque white glass."
        case .glass: "The frosted panels are white in both modes and only the gradient changes. Text is white in both modes."
        case .neu: "Dark mode has a dark base with darker and lighter shadows. Light mode has a light base with grey and white shadows."
        case .clay: "Dark mode tints the background and surface with the accent. Light mode has white cards. The pastel icon tiles and accent colored shadows are the same in both modes."
        case .brutal: "Outlines and hard shadows are white in dark mode and black in light mode. The background goes from near black to cream. The fills are the same."
        case .skeu: "The metal gradients are dark steel in dark mode and light aluminium in light mode. The light direction is the same."
        case .aurora: "Dark mode is near black with glowing blobs. Light mode is a pale lavender with softer glows. Gradient text is darker in light mode."
        case .oled: "Dark mode is true black with a faint accent glow. Light mode is white with hairline borders and no glow."
        case .bento: "Tile fills are near black and accent tints in dark mode, and white and pale tints in light mode. The amber tile is amber in both modes."
        case .mono: "Dark and light are near mirror images: text and background swap and hairlines keep the same weight. The primary button inverts."
        case .neon: "Dark mode is the native look. Light mode reduces the glow and darkens the glow color."
        }
    }

    private static func pct(_ v: Double) -> String { "\(Int((v * 100).rounded())) percent" }

    // MARK: markdown

    /// A description of the design only: exact values and what every screen looks like. It contains no instructions.
    @MainActor
    static func markdown(spec rawSpec: DesignSpec, options: HandoffOptions = HandoffOptions()) -> String {
        let spec = sanitized(rawSpec)
        let t = StyleTokens.make(spec)
        let info = StyleCatalog.info(spec.style)
        var L: [String] = []
        func add(_ s: String = "") { L.append(s) }
        func rad(_ r: CGFloat) -> String { r >= 99 ? "fully round" : "\(fmt(r)) pt" }
        func wname(_ w: Font.Weight) -> String { ScreenDescriber.weightName(w) }

        add("# Design: \(spec.name)")
        add()
        add("This file describes the exact look of the design as shown in the Style Lab preview. It contains design values only.")
        add()

        // 1
        add("## 1. Overview")
        add("- Style: \(info.name). \(info.tagline)")
        add("- Appearance shown: \(spec.mode.title) mode.")
        let described = spec.app.screens + (spec.imports.isEmpty ? [] : [SampleScreen.imported])
        if spec.hideDetails {
            add("- Content: the design is shown as empty tiles with no names, numbers, text or icons, so this file describes colors and styling only.")
        } else {
            add("- Sample app: \(spec.app.title) (\(spec.app.tagline)).")
            add("- Screens described: all \(described.count) screens of the \(spec.app.title) sample\(spec.imports.isEmpty ? "" : " and the imported screens"): \(Sentences.list(described.map(\.title))).")
        }
        add("- Accent color: \(t.accent.hex).")
        add("- Settings: corner roundness \(String(format: "%.2f", spec.radiusScale))x, depth \(pct(spec.depth)), density \(spec.density.title) (scale \(fmt(t.spacing))), icon weight \(spec.iconWeight.title), boost contrast \(spec.boostContrast ? "on" : "off").")
        add("- Canvas: every screen is 390 by 844 pt with no status bar, notch or device frame. The bottom bar is the standard liquid glass bar in every design.")
        add()

        if options.tokens {
            add("## 2. Colors")
            add("- Accent (raw): \(t.accent.hex)")
            add("- Accent used for icons and active states (adjusted for contrast): \(t.accentAdjusted.hex)")
            add("- Text on accent (buttons): \(t.buttonLabel.hex)")
            add("- Background: \(t.backgroundText)")
            add("- Surface (cards): \(t.surfaceText)")
            add("- Primary text: \(t.text.hex)")
            add("- Secondary text: \(t.secondary.hex)")
            add("- Separator: \(t.separatorText)")
            add("- Positive amount color: \(t.positive.hex)")
            add("- Toggle on and off: \(t.toggle.on.handoffText), \(t.toggle.off.handoffText)")
            add("- Selected item in the bottom bar: \(t.accentAdjusted.hex)")
            add()

            add("## 3. Shape and effects")
            add("- Corner radii: card \(rad(t.cardRadius)), icon tile \(rad(t.tileRadius)), button \(rad(t.buttonRadius)). The bottom bar is a full capsule.")
            t.depthLines.forEach { add("- \($0)") }
            add()

            add("## 4. Typography")
            add("- Typeface: \(t.typefaceName)")
            add("- Large title 34 pt \(wname(t.headingWeight)). Title 22 pt \(wname(t.headingWeight)). Section title 20 pt \(wname(t.headingWeight)). Body 16 pt regular. Caption 12.5 pt medium. Tab label 10 pt medium. Large amount 40 pt \(wname(t.amountWeight)).")
            add("- \(t.typeRules)")
            add()

            add("## 5. Icons and spacing")
            add("- Icon stroke weight \(fmt(t.strokeWidth)) pt (\(spec.iconWeight.title)). Icon sizes: 22 pt in the bottom bar, 28 pt in quick action tiles, 21 pt in list rows.")
            add("- Icon container: 62 pt in quick actions and 42 pt in rows, \(rad(t.tileRadius)) radius. \(t.tileDesc.prefix(1).uppercased() + t.tileDesc.dropFirst()).")
            add("- Icon color: \(t.iconRule)")
            add("- Density \(spec.density.title), scale \(fmt(t.spacing)). Screen side margin \(fmt(t.margin)) pt. Gap between blocks \(fmt(t.gap)) pt. List row padding \(fmt(t.rowV)) pt vertical and \(fmt(t.rowH)) pt horizontal.")
            add()
        }

        if options.components {
            var wording = info.handoffWording
            for (k, v) in t.wording { wording = wording.replacingOccurrences(of: "{\(k)}", with: v) }
            add("## 6. Components")
            add("- Card: \(wording)")
            add("- List row: icon tile at the left (42 pt), title and subtitle in the middle, value at the right, separated by \(t.separatorText).")
            add("- Quick action: \(t.tileDesc).")
            let fill = t.buttonGradient != nil ? "gradient fill based on \(t.accent.hex)" : "fill \(t.buttonFill.hex)"
            add("- Primary button: \(fill), \(t.buttonLabel.hex) label, \(rad(t.buttonRadius)) corners, 52 pt tall\(t.buttonExtra.isEmpty ? "" : ", " + t.buttonExtra).")
            let c = t.chip
            add("- Chip: fully rounded, \(c.fill.handoffText == "#000000 at 0 opacity" ? "no fill" : "fill " + c.fill.handoffText), text \(c.text.handoffText)\(c.border.map { ", " + fmt(c.borderWidth) + " pt outline " + $0.handoffText } ?? "").")
            let tg = t.toggle
            add("- Toggle: 51 by 31 pt, on is \(tg.on.handoffText), off is \(tg.off.handoffText)\(tg.square ? ", square knob and corners" : ", round knob")\(tg.recessed ? ", recessed track" : "")\(tg.metal ? ", metallic knob" : "").")
            for l in standardBarLines(spec, t) { add(l) }
            add("- Layout: \(t.layout == .bento && spec.app == .wallet ? "the wallet home screen is a bento grid: a wide hero tile with the balance, then a 2 by 2 grid of action tiles 96 pt tall, then the Recent list in one tile, with 12 pt between tiles. Other screens are stacked blocks." : "screens are stacked blocks from top to bottom.")")
            add()
        } else {
            add("## 6. Components")
            for l in standardBarLines(spec, t) { add(l) }
            add()
        }

        if options.appearance {
            func modeValues(_ m: AppearanceMode, shown: Bool) {
                var s2 = spec; s2.mode = m
                let o = StyleTokens.make(s2)
                add("\(m.title) mode\(shown ? " (shown in the preview)" : ""):")
                add("- Background: \(o.backgroundText)")
                add("- Surface (cards): \(o.surfaceText)")
                add("- Primary text: \(o.text.hex). Secondary text: \(o.secondary.hex)")
                add("- Separator: \(o.separatorText). Positive amount color: \(o.positive.hex)")
                add("- Accent for icons and active states: \(o.accentAdjusted.hex). Text on accent: \(o.buttonLabel.hex)")
                add("- Toggle on and off: \(o.toggle.on.handoffText), \(o.toggle.off.handoffText)")
                o.depthLines.forEach { add("- \($0)") }
                add("- Bottom bar: pill behind the selected item is \(m == .dark ? "white" : "black") at \(fmt(StandardBar.pillOpacity(dark: m == .dark))) opacity, border white at \(fmt(StandardBar.borderOpacity(dark: m == .dark))) opacity, unselected items \(m == .dark ? "white" : "black") at \(fmt(StandardBar.idleOpacity(dark: m == .dark))) opacity.")
                add()
            }
            add("## 7. Light and dark mode")
            add("The same design in both appearances. The shape, spacing, typography and icon weight are identical in both.")
            add("- \(modeBehavior(spec.style))")
            add()
            modeValues(spec.mode, shown: true)
            modeValues(spec.mode.opposite, shown: false)
        }

        if options.describeScreens && !spec.hideDetails {
            add("## 8. Screens")
            add("All \(described.count) screens of the \(spec.app.title) sample, each with every part as it appears in the preview, in reading order from top to bottom. Positions are in points from the top left of the 390 by 844 canvas. Text content is placeholder text for the \(spec.app.title) sample.")
            add()
            for screen in described {
                if screen == .imported {
                    if options.imports {
                        for imp in spec.imports { importLines(imp, spec).forEach { add($0) } ; add() }
                    }
                } else {
                    ScreenDescriber.lines(spec: spec, screen: screen).forEach { add($0) }
                    add()
                }
            }
        }

        if options.accessibility {
            add("## 9. Contrast measurements")
            let rows = t.contrastRows
            func badge(_ row: StyleTokens.ContrastRow) -> String { row.passes ? "Pass" : "Low" }
            func f(_ v: Double) -> String { String(format: "%.1f", v) }
            add("- Body text on surface: \(f(rows[0].ratio)):1 (\(badge(rows[0])), target 4.5).")
            add("- Secondary text on surface: \(f(rows[1].ratio)):1 (\(badge(rows[1])), target 4.5).")
            add("- Raw accent as an icon: \(f(rows[2].ratio)):1 (\(badge(rows[2])), target 3).\(rows[2].passes ? "" : " The adjusted icon color above is shown instead.")")
            add("- Button label on accent: \(f(rows[3].ratio)):1 (\(badge(rows[3])), target 4.5).")
            if t.estimated { add("- These values are estimates because the surface is translucent or a gradient.") }
            add()
        }

        if options.json {
            add("## 10. Machine readable design")
            add("```json")
            add(String(data: json(spec: spec), encoding: .utf8) ?? "{}")
            add("```")
        }
        return L.joined(separator: "\n") + "\n"
    }
}
