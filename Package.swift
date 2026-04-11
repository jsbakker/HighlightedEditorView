// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HighlightedEditorView",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "HighlightedEditorView",
            targets: ["HighlightedEditorView"]),
    ],
    targets: [
        .target(
            name: "WebCpp",
            dependencies: [],
            path: "WebCpp",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("."),
                .headerSearchPath("colour"),
                .headerSearchPath("interop"),
                .headerSearchPath("languages"),
                .headerSearchPath("parsing"),
                .headerSearchPath("utils"),
                .unsafeFlags(["-std=c++23"]),
            ]),
        .target(
            name: "HighlightedEditorView",
            dependencies: ["WebCpp"],
            path: "HighlightedEditorView"),
        .testTarget(
            name: "HighlightedEditorViewTests",
            dependencies: ["HighlightedEditorView"],
            path: "HighlightedEditorViewTests"),
    ]
)