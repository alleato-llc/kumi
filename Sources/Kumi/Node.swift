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

    // MARK: Rendering

    /// The HTML string for this node and everything under it.
    public func render() -> String {
        switch storage {
        case .text(let string):
            return Escaping.text(string)
        case .raw(let html):
            return html
        case .fragment(let nodes):
            return nodes.map { $0.render() }.joined()
        case .element(let tag, let attributes, let children):
            var html = "<\(tag)"
            for attribute in attributes {
                if let value = attribute.value {
                    html += " \(attribute.name)=\"\(Escaping.attribute(value))\""
                } else {
                    html += " \(attribute.name)"
                }
            }
            // Void elements (<br>, <meta>, <img>, …) have no closing tag.
            if children.isEmpty, Node.voidElements.contains(tag.lowercased()) {
                return html + ">"
            }
            html += ">"
            for child in children {
                html += child.render()
            }
            return html + "</\(tag)>"
        }
    }

    /// The HTML5 void elements — they take no children and emit no closing tag.
    static let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img",
        "input", "link", "meta", "param", "source", "track", "wbr",
    ]
}

public extension Array where Element == Node {
    /// Renders a list of nodes to one concatenated string — the usual way to
    /// turn the children of a page into output.
    func render() -> String {
        map { $0.render() }.joined()
    }
}
