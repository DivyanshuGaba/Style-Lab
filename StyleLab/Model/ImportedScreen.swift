import Foundation

struct ImportedElement: Codable, Equatable, Identifiable, Sendable {
    enum Kind: String, Codable, Sendable { case text, shape, image }
    var id: String
    var kind: Kind
    /// Frame in points on the 390 by 844 canvas, origin top left.
    var x: Double, y: Double, w: Double, h: Double
    var text: String = ""
    var fontSize: Double = 16
    var weight: ElementWeight = .regular
    /// Text color for text, fill color for shapes.
    var colorHex: String = "#000000"
    var radius: Double = 0
    /// File name of the cropped image for icons and pictures.
    var file: String = ""
}

/// A screenshot converted into editable parts: a cleaned background plus text, shapes and icons.
struct ImportedScreen: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var name: String = "Imported screen"
    var bgHex: String = "#FFFFFF"
    var canvasW: Double = 390
    var canvasH: Double = 844
    var pixelW: Int = 0
    var pixelH: Int = 0
    var plateFile: String = "plate.jpg"
    var originalFile: String = "original.jpg"
    var elements: [ImportedElement] = []

    /// Short stable prefix used in edit keys.
    var key: String { String(id.uuidString.prefix(6)) }
    func editKey(_ el: ImportedElement) -> String { "imported/\(key).\(el.id)" }
}
