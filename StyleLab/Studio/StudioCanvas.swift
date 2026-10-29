import SwiftUI

struct StudioCanvas: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let a = RGB(hex: model.spec.accentHex).color
        ZStack {
            Color.canvas
            RadialGradient(colors: [a.opacity(0.32), a.opacity(0)], center: UnitPoint(x: 0.1, y: 0.12), startRadius: 0, endRadius: 360)
            RadialGradient(colors: [Chrome.violet.opacity(0.24), Chrome.violet.opacity(0)], center: UnitPoint(x: 0.95, y: 0.7), startRadius: 0, endRadius: 320)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.4), value: model.spec.accentHex)
    }
}
