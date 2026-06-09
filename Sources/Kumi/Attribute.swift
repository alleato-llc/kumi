/// One HTML attribute. A `nil` value is a **boolean attribute** — it renders as
/// just the name (`<details open>`), not `open=""`.
public struct Attribute: Sendable, Equatable {
    public let name: String
    public let value: String?

    public init(_ name: String, _ value: String?) {
        self.name = name
        self.value = value
    }

    // Sugar for the common ones — call sites read like intent:
    //   Node.tag("div", [.class("card"), .data("status", s)])

    /// `class="…"`.
    public static func `class`(_ value: String) -> Attribute { .init("class", value) }
    /// `id="…"`.
    public static func id(_ value: String) -> Attribute { .init("id", value) }
    /// `href="…"`.
    public static func href(_ value: String) -> Attribute { .init("href", value) }
    /// `data-<name>="…"`.
    public static func data(_ name: String, _ value: String) -> Attribute { .init("data-\(name)", value) }
    /// Any attribute by name.
    public static func attr(_ name: String, _ value: String) -> Attribute { .init(name, value) }
    /// A boolean attribute (`open`, `selected`, `disabled`) — name only.
    public static func flag(_ name: String) -> Attribute { .init(name, nil) }
}
