// JsonHighlightTests.swift
// HighlightedEditorViewTests

import XCTest
@testable import HighlightedEditorView

final class JsonHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            #"{"active": true, "deleted": false, "value": null}"#,
            language: "json")
        XCTAssertTrue(html.contains("<font CLASS=keyword>true</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>false</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>null</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#"{"key": "value"}"#, language: "json")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testNumbers() {
        let html = HighlightTestHelper.highlight(#"{"count": 42, "ratio": 3.14}"#, language: "json")
        XCTAssertTrue(html.contains("<font CLASS=integer>42</font>"))
        XCTAssertTrue(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

}
