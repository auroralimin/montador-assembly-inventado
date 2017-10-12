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
}

%token               COLON
%token               COMMA
%token <std::string> NAME
%token <int>         EQU_VAL
%token <std::string> EQU_IF
%token               ENDL
%token               END 0

%type <std::string> name
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
    | end_line pre_processor
    | end_line
    ;

line
    : label end_line {
          $$ = $1 + ": ";
          driver.insertLine(preScanner.getLine(), $$);
      }
    | label command end_line {
          $$ = $1 + ": " + $2;
          driver.insertLine(preScanner.getLine(), $$);
      }
    | command end_line {
          $$ = $1;
          driver.insertLine(preScanner.getLine(), $$);
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
    : label EQU_VAL end_line {
          driver.insertEqu($1, $2);
      }
    | label end_line EQU_VAL ENDL {
          driver.insertEqu($1, $3);
      }
    ;

if
    : EQU_IF NAME line {
          int nLine = preScanner.getLine();
          try {
              if (driver.getEqu($2) <= 0) {
                  driver.deleteLine(nLine);
              }
          } catch (sb::MapException &e) {
              std::cerr << "Erro semântico na linha " << nLine - 1
                        << ": IF para rótulo EQU não declarado." << std::endl;
          }
      }
    | EQU_IF NAME end_line line {
          int nLine = preScanner.getLine();
          try {
              if (driver.getEqu($2) <= 0) {
                  driver.deleteLine(nLine);
              }
          } catch (sb::MapException &e) {
              std::cerr << "Erro semântico na linha " << nLine - 1
                        << ": IF para rótulo EQU não declarado." << std::endl;
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
    std::cerr << "Erro na linha " << preScanner.getLine() << ": " 
              << errMsg << std::endl;
}

