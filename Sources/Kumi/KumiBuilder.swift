/// A result builder for element children, so a tree reads with native Swift
/// control flow:
///
/// ```swift
/// Node.div(.class("card")) {
///     Node.h2(text: "Title")
///     if showBody { Node.p(text: body) }     // optional
///     for row in rows { Node.li(text: row) }  // loop
///     if let link {                           // either
///         Node.a([.href(link)], text: "More")
///     } else {
///         Node.empty
///     }
///     "a bare string is escaped text"
/// }
/// ```
///
/// A statement may be a `Node`, a `[Node]` (spliced in), or a `String`
/// (escaped text). The builder is opt-in: the array forms (`Node.div([…], […])`)
/// are unchanged and still available.
@resultBuilder
public enum KumiBuilder {
    public static func buildBlock(_ parts: [Node]...) -> [Node] { parts.flatMap { $0 } }
    public static func buildExpression(_ node: Node) -> [Node] { [node] }
    public static func buildExpression(_ nodes: [Node]) -> [Node] { nodes }
    public static func buildExpression(_ text: String) -> [Node] { [.text(text)] }
    public static func buildOptional(_ part: [Node]?) -> [Node] { part ?? [] }
    public static func buildEither(first part: [Node]) -> [Node] { part }
    public static func buildEither(second part: [Node]) -> [Node] { part }
    public static func buildArray(_ parts: [[Node]]) -> [Node] { parts.flatMap { $0 } }
    public static func buildLimitedAvailability(_ part: [Node]) -> [Node] { part }
}

/// Builder-closure forms for the common container elements. Attributes are
/// variadic so `Node.div(.class("x"), .flag("open", if: y)) { … }` reads
/// cleanly; the generic `Node.tag(_:_:content:)` covers anything not listed.
public extension Node {
    static func tag(_ name: String, _ attributes: Attribute...,
                    @KumiBuilder content: () -> [Node]) -> Node {
        .tag(name, attributes, content())
    }

    static func div(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("div", attributes, content()) }
    static func span(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("span", attributes, content()) }
    static func section(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("section", attributes, content()) }
    static func article(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("article", attributes, content()) }
    static func header(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("header", attributes, content()) }
    static func footer(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("footer", attributes, content()) }
    static func nav(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("nav", attributes, content()) }
    static func main(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("main", attributes, content()) }
    static func aside(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("aside", attributes, content()) }
    static func p(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("p", attributes, content()) }
    static func a(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("a", attributes, content()) }
    static func ul(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("ul", attributes, content()) }
    static func ol(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("ol", attributes, content()) }
    static func li(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("li", attributes, content()) }
    static func table(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("table", attributes, content()) }
    static func thead(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("thead", attributes, content()) }
    static func tbody(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("tbody", attributes, content()) }
    static func tr(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("tr", attributes, content()) }
    static func th(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("th", attributes, content()) }
    static func td(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("td", attributes, content()) }
    static func details(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("details", attributes, content()) }
    static func summary(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("summary", attributes, content()) }
    static func label(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("label", attributes, content()) }
    static func pre(_ attributes: Attribute..., @KumiBuilder content: () -> [Node]) -> Node { .tag("pre", attributes, content()) }
}
