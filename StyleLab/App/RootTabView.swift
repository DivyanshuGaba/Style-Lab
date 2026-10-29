import SwiftUI

struct RootTabView: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        @Bindable var m = model
        TabView(selection: $m.tab) {
            DiscoverView().tabItem { Label("Discover", systemImage: "wand.and.stars") }.tag(AppTab.discover)
            GalleryView().tabItem { Label("Gallery", systemImage: "square.grid.2x2") }.tag(AppTab.gallery)
            StudioView().tabItem { Label("Studio", systemImage: "slider.horizontal.3") }.tag(AppTab.studio)
            LibraryView().tabItem { Label("Library", systemImage: "books.vertical") }.tag(AppTab.library)
        }
        .overlay(alignment: .top) {
            if let n = model.notice {
                Label(n, systemImage: "tray.and.arrow.down").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10).background(Chrome.gradient, in: Capsule())
                    .shadow(radius: 10, y: 4).padding(.top, 8).transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: model.notice)
        .fullScreenCover(item: $m.exportSpec) { spec in ExportFlowView(initial: spec) }
        .sheet(item: $m.detailStyle) { style in StyleDetailSheet(style: style) }
        .sheet(isPresented: $m.showImport) { ImportSheet() }
    }
}
