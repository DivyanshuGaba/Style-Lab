import SwiftUI

/// Renders any ScreenDef from style tokens. Every visible part is an Editable so it can be restyled in the layout editor.
struct BlockScreen: View {
    @Environment(\.hideDetails) private var hideDetails
    let t: StyleTokens
    let def: ScreenDef
    let screen: SampleScreen

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: t.gap) {
                ForEach(Array(def.blocks.enumerated()), id: \.offset) { i, b in
                    block(b, "b\(i)")
                }
            }
            .padding(.horizontal, t.margin).padding(.top, 20)
            Spacer(minLength: 0)
            TabBarView(t: t, tabs: def.tabs, active: def.active)
        }
    }

    @ViewBuilder private func block(_ b: Block, _ p: String) -> some View {
        switch b {
        case .header(let sub, let title, let icon): header(sub, title, icon, p)
        case .hero(let label, let value, let chip): hero(label, value, chip, p)
        case .search(let ph): search(ph, p)
        case .chips(let items): chips(items, p)
        case .actions(let items): actions(items, p)
        case .stats(let items): stats(items, p)
        case .list(let title, let rows): list(title, rows, p)
        case .people(let title, let names): people(title, names, p)
        case .bars(let title, let items): bars(title, items, p)
        case .chat(let msgs): chat(msgs, p)
        case .grid(let title, let items): grid(title, items, p)
        case .toggles(let rows): toggles(rows, p)
        case .profile(let name, let email): profile(name, email, p)
        case .button(let title):
            Editable(id: "\(p).button", name: "Button: \(title)", kind: .button) { e in PrimaryButton(t: t, title: title, edit: e) }
        }
    }

    private func sectionTitle(_ s: String, _ p: String) -> some View {
        HStack {
            Editable(id: "\(p).title", name: "Section title: \(s)", kind: .text) { e in t.text(.section, s, e) }
            Spacer()
        }
    }

    private func header(_ sub: String, _ title: String, _ icon: String, _ p: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if !sub.isEmpty { Editable(id: "\(p).sub", name: "Small heading", kind: .text) { e in t.text(.caption, sub, e, color: t.secondary.color) } }
                Editable(id: "\(p).title", name: "Screen title", kind: .text) { e in t.text(.largeTitle, title, e) }
            }
            Spacer()
            if !icon.isEmpty {
                Editable(id: "\(p).icon", name: "Header icon", kind: .icon) { e in IconTile(t: t, icon: icon, size: 42, iconSize: 20, edit: e) }
            }
        }
    }

    private func hero(_ label: String, _ value: String, _ chip: String, _ p: String) -> some View {
        Editable(id: p, name: "Hero card", kind: .card) { e in
            VStack(alignment: .leading, spacing: 6) {
                Editable(id: "\(p).label", name: "Hero label", kind: .text) { e2 in
                    t.label(e2.text ?? label, weight: e2.weight?.font).foregroundStyle(e2.fg(t.secondary.color))
                }
                Editable(id: "\(p).value", name: "Hero value", kind: .text) { e2 in AmountText(t: t, s: value, edit: e2) }
                Editable(id: "\(p).chip", name: "Hero chip", kind: .chip) { e2 in ChipView(t: t, s: chip, edit: e2) }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(18).optSurface(e.surface(t.card))
        }
    }

    private func search(_ ph: String, _ p: String) -> some View {
        Editable(id: p, name: "Search field", kind: .card) { e in
            HStack(spacing: 10) {
                Editable(id: "\(p).icon", name: "Search icon", kind: .glyph) { e2 in
                    Image(systemName: e2.icon ?? "magnifyingglass").font(.system(size: 17, weight: e2.weight?.font ?? t.iconWeight)).foregroundStyle(e2.fg(t.accentAdjusted.color))
                }
                Editable(id: "\(p).text", name: "Search text", kind: .text) { e3 in
                    Text(e3.text ?? e.text ?? ph).font(t.font(.body, weight: e3.weight?.font ?? e.weight?.font)).foregroundStyle(e3.fg(t.secondary.color))
                }
                Spacer()
            }
            .padding(.horizontal, 14).frame(height: 48).optSurface(e.surface(t.card))
        }
    }

    private func chips(_ items: [String], _ p: String) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, s in
                Editable(id: "\(p).c\(i)", name: "Filter: \(s)", kind: .chip) { e in
                    let on = i == 0
                    Text(e.text ?? s).font(t.font(.caption, weight: e.weight?.font ?? .semibold))
                        .foregroundStyle(e.fg(on ? t.buttonLabel.color : t.secondary.color))
                        .opacity(hideDetails ? 0 : 1)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Capsule().fill(e.bgHidden ? Color.clear : (e.bgHex.map { RGB(hex: $0).color } ?? (on ? t.buttonFill.color : t.separator))))
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func actions(_ items: [ActDef], _ p: String) -> some View {
        HStack {
            ForEach(Array(items.enumerated()), id: \.offset) { i, a in
                VStack(spacing: 6) {
                    Editable(id: "\(p).a\(i)", name: "Action: \(a.label)", kind: .icon) { e in
                        IconTile(t: t, icon: a.icon, index: i, size: 62, iconSize: 28, edit: e)
                    }
                    Editable(id: "\(p).a\(i).label", name: "Action label: \(a.label)", kind: .text) { e in
                        t.label(e.text ?? a.label, weight: e.weight?.font ?? .semibold).foregroundStyle(e.fg(t.text.color))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func stats(_ items: [StatDef], _ p: String) -> some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, s in
                Editable(id: "\(p).s\(i)", name: "Stat tile: \(s.label)", kind: .card) { e in
                    HStack(spacing: 10) {
                        Editable(id: "\(p).s\(i).icon", name: "Stat icon: \(s.label)", kind: .icon) { e2 in
                            IconTile(t: t, icon: s.icon, index: i, size: 38, iconSize: 18, edit: e2)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Editable(id: "\(p).s\(i).value", name: "Stat number: \(s.label)", kind: .text) { e2 in
                                Text(e2.text ?? s.value).font(t.font(.title, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.text.color)).minimumScaleFactor(0.7).lineLimit(1)
                            }
                            Editable(id: "\(p).s\(i).label", name: "Stat label: \(s.label)", kind: .text) { e2 in
                                Text(e2.text ?? s.label).font(t.font(.caption, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.secondary.color)).lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading).optSurface(e.surface(t.card))
                }
            }
        }
    }

    private func list(_ title: String, _ rows: [RowDef], _ p: String) -> some View {
        VStack(spacing: 10) {
            if !title.isEmpty { sectionTitle(title, p) }
            Editable(id: "\(p).card", name: "List card: \(title)", kind: .card) { e in
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                        Editable(id: "\(p).r\(i)", name: "Row: \(r.title)", kind: .row) { _ in
                            HStack(spacing: 12) {
                                Editable(id: "\(p).r\(i).icon", name: "Row icon: \(r.title)", kind: .icon) { e3 in IconTile(t: t, icon: r.icon, index: i, edit: e3) }
                                VStack(alignment: .leading, spacing: 2) {
                                    Editable(id: "\(p).r\(i).title", name: "Row title: \(r.title)", kind: .text) { e3 in
                                        Text(e3.text ?? r.title).font(t.font(.body, weight: e3.weight?.font ?? .semibold)).foregroundStyle(e3.fg(t.text.color))
                                    }
                                    Editable(id: "\(p).r\(i).sub", name: "Row subtitle: \(r.title)", kind: .text) { e3 in
                                        Text(e3.text ?? r.subtitle).font(t.font(.caption, weight: e3.weight?.font)).foregroundStyle(e3.fg(t.secondary.color))
                                    }
                                }
                                Spacer()
                                if !r.value.isEmpty {
                                    Editable(id: "\(p).r\(i).value", name: "Row value: \(r.title)", kind: .text) { e3 in
                                        Text(e3.text ?? r.value).font(t.font(.body, weight: e3.weight?.font ?? .semibold)).foregroundStyle(e3.fg(r.positive ? t.positive.color : t.text.color))
                                    }
                                }
                            }
                            .padding(.vertical, t.rowV).padding(.horizontal, t.rowH)
                        }
                        if i < rows.count - 1 { Rectangle().fill(t.separator).frame(height: 0.5).padding(.leading, t.rowH + 54) }
                    }
                }
                .optSurface(e.surface(t.card))
            }
        }
    }

    private func people(_ title: String, _ names: [String], _ p: String) -> some View {
        VStack(spacing: 10) {
            sectionTitle(title, p)
            HStack {
                ForEach(Array(names.enumerated()), id: \.offset) { i, n in
                    VStack(spacing: 5) {
                        Editable(id: "\(p).p\(i)", name: "Avatar: \(n)", kind: .icon) { e in
                            IconTile(t: t, initials: String(n.prefix(1)), index: i, size: 52, iconSize: 24, edit: e)
                        }
                        Editable(id: "\(p).p\(i).name", name: "Avatar name: \(n)", kind: .text) { e in
                            Text(e.text ?? n).font(t.font(.caption, weight: e.weight?.font)).foregroundStyle(e.fg(t.secondary.color)).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func bars(_ title: String, _ items: [BarDef], _ p: String) -> some View {
        VStack(spacing: 10) {
            sectionTitle(title, p)
            ForEach(Array(items.enumerated()), id: \.offset) { i, b in
                Editable(id: "\(p).g\(i)", name: "Progress: \(b.name)", kind: .card) { e in
                    VStack(spacing: 6) {
                        HStack {
                            Editable(id: "\(p).g\(i).name", name: "Progress name: \(b.name)", kind: .text) { e3 in
                                Text(e3.text ?? b.name).font(t.font(.body, weight: e3.weight?.font ?? .semibold)).foregroundStyle(e3.fg(t.text.color))
                            }
                            Spacer()
                            Editable(id: "\(p).g\(i).value", name: "Progress value: \(b.name)", kind: .text) { e3 in
                                Text(e3.text ?? b.value).font(t.font(.caption, weight: e3.weight?.font)).foregroundStyle(e3.fg(t.secondary.color))
                            }
                        }
                        Editable(id: "\(p).g\(i).bar", name: "Progress bar: \(b.name)", kind: .control) { e3 in
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(t.separator)
                                    Capsule().fill(e3.fg(t.accentAdjusted.color)).frame(width: g.size.width * b.pct)
                                }
                            }.frame(height: 8)
                        }
                    }
                    .padding(.vertical, 12).padding(.horizontal, 14).frame(maxWidth: .infinity).optSurface(e.surface(t.card))
                }
            }
        }
    }

    private func chat(_ msgs: [(String, Bool)], _ p: String) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(msgs.enumerated()), id: \.offset) { i, m in
                HStack {
                    if m.1 { Spacer(minLength: 60) }
                    Editable(id: "\(p).m\(i)", name: "Message \(i + 1)", kind: .card) { e in
                        Text(e.text ?? m.0).font(t.font(.body, weight: e.weight?.font)).foregroundStyle(e.fg(m.1 ? t.buttonLabel.color : t.text.color))
                            .opacity(hideDetails ? 0 : 1)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .optSurface(e.surface(m.1 ? t.button : t.card))
                    }
                    if !m.1 { Spacer(minLength: 60) }
                }
            }
        }
    }

    private func grid(_ title: String, _ items: [ProductDef], _ p: String) -> some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return VStack(spacing: 10) {
            sectionTitle(title, p)
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, it in
                    Editable(id: "\(p).t\(i)", name: "Product: \(it.name)", kind: .card) { e in
                        VStack(alignment: .leading, spacing: 8) {
                            Editable(id: "\(p).t\(i).icon", name: "Product icon: \(it.name)", kind: .icon) { e2 in IconTile(t: t, icon: it.icon, index: i, size: 56, iconSize: 26, edit: e2) }
                            Editable(id: "\(p).t\(i).name", name: "Product name: \(it.name)", kind: .text) { e3 in
                                Text(e3.text ?? e.text ?? it.name).font(t.font(.body, weight: e3.weight?.font ?? e.weight?.font ?? .semibold)).foregroundStyle(e3.fg(e.fg(t.text.color)))
                            }
                            Editable(id: "\(p).t\(i).price", name: "Product price: \(it.name)", kind: .text) { e3 in
                                Text(e3.text ?? it.price).font(t.font(.caption, weight: e3.weight?.font)).foregroundStyle(e3.fg(t.secondary.color))
                            }
                        }
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading).optSurface(e.surface(t.card))
                    }
                }
            }
        }
    }

    private func toggles(_ rows: [(String, String, Bool?)], _ p: String) -> some View {
        Editable(id: p, name: "Settings group", kind: .card) { e in
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, it in
                    Editable(id: "\(p).r\(i)", name: "Row: \(it.0)", kind: .row) { _ in
                        HStack(spacing: 12) {
                            Editable(id: "\(p).r\(i).icon", name: "Row icon: \(it.0)", kind: .icon) { e3 in IconTile(t: t, icon: it.1, index: i, edit: e3) }
                            Editable(id: "\(p).r\(i).title", name: "Row label: \(it.0)", kind: .text) { e3 in
                                Text(e3.text ?? it.0).font(t.font(.body, weight: e3.weight?.font)).foregroundStyle(e3.fg(t.text.color))
                            }
                            Spacer()
                            if let on = it.2 {
                                Editable(id: "\(p).r\(i).switch", name: "Switch: \(it.0)", kind: .control) { _ in PreviewToggle(tokens: t, isOn: on) }
                            } else {
                                Editable(id: "\(p).r\(i).chevron", name: "Arrow: \(it.0)", kind: .glyph) { e3 in
                                    Image(systemName: e3.icon ?? "chevron.right").font(.system(size: 14, weight: e3.weight?.font ?? .semibold)).foregroundStyle(e3.fg(t.secondary.color))
                                }
                            }
                        }
                        .padding(.vertical, t.rowV).padding(.horizontal, t.rowH)
                    }
                    if i < rows.count - 1 { Rectangle().fill(t.separator).frame(height: 0.5).padding(.leading, t.rowH + 54) }
                }
            }
            .optSurface(e.surface(t.card))
        }
    }

    private func profile(_ name: String, _ email: String, _ p: String) -> some View {
        Editable(id: p, name: "Profile card", kind: .card) { e in
            HStack(spacing: 12) {
                Editable(id: "\(p).avatar", name: "Profile avatar", kind: .icon) { e2 in IconTile(t: t, icon: "person", index: 1, size: 54, iconSize: 26, edit: e2) }
                VStack(alignment: .leading, spacing: 2) {
                    Editable(id: "\(p).name", name: "Profile name", kind: .text) { e2 in t.text(.section, name, e2) }
                    Editable(id: "\(p).email", name: "Profile email", kind: .text) { e2 in t.text(.caption, email, e2, color: t.secondary.color) }
                }
                Spacer()
            }
            .padding(t.rowH).frame(maxWidth: .infinity).optSurface(e.surface(t.card))
        }
    }
}

struct BentoHomeScreen: View {
    let t: StyleTokens
    let def: ScreenDef
    private var recentRows: [RowDef] {
        for b in def.blocks { if case .list(_, let r) = b { return r } }
        return []
    }
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Editable(id: "bento.title", name: "Screen title", kind: .text) { e in t.text(.largeTitle, "Wallet", e) }
                    Spacer()
                    Editable(id: "bento.icon", name: "Header icon", kind: .icon) { e in IconTile(t: t, icon: "bell", size: 42, iconSize: 20, edit: e) }
                }
                .padding(.bottom, 4)
                Editable(id: "bento.hero", name: "Hero tile", kind: .card) { e in
                    VStack(alignment: .leading, spacing: 6) {
                        Editable(id: "bento.label", name: "Hero label", kind: .text) { e2 in
                            Text(e2.text ?? "Total balance").font(t.font(.caption, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.onAccent.op(0.8)))
                        }
                        Editable(id: "bento.value", name: "Hero value", kind: .text) { e2 in
                            Text(e2.text ?? "$12,480.50").font(t.font(.amount, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.onAccent.color))
                        }
                        Editable(id: "bento.chip", name: "Hero note", kind: .text) { e2 in
                            Text(e2.text ?? "+2.4% this week").font(t.font(.caption, weight: e2.weight?.font ?? .semibold)).foregroundStyle(e2.fg(t.onAccent.color))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(20)
                    .optSurface(e.surface(SurfaceStyle(radius: t.cardRadius, fill: .solid(t.accent.color), shadows: t.card.shadows)))
                }
                let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(Array(ScreenDefs.standardActions.enumerated()), id: \.offset) { i, a in
                        Editable(id: "bento.a\(i)", name: "Action tile: \(a.label)", kind: .card) { e in
                            let c = t.bentoTiles.isEmpty ? (t.accent.color, Color.white) : t.bentoTiles[i % 4]
                            VStack(alignment: .leading) {
                                Editable(id: "bento.a\(i).icon", name: "Tile icon: \(a.label)", kind: .glyph) { e2 in
                                    Image(systemName: e2.icon ?? a.icon).font(.system(size: 24, weight: e2.weight?.font ?? t.iconWeight)).foregroundStyle(e2.fg(e.fg(c.1)))
                                }
                                Spacer()
                                Editable(id: "bento.a\(i).label", name: "Tile label: \(a.label)", kind: .text) { e2 in
                                    Text(e2.text ?? e.text ?? a.label).font(.system(size: 16, weight: e2.weight?.font ?? e.weight?.font ?? .bold, design: t.bodyDesign)).foregroundStyle(e2.fg(e.fg(c.1)))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading).frame(height: 96).padding(14)
                            .optSurface(e.surface(SurfaceStyle(radius: t.cardRadius * 0.75, fill: .solid(c.0), shadows: t.card.shadows)))
                        }
                    }
                }
                Editable(id: "bento.recent", name: "Recent tile", kind: .card) { e in
                    VStack(alignment: .leading, spacing: 0) {
                        Editable(id: "bento.recent.title", name: "Section title: Recent", kind: .text) { e2 in
                            Text(e2.text ?? "Recent").font(t.font(.section, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.text.color))
                        }.padding(.horizontal, t.rowH).padding(.top, 14)
                        ForEach(Array(recentRows.enumerated()), id: \.offset) { i, r in
                            HStack(spacing: 12) {
                                Editable(id: "bento.r\(i).icon", name: "Row icon: \(r.title)", kind: .icon) { e2 in IconTile(t: t, icon: r.icon, index: i, edit: e2) }
                                VStack(alignment: .leading, spacing: 2) {
                                    Editable(id: "bento.r\(i).title", name: "Row title: \(r.title)", kind: .text) { e2 in
                                        Text(e2.text ?? r.title).font(t.font(.body, weight: e2.weight?.font ?? .semibold)).foregroundStyle(e2.fg(t.text.color))
                                    }
                                    Editable(id: "bento.r\(i).sub", name: "Row subtitle: \(r.title)", kind: .text) { e2 in
                                        Text(e2.text ?? r.subtitle).font(t.font(.caption, weight: e2.weight?.font)).foregroundStyle(e2.fg(t.secondary.color))
                                    }
                                }
                                Spacer()
                                Editable(id: "bento.r\(i).value", name: "Row value: \(r.title)", kind: .text) { e2 in
                                    Text(e2.text ?? r.value).font(t.font(.body, weight: e2.weight?.font ?? .semibold)).foregroundStyle(e2.fg(r.positive ? t.positive.color : t.text.color))
                                }
                            }
                            .padding(.vertical, t.rowV).padding(.horizontal, t.rowH)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).optSurface(e.surface(t.card))
                }
            }
            .padding(.horizontal, t.margin).padding(.top, 20)
            Spacer(minLength: 0)
            TabBarView(t: t, tabs: def.tabs, active: def.active)
        }
    }
}
