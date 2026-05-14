// YamlHighlightTests.swift
// HighlightedEditorViewTests

import XCTest
@testable import HighlightedEditorView

final class YamlHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("enabled: true\ndeleted: false\nvalue: null",
                                                  language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=keyword>true</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>false</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>null</font>"))
    }

    func testLegacyBooleanAliases() {
        let html = HighlightTestHelper.highlight("a: yes\nb: no\nc: on\nd: off",
                                                  language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=keyword>yes</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>no</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>on</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>off</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#"name: "Alice""#, language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("name: 'Alice'", language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("key: value # a comment", language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=comment># a comment</font>"))
    }

    func testNumbers() {
        let html = HighlightTestHelper.highlight("count: 42", language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=integer>42</font>"))
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("list:\n  - item", language: "yaml")
        XCTAssertTrue(html.contains("<font CLASS=symbols>"))
    }
}
