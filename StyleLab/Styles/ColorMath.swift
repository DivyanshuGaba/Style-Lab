import SwiftUI

struct RGB: Equatable, Sendable {
    var r: Double, g: Double, b: Double   // 0...255
    init(r: Double, g: Double, b: Double) { self.r = r; self.g = g; self.b = b }
    init(hex: String) { self = ColorMath.parse(hex) ?? RGB(r: 0, g: 0, b: 0) }
    static let black = RGB(r: 0, g: 0, b: 0)
    static let white = RGB(r: 255, g: 255, b: 255)

    var hex: String {
        func c(_ v: Double) -> Int { max(0, min(255, Int(v.rounded()))) }
        return String(format: "#%02X%02X%02X", c(r), c(g), c(b))
    }
    var color: Color { Color(red: r / 255, green: g / 255, blue: b / 255) }
    func op(_ a: Double) -> Color { color.opacity(a) }
}

enum ColorMath {
    static func parse(_ hex: String) -> RGB? {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        return RGB(r: Double((v >> 16) & 255), g: Double((v >> 8) & 255), b: Double(v & 255))
    }

    static func linearize(_ v: Double) -> Double {
        let c = v / 255
        return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    static func luminance(_ c: RGB) -> Double {
        0.2126 * linearize(c.r) + 0.7152 * linearize(c.g) + 0.0722 * linearize(c.b)
    }

    static func contrast(_ a: RGB, _ b: RGB) -> Double {
        let l1 = luminance(a), l2 = luminance(b)
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }

    static func onColor(_ x: RGB) -> RGB {
        contrast(x, .black) >= contrast(x, .white) ? .black : .white
    }

    static func mix(_ a: RGB, _ b: RGB, _ t: Double) -> RGB {
        RGB(r: (a.r * (1 - t) + b.r * t).rounded(), g: (a.g * (1 - t) + b.g * t).rounded(), b: (a.b * (1 - t) + b.b * t).rounded())
    }

    static func ensure(_ a: RGB, _ bg: RGB, _ minRatio: Double) -> RGB {
        let target: RGB = luminance(bg) > 0.4 ? .black : .white
        var t = 0.0
        var c = a
        while contrast(c, bg) < minRatio && t < 1 {
            t += 0.1
            c = mix(a, target, t)
        }
        return c
    }

    /// Rotates hue in degrees, keeping saturation and lightness.
    static func rotateHue(_ c: RGB, _ degrees: Double) -> RGB {
        let r = c.r / 255, g = c.g / 255, b = c.b / 255
        let mx = max(r, g, b), mn = min(r, g, b), d = mx - mn
        let l = (mx + mn) / 2
        var h = 0.0, s = 0.0
        if d > 0 {
            s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn)
            if mx == r { h = (g - b) / d + (g < b ? 6 : 0) }
            else if mx == g { h = (b - r) / d + 2 } else { h = (r - g) / d + 4 }
            h *= 60
        }
        h = (h + degrees).truncatingRemainder(dividingBy: 360); if h < 0 { h += 360 }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q
        func f(_ t0: Double) -> Double {
            var t = t0; if t < 0 { t += 1 }; if t > 1 { t -= 1 }
            if t < 1.0 / 6 { return p + (q - p) * 6 * t }
            if t < 0.5 { return q }
            if t < 2.0 / 3 { return p + (q - p) * (2.0 / 3 - t) * 6 }
            return p
        }
        if s == 0 { return c }
        return RGB(r: (f(h / 360 + 1.0 / 3) * 255).rounded(), g: (f(h / 360) * 255).rounded(), b: (f(h / 360 - 1.0 / 3) * 255).rounded())
    }
}
