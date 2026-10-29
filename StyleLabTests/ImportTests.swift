import XCTest
import SwiftUI
@testable import StyleLab

@MainActor
final class ImportTests: XCTestCase {
    /// A fake app screen: grey page, a blue button with text, a white card with text, and a round icon.
    func fixture() -> UIImage {
        let fmt = UIGraphicsImageRendererFormat(); fmt.scale = 1; fmt.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 780, height: 1688), format: fmt).image { ctx in
            let c = ctx.cgContext
            UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1).setFill(); c.fill(CGRect(x: 0, y: 0, width: 780, height: 1688))
            UIColor.white.setFill(); UIBezierPath(roundedRect: CGRect(x: 40, y: 400, width: 700, height: 240), cornerRadius: 36).fill()
            UIColor(red: 0.18, green: 0.42, blue: 1, alpha: 1).setFill(); UIBezierPath(roundedRect: CGRect(x: 40, y: 900, width: 700, height: 120), cornerRadius: 28).fill()
            let big = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 56, weight: .bold), .foregroundColor: UIColor.black]
            ("Total balance" as NSString).draw(at: CGPoint(x: 80, y: 440), withAttributes: big)
            ("$12,480.50" as NSString).draw(at: CGPoint(x: 80, y: 520), withAttributes: big)
            let white = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 48, weight: .semibold), .foregroundColor: UIColor.white]
            ("Continue" as NSString).draw(at: CGPoint(x: 300, y: 938), withAttributes: white)
            UIColor.red.setFill(); c.fillEllipse(in: CGRect(x: 60, y: 150, width: 90, height: 90))
        }
    }

    func testAnalyzeFindsTextShapesAndCleansBackground() throws {
        let r = try ImportEngine.analyze(fixture(), name: "Test")
        let texts = r.screen.elements.filter { $0.kind == .text }.map(\.text).joined(separator: " ")
        XCTAssertTrue(texts.contains("Continue"), texts)
        XCTAssertTrue(texts.contains("Total balance"), texts)
        XCTAssertGreaterThanOrEqual(r.screen.elements.filter { $0.kind == .shape }.count, 1)
        XCTAssertEqual(r.screen.canvasW, 390, accuracy: 1)
        XCTAssertNotNil(UIImage(data: r.plate))
        XCTAssertTrue(r.screen.elements.allSatisfy { $0.w > 0 && $0.h > 0 })
        for el in r.screen.elements where el.kind == .text { XCTAssertGreaterThanOrEqual(el.fontSize, 8) }
    }

    func testHandoffListsImportedElementsWithEdits() throws {
        let r = try ImportEngine.analyze(fixture(), name: "Test")
        var spec = DesignSpec()
        spec.imports = [r.screen]; spec.currentImport = r.screen.id; spec.screens = [.imported]
        let t = try XCTUnwrap(r.screen.elements.first { $0.kind == .text })
        spec.edits[r.screen.editKey(t)] = ElementEdit(screen: "imported", name: "t", kind: .text, dx: 10, fgHex: "#FF0000", text: "Hello")
        let md = HandoffWriter.markdown(spec: spec)
        XCTAssertTrue(md.contains("imported from a screenshot"))
        XCTAssertTrue(md.contains("## 10. Machine readable design"))
        XCTAssertTrue(md.contains("\"Hello\""))
        XCTAssertTrue(md.contains("#FF0000"))
        XCTAssertFalse(md.contains("--"))
        let decoded = try DesignStore.decoder().decode(DesignSpec.self, from: DesignStore.encoder().encode(spec))
        XCTAssertEqual(decoded.imports, spec.imports)
    }
}

extension ImportTests {
    /// A busier screen: gradient banner, noisy photo, circle, triangle, tinted icon tile and an outlined field.
    func richFixture() -> UIImage {
        let fmt = UIGraphicsImageRendererFormat(); fmt.scale = 1; fmt.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 780, height: 1688), format: fmt).image { ctx in
            let c = ctx.cgContext
            UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1).setFill(); c.fill(CGRect(x: 0, y: 0, width: 780, height: 1688))
            // gradient banner
            c.saveGState(); UIBezierPath(roundedRect: CGRect(x: 40, y: 80, width: 700, height: 220), cornerRadius: 36).addClip()
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1).cgColor, UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 1).cgColor] as CFArray, locations: [0, 1])!
            c.drawLinearGradient(grad, start: CGPoint(x: 40, y: 80), end: CGPoint(x: 740, y: 300), options: []); c.restoreGState()
            let white = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 56, weight: .bold), .foregroundColor: UIColor.white]
            ("Summer sale" as NSString).draw(at: CGPoint(x: 80, y: 160), withAttributes: white)
            // noisy photo
            var g = SystemRandomNumberGenerator()
            for y in stride(from: 360, to: 620, by: 4) { for x in stride(from: 40, to: 380, by: 4) {
                UIColor(red: CGFloat.random(in: 0.2...0.9, using: &g), green: CGFloat.random(in: 0.3...0.8, using: &g), blue: CGFloat.random(in: 0.1...0.7, using: &g), alpha: 1).setFill()
                c.fill(CGRect(x: x, y: y, width: 4, height: 4)) } }
            // circle avatar and triangle
            UIColor.orange.setFill(); c.fillEllipse(in: CGRect(x: 440, y: 380, width: 120, height: 120))
            UIColor.systemRed.setFill()
            let tri = UIBezierPath(); tri.move(to: CGPoint(x: 640, y: 380)); tri.addLine(to: CGPoint(x: 720, y: 520)); tri.addLine(to: CGPoint(x: 560, y: 520)); tri.close(); tri.fill()
            // tinted tile with a glyph
            UIColor(red: 0.88, green: 0.93, blue: 1, alpha: 1).setFill(); UIBezierPath(roundedRect: CGRect(x: 40, y: 700, width: 120, height: 120), cornerRadius: 28).fill()
            let cfg = UIImage.SymbolConfiguration(pointSize: 60, weight: .semibold)
            UIImage(systemName: "paperplane.fill", withConfiguration: cfg)?.withTintColor(UIColor(red: 0.18, green: 0.42, blue: 1, alpha: 1), renderingMode: .alwaysOriginal).draw(in: CGRect(x: 66, y: 726, width: 68, height: 68))
            // outlined text field
            UIColor.gray.setStroke(); let box = UIBezierPath(roundedRect: CGRect(x: 40, y: 900, width: 700, height: 100), cornerRadius: 20); box.lineWidth = 3; box.stroke()
            let dark = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 44), .foregroundColor: UIColor.darkGray]
            ("Search products" as NSString).draw(at: CGPoint(x: 80, y: 925), withAttributes: dark)
        }
    }
}

@MainActor
final class ImportRenderTests: XCTestCase {
    func testRenderImportedCanvas() throws {
        let fix = ImportTests().richFixture()
        let r = try ImportEngine.analyze(fix, name: "Look")
        ImportStore.write(r.plate, id: r.screen.id, file: r.screen.plateFile)
        for c in r.crops { ImportStore.write(c.data, id: r.screen.id, file: c.file) }
        var spec = DesignSpec(); spec.imports = [r.screen]; spec.currentImport = r.screen.id
        // move the first text and recolor the first shape, as the editor would
        if let t = r.screen.elements.first(where: { $0.kind == .text }) { spec.edits[r.screen.editKey(t)] = ElementEdit(screen: "imported", name: "t", kind: .text, dy: 60, fgHex: "#E23D7B") }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let left = Image(uiImage: fix).resizable().frame(width: 390, height: 844)
        let sheet = HStack(spacing: 10) { left; SampleScreenView(spec: spec, screen: .imported) }.padding(10).background(Color.gray)
        let ren = ImageRenderer(content: sheet); ren.scale = 2
        if let d = ren.uiImage?.pngData() { try d.write(to: docs.appendingPathComponent("import-check.png")) }
        let summary = r.screen.elements.map { "\($0.kind.rawValue) \($0.text) \(Int($0.x)),\(Int($0.y)) \(Int($0.w))x\(Int($0.h)) fs\($0.fontSize) \($0.colorHex)" }.joined(separator: "\n")
        try summary.write(to: docs.appendingPathComponent("import-summary.txt"), atomically: true, encoding: .utf8)
    }
}
