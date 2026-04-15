// ElixirHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class ElixirHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("defmodule Foo do\n  def bar, do: nil\nend", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=keyword>defmodule</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>def</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>do</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>end</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>nil</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight("is_binary(String.upcase(s))", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=keytype>String</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello elixir""#, language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("'charlist'", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("x = 1 # comment", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=comment># comment</font>"))
    }

    func testTripleQuoteString() {
        let html = HighlightTestHelper.highlight("s = \"\"\"\nhello\n\"\"\"", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testModuleAttribute() {
        let html = HighlightTestHelper.highlight("@moduledoc \"docs\"", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=preproc>@moduledoc</font>"))
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("x = 1 + 2", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=symbols>+</font>"))
    }

    func testUnderscoreNumbers() {
        let html = HighlightTestHelper.highlight("x = 1_000_000", language: "ex")
        XCTAssertTrue(html.contains("<font CLASS=integer>1_000_000</font>"))
    }
}
