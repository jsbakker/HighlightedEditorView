//
//  HighlightTestHelper.swift
//  WebCppTests
//
//  Shared helper for syntax-highlighting tests.
//  Calls the WebCpp Driver directly via Swift/C++ interop.
//

import Foundation
import WebCpp

enum HighlightTestHelper {

    static func highlight(_ source: String, language ext: String) -> String {
        let filename = "snippet.\(ext)"
        let d = Driver()
        return String(d.highlight_from_string(std.string(source), std.string(filename), WebCppStringVector()))
    }

    static func highlight(_ source: String, language ext: String, options: [String]) -> String {
        let filename = "snippet.\(ext)"
        var opts = WebCppStringVector()
        for opt in options { opts.push_back(std.string(opt)) }
        let d = Driver()
        return String(d.highlight_from_string(std.string(source), std.string(filename), opts))
    }
}
