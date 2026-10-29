import SwiftUI

/// The bottom bar used in every design. It is the same liquid glass bar as the one in Style Lab itself:
/// a floating capsule with a pill behind the selected item. It deliberately ignores the style's own look.
enum StandardBar {
    static let height: CGFloat = 62
    static let sideInset: CGFloat = 20
    static let bottomInset: CGFloat = 24
    static let pillInset: CGFloat = 5
    static let iconSize: CGFloat = 22
    static let labelSize: CGFloat = 10

    static func borderOpacity(dark: Bool) -> Double { dark ? 0.22 : 0.7 }
    static func pillOpacity(dark: Bool) -> Double { dark ? 0.12 : 0.07 }
    static func idleOpacity(dark: Bool) -> Double { dark ? 0.9 : 0.75 }
    static let shadowOpacity = 0.18
    static let shadowBlur: CGFloat = 18
    static let shadowY: CGFloat = 8
    static func solidHex(dark: Bool) -> String { dark ? "#1C1C1E" : "#FFFFFF" }
}

struct TabBarView: View {
    @Environment(\.hideDetails) private var hideDetails
    let t: StyleTokens
    let tabs: [ActDef]
    let active: Int

    var body: some View {
        let dark = t.mode == .dark
        let idle = (dark ? Color.white : Color.black).opacity(StandardBar.idleOpacity(dark: dark))
        Editable(id: "tabbar", name: "Bottom bar", kind: .card, shared: true) { e in
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { i, tab in
                    let selected = i == active
                    Editable(id: "tab.\(tab.label)", name: "Tab: \(tab.label)", kind: .glyph, shared: true, keepWhenHidden: true) { te in
                        VStack(spacing: 3) {
                            Image(systemName: te.icon ?? tab.icon).font(.system(size: StandardBar.iconSize, weight: te.weight?.font ?? .regular))
                                .overlay(alignment: .topTrailing) { if let b = te.badge { BadgeView(n: b, size: 24).offset(x: 12, y: -6) } }
                            Text(te.text ?? tab.label).font(.system(size: StandardBar.labelSize, weight: .medium))
                        }
                        .foregroundStyle(te.fg(selected ? t.accentAdjusted.color : idle))
                        .opacity(hideDetails ? 0 : 1)
                        .frame(maxWidth: .infinity).frame(height: StandardBar.height - StandardBar.pillInset * 2)
                        .background {
                            if selected { Capsule().fill((dark ? Color.white : Color.black).opacity(StandardBar.pillOpacity(dark: dark))) }
                        }
                    }
                }
            }
            .padding(StandardBar.pillInset)
            .frame(height: StandardBar.height)
            .background {
                if !e.bgHidden {
                    if let hex = e.bgHex { Capsule().fill(RGB(hex: hex).color) }
                    else if t.reduceTransparency { Capsule().fill(RGB(hex: StandardBar.solidHex(dark: dark)).color) }
                    else { Capsule().fill(.ultraThinMaterial) }
                }
            }
            .overlay { if !e.bgHidden { Capsule().strokeBorder(Color.white.opacity(StandardBar.borderOpacity(dark: dark)), lineWidth: 1) } }
            .shadow(color: .black.opacity(e.bgHidden ? 0 : StandardBar.shadowOpacity), radius: StandardBar.shadowBlur / 2, y: StandardBar.shadowY)
        }
        .padding(.horizontal, StandardBar.sideInset).padding(.bottom, StandardBar.bottomInset)
    }
}

struct IconTile: View {
    @Environment(\.hideDetails) private var hideDetails
    let t: StyleTokens
    var icon: String = ""
    var initials: String = ""
    var index = 0
    var size: CGFloat = 42
    var iconSize: CGFloat = 21
    var edit = ElementEdit()
    var body: some View {
        let color = edit.fg(t.tileIconColor(index))
        let weight = edit.weight?.font ?? t.iconWeight
        let symbol = edit.icon ?? icon
        Group {
            if symbol.isEmpty {
                Text(initials).font(.system(size: iconSize * 0.8, weight: edit.weight?.font ?? .semibold, design: t.bodyDesign))
            } else {
                Image(systemName: symbol).font(.system(size: iconSize, weight: weight))
            }
        }
        .foregroundStyle(color)
        .opacity(hideDetails ? 0 : 1)
        .frame(width: size, height: size)
        .optSurface(edit.surface(t.tileForIndex(index)))
        .overlay(alignment: .topTrailing) {
            if let b = edit.badge, !hideDetails { BadgeView(n: b, size: size).offset(x: size * 0.18, y: -size * 0.18) }
        }
    }
}

struct BadgeView: View {
    let n: Int
    let size: CGFloat
    var body: some View {
        Text("\(n)").font(.system(size: max(11, size * 0.26), weight: .bold)).foregroundStyle(.white)
            .padding(.horizontal, 5).frame(minWidth: max(16, size * 0.36), minHeight: max(16, size * 0.36))
            .background(Capsule().fill(Color.red))
    }
}

struct PrimaryButton: View {
    @Environment(\.hideDetails) private var hideDetails
    let t: StyleTokens
    let title: String
    var edit = ElementEdit()
    var body: some View {
        t.label(edit.text ?? title, .body).fontWeight(edit.weight?.font ?? .semibold).foregroundStyle(edit.fg(t.buttonLabel.color))
            .opacity(hideDetails ? 0 : 1)
            .frame(maxWidth: .infinity).frame(height: 52).optSurface(edit.surface(t.button))
    }
}

struct AmountText: View {
    let t: StyleTokens
    let s: String
    var edit = ElementEdit()
    var body: some View {
        let txt = Text(edit.text ?? s).font(t.font(.amount, weight: edit.weight?.font))
        if let g = t.amountGradient, edit.fgHex == nil {
            txt.foregroundStyle(LinearGradient(colors: g, startPoint: .leading, endPoint: .trailing))
        } else { txt.foregroundStyle(edit.fg(t.text.color)) }
    }
}

struct ChipView: View {
    @Environment(\.hideDetails) private var hideDetails
    let t: StyleTokens
    let s: String
    var edit = ElementEdit()
    var body: some View {
        let c = t.chip
        let fill = edit.bgHidden ? Color.clear : (edit.bgHex.map { RGB(hex: $0).color } ?? c.fill)
        Text(edit.text ?? s).font(t.font(.caption, weight: edit.weight?.font ?? .semibold)).foregroundStyle(edit.fg(c.text))
            .opacity(hideDetails ? 0 : 1)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(fill))
            .overlay { if let b = c.border, !edit.bgHidden { Capsule().strokeBorder(b, lineWidth: c.borderWidth) } }
    }
}

extension StyleTokens {
    func text(_ role: FontRole, _ s: String, _ e: ElementEdit, color: Color? = nil) -> some View {
        Text(e.text ?? s).font(font(role, weight: e.weight?.font)).foregroundStyle(e.fg(color ?? text.color))
    }
}
