// LuaHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class LuaHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            "local x = nil\nif x then return end", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=keyword>local</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>nil</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>if</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>then</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>return</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>end</font>"))
    }

    func testBooleanLiterals() {
        let html = HighlightTestHelper.highlight("local a = true\nlocal b = false", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=keyword>true</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>false</font>"))
    }

    func testStdlibTypes() {
        let html = HighlightTestHelper.highlight("math.floor(1.5)\nstring.len(s)", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=keytype>math</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>string</font>"))
    }

    func testDoubleQuoteString() {
        let html = HighlightTestHelper.highlight(#""hello world""#, language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }

    func testSingleQuoteString() {
        let html = HighlightTestHelper.highlight("'hello'", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=sinquot>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("x = 1 -- assign x", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=comment>-- assign x</font>"))
    }

    func testInteger() {
        let html = HighlightTestHelper.highlight("x = 42", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=integer>42</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("--[[ this is\na block comment ]]", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=comment>--[["), "block comment open not highlighted")
        XCTAssertTrue(html.contains("]]</font>"), "block comment close not highlighted")
    }

    func testBlockCommentDoesNotConsumeInlineComment() {
        // A plain -- should still work as an inline comment when not followed by [[
        let html = HighlightTestHelper.highlight("x = 1 -- plain comment", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=comment>-- plain comment</font>"))
    }
}
