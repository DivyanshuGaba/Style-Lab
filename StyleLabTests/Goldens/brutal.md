# Design: Ledgerly Neo Brutalism

This file describes the exact look of the design as shown in the Style Lab preview. It contains design values only.

## 1. Overview
- Style: Neo Brutalism. Thick outlines, hard offset shadows and flat, loud color.
- Appearance shown: Dark mode.
- Sample app: Wallet and payments (Balances, cards and payments).
- Screens described: all 6 screens of the Wallet and payments sample: Home, Cards, Insights, Notifications, Settings and Profile.
- Accent color: #2F6BFF.
- Settings: corner roundness 1.00x, depth 60 percent, density Regular (scale 1), icon weight Regular, boost contrast off.
- Canvas: every screen is 390 by 844 pt with no status bar, notch or device frame. The bottom bar is the standard liquid glass bar in every design.

## 2. Colors
- Accent (raw): #2F6BFF
- Accent used for icons and active states (adjusted for contrast): #2F6BFF
- Text on accent (buttons): #000000
- Background: #151515
- Surface (cards): #232323
- Primary text: #FFFFFF
- Secondary text: #E5E5E5
- Separator: #FFFFFF, 3.2 pt
- Positive amount color: #5BE08C
- Toggle on and off: #2F6BFF, #444444
- Selected item in the bottom bar: #2F6BFF

## 3. Shape and effects
- Corner radii: card 6 pt, icon tile 6 pt, button 6 pt. The bottom bar is a full capsule.
- Every element has a 3.2 pt solid outline in #FFFFFF.
- Cards and buttons have a hard shadow offset 6 pt right and down, no blur, in #FFFFFF. Icon tiles use half that offset (3 pt).
- Icon tile fills rotate through #FF6B6B, #FFD93D, #6BCB77, #4D96FF. Chips are #FFD93D with black text and a 2 pt outline.

## 4. Typography
- Typeface: SF with heavy weights
- Large title 34 pt heavy. Title 22 pt heavy. Section title 20 pt heavy. Body 16 pt regular. Caption 12.5 pt medium. Tab label 10 pt medium. Large amount 40 pt black.
- Labels are uppercase with 0.06 em tracking. Headings use heavy weight and big numbers use black weight.

## 5. Icons and spacing
- Icon stroke weight 2.4 pt (Regular). Icon sizes: 22 pt in the bottom bar, 28 pt in quick action tiles, 21 pt in list rows.
- Icon container: 62 pt in quick actions and 42 pt in rows, 6 pt radius. 62 pt near square tile with 3.2 pt outline and hard shadow, rotating flat fills, black icon, label below at 12 pt semibold uppercase.
- Icon color: black on the colored tile.
- Density Regular, scale 1. Screen side margin 20 pt. Gap between blocks 18 pt. List row padding 12 pt vertical and 16 pt horizontal.

## 6. Components
- Card: Every element has a 3.2 pt solid white outline and a hard offset shadow of 6 pt with no blur. Fills are flat and saturated. Labels are uppercase. Corners are nearly square (18 pt).
- List row: icon tile at the left (42 pt), title and subtitle in the middle, value at the right, separated by #FFFFFF, 3.2 pt.
- Quick action: 62 pt near square tile with 3.2 pt outline and hard shadow, rotating flat fills, black icon, label below at 12 pt semibold uppercase.
- Primary button: fill #2F6BFF, #000000 label, 6 pt corners, 52 pt tall, uppercase label with 0.05 em tracking, 3.2 pt outline and hard shadow.
- Chip: fully rounded, fill #FFD93D, text #000000, 2 pt outline #FFFFFF.
- Toggle: 51 by 31 pt, on is #2F6BFF, off is #444444, square knob and corners.
- Bottom bar (identical in every design): a floating liquid glass tab bar, like the one in iOS 26 and later. It is a full capsule, 62 pt tall, inset 20 pt from the left and right edges and 24 pt above the bottom edge, with four evenly spaced items.
- Bottom bar background: the system ultra thin material (the native liquid glass effect on iOS 26 and later), a 1 pt border in white at 0.22 opacity and a soft shadow (black at 0.18 opacity, blur 18 pt, 8 pt down). With Reduce Transparency on, the fill is solid #1C1C1E.
- Bottom bar items: each item stacks a 22 pt SF Symbol above a 10 pt medium label. The selected item sits on an inner rounded pill inset 5 pt from the bar (white at 0.12 opacity) and is drawn in the accent color #2F6BFF. Unselected items are white at 0.9 opacity.
- Layout: screens are stacked blocks from top to bottom.

## 7. Light and dark mode
The same design in both appearances. The shape, spacing, typography and icon weight are identical in both.
- Outlines and hard shadows are white in dark mode and black in light mode. The background goes from near black to cream. The fills are the same.

Dark mode (shown in the preview):
- Background: #151515
- Surface (cards): #232323
- Primary text: #FFFFFF. Secondary text: #E5E5E5
- Separator: #FFFFFF, 3.2 pt. Positive amount color: #5BE08C
- Accent for icons and active states: #2F6BFF. Text on accent: #000000
- Toggle on and off: #2F6BFF, #444444
- Every element has a 3.2 pt solid outline in #FFFFFF.
- Cards and buttons have a hard shadow offset 6 pt right and down, no blur, in #FFFFFF. Icon tiles use half that offset (3 pt).
- Icon tile fills rotate through #FF6B6B, #FFD93D, #6BCB77, #4D96FF. Chips are #FFD93D with black text and a 2 pt outline.
- Bottom bar: pill behind the selected item is white at 0.12 opacity, border white at 0.22 opacity, unselected items white at 0.9 opacity.

Light mode:
- Background: #FFF7D1
- Surface (cards): #FFFFFF
- Primary text: #000000. Secondary text: #222222
- Separator: #000000, 3.2 pt. Positive amount color: #12794A
- Accent for icons and active states: #2F6BFF. Text on accent: #000000
- Toggle on and off: #2F6BFF, #DDDDDD
- Every element has a 3.2 pt solid outline in #000000.
- Cards and buttons have a hard shadow offset 6 pt right and down, no blur, in #000000. Icon tiles use half that offset (3 pt).
- Icon tile fills rotate through #FF6B6B, #FFD93D, #6BCB77, #4D96FF. Chips are #FFD93D with black text and a 2 pt outline.
- Bottom bar: pill behind the selected item is black at 0.07 opacity, border white at 0.7 opacity, unselected items black at 0.75 opacity.

## 8. Screens
All 6 screens of the Wallet and payments sample, each with every part as it appears in the preview, in reading order from top to bottom. Positions are in points from the top left of the 390 by 844 canvas. Text content is placeholder text for the Wallet and payments sample.

### Home screen
Canvas 390 by 844 pt. Background: #151515.
- Small heading: Text "Good evening", 12.5 pt medium, color #E5E5E5. Position x 20, y 20, size 83 by 15 pt.
- Header icon: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bell at 20 pt semibold, color #000000. Position x 328, y 28, size 42 by 42 pt.
- Screen title: Text "Wallet", 34 pt heavy, color #FFFFFF. Position x 20, y 37, size 104 by 41 pt.
- Hero card: Hero card with 18 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 96, size 350 by 136 pt.
- Hero label: Text "Total balance", 12.5 pt medium, color #E5E5E5, shown in capitals with 0.75 pt letter spacing. Position x 38, y 114, size 112 by 15 pt.
- Hero value: Text "$12,480.50", 40 pt black, color #FFFFFF. Position x 38, y 135, size 237 by 48 pt.
- Hero chip: Chip "+2.4% this week", 12.5 pt semibold, capsule, fill #FFD93D, text #000000, 2 pt outline #FFFFFF, padding 10 by 5 pt. Position x 38, y 189, size 122 by 25 pt.
- Action: Send: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol paperplane at 28 pt semibold, color #000000. Position x 30, y 250, size 62 by 62 pt.
- Action: Request: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol arrow.down.left at 28 pt semibold, color #000000. Position x 119, y 250, size 62 by 62 pt.
- Action: Scan: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol qrcode.viewfinder at 28 pt semibold, color #000000. Position x 209, y 250, size 62 by 62 pt.
- Action: More: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol ellipsis at 28 pt semibold, color #000000. Position x 298, y 250, size 62 by 62 pt.
- Action label: Send: Text "Send", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 42, y 318, size 38 by 15 pt.
- Action label: Request: Text "Request", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 118, y 318, size 65 by 15 pt.
- Action label: Scan: Text "Scan", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 220, y 318, size 39 by 15 pt.
- Action label: More: Text "More", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 309, y 318, size 40 by 15 pt.
- Section title: Recent: Text "Recent", 20 pt heavy, color #FFFFFF. Position x 20, y 351, size 69 by 24 pt.
- List card: Recent: List card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 385, size 350 by 199 pt.
- Row: Blue Door Coffee: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 385, size 350 by 66 pt.
- Row icon: Blue Door Coffee: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol cup.and.saucer at 21 pt semibold, color #000000. Position x 36, y 397, size 42 by 42 pt.
- Row title: Blue Door Coffee: Text "Blue Door Coffee", 16 pt semibold, color #FFFFFF. Position x 90, y 400, size 129 by 20 pt.
- Row value: Blue Door Coffee: Text "-$4.80", 16 pt semibold, color #FFFFFF. Position x 301, y 408, size 53 by 20 pt.
- Row subtitle: Blue Door Coffee: Text "Today, 8:42", 12.5 pt medium, color #E5E5E5. Position x 90, y 422, size 71 by 15 pt.
- Row: Invoice paid: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 452, size 350 by 66 pt.
- Row icon: Invoice paid: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol arrow.down.left at 21 pt semibold, color #000000. Position x 36, y 464, size 42 by 42 pt.
- Row title: Invoice paid: Text "Invoice paid", 16 pt semibold, color #FFFFFF. Position x 90, y 467, size 91 by 20 pt.
- Row value: Invoice paid: Text "+$1,200.00", 16 pt semibold, color #5BE08C. Position x 267, y 475, size 87 by 20 pt.
- Row subtitle: Invoice paid: Text "Yesterday", 12.5 pt medium, color #E5E5E5. Position x 90, y 489, size 60 by 15 pt.
- Row: Market Street: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 518, size 350 by 66 pt.
- Row icon: Market Street: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bag at 21 pt semibold, color #000000. Position x 36, y 530, size 42 by 42 pt.
- Row title: Market Street: Text "Market Street", 16 pt semibold, color #FFFFFF. Position x 90, y 533, size 104 by 20 pt.
- Row value: Market Street: Text "-$36.15", 16 pt semibold, color #FFFFFF. Position x 294, y 541, size 60 by 20 pt.
- Row subtitle: Market Street: Text "Monday", 12.5 pt medium, color #E5E5E5. Position x 90, y 555, size 48 by 15 pt.
- Button: Add money: Primary button "Add money", fill #2F6BFF, label 16 pt semibold in #000000, 52 pt tall, full width, corner radius 6 pt. Position x 20, y 602, size 350 by 52 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", selected, symbol house at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", not selected, symbol creditcard at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", not selected, symbol chart.bar at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", not selected, symbol person at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 280, y 763, size 85 by 52 pt.

### Cards screen
Canvas 390 by 844 pt. Background: #151515.
- Header icon: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol plus at 20 pt semibold, color #000000. Position x 328, y 20, size 42 by 42 pt.
- Screen title: Text "Cards", 34 pt heavy, color #FFFFFF. Position x 20, y 21, size 99 by 41 pt.
- Hero card: Hero card with 18 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 80, size 350 by 136 pt.
- Hero label: Text "Card balance", 12.5 pt medium, color #E5E5E5, shown in capitals with 0.75 pt letter spacing. Position x 38, y 98, size 107 by 15 pt.
- Hero value: Text "$3,204.18", 40 pt black, color #FFFFFF. Position x 38, y 119, size 208 by 48 pt.
- Hero chip: Chip "Ends 4821", 12.5 pt semibold, capsule, fill #FFD93D, text #000000, 2 pt outline #FFFFFF, padding 10 by 5 pt. Position x 38, y 173, size 84 by 25 pt.
- Action: Freeze: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol lock at 28 pt semibold, color #000000. Position x 30, y 234, size 62 by 62 pt.
- Action: Details: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol eye at 28 pt semibold, color #000000. Position x 119, y 234, size 62 by 62 pt.
- Action: Limits: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol arrow.left.arrow.right at 28 pt semibold, color #000000. Position x 209, y 234, size 62 by 62 pt.
- Action: More: Icon tile 62 by 62 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol ellipsis at 28 pt semibold, color #000000. Position x 298, y 234, size 62 by 62 pt.
- Action label: Freeze: Text "Freeze", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 35, y 302, size 52 by 15 pt.
- Action label: Details: Text "Details", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 121, y 302, size 58 by 15 pt.
- Action label: Limits: Text "Limits", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 216, y 302, size 47 by 15 pt.
- Action label: More: Text "More", 12.5 pt semibold, color #FFFFFF, shown in capitals with 0.75 pt letter spacing. Position x 309, y 302, size 40 by 15 pt.
- Section title: Transactions: Text "Transactions", 20 pt heavy, color #FFFFFF. Position x 20, y 335, size 128 by 24 pt.
- List card: Transactions: List card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 369, size 350 by 199 pt.
- Row: Grocery Mart: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 369, size 350 by 66 pt.
- Row icon: Grocery Mart: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol cart at 21 pt semibold, color #000000. Position x 36, y 381, size 42 by 42 pt.
- Row title: Grocery Mart: Text "Grocery Mart", 16 pt semibold, color #FFFFFF. Position x 90, y 384, size 101 by 20 pt.
- Row value: Grocery Mart: Text "-$62.40", 16 pt semibold, color #FFFFFF. Position x 291, y 392, size 63 by 20 pt.
- Row subtitle: Grocery Mart: Text "Today", 12.5 pt medium, color #E5E5E5. Position x 90, y 406, size 36 by 15 pt.
- Row: Noodle Bar: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 436, size 350 by 66 pt.
- Row icon: Noodle Bar: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol fork.knife at 21 pt semibold, color #000000. Position x 36, y 448, size 42 by 42 pt.
- Row title: Noodle Bar: Text "Noodle Bar", 16 pt semibold, color #FFFFFF. Position x 90, y 451, size 84 by 20 pt.
- Row value: Noodle Bar: Text "-$18.00", 16 pt semibold, color #FFFFFF. Position x 294, y 459, size 60 by 20 pt.
- Row subtitle: Noodle Bar: Text "Yesterday", 12.5 pt medium, color #E5E5E5. Position x 90, y 473, size 60 by 15 pt.
- Row: Refund: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 502, size 350 by 66 pt.
- Row icon: Refund: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol arrow.down.left at 21 pt semibold, color #000000. Position x 36, y 514, size 42 by 42 pt.
- Row title: Refund: Text "Refund", 16 pt semibold, color #FFFFFF. Position x 90, y 517, size 55 by 20 pt.
- Row value: Refund: Text "+$24.99", 16 pt semibold, color #5BE08C. Position x 288, y 525, size 66 by 20 pt.
- Row subtitle: Refund: Text "Monday", 12.5 pt medium, color #E5E5E5. Position x 90, y 539, size 48 by 15 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", not selected, symbol house at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", selected, symbol creditcard at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", not selected, symbol chart.bar at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", not selected, symbol person at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 280, y 763, size 85 by 52 pt.

### Insights screen
Canvas 390 by 844 pt. Background: #151515.
- Small heading: Text "This week", 12.5 pt medium, color #E5E5E5. Position x 20, y 20, size 61 by 15 pt.
- Header icon: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol calendar at 20 pt semibold, color #000000. Position x 328, y 28, size 42 by 42 pt.
- Screen title: Text "Insights", 34 pt heavy, color #FFFFFF. Position x 20, y 37, size 134 by 41 pt.
- Hero card: Hero card with 18 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 96, size 350 by 136 pt.
- Hero label: Text "Revenue", 12.5 pt medium, color #E5E5E5, shown in capitals with 0.75 pt letter spacing. Position x 38, y 114, size 64 by 15 pt.
- Hero value: Text "$18,420", 40 pt black, color #FFFFFF. Position x 38, y 135, size 172 by 48 pt.
- Hero chip: Chip "+8.2%", 12.5 pt semibold, capsule, fill #FFD93D, text #000000, 2 pt outline #FFFFFF, padding 10 by 5 pt. Position x 38, y 189, size 61 by 25 pt.
- Section title: By category: Text "By category", 20 pt heavy, color #FFFFFF. Position x 20, y 250, size 118 by 24 pt.
- Progress: Phones: Progress card with 14 pt side padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 284, size 350 by 58 pt.
- Progress name: Phones: Text "Phones", 16 pt semibold, color #FFFFFF. Position x 34, y 296, size 57 by 20 pt.
- Progress value: Phones: Text "$9.1k", 12.5 pt medium, color #E5E5E5. Position x 323, y 299, size 33 by 15 pt.
- Progress bar: Phones: Progress bar, 8 pt tall capsule, track #FFFFFF, 3.2 pt, fill #2F6BFF, 80 percent filled. Position x 34, y 322, size 322 by 8 pt.
- Progress: Accessories: Progress card with 14 pt side padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 352, size 350 by 58 pt.
- Progress name: Accessories: Text "Accessories", 16 pt semibold, color #FFFFFF. Position x 34, y 364, size 92 by 20 pt.
- Progress value: Accessories: Text "$5.2k", 12.5 pt medium, color #E5E5E5. Position x 322, y 367, size 34 by 15 pt.
- Progress bar: Accessories: Progress bar, 8 pt tall capsule, track #FFFFFF, 3.2 pt, fill #2F6BFF, 50 percent filled. Position x 34, y 390, size 322 by 8 pt.
- Progress: Repairs: Progress card with 14 pt side padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 420, size 350 by 58 pt.
- Progress name: Repairs: Text "Repairs", 16 pt semibold, color #FFFFFF. Position x 34, y 432, size 57 by 20 pt.
- Progress value: Repairs: Text "$4.1k", 12.5 pt medium, color #E5E5E5. Position x 323, y 435, size 33 by 15 pt.
- Progress bar: Repairs: Progress bar, 8 pt tall capsule, track #FFFFFF, 3.2 pt, fill #2F6BFF, 30 percent filled. Position x 34, y 458, size 322 by 8 pt.
- Stat tile: Orders: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 496, size 169 by 67 pt.
- Stat tile: Visitors: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 201, y 496, size 169 by 67 pt.
- Stat number: Orders: Text "214", 22 pt heavy, color #FFFFFF. Position x 80, y 508, size 40 by 27 pt.
- Stat number: Visitors: Text "96", 22 pt heavy, color #FFFFFF. Position x 261, y 508, size 30 by 27 pt.
- Stat icon: Orders: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol cart at 18 pt semibold, color #000000. Position x 32, y 511, size 38 by 38 pt.
- Stat icon: Visitors: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol person.2 at 18 pt semibold, color #000000. Position x 213, y 511, size 38 by 38 pt.
- Stat label: Orders: Text "Orders", 12.5 pt medium, color #E5E5E5. Position x 80, y 536, size 42 by 15 pt.
- Stat label: Visitors: Text "Visitors", 12.5 pt medium, color #E5E5E5. Position x 261, y 536, size 46 by 15 pt.
- Stat tile: Conversion: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 575, size 169 by 67 pt.
- Stat tile: Refunds: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 201, y 575, size 169 by 67 pt.
- Stat number: Conversion: Text "4.1%", 22 pt heavy, color #FFFFFF. Position x 80, y 587, size 54 by 27 pt.
- Stat number: Refunds: Text "6", 22 pt heavy, color #FFFFFF. Position x 261, y 587, size 15 by 27 pt.
- Stat icon: Conversion: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol percent at 18 pt semibold, color #000000. Position x 32, y 590, size 38 by 38 pt.
- Stat icon: Refunds: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol arrow.uturn.left at 18 pt semibold, color #000000. Position x 213, y 590, size 38 by 38 pt.
- Stat label: Conversion: Text "Conversion", 12.5 pt medium, color #E5E5E5. Position x 80, y 615, size 68 by 15 pt.
- Stat label: Refunds: Text "Refunds", 12.5 pt medium, color #E5E5E5. Position x 261, y 615, size 50 by 15 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", not selected, symbol house at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", not selected, symbol creditcard at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", selected, symbol chart.bar at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", not selected, symbol person at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 280, y 763, size 85 by 52 pt.

### Notifications screen
Canvas 390 by 844 pt. Background: #151515.
- Header icon: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol checkmark.circle at 20 pt semibold, color #000000. Position x 328, y 20, size 42 by 42 pt.
- Screen title: Text "Notifications", 34 pt heavy, color #FFFFFF. Position x 20, y 21, size 214 by 41 pt.
- Filter: All: Chip "All", 12.5 pt semibold, capsule, selected, fill #2F6BFF, text #000000, padding 12 by 8 pt. Position x 20, y 80, size 40 by 31 pt.
- Filter: Unread: Chip "Unread", 12.5 pt semibold, capsule, not selected, fill #FFFFFF, 3.2 pt, text #E5E5E5, padding 12 by 8 pt. Position x 68, y 80, size 69 by 31 pt.
- Filter: Mentions: Chip "Mentions", 12.5 pt semibold, capsule, not selected, fill #FFFFFF, 3.2 pt, text #E5E5E5, padding 12 by 8 pt. Position x 145, y 80, size 81 by 31 pt.
- Section title: Today: Text "Today", 20 pt heavy, color #FFFFFF. Position x 20, y 129, size 59 by 24 pt.
- List card: Today: List card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 163, size 350 by 266 pt.
- Row: Payment received: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 163, size 350 by 66 pt.
- Row icon: Payment received: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bell at 21 pt semibold, color #000000. Position x 36, y 175, size 42 by 42 pt.
- Row title: Payment received: Text "Payment received", 16 pt semibold, color #FFFFFF. Position x 90, y 178, size 136 by 20 pt.
- Row value: Payment received: Text "2m", 16 pt semibold, color #FFFFFF. Position x 330, y 186, size 24 by 20 pt.
- Row subtitle: Payment received: Text "Invoice 1042", 12.5 pt medium, color #E5E5E5. Position x 90, y 200, size 76 by 15 pt.
- Row: Maya sent a message: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 230, size 350 by 66 pt.
- Row icon: Maya sent a message: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bubble.left at 21 pt semibold, color #000000. Position x 36, y 242, size 42 by 42 pt.
- Row title: Maya sent a message: Text "Maya sent a message", 16 pt semibold, color #FFFFFF. Position x 90, y 245, size 163 by 20 pt.
- Row value: Maya sent a message: Text "1h", 16 pt semibold, color #FFFFFF. Position x 336, y 253, size 18 by 20 pt.
- Row subtitle: Maya sent a message: Text "See you at 7?", 12.5 pt medium, color #E5E5E5. Position x 90, y 267, size 80 by 15 pt.
- Row: Price drop: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 296, size 350 by 66 pt.
- Row icon: Price drop: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol tag at 21 pt semibold, color #000000. Position x 36, y 308, size 42 by 42 pt.
- Row title: Price drop: Text "Price drop", 16 pt semibold, color #FFFFFF. Position x 90, y 311, size 78 by 20 pt.
- Row value: Price drop: Text "3h", 16 pt semibold, color #FFFFFF. Position x 334, y 319, size 20 by 20 pt.
- Row subtitle: Price drop: Text "USB C cable", 12.5 pt medium, color #E5E5E5. Position x 90, y 333, size 74 by 15 pt.
- Row: Order shipped: List row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 363, size 350 by 66 pt.
- Row icon: Order shipped: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol shippingbox at 21 pt semibold, color #000000. Position x 36, y 375, size 42 by 42 pt.
- Row title: Order shipped: Text "Order shipped", 16 pt semibold, color #FFFFFF. Position x 90, y 378, size 109 by 20 pt.
- Row value: Order shipped: Text "5h", 16 pt semibold, color #FFFFFF. Position x 334, y 386, size 20 by 20 pt.
- Row subtitle: Order shipped: Text "Order 2041", 12.5 pt medium, color #E5E5E5. Position x 90, y 400, size 68 by 15 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", selected, symbol house at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", not selected, symbol creditcard at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", not selected, symbol chart.bar at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", not selected, symbol person at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 280, y 763, size 85 by 52 pt.

### Settings screen
Canvas 390 by 844 pt. Background: #151515.
- Screen title: Text "Settings", 34 pt heavy, color #FFFFFF. Position x 20, y 20, size 140 by 41 pt.
- Profile card: Profile card with 16 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 79, size 350 by 86 pt.
- Profile avatar: Icon tile 54 by 54 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol person at 26 pt semibold, color #000000. Position x 36, y 95, size 54 by 54 pt.
- Profile name: Text "Alex Morgan", 20 pt heavy, color #FFFFFF. Position x 102, y 102, size 122 by 24 pt.
- Profile email: Text "alex@example.com", 12.5 pt medium, color #E5E5E5. Position x 102, y 128, size 116 by 15 pt.
- Settings group: Grouped settings card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 183, size 350 by 199 pt.
- Row: Notifications: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 183, size 350 by 66 pt.
- Row icon: Notifications: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bell at 21 pt semibold, color #000000. Position x 36, y 195, size 42 by 42 pt.
- Switch: Notifications: Switch 51 by 31 pt, on, on color #2F6BFF, off color #444444. Position x 303, y 201, size 51 by 31 pt.
- Row label: Notifications: Text "Notifications", 16 pt regular, color #FFFFFF. Position x 90, y 206, size 92 by 20 pt.
- Row: Face ID: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 250, size 350 by 66 pt.
- Row icon: Face ID: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol faceid at 21 pt semibold, color #000000. Position x 36, y 262, size 42 by 42 pt.
- Switch: Face ID: Switch 51 by 31 pt, on, on color #2F6BFF, off color #444444. Position x 303, y 268, size 51 by 31 pt.
- Row label: Face ID: Text "Face ID", 16 pt regular, color #FFFFFF. Position x 90, y 273, size 54 by 20 pt.
- Row: Dark appearance: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 316, size 350 by 66 pt.
- Row icon: Dark appearance: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol moon at 21 pt semibold, color #000000. Position x 36, y 328, size 42 by 42 pt.
- Switch: Dark appearance: Switch 51 by 31 pt, off, on color #2F6BFF, off color #444444. Position x 303, y 334, size 51 by 31 pt.
- Row label: Dark appearance: Text "Dark appearance", 16 pt regular, color #FFFFFF. Position x 90, y 339, size 124 by 20 pt.
- Settings group: Grouped settings card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 400, size 350 by 199 pt.
- Row: Language: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 400, size 350 by 66 pt.
- Row icon: Language: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol globe at 21 pt semibold, color #000000. Position x 36, y 412, size 42 by 42 pt.
- Row label: Language: Text "Language", 16 pt regular, color #FFFFFF. Position x 90, y 423, size 72 by 20 pt.
- Arrow: Language: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 426, size 12 by 15 pt.
- Row: Privacy: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 467, size 350 by 66 pt.
- Row icon: Privacy: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol lock at 21 pt semibold, color #000000. Position x 36, y 479, size 42 by 42 pt.
- Row label: Privacy: Text "Privacy", 16 pt regular, color #FFFFFF. Position x 90, y 490, size 53 by 20 pt.
- Arrow: Privacy: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 493, size 12 by 15 pt.
- Row: Help: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 533, size 350 by 66 pt.
- Row icon: Help: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol ellipsis at 21 pt semibold, color #000000. Position x 36, y 545, size 42 by 42 pt.
- Row label: Help: Text "Help", 16 pt regular, color #FFFFFF. Position x 90, y 556, size 34 by 20 pt.
- Arrow: Help: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 559, size 12 by 15 pt.
- Button: Save changes: Primary button "Save changes", fill #2F6BFF, label 16 pt semibold in #000000, 52 pt tall, full width, corner radius 6 pt. Position x 20, y 617, size 350 by 52 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", not selected, symbol house at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", not selected, symbol creditcard at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", not selected, symbol chart.bar at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", selected, symbol person at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 280, y 763, size 85 by 52 pt.

### Profile screen
Canvas 390 by 844 pt. Background: #151515.
- Header icon: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol gearshape at 20 pt semibold, color #000000. Position x 328, y 20, size 42 by 42 pt.
- Screen title: Text "Profile", 34 pt heavy, color #FFFFFF. Position x 20, y 21, size 108 by 41 pt.
- Profile card: Profile card with 16 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 80, size 350 by 86 pt.
- Profile avatar: Icon tile 54 by 54 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol person at 26 pt semibold, color #000000. Position x 36, y 96, size 54 by 54 pt.
- Profile name: Text "Alex Morgan", 20 pt heavy, color #FFFFFF. Position x 102, y 103, size 122 by 24 pt.
- Profile email: Text "alex@example.com", 12.5 pt medium, color #E5E5E5. Position x 102, y 129, size 116 by 15 pt.
- Stat tile: Orders: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 184, size 169 by 67 pt.
- Stat tile: Reviews: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 201, y 184, size 169 by 67 pt.
- Stat number: Orders: Text "12", 22 pt heavy, color #FFFFFF. Position x 80, y 196, size 25 by 27 pt.
- Stat number: Reviews: Text "4", 22 pt heavy, color #FFFFFF. Position x 261, y 196, size 15 by 27 pt.
- Stat icon: Orders: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol bag at 18 pt semibold, color #000000. Position x 32, y 199, size 38 by 38 pt.
- Stat icon: Reviews: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol star at 18 pt semibold, color #000000. Position x 213, y 199, size 38 by 38 pt.
- Stat label: Orders: Text "Orders", 12.5 pt medium, color #E5E5E5. Position x 80, y 224, size 42 by 15 pt.
- Stat label: Reviews: Text "Reviews", 12.5 pt medium, color #E5E5E5. Position x 261, y 224, size 50 by 15 pt.
- Stat tile: Coupons: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 20, y 263, size 169 by 67 pt.
- Stat tile: Saved: Stat tile with 12 pt padding, standard card style (section 6), corner radius 6 pt. Position x 201, y 263, size 169 by 67 pt.
- Stat number: Coupons: Text "2", 22 pt heavy, color #FFFFFF. Position x 80, y 275, size 14 by 27 pt.
- Stat number: Saved: Text "9", 22 pt heavy, color #FFFFFF. Position x 261, y 275, size 15 by 27 pt.
- Stat icon: Coupons: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol ticket at 18 pt semibold, color #000000. Position x 32, y 278, size 38 by 38 pt.
- Stat icon: Saved: Icon tile 38 by 38 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol heart at 18 pt semibold, color #000000. Position x 213, y 278, size 38 by 38 pt.
- Stat label: Coupons: Text "Coupons", 12.5 pt medium, color #E5E5E5. Position x 80, y 303, size 54 by 15 pt.
- Stat label: Saved: Text "Saved", 12.5 pt medium, color #E5E5E5. Position x 261, y 303, size 37 by 15 pt.
- Settings group: Grouped settings card, rows separated by hairlines (#FFFFFF, 3.2 pt), standard card style (section 6), corner radius 6 pt. Position x 20, y 348, size 350 by 199 pt.
- Row: Edit details: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 348, size 350 by 66 pt.
- Row icon: Edit details: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol person at 21 pt semibold, color #000000. Position x 36, y 360, size 42 by 42 pt.
- Row label: Edit details: Text "Edit details", 16 pt regular, color #FFFFFF. Position x 90, y 371, size 80 by 20 pt.
- Arrow: Edit details: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 374, size 12 by 15 pt.
- Row: Payment methods: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 415, size 350 by 66 pt.
- Row icon: Payment methods: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol creditcard at 21 pt semibold, color #000000. Position x 36, y 427, size 42 by 42 pt.
- Row label: Payment methods: Text "Payment methods", 16 pt regular, color #FFFFFF. Position x 90, y 438, size 132 by 20 pt.
- Arrow: Payment methods: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 441, size 12 by 15 pt.
- Row: Addresses: Settings row with 12 pt vertical and 16 pt horizontal padding. Position x 20, y 481, size 350 by 66 pt.
- Row icon: Addresses: Icon tile 42 by 42 pt in the standard tile style (Quick action in section 6), corner radius 6 pt, symbol mappin.and.ellipse at 21 pt semibold, color #000000. Position x 36, y 493, size 42 by 42 pt.
- Row label: Addresses: Text "Addresses", 16 pt regular, color #FFFFFF. Position x 90, y 504, size 77 by 20 pt.
- Arrow: Addresses: Symbol chevron.right at 14 pt semibold, color #E5E5E5. Position x 342, y 507, size 12 by 15 pt.
- Button: Sign out: Primary button "Sign out", fill #2F6BFF, label 16 pt semibold in #000000, 52 pt tall, full width, corner radius 6 pt. Position x 20, y 565, size 350 by 52 pt.
- Bottom bar: Standard liquid glass bottom bar (section 6). Position x 20, y 758, size 350 by 62 pt.
- Tab: Home: Tab "Home", not selected, symbol house at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 25, y 763, size 85 by 52 pt.
- Tab: Cards: Tab "Cards", not selected, symbol creditcard at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 110, y 763, size 85 by 52 pt.
- Tab: Insights: Tab "Insights", not selected, symbol chart.bar at 22 pt, label 10 pt medium, color #FFFFFF at 0.9 opacity. Position x 195, y 763, size 85 by 52 pt.
- Tab: Profile: Tab "Profile", selected, symbol person at 22 pt, label 10 pt medium, color #2F6BFF, on the inner pill. Position x 280, y 763, size 85 by 52 pt.

## 9. Contrast measurements
- Body text on surface: 15.7:1 (Pass, target 4.5).
- Secondary text on surface: 12.5:1 (Pass, target 4.5).
- Raw accent as an icon: 3.5:1 (Pass, target 3).
- Button label on accent: 4.7:1 (Pass, target 4.5).

## 10. Machine readable design
```json
{
  "design" : {
    "accentHex" : "#2F6BFF",
    "app" : "wallet",
    "boostContrast" : false,
    "brief" : {
      "appName" : "Ledgerly",
      "category" : "finance",
      "context" : "night",
      "effort" : "simple",
      "mood" : "calm",
      "oneLiner" : "A budgeting app for freelancers who hate spreadsheets"
    },
    "createdAt" : "2023-11-14T22:13:20Z",
    "density" : "regular",
    "depth" : 0.6,
    "edits" : {

    },
    "hideDetails" : false,
    "iconWeight" : "regular",
    "id" : "00000000-0000-0000-0000-000000000001",
    "imports" : [

    ],
    "mode" : "dark",
    "name" : "Ledgerly Neo Brutalism",
    "notes" : "Keep icons easy to see at night.",
    "radiusScale" : 1,
    "satisfaction" : [
      "iconsHardToSee"
    ],
    "screens" : [
      "home",
      "settings"
    ],
    "style" : "brutal",
    "tabBar" : "styleDefault",
    "typeface" : "styleDefault",
    "updatedAt" : "2023-11-14T22:13:20Z"
  },
  "resolved" : {
    "chosen" : {
      "accentAdjusted" : "#2F6BFF",
      "accentRaw" : "#2F6BFF",
      "background" : "#151515",
      "blockGap" : 18,
      "buttonRadius" : 6,
      "cardRadius" : 6,
      "contrastBodyText" : 15.72,
      "contrastButtonLabel" : 4.67,
      "contrastRawAccentIcon" : 3.49,
      "contrastSecondaryText" : 12.48,
      "iconStrokeWidth" : 2.4,
      "mode" : "dark",
      "onAccent" : "#000000",
      "positive" : "#5BE08C",
      "rowPaddingHorizontal" : 16,
      "rowPaddingVertical" : 12,
      "screenMargin" : 20,
      "secondaryText" : "#E5E5E5",
      "separator" : "#FFFFFF, 3.2 pt",
      "spacingScale" : 1,
      "surface" : "#232323",
      "tabBarHeight" : 62,
      "tabBarRadius" : 31,
      "text" : "#FFFFFF",
      "tileRadius" : 6,
      "toggleOff" : "#444444",
      "toggleOn" : "#2F6BFF",
      "typeface" : "SF with heavy weights"
    },
    "opposite" : {
      "accentAdjusted" : "#2F6BFF",
      "accentRaw" : "#2F6BFF",
      "background" : "#FFF7D1",
      "blockGap" : 18,
      "buttonRadius" : 6,
      "cardRadius" : 6,
      "contrastBodyText" : 21,
      "contrastButtonLabel" : 4.67,
      "contrastRawAccentIcon" : 4.5,
      "contrastSecondaryText" : 15.91,
      "iconStrokeWidth" : 2.4,
      "mode" : "light",
      "onAccent" : "#000000",
      "positive" : "#12794A",
      "rowPaddingHorizontal" : 16,
      "rowPaddingVertical" : 12,
      "screenMargin" : 20,
      "secondaryText" : "#222222",
      "separator" : "#000000, 3.2 pt",
      "spacingScale" : 1,
      "surface" : "#FFFFFF",
      "tabBarHeight" : 62,
      "tabBarRadius" : 31,
      "text" : "#000000",
      "tileRadius" : 6,
      "toggleOff" : "#DDDDDD",
      "toggleOn" : "#2F6BFF",
      "typeface" : "SF with heavy weights"
    }
  },
  "schemaVersion" : 1
}
```
