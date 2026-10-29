import SwiftUI

/// Describes every part of a sample screen as it looks in the preview: its content, font, color, size and exact position.
@MainActor
enum ScreenDescriber {
    static func frames(spec: DesignSpec, screen: SampleScreen) -> [String: ElementFrame] {
        let sink = FrameSink()
        let r = ImageRenderer(content: SampleScreenView(spec: spec, screen: screen).environment(\.frameSink, sink))
        r.scale = 1
        _ = r.uiImage
        return sink.frames
    }

    static func weightName(_ w: Font.Weight) -> String {
        if w == .ultraLight { return "ultra light" }; if w == .thin { return "thin" }; if w == .light { return "light" }
        if w == .regular { return "regular" }; if w == .medium { return "medium" }; if w == .semibold { return "semibold" }
        if w == .bold { return "bold" }; if w == .heavy { return "heavy" }; if w == .black { return "black" }
        return "regular"
    }

    /// Text that was drawn into the sample screen, in reading order, followed by the bottom bar.
    static func lines(spec: DesignSpec, screen: SampleScreen) -> [String] {
        let t = StyleTokens.make(spec)
        let def = AppContent.def(screen, spec.app)
        let prefix = screen.editKey(spec.app)
        let fr = frames(spec: spec, screen: screen)
        let c = Ctx(t: t, spec: spec, prefix: prefix)

        if screen == .home && t.layout == .bento && spec.app == .wallet { c.bento(def) }
        else { for (i, b) in def.blocks.enumerated() { c.block(b, "b\(i)") } }
        c.tabBar(def)

        var out: [String] = ["### \(screen.title) screen"]
        let bgEdit = spec.edits[prefix + "/background"]?.bgHex
        out.append("Canvas 390 by 844 pt. Background: \(bgEdit?.uppercased() ?? t.backgroundText).")
        let keys = fr.keys.sorted { a, b in
            let ra = fr[a]!.rect, rb = fr[b]!.rect
            if abs(ra.minY - rb.minY) > 0.5 { return ra.minY < rb.minY }
            if abs(ra.minX - rb.minX) > 0.5 { return ra.minX < rb.minX }
            return a < b
        }
        for k in keys {
            guard let f = fr[k] else { continue }
            let desc = c.out[k] ?? "\(f.kind.rawValue.capitalized) element"
            let r = f.rect
            out.append("- \(HandoffWriter.clean(f.name)): \(desc). Position x \(fmt(r.minX)), y \(fmt(r.minY)), size \(fmt(r.width)) by \(fmt(r.height)) pt.")
        }
        return out
    }

    // MARK: per element descriptions

    @MainActor private final class Ctx {
        let t: StyleTokens
        let spec: DesignSpec
        let prefix: String
        var out: [String: String] = [:]
        init(t: StyleTokens, spec: DesignSpec, prefix: String) { self.t = t; self.spec = spec; self.prefix = prefix }

        func e(_ id: String, shared: Bool = false) -> ElementEdit { spec.edits[(shared ? "all" : prefix) + "/" + id] ?? ElementEdit() }
        func add(_ id: String, shared: Bool = false, _ text: String) { out[(shared ? "all" : prefix) + "/" + id] = text }

        func size(_ r: FontRole) -> Double {
            switch r { case .largeTitle: 34; case .title: 22; case .section: 20; case .body: 16; case .caption: 12.5; case .tabLabel: 10; case .amount: 40 }
        }
        func weight(_ r: FontRole) -> Font.Weight {
            switch r { case .largeTitle, .title, .section: t.headingWeight; case .amount: t.amountWeight; case .body: .regular; case .caption, .tabLabel: .medium }
        }
        var tileRadiusText: String { t.tileRadius >= 99 ? "fully round" : "\(fmt(t.tileRadius)) pt" }

        func text(_ id: String, _ role: FontRole, _ base: String, color: RGB, weight w: Font.Weight? = nil, label: Bool = false, shared: Bool = false) {
            let ed = e(id, shared: shared)
            let ww = ed.weight?.font ?? w ?? weight(role)
            let col = ed.fgHex.map { RGB(hex: $0) } ?? color
            var s = "Text \"\(HandoffWriter.clean(ed.text ?? base))\", \(fmt(size(role))) pt \(weightName(ww)), color \(col.hex)"
            if label && t.upperLabels { s += ", shown in capitals with \(fmt(t.labelTracking)) pt letter spacing" }
            if role == .amount, let g = t.amountGradient, ed.fgHex == nil, g.count == 2 { s += ", filled with a horizontal gradient from \(g[0].handoffText) to \(g[1].handoffText)" }
            add(id, shared: shared, s)
        }

        func tile(_ id: String, symbol: String, size: Int, iconSize: Int, index: Int, initials: String = "") {
            let ed = e(id)
            let sym = ed.icon ?? symbol
            let iconColor = ed.fgHex.map { RGB(hex: $0).hex } ?? t.tileIconColor(index).handoffText
            var s = "Icon tile \(size) by \(size) pt"
            if ed.bgHidden { s += " with no background" }
            else if let b = ed.bgHex { s += " with background \(b.uppercased()), corner radius \(tileRadiusText)" }
            else { s += " in the standard tile style (Quick action in section 6), corner radius \(tileRadiusText)" }
            if sym.isEmpty { s += ", initial \"\(initials)\" at \(fmt(Double(iconSize) * 0.8)) pt, color \(iconColor)" }
            else { s += ", symbol \(sym) at \(iconSize) pt \(weightName(ed.weight?.font ?? t.iconWeight)), color \(iconColor)" }
            if let b = ed.badge { s += ", red number badge \(b)" }
            add(id, s)
        }

        func card(_ id: String, _ what: String) {
            let ed = e(id)
            var s = what
            if ed.bgHidden { s += ", no background" }
            else if let b = ed.bgHex { s += ", fill \(b.uppercased())" }
            else { s += ", standard card style (section 6), corner radius \(fmt(t.cardRadius)) pt" }
            add(id, s)
        }

        func chip(_ id: String, _ base: String, selected: Bool?) {
            let ed = e(id)
            var s = "Chip \"\(HandoffWriter.clean(ed.text ?? base))\", \(fmt(12.5)) pt \(weightName(ed.weight?.font ?? .semibold)), capsule"
            if let sel = selected {
                let fill = ed.bgHex.map { $0.uppercased() } ?? (sel ? t.buttonFill.hex : t.separatorText)
                let txt = ed.fgHex.map { $0.uppercased() } ?? (sel ? t.buttonLabel.hex : t.secondary.hex)
                s += ", \(sel ? "selected" : "not selected"), fill \(ed.bgHidden ? "none" : fill), text \(txt), padding 12 by 8 pt"
            } else {
                s += ", fill \(ed.bgHidden ? "none" : (ed.bgHex?.uppercased() ?? t.chip.fill.handoffText)), text \(ed.fgHex?.uppercased() ?? t.chip.text.handoffText)"
                if let b = t.chip.border, !ed.bgHidden { s += ", \(fmt(t.chip.borderWidth)) pt outline \(b.handoffText)" }
                s += ", padding 10 by 5 pt"
            }
            add(id, s)
        }

        func sectionTitle(_ p: String, _ title: String) { text("\(p).title", .section, title, color: t.text) }

        func block(_ b: Block, _ p: String) {
            switch b {
            case .header(let sub, let title, let icon):
                if !sub.isEmpty { text("\(p).sub", .caption, sub, color: t.secondary) }
                text("\(p).title", .largeTitle, title, color: t.text)
                if !icon.isEmpty { tile("\(p).icon", symbol: icon, size: 42, iconSize: 20, index: 0) }
            case .hero(let label, let value, let chipText):
                card(p, "Hero card with 18 pt padding")
                text("\(p).label", .caption, label, color: t.secondary, label: true)
                text("\(p).value", .amount, value, color: t.text)
                chip("\(p).chip", chipText, selected: nil)
            case .search(let ph):
                card(p, "Search field, 48 pt tall with 14 pt side padding")
                let ie = e("\(p).icon")
                add("\(p).icon", "Symbol \(ie.icon ?? "magnifyingglass") at 17 pt \(weightName(ie.weight?.font ?? t.iconWeight)), color \(ie.fgHex?.uppercased() ?? t.accentAdjusted.hex)")
                text("\(p).text", .body, ph, color: t.secondary)
            case .chips(let items):
                for (i, s) in items.enumerated() { chip("\(p).c\(i)", s, selected: i == 0) }
            case .actions(let items):
                for (i, a) in items.enumerated() {
                    tile("\(p).a\(i)", symbol: a.icon, size: 62, iconSize: 28, index: i)
                    text("\(p).a\(i).label", .caption, a.label, color: t.text, weight: .semibold, label: true)
                }
            case .stats(let items):
                for (i, s) in items.enumerated() {
                    card("\(p).s\(i)", "Stat tile with 12 pt padding")
                    tile("\(p).s\(i).icon", symbol: s.icon, size: 38, iconSize: 18, index: i)
                    text("\(p).s\(i).value", .title, s.value, color: t.text)
                    text("\(p).s\(i).label", .caption, s.label, color: t.secondary)
                }
            case .list(let title, let rows):
                if !title.isEmpty { sectionTitle(p, title) }
                card("\(p).card", "List card, rows separated by hairlines (\(t.separatorText))")
                for (i, r) in rows.enumerated() {
                    add("\(p).r\(i)", "List row with \(fmt(t.rowV)) pt vertical and \(fmt(t.rowH)) pt horizontal padding")
                    tile("\(p).r\(i).icon", symbol: r.icon, size: 42, iconSize: 21, index: i)
                    text("\(p).r\(i).title", .body, r.title, color: t.text, weight: .semibold)
                    text("\(p).r\(i).sub", .caption, r.subtitle, color: t.secondary)
                    if !r.value.isEmpty { text("\(p).r\(i).value", .body, r.value, color: r.positive ? t.positive : t.text, weight: .semibold) }
                }
            case .people(let title, let names):
                sectionTitle(p, title)
                for (i, n) in names.enumerated() {
                    tile("\(p).p\(i)", symbol: "", size: 52, iconSize: 24, index: i, initials: String(n.prefix(1)))
                    text("\(p).p\(i).name", .caption, n, color: t.secondary)
                }
            case .bars(let title, let items):
                sectionTitle(p, title)
                for (i, b) in items.enumerated() {
                    card("\(p).g\(i)", "Progress card with 14 pt side padding")
                    text("\(p).g\(i).name", .body, b.name, color: t.text, weight: .semibold)
                    text("\(p).g\(i).value", .caption, b.value, color: t.secondary)
                    let be = e("\(p).g\(i).bar")
                    add("\(p).g\(i).bar", "Progress bar, 8 pt tall capsule, track \(t.separatorText), fill \(be.fgHex?.uppercased() ?? t.accentAdjusted.hex), \(Int(b.pct * 100)) percent filled")
                }
            case .chat(let msgs):
                for (i, m) in msgs.enumerated() {
                    let ed = e("\(p).m\(i)")
                    let who = m.1 ? "Sent message bubble, filled like the primary button, text \(ed.fgHex?.uppercased() ?? t.buttonLabel.hex)" : "Received message bubble, standard card style, text \(ed.fgHex?.uppercased() ?? t.text.hex)"
                    add("\(p).m\(i)", "\(who), \"\(HandoffWriter.clean(ed.text ?? m.0))\" at 16 pt \(weightName(ed.weight?.font ?? .regular)), padding 14 by 10 pt")
                }
            case .grid(let title, let items):
                sectionTitle(p, title)
                for (i, it) in items.enumerated() {
                    card("\(p).t\(i)", "Product tile with 12 pt padding")
                    tile("\(p).t\(i).icon", symbol: it.icon, size: 56, iconSize: 26, index: i)
                    text("\(p).t\(i).name", .body, it.name, color: t.text, weight: .semibold)
                    text("\(p).t\(i).price", .caption, it.price, color: t.secondary)
                }
            case .toggles(let rows):
                card(p, "Grouped settings card, rows separated by hairlines (\(t.separatorText))")
                for (i, r) in rows.enumerated() {
                    add("\(p).r\(i)", "Settings row with \(fmt(t.rowV)) pt vertical and \(fmt(t.rowH)) pt horizontal padding")
                    tile("\(p).r\(i).icon", symbol: r.1, size: 42, iconSize: 21, index: i)
                    text("\(p).r\(i).title", .body, r.0, color: t.text)
                    if let on = r.2 {
                        add("\(p).r\(i).switch", "Switch 51 by 31 pt, \(on ? "on" : "off"), on color \(t.toggle.on.handoffText), off color \(t.toggle.off.handoffText)")
                    } else {
                        let ce = e("\(p).r\(i).chevron")
                        add("\(p).r\(i).chevron", "Symbol \(ce.icon ?? "chevron.right") at 14 pt \(weightName(ce.weight?.font ?? .semibold)), color \(ce.fgHex?.uppercased() ?? t.secondary.hex)")
                    }
                }
            case .profile(let name, let email):
                card(p, "Profile card with \(fmt(t.rowH)) pt padding")
                tile("\(p).avatar", symbol: "person", size: 54, iconSize: 26, index: 1)
                text("\(p).name", .section, name, color: t.text)
                text("\(p).email", .caption, email, color: t.secondary)
            case .button(let title):
                let ed = e("\(p).button")
                let fill = ed.bgHidden ? "no fill" : (ed.bgHex.map { "fill \($0.uppercased())" } ?? (t.buttonGradient != nil ? "gradient fill based on \(t.accent.hex)" : "fill \(t.buttonFill.hex)"))
                add("\(p).button", "Primary button \"\(HandoffWriter.clean(ed.text ?? title))\", \(fill), label 16 pt \(weightName(ed.weight?.font ?? .semibold)) in \(ed.fgHex?.uppercased() ?? t.buttonLabel.hex), 52 pt tall, full width, corner radius \(fmt(t.buttonRadius)) pt")
            }
        }

        func bento(_ def: ScreenDef) {
            text("bento.title", .largeTitle, "Wallet", color: t.text)
            tile("bento.icon", symbol: "bell", size: 42, iconSize: 20, index: 0)
            card("bento.hero", "Hero tile filled with the accent \(t.accent.hex), 20 pt padding")
            text("bento.label", .caption, "Total balance", color: t.onAccent)
            text("bento.value", .amount, "$12,480.50", color: t.onAccent)
            text("bento.chip", .caption, "+2.4% this week", color: t.onAccent, weight: .semibold)
            for (i, a) in ScreenDefs.standardActions.enumerated() {
                let fills = t.bentoTiles.isEmpty ? (Color.clear, Color.clear) : t.bentoTiles[i % 4]
                card("bento.a\(i)", "Action tile 96 pt tall with 14 pt padding, fill \(fills.0.handoffText)")
                let ie = e("bento.a\(i).icon")
                add("bento.a\(i).icon", "Symbol \(ie.icon ?? a.icon) at 24 pt, color \(ie.fgHex?.uppercased() ?? fills.1.handoffText)")
                text("bento.a\(i).label", .body, a.label, color: t.text, weight: .bold)
            }
            card("bento.recent", "Recent tile, standard card style")
            text("bento.recent.title", .section, "Recent", color: t.text)
            var rows: [RowDef] = []
            for b in def.blocks { if case .list(_, let r) = b { rows = r; break } }
            for (i, r) in rows.enumerated() {
                tile("bento.r\(i).icon", symbol: r.icon, size: 42, iconSize: 21, index: i)
                text("bento.r\(i).title", .body, r.title, color: t.text, weight: .semibold)
                text("bento.r\(i).sub", .caption, r.subtitle, color: t.secondary)
                text("bento.r\(i).value", .body, r.value, color: r.positive ? t.positive : t.text, weight: .semibold)
            }
        }

        func tabBar(_ def: ScreenDef) {
            let be = e("tabbar", shared: true)
            add("tabbar", shared: true, "Standard liquid glass bottom bar (section 6)\(be.bgHidden ? ", background hidden" : "")")
            for (i, tab) in def.tabs.enumerated() {
                let ed = e("tab.\(tab.label)", shared: true)
                let selected = i == def.active
                let dark = spec.mode == .dark
                let idle = (dark ? "#FFFFFF" : "#000000") + " at \(fmt(StandardBar.idleOpacity(dark: dark))) opacity"
                let color = ed.fgHex?.uppercased() ?? (selected ? t.accentAdjusted.hex : idle)
                add("tab.\(tab.label)", shared: true, "Tab \"\(HandoffWriter.clean(ed.text ?? tab.label))\", \(selected ? "selected" : "not selected"), symbol \(ed.icon ?? tab.icon) at 22 pt, label 10 pt medium, color \(color)\(selected ? ", on the inner pill" : "")")
            }
        }
    }
}
