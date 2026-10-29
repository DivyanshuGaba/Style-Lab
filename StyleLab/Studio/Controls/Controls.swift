import SwiftUI

struct StyleControls: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        sectionBox("Appearance") {
            Picker("Mode", selection: model.binding(\.mode)) { Text("Light").tag(AppearanceMode.light); Text("Dark").tag(AppearanceMode.dark) }.pickerStyle(.segmented)
        }
        sectionBox("Style") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(StyleID.allCases) { s in
                        Button { model.useStyle(s, openStudio: false) } label: {
                            VStack(spacing: 4) {
                                PreviewCanvas(spec: model.spec.with(style: s).withoutLayoutEdits).frame(height: 150)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor, lineWidth: model.spec.style == s ? 3 : 0))
                                Text(StyleCatalog.info(s).shortLabel).font(.caption.weight(model.spec.style == s ? .bold : .regular)).foregroundStyle(.primary)
                            }
                        }.buttonStyle(.plain).accessibilityLabel(StyleCatalog.info(s).name).accessibilityAddTraits(model.spec.style == s ? .isSelected : [])
                    }
                }
            }
        }
    }
}

struct ColorControls: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let t = StyleTokens.make(model.spec)
        let accent = RGB(hex: model.spec.accentHex)
        sectionBox("Accent") {
            HStack {
                ForEach(Palette.accents, id: \.self) { hex in
                    Button { model.update { $0.accentHex = hex }; Haptics.select() } label: {
                        Circle().fill(RGB(hex: hex).color).frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.primary, lineWidth: model.spec.accentHex.uppercased() == hex ? 3 : 0).padding(-3))
                            .frame(minWidth: 44, minHeight: 44)
                    }.buttonStyle(.plain).accessibilityLabel("Accent \(hex)").accessibilityAddTraits(model.spec.accentHex.uppercased() == hex ? .isSelected : [])
                }
            }
            ColorPicker("Custom color", selection: Binding(
                get: { accent.color },
                set: { c in
                    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                    UIColor(c).getRed(&r, green: &g, blue: &b, alpha: &a)
                    let hex = RGB(r: Double(r) * 255, g: Double(g) * 255, b: Double(b) * 255).hex
                    model.update(key: "accent") { $0.accentHex = hex }
                }), supportsOpacity: false).frame(minHeight: 44)
            let ratio = ColorMath.contrast(accent, t.surfaceEstimate)
            Text("Accent \(model.spec.accentHex.uppercased()) on the surface: \(String(format: "%.1f", ratio)):1 \(ratio >= 3 ? "(Pass for icons)" : "(Low for icons)")").font(.footnote).foregroundStyle(.secondary)
        }
        sectionBox("Harmony") {
            HStack {
                harmony("Complementary", 180); harmony("Analogous", 30); harmony("Triadic", 120)
            }
        }
        sectionBox("Palette") {
            let items: [(String, String)] = [("Background", t.backgroundText), ("Surface", t.surface), ("Text", t.text.hex), ("Secondary", t.secondary.hex), ("Icon accent", t.accentAdjusted.hex)]
            ForEach(items, id: \.0) { item in
                Button { UIPasteboard.general.string = item.1; Haptics.success() } label: {
                    HStack { Text(item.0); Spacer(); Text(item.1).font(.footnote.monospaced()).foregroundStyle(.secondary).multilineTextAlignment(.trailing); Image(systemName: "doc.on.doc").font(.footnote) }.frame(minHeight: 44)
                }.buttonStyle(.plain)
            }
        }
    }
    private func harmony(_ title: String, _ deg: Double) -> some View {
        Button { let c = ColorMath.rotateHue(RGB(hex: model.spec.accentHex), deg); model.update { $0.accentHex = c.hex }; Haptics.select() } label: {
            Text(title).font(.footnote).frame(maxWidth: .infinity).frame(minHeight: 44)
        }.buttonStyle(ChromeSecondaryStyle())
    }
}

private extension StyleTokens { var surface: String { surfaceText } }

struct ShapeControls: View {
    @Environment(AppModel.self) private var model
    private var depthLabel: String {
        switch model.spec.style {
        case .ios, .neu: "Shadow depth"
        case .liquid, .glass: "Blur and glass"
        case .neon, .aurora, .oled: "Glow"
        case .brutal: "Hard shadow"
        default: "Depth"
        }
    }
    /// A slider binding that clicks to its default value and ticks when it gets there.
    private func detent(_ kp: WritableKeyPath<DesignSpec, Double>, key: String, at def: Double, tol: Double) -> Binding<Double> {
        Binding(get: { model.spec[keyPath: kp] }, set: { v in
            var nv = v
            if abs(v - def) < tol { nv = def; if model.spec[keyPath: kp] != def { Haptics.snap() } }
            model.update(key: key) { $0[keyPath: kp] = nv }
        })
    }
    var body: some View {
        let t = StyleTokens.make(model.spec)
        sectionBox("Corner roundness") {
            HStack { Text("Corners"); Spacer(); Text("\(String(format: "%.2f", model.spec.radiusScale))x, card \(fmt(t.cardRadius)) pt").monospacedDigit().foregroundStyle(.secondary) }
            Slider(value: detent(\.radiusScale, key: "radius", at: 1.0, tol: 0.03), in: 0.3...1.6).frame(minHeight: 44)
                .accessibilityLabel("Corner roundness").accessibilityValue("\(String(format: "%.2f", model.spec.radiusScale)) times")
        }
        sectionBox(depthLabel) {
            HStack { Text(depthLabel); Spacer(); Text("\(Int((model.spec.depth * 100).rounded())) percent").monospacedDigit().foregroundStyle(.secondary) }
            Slider(value: detent(\.depth, key: "depth", at: 0.6, tol: 0.02), in: 0...1).frame(minHeight: 44)
                .accessibilityLabel(depthLabel).accessibilityValue("\(Int((model.spec.depth * 100).rounded())) percent")
        }
    }
}

struct TypeControls: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let t = StyleTokens.make(model.spec)
        sectionBox("Typeface") {
            Picker("Typeface", selection: model.binding(\.typeface)) { ForEach(Typeface.allCases, id: \.self) { Text($0.title).tag($0) } }.pickerStyle(.menu)
            Text("The quick brown fox").font(t.font(.title)).foregroundStyle(.primary)
            Text(t.typefaceName).font(.footnote).foregroundStyle(.secondary)
        }
        sectionBox("Text size preview") {
            Text("This line follows your Dynamic Type setting.").font(.body)
            Text("The preview itself is a fixed size sample.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

struct IconControls: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        let t = StyleTokens.make(model.spec)
        sectionBox("Icon weight") {
            Picker("Weight", selection: model.binding(\.iconWeight)) { ForEach(IconWeight.allCases, id: \.self) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
            Text("Stroke \(fmt(t.strokeWidth)) pt").font(.footnote).foregroundStyle(.secondary)
        }
        sectionBox("Main icons at 24 pt") {
            ZStack {
                BackgroundView(spec: t.background).clipShape(RoundedRectangle(cornerRadius: 12))
                HStack(spacing: 8) {
                    ForEach(Array(Sample.mainIcons.enumerated()), id: \.offset) { i, name in
                        Image(systemName: name).font(t.iconFont(24)).foregroundStyle(t.tileIconColor(i)).frame(width: 44, height: 44).surface(t.tileForIndex(i))
                    }
                }.padding(10)
            }
            .environment(\.colorScheme, model.spec.mode == .dark ? .dark : .light)
        }
    }
}

struct LayoutControls: View {
    @Environment(AppModel.self) private var model
    var body: some View {
        sectionBox("Density") {
            Picker("Density", selection: model.binding(\.density)) { ForEach(Density.allCases, id: \.self) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
        }
        sectionBox("Bottom bar") {
            Label("The same liquid glass bar in every design", systemImage: "capsule.portrait")
                .font(.subheadline.weight(.semibold))
            Text("A floating glass capsule with a pill behind the selected tab. It is identical in all styles and is always described in the export. You can still hide it, move it or recolor it with Edit.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        sectionBox("Content") {
            Toggle("Hide details (empty tiles)", isOn: model.binding(\.hideDetails)).frame(minHeight: 44)
            Text("Removes every name, number, text and icon so only the tiles remain. Downloads and screenshots follow it, and the export text then contains design values only, with nothing about the sample content.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        sectionBox("Hand edits") {
            let n = model.spec.edits.count
            Text(n == 0 ? "No hand edits yet. Use Edit above the preview to move, resize and restyle parts of a screen." : "\(n) element\(n == 1 ? "" : "s") moved or restyled across your screens.")
                .font(.footnote).foregroundStyle(.secondary)
            Button(role: .destructive) { model.resetAllEdits(); Haptics.success() } label: {
                Label("Reset all hand edits", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity).frame(minHeight: 44)
            }
            .buttonStyle(ChromeSecondaryStyle()).disabled(n == 0).opacity(n == 0 ? 0.45 : 1)
        }
    }
}

struct CheckControls: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceTransparency) private var reduceT
    @Environment(\.accessibilityReduceMotion) private var reduceM
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        let t = StyleTokens.make(model.spec)
        sectionBox("Contrast") {
            ForEach(t.contrastRows) { r in
                HStack {
                    Text(r.title).font(.subheadline)
                    Spacer()
                    Text("\(String(format: "%.1f", r.ratio)):1").monospacedDigit()
                    Text(r.passes ? "Pass" : "Low").font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill((r.passes ? Color.green : Color.orange).opacity(0.25)))
                }.frame(minHeight: 36)
            }
            if t.estimated { Text("Estimated, depends on the content behind the glass.").font(.footnote).foregroundStyle(.secondary) }
            Toggle("Boost contrast", isOn: model.binding(\.boostContrast)).frame(minHeight: 44)
        }
        if reduceT || reduceM || contrast == .increased {
            sectionBox("Active system settings") {
                if reduceT { Label("Reduce Transparency is on. The preview shows solid fallbacks, the export describes the translucent design.", systemImage: "info.circle") }
                if contrast == .increased { Label("Increase Contrast is on. The preview behaves as if Boost contrast is on.", systemImage: "info.circle") }
                if reduceM { Label("Reduce Motion is on. Animated gradients are skipped.", systemImage: "info.circle") }
            }.font(.footnote)
        }
        sectionBox("Editorial ratings") {
            Text(StyleCatalog.info(model.spec.style).name).font(.subheadline.bold())
            RatingBars(ratings: StyleCatalog.info(model.spec.style).ratings)
            if let c = model.spec.compareStyle {
                Divider()
                Text(StyleCatalog.info(c).name).font(.subheadline.bold())
                RatingBars(ratings: StyleCatalog.info(c).ratings)
            }
        }
    }
}
