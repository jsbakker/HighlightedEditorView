// ClojureHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class ClojureHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("(defn greet [name] (str \"Hello\" name))", language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=keyword>defn</font>"))
    }

    func testMoreKeywords() {
        let html = HighlightTestHelper.highlight("(let [x 1] (if x (do x) nil))", language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=keyword>let</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>if</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>do</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>nil</font>"))
    }

    func testTypes() {
        let html = HighlightTestHelper.highlight("(instance? String s)", language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=keytype>String</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello clojure""#, language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("; this is a comment", language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=comment>; this is a comment</font>"))
    }

    func testSymbols() {
        let html = HighlightTestHelper.highlight("(+ 1 2)", language: "clj")
        XCTAssertTrue(html.contains("<font CLASS=symbols>+</font>"))
    }
}
