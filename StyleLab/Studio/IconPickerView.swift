import SwiftUI

enum IconCatalog {
    static let groups: [(String, [String])] = [
        ("Money and shopping", ["dollarsign.circle", "eurosign.circle", "sterlingsign.circle", "yensign.circle", "banknote", "creditcard", "wallet.pass", "cart", "bag", "basket", "tag", "percent", "chart.bar", "chart.line.uptrend.xyaxis", "chart.pie", "doc.text", "gift", "storefront", "building.columns"]),
        ("Actions and arrows", ["paperplane", "arrow.up.right", "arrow.down.left", "arrow.up", "arrow.down", "arrow.left", "arrow.right", "arrow.left.arrow.right", "chevron.left", "chevron.right", "arrow.uturn.left", "arrow.clockwise", "arrow.triangle.2.circlepath", "square.and.arrow.up", "square.and.arrow.down", "plus", "minus", "xmark", "checkmark", "ellipsis", "ellipsis.circle", "line.3.horizontal", "slider.horizontal.3", "magnifyingglass", "qrcode.viewfinder", "barcode.viewfinder", "viewfinder", "doc.on.doc", "trash", "pencil", "square.and.pencil"]),
        ("Communication", ["bell", "bell.badge", "bubble.left", "bubble.left.and.bubble.right", "message", "envelope", "phone", "video", "mic", "speaker.wave.2", "paperclip", "link", "at", "megaphone"]),
        ("People", ["person", "person.2", "person.3", "person.crop.circle", "person.badge.plus", "person.badge.shield.checkmark", "figure.walk", "figure.run", "hand.raised", "hand.thumbsup", "heart", "star", "face.smiling", "faceid"]),
        ("Media", ["play.fill", "pause.fill", "backward.fill", "forward.fill", "music.note", "headphones", "photo", "camera", "film", "tv", "gamecontroller", "book", "newspaper", "waveform"]),
        ("Places and travel", ["house", "mappin.and.ellipse", "map", "location", "airplane", "car", "bus", "tram", "bicycle", "bed.double", "building.2", "globe", "fuelpump"]),
        ("Food and drink", ["cup.and.saucer", "fork.knife", "takeoutbag.and.cup.and.straw", "wineglass", "birthday.cake"]),
        ("Tools and devices", ["wrench.and.screwdriver", "hammer", "gearshape", "iphone", "laptopcomputer", "applewatch", "desktopcomputer", "printer", "battery.100", "wifi", "cable.connector", "keyboard", "cpu", "externaldrive", "shippingbox", "archivebox", "tray", "folder", "doc", "calendar", "clock", "timer", "checklist", "list.bullet", "pin", "bookmark", "flag"]),
        ("Status and nature", ["checkmark.circle", "exclamationmark.triangle", "info.circle", "questionmark.circle", "lock", "key", "shield", "eye", "sun.max", "moon", "cloud", "bolt", "flame", "leaf", "drop", "snowflake", "sparkles", "wand.and.stars", "crown", "trophy", "medal"]),
        ("Health and learning", ["heart.text.square", "cross.case", "pills", "dumbbell", "stethoscope", "graduationcap", "pencil.and.ruler", "backpack", "lightbulb"]),
    ]
}

/// Lets the person swap any SF Symbol for another.
struct IconPickerView: View {
    let current: String?
    let onPick: (String?) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var custom = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        TextField("Any SF Symbol name, for example star.fill", text: $custom).textFieldStyle(.roundedBorder).textInputAutocapitalization(.never).autocorrectionDisabled()
                        Button("Use") { let n = custom.trimmingCharacters(in: .whitespaces); if UIImage(systemName: n) != nil { onPick(n); dismiss() } else { Haptics.snap() } }
                            .buttonStyle(ChromePrimaryStyle(compact: true)).disabled(custom.isEmpty)
                    }
                    Button { onPick(nil); dismiss() } label: { Label("Use the original icon", systemImage: "arrow.uturn.backward").frame(maxWidth: .infinity).frame(minHeight: 44) }
                        .buttonStyle(ChromeSecondaryStyle())
                    ForEach(IconCatalog.groups, id: \.0) { group in
                        let items = group.1.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }
                        if !items.isEmpty {
                            Text(group.0).font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 58), spacing: 8)], spacing: 8) {
                                ForEach(items, id: \.self) { name in
                                    Button { onPick(name); Haptics.select(); dismiss() } label: {
                                        Image(systemName: name).font(.system(size: 22)).frame(maxWidth: .infinity, minHeight: 54)
                                            .foregroundStyle(current == name ? Color.white : Color.primary)
                                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(current == name ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color(.secondarySystemGroupedBackground))))
                                    }.buttonStyle(PressableStyle()).accessibilityLabel(name)
                                }
                            }
                        }
                    }
                }.padding()
            }
            .searchable(text: $search, prompt: "Search icons")
            .navigationTitle("Choose icon").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
        .presentationDetents([.large])
    }
}
