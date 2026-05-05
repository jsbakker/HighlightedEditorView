# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test class
swift test --filter WebCppHTMLParserTests

# Run a single test method
swift test --filter SwiftHighlightTests/testKeywords

# Build the framework for distribution (macOS only, requires Xcode)
xcodebuild archive \
  -scheme HighlightedEditorView \
  -configuration Release \
  -destination "platform=macOS" \
  -archivePath "./build/HighlightedEditorView.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

## Architecture

This is a Swift Package that provides a SwiftUI code editor with live syntax highlighting. It targets macOS 10.15+, uses Swift 6, and the C++ layer requires C++23.

### Layers

**WebCpp (C++ target)** — `WebCpp/`  
The syntax highlighting engine, ported from the [webcpp](https://github.com/jsbakker/WebCPlusPlus) project. Given a source string and a filename hint, it outputs HTML with tokens wrapped in `<font CLASS=keyword>` tags. Language detection is driven entirely by file extension. Each language lives in `WebCpp/languages/lang*.{h,cpp}`. The C bridge (`WebCpp/interop/WebCppBridge.cpp`, public header `WebCpp/include/WebCppBridge.h`) exposes a plain-C API (`webcpp_driver_*` functions + `webcpp_free_string`) for Swift interop.

**HighlightedEditorView (Swift target)** — `HighlightedEditorView/`  
- `WebCppWrapper/WebCppDriver.swift` — Swift wrapper around the C bridge. The key static method is `WebCppDriver.highlightString(_:filename:options:)`, which returns the HTML string.
- `WebCppWrapper/WebCppLanguage.swift` — `WebCppLanguage` enum mapping each supported language to its file extension (`rawValue`) and a `dummyFilename` property that WebCppDriver uses for language detection.
- `WebCppWrapper/WebCppHTMLParser.swift` — Parses the `<pre>…</pre>` block from WebCpp's HTML output into a `WebCppParseResult` (plain text + array of `WebCppTokenRange`). Also contains `rebaseTokenRanges`, which corrects range offsets when WebCpp inserts extra characters (e.g. trailing spaces on preprocessor lines) that are absent from the original source.
- `WebCppWrapper/WebCppTheme.swift` — Maps WebCpp CSS token class names (`"keyword"`, `"comment"`, `"dblquot"`, etc.) to adaptive `NSColor` values (light/dark) and font traits (bold for keywords/keytypes, italic for comments).
- `HighlightedEditor.swift` — The public `HighlightedEditor` SwiftUI view (`NSViewRepresentable` wrapping `NSTextView` in `NSScrollView`). Re-highlights by updating only text attributes (never replacing text), preserving cursor and undo history. A `Coordinator` (inner class, `NSTextViewDelegate`) debounces re-highlighting to ~50 ms after each keystroke.

**HighlightedEditorViewTests** — `HighlightedEditorViewTests/`  
- `WebCppHTMLParserTests.swift` — Unit tests for the HTML parser and range rebasing.
- `WebCpp/HighlightTestHelper.swift` — Shared helper that calls the C bridge directly (no app hosting needed). Use `HighlightTestHelper.highlight(_:language:)` with the file extension string (e.g. `"swift"`, `"cpp"`).
- `WebCpp/*HighlightTests.swift` — Per-language tests asserting that specific tokens get the expected CSS class.
- `WebCpp/*MultilineCommentTests.swift`, `*MultilineStringTests.swift`, `*BackslashContinuationTests.swift` — Edge-case tests for multi-line constructs.

### Token class names (WebCppTheme)

| Class | Meaning |
|---|---|
| `nortext` | Default/uncolored text |
| `keyword` | Language keywords (bold) |
| `keytype` | Type keywords (bold) |
| `comment` | Comments (italic) |
| `preproc` | Preprocessor directives |
| `dblquot` | Double-quoted strings |
| `sinquot` | Single-quoted strings |
| `integer` | Integer literals |
| `floatpt` | Floating-point literals |
| `symbols` | Operators/symbols |
| `bgcolor` | Background (same as editor background) |

### Adding a new language

1. Add `lang*.h` / `lang*.cpp` in `WebCpp/languages/`, following the pattern of an existing language.
2. Register it in `WebCpp/languages/lang_factory.cpp` and `WebCpp/languages/deflangs.h`.
3. Add a case to `WebCppLanguage` in `HighlightedEditorView/WebCppWrapper/WebCppLanguage.swift` with the correct file extension as `rawValue`.
4. Add highlight tests in `HighlightedEditorViewTests/WebCpp/`.
