// The YAML Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#pragma once
#include "lang_rules.h"

class LangYaml : public LanguageRules {
  public:
    LangYaml();
    void initReservedWords() override;
};
