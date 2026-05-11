// TomlHighlightTests.swift
// HighlightedEditorViewTests

import XCTest
@testable import HighlightedEditorView

final class TomlHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("active = true\ndeleted = false",
                                                  language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=keyword>true</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>false</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#"name = "Alice""#, language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("path = 'C:\\Users\\alice'", language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testTripleDblQuoteString() {
        let html = HighlightTestHelper.highlight(
            "desc = \"\"\"\nline one\nline two\n\"\"\"",
            language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("# top-level comment", language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=comment># top-level comment</font>"))
    }

    func testNumbers() {
        let html = HighlightTestHelper.highlight("port = 8080", language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=integer>8080</font>"))
    }

    func testUnderscoreNumbers() {
        let html = HighlightTestHelper.highlight("big = 1_000_000", language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=integer>1_000_000</font>"))
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("[server]\nport = 8080", language: "toml")
        XCTAssertTrue(html.contains("<font CLASS=symbols>"))
    }
}
