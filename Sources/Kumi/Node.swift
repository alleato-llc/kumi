/// A piece of HTML.
///
/// Kumi (組 — *kumu*, to assemble/braid) builds markup as a tree of `Node`s,
/// then `render()`s it to a string. The point is that the rendering is the only
/// thing that emits markup, so three classes of bug can't happen:
///
///  - **Unescaped content** — `.text(_:)` and attribute values escape `& < > "`
///    automatically; reach for `.raw(_:)` only for HTML you already trust.
///  - **Unclosed tags** — every element closes on render (void elements like
///    `<br>`/`<meta>` correctly emit no closing tag).
///  - **Nondeterministic attribute order** — attributes are an ordered array,
///    so the same tree always renders byte-for-byte the same.
public struct Node: Sendable, Equatable {
    enum Storage: Sendable, Equatable {
        case element(tag: String, attributes: [Attribute], children: [Node])
        case text(String)
        case raw(String)
        case fragment([Node])
    }

    let storage: Storage

    // MARK: Building

    /// An element with children: `Node.tag("ul", [.class("list")], [item, item])`.
    public static func tag(_ name: String, _ attributes: [Attribute] = [],
                           _ children: [Node] = []) -> Node {
        Node(storage: .element(tag: name, attributes: attributes, children: children))
    }

    /// An element wrapping a single escaped text child:
    /// `Node.tag("span", [.class("name")], text: title)`.
    public static func tag(_ name: String, _ attributes: [Attribute] = [],
                           text: String) -> Node {
        .tag(name, attributes, [.text(text)])
    }

    /// Escaped text content.
    public static func text(_ string: String) -> Node {
        Node(storage: .text(string))
    }

    /// Pre-rendered, **trusted** HTML inserted verbatim — for a CSS/JS block or
    /// a fragment built elsewhere. Not escaped, so never pass user input here.
    public static func raw(_ html: String) -> Node {
        Node(storage: .raw(html))
    }

    /// Several nodes with no wrapping element — splice a list into a parent.
    public static func fragment(_ nodes: [Node]) -> Node {
        Node(storage: .fragment(nodes))
    }

    /// A full HTML5 document: the `<!DOCTYPE html>` line, then `<html lang=…>`
    /// wrapping `<head>` and `<body>`. `render()` it for the page string.
    public static func document(lang: String = "en",
                                head: [Node] = [],
                                body: [Node] = []) -> Node {
        .fragment([
            .raw("<!DOCTYPE html>"),
            .tag("html", [.attr("lang", lang)], [
                .tag("head", [], head),
                .tag("body", [], body),
            ]),
        ])
    }

    /// Nothing — renders to the empty string. The neutral element you place in
    /// a children array when a node is conditionally absent.
    public static let empty = Node(storage: .fragment([]))

    /// `build()` when `condition` holds, otherwise `.empty`. Lets a children
    /// array stay declarative: `.when(!tags.isEmpty) { .div([.class("tags")], …) }`.
    public static func when(_ condition: Bool, _ build: () -> Node) -> Node {
        condition ? build() : .empty
    }

    /// The node if present, otherwise `.empty` — `.optional(reportLink.map { … })`.
    public static func optional(_ node: Node?) -> Node {
        node ?? .empty
    }

    /// An HTML comment `<!-- text -->`. The content is neutralized so it can't
    /// close the comment early: any `--` run is broken (a comment may not
    /// contain `-->`), which keeps even untrusted text safe here.
    public static func comment(_ text: String) -> Node {
        var safe = ""
        safe.reserveCapacity(text.count)
        var lastWasDash = false
        for character in text {
            if character == "-" && lastWasDash { safe.append(" ") }
            safe.append(character)
            lastWasDash = (character == "-")
        }
        return .raw("<!--\(safe)-->")
    }

    // MARK: Rendering

    /// The single worker: writes this node (and everything under it) into the
    /// `write` sink, one token at a time — each output byte is produced once.
    /// `render()` builds a String over this; a caller can stream straight to a
    /// file by passing their own sink (`node.render { handle.write(Data($0.utf8)) }`),
    /// keeping Foundation out of Kumi.
    public func render(to write: (String) -> Void) {
        switch storage {
        case .text(let string):
            write(Escaping.text(string))
        case .raw(let html):
            write(html)
        case .fragment(let nodes):
            for node in nodes { node.render(to: write) }
        case .element(let tag, let attributes, let children):
            write("<\(tag)")
            // An empty-name attribute is the "nothing" sentinel (a dropped
            // conditional attribute) — skip it.
            for attribute in attributes where !attribute.name.isEmpty {
                if let value = attribute.value {
                    write(" \(attribute.name)=\"\(Escaping.attribute(value))\"")
                } else {
                    write(" \(attribute.name)")
                }
            }
            // Void elements (<br>, <meta>, <img>, …) have no closing tag.
            if children.isEmpty, Node.voidElements.contains(tag.lowercased()) {
                write(">")
                return
            }
            write(">")
            for child in children { child.render(to: write) }
            write("</\(tag)>")
        }
    }

    /// The HTML string for this node and everything under it.
    public func render() -> String {
        var output = ""
        render(to: { output += $0 })
        return output
    }

    /// Appends this node's HTML to an existing buffer — one growing
    /// allocation across a whole page.
    public func render(into output: inout String) {
        render(to: { output += $0 })
    }

    /// The HTML5 void elements — they take no children and emit no closing tag.
    static let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img",
        "input", "link", "meta", "param", "source", "track", "wbr",
    ]
}

extension Node: CustomStringConvertible {
    /// `description` is the rendered HTML, so `print(node)` and `"\(node)"`
    /// just work.
    public var description: String { render() }
}

public extension Array where Element == Node {
    /// Renders a list of nodes to one concatenated string — the usual way to
    /// turn the children of a page into output. Uses a single growing buffer.
    func render() -> String {
        var output = ""
        for node in self { node.render(to: { output += $0 }) }
        return output
    }
}
