%{
    #include "Scanner.hpp"

    #include <string>

    #include "Driver.hpp"
    #include "OutFormat.hpp"
    #include "Parser.hxx"

    using token = sb::Parser::token;
    int yycolumn = 1;

    #undef  YY_DECL
    #define YY_DECL int sb::Scanner::yylex(\
                            sb::Parser::semantic_type *const lval,\
                            sb::Parser::location_type *location)
    #define yyterminate() return token::END
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION location->step(); location->columns(yyleng);
%}

%option yyclass="sb::Scanner"
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
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "ENDL token" << std::endl;
    }
    return token::ENDL;
}
, {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "COMMA token" << std::endl;
    }
    return token::COMMA;
}
TEXT {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "TEXT token" << std::endl;
    }
    return token::TEXT;
}
DATA {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "DATA token" << std::endl;
    }
    return token::DATA;
}
ADD {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "ADD token" << std::endl;
    }
    return token::ADD;
}
SUB {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "SUB token" << std::endl;
    }
    return token::SUB;
}
MULT {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "MULT token" << std::endl;
    }
    return token::MULT;
}
DIV {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "DIV token" << std::endl;
    }
    return token::DIV;
}
JMP {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "JMP token" << std::endl;
    }
    return token::JMP;
}
JMPP {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "JMPP token" << std::endl;
    }
    return token::JMPP;
}
JMPN {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "JMPN token" << std::endl;
    }
    return token::JMPN;
}
JMPZ {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "JUMPZ token" << std::endl;
    }
    return token::JMPZ;
}
COPY {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "COPY token" << std::endl;
    }
    return token::COPY;
}
LOAD {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "LOAD token" << std::endl;
    }
    return token::LOAD;
}
STORE {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "STORE token" << std::endl;
    }
    return token::STORE;
}
INPUT {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "INPUT token" << std::endl;
    }
    return token::INPUT ;
}
OUTPUT {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "OUTPUT token" << std::endl;
    }
    return token::OUTPUT;
}
STOP {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "STOP token" << std::endl;
    }
    return token::STOP;
}
SECTION {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "SECTION token" << std::endl;
    }
    return token::SECTION;
}
SPACE {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "SPACE token" << std::endl;
    }
    return token::SPACE;
}
CONST {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "CONST token" << std::endl;
    }
    return token::CONST;
}

[+-]*0x[0-9a-fA-F]+[ \n\t] {
    std::string str(yytext);
    yyless(str.length() - 1);
    int num = std::stoi(yytext, 0, 16);
    yylval->build<int>(num);
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "Hex NUM token" << std::endl;
    }
    return token::NUM;
}
[+-]*(0x)*[0-9]+[ \n\t] {
    std::string str(yytext);
    yyless(str.length()-1);
    int num = std::stoi(yytext);
    yylval->build<int>(num);
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "NUM token" << std::endl;
    }
    return token::NUM;
}
[a-z_]+[a-z0-9_]*: {
    std::string label(yytext);
    label = label.substr(0, label.length() - 1);
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "LABEL token" << std::endl;
    }
    yylval->build<std::string>(label);
    return token::LABEL;
}
[^ \n\t:]*[^ \n\ta-z0-9_,:]+[^ \n\t:]*:* {
    return processInvalidToken();
}
[0-9]+[^ \n\t0-9]+[^ \n\t]*:* {
    return processInvalidToken();
}
[a-z_]+[a-z0-9_]* {
    if (DEBUG) {
        const std::string blue = COLOR(sb::color::blue);
        std::cout << blue << "Scanner: " << OFF << "NAME token" << std::endl;
    }
    yylval->build<std::string>(yytext);
    return token::NAME;
}
;.*   ;
[ \t] ;
%%

int sb::Scanner::getLine() {
    return nLine;
}

int sb::Scanner::processInvalidToken() {
    std::string invalid(yytext);
    yylval->build<std::string>(invalid);
    if (!invalid.compare(invalid.length() - 1, 1, ":")) {
        if (DEBUG) {
            const std::string blue = COLOR(sb::color::blue);
            std::cout << blue << "Scanner: " << OFF
                      << "Invalid LABEL token: \""
                      << yytext << "\"" << std::endl;
        }
        return token::LABEL;
    } else {
        if (DEBUG) {
            const std::string blue = COLOR(sb::color::blue);
            std::cout << blue << "Scanner: " << OFF 
                      << "INVALID token: \"" << yytext << "\"" << std::endl;
        }
        return token::INVALID;
    }
}

