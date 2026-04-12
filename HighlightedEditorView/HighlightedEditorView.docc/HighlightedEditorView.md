# ``HighlightedEditorView``

A SwiftUI text editing view with real-time syntax highlighting.

## Overview

The syntax highlighting supports 48 computer languages:

- Ada
- Assembly
- Asp
- Basic
- C
- C#
- C++
- Cascading StyleSheet
- DOS Batch
- EMF
- Euphoria
- F#
- Fortran
- Gherkin
- GLSL
- Go
- Haskell
- HLSL
- HTML
- Java
- JavaScript
- Kotlin
- Modula
- Nasa CLIPS
- NVidia Cg
- Objective-C
- Objective-C++
- OCaml
- Pascal
- Perl
- PHP
- Power Builder
- Python
- R
- RenderMan
- Ruby
- Rust
- Scala
- SQL
- Swift
- Tcl
- TypeScript
- Unix shell
- UnrealScript
- Vala
- VHDL
- XML
- Zig

This framework utilizes native code for highlighting, via the WebCpp syntax highlighter.

### Using HighlightedEditor in SwiftUI
To use the syntax highlighted editor in your SwiftUI application, import `HighlightedEditorView`, and use `HighlightedEditor` in your content view.

```swift
import SwiftUI
import HighlightedEditorView

var sampleMultilineText = """
    func registerAppWait(reply: @escaping (String) -> Void) {
        queue.async {
            if let text = self.pendingText {
                // Work is already queued — deliver immediately
                self.pendingText = nil
                reply(text)
            } else {
                // No work yet — hold the reply until extension submits
                self.appWaitReply = reply
            }
        }
    }
    """

struct ContentView: View {
    var body: some View {

        HighlightedEditor(
        text: Binding(
            get: { sampleMultilineText },
            set: { sampleMultilineText = $0 }
        ), language: .swift)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(8)
            .padding()
    }
}

#Preview {
    ContentView() // Yes, HighlightedEditor works in Previews
}
```
![Test Application](TestApp.png)

Note, how we can edit the contents at runtime, and the editor's new value will be updated by the binding's setter.

### Choose Supported Language
You may also display a language picker with all of the supported languages, and bind it to a state variable.

```swift
    @State private var language: WebCppLanguage = .swift

    // later in view body ...

        Picker("Language", selection: $language) {
            ForEach(WebCppLanguage.allCases) { lang in
                Text(lang.displayName)
                    .tag(lang)
            }
        }
```
## Topics
