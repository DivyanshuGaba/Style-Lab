import SwiftUI

struct DiscoverView: View {
    @Environment(AppModel.self) private var model
    @State private var wizard = false

    var body: some View {
        NavigationStack {
            Group {
                if model.briefDone { SuggestionsView(onEdit: { wizard = true }) } else { intro }
            }
            .navigationTitle("Discover")
            .fullScreenCover(isPresented: $wizard) {
                BriefWizardView(initial: model.spec.brief) { model.finishBrief($0); wizard = false } onCancel: { wizard = false }
            }
        }
    }

    private var intro: some View {
        ScrollView {
            VStack(spacing: 18) {
                HeroStack().padding(.top, 8)
                Text("Find the look of your app").font(.system(.largeTitle, design: .rounded, weight: .bold)).multilineTextAlignment(.center)
                Text("Answer five quick questions. Style Lab ranks 12 visual styles for your app, lets you tune every detail, then writes the handoff for Claude Code.")
                    .multilineTextAlignment(.center).foregroundStyle(.secondary).padding(.horizontal, 28)
                Button { wizard = true; Haptics.impact() } label: { Label("Start with a brief", systemImage: "sparkles").frame(maxWidth: .infinity).frame(minHeight: 48) }
                    .buttonStyle(ChromePrimaryStyle()).padding(.horizontal, 28)
                Button("Skip and browse styles") { model.tab = .gallery }.frame(minHeight: 44)
                HStack(spacing: 10) {
                    FeaturePill(t: "12 live styles", i: "paintpalette"); FeaturePill(t: "Live checks", i: "checkmark.seal"); FeaturePill(t: "Claude handoff", i: "doc.text")
                }
            }
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .chromeBackground()
    }
}

struct FeaturePill: View {
    let t: String, i: String
    var body: some View {
        VStack(spacing: 4) { Image(systemName: i).font(.title3).foregroundStyle(Chrome.indigo); Text(t).font(.caption.weight(.semibold)) }
            .frame(maxWidth: .infinity).padding(.vertical, 12).chromeCard(radius: 16)
    }
}

struct OptionCard: View {
    let title: String, subtitle: String, selected: Bool
    var icon: String? = nil
    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon).font(.title3).foregroundStyle(selected ? Color.white : Chrome.indigo)
                    .frame(width: 42, height: 42)
                    .background(selected ? AnyShapeStyle(Chrome.gradient) : AnyShapeStyle(Chrome.indigo.opacity(0.12)), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: selected ? "checkmark.circle.fill" : "circle").foregroundStyle(selected ? Chrome.indigo : .secondary)
                .symbolEffect(.bounce, value: selected)
        }
        .padding(14).frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .chromeCard()
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(selected ? Chrome.indigo : .clear, lineWidth: 2))
        .scaleEffect(selected ? 1.01 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct BriefWizardView: View {
    @State var brief: Brief
    let onFinish: (Brief) -> Void
    let onCancel: () -> Void
    @State private var step = 0
    private let total = 5

    init(initial: Brief, onFinish: @escaping (Brief) -> Void, onCancel: @escaping () -> Void) {
        _brief = State(initialValue: initial); self.onFinish = onFinish; self.onCancel = onCancel
    }

    private let catIcon: [AppCategory: String] = [.finance: "banknote", .social: "bubble.left.and.bubble.right", .wellness: "heart.text.square", .games: "gamecontroller",
        .utility: "wrench.and.screwdriver", .shopping: "bag", .education: "graduationcap", .media: "play.rectangle", .travel: "airplane", .productivity: "checklist"]
    private let catHelp: [AppCategory: String] = [
        .finance: "Money, budgets, banking, payments.", .social: "Friends, chat, sharing, feeds.", .wellness: "Sleep, meditation, health, fitness.",
        .games: "Play, levels, drawing, creating.", .utility: "Tools that do one job well.", .shopping: "Stores, carts, buying.",
        .education: "Learning, courses, kids.", .media: "Music, video, podcasts, reading.", .travel: "Trips, flights, hotels, maps.", .productivity: "Tasks, notes, calendars, teams."]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Close", action: onCancel).frame(minHeight: 44)
                Spacer()
                Text("Step \(step + 1) of \(total)").font(.footnote).foregroundStyle(.secondary)
            }.padding(.horizontal)
            ProgressView(value: Double(step + 1), total: Double(total)).tint(Chrome.indigo).padding(.horizontal)
                .animation(.easeInOut, value: step)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) { content }.padding()
                    .id(step)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
            .clipped()
            HStack {
                Button("Back") { step -= 1 }.disabled(step == 0).frame(minHeight: 44)
                Spacer()
                if step < total - 1 { Button("Skip") { step += 1 }.frame(minHeight: 44).padding(.trailing, 8) }
                Button(step == total - 1 ? "See suggestions" : "Next") {
                    if step == total - 1 { onFinish(brief) } else { step += 1 }
                }.buttonStyle(ChromePrimaryStyle()).frame(minHeight: 44)
            }.padding()
        }
        .chromeBackground()
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0:
            Text("What are you creating?").font(.title.bold())
            TextField("App name (optional)", text: $brief.appName).textFieldStyle(.roundedBorder).frame(minHeight: 44)
            Text("Describe your app in your own words").font(.subheadline).foregroundStyle(.secondary)
            TextField("A budgeting app for freelancers who hate spreadsheets", text: $brief.oneLiner, axis: .vertical)
                .lineLimit(3...6).textFieldStyle(.roundedBorder)
        case 1:
            Text("What kind of app is it?").font(.title.bold())
            Button("Guess from my description") { brief.category = CategoryGuesser.guess(brief.oneLiner); Haptics.select() }
                .buttonStyle(ChromeSecondaryStyle()).frame(minHeight: 44)
            ForEach(AppCategory.allCases, id: \.self) { c in
                Button { brief.category = c; Haptics.select() } label: { OptionCard(title: c.title, subtitle: catHelp[c] ?? "", selected: brief.category == c, icon: catIcon[c]) }.buttonStyle(.plain)
            }
        case 2:
            Text("How should it feel?").font(.title.bold())
            moodCard(.calm, "Calm and trustworthy", "Quiet, steady, nothing shouts.")
            moodCard(.premium, "Premium and rich", "Layered, polished, high quality.")
            moodCard(.playful, "Friendly and playful", "Warm, approachable, a little fun.")
            moodCard(.bold, "Bold and loud", "Strong contrast and attitude.")
            moodCard(.tech, "Technical and futuristic", "Precise, glowing, information dense.")
        case 3:
            Text("Who uses it, and where?").font(.title.bold())
            ctxCard(.legible, "Many ages, often outdoors", "Legibility comes first.")
            ctxCard(.mixed, "A mix, normal conditions", "No special constraints.")
            ctxCard(.night, "Mostly at night or in dark mode", "Dark is the main look.")
        default:
            Text("How much build effort?").font(.title.bold())
            Button { brief.effort = .simple } label: { OptionCard(title: "Keep it fast and simple", subtitle: "Prefer styles that are quick to build and maintain.", selected: brief.effort == .simple, icon: "hare") }.buttonStyle(.plain)
            Button { brief.effort = .rich } label: { OptionCard(title: "Happy to invest in polish", subtitle: "Richer, more layered styles are welcome.", selected: brief.effort == .rich, icon: "wand.and.stars") }.buttonStyle(.plain)
        }
    }
    private func moodIcon(_ m: Mood) -> String {
        switch m { case .calm: "leaf"; case .premium: "sparkles"; case .playful: "face.smiling"; case .bold: "bolt.fill"; case .tech: "cpu" }
    }
    private func moodCard(_ m: Mood, _ t: String, _ s: String) -> some View {
        Button { brief.mood = m; Haptics.select() } label: { OptionCard(title: t, subtitle: s, selected: brief.mood == m, icon: moodIcon(m)) }.buttonStyle(.plain)
    }
    private func ctxCard(_ c: UsageContext, _ t: String, _ s: String) -> some View {
        Button { brief.context = c; Haptics.select() } label: { OptionCard(title: t, subtitle: s, selected: brief.context == c, icon: c == .legible ? "sun.max" : (c == .mixed ? "person.2" : "moon.stars")) }.buttonStyle(.plain)
    }
}

struct SuggestionsView: View {
    @Environment(AppModel.self) private var model
    let onEdit: () -> Void

    private func warning(_ s: StyleScore) -> String {
        let info = StyleCatalog.info(s.style), b = model.spec.brief
        if b.context == .legible && info.ratings.textLegibility <= 2 { return "Low contrast risk for your audience, boost contrast is recommended." }
        if b.effort == .simple && info.ratings.ease <= 2 { return "This will take more build effort than you wanted." }
        return info.watchOut.prefix(1).uppercased() + info.watchOut.dropFirst()
    }

    var body: some View {
        let ranking = model.ranking
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(StyleRanker.briefSentence(model.spec.brief) + ".").font(.headline)
                    Button("Edit my answers", action: onEdit).frame(minHeight: 44)
                }
                .padding().frame(maxWidth: .infinity, alignment: .leading)
                .chromeCard()

                ForEach(Array(ranking.prefix(3).enumerated()), id: \.element.id) { i, s in card(s, rank: i + 1, next: ranking[min(i + 1, ranking.count - 1)].style) }

                DisclosureGroup("Why not the others?") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ranking.suffix(3)) { s in
                            Text("\(StyleCatalog.info(s.style).name): \(s.mismatch).").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 6)
                }
                .padding().chromeCard()

                Button { model.gallerySort = .fit; model.tab = .gallery } label: {
                    HStack { Text("See all 12 styles"); Spacer(); Image(systemName: "chevron.right") }.frame(minHeight: 44)
                }
                .padding(.horizontal).chromeCard()
            }
            .padding()
        }
        .chromeBackground()
    }

    private func card(_ s: StyleScore, rank: Int, next: StyleID) -> some View {
        let info = StyleCatalog.info(s.style)
        let preview = DesignSpec.pristine(style: s.style, mode: model.spec.brief.context == .night ? .dark : .light)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                PreviewCanvas(spec: preview).frame(height: 190)
                VStack(alignment: .leading, spacing: 8) {
                    if rank == 1 { Badge(text: "Best match", icon: "star.fill") }
                    HStack(spacing: 10) {
                        FitRing(percent: s.percent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(info.name).font(.system(.headline, design: .rounded))
                            Text("#\(rank) for your brief").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    FlowChips(items: s.reasons)
                }
            }
            Label(warning(s), systemImage: "exclamationmark.triangle").font(.footnote).foregroundStyle(.secondary)
            HStack {
                Button { model.openInStudio(style: s.style) } label: { Text("Open in Studio").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromePrimaryStyle())
                Button { model.startProject(style: s.style); model.update { $0.compareStyle = next } } label: { Text("Compare with next").frame(maxWidth: .infinity).frame(minHeight: 44) }.buttonStyle(ChromeSecondaryStyle())
            }
        }
        .padding().chromeCard(radius: 26)
    }
}

struct FlowChips: View {
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { Label($0, systemImage: "checkmark").font(.caption2.weight(.semibold)).foregroundStyle(Chrome.indigo).padding(.horizontal, 8).padding(.vertical, 4).background(Capsule().fill(Chrome.indigo.opacity(0.12))) }
        }
    }
}
