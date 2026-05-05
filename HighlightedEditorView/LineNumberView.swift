//
//  LineNumberView.swift
//  HighlightedEditorView
//
//  A plain NSView that draws line numbers alongside an NSTextView.
//  Uses no NSRulerView machinery — the text view's layout and rendering
//  are completely unaffected.
//

import AppKit

/// A view that draws line numbers aligned to each line of an associated NSTextView.
///
/// Placed to the left of the scroll view in an `EditorContainerView`. Because this is
/// a plain `NSView` sibling of the scroll view (not an `NSRulerView` attached to it),
/// there is zero interaction with the text view's text-container inset, paragraph-style
/// markers, or any other AppKit ruler machinery. Line numbers are never part of the
/// text binding and cannot be selected or edited.
///
/// Scroll synchronisation is achieved by observing `NSView.boundsDidChangeNotification`
/// on the scroll view's content (clip) view, which fires on every scroll event.
/// Coordinate conversion from text-view space to this view's space is handled by
/// `convert(_:from:)`, which AppKit resolves through the full view hierarchy and
/// therefore automatically accounts for the current scroll offset.
final class LineNumberView: NSView {

    private weak var textView: NSTextView?
    private let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    private static let horizontalPadding: CGFloat = 6
    private nonisolated(unsafe) var boundsObservation: NSObjectProtocol?

    /// The fixed gutter width, computed from the font metrics for a 4-digit line number.
    /// Supports files up to 9999 lines without any layout change.
    static let gutterWidth: CGFloat = {
        let font   = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        let sample = String(repeating: "8", count: 4) as NSString
        let w      = sample.size(withAttributes: [.font: font]).width
        return ceil(w + 2 * horizontalPadding)
    }()

    override var isFlipped: Bool { true }

    init(textView: NSTextView) {
        self.textView = textView
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    /// Registers for scroll notifications so line numbers redraw when the user scrolls.
    /// Call this after both this view and the scroll view are in the view hierarchy.
    func startObservingScroll(in scrollView: NSScrollView) {
        scrollView.contentView.postsBoundsChangedNotifications = true
        boundsObservation = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.needsDisplay = true }
        }
    }

    deinit {
        if let obs = boundsObservation {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        // Gutter background
        WebCppTheme.backgroundColor.setFill()
        bounds.fill()

        // 1-pt separator on the trailing edge
        WebCppTheme.color(for: "comment").withAlphaComponent(0.3).setFill()
        NSRect(x: bounds.maxX - 1, y: dirtyRect.minY,
               width: 1, height: dirtyRect.height).fill()

        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        layoutManager.ensureLayout(for: textContainer)

        let source      = textView.string as NSString
        let totalGlyphs = layoutManager.numberOfGlyphs
        let fg          = WebCppTheme.color(for: "comment")
        let fallbackH   = font.ascender - font.descender + font.leading

        // Empty document: draw "1" at the text container origin.
        guard totalGlyphs > 0 else {
            let tvOrigin = textView.textContainerOrigin
            let ptInSelf = convert(NSPoint(x: 0, y: tvOrigin.y), from: textView)
            drawNumber(1, atY: ptInSelf.y, lineHeight: fallbackH, color: fg)
            return
        }

        var lineNumber    = 1
        var prevCharIndex = -1
        let fullRange     = NSRange(location: 0, length: totalGlyphs)

        layoutManager.enumerateLineFragments(forGlyphRange: fullRange) {
            [weak self] (_, usedRect, _, glyphRange, stop) in
            guard let self else { stop.pointee = true; return }

            let charRange = layoutManager.characterRange(
                forGlyphRange: glyphRange, actualGlyphRange: nil)
            let firstChar = charRange.location

            // A new logical line starts at the first fragment, or when the
            // character immediately preceding this fragment is a newline.
            let isNewLine: Bool
            if prevCharIndex < 0 {
                isNewLine = true
            } else if firstChar > 0 {
                isNewLine = source.character(at: firstChar - 1)
                               == unichar(("\n" as Unicode.Scalar).value)
            } else {
                isNewLine = false
            }

            if isNewLine {
                // usedRect is in text-container space; add textContainerOrigin to
                // reach text-view space, then convert to this view's space.
                // The conversion accounts for the current scroll offset automatically.
                let tvOrigin = textView.textContainerOrigin
                let ptInTV   = NSPoint(x: usedRect.origin.x + tvOrigin.x,
                                       y: usedRect.origin.y + tvOrigin.y)
                let ptInSelf = self.convert(ptInTV, from: textView)

                if ptInSelf.y + usedRect.height >= dirtyRect.minY &&
                   ptInSelf.y <= dirtyRect.maxY {
                    self.drawNumber(lineNumber, atY: ptInSelf.y,
                                    lineHeight: usedRect.height, color: fg)
                }
                lineNumber += 1
            }
            prevCharIndex = firstChar
        }
    }

    private func drawNumber(_ n: Int, atY y: CGFloat, lineHeight: CGFloat, color: NSColor) {
        let str   = "\(n)" as NSString
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let size  = str.size(withAttributes: attrs)
        // Right-align within the gutter, with padding on the right.
        let x    = bounds.width - size.width - Self.horizontalPadding
        // Vertically center within the line fragment.
        let yOff = y + (lineHeight - size.height) / 2
        str.draw(in: NSRect(x: x, y: yOff, width: size.width, height: size.height),
                 withAttributes: attrs)
    }
}
