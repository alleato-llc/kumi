import Kumi

// A test-report dashboard built straight from a data model — the kind of page
// Kumi was born for. Shows: the @KumiBuilder with `for`/`if`, conditional
// attributes (`.flag("open", if:)`), and conditional classes (`.classes`).

struct TestCase { let name: String; let passed: Bool; let ms: Int }
struct Suite { let name: String; let cases: [TestCase] }

let suites = [
    Suite(name: "Lexer", cases: [
        TestCase(name: "tokenizes numbers", passed: true, ms: 1),
        TestCase(name: "handles 0x & 0b literals", passed: true, ms: 2),
    ]),
    Suite(name: "Parser", cases: [
        TestCase(name: "parses precedence", passed: true, ms: 3),
        TestCase(name: "reports a caret at the column", passed: true, ms: 2),
    ]),
    Suite(name: "Evaluator", cases: [
        TestCase(name: "exact decimal arithmetic", passed: true, ms: 5),
        TestCase(name: "tail-call recursion", passed: false, ms: 41),
    ]),
]

let css = """
:root { --bg:#fdf6e3; --fg:#073642; --muted:#657b83; --line:rgba(7,54,66,.12);
        --ok:#2aa198; --bad:#dc322f; }
* { box-sizing:border-box; margin:0; }
body { font:16px/1.5 system-ui,sans-serif; background:var(--bg); color:var(--fg);
       padding:2.5rem 1rem; max-width:760px; margin:0 auto; }
.hero h1 { font-size:1.7rem; letter-spacing:-.02em; }
.hero .sub { color:var(--muted); margin:.3rem 0 1.5rem; }
.suite { border:1px solid var(--line); border-radius:10px; margin-bottom:.75rem; overflow:hidden; }
.suite > summary { display:flex; gap:.6rem; align-items:center; padding:.7rem 1rem; cursor:pointer; list-style:none; }
.suite > summary::-webkit-details-marker { display:none; }
.suite[data-status="failed"] > summary { background:color-mix(in srgb,var(--bad) 9%,transparent); }
.name { flex:1; font-weight:600; }
.badge { font-size:.72rem; font-weight:700; text-transform:uppercase; padding:2px 9px; border-radius:999px; }
.badge.ok { color:var(--ok); background:color-mix(in srgb,var(--ok) 16%,transparent); }
.badge.bad { color:var(--bad); background:color-mix(in srgb,var(--bad) 16%,transparent); }
.case { display:flex; gap:.6rem; align-items:center; padding:.45rem 1rem; border-top:1px solid var(--line); font-size:.92rem; }
.case .mark { font-weight:700; color:var(--ok); }
.case.bad .mark { color:var(--bad); }
.case.bad { color:var(--bad); }
.cname { flex:1; }
.ms { color:var(--muted); font-size:.8rem; }
footer { text-align:center; color:var(--muted); font-size:.8rem; margin-top:1.5rem; }
footer a { color:inherit; }
"""

let source = "https://github.com/alleato-llc/kumi/blob/main/Examples/report/main.swift"

let page = Node.document(head: [
    .meta([.attr("charset", "UTF-8")]),
    .meta([.attr("name", "viewport"), .attr("content", "width=device-width, initial-scale=1")]),
    .title([], text: "Build Report — Kumi demo"),
    .style(css),
], body: [
    .header([.class("hero")], [
        .h1([], text: "Build Report"),
        .p([.class("sub")], text: "3 suites · 6 tests · built with Kumi"),
    ]),
    Node.main {
        for suite in suites {
            let failed = suite.cases.contains { !$0.passed }
            // A failing suite opens by default so its failure is visible.
            Node.details(.class("suite"), .data("status", failed ? "failed" : "passed"),
                         .flag("open", if: failed)) {
                Node.summary {
                    Node.span([.class("name")], text: suite.name)
                    Node.span([.classes(["badge", failed ? "bad" : "ok"])],
                              text: failed ? "failing" : "passing")
                }
                for test in suite.cases {
                    Node.div(.classes(["case", test.passed ? nil : "bad"])) {
                        Node.span([.class("mark")], text: test.passed ? "✓" : "✗")
                        Node.span([.class("cname")], text: test.name)
                        Node.span([.class("ms")], text: "\(test.ms)ms")
                    }
                }
            }
        }
    },
    .tag("footer", [], [
        .text("Built with "),
        .a([.href("https://github.com/alleato-llc/kumi")], text: "Kumi"),
        .text(" · "),
        .a([.href(source)], text: "view source ↗"),
    ]),
])

print(page.render())
