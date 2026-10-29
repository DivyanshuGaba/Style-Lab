import SwiftUI

enum Sample {
    struct Row { let icon: String; let title: String; let subtitle: String; let value: String; let positive: Bool }
    static let rows = [
        Row(icon: "cup.and.saucer", title: "Blue Door Coffee", subtitle: "Today, 8:42", value: "-$4.80", positive: false),
        Row(icon: "arrow.down.left", title: "Invoice paid", subtitle: "Yesterday", value: "+$1,200.00", positive: true),
        Row(icon: "bag", title: "Market Street", subtitle: "Monday", value: "-$36.15", positive: false),
    ]
    struct Action { let icon: String; let label: String }
    static let actions = [Action(icon: "paperplane", label: "Send"), Action(icon: "arrow.down.left", label: "Request"),
                          Action(icon: "qrcode.viewfinder", label: "Scan"), Action(icon: "ellipsis", label: "More")]
    static let tabs = [Action(icon: "house", label: "Home"), Action(icon: "creditcard", label: "Cards"),
                       Action(icon: "chart.bar", label: "Insights"), Action(icon: "person", label: "Profile")]
    static let mainIcons = ["paperplane", "arrow.down.left", "qrcode.viewfinder", "bell", "lock", "chart.bar"]
}
