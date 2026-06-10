import Foundation
import Kumi

// An invoice rendered from line items — building a real HTML table from data.
// Shows: the table helpers, conditional row classes (`.classes`), computed
// values, and `.empty` for an optional note.

struct LineItem { let description: String; let qty: Int; let unit: Double }

let items = [
    LineItem(description: "Engine license", qty: 1, unit: 1200),
    LineItem(description: "Support hours", qty: 8, unit: 95),
    LineItem(description: "On-site visit", qty: 1, unit: 1500),
]
let total = items.reduce(0) { $0 + Double($1.qty) * $1.unit }

func money(_ amount: Double) -> String { "$" + String(format: "%.2f", amount) }

let css = """
:root { --bg:#fff; --fg:#1a202c; --muted:#718096; --line:#e2e8f0; --accent:#3182ce; --hi:#fffaf0; }
* { box-sizing:border-box; margin:0; }
body { font:16px/1.5 system-ui,sans-serif; color:var(--fg); background:#f7fafc; padding:2.5rem 1rem; }
.invoice { max-width:640px; margin:0 auto; background:var(--bg); border:1px solid var(--line); border-radius:12px; padding:2rem; }
h1 { font-size:1.5rem; } .meta { color:var(--muted); margin:.2rem 0 1.5rem; }
table { width:100%; border-collapse:collapse; }
th, td { text-align:left; padding:.6rem .5rem; border-bottom:1px solid var(--line); }
th { font-size:.75rem; text-transform:uppercase; letter-spacing:.04em; color:var(--muted); }
td.num, th.num { text-align:right; font-variant-numeric:tabular-nums; }
tr.large td { background:var(--hi); }
tfoot td { font-weight:700; border-top:2px solid var(--fg); border-bottom:none; }
.note { color:var(--muted); font-size:.85rem; margin-top:1rem; }
"""

let page = Node.document(head: [
    .meta([.attr("charset", "UTF-8")]),
    .meta([.attr("name", "viewport"), .attr("content", "width=device-width, initial-scale=1")]),
    .title([], text: "Invoice — Kumi demo"),
    .style(css),
], body: [
    Node.section(.class("invoice")) {
        Node.h1(text: "Invoice #2026-014")
        Node.p([.class("meta")], text: "Alleato LLC · due in 30 days")
        Node.table {
            Node.thead {
                Node.tr {
                    Node.th(text: "Description")
                    Node.th([.class("num")], text: "Qty")
                    Node.th([.class("num")], text: "Unit")
                    Node.th([.class("num")], text: "Amount")
                }
            }
            Node.tbody {
                for item in items {
                    let amount = Double(item.qty) * item.unit
                    // Highlight large line items.
                    Node.tr(.classes([amount >= 1000 ? "large" : nil])) {
                        Node.td(text: item.description)
                        Node.td([.class("num")], text: "\(item.qty)")
                        Node.td([.class("num")], text: money(item.unit))
                        Node.td([.class("num")], text: money(amount))
                    }
                }
            }
            Node.tag("tfoot") {
                Node.tr {
                    Node.td([.attr("colspan", "3")], text: "Total")
                    Node.td([.class("num")], text: money(total))
                }
            }
        }
        Node.p([.class("note")], text: "Thank you for your business.")
    },
])

print(page.render())
