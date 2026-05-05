# Add a new language to WebCpp + HighlightedEditorView

Follow these steps to add support for a new syntax-highlighted language. Four files touch the C++ engine; one file touches the Swift layer.

---

## 1. Choose a lang ID constant (`WebCpp/languages/deflangs.h`)

Pick an unused `uint8_t` hex value and add a constant to the `lang` namespace, following the existing pattern:

```cpp
inline constexpr std::uint8_t LUA_FILE = 0x3E;   // next available after 0x3D
```

Also `#include` the new header you'll create in step 2 here.

---

## 2. Write the language header (`WebCpp/languages/lang<name>.h`)

Boilerplate — just declare the class:

```cpp
// The Lua Language definition file for Web C Plus Plus
#pragma once
#include "lang_rules.h"

class LangLua : public LanguageRules {
  public:
    LangLua();
    void initReservedWords() override;
};
```

---

## 3. Write the language implementation (`WebCpp/languages/lang<name>.cpp`)

The constructor sets flags from `LanguageRules`; `initReservedWords()` populates `keys` (bold keywords) and `types` (bold type names).

### All available flags

**Strings**
| Flag | Effect |
|---|---|
| `doStringsDblQuote = true` | Highlight `"…"` strings (default **on**) |
| `doStringsSinQuote = true` | Highlight `'…'` strings |
| `doStringsBackTick = true` | Highlight `` `…` `` strings |
| `doMultilineStrTripleDblQuote = true` | Highlight `"""…"""` triple-quoted strings |
| `doMultilineStrRaw = true` | Highlight raw string literals (e.g. Rust `r"…"`, Go `` `…` ``) |
| `doMultilineStrHeredoc = true` | Highlight `<<MARKER … MARKER` heredocs |
| `doMultilineStrHeredocTpl = true` | Heredoc variant used by some template languages |
| `doMultilineStrPercentQ = true` | Highlight Ruby-style `%q{…}` / `%Q{…}` strings |
| `doRequireBackslashContinuation = false` | Allow string literals to span lines without a trailing `\` (Ruby, Perl, Shell, PHP, Tcl). Default is **true** (most languages). |

**String interpolation** (highlight the `${expr}` part inside strings)
```cpp
doInterpolate = true;
interpolStart = "${";   // opening marker, e.g. "${" (JS/Kotlin), "#{" (Ruby), "\\(" (Swift), "{" (Python f-strings)
interpolEnd   = '}';    // closing char
interpolCssClass = "dblquot";  // CSS class of the string type that interpolates (usually leave as default)
```

**Comments — inline (single-line)**
| Flag | Style |
|---|---|
| `doInlineCommentDblSlash = true` | `//` (C, C++, Java, Swift, Go, Rust, …) |
| `doInlineCommentHash = true` | `#` (Python, Ruby, Shell, Perl, R, …) |
| `doInlineCommentDblDash = true` | `--` (Lua, SQL, Ada, Haskell, …) |
| `doInlineCommentSemiColon = true` | `;` (Assembly, Lisp, Clojure, …) |
| `doInlineCommentRem = true` | `REM` / `rem` (DOS Batch, BASIC) |
| `doInlineCommentSingleQuote = true` | `'` (Visual Basic style) |
| `doInlineCommentDblColon = true` | `::` (DOS Batch labels-as-comments) |
| `doFirstCharCommentFortran = true` | `C` or `*` in column 1 (fixed-form Fortran) |
| `doFirstCharCommentHash = true` | `#` only when it is the very first character of the line |

**Comments — block (multi-line)**
| Flag | Style |
|---|---|
| `doBlockCommentPLI = true` | `/* … */` (C, C++, Java, Swift, Kotlin, CSS, Rust, …) |
| `doBlockCommentPascal = true` | `(* … *)` (Pascal, OCaml, Modula-2) |
| `doBlockCommentHaskell = true` | `{- … -}` (Haskell) |
| `doBlockCommentMarkup = true` | `<!-- … -->` (HTML, XML) |
| `doBlockCommentLua = true` | `--[[ … ]]` (Lua) |
| `doBlockCommentPowerShell = true` | `<# … #>` (PowerShell) |
| `doBlockCommentJulia = true` | `#= … =#` (Julia) |
| `doBlockCommentNim = true` | `#[ … ]#` (Nim) |
| `doBlockCommentD = true` | `/+ … +/` nestable (D) |

**Important:** never use an existing flag as an approximation for a different token. If the language's block comment style isn't listed above, add a new flag + inline wrapper + `doParsing()` dispatch following the pattern in `engine.h` and `engine.cpp`. The four files to touch are `lang_rules.h`, `engine.h`, `engine.cpp` (in `doParsing()`), and this command's flag table.

**Numbers**
| Flag | Effect |
|---|---|
| `doNumbers = true` | Highlight integer and float literals (default **on**) |
| `doUnderscoreNumbers = true` | Also highlight `1_000_000`-style numeric separators |

**Keywords & symbols**
| Flag | Effect |
|---|---|
| `doKeywords = true` | Match `keys` and `types` word lists (default **on**) |
| `doCaseKeys = true` | Keywords are case-sensitive (default **on**; set false for SQL, BASIC, etc.) |
| `doSymbols = true` | Highlight operators/punctuation as `symbols` class |
| `doLabels = true` | Highlight label-style identifiers |

**Preprocessor & sigils**
| Flag | Effect |
|---|---|
| `doPreProc = true` | Highlight `#directive` lines (C/C++ `#include`, Rust `#[attr]`) |
| `doScalars = true` | Highlight `$name` variables (Perl, PHP, Shell, PowerShell) |
| `doArrays = true` | Highlight `@name` arrays (Perl) |
| `doHashes = true` | Highlight `%name` hashes (Perl) |
| `doHtmlTags = true` | Highlight `<tag>` inside the text (used by HTML/ASP/PHP modes) |

### Example — Lua

```cpp
#include "langlua.h"
#include <algorithm>
#include <iterator>
#include <string>
using std::string;

LangLua::LangLua() {
    initReservedWords();

    doStringsSinQuote        = true;
    doSymbols                = true;
    doInlineCommentDblDash   = true;   // --
    doBlockCommentLua        = true;   // --[[ … ]]
}

void LangLua::initReservedWords() {
    string K[] = {
        "and", "break", "do", "else", "elseif", "end", "false", "for",
        "function", "goto", "if", "in", "local", "nil", "not", "or",
        "repeat", "return", "then", "true", "until", "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    string T[] = {
        "coroutine", "io", "math", "os", "package", "string", "table", "utf8",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
```

### Example — Dart (very close to Kotlin)

```cpp
LangDart::LangDart() {
    initReservedWords();
    doStringsSinQuote           = true;
    doSymbols                   = true;
    doUnderscoreNumbers         = true;
    doBlockCommentPLI           = true;   // /* */
    doInlineCommentDblSlash     = true;   // //
    doMultilineStrTripleDblQuote = true;  // """…"""
    doInterpolate               = true;
    interpolStart               = "${";
    interpolEnd                 = '}';
}
```

---

## 4. Register in the factory (`WebCpp/languages/lang_factory.cpp`)

Two places:

**a) Extension map** — add every file extension that maps to this language:
```cpp
{"lua", lang::LUA_FILE},
```

**b) `createFromFilename` switch** — add a case:
```cpp
case (lang::LUA_FILE):
    return {make_unique<LangLua>(), id, "Lua script"};
```

---

## 5. Add the Swift enum case (`HighlightedEditorView/WebCppWrapper/WebCppLanguage.swift`)

Add a case to `WebCppLanguage` with the primary extension as `rawValue`, and a `displayName`:

```swift
case lua = "lua"
// …
case .lua: return "Lua"
```

The `dummyFilename` property (`"snippet.\(rawValue)"`) is automatically used by the driver for language detection, so no further Swift changes are needed.

---

## 6. Update the README (`README.md`)

Increment the language count in the opening sentence and add the language name to the alphabetically sorted list:

```markdown
The syntax highlighting supports 54 computer languages:
...
- Lua
...
```

## 7. Write tests (`HighlightedEditorViewTests/WebCpp/<Name>HighlightTests.swift`)

**Every flag you set to `true` in the constructor must have a corresponding test.** Go through the constructor line by line and write a test for each one. An untested flag is a silent bug — it may be misconfigured, approximate, or broken, and no one will know.

| Flag set in constructor | Required test |
|---|---|
| `doKeywords` (always on) | keywords highlighted as `keyword` |
| `types` list populated | types highlighted as `keytype` |
| `doStringsDblQuote` | double-quoted string produces `dblquot` span |
| `doStringsSinQuote` | single-quoted string produces `sinquot` span |
| `doStringsBackTick` | backtick string produces `dblquot` span |
| `doMultilineStrTripleDblQuote` | `"""…"""` produces `dblquot` span |
| `doMultilineStrRaw` | raw string literal produces `dblquot` span |
| `doMultilineStrHeredoc` | heredoc produces `dblquot` span |
| `doMultilineStrPercentQ` | `%Q{…}` / `%q{…}` produce correct spans |
| `doInterpolate` | interpolation marker inside a string is highlighted |
| `doInlineCommentDblSlash` | `// text` produces `comment` span |
| `doInlineCommentHash` | `# text` produces `comment` span |
| `doInlineCommentDblDash` | `-- text` produces `comment` span |
| `doInlineCommentSemiColon` | `; text` produces `comment` span |
| `doInlineCommentRem` | `REM text` produces `comment` span |
| `doInlineCommentSingleQuote` | `' text` produces `comment` span |
| `doBlockCommentPLI` | `/* … */` produces `comment` span |
| `doBlockCommentPascal` | `(* … *)` produces `comment` span |
| `doBlockCommentHaskell` | `{- … -}` produces `comment` span |
| `doBlockCommentMarkup` | `<!-- … -->` produces `comment` span |
| `doBlockCommentLua` | `--[[ … ]]` produces `comment` span |
| `doBlockCommentPowerShell` | `<# … #>` produces `comment` span |
| `doBlockCommentJulia` | `#= … =#` produces `comment` span |
| `doBlockCommentNim` | `#[ … ]#` produces `comment` span |
| `doBlockCommentD` | `/+ … +/` produces `comment` span |
| `doInlineCommentDblColon` | `:: text` produces `comment` span |
| `doFirstCharCommentFortran` | `C ...` / `* ...` in column 1 produces `comment` span |
| `doFirstCharCommentHash` | `#` at column 1 produces `comment` span |
| `doPreProc` | `#directive` produces `preproc` span |
| `doScalars` | `$var` produces `preproc` span |
| `doArrays` | `@arr` produces `preproc` span |
| `doHashes` | `%hash` produces `preproc` span |
| `doLabels` | label identifier produces `preproc` span |
| `doHtmlTags` | `<tag>` produces correct span |
| `doSymbols` | an operator produces `symbols` span |
| `doNumbers` | an integer literal produces `integer` span |
| `doUnderscoreNumbers` | `1_000` produces `integer` span |
| `doCaseKeys = false` | UPPERCASE keyword is still highlighted |

Use `HighlightTestHelper.highlight(_:language:)` with the file extension string:

```swift
import XCTest
@testable import HighlightedEditorView

final class LuaHighlightTests: XCTestCase {

    func testKeywords() {
        let html = HighlightTestHelper.highlight("local x = nil", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=keyword>local</font>"))
        XCTAssertTrue(html.contains("<font CLASS=keyword>nil</font>"))
    }

    func testLineComment() {
        let html = HighlightTestHelper.highlight("x = 1 -- comment", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=comment>-- comment</font>"))
    }

    func testBlockComment() {
        let html = HighlightTestHelper.highlight("--[[ block\ncomment ]]", language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=comment>--[["))
        XCTAssertTrue(html.contains("]]</font>"))
    }

    func testString() {
        let html = HighlightTestHelper.highlight(#""hello""#, language: "lua")
        XCTAssertTrue(html.contains("<font CLASS=dblquot>"))
    }
}
```

---

## Checklist

- [ ] `deflangs.h` — new `constexpr` ID constant + `#include`
- [ ] `lang<name>.h` — class declaration
- [ ] `lang<name>.cpp` — constructor flags + `initReservedWords()`
- [ ] `lang_factory.cpp` — extension map entries + switch case
- [ ] `WebCppLanguage.swift` — enum case + `displayName`
- [ ] `README.md` — increment language count + add name to sorted list
- [ ] `<Name>HighlightTests.swift` — **one test per flag set to `true` in the constructor**, using the table above as the guide
