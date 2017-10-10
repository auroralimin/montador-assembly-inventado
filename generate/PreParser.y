%skeleton "lalr1.cc"
%require  "3.0"
%debug
%defines
%define api.namespace {sb}
%define parser_class_name {PreParser}
%define api.value.type variant

%code requires {
     namespace sb {
        class Driver;
        class PreScanner;
    }
}

%parse-param {PreScanner &preScanner}
%parse-param {Driver &driver}

%code{
    #include "Driver.hpp"

    #undef yylex
    #define yylex preScanner.yylex
}

%token               COLON
%token <std::string> NAME
%token <int>         EQU_VAL
%token <std::string> EQU_IF
%token               ENDL
%token               END 0

%type <std::string> line
%type <std::string> label
%type <std::string> command

%locations

%%

pre_processor
    : equ  pre_processor
    | equ
    | if   pre_processor
    | if
    | line pre_processor
    | line
    | ENDL pre_processor
    | ENDL
    ;

line
    : label ENDL {
          $$ = $1 + ": ";
          driver.insertLine(preScanner.getLine(), $$);
      }
    | label command ENDL {
          $$ = $1 + ": " + $2;
          driver.insertLine(preScanner.getLine(), $$);
      }
    | command ENDL {
          $$ = $1;
          driver.insertLine(preScanner.getLine(), $$);
      }
    ;

command
    : NAME command {
          $$ = $1 + " " + $2;
     }
    | NAME {
          $$ = $1;
      }
    ;

equ
    : label EQU_VAL ENDL {
          driver.insertEqu($1, $2);
      }
    | label ENDL EQU_VAL ENDL {
          driver.insertEqu($1, $3);
      }
    ;

if
    : EQU_IF NAME line {
          int nLine = preScanner.getLine();
          if (!driver.getEqu($2, nLine)) {
              driver.deleteLine(nLine);
          }
      }
    | EQU_IF NAME ENDL line {
          int nLine = preScanner.getLine();
          if (!driver.getEqu($2, nLine)) {
              driver.deleteLine(nLine);
          }
      }
    ;

label
    : NAME COLON {
          $$ = $1;
      }
    ;

%%

void sb::PreParser::error(const location_type &l, const std::string &errMsg) {
   std::cerr << "Erro na linha " << l << ": " << errMsg << std::endl;
}

