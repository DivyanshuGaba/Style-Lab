import SwiftUI

enum GalleryFilter: String, CaseIterable {
    case all = "All", dark = "Dark friendly", easy = "Easy to build", rich = "Most rich", access = "Highest accessibility", perf = "Best performance"
    func matches(_ s: StyleInfo) -> Bool {
        switch self {
        case .all: true
        case .dark: s.nightFriendly
        case .easy: s.ratings.ease >= 4
        case .rich: s.ratings.richness >= 4
        case .access: s.ratings.accessibility >= 4
        case .perf: s.ratings.performance >= 5
        }
    }
}

struct GalleryView: View {
    @Environment(AppModel.self) private var model
    @State private var filter: GalleryFilter = .all

    private var styles: [StyleInfo] {
        let f = StyleCatalog.all.filter { filter.matches($0) }
        switch model.gallerySort {
        case .fit:
            let order = model.ranking.map(\.style)
            return f.sorted { (order.firstIndex(of: $0.id) ?? 0) < (order.firstIndex(of: $1.id) ?? 0) }
        case .name: return f.sorted { $0.name < $1.name }
        case .accessibility: return f.sorted { $0.ratings.accessibility > $1.ratings.accessibility }
        case .richness: return f.sorted { $0.ratings.richness > $1.ratings.richness }
        }
    }

    var body: some View {
        @Bindable var m = model
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sample app").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SampleApp.allCases) { a in
                                Button { m.galleryApp = a; m.galleryScreen = a.mainScreen; Haptics.select() } label: {
                                    HStack(spacing: 6) { Image(systemName: a.icon); Text(a.shortTitle) }
                                        .font(.subheadline.weight(.semibold)).foregroundStyle(m.galleryApp == a ? Color.white : Color.primary)
                                        .padding(.horizontal, 14).frame(minHeight: 40)
                                        .background(Capsule().fill(m.galleryApp == a ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color(.secondarySystemGroupedBackground))))
                                        .frame(minHeight: 44)
                                }.buttonStyle(PressableStyle())
                            }
                        }.padding(.horizontal)
                    }
                    HStack(spacing: 10) {
                        Text(m.galleryApp.tagline).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
                        Spacer()
                        ScreenPickerMenu(screen: $m.galleryScreen, app: m.galleryApp, showImports: false)
                    }.padding(.horizontal)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(GalleryFilter.allCases, id: \.self) { f in
                            Button { filter = f } label: {
                                HStack(spacing: 4) { if filter == f { Image(systemName: "checkmark") }; Text(f.rawValue) }
                                    .font(.subheadline.weight(.semibold)).foregroundStyle(filter == f ? Color.white : Color.primary)
                                    .padding(.horizontal, 14).frame(minHeight: 38)
                                    .background(Capsule().fill(filter == f ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Color(.secondarySystemGroupedBackground))))
                                    .frame(minHeight: 44)
                            }.buttonStyle(PressableStyle()).animation(.spring(response: 0.3, dampingFraction: 0.8), value: filter)
                        }
                    }.padding(.horizontal)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                    ForEach(styles) { s in
                        Button { model.detailStyle = s.id } label: {
                            VStack(spacing: 6) {
                                PreviewCanvas(spec: DesignSpec.pristine(style: s.id, app: model.galleryApp), screen: model.galleryScreen).frame(height: 260)
                                    .overlay(alignment: .topTrailing) {
                                        if let p = model.percent(for: s.id) { Badge(text: "\(p)%").padding(6) }
                                    }
                                Text(s.name).font(.system(.subheadline, design: .rounded, weight: .bold)).foregroundStyle(.primary)
                                HStack(spacing: 6) {
                                    Text(s.shortLabel).foregroundStyle(.secondary)
                                    if s.nightFriendly { Image(systemName: "moon.stars.fill").foregroundStyle(Chrome.violet) }
                                    Spacer()
                                    HStack(spacing: 2) { ForEach(0..<5, id: \.self) { Circle().fill($0 < s.ratings.richness ? Chrome.indigo : Color.primary.opacity(0.15)).frame(width: 5, height: 5) } }
                                }.font(.caption).padding(.horizontal, 4)
                            }
                            .padding(8).frame(maxWidth: .infinity)
                            .chromeCard(radius: 22)
                            .transition(.scale(scale: 0.92).combined(with: .opacity))
                        }.buttonStyle(PressableStyle())
                    }
                }.padding()
            }
            .chromeBackground()
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: styles.map(\.id))
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $m.gallerySort) {
                            ForEach(GallerySort.allCases, id: \.self) { s in
                                if s != .fit || model.briefDone { Text(s.rawValue).tag(s) }
                            }
                        }
                    } label: { Label("Sort: \(model.gallerySort.rawValue)", systemImage: "arrow.up.arrow.down") }
                }
            }
        }
    }
}

struct RatingBars: View {
    let ratings: Ratings
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(zip(Ratings.labels, ratings.all).enumerated()), id: \.offset) { _, pair in
                HStack {
                    Text(pair.0).font(.subheadline).frame(width: 150, alignment: .leading)
                    ProgressView(value: Double(pair.1), total: 5)
                    Text("\(pair.1)/5").font(.subheadline.monospacedDigit())
                }
                .accessibilityElement(children: .ignore).accessibilityLabel(pair.0).accessibilityValue("\(pair.1) out of 5")
            }
            Text("Editorial ratings, not measurements.").font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct StyleDetailSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let style: StyleID
    @State private var mode: AppearanceMode?

    var body: some View {
        let info = StyleCatalog.info(style)
        @Bindable var m = model
        let spec = DesignSpec.pristine(style: style, mode: mode ?? .light, app: model.galleryApp)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Mode", selection: Binding(get: { mode ?? .light }, set: { mode = $0 })) {
                        Text("Light").tag(AppearanceMode.light); Text("Dark").tag(AppearanceMode.dark)
                    }.pickerStyle(.segmented)
                    ScreenPickerMenu(screen: $m.galleryScreen, app: model.galleryApp, showImports: false)
                    PreviewCanvas(spec: spec, screen: model.galleryScreen, framed: true).frame(height: 420).frame(maxWidth: .infinity)
                    Text(info.tagline).font(.headline)
                    Group {
                        Text("Best for: ").bold() + Text(info.bestFor)
                        Text("Watch out: ").bold() + Text(info.watchOut)
                    }.font(.subheadline)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tips").font(.headline)
                        ForEach(info.tips, id: \.self) { Text("• \($0)").font(.subheadline) }
                    }
                    RatingBars(ratings: info.ratings)
                    Button { model.update { $0.compareStyle = style == $0.style ? nil : style }; dismiss(); model.tab = .studio } label: {
                        Text("Add to compare").frame(maxWidth: .infinity).frame(minHeight: 44)
                    }.buttonStyle(ChromeSecondaryStyle())
                    Button { model.startProject(style: style, mode: mode, app: model.galleryApp); model.requestedScreen = model.galleryScreen; dismiss() } label: {
                        Label("Edit in Studio", systemImage: "slider.horizontal.3").frame(maxWidth: .infinity).frame(minHeight: 44)
                    }.buttonStyle(ChromePrimaryStyle())
                }.padding()
            }
            .chromeBackground().navigationTitle(info.name).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .presentationDragIndicator(.visible).presentationCornerRadius(32)
    }
}
