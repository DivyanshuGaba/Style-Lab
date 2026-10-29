import SwiftUI

@main
struct StyleLabApp: App {
    @State private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            RootTabView().environment(model)
        }
    }
}
