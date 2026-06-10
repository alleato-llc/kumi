import Testing
@testable import Kumi

@Suite("Kumi HTML builder")
struct KumiTests {
    @Test func rendersAnElementWithAttributesAndText() {
        let node = Node.tag("span", [.class("name")], text: "Ada")
        #expect(node.render() == "<span class=\"name\">Ada</span>")
    }

    @Test func escapesTextContent() {
        #expect(Node.text("a & b < c > d").render() == "a &amp; b &lt; c &gt; d")
        // A quote is fine in text (only attributes need it escaped).
        #expect(Node.text("say \"hi\"").render() == "say \"hi\"")
    }

    @Test func escapesAttributeValues() {
        let node = Node.tag("a", [.href("?q=a&b"), .attr("title", "a \"q\" <x>")])
        #expect(node.render()
            == "<a href=\"?q=a&amp;b\" title=\"a &quot;q&quot; &lt;x&gt;\"></a>")
    }

    @Test func preservesAttributeOrder() {
        // Deterministic output — the array order is the render order.
        let node = Node.tag("div", [.class("c"), .data("status", "passed"), .id("x")])
        #expect(node.render() == "<div class=\"c\" data-status=\"passed\" id=\"x\"></div>")
    }

    @Test func booleanAttributeRendersNameOnly() {
        let node = Node.tag("details", [.class("group"), .flag("open")])
        #expect(node.render() == "<details class=\"group\" open></details>")
    }

    @Test func voidElementHasNoClosingTag() {
        #expect(Node.tag("br").render() == "<br>")
        #expect(Node.tag("meta", [.attr("charset", "UTF-8")]).render() == "<meta charset=\"UTF-8\">")
        #expect(Node.tag("img", [.attr("src", "a.png")]).render() == "<img src=\"a.png\">")
    }

    @Test func nestsChildren() {
        let node = Node.tag("ul", [.class("list")], [
            .tag("li", [], text: "one"),
            .tag("li", [], text: "two"),
        ])
        #expect(node.render() == "<ul class=\"list\"><li>one</li><li>two</li></ul>")
    }

    @Test func rawPassesThroughUnescaped() {
        let node = Node.tag("style", [], [.raw("a < b { color: red }")])
        #expect(node.render() == "<style>a < b { color: red }</style>")
    }

    @Test func fragmentSplicesWithoutAWrapper() {
        let node = Node.fragment([.tag("b", [], text: "x"), .text(" & "), .tag("i", [], text: "y")])
        #expect(node.render() == "<b>x</b> &amp; <i>y</i>")
    }

    @Test func arrayOfNodesRendersConcatenated() {
        let nodes: [Node] = [.tag("h1", [], text: "Title"), .tag("p", [], text: "Body")]
        #expect(nodes.render() == "<h1>Title</h1><p>Body</p>")
    }

    @Test func documentWrapsDoctypeHeadAndBody() {
        let html = Node.document(
            head: [.tag("meta", [.attr("charset", "UTF-8")]), .tag("title", [], text: "T")],
            body: [.tag("h1", [], text: "H & co")]
        ).render()
        #expect(html.hasPrefix("<!DOCTYPE html><html lang=\"en\"><head>"))
        #expect(html.contains("<head><meta charset=\"UTF-8\"><title>T</title></head>"))
        #expect(html.contains("<body><h1>H &amp; co</h1></body>"))
        #expect(html.hasSuffix("</html>"))
    }

    @Test func documentLangIsConfigurable() {
        #expect(Node.document(lang: "ja").render().contains("<html lang=\"ja\">"))
    }

    @Test func tagHelpersMatchTheGenericForm() {
        // Helpers are sugar over Node.tag — identical output.
        #expect(Node.h2([.class("title")], text: "Hi & bye").render()
            == Node.tag("h2", [.class("title")], text: "Hi & bye").render())
        #expect(Node.div([.id("card")], [.p([], text: "x")]).render()
            == "<div id=\"card\"><p>x</p></div>")
        #expect(Node.img([.attr("src", "a.png")]).render() == "<img src=\"a.png\">")
        #expect(Node.br().render() == "<br>")
        #expect(Node.style("a{color:red}").render() == "<style>a{color:red}</style>")
    }

    @Test func helpersReadLikeMarkup() {
        let html = Node.section([.id("s")], [
            .h2([], text: "Title"),
            .ul([.class("list")], [.li([], text: "one"), .li([], text: "two")]),
        ]).render()
        #expect(html == "<section id=\"s\"><h2>Title</h2>"
            + "<ul class=\"list\"><li>one</li><li>two</li></ul></section>")
    }

    @Test func emptyAndConditionalContent() {
        #expect(Node.empty.render() == "")
        #expect(Node.when(true) { .tag("b", [], text: "x") }.render() == "<b>x</b>")
        #expect(Node.when(false) { .tag("b", [], text: "x") }.render() == "")
        #expect(Node.optional(nil).render() == "")
        #expect(Node.optional(.tag("i", [], text: "y")).render() == "<i>y</i>")
        // Conditional nodes keep a children array declarative.
        let html = Node.div([], [
            .tag("h2", [], text: "Title"),
            .when(false) { .tag("p", [], text: "hidden") },
            .when(true) { .tag("p", [], text: "shown") },
        ]).render()
        #expect(html == "<div><h2>Title</h2><p>shown</p></div>")
    }

    @Test func commentIsNeutralized() {
        #expect(Node.comment(" a note ").render() == "<!-- a note -->")
        // A "-->" in content can't close the comment early.
        let r = Node.comment("danger --> x").render()
        #expect(!r.dropFirst(4).dropLast(3).contains("-->"))
        #expect(r.hasPrefix("<!--") && r.hasSuffix("-->"))
    }

    @Test func descriptionIsRenderedHTML() {
        let node = Node.tag("span", [.class("x")], text: "hi")
        #expect(node.description == node.render())
        #expect("\(node)" == "<span class=\"x\">hi</span>")
    }

    @Test func classesJoinsAndDropsNils() {
        #expect(Node.div([.classes(["card", true ? "on" : nil, false ? "x" : nil])]).render()
            == "<div class=\"card on\"></div>")
        // All-nil produces nothing (no empty class="").
        #expect(Node.span([.classes([nil, nil])], text: "x").render() == "<span>x</span>")
    }

    @Test func conditionalAttributesAppearOnlyWhenTrue() {
        #expect(Node.tag("details", [.flag("open", if: true)]).render() == "<details open></details>")
        #expect(Node.tag("details", [.flag("open", if: false)]).render() == "<details></details>")
        #expect(Node.tag("li", [.class("row"), .when(true, .attr("aria-current", "true"))]).render()
            == "<li class=\"row\" aria-current=\"true\"></li>")
        #expect(Node.tag("li", [.class("row"), .when(false, .attr("aria-current", "true"))]).render()
            == "<li class=\"row\"></li>")
    }

    @Test func builderAssemblesChildrenWithControlFlow() {
        let rows = [1, 2]
        let showBody = true
        let html = Node.div(.class("card")) {
            Node.h2(text: "Title")
            if showBody { Node.p(text: "body & more") }
            for row in rows { Node.li(text: "\(row)") }
            if rows.isEmpty { Node.span(text: "none") } else { Node.empty }
            "trailing & text"
        }.render()
        #expect(html == "<div class=\"card\"><h2>Title</h2><p>body &amp; more</p>"
            + "<li>1</li><li>2</li>trailing &amp; text</div>")
    }

    @Test func renderIntoBufferMatchesRender() {
        let node = Node.section([.id("s")], [.h2([], text: "T"), .p([], text: "b")])
        var buffer = "PREFIX:"
        node.render(into: &buffer)
        #expect(buffer == "PREFIX:" + node.render())
        // The sink form collects the same bytes.
        var collected = ""
        node.render(to: { collected += $0 })
        #expect(collected == node.render())
    }

    @Test func mixesRawAndBuiltMarkup() {
        // The real consumer pattern: a built shell with a trusted inner block.
        let page = Node.tag("section", [.id("s1")], [
            .tag("h2", [], text: "Heading & more"),
            .raw("<!-- prebuilt -->"),
        ])
        #expect(page.render()
            == "<section id=\"s1\"><h2>Heading &amp; more</h2><!-- prebuilt --></section>")
    }
}
