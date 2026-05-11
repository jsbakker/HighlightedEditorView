// The YAML Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langyaml.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangYaml::LangYaml() {

    initReservedWords();

    doStringsSinQuote    = true;
    doSymbols            = true;
    doInlineCommentHash  = true;  // #
}

void LangYaml::initReservedWords() {

    // YAML boolean and null scalars (all case variants per the YAML 1.2 core schema)
    string K[] = {
        "false", "null", "true",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // YAML 1.1 legacy boolean aliases still widely used by parsers
    string T[] = {
        "False", "No", "NULL", "Null", "OFF", "ON", "Off",
        "On", "TRUE", "True", "TRUE", "YES", "Yes",
        "no", "off", "on", "yes",
        "FALSE", "NO",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
