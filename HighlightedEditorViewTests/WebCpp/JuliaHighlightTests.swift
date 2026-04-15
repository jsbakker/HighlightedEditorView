// JuliaHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class JuliaHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("function greet(name)\n  return \"Hello\"\nend", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=keyword>function</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>return</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>end</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight("x::Int = 0\ny::Float64 = 1.0", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=keytype>Int</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>Float64</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello julia""#, language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testTripleQuoteString() {
        let html = HighlightTestHelper.highlight("\"\"\"\nhello\n\"\"\"", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("x = 1 # comment", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=comment># comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("#= this is\na block comment =#", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=comment>#="), "block comment open not highlighted")
        XCTAssertTrue(html.contains("=#</font>"), "block comment close not highlighted")
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("z = x + y", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=symbols>+</font>"))
    }

    func testUnderscoreNumbers() {
        let html = HighlightTestHelper.highlight("n = 1_000_000", language: "jl")
        XCTAssertTrue(html.contains("<font CLASS=integer>1_000_000</font>"))
    }
}
