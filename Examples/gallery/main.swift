import Kumi

// The gallery index — itself built with Kumi, so the showcase page is its own
// demo. Links the three examples.

struct Demo { let href: String; let title: String; let blurb: String }

let demos = [
    Demo(href: "report.html", title: "Build report",
         blurb: "A test dashboard from a data model — the @KumiBuilder with for/if, conditional `.flag(\"open\", if:)`, and conditional classes."),
    Demo(href: "invoice.html", title: "Invoice table",
         blurb: "A line-item table — the table helpers, conditional row classes, and computed totals."),
    Demo(href: "article.html", title: "Article",
         blurb: "A document with prose and a code block — and a user comment whose <script> is escaped to inert text."),
]

let css = """
:root { --bg:#0f1115; --fg:#e6e6e6; --muted:#9aa0a6; --line:#272b33; --accent:#7aa2f7; }
* { box-sizing:border-box; margin:0; }
body { font:16px/1.6 system-ui,sans-serif; background:var(--bg); color:var(--fg); padding:3rem 1rem; }
.wrap { max-width:680px; margin:0 auto; }
h1 { font-size:2rem; letter-spacing:-.02em; }
.sub { color:var(--muted); margin:.4rem 0 2rem; }
.card { display:block; border:1px solid var(--line); border-radius:12px; padding:1.1rem 1.2rem; margin-bottom:1rem; text-decoration:none; color:inherit; transition:border-color .15s; }
.card:hover { border-color:var(--accent); }
.card h2 { font-size:1.15rem; color:var(--accent); }
.card p { color:var(--muted); margin-top:.3rem; font-size:.95rem; }
footer { color:var(--muted); font-size:.85rem; margin-top:2rem; }
footer a { color:var(--accent); }
"""

let page = Node.document(head: [
    .meta([.attr("charset", "UTF-8")]),
    .meta([.attr("name", "viewport"), .attr("content", "width=device-width, initial-scale=1")]),
    .title([], text: "Kumi 組 — examples"),
    .style(css),
], body: [
    Node.div(.class("wrap")) {
        Node.h1(text: "Kumi 組 — examples")
        Node.p([.class("sub")], text: "Each page below is built with Kumi (including this index).")
        for demo in demos {
            Node.a(.class("card"), .href(demo.href)) {
                Node.h2(text: demo.title)
                Node.p([], text: demo.blurb)
            }
        }
        Node.tag("footer") {
            Node.text("Source: ")
            Node.a([.href("https://github.com/alleato-llc/kumi")], text: "github.com/alleato-llc/kumi")
        }
    },
])

print(page.render())
