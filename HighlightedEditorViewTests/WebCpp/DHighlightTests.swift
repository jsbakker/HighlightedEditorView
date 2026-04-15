// DHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class DHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("module foo;\nimport std.stdio;\nvoid main() {}", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=keyword>module</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>import</font>"))
    }

    func testMoreKeywords() {
        let html = HighlightTestHelper.highlight("class Foo : Bar {\n  override void run() {}\n}", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=keyword>class</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>override</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight("int x = 0;\nstring s = \"hi\";\nbool b = true;", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=keytype>int</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>string</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>bool</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello d""#, language: "d")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testBacktickString() {
        let html = HighlightTestHelper.highlight("`raw string`", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=preproc>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("int x = 1; // comment", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=comment>// comment</font>"))
    }

    func testBlockCommentPLI() {
        let html = HighlightTestHelper.highlight("/* block comment */", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=comment>/* block comment */</font>"))
    }

    func testBlockCommentD() {
        let html = HighlightTestHelper.highlight("/+ nested\nblock comment +/", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=comment>/+"), "D block comment open not highlighted")
        XCTAssertTrue(html.contains("+/</font>"), "D block comment close not highlighted")
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("int z = x + y;", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=symbols>+</font>"))
    }

    func testUnderscoreNumbers() {
        let html = HighlightTestHelper.highlight("int n = 1_000_000;", language: "d")
        XCTAssertTrue(html.contains("<font CLASS=integer>1_000_000</font>"))
    }
}
