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
%token <std::string> CONST
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
    | CONST { $$ = $1; }
    | CONST NUM {
          $$ = $1 + " " + std::to_string($2);
      }
    | CONST name {
          $$ = $1 + " " + $2;
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
          try {
              $$ = std::to_string(driver.getEqu($1));
          } catch (sb::MapException &e) {
              $$ = $1;
          }

      }
    | NAME COMMA {
          try {
              $$ = std::to_string(driver.getEqu($1)) + ",";
          } catch (sb::MapException &e) {
              $$ = $1 + ",";
          }
      }
    | INVALID {
          int nLine = preScanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          driver.printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            sb::errorType::lexical);
          try {
              $$ = std::to_string(driver.getEqu($1));
          } catch (sb::MapException &e) {
              $$ = $1;
          }
      }
    | INVALID COMMA {
          int nLine = preScanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          driver.printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            sb::errorType::lexical);
          try {
              $$ = std::to_string(driver.getEqu($1)) + ",";
          } catch (sb::MapException &e) {
              $$ = $1 + ",";
          }
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
              equif = driver.getEqu($2) ? true : false;
          } catch (sb::MapException &e) {
              driver.printError(nLine, $2, "IF para rótulo EQU não declarado.",
                                sb::errorType::warning);
          }
      }
    | IF NAME {
          int nLine = preScanner.getLine();
          try {
              equif = driver.getEqu($2) ? true : false;
          } catch (sb::MapException &e) {
              driver.printError(nLine, $2, "IF para rótulo EQU não declarado.",
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

