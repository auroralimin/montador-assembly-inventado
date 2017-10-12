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
   
    #include <exception>

    #include "MapException.hpp"

    #undef yylex
    #define yylex preScanner.yylex

    #define UNUSED_VAR (void)

    bool equif = true;
}

%token               COLON
%token               COMMA
%token <std::string> NAME
%token               EQU
%token <int>         NUM
%token               IF
%token               ENDL
%token               END 0

%type <std::string> name
%type <std::string> line
%type <std::string> label
%type <std::string> command

%locations

%%

pre_processor
    : equ      pre_processor
    | equ
    | if       pre_processor
    | if
    | line     pre_processor
    | line
    | end_line pre_processor
    | end_line
    ;

line
    : label end_line {
          $$ = $1 + ": ";
          if (equif) {
              driver.insertLine(preScanner.getLine(), $$);
          } else {
              equif = true;
          }
      }
    | label command end_line {
          $$ = $1 + ": " + $2;
          if (equif) {
              driver.insertLine(preScanner.getLine(), $$);
              equif = true;
          } else {
              equif = true;
          }
      }
    | command end_line {
          $$ = $1;
          if (equif) {
              driver.insertLine(preScanner.getLine(), $$);
              equif = true;
          } else {
              equif = true;
          }
      }
    ;

command
    : name command {
          try {
              $$ = std::to_string(driver.getEqu($1)) + " " + $2;
          } catch (std::exception &e) {
              $$ = $1 + " " + $2;
          }
      }
    | name {
          try {
              $$ = std::to_string(driver.getEqu($1));
          } catch (std::exception &e) {
              $$ = $1;
          }
      }
    ;

name
    : NAME {
          $$ = $1;
      }
    | NAME COMMA {
          $$ = $1 + ",";
      }
    ;

equ
    : label EQU NUM end_line {
          driver.insertEqu($1, $3);
      }
    | label end_line EQU NUM end_line {
          driver.insertEqu($1, $4);
      }
    ;

if
    : IF NAME line {
          int nLine = preScanner.getLine();
          try {
              if (driver.getEqu($2) <= 0) {
                  equif = false;
              }
          } catch (sb::MapException &e) {
              driver.printError(nLine, $2,
                                "IF para rótulo EQU não declarado.",
                                sb::errorType::warning);
          }
      }
    | IF NAME {
          int nLine = preScanner.getLine();
          try {
              if (driver.getEqu($2) <= 0) {
                  equif = false;
              }
          } catch (sb::MapException &e) {
              driver.printError(nLine, $2,
                                "IF para rótulo EQU não declarado.",
                                sb::errorType::warning);
          }
    }
    ;

label
    : NAME COLON {
          $$ = $1;
      }
    ;

end_line
    : ENDL end_line
    | ENDL
    ;

%%

void sb::PreParser::error(const location_type &l, const std::string &errMsg) {
    UNUSED_VAR l;
    std::cerr << "Erro na linha " << preScanner.getLine() + 1 << ": " 
              << errMsg << std::endl;
}

