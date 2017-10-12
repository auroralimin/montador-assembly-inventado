%{
    #include "PreScanner.hpp"

    #include <string>

    #include "PreParser.hxx"

    using token = sb::PreParser::token;
    int yycolumn = 1;
    #undef  YY_DECL
    #define YY_DECL int sb::PreScanner::yylex(\
                            sb::PreParser::semantic_type *const lval,\
                            sb::PreParser::location_type *loc)
    #define yyterminate() return( token::END )
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION loc->step(); loc->columns(yyleng);
%}

%option yyclass="sb::PreScanner"
%option debug
%option yylineno
%option nodefault
%option noyywrap
%option c++
%option caseless

%%
%{
                  yylval = lval;
%}
\n                {
                  nLine++;
                  return token::ENDL;
                  }
:                 {
                  return token::COLON;
                  }
,                 {
                  return token::COMMA;
                  }
IF                {
                  return token::EQU_IF;
                  }
[a-z_]+[a-z0-9_]* {
                  std::string name(yytext);
                  transform(name.begin(), name.end(), name.begin(), ::toupper);
                  yylval->build<std::string>(name);
                  return token::NAME;
                  }
EQU[ \t][0-9]+    {
                  std::string matchedText(yytext);
                  int len = matchedText.length();
                  std::string value = matchedText.substr(len-1, len);
                  yylval->build<int>(stoi(value));
                  return token::EQU_VAL;
                  }
;.*               ;
[ \t]+            ;
.                 ;
%%

int sb::PreScanner::getLine() {
    return nLine;
}

