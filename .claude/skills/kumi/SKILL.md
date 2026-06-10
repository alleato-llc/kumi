---
name: kumi
description: Use when generating HTML from Swift — pages, test/report dashboards, emails, static-site fragments — with the Kumi library. Covers the Node tree, tag helpers, the @KumiBuilder closure syntax, conditional content and attributes, full-document assembly, auto-escaping, and streaming render. Apply whenever Swift code imports Kumi or needs to emit HTML safely instead of concatenating strings.
---

# Building HTML with Kumi

Kumi (組, "to assemble") is a tiny, **Foundation-free** Swift HTML builder. You
build a tree of `Node` values and render it to a string. Rendering is the only
thing that emits HTML, so three string-concat bugs are impossible: unescaped
content (text/attrs auto-escape `& < > "`), unclosed tags (every element closes;
void elements emit no closing tag), and nondeterministic attribute order
(attributes are ordered, so output is byte-stable — snapshot tests stay green).

## Install

```swift
.package(url: "https://github.com/alleato-llc/kumi.git", from: "0.4.0"),
// target:
.product(name: "Kumi", package: "kumi")
```

`import Kumi`. Nothing else is needed; Kumi pulls in no transitive dependencies.

## Core API

| Builder | Renders |
|---|---|
| `Node.tag(name, [attrs], [children])` | an element |
| `Node.tag(name, [attrs], text: "…")` | element wrapping one **escaped** text child |
| `Node.text("a < b")` | escaped text → `a &lt; b` |
| `Node.raw("<em>x</em>")` | **trusted** HTML, verbatim — never pass user input |
| `Node.fragment([…])` | several nodes, no wrapper |
| `Node.document(lang: "en", head: […], body: […])` | a full `<!DOCTYPE html>` page |
| `Node.comment("…")` | `<!-- … -->` (content neutralized, safe) |
| `Node.empty` | nothing (`""`) |
| `Node.when(cond) { node }` | the node only when `cond` |
| `Node.optional(node?)` | the node only when non-nil |

Render: `node.render() -> String`. `Node` is `CustomStringConvertible`, so
`"\(node)"` and `print(node)` also render. `[Node].render()` concatenates a list.

## Tag helpers — write code that reads like markup

Prefer the named helpers over `Node.tag("div", …)`. Two array forms per element:
`Node.div([attrs], [children])` and `Node.div([attrs], text: "…")`. Void
elements take attrs only: `Node.br([attrs])`, `Node.input([attrs])`, `Node.img([attrs])`.

Covered: `a article aside br button code details div em footer h1`–`h6` `header
hr img input label li link main meta nav ol p pre script section small span
strong style summary table tbody td th thead title tr ul`. **Anything not listed
still works via `Node.tag(name, …)`** — helpers are sugar, not a closed set.

```swift
let page = Node.section([.id("intro")], [
    .h2([], text: "Hello & welcome"),                  // auto-escaped
    .a([.class("cta"), .href("/start?a=1&b=2")], text: "Start"),
    .details([.class("group"), .flag("open")], [       // boolean attribute
        .summary([], text: "More"),
        .raw("<!-- a trusted, prebuilt block -->"),
    ]),
    .br(),                                              // void → no closing tag
])
print(page.render())
```

## Attributes

`.class(_)`, `.id(_)`, `.href(_)`, `.data(name, value)` (→ `data-name`),
`.attr(name, value)` (anything), `.flag(name)` (boolean, e.g. `open`/`disabled`).
Raw init: `Attribute(name, value: String?)` — a `nil` value is a boolean flag.

Conditional / combined attributes (no ternary, dropped ones render to nothing):

```swift
.classes(["card", active ? "on" : nil])          // → class="card on" (nils drop)
.flag("open", if: isOpen)                          // attribute only when isOpen
.when(selected, .attr("aria-selected", "true"))    // any attribute, only when true
```

## @KumiBuilder — native control flow when nesting

Container helpers (`div span section article header footer nav main aside p a ul
ol li table thead tbody tr th td details summary label pre`, plus
`Node.tag(name, …)`) take **variadic attributes + a `@KumiBuilder` closure**:

```swift
Node.div(.class("card")) {
    Node.h2(text: "Title")
    if showBody { Node.p(text: body) }        // if  → optional
    for row in rows { Node.li(text: row) }    // for → loop
    if let link {                             // if/else → either
        Node.a([.href(link)], text: "More")
    } else {
        Node.empty
    }
    "a bare string is escaped text"           // String → escaped text node
}
```

A builder statement is a `Node`, a `[Node]` (spliced), or a `String` (escaped).
It's opt-in — the array forms still work unchanged. Note the helper *with text*
uses a `text:` label (`Node.h2(text:)`) inside the builder, where the array form
omits the empty `[]`.

## Full document

```swift
Node.document(
    head: [.meta([.attr("charset", "UTF-8")]), .title([], text: "Report")],
    body: [.h1([], text: "Hi")]
).render()
// <!DOCTYPE html><html lang="en"><head>…</head><body><h1>Hi</h1></body></html>
```

## Streaming / appending (Foundation stays in *your* code)

`render() -> String` is built over one worker, `render(to: (String) -> Void)`:

```swift
node.render { handle.write(Data($0.utf8)) }   // stream, no String materialized
var page = ""; node.render(into: &page)        // append into a buffer you hold
```

## Gotchas & conventions

- **`.raw` is an escape hatch for HTML you already trust** — never user input.
  Everything else (text, attribute values) is escaped automatically.
- Output is **deterministic** (ordered attributes, no incidental whitespace) — a
  rendered tree is safe to assert on in snapshot tests.
- Kumi emits **no whitespace of its own**; if you want pretty output, add it.
- Keep Kumi **dependency-free** when extending it: no Foundation, no third-party
  imports in `Sources/Kumi/` (that's the whole point — it can be vendored into a
  library without becoming viral on consumers). Demos under `Examples/` may use
  Foundation; the library may not.

## Deeper examples

Runnable showcases live in `Examples/` (`report`, `invoice`, `article`,
`gallery`) — each builds a styled page with the builder, conditional classes,
and `.flag(_, if:)`. `swift run report` prints one to stdout; `Examples/render.sh`
renders all of them. The README's "Input → output" table is the quickest API
reference.
