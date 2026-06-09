/// HTML escaping — the whole point of the library is that you can't forget it.
/// Foundation-free (a manual scan), so Kumi stays portable and dependency-free.
enum Escaping {
    /// Escapes text-node content: `&`, `<`, `>`. (A literal `"` is fine in text.)
    static func text(_ string: String) -> String {
        escape(string, quotes: false)
    }

    /// Escapes an attribute value: text rules plus `"` (the value delimiter).
    static func attribute(_ string: String) -> String {
        escape(string, quotes: true)
    }

    private static func escape(_ string: String, quotes: Bool) -> String {
        var out = ""
        out.reserveCapacity(string.count)
        for character in string {
            switch character {
            case "&": out += "&amp;"
            case "<": out += "&lt;"
            case ">": out += "&gt;"
            case "\"" where quotes: out += "&quot;"
            default: out.append(character)
            }
        }
        return out
    }
}
