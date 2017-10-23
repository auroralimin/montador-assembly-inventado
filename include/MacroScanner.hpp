#ifndef MAC_MACRO_SCANNER_HPP
#define MAC_MACRO_SCANNER_HPP

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "macro/MacroParser.hxx"
#include "macro/location.hh"

namespace mac{
    class MacroScanner : public yyFlexLexer{
    public:
        using FlexLexer::yylex;
        
        MacroScanner(std::istream *in) : yyFlexLexer(in) {};
        virtual ~MacroScanner() { };
        virtual int yylex(mac::MacroParser::semantic_type * const lval,
                          mac::MacroParser::location_type *location);
        int getLine();
        
    private:
        int processInvalidToken();
        mac::MacroParser::semantic_type *yylval = nullptr;
        int nLine = 0;
    };
}

#endif

