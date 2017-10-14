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

%token               ENDL
%token               COMMA
%token               IF
%token               EQU
%token               CONST
%token <std::string> LABEL
%token <std::string> INVALID
%token <std::string> NAME
%token <int>         NUM
%token               END 0

%type <std::string> line
%type <std::string> command
%type <std::string> name

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
    : LABEL end_line {
          $$ = $1;
          if (equif) {
              driver.insertLine(preScanner.getLine(), $$);
          } else {
              equif = true;
          }
      }
    | LABEL command end_line {
          $$ = $1 + " " + $2;
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
    | CONST NUM {
          $$ = "CONST " + std::to_string($2);
      }
    | CONST name {
          $$ = "CONST " + $2;
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
          //TODO: Para todos os names, verificar se é uma label de um EQU e
          // se for expandir
          $$ = $1;
      }
    | NAME COMMA {
          $$ = $1 + ",";
      }
    | INVALID {
          $$ = $1;
          int nLine = preScanner.getLine();
          if (!driver.hasSubstr(nLine, $1)) {
              nLine++;
          }
          driver.printError(nLine, $$, "Token inválido: \"" + $$ + "\".",
                            sb::errorType::lexical);
      }
    | INVALID COMMA {
          $$ = $1 + ",";
          int nLine = preScanner.getLine();
          if (!driver.hasSubstr(nLine, $1)) {
              nLine++;
          }
          driver.printError(nLine, $$, "Token inválido: \"" + $$ + "\".",
                            sb::errorType::lexical);
      }
 
    ;

equ
    : LABEL EQU NUM end_line {
          std::string label($1);
          label = label.substr(0, label.length() - 1);
          driver.insertEqu(label, $3);
      }
    | LABEL end_line EQU NUM end_line {
          std::string label($1);
          label = label.substr(0, label.length() - 1);
          driver.insertEqu(label, $4);
      }
    ;

if
    : IF NAME line {
          int nLine = preScanner.getLine();
          try {
              if (driver.getEqu($2) == 0) {
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
              if (driver.getEqu($2) == 0) {
                  equif = false;
              }
          } catch (sb::MapException &e) {
              driver.printError(nLine, $2,
                                "IF para rótulo EQU não declarado.",
                                sb::errorType::warning);
          }
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

