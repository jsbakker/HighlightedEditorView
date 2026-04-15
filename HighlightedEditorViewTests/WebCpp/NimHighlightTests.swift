// NimHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class NimHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("proc greet(name: string): string =\n  return \"Hello\"", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=keyword>proc</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>return</font>"))
    }

    func testCaseInsensitiveKeywords() {
        let html = HighlightTestHelper.highlight("PROC foo() =\n  VAR x = 1", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=keyword>PROC</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>VAR</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight("var x: int = 0\nvar s: string = \"\"", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=keytype>int</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>string</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello nim""#, language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testTripleQuoteString() {
        let html = HighlightTestHelper.highlight("\"\"\"\nhello\n\"\"\"", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("var x = 1 # comment", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=comment># comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("#[ this is\na block comment ]#", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=comment>#["), "block comment open not highlighted")
        XCTAssertTrue(html.contains("]#</font>"), "block comment close not highlighted")
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("z = x + y", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=symbols>+</font>"))
    }

    func testUnderscoreNumbers() {
        let html = HighlightTestHelper.highlight("n = 1_000_000", language: "nim")
        XCTAssertTrue(html.contains("<font CLASS=integer>1_000_000</font>"))
    }
}
