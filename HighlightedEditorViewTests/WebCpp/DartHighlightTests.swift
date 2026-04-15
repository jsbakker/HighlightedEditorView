// DartHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class DartHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            "class Foo extends Bar implements Baz {\n  final int x;\n}", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=keyword>class</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>extends</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>implements</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>final</font>"))
    }

    func testAsyncKeywords() {
        let html = HighlightTestHelper.highlight(
            "Future<void> load() async {\n  await fetch();\n}", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=keyword>async</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>await</font>"))
    }

    func testNullSafetyKeywords() {
        let html = HighlightTestHelper.highlight("late String? name;", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=keyword>late</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight(
            "int x = 0;\nString s = '';\nList<int> items = [];", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=keytype>int</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>String</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>List</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello dart""#, language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("'hello'", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("var x = 1; // comment", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=comment>// comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("/* block */", language: "dart")
        XCTAssertTrue(html.contains("<font CLASS=comment>/* block */</font>"))
    }
}
