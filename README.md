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

let page = Node.tag("section", [.id("intro")], [
    .tag("h2", [], text: "Hello & welcome"),          // escaped → "Hello &amp; welcome"
    .tag("a", [.class("cta"), .href("/start?a=1&b=2")], text: "Start"),
    .tag("details", [.class("group"), .flag("open")], [ // boolean attribute
        .tag("summary", [], text: "More"),
        .raw("<!-- a trusted, prebuilt block -->"),
    ]),
    .tag("br"),                                         // → "<br>" (void, no close)
])

print(page.render())
```

Building blocks:

| Builder | Renders |
|---|---|
| `Node.tag(name, attrs, children)` | an element |
| `Node.tag(name, attrs, text:)` | an element wrapping one escaped text child |
| `Node.text(_:)` | escaped text |
| `Node.raw(_:)` | trusted HTML, verbatim (never pass user input) |
| `Node.fragment(_:)` | several nodes with no wrapper |
| `[Node].render()` | a list of nodes, concatenated |

Attribute sugar: `.class(_)`, `.id(_)`, `.href(_)`, `.data(name, value)`,
`.attr(name, value)`, and `.flag(name)` for boolean attributes.

## Add it

```swift
.package(url: "https://github.com/alleato-llc/kumi.git", from: "0.1.0"),
```

```swift
.target(name: "YourTarget", dependencies: [.product(name: "Kumi", package: "kumi")]),
```
