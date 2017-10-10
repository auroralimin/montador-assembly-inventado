%{
    #include <string>

    #include "PreScanner.hpp"
    #include "PreParser.hxx"
    #undef  YY_DECL
    #define YY_DECL int sb::PreScanner::yylex(\
                            sb::PreParser::semantic_type *const lval,\
                            sb::PreParser::location_type *loc)

    using token = sb::PreParser::token;

    #define yyterminate() return( token::END )

    #define YY_NO_UNISTD_H

    #define YY_USER_ACTION loc->step(); loc->columns(yyleng);
%}

%option debug
%option nodefault
%option yyclass="sb::PreScanner"
%option noyywrap
%option c++

%%
%{ 
            yylval = lval;
%}
\n                    {
                      nLine++;
                      return token::ENDL;
                      }
:                     {
                      return token::COLON;
                      }
IF                    {
                      return token::EQU_IF;
                      }
[a-zA-Z]+[a-zA-Z0-9]* {
                      yylval->build<std::string>(yytext);
                      return token::NAME;
                      }
EQU[ \t][0-1]         {
                      std::string matchedText(yytext);
                      int len = matchedText.length();
                      std::string value = matchedText.substr(len-1, len);
                      yylval->build<int>(stoi(value));
                      return token::EQU_VAL;
                      }
;.+                   ;
[ \t]                 ;
.                     ;
%%

int sb::PreScanner::getLine() {
    return nLine;
}

