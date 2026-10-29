import XCTest
@testable import StyleLab

final class ColorMathTests: XCTestCase {
    func testContrast() {
        XCTAssertEqual(ColorMath.contrast(.black, .white), 21.0, accuracy: 0.05)
        XCTAssertEqual(ColorMath.contrast(RGB(hex: "#767676"), .white), 4.54, accuracy: 0.02)
        XCTAssertEqual(ColorMath.contrast(.white, .white), 1.0, accuracy: 0.001)
    }
    func testOnColor() {
        XCTAssertEqual(ColorMath.onColor(.white), .black)
        XCTAssertEqual(ColorMath.onColor(.black), .white)
    }
    func testMixAndEnsure() {
        let a = RGB(hex: "#2F6BFF"), b = RGB(hex: "#E0A100")
        XCTAssertEqual(ColorMath.mix(a, b, 0), a)
        XCTAssertEqual(ColorMath.mix(a, b, 1), b)
        for hex in ["#E0A100", "#FFFF00", "#2F6BFF", "#777777"] {
            let c = ColorMath.ensure(RGB(hex: hex), .white, 4.5)
            XCTAssertTrue(ColorMath.contrast(c, .white) >= 4.5 || c == .black, hex)
        }
    }
    func testParse() {
        XCTAssertEqual(ColorMath.parse("#FFF"), .white)
        XCTAssertNil(ColorMath.parse("zzz"))
        XCTAssertEqual(RGB(hex: "#2f6bff").hex, "#2F6BFF")
    }
}

final class StyleRankerTests: XCTestCase {
    func testBriefs() {
        var b = Brief(); b.category = .finance; b.mood = .calm; b.context = .mixed; b.effort = .simple
        XCTAssertTrue([.ios, .oled].contains(StyleRanker.rank(b)[0].style))
        b = Brief(); b.category = .games; b.mood = .bold; b.context = .mixed; b.effort = .rich
        XCTAssertTrue([.brutal, .skeu].contains(StyleRanker.rank(b)[0].style))
        b = Brief(); b.category = .wellness; b.mood = .premium; b.context = .night; b.effort = .rich
        XCTAssertTrue([.liquid, .aurora, .glass].contains(StyleRanker.rank(b)[0].style))
    }
    func testBoundsAndDeterminism() {
        for c in AppCategory.allCases { for m in Mood.allCases { for ctx in UsageContext.allCases { for e in BuildEffort.allCases {
            let b = Brief(category: c, mood: m, context: ctx, effort: e)
            let r = StyleRanker.rank(b)
            XCTAssertEqual(r.count, 12)
            XCTAssertTrue(r.allSatisfy { (5...99).contains($0.percent) })
            XCTAssertEqual(r, StyleRanker.rank(b))
        } } } }
    }
    func testGuesser() {
        XCTAssertEqual(CategoryGuesser.guess("A budgeting app for freelancers"), .finance)
        XCTAssertEqual(CategoryGuesser.guess("hello"), .utility)
    }
}

final class SuggestionEngineTests: XCTestCase {
    func testNeuLegible() {
        var s = DesignSpec(); s.style = .neu; s.brief.context = .legible
        XCTAssertTrue(SuggestionEngine.suggestions(for: s).contains { $0.id == "neu" })
    }
    func testOledLightNoNight() {
        var s = DesignSpec(); s.style = .oled; s.mode = .light
        XCTAssertFalse(SuggestionEngine.suggestions(for: s).contains { $0.id == "night" })
    }
    func testContrastAction() {
        var s = DesignSpec(); s.style = .glass; s.mode = .light; s.accentHex = "#E0A100"
        let sug = SuggestionEngine.suggestions(for: s).first { $0.id == "contrast" }
        XCTAssertNotNil(sug)
        var copy = s
        sug?.actions.first?.apply(to: &copy)
        XCTAssertTrue(copy.boostContrast)
    }
    func testNothingToFlag() {
        XCTAssertTrue(SuggestionEngine.suggestions(for: DesignSpec()).isEmpty)
    }
}

final class SentencesTests: XCTestCase {
    func testAllNonEmpty() {
        Mood.allCases.forEach { XCTAssertFalse(Sentences.mood($0).isEmpty) }
        UsageContext.allCases.forEach { XCTAssertFalse(Sentences.context($0).isEmpty) }
        BuildEffort.allCases.forEach { XCTAssertFalse(Sentences.effort($0).isEmpty) }
        SatisfactionFlag.allCases.forEach { XCTAssertFalse(Sentences.flag($0).isEmpty) }
    }
}

final class DesignStoreTests: XCTestCase {
    func tempDir() -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("StyleLabTest-\(UUID().uuidString)/designs")
        return u
    }
    func testRoundTripDuplicateDelete() {
        let dir = tempDir()
        let store = DesignStore(directory: dir)
        var s = DesignSpec(); s.name = "A"; s.createdAt = Date(timeIntervalSince1970: 1_700_000_000); s.updatedAt = s.createdAt
        store.save(s)
        let again = DesignStore(directory: dir)
        XCTAssertEqual(again.designs.first, s)
        let dup = again.duplicate(s)
        XCTAssertEqual(again.designs.count, 2)
        again.delete(dup.id)
        XCTAssertEqual(again.designs.count, 1)
    }
    func testCorruptFileIgnored() throws {
        let dir = tempDir()
        let store = DesignStore(directory: dir)
        store.save(DesignSpec())
        try "not json".write(to: dir.appendingPathComponent("bad.json"), atomically: true, encoding: .utf8)
        XCTAssertEqual(DesignStore(directory: dir).designs.count, 1)
    }
}

@MainActor
final class HandoffWriterTests: XCTestCase {
    func fixture(_ style: StyleID) -> DesignSpec {
        var s = DesignSpec()
        s.id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        s.name = "Ledgerly \(StyleCatalog.info(style).name)"
        s.brief = Brief(appName: "Ledgerly", oneLiner: "A budgeting app for freelancers who hate spreadsheets", category: .finance, mood: .calm, context: .night, effort: .simple)
        s.style = style; s.mode = .dark
        s.satisfaction = [.iconsHardToSee]; s.notes = "Keep icons easy to see at night."
        s.createdAt = Date(timeIntervalSince1970: 1_700_000_000); s.updatedAt = s.createdAt
        return s
    }

    func testGolden() throws {
        for style in [StyleID.ios, .liquid, .brutal] {
            let md = HandoffWriter.markdown(spec: fixture(style))
            if let url = Bundle(for: Self.self).url(forResource: style.rawValue, withExtension: "md") {
                let data = try Data(contentsOf: url)
                XCTAssertEqual(String(decoding: data, as: UTF8.self), md, "golden mismatch for \(style)")
            } else {
                print("GOLDEN-B64 \(style.rawValue) \(Data(md.utf8).base64EncodedString()) END")
                XCTFail("golden file missing for \(style)")
            }
        }
    }

    func testStructureForAllStyles() throws {
        for style in StyleID.allCases {
            let spec = fixture(style)
            let md = HandoffWriter.markdown(spec: spec)
            var last = md.startIndex
            for n in 1...10 {
                let range = md.range(of: "\n## \(n). ", range: last..<md.endIndex)
                XCTAssertNotNil(range, "\(style) missing section \(n)")
                if let r = range { last = r.upperBound }
            }
            XCTAssertFalse(md.contains("--"), "\(style) has double hyphen")
            XCTAssertNil(md.range(of: "<[a-zA-Z/][^>]*>", options: .regularExpression), "\(style) has HTML")
            XCTAssertFalse(md.contains("|"))
            XCTAssertEqual(md, HandoffWriter.markdown(spec: spec), "not deterministic")
            let open = try XCTUnwrap(md.range(of: "```json\n")), close = try XCTUnwrap(md.range(of: "\n```", range: open.upperBound..<md.endIndex))
            let body = md[open.upperBound..<close.lowerBound]
            let decoded = try DesignStore.decoder().decode(HandoffJSON.self, from: Data(body.utf8))
            XCTAssertEqual(decoded.design, HandoffWriter.sanitized(spec))
        }
    }
}

@MainActor
final class EditorModelTests: XCTestCase {
    func testOldFilesDecode() throws {
        let json = #"{"schemaVersion":1,"design":{"id":"00000000-0000-0000-0000-000000000009","name":"Old","style":"neon","mode":"dark"}}"#
        let f = try DesignStore.decoder().decode(DesignFile.self, from: Data(json.utf8))
        XCTAssertEqual(f.design.style, .neon)
        XCTAssertTrue(f.design.edits.isEmpty)
    }
    func testEditsRoundTripAndAppearInTheDescription() throws {
        var s = DesignSpec()
        s.app = .pos
        s.edits["pos-sales/b1"] = ElementEdit(screen: "pos-sales", name: "Hero card", kind: .card, dx: 12, dy: 0, bgHex: "#FF0000")
        s.edits["pos-sales/b0.title"] = ElementEdit(screen: "pos-sales", name: "Screen title", kind: .text, text: "Hello Sales")
        let data = try DesignStore.encoder().encode(s)
        XCTAssertEqual(try DesignStore.decoder().decode(DesignSpec.self, from: data).edits, s.edits)
        let md = HandoffWriter.markdown(spec: s)
        XCTAssertTrue(md.contains("## 8. Screens"))
        XCTAssertTrue(md.contains("Hello Sales"))
        XCTAssertTrue(md.contains("fill #FF0000. Position x 32,"), "moved card should sit 12 pt to the right of the 20 pt margin")
        XCTAssertFalse(md.contains("--"))
    }

    func testIconEditsAreDescribed() {
        var s = DesignSpec()
        s.edits["all/tab.Home"] = ElementEdit(screen: "all", name: "Tab: Home", kind: .glyph, icon: "star.fill")
        s.edits["home/b2.a0"] = ElementEdit(screen: "home", name: "Action: Send", kind: .icon, icon: "paperplane.fill", badge: 2)
        let md = HandoffWriter.markdown(spec: s)
        XCTAssertTrue(md.contains("symbol star.fill at 22 pt"))
        XCTAssertTrue(md.contains("symbol paperplane.fill at 28 pt"))
        XCTAssertTrue(md.contains("red number badge 2"))
        XCTAssertFalse(ElementEdit(icon: "x").isDefault)
    }

    func testExportIsADescriptionNotInstructions() {
        for style in StyleID.allCases {
            var s = DesignSpec(); s.style = style
            s.notes = "Make the icons bigger"
            let md = HandoffWriter.markdown(spec: s)
            for phrase in ["Build the app", "Implementation guidance", "Open questions", "Ask before", "Do not ", "You are receiving", "Create one design token", "Rebuild"] {
                XCTAssertFalse(md.contains(phrase), "\(style) contains instruction text: \(phrase)")
            }
            XCTAssertFalse(md.contains("Make the icons bigger") && md.contains("## 11"), "notes are not part of the description")
        }
    }

    func testDefaultEditIsRemovable() {
        XCTAssertTrue(ElementEdit().isDefault)
        var e = ElementEdit(); e.dx = 1
        XCTAssertFalse(e.isDefault)
    }
    func testEveryScreenHasContent() {
        for s in SampleScreen.allCases {
            let d = ScreenDefs.def(s)
            XCTAssertFalse(d.blocks.isEmpty, "\(s)")
            XCTAssertEqual(d.tabs.count, 4)
            XCTAssertFalse(s.title.isEmpty)
        }
    }
}

@MainActor
final class ProjectIsolationTests: XCTestCase {
    func makeModel() -> AppModel {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("SLProj-\(UUID().uuidString)/designs")
        return AppModel(store: DesignStore(directory: dir))
    }

    func testPristineIgnoresStudioWork() {
        let g = DesignSpec.pristine(style: .neon)
        XCTAssertEqual(g.accentHex, "#2F6BFF"); XCTAssertTrue(g.edits.isEmpty); XCTAssertFalse(g.hasCustomizations)
    }

    func testStartProjectSavesEditedDesignAndStartsClean() {
        let m = makeModel()
        m.update { $0.accentHex = "#E23D7B"; $0.edits["home/b0.title"] = ElementEdit(screen: "home", name: "t", kind: .text, dx: 5) }
        XCTAssertTrue(m.spec.hasCustomizations)
        let oldId = m.spec.id
        m.startProject(style: .brutal)
        XCTAssertEqual(m.spec.style, .brutal)
        XCTAssertEqual(m.spec.accentHex, "#2F6BFF")
        XCTAssertTrue(m.spec.edits.isEmpty)
        XCTAssertNotEqual(m.spec.id, oldId)
        XCTAssertEqual(m.store.designs.first { $0.id == oldId }?.accentHex, "#E23D7B")
        XCTAssertFalse(m.canUndo)
    }

    func testUntouchedDesignIsNotSaved() {
        let m = makeModel()
        m.startProject(style: .oled)
        XCTAssertTrue(m.store.designs.isEmpty)
    }

    func testResetAllEdits() {
        let m = makeModel()
        m.update { $0.edits["a/b"] = ElementEdit(dx: 1) }
        m.resetAllEdits()
        XCTAssertTrue(m.spec.edits.isEmpty)
    }
}

@MainActor
final class SampleAppAndProjectTests: XCTestCase {
    func makeModel() -> AppModel {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("SLApp-\(UUID().uuidString)/designs")
        return AppModel(store: DesignStore(directory: dir))
    }

    func testEveryAppHasContentForItsScreens() {
        for app in SampleApp.allCases {
            XCTAssertFalse(app.screens.isEmpty)
            for s in app.screens {
                let d = AppContent.def(s, app)
                XCTAssertFalse(d.blocks.isEmpty, "\(app) \(s)")
                XCTAssertEqual(d.tabs.count, 4, "\(app) \(s)")
                XCTAssertTrue((0..<4).contains(d.active), "\(app) \(s)")
            }
        }
    }

    func testAppSpecificContentIsDifferent() {
        let wallet = AppContent.def(.home, .wallet).tabs.map(\.label)
        let pos = AppContent.def(.home, .pos).tabs.map(\.label)
        XCTAssertNotEqual(wallet, pos)
        XCTAssertEqual(pos.first, "Register")
    }

    func testEditKeysKeepWalletCompatible() {
        XCTAssertEqual(SampleScreen.home.editKey(.wallet), "home")
        XCTAssertEqual(SampleScreen.home.editKey(.pos), "pos-home")
        XCTAssertEqual(SampleScreen.imported.editKey(.pos), "imported")
    }

    func testOldDesignsDecodeAsWalletApp() throws {
        let json = #"{"schemaVersion":1,"design":{"id":"00000000-0000-0000-0000-00000000000a","name":"Old"}}"#
        let f = try DesignStore.decoder().decode(DesignFile.self, from: Data(json.utf8))
        XCTAssertEqual(f.design.app, .wallet)
    }

    func testProjectLifecycle() {
        let m = makeModel()
        XCTAssertFalse(m.isSavedProject)
        m.createProject(name: "  My POS  ")
        XCTAssertTrue(m.isSavedProject)
        XCTAssertEqual(m.spec.name, "My POS")
        m.renameProject("POS v2")
        XCTAssertEqual(m.store.designs.first?.name, "POS v2")
        let id = m.spec.id
        m.deleteProject()
        XCTAssertFalse(m.store.designs.contains { $0.id == id })
        XCTAssertNotEqual(m.spec.id, id)
        XCTAssertEqual(m.tab, .gallery)
    }

    func testStartProjectUsesChosenApp() {
        let m = makeModel()
        m.startProject(style: .neon, app: .delivery)
        XCTAssertEqual(m.spec.app, .delivery)
        XCTAssertEqual(m.spec.screens, Array(SampleApp.delivery.screens.prefix(2)))
        XCTAssertFalse(m.isSavedProject)   // saved only after the person names it
    }

    func testHandoffMentionsNonWalletApp() {
        var s = DesignSpec(); s.app = .foodOrder; s.screens = [.home]
        let md = HandoffWriter.markdown(spec: s)
        XCTAssertTrue(md.contains("Food ordering"))
        XCTAssertTrue(md.contains("Tab \"Menu\""))
        XCTAssertTrue(md.contains("Tab \"Offers\""))
    }
}

@MainActor
final class StandardBarTests: XCTestCase {
    func testEveryStyleExportsTheSameBottomBar() {
        var seen: Set<String> = []
        for style in StyleID.allCases {
            var s = DesignSpec(); s.style = style; s.mode = .dark; s.accentHex = "#2F6BFF"
            let md = HandoffWriter.markdown(spec: s)
            XCTAssertTrue(md.contains("Bottom bar (identical in every design): a floating liquid glass tab bar"), "\(style)")
            XCTAssertTrue(md.contains("62 pt tall, inset 20 pt from the left and right edges and 24 pt above the bottom edge"), "\(style)")
            // the bar paragraph is identical for every style except the accent color that is chosen per style
            let line = md.split(separator: "\n").first { $0.hasPrefix("- Bottom bar background") }.map(String.init) ?? ""
            seen.insert(line)
        }
        XCTAssertEqual(seen.count, 1)
    }
    func testBarStillExportedWhenComponentsAreOff() {
        var o = HandoffOptions(); o.components = false
        let md = HandoffWriter.markdown(spec: DesignSpec(), options: o)
        XCTAssertTrue(md.contains("floating liquid glass tab bar"))
    }
}

@MainActor
final class ScreenDownloaderTests: XCTestCase {
    func testRendersEveryScreenOfTheApp() async {
        var spec = DesignSpec(); spec.app = .reminders; spec.name = "Remind Me"
        let items = await ScreenDownloader.renderAll(spec: spec)
        XCTAssertEqual(items.count, SampleApp.reminders.screens.count)
        XCTAssertTrue(items.allSatisfy { $0.image.size.width > 100 && $0.name.hasSuffix(".png") })
        XCTAssertEqual(Set(items.map(\.name)).count, items.count)
        let urls = ScreenDownloader.writeFiles(items, id: spec.id)
        XCTAssertEqual(urls.count, items.count)
        XCTAssertTrue(urls.allSatisfy { FileManager.default.fileExists(atPath: $0.path) })
    }
}


@MainActor
final class AllScreensExportTests: XCTestCase {
    func testExportDescribesEveryScreenOfEveryApp() {
        for app in SampleApp.allCases {
            var spec = DesignSpec(); spec.app = app
            spec.screens = [app.screens[0]]          // the screenshot selection must not limit the description
            let md = HandoffWriter.markdown(spec: spec)
            for s in app.screens { XCTAssertTrue(md.contains("### \(s.title) screen"), "\(app) is missing \(s)") }
            XCTAssertTrue(md.contains("all \(app.screens.count) screens"), "\(app)")
        }
    }
}

@MainActor
final class HideDetailsTests: XCTestCase {
    func testDecodesAsOffForOlderDesigns() throws {
        let json = #"{"schemaVersion":1,"design":{"id":"00000000-0000-0000-0000-00000000000b","name":"Old"}}"#
        XCTAssertFalse(try DesignStore.decoder().decode(DesignFile.self, from: Data(json.utf8)).design.hideDetails)
    }

    func testExportCarriesDesignValuesOnlyWhenDetailsAreHidden() throws {
        for style in StyleID.allCases {
            var s = DesignSpec(); s.style = style; s.hideDetails = true; s.app = .foodOrder
            s.edits["foodOrder-home/b0.title"] = ElementEdit(screen: "foodOrder-home", name: "t", kind: .text, text: "Secret menu")
            let md = HandoffWriter.markdown(spec: s)
            XCTAssertFalse(md.contains("## 8. Screens"), "\(style)")
            XCTAssertFalse(md.contains("### "), "\(style)")
            XCTAssertFalse(md.contains("Sample app"), "\(style)")
            XCTAssertFalse(md.contains("Food ordering"), "\(style)")
            XCTAssertFalse(md.contains("Secret menu"), "\(style)")
            XCTAssertFalse(md.contains("Chef's picks"), "\(style)")
            // design values are still there
            XCTAssertTrue(md.contains("## 2. Colors")); XCTAssertTrue(md.contains("floating liquid glass tab bar"))
            XCTAssertTrue(md.contains("## 7. Light and dark mode"))
            let data = HandoffWriter.json(spec: s)
            let decoded = try DesignStore.decoder().decode(HandoffJSON.self, from: data)
            XCTAssertTrue(decoded.design.edits.isEmpty); XCTAssertTrue(decoded.design.imports.isEmpty)
        }
    }

    func testDetailsHiddenRoundTrips() throws {
        var s = DesignSpec(); s.hideDetails = true
        let back = try DesignStore.decoder().decode(DesignSpec.self, from: DesignStore.encoder().encode(s))
        XCTAssertTrue(back.hideDetails)
        XCTAssertTrue(s.hasCustomizations)
    }
}
