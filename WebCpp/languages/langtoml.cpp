// The TOML Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langtoml.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangToml::LangToml() {

    initReservedWords();

    doStringsSinQuote           = true;
    doSymbols                   = true;
    doUnderscoreNumbers         = true;
    doMultilineStrTripleDblQuote = true;  // """…"""
    doInlineCommentHash          = true;   // #
}

void LangToml::initReservedWords() {

    // TOML boolean literals
    string K[] = {
        "false", "true",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));
}
