%{
    #include "MacroScanner.hpp"

    #include <string>

    #include "DriverMacro.hpp"
    #include "macro/MacroParser.hxx"

    using token = mac::MacroParser::token;
    int yycolumn = 1;

    #undef  YY_DECL
    #define YY_DECL int mac::MacroScanner::yylex(\
                            mac::MacroParser::semantic_type *const lval,\
                            mac::MacroParser::location_type *location)
    #define yyterminate() return token::END
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION location->step(); location->columns(yyleng);
%}

%option yyclass="mac::MacroScanner"
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
linha.[0-9]+ {
    std::string str(yytext);
    str = str.substr(6, str.length());
    nLine = atoi(str.c_str());
}
\n {
    if (DEBUG) std::cout << "ENDL token" << std::endl;
    return token::ENDL;
}
, {
    if (DEBUG) std::cout << "COMMA token" << std::endl;
    return token::COMMA;
}
MACRO {
    if (DEBUG) std::cout << "MACRO token" << std::endl;
    return token::MACRO;
}
ENDMACRO {
    if (DEBUG) std::cout << "ENDMACRO token" << std::endl;
    return token::ENDMACRO;
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

int mac::MacroScanner::getLine() {
    return nLine;
}

int mac::MacroScanner::processInvalidToken() {
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

