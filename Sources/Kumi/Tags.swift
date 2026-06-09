/// Convenience constructors for the common HTML elements — each a thin wrapper
/// over `Node.tag`, so call sites read like the markup:
///
/// ```swift
/// Node.div([.class("card")], [
///     .h2([], text: title),
///     .p([], text: body),
/// ])
/// ```
///
/// instead of repeating `Node.tag("div", …)`. Anything not listed here still
/// works through `Node.tag` — these are sugar, not a closed set. Container
/// elements come in two forms (children, or a single escaped text child); void
/// elements (`br`, `img`, …) take attributes only.
public extension Node {
    // Sections & grouping
    static func div(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("div", attributes, children) }
    static func div(_ attributes: [Attribute] = [], text: String) -> Node { .tag("div", attributes, text: text) }
    static func span(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("span", attributes, children) }
    static func span(_ attributes: [Attribute] = [], text: String) -> Node { .tag("span", attributes, text: text) }
    static func section(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("section", attributes, children) }
    static func article(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("article", attributes, children) }
    static func header(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("header", attributes, children) }
    static func footer(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("footer", attributes, children) }
    static func nav(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("nav", attributes, children) }
    static func main(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("main", attributes, children) }
    static func aside(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("aside", attributes, children) }

    // Headings
    static func h1(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h1", attributes, children) }
    static func h1(_ attributes: [Attribute] = [], text: String) -> Node { .tag("h1", attributes, text: text) }
    static func h2(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h2", attributes, children) }
    static func h2(_ attributes: [Attribute] = [], text: String) -> Node { .tag("h2", attributes, text: text) }
    static func h3(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h3", attributes, children) }
    static func h3(_ attributes: [Attribute] = [], text: String) -> Node { .tag("h3", attributes, text: text) }
    static func h4(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h4", attributes, children) }
    static func h4(_ attributes: [Attribute] = [], text: String) -> Node { .tag("h4", attributes, text: text) }
    static func h5(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h5", attributes, children) }
    static func h6(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("h6", attributes, children) }

    // Text & inline
    static func p(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("p", attributes, children) }
    static func p(_ attributes: [Attribute] = [], text: String) -> Node { .tag("p", attributes, text: text) }
    static func a(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("a", attributes, children) }
    static func a(_ attributes: [Attribute] = [], text: String) -> Node { .tag("a", attributes, text: text) }
    static func strong(_ attributes: [Attribute] = [], text: String) -> Node { .tag("strong", attributes, text: text) }
    static func em(_ attributes: [Attribute] = [], text: String) -> Node { .tag("em", attributes, text: text) }
    static func small(_ attributes: [Attribute] = [], text: String) -> Node { .tag("small", attributes, text: text) }
    static func code(_ attributes: [Attribute] = [], text: String) -> Node { .tag("code", attributes, text: text) }
    static func pre(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("pre", attributes, children) }

    // Lists
    static func ul(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("ul", attributes, children) }
    static func ol(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("ol", attributes, children) }
    static func li(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("li", attributes, children) }
    static func li(_ attributes: [Attribute] = [], text: String) -> Node { .tag("li", attributes, text: text) }

    // Tables
    static func table(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("table", attributes, children) }
    static func thead(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("thead", attributes, children) }
    static func tbody(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("tbody", attributes, children) }
    static func tr(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("tr", attributes, children) }
    static func th(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("th", attributes, children) }
    static func th(_ attributes: [Attribute] = [], text: String) -> Node { .tag("th", attributes, text: text) }
    static func td(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("td", attributes, children) }
    static func td(_ attributes: [Attribute] = [], text: String) -> Node { .tag("td", attributes, text: text) }

    // Interactive & forms
    static func details(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("details", attributes, children) }
    static func summary(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("summary", attributes, children) }
    static func summary(_ attributes: [Attribute] = [], text: String) -> Node { .tag("summary", attributes, text: text) }
    static func button(_ attributes: [Attribute] = [], text: String) -> Node { .tag("button", attributes, text: text) }
    static func label(_ attributes: [Attribute] = [], _ children: [Node] = []) -> Node { .tag("label", attributes, children) }

    // Document head
    static func title(_ attributes: [Attribute] = [], text: String) -> Node { .tag("title", attributes, text: text) }
    static func style(_ css: String) -> Node { .tag("style", [], [.raw(css)]) }
    static func script(_ js: String) -> Node { .tag("script", [], [.raw(js)]) }

    // Void elements (no children, no closing tag)
    static func br(_ attributes: [Attribute] = []) -> Node { .tag("br", attributes) }
    static func hr(_ attributes: [Attribute] = []) -> Node { .tag("hr", attributes) }
    static func img(_ attributes: [Attribute] = []) -> Node { .tag("img", attributes) }
    static func input(_ attributes: [Attribute] = []) -> Node { .tag("input", attributes) }
    static func meta(_ attributes: [Attribute] = []) -> Node { .tag("meta", attributes) }
    static func link(_ attributes: [Attribute] = []) -> Node { .tag("link", attributes) }
}
