# Kumi 組

A tiny, dependency-free HTML builder for Swift.

*Kumi* (組 — *kumu*, "to assemble / braid") builds markup as a tree of `Node`s
and renders it to a string. Rendering is the only thing that emits HTML, so the
three classic string-concatenation bugs can't happen:

- **Unescaped content** — text nodes and attribute values escape `& < > "`
  automatically; you reach for `.raw(_:)` only for HTML you already trust.
- **Unclosed tags** — every element closes on render; void elements
  (`<br>`, `<meta>`, `<img>`, …) correctly emit no closing tag.
- **Nondeterministic attribute order** — attributes are an ordered array, so
  the same tree always renders byte-for-byte the same (your snapshot tests stay
  stable).

No Foundation, no third-party dependencies — safe to vendor into a library
without making that dependency viral on its consumers.

## Use

```swift
import Kumi

let page = Node.section([.id("intro")], [
    .h2([], text: "Hello & welcome"),                 // text auto-escaped
    .a([.class("cta"), .href("/start?a=1&b=2")], text: "Start"),
    .details([.class("group"), .flag("open")], [      // boolean attribute
        .summary([], text: "More"),
        .raw("<!-- a trusted, prebuilt block -->"),
    ]),
    .br(),                                            // void → no closing tag
])

print(page.render())
```

produces (compact — Kumi adds no whitespace of its own):

```html
<section id="intro"><h2>Hello &amp; welcome</h2><a class="cta" href="/start?a=1&amp;b=2">Start</a><details class="group" open><summary>More</summary><!-- a trusted, prebuilt block --></details><br></section>
```

### Input → output

| Swift | HTML |
|---|---|
| `Node.text("a < b & c")` | `a &lt; b &amp; c` |
| `Node.tag("span", [.class("tag")], text: "x")` | `<span class="tag">x</span>` |
| `Node.tag("input", [.attr("value", "a \"b\"")])` | `<input value="a &quot;b&quot;">` |
| `Node.tag("details", [.flag("open")], text: "hi")` | `<details open>hi</details>` |
| `Node.tag("br")` | `<br>` |
| `Node.raw("<em>trusted</em>")` | `<em>trusted</em>` |
| `Node.fragment([.tag("b", [], text: "x"), .text(" & "), .tag("i", [], text: "y")])` | `<b>x</b> &amp; <i>y</i>` |

A whole page with `Node.document`:

```swift
Node.document(
    head: [.tag("meta", [.attr("charset", "UTF-8")]), .tag("title", [], text: "Report")],
    body: [.tag("h1", [], text: "Hi")]
).render()
```

```html
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Report</title></head><body><h1>Hi</h1></body></html>
```

Building blocks:

| Builder | Renders |
|---|---|
| `Node.tag(name, attrs, children)` | an element |
| `Node.tag(name, attrs, text:)` | an element wrapping one escaped text child |
| `Node.text(_:)` | escaped text |
| `Node.raw(_:)` | trusted HTML, verbatim (never pass user input) |
| `Node.fragment(_:)` | several nodes with no wrapper |
| `Node.document(lang:head:body:)` | a full `<!DOCTYPE html>` page |
| `Node.comment(_:)` | an `<!-- … -->` (content neutralized — safe) |
| `Node.empty` | nothing (renders `""`) |
| `Node.when(cond) { … }` / `Node.optional(_:)` | a node only when present/true |
| `[Node].render()` | a list of nodes, concatenated |

A `Node` is `CustomStringConvertible`, so `print(node)` and `"\(node)"` render it.

Conditional content keeps a children array declarative:

```swift
Node.div([.class("card")], [
    .h2([], text: title),
    .when(!tags.isEmpty) { .ul([], tags.map { .li([], text: $0) }) },
    .optional(footer),   // a Node? — included only if non-nil
])
```

Attribute sugar: `.class(_)`, `.id(_)`, `.href(_)`, `.data(name, value)`,
`.attr(name, value)`, and `.flag(name)` for boolean attributes.

**Conditional / multiple attributes** — drop or combine without a ternary:

```swift
.classes(["card", active ? "on" : nil])   // → class="card on"  (nils drop)
.flag("open", if: isOpen)                  // the attribute only when isOpen
.when(selected, .attr("aria-selected", "true"))   // any attribute, only when true
```

A dropped conditional renders to nothing (no empty `class=""`).

### Tag helpers

The example above uses the named helpers (`.section`, `.h2`, `.a`, `.details`,
`.summary`, `.br`) rather than `Node.tag("section", …)`, so the code reads like
the markup. Common elements are covered — `Node.div`, `.h1`–`.h6`, `.p`, `.a`,
`.span`, `.ul`/`.ol`/`.li`, `.table`/`.tr`/`.th`/`.td`, `.details`/`.summary`,
`.img`/`.br`/`.input` (void), `.style`/`.script`, and more. Each is a one-line
wrapper over `Node.tag`, so output is identical and **anything not listed still
works via `Node.tag`** — the helpers are sugar, not a closed set.

### Builder syntax

For nesting with native control flow, container helpers take a `@KumiBuilder`
closure (attributes are variadic):

```swift
Node.div(.class("card")) {
    Node.h2(text: "Title")
    if showBody { Node.p(text: body) }       // if  → optional
    for row in rows { Node.li(text: row) }    // for → loop
    if let link {                             // if/else → either
        Node.a([.href(link)], text: "More")
    } else {
        Node.empty
    }
    "a bare string is escaped text"
}
```

A statement is a `Node`, a `[Node]` (spliced), or a `String` (escaped text).
It's opt-in — the array forms (`Node.div([…], […])`) still work unchanged.

## Rendering

`render() -> String` is built over one worker, `render(to: (String) -> Void)`,
which writes each token once into a sink. Use it directly to **stream** to a
file (Foundation stays in your code, not Kumi), or `render(into: &buffer)` to
append into a buffer you already hold:

```swift
node.render { handle.write(Data($0.utf8)) }   // stream, no String materialized
var page = ""; node.render(into: &page)        // append to an existing buffer
```

## Add it

```swift
.package(url: "https://github.com/alleato-llc/kumi.git", from: "0.2.0"),
```

```swift
.target(name: "YourTarget", dependencies: [.product(name: "Kumi", package: "kumi")]),
```

## License

[MIT](LICENSE) © Alleato LLC.
