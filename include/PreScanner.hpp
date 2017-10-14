#ifndef SB_PRE_SCANNER_HPP
#define SB_PRE_SCANNER_HPP

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "PreParser.hxx"
#include "location.hh"

namespace sb{
    class PreScanner : public yyFlexLexer{
        public:
            using FlexLexer::yylex;

            PreScanner(std::istream *in) : yyFlexLexer(in) {};
            virtual ~PreScanner() {};
            virtual int yylex(sb::PreParser::semantic_type * const lval,
                              sb::PreParser::location_type *location);
            int getLine();

        private:
            int processInvalidToken();
            sb::PreParser::semantic_type *yylval = nullptr;
            int nLine = 0;
    };
}

#endif

