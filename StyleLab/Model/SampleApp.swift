import SwiftUI

/// The kind of app the sample screens pretend to be, so a style can be judged on content that looks like the real thing.
enum SampleApp: String, Codable, CaseIterable, Sendable, Identifiable {
    case wallet, pos, foodOrder, delivery, shop, fitness, travel, music, chat, reminders
    var id: String { rawValue }

    var title: String {
        switch self {
        case .wallet: "Wallet and payments"
        case .pos: "POS and stock manager"
        case .foodOrder: "Food ordering"
        case .delivery: "Food delivery"
        case .shop: "Online shopping"
        case .fitness: "Fitness"
        case .travel: "Travel booking"
        case .music: "Music streaming"
        case .chat: "Chat and social"
        case .reminders: "Reminders"
        }
    }
    var shortTitle: String {
        switch self {
        case .wallet: "Wallet"; case .pos: "POS and stock"; case .foodOrder: "Food ordering"; case .delivery: "Delivery"
        case .shop: "Shopping"; case .fitness: "Fitness"; case .travel: "Travel"; case .music: "Music"; case .chat: "Chat"; case .reminders: "Reminders"
        }
    }
    var icon: String {
        switch self {
        case .wallet: "creditcard"; case .pos: "shippingbox"; case .foodOrder: "fork.knife"; case .delivery: "bag"
        case .shop: "storefront"; case .fitness: "figure.run"; case .travel: "airplane"; case .music: "music.note"; case .chat: "bubble.left.and.bubble.right"; case .reminders: "checklist"
        }
    }
    var tagline: String {
        switch self {
        case .wallet: "Balances, cards and payments"
        case .pos: "Register, sales, inventory and customers"
        case .foodOrder: "Menu, cart and orders for a restaurant"
        case .delivery: "Restaurants near you and live tracking"
        case .shop: "Browse, cart and orders for a store"
        case .fitness: "Workouts, plans and progress"
        case .travel: "Trips, destinations and bookings"
        case .music: "Now playing, browse and charts"
        case .chat: "Messages, friends and contacts"
        case .reminders: "Today, scheduled reminders and lists"
        }
    }
    /// The screens that make sense for this app. The first one is its main screen.
    var screens: [SampleScreen] {
        switch self {
        case .wallet: [.home, .wallet, .analytics, .notifications, .settings, .profile]
        case .pos: [.home, .sales, .inventory, .customers, .invoices, .settings]
        case .foodOrder: [.home, .explore, .cart, .orders, .profile, .settings]
        case .delivery: [.home, .explore, .cart, .orders, .notifications, .profile]
        case .shop: [.shop, .explore, .cart, .orders, .profile, .settings]
        case .fitness: [.workouts, .calendar, .tasks, .analytics, .profile, .settings]
        case .travel: [.trips, .explore, .calendar, .notifications, .profile, .settings]
        case .music: [.music, .explore, .notifications, .profile, .settings]
        case .chat: [.messages, .chat, .friends, .contacts, .profile, .settings]
        case .reminders: [.home, .calendar, .tasks, .notifications, .settings]
        }
    }
    var mainScreen: SampleScreen { screens.first ?? .home }
}

private func R(_ i: String, _ t: String, _ s: String, _ v: String, _ p: Bool = false) -> RowDef { RowDef(icon: i, title: t, subtitle: s, value: v, positive: p) }
private func A(_ i: String, _ l: String) -> ActDef { ActDef(icon: i, label: l) }
private func S(_ i: String, _ v: String, _ l: String) -> StatDef { StatDef(icon: i, value: v, label: l) }
private func B(_ n: String, _ p: Double, _ v: String) -> BarDef { BarDef(name: n, pct: p, value: v) }
private func P(_ i: String, _ n: String, _ p: String) -> ProductDef { ProductDef(icon: i, name: n, price: p) }

enum AppContent {
    private static let posTabs = [A("creditcard", "Register"), A("chart.line.uptrend.xyaxis", "Sales"), A("shippingbox", "Stock"), A("person.2", "Customers")]
    private static let foodTabs = [A("fork.knife", "Menu"), A("tag", "Offers"), A("clock", "Orders"), A("person", "Profile")]
    private static let deliveryTabs = [A("house", "Home"), A("magnifyingglass", "Search"), A("bag", "Orders"), A("person", "Account")]
    private static let fitnessTabs = [A("figure.run", "Workouts"), A("calendar", "Plan"), A("chart.bar", "Progress"), A("person", "Me")]
    private static let reminderTabs = [A("sun.max", "Today"), A("calendar", "Scheduled"), A("list.bullet", "Lists"), A("gearshape", "Settings")]
    private static let travelTabs = [A("airplane", "Trips"), A("magnifyingglass", "Explore"), A("heart", "Saved"), A("person", "Me")]

    /// Tabs and which one is active, when the app has its own navigation.
    private static func nav(_ app: SampleApp, _ s: SampleScreen) -> (tabs: [ActDef], active: Int)? {
        switch app {
        case .pos:
            let a: [SampleScreen: Int] = [.home: 0, .sales: 1, .inventory: 2, .customers: 3, .invoices: 1]
            return (posTabs, a[s] ?? 0)
        case .foodOrder:
            let a: [SampleScreen: Int] = [.home: 0, .explore: 1, .cart: 2, .orders: 2, .profile: 3]
            return (foodTabs, a[s] ?? 0)
        case .delivery:
            let a: [SampleScreen: Int] = [.home: 0, .explore: 1, .cart: 2, .orders: 2, .notifications: 0, .profile: 3]
            return (deliveryTabs, a[s] ?? 0)
        case .fitness:
            let a: [SampleScreen: Int] = [.workouts: 0, .calendar: 1, .tasks: 1, .analytics: 2, .profile: 3]
            return (fitnessTabs, a[s] ?? 0)
        case .travel:
            let a: [SampleScreen: Int] = [.trips: 0, .explore: 1, .calendar: 0, .notifications: 2, .profile: 3]
            return (travelTabs, a[s] ?? 0)
        case .reminders:
            let a: [SampleScreen: Int] = [.home: 0, .calendar: 1, .tasks: 2, .notifications: 0, .settings: 3]
            return (reminderTabs, a[s] ?? 0)
        default: return nil
        }
    }

    private static func blocks(_ app: SampleApp, _ s: SampleScreen) -> [Block]? {
        switch (app, s) {
        // POS and stock manager
        case (.pos, .home): return [
            .header(sub: "Counter 1", title: "Register", icon: "barcode.viewfinder"),
            .search("Scan or search an item"),
            .grid(title: "Quick items", items: [P("cup.and.saucer", "Coffee", "$3.50"), P("takeoutbag.and.cup.and.straw", "Sandwich", "$6.00"), P("drop", "Water", "$1.50"), P("birthday.cake", "Cookie", "$2.25")]),
            .hero(label: "Current sale", value: "$24.50", chip: "5 items"),
            .button("Charge $24.50")]
        // Food ordering
        case (.foodOrder, .home): return [
            .header(sub: "Table 12", title: "Menu", icon: "bell"),
            .search("Search dishes"),
            .chips(["Popular", "Starters", "Mains", "Drinks"]),
            .grid(title: "Chef's picks", items: [P("fork.knife", "Margherita", "$12.00"), P("leaf", "Caesar salad", "$9.50"), P("flame", "Spicy ramen", "$13.50"), P("cup.and.saucer", "Lemonade", "$3.00")]),
            .button("View order")]
        case (.foodOrder, .explore): return [
            .header(sub: "", title: "Offers", icon: "slider.horizontal.3"),
            .hero(label: "Lunch special", value: "2 for 1", chip: "Until 3 PM"),
            .chips(["All", "Italian", "Asian", "Vegan"]),
            .grid(title: "Today's deals", items: [P("fork.knife", "Pasta set", "$11.00"), P("leaf", "Veggie bowl", "$10.00"), P("flame", "Ramen combo", "$14.00"), P("birthday.cake", "Dessert duo", "$7.00")])]
        case (.foodOrder, .cart): return [
            .header(sub: "Table 12", title: "Your order", icon: "trash"),
            .list(title: "3 items", rows: [R("fork.knife", "Margherita", "Extra cheese, qty 1", "$12.00"), R("leaf", "Caesar salad", "No croutons, qty 1", "$9.50"), R("cup.and.saucer", "Lemonade", "Large, qty 2", "$6.00")]),
            .hero(label: "Total", value: "$27.50", chip: "Service included"),
            .button("Place order")]
        case (.foodOrder, .orders): return [
            .header(sub: "", title: "Orders", icon: "clock"),
            .chips(["Active", "Past"]),
            .list(title: "Today", rows: [R("fork.knife", "Order 118", "Table 12, preparing", "$27.50"), R("fork.knife", "Order 112", "Table 12, served", "$14.00", true)]),
            .button("Reorder")]
        // Food delivery
        case (.delivery, .home): return [
            .header(sub: "Deliver to Home", title: "Hungry?", icon: "bell"),
            .search("Restaurants, dishes or groceries"),
            .chips(["Pizza", "Sushi", "Burgers", "Healthy"]),
            .hero(label: "Offer", value: "Free delivery", chip: "First order"),
            .list(title: "Restaurants near you", rows: [R("fork.knife", "Luigi's Pizza", "4.8 stars, 25 min", "$$"), R("fish", "Sakura Sushi", "4.7 stars, 30 min", "$$$"), R("flame", "Burger Hub", "4.5 stars, 20 min", "$")])]
        case (.delivery, .explore): return [
            .header(sub: "", title: "Search", icon: "slider.horizontal.3"),
            .search("Cuisines, restaurants, dishes"),
            .chips(["Open now", "Under 30 min", "Offers"]),
            .grid(title: "Cuisines", items: [P("fork.knife", "Italian", "120 places"), P("flame", "Burgers", "86 places"), P("leaf", "Healthy", "64 places"), P("cup.and.saucer", "Cafes", "92 places")])]
        case (.delivery, .cart): return [
            .header(sub: "", title: "Checkout", icon: "trash"),
            .list(title: "Luigi's Pizza", rows: [R("fork.knife", "Margherita", "Large, qty 1", "$14.00"), R("fork.knife", "Garlic bread", "qty 1", "$5.50"), R("cup.and.saucer", "Cola", "qty 2", "$6.00")]),
            .hero(label: "Total", value: "$31.80", chip: "Delivery $2.99 included"),
            .button("Pay and order")]
        case (.delivery, .orders): return [
            .header(sub: "Live", title: "Track order", icon: "phone"),
            .hero(label: "Arriving in", value: "12 min", chip: "Order 2041, on the way"),
            .bars(title: "Order status", items: [B("Order placed", 1.0, "8:42"), B("Preparing", 1.0, "8:50"), B("On the way", 0.6, "9:02")]),
            .list(title: "Courier", rows: [R("person.crop.circle", "Mateo R.", "Scooter, 4.9 stars", "Call")]),
            .button("Contact courier")]
        // Travel
        case (.travel, .explore): return [
            .header(sub: "", title: "Explore", icon: "slider.horizontal.3"),
            .search("Where to?"),
            .chips(["Beaches", "Cities", "Mountains"]),
            .grid(title: "Popular destinations", items: [P("sun.max", "Lisbon", "$420"), P("snowflake", "Zermatt", "$680"), P("leaf", "Bali", "$740"), P("building.2", "Tokyo", "$910")])]
        // Reminders
        case (.reminders, .home): return [
            .header(sub: "Friday, October 16", title: "Today", icon: "plus"),
            .stats([S("sun.max", "4", "Today"), S("calendar", "7", "Scheduled"), S("tray", "12", "All"), S("flag", "2", "Flagged")]),
            .toggles([("Call the dentist", "phone", false), ("Buy groceries", "cart", false), ("Submit the report", "doc.text", true), ("Pay rent", "banknote", false)]),
            .button("New reminder")]
        case (.reminders, .calendar): return [
            .header(sub: "October", title: "Scheduled", icon: "calendar"),
            .chips(["Today", "Tomorrow", "This week", "Later"]),
            .list(title: "Upcoming", rows: [R("bell", "Call the dentist", "Today, 9:00 AM", "In 2 h"), R("bell", "Team standup", "Today, 11:30 AM", "Daily"), R("bell", "Pick up parcel", "Tomorrow, 5:00 PM", ""), R("bell", "Water the plants", "Sunday, 8:00 AM", "Weekly")]),
            .button("Add reminder")]
        case (.reminders, .tasks): return [
            .header(sub: "", title: "Lists", icon: "plus"),
            .search("Search reminders"),
            .list(title: "My lists", rows: [R("house", "Personal", "5 reminders", "5"), R("briefcase", "Work", "8 reminders", "8"), R("cart", "Groceries", "4 reminders", "4"), R("heart", "Family", "2 reminders", "2")]),
            .button("Add list")]
        // Music
        case (.music, .explore): return [
            .header(sub: "", title: "Browse", icon: "magnifyingglass"),
            .search("Artists, songs, podcasts"),
            .chips(["Pop", "Rock", "Jazz", "Focus"]),
            .list(title: "Top charts", rows: [R("music.note", "Afterglow", "Neon Tides", "1"), R("music.note", "City Lights", "Luna Vale", "2"), R("music.note", "Slow Burn", "Aria Fox", "3"), R("music.note", "Daybreak", "The Hollows", "4")])]
        default: return nil
        }
    }

    /// The screen content for a sample app. Apps reuse the shared screens and override the ones that must look different.
    static func def(_ screen: SampleScreen, _ app: SampleApp) -> ScreenDef {
        let base = ScreenDefs.def(screen)
        if app == .wallet || screen == .imported { return base }
        let n = nav(app, screen)
        return ScreenDef(tabs: n?.tabs ?? base.tabs, active: n?.active ?? base.active, blocks: blocks(app, screen) ?? base.blocks)
    }
}

extension SampleScreen {
    /// Key prefix for hand edits. The wallet app keeps the plain name so older designs keep their edits.
    func editKey(_ app: SampleApp) -> String { app == .wallet || self == .imported ? rawValue : app.rawValue + "-" + rawValue }
}
