# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Kumi** (組 — *kumu*, "to assemble/braid") is a tiny HTML builder for Swift: build a tree of `Node`s, call `render()`, get a string. It exists so that consumers (today: `alleato-llc/pickle-kit`'s report generators) build markup without hand-written tag strings, which leak unescaped content, drop closing tags, and emit attributes in nondeterministic order.

## Commands

```sh
swift build
swift test            # Swift Testing (not XCTest)
swift test --filter KumiTests
```

There is no linter, no app target, no CI config in-repo. The whole library is three source files.

## Architecture

One module, `Kumi`, in `Sources/Kumi/`:

- **`Node.swift`** — the public `Node` value type (an enum-backed `Storage`: `.element`/`.text`/`.raw`/`.fragment`), the static factories (`tag`/`text`/`raw`/`fragment`/`document`/`comment`, plus the conditional helpers `empty`/`when`/`optional`), and `render()`. `render()` is the *only* place markup is emitted; `Node` is `CustomStringConvertible` (`description == render()`). `comment` neutralizes `--` runs so content can't close the comment early (safe even for untrusted text). Also the `voidElements` set (`<br>`, `<meta>`, … — no closing tag) and `[Node].render()`.
- **`Attribute.swift`** — the `Attribute` value type (`name` + optional `value`; a `nil` value is a boolean attribute like `open`) plus the sugar statics (`.class`, `.id`, `.href`, `.data`, `.attr`, `.flag`).
- **`Tags.swift`** — named convenience constructors for the common HTML elements (`Node.div`, `.h2`, `.ul`/`.li`, `.tr`/`.td`, `.details`/`.summary`, void `.img`/`.br`, `.style`/`.script`, …). Each is a one-line wrapper over `Node.tag`, so output is identical; it's a **curated set, not exhaustive** — anything unlisted uses `Node.tag` directly. Container helpers come in two forms (children, or `text:`); void helpers take attributes only.
- **`Escaping.swift`** — `Escaping.text` (escapes `& < >`) and `Escaping.attribute` (those plus `"`). A manual scan, no Foundation.

Tests are in `Tests/KumiTests/KumiTests.swift` (Swift Testing, `@testable import Kumi`).

## Invariants — do not break these

- **Zero dependencies, no Foundation.** Kumi is *depended on by other packages*, so any dependency it takes becomes viral on every consumer. Keep `Package.swift` dependency-free and keep the source Foundation-free (escaping is a hand-rolled scan for exactly this reason). **Never add a dependency on a consumer** (e.g. pickle-kit) — that's a package cycle SwiftPM rejects.
- **Escaping is the point.** Text escapes `& < >`; attribute values escape those plus `"`. Quotes in *text* are left literal (the HTML-correct rule) — don't "fix" that. `.raw(_:)` is the trusted escape hatch and is never escaped; never route user input through it.
- **Deterministic output.** Attributes are an *ordered array*, rendered in array order — consumers' snapshot/substring tests depend on stable order. Don't switch attributes to a dictionary.
- **Rendering is compact.** `render()` adds no whitespace of its own (no indentation/newlines between elements). This keeps inline content exact (no stray spaces) and output deterministic; pretty-printing HTML is whitespace-sensitive and deliberately out of scope.
- **Void elements emit no closing tag** and ignore children. Extend `voidElements` if a new one is needed; don't special-case at call sites.

## Adding to the API

Keep the surface small. A new convenience belongs here only if it's broadly useful (like `document`); one-off shapes compose from `tag`/`text`/`raw`/`fragment` at the call site. Every public addition gets a test in `KumiTests` asserting the exact rendered string (the tests are the spec — they pin output byte-for-byte).

## Consumers

`alleato-llc/pickle-kit` depends on Kumi (`from: "0.1.0"`) for its living-spec/report HTML. The dependency is **one-way** (pickle-kit → Kumi); never reverse it. When changing `render()` output, remember a behavior change ripples into pickle-kit's (and transitively soroban's) generated reports — bump the version thoughtfully.
