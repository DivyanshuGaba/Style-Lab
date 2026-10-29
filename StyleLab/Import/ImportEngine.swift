import SwiftUI
import UIKit
import Vision

/// Raw RGBA pixels with a few sampling helpers.
struct PixelBuffer {
    let w: Int, h: Int
    var px: [UInt8]

    init?(_ cg: CGImage) {
        w = cg.width; h = cg.height
        px = [UInt8](repeating: 0, count: w * h * 4)
        let (cw, ch) = (w, h)
        let ok: Bool = px.withUnsafeMutableBytes { ptr in
            guard let ctx = CGContext(data: ptr.baseAddress, width: cw, height: ch, bitsPerComponent: 8, bytesPerRow: cw * 4,
                                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return false }
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cw, height: ch))
            return true
        }
        if !ok { return nil }
    }

    func at(_ x: Int, _ y: Int) -> RGB {
        let cx = min(max(x, 0), w - 1), cy = min(max(y, 0), h - 1)
        let i = (cy * w + cx) * 4
        return RGB(r: Double(px[i]), g: Double(px[i + 1]), b: Double(px[i + 2]))
    }

    mutating func fill(_ r: CGRect, _ c: RGB) {
        let x0 = max(0, Int(r.minX.rounded(.down))), x1 = min(w, Int(r.maxX.rounded(.up))), y0 = max(0, Int(r.minY.rounded(.down))), y1 = min(h, Int(r.maxY.rounded(.up)))
        guard x0 < x1, y0 < y1 else { return }
        let rr = UInt8(max(0, min(255, c.r.rounded()))), gg = UInt8(max(0, min(255, c.g.rounded()))), bb = UInt8(max(0, min(255, c.b.rounded())))
        for y in y0..<y1 { for x in x0..<x1 { let i = (y * w + x) * 4; px[i] = rr; px[i + 1] = gg; px[i + 2] = bb } }
    }

    /// Fills a box by blending the colors just left and right of it, row by row. Hides text on gradients.
    mutating func fillBlend(_ r: CGRect) {
        let x0 = max(0, Int(r.minX.rounded(.down))), x1 = min(w, Int(r.maxX.rounded(.up))), y0 = max(0, Int(r.minY.rounded(.down))), y1 = min(h, Int(r.maxY.rounded(.up)))
        guard x0 < x1, y0 < y1 else { return }
        for y in y0..<y1 {
            let l = at(x0 - 3, y), rr = at(x1 + 2, y)
            for x in x0..<x1 {
                let t = Double(x - x0) / Double(max(1, x1 - x0 - 1))
                let i = (y * w + x) * 4
                px[i] = UInt8(max(0, min(255, l.r * (1 - t) + rr.r * t))); px[i + 1] = UInt8(max(0, min(255, l.g * (1 - t) + rr.g * t))); px[i + 2] = UInt8(max(0, min(255, l.b * (1 - t) + rr.b * t)))
            }
        }
    }

    func cgImage() -> CGImage? {
        let data = Data(px)
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue), provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

    func lum(_ x: Int, _ y: Int) -> Double { let c = at(x, y); return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b }

    private func median(_ v: [Double]) -> Double { v.isEmpty ? 0 : v.sorted()[v.count / 2] }

    /// Median color of a thin ring just outside the rect, which is a good guess for what was behind it.
    func ring(_ r: CGRect, pad: Int = 3) -> RGB {
        var rs: [Double] = [], gs: [Double] = [], bs: [Double] = []
        func add(_ x: Int, _ y: Int) { let c = at(x, y); rs.append(c.r); gs.append(c.g); bs.append(c.b) }
        let n = 14
        for i in 0...n {
            let fx = Int(r.minX + r.width * Double(i) / Double(n)), fy = Int(r.minY + r.height * Double(i) / Double(n))
            add(fx, Int(r.minY) - pad); add(fx, Int(r.maxY) + pad)
            add(Int(r.minX) - pad, fy); add(Int(r.maxX) + pad, fy)
        }
        return RGB(r: median(rs), g: median(gs), b: median(bs))
    }

    func average(_ r: CGRect) -> RGB {
        var sr = 0.0, sg = 0.0, sb = 0.0, n = 0.0
        let stepX = max(1, Int(r.width) / 10), stepY = max(1, Int(r.height) / 10)
        var y = Int(r.minY)
        while y < Int(r.maxY) { var x = Int(r.minX); while x < Int(r.maxX) { let c = at(x, y); sr += c.r; sg += c.g; sb += c.b; n += 1; x += stepX }; y += stepY }
        return n == 0 ? at(Int(r.midX), Int(r.midY)) : RGB(r: sr / n, g: sg / n, b: sb / n)
    }

    /// The ink color of a text box: the mean of the pixels that differ most from the background.
    func inkColor(_ r: CGRect, bg: RGB) -> RGB {
        var samples: [(Double, RGB)] = []
        let stepX = max(1, Int(r.width) / 30), stepY = max(1, Int(r.height) / 12)
        var y = Int(r.minY)
        while y < Int(r.maxY) { var x = Int(r.minX); while x < Int(r.maxX) { let c = at(x, y); samples.append((abs(c.r - bg.r) + abs(c.g - bg.g) + abs(c.b - bg.b), c)); x += stepX }; y += stepY }
        guard !samples.isEmpty else { return .black }
        let top = samples.sorted { $0.0 > $1.0 }.prefix(max(1, samples.count / 8))
        let n = Double(top.count)
        return RGB(r: top.reduce(0) { $0 + $1.1.r } / n, g: top.reduce(0) { $0 + $1.1.g } / n, b: top.reduce(0) { $0 + $1.1.b } / n)
    }

    /// Largest per channel standard deviation over a sparse grid, skipping the given holes.
    func flatness(_ r: CGRect, holes: [CGRect]) -> Double? {
        var vals: [RGB] = []
        let n = 14
        for i in 0..<n { for j in 0..<n {
            let p = CGPoint(x: r.minX + 3 + (r.width - 6) * (Double(i) + 0.5) / Double(n), y: r.minY + 3 + (r.height - 6) * (Double(j) + 0.5) / Double(n))
            if holes.contains(where: { $0.insetBy(dx: -3, dy: -3).contains(p) }) { continue }
            vals.append(at(Int(p.x), Int(p.y)))
        } }
        guard vals.count >= 20 else { return nil }
        func sd(_ f: (RGB) -> Double) -> Double { let m = vals.reduce(0) { $0 + f($1) } / Double(vals.count); return sqrt(vals.reduce(0) { $0 + pow(f($1) - m, 2) } / Double(vals.count)) }
        return max(sd { $0.r }, sd { $0.g }, sd { $0.b })
    }
}

struct ImportResult: @unchecked Sendable {
    var screen: ImportedScreen
    var plate: Data
    var original: Data
    var crops: [(file: String, data: Data)]
}

enum ImportEngine {
    struct Failure: LocalizedError { let message: String; var errorDescription: String? { message } }

    /// Upright pixels, at most 2400 on the long side.
    static func normalize(_ image: UIImage) -> (UIImage, PixelBuffer)? {
        let longSide = max(image.size.width * image.scale, image.size.height * image.scale)
        let f = min(1, 2400 / longSide)
        let size = CGSize(width: (image.size.width * image.scale * f).rounded(), height: (image.size.height * image.scale * f).rounded())
        let fmt = UIGraphicsImageRendererFormat(); fmt.scale = 1; fmt.opaque = true
        let norm = UIGraphicsImageRenderer(size: size, format: fmt).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        guard let cg = norm.cgImage, let buf = PixelBuffer(cg) else { return nil }
        return (norm, buf)
    }

    private struct Region {
        var id: Int32
        var area = 0
        var minX = Int.max, maxX = 0, minY = Int.max, maxY = 0
        var sum = (0, 0, 0)
        var seed = (0, 0, 0)
        var w: Int { maxX - minX + 1 }
        var h: Int { maxY - minY + 1 }
        var mean: RGB { RGB(r: Double(sum.0) / Double(max(area, 1)), g: Double(sum.1) / Double(max(area, 1)), b: Double(sum.2) / Double(max(area, 1))) }
    }

    /// Splits a screenshot into layers: text (on device OCR), flat colored shapes, and everything else as cut out pictures.
    static func analyze(_ image: UIImage, name: String) throws -> ImportResult {
        guard let (norm, buf0) = normalize(image) else { throw Failure(message: "The image could not be read.") }
        var buf = buf0
        let W = Double(buf.w), H = Double(buf.h)
        let s = min(390 / W, 844 / H)                    // points per pixel
        let g = max(1, Int((1 / s).rounded()))           // one grid cell is about one point
        let GW = buf.w / g, GH = buf.h / g
        guard GW > 20, GH > 20, let cg = norm.cgImage else { throw Failure(message: "The image is too small.") }

        // 1. Text with Vision's on device recognizer
        struct TextBox { var rect: CGRect; var text: String }
        var texts: [TextBox] = []
        let treq = VNRecognizeTextRequest()
        treq.recognitionLevel = .accurate; treq.usesLanguageCorrection = true
        try VNImageRequestHandler(cgImage: cg, options: [:]).perform([treq])
        for o in treq.results ?? [] {
            guard let c = o.topCandidates(1).first, c.confidence > 0.3, !c.string.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            let b = o.boundingBox
            texts.append(TextBox(rect: CGRect(x: b.minX * W, y: (1 - b.maxY) * H, width: b.width * W, height: b.height * H), text: c.string))
        }
        let textRects = texts.map(\.rect)

        // 2. A copy without the text, used for sampling and cutting pictures
        var clean = buf
        for r in textRects { clean.fillBlend(r.insetBy(dx: -2, dy: -2)) }

        // 3. One color per cell
        var cr = [UInt8](repeating: 0, count: GW * GH * 3)
        for y in 0..<GH { for x in 0..<GW {
            var sr = 0, sg = 0, sb = 0, n = 0
            let step = max(1, g / 2)
            var yy = 0
            while yy < g { var xx = 0; while xx < g { let i = ((y * g + yy) * clean.w + (x * g + xx)) * 4; sr += Int(clean.px[i]); sg += Int(clean.px[i + 1]); sb += Int(clean.px[i + 2]); n += 1; xx += step }; yy += step }
            let o = (y * GW + x) * 3
            cr[o] = UInt8(sr / n); cr[o + 1] = UInt8(sg / n); cr[o + 2] = UInt8(sb / n)
        } }
        // text cells are barriers (-2); we already painted them out of `clean`, so they simply join the surrounding region
        var label = [Int32](repeating: -1, count: GW * GH)

        // 4. Flat color regions by flood fill
        let tol = 10
        var regions: [Region] = []
        var stack: [Int] = []
        for start in 0..<(GW * GH) where label[start] == -1 {
            let id = Int32(regions.count)
            var reg = Region(id: id)
            let so = start * 3
            reg.seed = (Int(cr[so]), Int(cr[so + 1]), Int(cr[so + 2]))
            stack.append(start); label[start] = id
            while let i = stack.popLast() {
                let x = i % GW, y = i / GW, o = i * 3
                reg.area += 1
                reg.minX = min(reg.minX, x); reg.maxX = max(reg.maxX, x); reg.minY = min(reg.minY, y); reg.maxY = max(reg.maxY, y)
                reg.sum.0 += Int(cr[o]); reg.sum.1 += Int(cr[o + 1]); reg.sum.2 += Int(cr[o + 2])
                for (nx, ny) in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)] where nx >= 0 && nx < GW && ny >= 0 && ny < GH {
                    let j = ny * GW + nx
                    if label[j] == -1 {
                        let p = j * 3
                        if abs(Int(cr[p]) - reg.seed.0) <= tol && abs(Int(cr[p + 1]) - reg.seed.1) <= tol && abs(Int(cr[p + 2]) - reg.seed.2) <= tol {
                            label[j] = id; stack.append(j)
                        }
                    }
                }
            }
            regions.append(reg)
        }

        // 5. Page color: the biggest region
        guard let bgRegion = regions.max(by: { $0.area < $1.area }) else { throw Failure(message: "Nothing found.") }
        let page = bgRegion.mean
        func nearPage(_ c: RGB) -> Bool { abs(c.r - page.r) <= 10 && abs(c.g - page.g) <= 10 && abs(c.b - page.b) <= 10 }

        func tooBig(_ r: CGRect) -> Bool { Double(r.width * r.height) > 0.45 * W * H || (Double(r.width) > 0.92 * W && Double(r.height) > 0.3 * H) }

        // 5b. Gradients and textured areas: many neighboring regions with similar colors become one picture
        var parent = Array(0..<regions.count)
        func find(_ x: Int) -> Int { var r = x; while parent[r] != r { parent[r] = parent[parent[r]]; r = parent[r] }; return r }
        func eligible(_ r: Region) -> Bool { r.id != bgRegion.id && !nearPage(r.mean) && r.area >= 6 }
        var edgeCount: [Int: Int] = [:]
        for y in 0..<GH { for x in 0..<GW {
            let a = Int(label[y * GW + x])
            if x + 1 < GW { let b = Int(label[y * GW + x + 1]); if a != b { edgeCount[min(a, b) * regions.count + max(a, b), default: 0] += 1 } }
            if y + 1 < GH { let b = Int(label[(y + 1) * GW + x]); if a != b { edgeCount[min(a, b) * regions.count + max(a, b), default: 0] += 1 } }
        } }
        for (k, n) in edgeCount where n >= 4 {
            let a = k / regions.count, b = k % regions.count
            guard eligible(regions[a]), eligible(regions[b]) else { continue }
            let ma = regions[a].mean, mb = regions[b].mean
            if max(abs(ma.r - mb.r), abs(ma.g - mb.g), abs(ma.b - mb.b)) <= 26 { parent[find(a)] = find(b) }
        }
        var members: [Int: [Int]] = [:]
        for r in regions where eligible(r) { members[find(Int(r.id)), default: []].append(Int(r.id)) }
        var groupRoot = [Int32: Int](); var groupRect: [Int: CGRect] = [:]
        for (root, ids) in members where ids.count >= 4 && ids.reduce(0, { $0 + regions[$1].area }) >= 80 {
            var minX = Int.max, maxX = 0, minY = Int.max, maxY = 0
            for i in ids { let r = regions[i]; minX = min(minX, r.minX); maxX = max(maxX, r.maxX); minY = min(minY, r.minY); maxY = max(maxY, r.maxY) }
            let rect = CGRect(x: Double(minX * g), y: Double(minY * g), width: Double((maxX - minX + 1) * g), height: Double((maxY - minY + 1) * g))
            // page sized gradients or textures are the background, not something to move
            if tooBig(rect) { continue }
            for i in ids { groupRoot[Int32(i)] = root }
            groupRect[root] = rect
        }

        // 6. Accept flat regions as shapes
        struct Shape { var rect: CGRect; var fill: RGB; var radius: Double; var silhouette: Bool; var id: Int32 }
        var shapes: [Shape] = []
        var accepted = Set<Int32>()
        var background = Set<Int32>([bgRegion.id])
        for r in regions.sorted(by: { $0.area > $1.area }) {
            if r.id == bgRegion.id { continue }
            let mean = r.mean
            if nearPage(mean) { background.insert(r.id); continue }
            if groupRoot[r.id] != nil { continue }
            guard r.area >= 60, r.w >= 6, r.h >= 6, shapes.count < 120 else { continue }
            let rect = CGRect(x: Double(r.minX * g), y: Double(r.minY * g), width: Double(r.w * g), height: Double(r.h * g))
            if tooBig(rect) { background.insert(r.id); continue }
            // thin bands with little contrast are slices of a gradient, not shapes
            if min(r.w, r.h) < 8 {
                let outside = clean.ring(rect, pad: 3)
                if abs(outside.r - mean.r) <= 18 && abs(outside.g - mean.g) <= 18 && abs(outside.b - mean.b) <= 18 { continue }
            }
            // silhouette: per row extent of the region
            var sil = 0
            for y in r.minY...r.maxY {
                var lo = Int.max, hi = -1
                for x in r.minX...r.maxX where label[y * GW + x] == r.id { lo = min(lo, x); hi = max(hi, x) }
                if hi >= lo { sil += hi - lo + 1 }
            }
            let ratio = Double(sil) / Double(r.w * r.h)
            // corner radius from the diagonal through the top left corner
            var k = 0
            while k < min(r.w, r.h) / 2, label[(r.minY + k) * GW + (r.minX + k)] != r.id { k += 1 }
            let radiusCells = min(Double(k) / 0.293, Double(min(r.w, r.h)) / 2)
            shapes.append(Shape(rect: rect, fill: mean, radius: radiusCells * Double(g), silhouette: ratio < 0.62, id: r.id))
            accepted.insert(r.id)
        }

        // 7. Everything else becomes pictures. Mark leftover cells, grow them a little, then group.
        var left = [Bool](repeating: false, count: GW * GH)
        for i in 0..<(GW * GH) { let l = label[i]; left[i] = !accepted.contains(l) && !background.contains(l) && groupRoot[l] == nil }
        var dil = left
        for y in 0..<GH { for x in 0..<GW where left[y * GW + x] {
            for dy in -2...2 { for dx in -2...2 { let nx = x + dx, ny = y + dy; if nx >= 0, nx < GW, ny >= 0, ny < GH { dil[ny * GW + nx] = true } } }
        } }
        struct Pic { var rect: CGRect; var cells: Int }
        var pics: [Pic] = []
        var seen = [Bool](repeating: false, count: GW * GH)
        for start in 0..<(GW * GH) where dil[start] && !seen[start] {
            var minX = GW, maxX = 0, minY = GH, maxY = 0, count = 0
            var cells: [Int] = []
            stack.append(start); seen[start] = true
            while let i = stack.popLast() {
                let x = i % GW, y = i / GW
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
                if left[i] { count += 1; cells.append(i) }
                for (nx, ny) in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)] where nx >= 0 && nx < GW && ny >= 0 && ny < GH {
                    let j = ny * GW + nx
                    if dil[j] && !seen[j] { seen[j] = true; stack.append(j) }
                }
            }
            let x0 = minX + 2, x1 = maxX - 2, y0 = minY + 2, y1 = maxY - 2
            guard x1 - x0 + 1 >= 8, y1 - y0 + 1 >= 8, count >= 30 else { continue }
            let rect = CGRect(x: Double(x0 * g), y: Double(y0 * g), width: Double((x1 - x0 + 1) * g), height: Double((y1 - y0 + 1) * g))
            if tooBig(rect) { continue }
            // ignore faint halos such as shadows
            let ring = clean.ring(rect, pad: 3)
            var dev = 0.0, maxDev = 0.0
            for c in cells.prefix(600) {
                let o = c * 3
                let d = max(abs(Double(cr[o]) - ring.r), abs(Double(cr[o + 1]) - ring.g), abs(Double(cr[o + 2]) - ring.b))
                dev += d; maxDev = max(maxDev, d)
            }
            dev /= Double(min(cells.count, 600))
            guard dev >= 14 || maxDev >= 60 else { continue }
            pics.append(Pic(rect: rect, cells: count))
        }
        // a piece that sits inside a bigger piece is part of it
        pics = pics.filter { a in !pics.contains { b in b.rect != a.rect && b.rect.insetBy(dx: -2, dy: -2).contains(a.rect) } }
        pics = Array(pics.sorted { ($0.rect.minY, $0.rect.minX) < ($1.rect.minY, $1.rect.minX) }.prefix(60))

        // 8. Cut the pictures and silhouettes out of the clean image
        var crops: [(String, Data)] = []
        var els: [ImportedElement] = []
        for (i, sh) in shapes.sorted(by: { $0.rect.width * $0.rect.height > $1.rect.width * $1.rect.height }).enumerated() {
            if sh.silhouette {
                if let data = cropSilhouette(clean, rect: sh.rect, label: label, GW: GW, g: g, member: { $0 == sh.id }) {
                    let file = "s\(i).png"; crops.append((file, data))
                    els.append(ImportedElement(id: "m\(i)", kind: .image, x: sh.rect.minX * s, y: sh.rect.minY * s, w: sh.rect.width * s, h: sh.rect.height * s, file: file))
                }
            } else {
                els.append(ImportedElement(id: "s\(i)", kind: .shape, x: sh.rect.minX * s, y: sh.rect.minY * s, w: sh.rect.width * s, h: sh.rect.height * s,
                                           colorHex: sh.fill.hex, radius: (sh.radius * s * 10).rounded() / 10))
            }
        }
        for (n, (root, rect)) in groupRect.sorted(by: { $0.key < $1.key }).enumerated() {
            if let data = cropSilhouette(clean, rect: rect, label: label, GW: GW, g: g, member: { groupRoot[$0] == root }) {
                let file = "g\(n).png"; crops.append((file, data))
                els.append(ImportedElement(id: "g\(n)", kind: .image, x: rect.minX * s, y: rect.minY * s, w: rect.width * s, h: rect.height * s, file: file))
            }
        }
        for (i, p) in pics.enumerated() {
            let wpt = Double(p.rect.width) * s, hpt = Double(p.rect.height) * s
            let opaque = wpt >= 56 && hpt >= 56
            let rr = p.rect.insetBy(dx: -2, dy: -2)
            if let data = cropPNG(clean, rr, opaque: opaque) {
                let file = "c\(i).png"; crops.append((file, data))
                els.append(ImportedElement(id: "i\(i)", kind: .image, x: rr.minX * s, y: rr.minY * s, w: rr.width * s, h: rr.height * s, file: file))
            }
        }
        let meas = UIFont.systemFont(ofSize: 17)
        for (i, t) in texts.enumerated() {
            let bg = buf.ring(t.rect, pad: 3)
            let ink = buf.inkColor(t.rect, bg: bg)
            let mw = (t.text as NSString).size(withAttributes: [.font: meas]).width
            let fsH = t.rect.height / 1.15
            let fsW = mw > 0 ? 17 * t.rect.width / mw : fsH
            let fsPx = min(max(fsW, fsH * 0.7), fsH * 1.25)
            let fs = max(8, (fsPx * s * 10).rounded() / 10)
            let lineH = fs * 1.2
            els.append(ImportedElement(id: "t\(i)", kind: .text, x: t.rect.minX * s, y: t.rect.midY * s - lineH / 2, w: t.rect.width * s, h: lineH,
                                       text: t.text, fontSize: fs, weight: guessWeight(buf, t.rect, text: t.text, fontPx: fsPx, bg: bg, ink: ink), colorHex: ink.hex))
        }
        for i in els.indices {
            els[i].x = (els[i].x * 10).rounded() / 10; els[i].y = (els[i].y * 10).rounded() / 10
            els[i].w = (els[i].w * 10).rounded() / 10; els[i].h = (els[i].h * 10).rounded() / 10
        }

        // 9. Background layer: the page color plus whatever was left (shadows, hairlines), with extracted areas painted over
        var plate = clean
        for p in pics { plate.fill(p.rect.insetBy(dx: -2, dy: -2), clean.ring(p.rect, pad: 3)) }
        for rect in groupRect.values { plate.fill(rect.insetBy(dx: -1, dy: -1), clean.ring(rect, pad: 4)) }
        for sh in shapes.sorted(by: { $0.rect.width * $0.rect.height < $1.rect.width * $1.rect.height }) {
            plate.fill(sh.rect.insetBy(dx: -1, dy: -1), clean.ring(sh.rect, pad: 4))
        }
        buf = clean   // silence unused warning for the mutable original
        var screen = ImportedScreen()
        screen.name = name; screen.bgHex = page.hex
        screen.canvasW = (W * s * 10).rounded() / 10; screen.canvasH = (H * s * 10).rounded() / 10
        screen.pixelW = Int(W); screen.pixelH = Int(H); screen.elements = els
        guard let plateCG = plate.cgImage(), let plateData = UIImage(cgImage: plateCG).jpegData(compressionQuality: 0.92),
              let original = norm.jpegData(compressionQuality: 0.9) else { throw Failure(message: "The image could not be saved.") }
        return ImportResult(screen: screen, plate: plateData, original: original, crops: crops)
    }

    // MARK: cutting

    /// Turns a rectangle the person drew into a picture layer and paints it out of the background layer.
    static func cutRegion(plate plateData: Data, screen: ImportedScreen, rectPt: CGRect) -> (crop: Data, newPlate: Data, element: ImportedElement)? {
        guard let img = UIImage(data: plateData), let cg = img.cgImage, var plate = PixelBuffer(cg) else { return nil }
        let s = screen.canvasW / Double(plate.w)
        let px = CGRect(x: rectPt.minX / s, y: rectPt.minY / s, width: rectPt.width / s, height: rectPt.height / s)
            .intersection(CGRect(x: 0, y: 0, width: Double(plate.w), height: Double(plate.h))).integral
        guard px.width >= 6, px.height >= 6 else { return nil }
        let opaque = px.width * s >= 56 && px.height * s >= 56
        guard let crop = cropPNG(plate, px, opaque: opaque) else { return nil }
        plate.fill(px, plate.ring(px, pad: 3))
        guard let newCG = plate.cgImage(), let newData = UIImage(cgImage: newCG).jpegData(compressionQuality: 0.92) else { return nil }
        let id = "u" + String(UUID().uuidString.prefix(6))
        let el = ImportedElement(id: id, kind: .image, x: (px.minX * s * 10).rounded() / 10, y: (px.minY * s * 10).rounded() / 10,
                                 w: (px.width * s * 10).rounded() / 10, h: (px.height * s * 10).rounded() / 10, file: id + ".png")
        return (crop, newData, el)
    }

    /// Uses Apple's on device subject segmentation to remove everything but the main subject of a picture.
    static func cutOutSubject(_ data: Data) -> Data? {
        guard let ui = UIImage(data: data), let cg = ui.cgImage else { return nil }
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        let req = VNGenerateForegroundInstanceMaskRequest()
        do {
            try handler.perform([req])
            guard let result = req.results?.first, !result.allInstances.isEmpty else { return nil }
            let buffer = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: false)
            let ci = CIImage(cvPixelBuffer: buffer)
            guard let out = CIContext().createCGImage(ci, from: ci.extent) else { return nil }
            return UIImage(cgImage: out).pngData()
        } catch { return nil }
    }

    // MARK: helpers

    /// Compares how much of the text box is covered by ink with how much regular, bold and heavy renderings cover.
    private static func guessWeight(_ buf: PixelBuffer, _ r: CGRect, text: String, fontPx: Double, bg: RGB, ink: RGB) -> ElementWeight {
        let full = abs(ink.r - bg.r) + abs(ink.g - bg.g) + abs(ink.b - bg.b)
        guard full > 60, r.width > 8, r.height > 6 else { return .regular }
        var hit = 0, total = 0
        let stepX = max(1, Int(r.width) / 80), stepY = max(1, Int(r.height) / 24)
        var y = Int(r.minY)
        while y < Int(r.maxY) { var x = Int(r.minX); while x < Int(r.maxX) {
            let c = buf.at(x, y)
            if abs(c.r - bg.r) + abs(c.g - bg.g) + abs(c.b - bg.b) > full * 0.5 { hit += 1 }
            total += 1; x += stepX }; y += stepY }
        guard total > 0 else { return .regular }
        let actual = Double(hit) / Double(total)
        let size = CGSize(width: max(8, r.width), height: max(8, r.height))
        let fmt = UIGraphicsImageRendererFormat(); fmt.scale = 1; fmt.opaque = true
        var best: (ElementWeight, Double) = (.regular, .infinity)
        for (w, fw) in [(ElementWeight.regular, UIFont.Weight.regular), (.bold, .semibold), (.heavy, .heavy)] {
            let img = UIGraphicsImageRenderer(size: size, format: fmt).image { ctx in
                UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
                (text as NSString).draw(at: CGPoint(x: 0, y: (size.height - fontPx * 1.2) / 2), withAttributes: [.font: UIFont.systemFont(ofSize: fontPx, weight: fw), .foregroundColor: UIColor.black])
            }
            guard let cg = img.cgImage, let pb = PixelBuffer(cg) else { continue }
            var h2 = 0, t2 = 0
            var yy = 0
            while yy < pb.h { var xx = 0; while xx < pb.w { if pb.lum(xx, yy) < 128 { h2 += 1 }; t2 += 1; xx += stepX }; yy += stepY }
            let cov = t2 > 0 ? Double(h2) / Double(t2) : 0
            if abs(cov - actual) < best.1 { best = (w, abs(cov - actual)) }
        }
        return best.0
    }

    /// Crops a region to a PNG. Unless `opaque`, a flat surround is made transparent so a glyph can be moved and tinted alone.
    static func cropPNG(_ buf: PixelBuffer, _ r0: CGRect, opaque: Bool) -> Data? {
        let r = r0.intersection(CGRect(x: 0, y: 0, width: buf.w, height: buf.h)).integral
        guard r.width >= 4, r.height >= 4 else { return nil }
        let bg = buf.ring(r, pad: 2)
        let flat = buf.flatness(r.insetBy(dx: -4, dy: -4), holes: [r.insetBy(dx: 3, dy: 3)]) ?? 99
        let useAlpha = !opaque && flat < 18
        let w = Int(r.width), h = Int(r.height)
        var out = [UInt8](repeating: 0, count: w * h * 4)
        for y in 0..<h { for x in 0..<w {
            let c = buf.at(Int(r.minX) + x, Int(r.minY) + y)
            var a = 1.0
            if useAlpha {
                let d = abs(c.r - bg.r) + abs(c.g - bg.g) + abs(c.b - bg.b)
                a = min(1, max(0, (d - 20) / 70)); if a < 0.02 { a = 0 }
            }
            let i = (y * w + x) * 4
            out[i] = UInt8(c.r * a); out[i + 1] = UInt8(c.g * a); out[i + 2] = UInt8(c.b * a); out[i + 3] = UInt8(a * 255)
        } }
        return pngFromRGBA(out, w, h)
    }

    /// Crops the exact outline of a flat region (circles, blobs, chevrons) with a transparent outside.
    private static func cropSilhouette(_ buf: PixelBuffer, rect: CGRect, label: [Int32], GW: Int, g: Int, member: (Int32) -> Bool) -> Data? {
        let r = rect.intersection(CGRect(x: 0, y: 0, width: buf.w, height: buf.h)).integral
        guard r.width >= 4, r.height >= 4 else { return nil }
        let w = Int(r.width), h = Int(r.height)
        var out = [UInt8](repeating: 0, count: w * h * 4)
        // row extents in pixels
        for y in 0..<h {
            let cy = (Int(r.minY) + y) / g
            var lo = Int.max, hi = -1
            for cx in (Int(r.minX) / g)...min(GW - 1, (Int(r.maxX) - 1) / g) where cy * GW + cx < label.count && member(label[cy * GW + cx]) { lo = min(lo, cx); hi = max(hi, cx) }
            guard hi >= lo else { continue }
            for x in 0..<w {
                let cx = (Int(r.minX) + x) / g
                guard cx >= lo, cx <= hi else { continue }
                let c = buf.at(Int(r.minX) + x, Int(r.minY) + y)
                let i = (y * w + x) * 4
                out[i] = UInt8(c.r); out[i + 1] = UInt8(c.g); out[i + 2] = UInt8(c.b); out[i + 3] = 255
            }
        }
        return pngFromRGBA(out, w, h)
    }

    private static func pngFromRGBA(_ bytes: [UInt8], _ w: Int, _ h: Int) -> Data? {
        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let cg = CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        else { return nil }
        return UIImage(cgImage: cg).pngData()
    }
}

extension Color {
    var cgColorValue: CGColor { UIColor(self).cgColor }
}
