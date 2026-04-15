// GroovyHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class GroovyHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            "def greet(String name) {\n  return \"Hello, ${name}\"\n}", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=keyword>def</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>return</font>"))
    }

    func testClassKeywords() {
        let html = HighlightTestHelper.highlight(
            "class Foo extends Bar implements Baz {}", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=keyword>class</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>extends</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>implements</font>"))
    }

    func testTraitKeyword() {
        let html = HighlightTestHelper.highlight("trait Flyable {}", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=keyword>trait</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight(
            "String s\nInteger n\nList items", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=keytype>String</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>Integer</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>List</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello groovy""#, language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("'literal'", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("def x = 1 // comment", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=comment>// comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("/* block */", language: "groovy")
        XCTAssertTrue(html.contains("<font CLASS=comment>/* block */</font>"))
    }
}
