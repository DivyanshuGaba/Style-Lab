import SwiftUI

/// Shared look for the app's own interface (never the design being edited).
enum Chrome {
    static let indigo = Color(red: 0.141, green: 0.278, blue: 0.839)
    static let violet = Color(red: 0.45, green: 0.30, blue: 0.92)
    static var gradient: LinearGradient { LinearGradient(colors: [indigo, violet], startPoint: .topLeading, endPoint: .bottomTrailing) }
}

struct ChromeCardModifier: ViewModifier {
    var radius: CGFloat = 20
    func body(content: Content) -> some View {
        content.background {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
                .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5))
        }
    }
}
extension View {
    func chromeCard(radius: CGFloat = 20) -> some View { modifier(ChromeCardModifier(radius: radius)) }

    /// Soft color glows behind scrolling screens.
    func chromeBackground() -> some View {
        background {
            ZStack {
                Color(.systemGroupedBackground)
                RadialGradient(colors: [Chrome.indigo.opacity(0.22), Chrome.indigo.opacity(0)], center: UnitPoint(x: 0.1, y: 0), startRadius: 0, endRadius: 380)
                RadialGradient(colors: [Chrome.violet.opacity(0.18), Chrome.violet.opacity(0)], center: UnitPoint(x: 0.95, y: 0.04), startRadius: 0, endRadius: 340)
            }.ignoresSafeArea()
        }
    }
}

struct ChromePrimaryStyle: ButtonStyle {
    var compact = false
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .subheadline.weight(.bold) : .headline)
            .foregroundStyle(.white)
            .padding(.horizontal, compact ? 14 : 18).padding(.vertical, compact ? 7 : 4)
            .background(Chrome.gradient.opacity(enabled ? 1 : 0.4), in: RoundedRectangle(cornerRadius: compact ? 16 : 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
            .shadow(color: Chrome.indigo.opacity(enabled ? 0.35 : 0), radius: configuration.isPressed ? 4 : 12, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ChromeSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Chrome.indigo)
            .padding(.horizontal, 14)
            .background(Chrome.indigo.opacity(configuration.isPressed ? 0.2 : 0.11), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ChromeIconStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Chrome.indigo)
            .background(Chrome.indigo.opacity(configuration.isPressed ? 0.2 : 0.11), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.97 : 1).animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct FitRing: View {
    let percent: Int
    var body: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(0.1), lineWidth: 6)
            Circle().trim(from: 0, to: Double(percent) / 100).stroke(Chrome.gradient, style: StrokeStyle(lineWidth: 6, lineCap: .round)).rotationEffect(.degrees(-90))
            Text("\(percent)").font(.system(size: 15, weight: .bold, design: .rounded)).monospacedDigit()
        }
        .frame(width: 48, height: 48)
        .accessibilityElement(children: .ignore).accessibilityLabel("\(percent) percent fit")
    }
}

struct Badge: View {
    let text: String
    var icon: String? = nil
    var body: some View {
        HStack(spacing: 4) { if let icon { Image(systemName: icon) }; Text(text) }
            .font(.caption.weight(.bold)).foregroundStyle(.white)
            .padding(.horizontal, 9).padding(.vertical, 4).background(Chrome.gradient, in: Capsule())
    }
}

/// Cycling stack of live style previews used as the Discover hero.
struct HeroStack: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var i = 0
    private let order: [StyleID] = [.liquid, .brutal, .neon, .clay, .oled, .aurora, .skeu, .bento]
    private let timer = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()
    var body: some View {
        let spec = { (s: StyleID, dark: Bool) -> DesignSpec in var d = DesignSpec(); d.style = s; d.mode = dark ? .dark : .light; d.accentHex = Palette.accents[(order.firstIndex(of: s) ?? 0) % 6]; return d }
        ZStack {
            ForEach(0..<3, id: \.self) { k in
                let s = order[(i + k) % order.count]
                PreviewCanvas(spec: spec(s, [.neon, .oled, .aurora, .liquid].contains(s)), framed: true)
                    .frame(height: 300 - CGFloat(k) * 28)
                    .rotationEffect(.degrees(Double(k - 1) * 9))
                    .offset(x: CGFloat(k - 1) * 70, y: CGFloat(k) * 8)
                    .zIndex(Double(2 - k))
                    .opacity(1 - Double(k) * 0.12)
                    .id("\(s.rawValue)-\(k)")
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.9)), removal: .opacity))
            }
        }
        .frame(height: 320)
        .animation(reduceMotion ? nil : .spring(response: 0.7, dampingFraction: 0.8), value: i)
        .onReceive(timer) { _ in if !reduceMotion { i += 1 } }
        .accessibilityHidden(true)
    }
}
