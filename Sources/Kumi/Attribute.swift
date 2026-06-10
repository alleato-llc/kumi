/// One HTML attribute. A `nil` value is a **boolean attribute** — it renders as
/// just the name (`<details open>`), not `open=""`. An **empty name** is the
/// "nothing" sentinel: a dropped conditional attribute, skipped on render —
/// that's what the `if:` / `.when` / all-nil-`.classes` forms produce.
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

    // MARK: Conditional / multiple

    /// One `class` from several optional names — `nil`s drop, the rest join:
    /// `.classes(["card", active ? "on" : nil])` → `class="card on"` (or
    /// `class="card"`). All-`nil` produces nothing.
    public static func classes(_ values: [String?]) -> Attribute {
        let joined = values.compactMap { $0 }.joined(separator: " ")
        return joined.isEmpty ? .init("", nil) : .init("class", joined)
    }

    /// A boolean attribute included only when `condition` holds —
    /// `.flag("open", if: isOpen)`. When false it renders to nothing.
    public static func flag(_ name: String, if condition: Bool) -> Attribute {
        condition ? .init(name, nil) : .init("", nil)
    }

    /// Any attribute included only when `condition` holds —
    /// `.when(selected, .attr("aria-selected", "true"))`. Otherwise nothing.
    public static func when(_ condition: Bool, _ attribute: Attribute) -> Attribute {
        condition ? attribute : .init("", nil)
    }
}
