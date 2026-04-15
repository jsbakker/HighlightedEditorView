// WGSLHighlightTests.swift

import XCTest
@testable import HighlightedEditorView

final class WGSLHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight(
            "fn main() -> void {\n  let x: f32 = 0.0;\n  return;\n}", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keyword>fn</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>let</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>return</font>"))
    }

    func testStructAndVar() {
        let html = HighlightTestHelper.highlight(
            "struct Uniforms { model: mat4x4f }\nvar<uniform> u: Uniforms;", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keyword>struct</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>var</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>uniform</font>"))
    }

    func testAttributes() {
        let html = HighlightTestHelper.highlight(
            "@vertex\nfn vs_main(@location(0) pos: vec4f) -> @builtin(position) vec4f {",
            language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keyword>@vertex</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>@location</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>@builtin</font>"))
    }

    func testScalarTypes() {
        let html = HighlightTestHelper.highlight("var x: f32;\nvar y: i32;\nvar z: u32;", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keytype>f32</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>i32</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>u32</font>"))
    }

    func testVectorTypes() {
        let html = HighlightTestHelper.highlight("var v: vec4f;\nvar u: vec2<f32>;", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keytype>vec4f</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>vec2</font>"))
    }

    func testMatrixTypes() {
        let html = HighlightTestHelper.highlight("var m: mat4x4f;", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keytype>mat4x4f</font>"))
    }

    func testBuiltinFunctions() {
        let html = HighlightTestHelper.highlight("let n = normalize(v);\nlet d = dot(a, b);", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=keytype>normalize</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keytype>dot</font>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("let x = 1.0; // a comment", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=comment>// a comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("/* block */", language: "wgsl")
        XCTAssertTrue(html.contains("<font CLASS=comment>/* block */</font>"))
    }
}
