//
//  HighlightedEditorView.swift
//  HighlightedEditorView
//
//  An editable NSTextView wrapped for SwiftUI that applies live WebCpp
//  syntax highlighting on every edit.
//
//  Strategy: after each text change, WebCppDriver re-highlights the full
//  source, parseWebCppHTML() extracts the token ranges, and we apply only
//  the .foregroundColor / .font attributes to the existing NSTextStorage.
//  Because the text content itself is never replaced, the cursor position
//  and undo stack are preserved across re-highlighting passes.
//

import SwiftUI
import AppKit

/// A SwiftUI wrapper around an AppKit-powered, syntax-highlighted text editor.
///
/// HighlightedEditor embeds an NSTextView inside an NSScrollView and applies live
/// syntax highlighting using WebCpp on every edit. It preserves the user's cursor
/// position and the undo stack by updating only text attributes (foreground color
/// and font) rather than replacing the underlying text content.
///
/// Usage:
/// - Bind the editor to a String source of truth via `text`.
/// - Specify the language with `language` to drive WebCpp tokenization and styling.
/// - The editor automatically re-highlights when text changes, when the selected
///   language changes, and when the system color scheme switches between light
///   and dark modes.
///
/// Behavior and implementation details:
/// - Uses a monospaced system font (regular, bold, italic variants) for code.
/// - Disables smart substitutions (quotes, dashes, spelling, replacements) to
///   avoid unintended code mutations.
/// - Respects the SwiftUI environment color scheme to update background and caret
///   colors in sync with the current theme.
/// - Debounces highlighting after edits (≈50 ms) to keep typing responsive while
///   maintaining fresh syntax colors.
/// - On external content changes (e.g., swapping between snippets), replaces the
///   text, clears the undo stack to avoid cross-snippet actions, and re-applies
///   highlighting.
/// - Re-aligns token ranges if WebCpp’s HTML introduces minor textual differences
///   (such as trailing spaces on preprocessor lines) to ensure colors land on the
///   correct characters in the actual source.
///
/// Requirements:
/// - WebCppDriver: performs syntax highlighting and produces HTML.
/// - WebCppTheme: maps token classes to NSColor and font traits.
/// - WebCppLanguage: identifies the language and provides an appropriate filename
///   hint for WebCpp.
///
/// Platform:
/// - macOS (AppKit). Designed for use in SwiftUI via NSViewRepresentable.
///
/// Threading:
/// - Highlighting and attribute application occur on the main thread, coordinated
///   with NSTextView updates and layout invalidation.
///
/// Scrolling and layout:
/// - Captures and restores scroll position across attribute updates to avoid
///   jumpiness while re-highlighting.
/// - Forces layout after attribute changes to ensure geometry is up to date
///   before restoring the scroll origin.
///
/// Limitations:
/// - Very large documents may incur noticeable re-highlighting cost since the
///   full text is re-tokenized; the short debounce mitigates this during typing.
/// - Rich text is controlled by the component; external attribute mutations may
///   be overwritten on the next highlight pass.
///
/// Bindings:
/// - text: The canonical source of truth for the editor’s content. Updated on
///   every edit.
/// - language: Determines the parser and token colors applied during highlighting.
public struct HighlightedEditor: NSViewRepresentable {

    @Environment(\.colorScheme) var systemColorScheme

    @Binding public var text: String
    public var language: WebCppLanguage

    /// Creates a syntax-highlighted editor bound to the provided text and configured for a language.
    ///
    /// - Parameters:
    ///   - text: A binding to the editor’s plain-text content. The editor writes all user edits
    ///           back through this binding and re-highlights on every change.
    ///   - language: The language used by the WebCpp highlighter to tokenize and colorize the text.
    ///               Changing this value triggers a re-highlighting pass.
    ///
    /// Behavior:
    /// - Preserves cursor position and undo history by updating only text attributes during highlighting.
    /// - Adapts to system color scheme changes and re-applies token colors accordingly.
    /// - Disables smart substitutions to avoid unintended mutations in code (quotes, dashes, etc.).
    ///
    /// Usage:
    /// - Embed in SwiftUI and pass a state or observable property via `text`.
    /// - Provide a `WebCppLanguage` to select the appropriate syntax rules.
    ///
    /// Threading:
    /// - All highlighting and attribute updates occur on the main thread in coordination with NSTextView.
    ///
    /// Performance:
    /// - Applies a short debounce (~50 ms) to re-highlighting after edits to keep typing responsive.
    ///
    /// Requirements:
    /// - WebCppDriver for tokenization and HTML generation.
    /// - WebCppTheme to map token classes to colors and font traits.
    public init(text: Binding<String>, language: WebCppLanguage) {
        self._text = text
        self.language = language
    }

    // MARK: - NSViewRepresentable

    /// Creates the view object and configures its initial state.
    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        configureTextView(textView, coordinator: context.coordinator)
        context.coordinator.textView = textView
        context.coordinator.currentColorScheme = systemColorScheme
        context.coordinator.setContent(text, language: language)
        return scrollView
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        let coord = context.coordinator

        // Always refresh the binding so the coordinator writes to the current snippet.
        coord.binding = $text

        if textView.string != text {
            // External change (e.g. snippet selection switched): replace content.
            coord.setContent(text, language: language)
        } else if coord.currentLanguage != language {
            // Language picker changed: re-highlight existing text.
            coord.currentLanguage = language
            coord.applyHighlighting(to: textView, text: text, language: language)
        } else if coord.currentColorScheme != systemColorScheme {
            // Color scheme changed: update background and re-apply token colors.
            coord.currentColorScheme = systemColorScheme
            textView.backgroundColor    = WebCppTheme.backgroundColor
            textView.insertionPointColor = WebCppTheme.color(for: "nortext")
            coord.applyHighlighting(to: textView, text: text, language: language)
        }
    }

    /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
    public func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }

    /// Cleans up the presented AppKit view (and coordinator) in anticipation of their removal.
    public static func dismantleNSView(_ scrollView: NSScrollView, coordinator: Coordinator) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        textView.undoManager?.removeAllActions()
    }

    // MARK: - Private setup

    private func configureTextView(_ textView: NSTextView, coordinator: Coordinator) {
        textView.isEditable                             = true
        textView.isSelectable                           = true
        textView.allowsUndo                             = true
        textView.isRichText                             = true   // We control all attributes
        textView.usesFontPanel                          = false
        textView.usesFindPanel                          = true
        textView.isAutomaticQuoteSubstitutionEnabled    = false
        textView.isAutomaticDashSubstitutionEnabled     = false
        textView.isAutomaticSpellingCorrectionEnabled   = false
        textView.isAutomaticTextReplacementEnabled      = false
        textView.smartInsertDeleteEnabled               = false
        textView.isVerticallyResizable                  = true
        textView.isHorizontallyResizable                = false
        textView.autoresizingMask                       = [.width]
        textView.textContainer?.widthTracksTextView     = true

        textView.backgroundColor    = WebCppTheme.backgroundColor
        textView.insertionPointColor = WebCppTheme.color(for: "nortext")

        let font = Self.monoFont
        textView.font = font
        textView.typingAttributes = [
            .font:            font,
            .foregroundColor: WebCppTheme.color(for: "nortext")
        ]

        textView.delegate = coordinator
    }

    // MARK: - Font helpers

    static let monoFont     = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    static let monoBold     = NSFont.monospacedSystemFont(ofSize: 13, weight: .bold)
    static let monoItalic: NSFont = {
        // On macOS, withSymbolicTraits returns NSFontDescriptor (non-optional).
        let descriptor = monoFont.fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: descriptor, size: 13) ?? monoFont
    }()

    // MARK: - Coordinator

    /// An NSObject-based delegate and controller that coordinates NSTextView editing,
    /// syntax highlighting, and SwiftUI state synchronization for HighlightedEditor.
    ///
    /// Responsibilities:
    /// - Acts as the NSTextViewDelegate to observe text changes and trigger re-highlighting.
    /// - Bridges edits from the AppKit text view to the SwiftUI Binding<String>.
    /// - Manages the currently selected WebCppLanguage and the active ColorScheme to
    ///   keep highlighting and appearance in sync with user preferences and system changes.
    /// - Applies WebCpp-driven syntax highlighting by updating only text attributes
    ///   (foreground color and font) to preserve cursor position and undo history.
    /// - Debounces frequent edits (≈50 ms) to maintain responsiveness while keeping
    ///   highlighting up to date.
    ///
    /// Lifecycle and usage:
    /// - Created by HighlightedEditor.makeCoordinator() and retained by SwiftUI.
    /// - Receives the NSTextView instance in makeNSView and stores a weak reference
    ///   for later updates.
    /// - On external content changes (e.g., selecting a different snippet), setContent(_:language:)
    ///   replaces the text, resets undo history, and reapplies highlighting.
    /// - On internal edits (user typing), textDidChange(_:) updates the binding and
    ///   schedules a debounced re-highlight pass.
    ///
    /// Scrolling and layout:
    /// - Captures and restores scroll position across attribute updates to avoid jumpiness
    ///   when re-highlighting invalidates layout.
    /// - Forces layout after attribute changes so geometry is correct before restoring
    ///   the scroll origin.
    ///
    /// Threading:
    /// - All operations occur on the main thread. Debounced work is dispatched to the
    ///   main queue to remain synchronized with NSTextView updates.
    ///
    /// Key properties:
    /// - binding: The SwiftUI Binding<String> that mirrors the text view’s content.
    /// - currentLanguage: The active WebCppLanguage that drives tokenization.
    /// - currentColorScheme: The system color scheme used to select theme colors.
    /// - textView: A weak reference to the managed NSTextView.
    /// - debounceItem: A pending DispatchWorkItem used to coalesce rapid edit events.
    ///
    /// Related methods:
    /// - setContent(_:language:): Replaces the entire text and reapplies highlighting,
    ///   clearing the undo stack to prevent cross-snippet actions.
    /// - applyHighlighting(to:text:language:): Runs WebCpp, parses token ranges,
    ///   realigns ranges if necessary, and updates foreground colors and fonts without
    ///   changing the underlying text content.
    /// - textDidChange(_:): NSTextViewDelegate callback that updates the binding and
    ///   debounces a re-highlight pass.
    public final class Coordinator: NSObject, NSTextViewDelegate {

        var binding: Binding<String>
        var currentLanguage: WebCppLanguage = .swift
        var currentColorScheme: ColorScheme = .light
        weak var textView: NSTextView?
        private var debounceItem: DispatchWorkItem?

        init(binding: Binding<String>) {
            self.binding = binding
        }

        /// Replaces the full text content and re-highlights.
        /// Used on initial load and when an external selection change occurs.
        func setContent(_ text: String, language: WebCppLanguage) {
            guard let textView else { return }
            currentLanguage = language

            textView.scroll(.zero)
            // Replace text — this resets the selection to position 0.
            textView.string = text
            // Clear the undo stack so actions from the previous snippet
            // don't bleed into this one.
            textView.undoManager?.removeAllActions()
            textView.typingAttributes = [
                .font:            HighlightedEditor.monoFont,
                .foregroundColor: WebCppTheme.color(for: "nortext")
            ]

            applyHighlighting(to: textView, text: text, language: language)
        }

        /// Applies WebCpp syntax highlighting attributes to the text storage
        /// without modifying the text content (cursor position is preserved).
        func applyHighlighting(to textView: NSTextView, text: String, language: WebCppLanguage) {
            guard !text.isEmpty,
                  let html = WebCppDriver.highlightString(text, filename: language.dummyFilename),
                  let storage = textView.textStorage else { return }

            var result = parseWebCppHTML(html)

            // WebCpp may insert extra characters (e.g. trailing spaces on
            // preprocessor lines).  Realign the parsed ranges to the actual
            // source text so the colours land on the right characters.
            if result.plainText != text {
                result = rebaseTokenRanges(result, to: text)
            }
            let monoFont = HighlightedEditor.monoFont
            let monoBold = HighlightedEditor.monoBold
            let monoItalic = HighlightedEditor.monoItalic
            let nortextColor = WebCppTheme.color(for: "nortext")
            let fullRange = NSRange(location: 0, length: storage.length)

            // Capture scroll position before attribute changes trigger layout invalidation.
            let scrollView = textView.enclosingScrollView
            let savedScrollOrigin = scrollView?.contentView.bounds.origin

            storage.beginEditing()

            // Reset everything to nortext / regular monospace
            storage.addAttribute(.foregroundColor, value: nortextColor, range: fullRange)
            storage.addAttribute(.font,            value: monoFont,     range: fullRange)

            // Apply per-token color (and bold / italic where applicable)
            for token in result.tokenRanges {
                guard token.range.location + token.range.length <= storage.length else { continue }

                storage.addAttribute(.foregroundColor,
                                     value: WebCppTheme.color(for: token.tokenClass),
                                     range: token.range)

                if WebCppTheme.isBold(for: token.tokenClass) {
                    storage.addAttribute(.font, value: monoBold, range: token.range)
                } else if WebCppTheme.isItalic(for: token.tokenClass) {
                    storage.addAttribute(.font, value: monoItalic, range: token.range)
                }
            }

            storage.endEditing()

            // endEditing() marks layout as needing invalidation but defers
            // actual computation.  Force it now so any frame/scroll
            // adjustments happen before we restore the scroll position.
            if let scrollView, let savedScrollOrigin {
                if let layoutManager = textView.layoutManager,
                   let textContainer = textView.textContainer {
                    layoutManager.ensureLayout(for: textContainer)
                }

                let maxY = max(0, (scrollView.documentView?.frame.height ?? 0)
                                - scrollView.contentView.bounds.height)
                let clampedOrigin = NSPoint(
                    x: savedScrollOrigin.x,
                    y: min(savedScrollOrigin.y, maxY)
                )
                scrollView.contentView.setBoundsOrigin(clampedOrigin)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }

        // MARK: NSTextViewDelegate

        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let newText = textView.string

            // Propagate the plain-text change to the SwiftUI binding immediately.
            binding.wrappedValue = newText

            // Re-highlight with a short debounce to avoid redundant work during
            // fast typing. 50 ms is imperceptible to the user and well within the
            // sub-100 ms highlighting budget for typical snippet sizes.
            debounceItem?.cancel()
            let lang = currentLanguage
            let item = DispatchWorkItem { [weak self, weak textView] in
                guard let self, let textView else { return }
                self.applyHighlighting(to: textView, text: newText, language: lang)
            }
            debounceItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: item)
        }
    }
}
