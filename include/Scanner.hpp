#ifndef SB_PRE_SCANNER_HPP
#define SB_PRE_SCANNER_HPP

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "Parser.hxx"
#include "location.hh"

namespace sb{
    class Scanner : public yyFlexLexer{
        public:
            using FlexLexer::yylex;

            Scanner(std::istream *in) : yyFlexLexer(in) {};
            virtual ~Scanner() {};
            virtual int yylex(sb::Parser::semantic_type * const lval,
                              sb::Parser::location_type *location);
            int getLine();

        private:
            int processInvalidToken();
            sb::Parser::semantic_type *yylval = nullptr;
            int nLine = 0;
    };
}

#endif

