// PowerShellHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class PowerShellHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            "function Get-Greeting {\n  param($Name)\n  return \"Hello\"\n}", language: "ps1")
        XCTAssertTrue(html.contains("CLASS=keyword>function</font>"))
        XCTAssertTrue(html.contains("CLASS=keyword>param</font>"))
        XCTAssertTrue(html.contains("CLASS=keyword>return</font>"))
    }

    func testControlFlow() {
        let html = HighlightTestHelper.highlight(
            "foreach ($item in $list) { if ($item) { break } }", language: "ps1")
        XCTAssertTrue(html.contains("CLASS=keyword>foreach</font>"))
        XCTAssertTrue(html.contains("CLASS=keyword>if</font>"))
        XCTAssertTrue(html.contains("CLASS=keyword>break</font>"))
    }

    func testCaseInsensitiveKeywords() {
        let html = HighlightTestHelper.highlight("FUNCTION foo {}\nFOREACH ($x in $y) {}", language: "ps1")
        XCTAssertTrue(html.contains("CLASS=keyword>FUNCTION</font>"))
        XCTAssertTrue(html.contains("CLASS=keyword>FOREACH</font>"))
    }

    func testScalarVariable() {
        let html = HighlightTestHelper.highlight("$Name = 'Alice'", language: "ps1")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
        // $Name should be highlighted as a scalar
        XCTAssertTrue(html.contains("CLASS=preproc>$Name</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""Hello World""#, language: "ps1")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("'literal string'", language: "ps1")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("$x = 1 # comment", language: "ps1")
        XCTAssertTrue(html.contains("<font CLASS=comment># comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("<# this is\na block comment #>", language: "ps1")
        XCTAssertTrue(html.contains("<font CLASS=comment>"), "block comment not highlighted")
        XCTAssertTrue(html.contains("#&gt;</font>") || html.contains("#>"), "block comment close not highlighted")
    }
}
