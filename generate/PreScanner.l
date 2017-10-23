%{
    #include "PreScanner.hpp"

    #include <string>

    #include "Driver.hpp"
    #include "pre/PreParser.hxx"

    using token = sb::PreParser::token;
    int yycolumn = 1;

    #undef  YY_DECL
    #define YY_DECL int sb::PreScanner::yylex(\
                            sb::PreParser::semantic_type *const lval,\
                            sb::PreParser::location_type *location)
    #define yyterminate()   static int once = 0;\
                            return once++ ? token::ENDL : token::END;
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION location->step(); location->columns(yyleng);
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
    if (DEBUG) std::cout << "ENDL token" << std::endl;
    return token::ENDL;
}
, {
    if (DEBUG) std::cout << "COMMA token" << std::endl;
    return token::COMMA;
}
IF {
    if (DEBUG) std::cout << "IF token" << std::endl;
    return token::IF;
}
EQU {
    if (DEBUG) std::cout << "EQU token" << std::endl;
    return token::EQU;
}
CONST {
    if (DEBUG) std::cout << "CONST token" << std::endl;
    return token::CONST;
}
[+-]*0x[0-9a-fA-F]+[ \n\t] {
    std::string str(yytext);
    yyless(str.length()-1);
    int num = std::stoi(yytext, 0, 16);
    yylval->build<int>(num);
    if (DEBUG) std::cout << "Hex NUM token: \"" << num << "\"" << std::endl;
    return token::NUM;
}
[+-]*(0x)*[0-9]+[ \n\t] {
    std::string str(yytext);
    yyless(str.length()-1);
    int num = std::stoi(yytext);
    yylval->build<int>(num);
    if (DEBUG) std::cout << "NUM token: \"" << num << "\"" << std::endl;
    return token::NUM;
}
[a-z_]+[a-z0-9_]*: {
    if (DEBUG) std::cout << "LABEL token: \"" << yytext << "\"" << std::endl;
    yylval->build<std::string>(yytext);
    return token::LABEL;
}
[^ \n\t:]*[^ \n\ta-z0-9_,:]+[^ \n\t:]*:* {
    return processInvalidToken();
}
[0-9]+[^ \n\t0-9]+[^ \n\t]*:* {
    return processInvalidToken();
}
[a-z_]+[a-z0-9_]* {
    if (DEBUG) std::cout << "NAME token: \"" << yytext << "\"" << std::endl;
    yylval->build<std::string>(yytext);
    return token::NAME;
}
;.*   ;
[ \t] ;
%%

int sb::PreScanner::getLine() {
    return nLine;
}

int sb::PreScanner::processInvalidToken() {
    std::string invalid(yytext);
    yylval->build<std::string>(invalid);
    if (!invalid.compare(invalid.length() - 1, 1, ":")) {
        if (DEBUG) {
            std::cout << "Invalid LABEL token: \""
                      << yytext << "\"" << std::endl;
        }
        return token::LABEL;
    } else {
        if (DEBUG) {
            std::cout << "INVALID token: \"" << yytext << "\"" << std::endl;
        }
        return token::INVALID;
    }
}

