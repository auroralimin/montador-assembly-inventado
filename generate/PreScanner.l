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
\n {
    nLine++;
    return token::ENDL;
}
: {
    return token::COLON;
}
, {
    return token::COMMA;
}
IF {
    return token::IF;
}
EQU {
    return token::EQU;
}
[a-z_]+[a-z0-9_]*: {
    yylval->build<std::string>(yytext);
    return token::LABEL;
}
[^ \n\t]*[^ \n\ta-z0-9_]+[^ \n\t]* {
    yylval->build<std::string>(yytext);
    return token::INVALID;
}
[0-9]+[^ \n\t0-9]+[0-9]* {
    yylval->build<std::string>(yytext);
    return token::INVALID;
}
[a-z_]+[a-z0-9_]* {
    yylval->build<std::string>(yytext);
    return token::NAME;
}
[0-9]+ {
    yylval->build<int>(atoi(yytext));
    return token::NUM;
}
;.*   ;
[ \t] ;
%%

int sb::PreScanner::getLine() {
    return nLine;
}

