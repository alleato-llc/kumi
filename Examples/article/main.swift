import Kumi

// A docs/blog article — the page-level API plus prose, a code block, and a
// list. The finale is a "user comment" containing markup: Kumi escapes text by
// default, so the <script> arrives as inert, visible text, not as an injection.

let features = [
    "Auto-escaping text and attribute values",
    "Auto-closing tags (void elements emit no close)",
    "Deterministic, ordered attributes",
]

let userComment = "Great post! <script>alert('xss')</script> & keep them coming 👏"

let css = """
:root { --bg:#fffdf9; --fg:#2d2a26; --muted:#6b665e; --line:#e7e2d8; --accent:#b5651d; }
* { box-sizing:border-box; margin:0; }
body { font:17px/1.65 Georgia,'Times New Roman',serif; color:var(--fg); background:var(--bg); padding:3rem 1rem; }
article { max-width:680px; margin:0 auto; }
h1 { font-size:2rem; letter-spacing:-.02em; line-height:1.2; }
.byline { color:var(--muted); font-style:italic; margin:.4rem 0 2rem; }
p { margin:1rem 0; } a { color:var(--accent); }
h2 { font-size:1.3rem; margin:2rem 0 .5rem; }
ul { margin:1rem 0 1rem 1.2rem; }
pre { background:#2d2a26; color:#f3eee4; padding:1rem; border-radius:8px; overflow:auto; font:14px/1.5 ui-monospace,Menlo,monospace; }
.comments { border-top:1px solid var(--line); margin-top:2.5rem; padding-top:1rem; }
.comment { background:#fff; border:1px solid var(--line); border-radius:8px; padding:.8rem 1rem; font-size:.95rem; }
footer { text-align:center; color:var(--muted); font-size:.8rem; margin:2rem 0 0; font-family:system-ui,sans-serif; }
footer a { color:var(--accent); }
"""

let source = "https://github.com/alleato-llc/kumi/blob/main/Examples/article/main.swift"

let page = Node.document(head: [
    .meta([.attr("charset", "UTF-8")]),
    .meta([.attr("name", "viewport"), .attr("content", "width=device-width, initial-scale=1")]),
    .title([], text: "Why escape by default — Kumi demo"),
    .style(css),
], body: [
    Node.article {
        Node.h1(text: "Why a builder escapes by default")
        Node.p([.class("byline")], text: "An example page, itself built with Kumi")
        Node.p([], [
            .text("Hand-written HTML strings leak three bugs: unescaped content, "),
            .text("unclosed tags, and nondeterministic attribute order. A builder "),
            .text("closes the door on all three. The same call site reads as markup:"),
        ])
        Node.pre([], [.code([], text: """
        Node.div([.class("card")], [
            .h2([], text: title),
            .p([], text: body),
        ])
        """)])
        Node.h2(text: "What you get")
        Node.ul {
            for feature in features { Node.li(text: feature) }
        }
        Node.section(.class("comments")) {
            Node.h2(text: "Comments")
            // The comment is untrusted text. Rendered as a text node, its markup
            // is escaped — the <script> shows as characters and never runs.
            Node.div([.class("comment")], text: userComment)
        }
        Node.tag("footer") {
            Node.text("Built with ")
            Node.a([.href("https://github.com/alleato-llc/kumi")], text: "Kumi")
            Node.text(" · ")
            Node.a([.href(source)], text: "view source ↗")
        }
    },
])

print(page.render())
