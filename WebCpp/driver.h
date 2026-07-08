/* webcpp - driver.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef DRIVER_H
#define DRIVER_H

#define HELP_LANGUAGES 'L'
#define HELP_DEFAULT 'D'

#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include <swift/bridging>

class CFfile;
class Engine;

// Type alias so Swift sees a concrete type rather than a 2-param generic.
using WebCppStringVector = std::vector<std::string>;

class SWIFT_SHARED_REFERENCE(webcpp_driver_retain, webcpp_driver_release)
Driver {
  public:
    Driver();
    ~Driver();
    bool switch_parser(const std::string &arg);
    uint8_t getExt(const std::string &filename) const;
    std::string checkExt(const std::string &filename);
    static void makeIndex(const std::string &prefix);
    bool prep_files(const std::string &ifile, const std::string &ofile, char over);
    std::string getTitle() const;
    void drive();
    std::string highlight_from_string(const std::string &source,
                                      const std::string &filename,
                                      const WebCppStringVector &options = {});

  private:
    void clean();
    void endio();

  protected:
    std::shared_ptr<CFfile> ObjIO;
    std::unique_ptr<Engine> lang;

    std::string iFile;
    std::string oFile;
};

// ARC retain/release stubs required by SWIFT_SHARED_REFERENCE.
// Driver instances are single-owner; retain is a no-op, release deletes.
inline void webcpp_driver_retain(Driver *) {}
inline void webcpp_driver_release(Driver *d) { delete d; }

#endif // DRIVER_H
