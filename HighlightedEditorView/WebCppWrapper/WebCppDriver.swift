//
//  WebCppDriver.swift
//  HighlightedEditorView
//
//  Swift wrapper around the WebCpp C++ Driver class via Swift/C++ interop.
//

internal import WebCpp

/// Swift-friendly wrapper around the WebCpp syntax-highlighting engine.
final class WebCppDriver {

    private let driver: Driver

    init() {
        driver = Driver()
    }

    // MARK: - Static

    /// Generates an index HTML file from a webcppbatch.txt listing.
    static func makeIndex(prefix: String = "") {
        Driver.makeIndex(std.string(prefix))
    }

    // MARK: - Instance

    /// Parses a command-line-style option (e.g. `"-l"`, `"--line-numbers"`, `"-c=scheme"`).
    /// - Returns: `true` if the option was recognised and applied.
    @discardableResult
    func parseSwitch(_ arg: String) -> Bool {
        driver.switch_parser(std.string(arg))
    }

    /// Returns the internal language file-type code for the given filename.
    func getExtension(for filename: String) -> UInt8 {
        driver.getExt(std.string(filename))
    }

    /// Detects the language for the given filename and returns a human-readable description
    /// (e.g. `"C++ file"`, `"Python script"`).
    func checkExtension(for filename: String) -> String {
        String(driver.checkExt(std.string(filename)))
    }

    /// Prepares input/output files for processing.
    @discardableResult
    func prepareFiles(input inputFile: String,
                      output outputFile: String,
                      overwrite: OverwriteMode = .force) -> Bool {
        driver.prep_files(std.string(inputFile), std.string(outputFile), overwrite.rawValue)
    }

    /// Returns the filename portion (without directory path) of the current input file.
    func getTitle() -> String {
        String(driver.getTitle())
    }

    /// Runs the syntax-highlighting engine on the prepared files.
    func drive() {
        driver.drive()
    }

    // MARK: - Convenience

    /// Converts a source code string to syntax-highlighted HTML.
    /// - Parameters:
    ///   - source: The source code text.
    ///   - filename: A representative filename used for language detection (e.g. `"example.swift"`).
    ///   - options: Optional command-line-style flags (e.g. `["-l", "-c=scheme"]`).
    /// - Returns: The highlighted HTML string, or `nil` on failure.
    static func highlightString(_ source: String,
                                filename: String,
                                options: [String] = []) -> String? {
        var opts = WebCppStringVector()
        for opt in options { opts.push_back(std.string(opt)) }
        let d = Driver()
        let result = String(d.highlight_from_string(std.string(source), std.string(filename), opts))
        return result.isEmpty ? nil : result
    }

    // MARK: - Supporting Types

    enum OverwriteMode: CChar {
        case force  = 0x66  // 'f'
        case never  = 0x6B  // 'k'
        case prompt = 0x77  // 'w'
    }
}
