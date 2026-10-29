import XCTest
import SwiftUI
@testable import StyleLab

@MainActor
final class FrameTests: XCTestCase {
    func testFramesAreCollectedSynchronously() throws {
        let sink = FrameSink()
        let view = SampleScreenView(spec: DesignSpec(), screen: .home).environment(\.frameSink, sink)
        let r = ImageRenderer(content: view)
        _ = r.uiImage
        print("FRAMES-COUNT \(sink.frames.count)")
        for (k, v) in sink.frames.sorted(by: { $0.key < $1.key }).prefix(12) { print("FRAME \(k) \(v.rect)") }
        XCTAssertGreaterThan(sink.frames.count, 10)
    }
}
