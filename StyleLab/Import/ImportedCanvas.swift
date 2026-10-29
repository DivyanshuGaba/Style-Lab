import SwiftUI

/// The editable version of an imported screenshot: a cleaned background with text, shapes and icons on top.
struct ImportedCanvas: View {
    let imp: ImportedScreen

    var body: some View {
        ZStack(alignment: .topLeading) {
            RGB(hex: imp.bgHex).color
            if let plate = ImportStore.image(imp.id, imp.plateFile) {
                Image(uiImage: plate).resizable().frame(width: imp.canvasW, height: imp.canvasH)
            }
            ForEach(ordered) { el in
                element(el).offset(x: el.x, y: el.y)
            }
        }
        .frame(width: 390, height: 844, alignment: .topLeading)
    }

    /// Backdrops first, biggest at the back, so small icons and pictures sit on top of the cards they were on. Text is always on top.
    private var ordered: [ImportedElement] {
        imp.elements.sorted {
            let a = $0.kind == .text, b = $1.kind == .text
            if a != b { return !a }
            return $0.w * $0.h > $1.w * $1.h
        }
    }

    @ViewBuilder private func element(_ el: ImportedElement) -> some View {
        let id = "\(imp.key).\(el.id)"
        // Anything covering a big part of the screen is a backdrop. It stays put unless chosen from the layers list.
        let backdrop = el.kind != .text && el.w * el.h > 0.3 * imp.canvasW * imp.canvasH
        switch el.kind {
        case .shape:
            Editable(id: id, name: "Shape \(el.id.dropFirst())", kind: .shape, selectable: !backdrop) { e in
                RoundedRectangle(cornerRadius: e.radius ?? el.radius, style: .continuous)
                    .fill(e.bgHidden ? Color.clear : RGB(hex: e.bgHex ?? el.colorHex).color)
                    .frame(width: el.w, height: el.h)
            }
        case .image:
            Editable(id: id, name: "Picture \(el.id.dropFirst())", kind: .image, selectable: !backdrop) { e in
                if let img = ImportStore.image(imp.id, el.file) {
                    if let tint = e.fgHex {
                        Image(uiImage: img).resizable().renderingMode(.template).foregroundStyle(RGB(hex: tint).color).frame(width: el.w, height: el.h)
                    } else {
                        Image(uiImage: img).resizable().frame(width: el.w, height: el.h)
                    }
                } else { Color.clear.frame(width: el.w, height: el.h) }
            }
        case .text:
            Editable(id: id, name: "Text: \(String(el.text.prefix(20)))", kind: .text) { e in
                Text(e.text ?? el.text)
                    .font(.system(size: el.fontSize, weight: e.weight?.font ?? el.weight.font))
                    .foregroundStyle(RGB(hex: e.fgHex ?? el.colorHex).color)
                    .lineLimit(1).fixedSize()
                    .frame(height: el.h, alignment: .leading)
            }
        }
    }
}
