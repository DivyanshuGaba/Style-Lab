import XCTest
import SwiftUI
@testable import StyleLab

@MainActor
final class RenderTests: XCTestCase {
    func testRenderContactSheets() throws {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for mode in [AppearanceMode.light, .dark] {
            let sheet = HStack(spacing: 8) {
                ForEach([StyleID.allCases[0..<6], StyleID.allCases[6..<12]].map(Array.init), id: \.first) { group in
                    VStack(spacing: 8) {
                        ForEach(group) { s in
                            var spec = DesignSpec(); let _ = (spec.style = s, spec.mode = mode)
                            SampleScreenView(spec: spec, screen: .home).frame(width: 390, height: 844).scaleEffect(0.42).frame(width: 164, height: 355)
                        }
                    }
                }
            }.padding(8).background(Color.gray)
            let r = ImageRenderer(content: sheet); r.scale = 2
            if let data = r.uiImage?.pngData() { try data.write(to: docs.appendingPathComponent("sheet-\(mode.rawValue).png")) }
        }
        let screens: [SampleScreen] = [.sales, .repair, .inventory, .friends, .chat, .cart, .analytics, .music, .courses, .calendar, .team, .explore]
        for (name, style, mode) in [("screens-ios", StyleID.ios, AppearanceMode.light), ("screens-neon", .neon, .dark)] {
            var spec = DesignSpec(); spec.style = style; spec.mode = mode
            let sp = spec
            let sheet = LazyVGrid(columns: Array(repeating: GridItem(.fixed(164), spacing: 8), count: 6), spacing: 8) {
                ForEach(screens, id: \.self) { sc in SampleScreenView(spec: sp, screen: sc).scaleEffect(0.42).frame(width: 164, height: 355) }
            }.padding(8).frame(width: 6 * 172 + 8).background(Color.gray)
            let r = ImageRenderer(content: sheet); r.scale = 2
            if let data = r.uiImage?.pngData() { try data.write(to: docs.appendingPathComponent("\(name).png")) }
        }
        do {
            let items: [(SampleApp, SampleScreen)] = SampleApp.allCases.flatMap { a in a.screens.prefix(3).map { (a, $0) } }
            let sheet = LazyVGrid(columns: Array(repeating: GridItem(.fixed(164), spacing: 8), count: 8), spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                    SampleScreenView(spec: DesignSpec.pristine(style: .ios, app: it.0), screen: it.1).scaleEffect(0.42).frame(width: 164, height: 355)
                }
            }.padding(8).frame(width: 8 * 172 + 8).background(Color.gray)
            let r = ImageRenderer(content: sheet); r.scale = 1.5
            if let data = r.uiImage?.pngData() { try data.write(to: docs.appendingPathComponent("apps.png")) }
        }
        do {
            let combos: [(StyleID, AppearanceMode, SampleScreen)] = [(.ios, .light, .home), (.neon, .dark, .settings), (.liquid, .dark, .home), (.bento, .light, .home), (.brutal, .light, .sales), (.clay, .light, .explore)]
            let sheet = HStack(spacing: 8) {
                ForEach(Array(combos.enumerated()), id: \.offset) { _, c in
                    var spec = DesignSpec.pristine(style: c.0, mode: c.1); let _ = (spec.hideDetails = true)
                    SampleScreenView(spec: spec, screen: c.2).scaleEffect(0.42).frame(width: 164, height: 355)
                }
            }.padding(8).background(Color.gray)
            let r = ImageRenderer(content: sheet); r.scale = 2
            if let data = r.uiImage?.pngData() { try data.write(to: docs.appendingPathComponent("hidden.png")) }
        }
        // a couple of larger single shots
        for s in [StyleID.liquid, .brutal, .bento] {
            var spec = DesignSpec(); spec.style = s; spec.mode = s == .liquid ? .dark : .light
            if let d = ScreenshotRenderer.image(spec: spec, screen: .home)?.pngData() { try d.write(to: docs.appendingPathComponent("single-\(s.rawValue).png")) }
        }
    }
}
