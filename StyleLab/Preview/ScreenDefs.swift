import SwiftUI

struct RowDef { let icon, title, subtitle, value: String; var positive = false }
struct StatDef { let icon, value, label: String }
struct ActDef { let icon, label: String }
struct BarDef { let name: String; let pct: Double; let value: String }
struct ProductDef { let icon, name, price: String }

enum Block {
    case header(sub: String, title: String, icon: String)
    case hero(label: String, value: String, chip: String)
    case search(String)
    case chips([String])
    case actions([ActDef])
    case stats([StatDef])
    case list(title: String, rows: [RowDef])
    case people(title: String, names: [String])
    case bars(title: String, items: [BarDef])
    case chat([(String, Bool)])
    case grid(title: String, items: [ProductDef])
    case toggles([(String, String, Bool?)])
    case profile(name: String, email: String)
    case button(String)
}

struct ScreenDef {
    let tabs: [ActDef]
    let active: Int
    let blocks: [Block]
}

extension SampleScreen {
    var title: String {
        switch self {
        case .home: "Home"; case .settings: "Settings"; case .sales: "Sales"; case .repair: "Repairs"; case .inventory: "Inventory"
        case .friends: "Friends"; case .contacts: "Contacts"; case .messages: "Messages"; case .chat: "Chat"; case .orders: "Orders"
        case .customers: "Customers"; case .invoices: "Invoices"; case .analytics: "Insights"; case .calendar: "Calendar"; case .tasks: "Tasks"
        case .wallet: "Cards"; case .profile: "Profile"; case .notifications: "Notifications"; case .explore: "Explore"; case .shop: "Shop"
        case .cart: "Cart"; case .workouts: "Workouts"; case .music: "Music"; case .trips: "Trips"; case .courses: "Courses"
        case .support: "Support"; case .appointments: "Appointments"; case .team: "Team"; case .expenses: "Expenses"
        case .imported: "Imported"
        }
    }
    var icon: String {
        switch self {
        case .home: "house"; case .settings: "gearshape"; case .sales: "chart.line.uptrend.xyaxis"; case .repair: "wrench.and.screwdriver"
        case .inventory: "shippingbox"; case .friends: "person.2"; case .contacts: "person.crop.circle"; case .messages: "bubble.left.and.bubble.right"
        case .chat: "bubble.left"; case .orders: "bag"; case .customers: "person.3"; case .invoices: "doc.text"; case .analytics: "chart.bar"
        case .calendar: "calendar"; case .tasks: "checklist"; case .wallet: "creditcard"; case .profile: "person"; case .notifications: "bell"
        case .explore: "magnifyingglass"; case .shop: "storefront"; case .cart: "cart"; case .workouts: "figure.run"; case .music: "music.note"
        case .trips: "airplane"; case .courses: "graduationcap"; case .support: "lifepreserver"; case .appointments: "clock"; case .team: "person.badge.shield.checkmark"
        case .expenses: "banknote"
        case .imported: "photo.on.rectangle"
        }
    }
    var group: String {
        switch self {
        case .home, .settings, .profile, .notifications, .wallet, .analytics: "General"
        case .sales, .repair, .inventory, .customers, .invoices, .orders, .support, .appointments, .team, .expenses: "Business"
        case .friends, .contacts, .messages, .chat: "Social"
        case .calendar, .tasks, .workouts, .music, .trips, .courses: "Lifestyle"
        case .shop, .explore, .cart: "Shopping"
        case .imported: "Imported"
        }
    }
    static let groups = ["General", "Business", "Social", "Lifestyle", "Shopping"]
}

private func R(_ i: String, _ t: String, _ s: String, _ v: String, _ p: Bool = false) -> RowDef { RowDef(icon: i, title: t, subtitle: s, value: v, positive: p) }
private func A(_ i: String, _ l: String) -> ActDef { ActDef(icon: i, label: l) }
private func S(_ i: String, _ v: String, _ l: String) -> StatDef { StatDef(icon: i, value: v, label: l) }
private func B(_ n: String, _ p: Double, _ v: String) -> BarDef { BarDef(name: n, pct: p, value: v) }
private func P(_ i: String, _ n: String, _ p: String) -> ProductDef { ProductDef(icon: i, name: n, price: p) }

enum ScreenDefs {
    static let std = [A("house", "Home"), A("creditcard", "Cards"), A("chart.bar", "Insights"), A("person", "Profile")]
    static let biz = [A("chart.line.uptrend.xyaxis", "Sales"), A("wrench.and.screwdriver", "Repairs"), A("shippingbox", "Inventory"), A("person.2", "Customers")]
    static let social = [A("house", "Feed"), A("person.2", "Friends"), A("bubble.left", "Chat"), A("person", "Me")]
    static let shopTabs = [A("bag", "Shop"), A("magnifyingglass", "Search"), A("cart", "Cart"), A("person", "Me")]
    static let life = [A("calendar", "Today"), A("checklist", "Tasks"), A("chart.bar", "Stats"), A("person", "Me")]
    static let media = [A("music.note", "Listen"), A("magnifyingglass", "Browse"), A("heart", "Library"), A("person", "Me")]

    static let standardActions = [A("paperplane", "Send"), A("arrow.down.left", "Request"), A("qrcode.viewfinder", "Scan"), A("ellipsis", "More")]

    static func def(_ s: SampleScreen) -> ScreenDef {
        switch s {
        case .imported: return ScreenDef(tabs: std, active: 0, blocks: [])
        case .home: return ScreenDef(tabs: std, active: 0, blocks: [
            .header(sub: "Good evening", title: "Wallet", icon: "bell"),
            .hero(label: "Total balance", value: "$12,480.50", chip: "+2.4% this week"),
            .actions(standardActions),
            .list(title: "Recent", rows: [R("cup.and.saucer", "Blue Door Coffee", "Today, 8:42", "-$4.80"), R("arrow.down.left", "Invoice paid", "Yesterday", "+$1,200.00", true), R("bag", "Market Street", "Monday", "-$36.15")]),
            .button("Add money")])
        case .settings: return ScreenDef(tabs: std, active: 3, blocks: [
            .header(sub: "", title: "Settings", icon: ""),
            .profile(name: "Alex Morgan", email: "alex@example.com"),
            .toggles([("Notifications", "bell", true), ("Face ID", "faceid", true), ("Dark appearance", "moon", false)]),
            .toggles([("Language", "globe", nil), ("Privacy", "lock", nil), ("Help", "ellipsis", nil)]),
            .button("Save changes")])
        case .sales: return ScreenDef(tabs: biz, active: 0, blocks: [
            .header(sub: "Today", title: "Sales", icon: "bell"),
            .hero(label: "Today's sales", value: "$4,820.00", chip: "+12% vs yesterday"),
            .stats([S("cart", "38", "Orders"), S("person.2", "21", "Customers"), S("tag", "$127", "Average sale"), S("arrow.uturn.left", "2", "Returns")]),
            .list(title: "Recent sales", rows: [R("doc.text", "INV 1042", "Walk in customer", "$240.00", true), R("doc.text", "INV 1041", "Priya K.", "$89.50", true)]),
            .button("New sale")])
        case .repair: return ScreenDef(tabs: biz, active: 1, blocks: [
            .header(sub: "Workshop", title: "Repairs", icon: "plus"),
            .chips(["All", "In progress", "Ready", "Waiting"]),
            .stats([S("wrench.and.screwdriver", "12", "Open jobs"), S("checkmark.circle", "7", "Ready"), S("clock", "3", "Overdue"), S("dollarsign.circle", "$1,340", "Revenue")]),
            .list(title: "Open jobs", rows: [R("iphone", "iPhone 14 screen", "Alex M. due today", "In progress"), R("laptopcomputer", "MacBook battery", "Priya K. due Friday", "Waiting")]),
            .button("New repair ticket")])
        case .inventory: return ScreenDef(tabs: biz, active: 2, blocks: [
            .header(sub: "Stock", title: "Inventory", icon: "barcode.viewfinder"),
            .search("Search items or scan"),
            .stats([S("shippingbox", "1,240", "Items"), S("exclamationmark.triangle", "9", "Low stock"), S("arrow.down.to.line", "3", "Out of stock"), S("dollarsign.circle", "$38k", "Value")]),
            .bars(title: "Low stock", items: [B("USB C cable", 0.2, "4 left"), B("Screen protector", 0.45, "18 left")]),
            .button("Add item")])
        case .friends: return ScreenDef(tabs: social, active: 1, blocks: [
            .header(sub: "Social", title: "Friends", icon: "person.badge.plus"),
            .people(title: "Online now", names: ["Maya", "Leo", "Zoe", "Ken", "Ava"]),
            .search("Find friends"),
            .list(title: "Suggestions", rows: [R("person.crop.circle", "Noah Park", "3 mutual friends", "Add"), R("person.crop.circle", "Isla Reed", "5 mutual friends", "Add"), R("person.crop.circle", "Omar Haddad", "2 mutual friends", "Add")]),
            .button("Invite friends")])
        case .contacts: return ScreenDef(tabs: social, active: 3, blocks: [
            .header(sub: "", title: "Contacts", icon: "plus"),
            .search("Search contacts"),
            .people(title: "Favourites", names: ["Mom", "Dad", "Sam", "Lia", "Raj"]),
            .list(title: "All contacts", rows: [R("person.crop.circle", "Alex Morgan", "+1 555 0142", ""), R("person.crop.circle", "Bella Ruiz", "+1 555 0178", ""), R("person.crop.circle", "Chris Doyle", "+1 555 0113", "")])])
        case .messages: return ScreenDef(tabs: social, active: 2, blocks: [
            .header(sub: "", title: "Messages", icon: "square.and.pencil"),
            .search("Search messages"),
            .list(title: "Recent chats", rows: [R("person.crop.circle", "Maya", "See you at 7?", "9:41"), R("person.crop.circle", "Design team", "New mockups are in", "9:12"), R("person.crop.circle", "Leo", "Thanks!", "Mon"), R("person.crop.circle", "Zoe", "Sent a photo", "Sun")])])
        case .chat: return ScreenDef(tabs: social, active: 2, blocks: [
            .header(sub: "Online", title: "Maya", icon: "phone"),
            .chat([("Hey, are we still on for tonight?", false), ("Yes! 7 works for me", true), ("Great, I booked a table", false), ("Perfect, see you there", true)]),
            .search("Type a message")])
        case .orders: return ScreenDef(tabs: shopTabs, active: 2, blocks: [
            .header(sub: "", title: "Orders", icon: "shippingbox"),
            .chips(["All", "Pending", "Shipped", "Delivered"]),
            .list(title: "Your orders", rows: [R("shippingbox", "Order 2041", "3 items, today", "$86.40"), R("shippingbox", "Order 2038", "1 item, Monday", "$24.00"), R("shippingbox", "Order 2031", "2 items, last week", "$57.90")]),
            .button("Track order")])
        case .customers: return ScreenDef(tabs: biz, active: 3, blocks: [
            .header(sub: "", title: "Customers", icon: "person.badge.plus"),
            .search("Search customers"),
            .stats([S("person.3", "128", "Total"), S("sparkles", "14", "New this month"), S("star", "9", "VIP"), S("clock", "3", "Overdue")]),
            .list(title: "Top customers", rows: [R("person.crop.circle", "Priya K.", "24 orders", "$2,140", true), R("person.crop.circle", "Alex M.", "18 orders", "$1,720", true)])])
        case .invoices: return ScreenDef(tabs: biz, active: 0, blocks: [
            .header(sub: "", title: "Invoices", icon: "doc.badge.plus"),
            .hero(label: "Outstanding", value: "$9,240.00", chip: "5 unpaid"),
            .chips(["All", "Paid", "Unpaid", "Overdue"]),
            .list(title: "Latest invoices", rows: [R("doc.text", "INV 1042", "Due in 5 days", "$240.00"), R("doc.text", "INV 1040", "Paid", "$1,100.00", true), R("doc.text", "INV 1037", "Overdue", "$560.00")]),
            .button("Create invoice")])
        case .analytics: return ScreenDef(tabs: std, active: 2, blocks: [
            .header(sub: "This week", title: "Insights", icon: "calendar"),
            .hero(label: "Revenue", value: "$18,420", chip: "+8.2%"),
            .bars(title: "By category", items: [B("Phones", 0.8, "$9.1k"), B("Accessories", 0.5, "$5.2k"), B("Repairs", 0.3, "$4.1k")]),
            .stats([S("cart", "214", "Orders"), S("person.2", "96", "Visitors"), S("percent", "4.1%", "Conversion"), S("arrow.uturn.left", "6", "Refunds")])])
        case .calendar: return ScreenDef(tabs: life, active: 0, blocks: [
            .header(sub: "October", title: "Calendar", icon: "plus"),
            .chips(["Mon 14", "Tue 15", "Wed 16", "Thu 17", "Fri 18"]),
            .list(title: "Today", rows: [R("clock", "Team standup", "9:00 AM", "30 min"), R("clock", "Client call", "11:30 AM", "45 min"), R("clock", "Design review", "2:00 PM", "1 hr")]),
            .button("Add event")])
        case .tasks: return ScreenDef(tabs: life, active: 1, blocks: [
            .header(sub: "3 left today", title: "Tasks", icon: "plus"),
            .chips(["Today", "Upcoming", "Done"]),
            .toggles([("Send invoices", "doc.text", false), ("Order new stock", "shippingbox", true), ("Call supplier", "phone", false), ("Update prices", "tag", false)]),
            .button("Add task")])
        case .wallet: return ScreenDef(tabs: std, active: 1, blocks: [
            .header(sub: "", title: "Cards", icon: "plus"),
            .hero(label: "Card balance", value: "$3,204.18", chip: "Ends 4821"),
            .actions([A("lock", "Freeze"), A("eye", "Details"), A("arrow.left.arrow.right", "Limits"), A("ellipsis", "More")]),
            .list(title: "Transactions", rows: [R("cart", "Grocery Mart", "Today", "-$62.40"), R("fork.knife", "Noodle Bar", "Yesterday", "-$18.00"), R("arrow.down.left", "Refund", "Monday", "+$24.99", true)])])
        case .profile: return ScreenDef(tabs: std, active: 3, blocks: [
            .header(sub: "", title: "Profile", icon: "gearshape"),
            .profile(name: "Alex Morgan", email: "alex@example.com"),
            .stats([S("bag", "12", "Orders"), S("star", "4", "Reviews"), S("ticket", "2", "Coupons"), S("heart", "9", "Saved")]),
            .toggles([("Edit details", "person", nil), ("Payment methods", "creditcard", nil), ("Addresses", "mappin.and.ellipse", nil)]),
            .button("Sign out")])
        case .notifications: return ScreenDef(tabs: std, active: 0, blocks: [
            .header(sub: "", title: "Notifications", icon: "checkmark.circle"),
            .chips(["All", "Unread", "Mentions"]),
            .list(title: "Today", rows: [R("bell", "Payment received", "Invoice 1042", "2m"), R("bubble.left", "Maya sent a message", "See you at 7?", "1h"), R("tag", "Price drop", "USB C cable", "3h"), R("shippingbox", "Order shipped", "Order 2041", "5h")])])
        case .explore: return ScreenDef(tabs: shopTabs, active: 1, blocks: [
            .header(sub: "", title: "Explore", icon: "slider.horizontal.3"),
            .search("Search products"),
            .chips(["All", "Phones", "Audio", "Wearables"]),
            .grid(title: "Popular", items: [P("iphone", "Phone X", "$699"), P("headphones", "Studio Pro", "$149"), P("applewatch", "Watch S", "$299"), P("airpodspro", "Buds", "$99")])])
        case .shop: return ScreenDef(tabs: shopTabs, active: 0, blocks: [
            .header(sub: "New arrivals", title: "Shop", icon: "bell"),
            .hero(label: "Weekend deal", value: "20% off", chip: "Ends Sunday"),
            .grid(title: "Trending", items: [P("headphones", "Studio Pro", "$149"), P("applewatch", "Watch S", "$299")]),
            .button("View all")])
        case .cart: return ScreenDef(tabs: shopTabs, active: 2, blocks: [
            .header(sub: "", title: "Cart", icon: "trash"),
            .list(title: "3 items", rows: [R("headphones", "Studio Pro", "Black, qty 1", "$149.00"), R("cable.connector", "USB C cable", "2 m, qty 2", "$24.00"), R("iphone.gen3", "Phone case", "Blue, qty 1", "$41.30")]),
            .hero(label: "Total", value: "$214.30", chip: "Free delivery"),
            .button("Checkout")])
        case .workouts: return ScreenDef(tabs: life, active: 1, blocks: [
            .header(sub: "Good morning", title: "Workouts", icon: "figure.run"),
            .hero(label: "Today's goal", value: "480 kcal", chip: "72% done"),
            .stats([S("figure.run", "5.2 km", "Distance"), S("timer", "42 min", "Time"), S("shoeprints.fill", "8,420", "Steps"), S("heart", "68 bpm", "Resting")]),
            .list(title: "Plan", rows: [R("dumbbell", "Upper body", "Today, 6:30 PM", "45 min")]),
            .button("Start workout")])
        case .music: return ScreenDef(tabs: media, active: 0, blocks: [
            .header(sub: "Now playing", title: "Music", icon: "music.note"),
            .hero(label: "Midnight Drive", value: "Neon Tides", chip: "2:41 of 3:58"),
            .actions([A("backward.fill", "Prev"), A("play.fill", "Play"), A("forward.fill", "Next"), A("heart", "Like")]),
            .list(title: "Up next", rows: [R("music.note", "Afterglow", "Neon Tides", "3:12"), R("music.note", "City Lights", "Luna Vale", "4:01")])])
        case .trips: return ScreenDef(tabs: life, active: 0, blocks: [
            .header(sub: "Next trip", title: "Trips", icon: "airplane"),
            .hero(label: "Lisbon", value: "Oct 24 to 31", chip: "8 days"),
            .list(title: "Bookings", rows: [R("airplane", "Flight TP 205", "Oct 24, 08:15", "Confirmed", true), R("bed.double", "Alfama Hotel", "7 nights", "Confirmed", true), R("car", "Airport transfer", "Oct 24, 11:00", "Pending")]),
            .button("Add booking")])
        case .courses: return ScreenDef(tabs: life, active: 2, blocks: [
            .header(sub: "Learning", title: "Courses", icon: "graduationcap"),
            .hero(label: "Continue", value: "SwiftUI Basics", chip: "Lesson 5 of 12"),
            .bars(title: "In progress", items: [B("Design systems", 0.6, "60%"), B("Color theory", 0.3, "30%"), B("Typography", 0.85, "85%")]),
            .button("Resume")])
        case .support: return ScreenDef(tabs: biz, active: 1, blocks: [
            .header(sub: "", title: "Support", icon: "plus"),
            .chips(["Open", "Pending", "Closed"]),
            .list(title: "Tickets", rows: [R("ticket", "Screen flickers", "Ticket 311, Priya K.", "High"), R("ticket", "Battery drains fast", "Ticket 309, Alex M.", "Medium"), R("ticket", "Wrong invoice", "Ticket 304, Sam T.", "Low")]),
            .button("New ticket")])
        case .appointments: return ScreenDef(tabs: biz, active: 1, blocks: [
            .header(sub: "", title: "Appointments", icon: "calendar.badge.plus"),
            .chips(["Today", "Week", "Month"]),
            .list(title: "Upcoming", rows: [R("clock", "Alex Morgan", "Today, 10:30", "Screen repair"), R("clock", "Priya Kapoor", "Today, 1:00", "Battery swap"), R("clock", "Sam Torres", "Tomorrow, 9:15", "Data transfer")]),
            .button("Book appointment")])
        case .team: return ScreenDef(tabs: biz, active: 3, blocks: [
            .header(sub: "", title: "Team", icon: "person.badge.plus"),
            .people(title: "On shift", names: ["Ana", "Ben", "Cho", "Dev", "Eli"]),
            .list(title: "Staff", rows: [R("person.crop.circle", "Ana Silva", "Manager", "On shift", true), R("person.crop.circle", "Ben Okafor", "Technician", "On shift", true), R("person.crop.circle", "Cho Lin", "Sales", "Off")]),
            .button("Add member")])
        case .expenses: return ScreenDef(tabs: biz, active: 0, blocks: [
            .header(sub: "", title: "Expenses", icon: "plus"),
            .hero(label: "This month", value: "$2,184.60", chip: "4% under budget"),
            .bars(title: "Budget", items: [B("Rent", 0.9, "$900"), B("Supplies", 0.55, "$540"), B("Utilities", 0.3, "$210")]),
            .list(title: "Recent", rows: [R("bolt", "Electric bill", "Today", "-$84.20"), R("shippingbox", "Parts order", "Yesterday", "-$312.00")])])
        }
    }
}
