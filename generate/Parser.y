%skeleton "lalr1.cc"
%require  "3.0"
%debug
%defines
%define api.namespace {sb}
%define parser_class_name {Parser}
%define api.value.type variant

%code requires {
     namespace sb {
        class Driver;
        class Scanner;
    }
}

%parse-param {Scanner &scanner}
%parse-param {Driver &driver}

%code{
    #include "Driver.hpp"
   
    #include <exception>

    #include "MapException.hpp"

    #undef yylex
    #define yylex scanner.yylex

    #define UNUSED_VAR (void)

    bool isSpace = false;
}

/******************************************************************************/
/*                                 TOKENS                                     */
/*----------------------------------------------------------------------------*/
%token               ADD
%token               SUB
%token               MULT
%token               DIV
%token               JMP
%token               JMPN
%token               JMPP
%token               JMPZ
%token               COPY
%token               LOAD
%token               STORE
%token               INPUT
%token               OUTPUT
%token               STOP

%token               SECTION
%token               SPACE
%token               CONST

%token <std::string> LABEL
%token <std::string> INVALID
%token <std::string> NAME
%token <int>         NUM

%token               ENDL
%token               COMMA
%token               END 0

/******************************************************************************/
/*                                  TYPES                                     */
/*----------------------------------------------------------------------------*/
%type <int>         command
%type <int>         instruction
%type <int>         directive
%type <int>         inst_dir
%type <std::string> name

%locations

%%

one_pass
    : line     one_pass
    | line
    | end_line one_pass
    | end_line
    ;

line
    : LABEL end_line {
          driver.insertLabel($1, 0);
      }
    | LABEL command end_line {
          driver.insertLabel($1, $2);
      }
    | command end_line 
    ;

command
    : instruction {
          $$ = $1;
      }
    | directive {
          $$ = $1;
      }
    ;
   
instruction
    : ADD name {
          $$ = 2;
          driver.assembler(1);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | SUB name {
          $$ = 2;
          driver.assembler(2);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | MULT name {
          $$ = 2;
          driver.assembler(3);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | DIV name {
          $$ = 2;
          driver.assembler(4);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | JMP name {
          $$ = 2;
          driver.assembler(5);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | JMPN name {
          $$ = 2;
          driver.assembler(6);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | JMPP name {
          $$ = 2;
          driver.assembler(7);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | JMPZ name {
          $$ = 2;
          driver.assembler(8);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | COPY name COMMA name {
          $$ = 3;
          driver.assembler(9);
          driver.insertRef($2);
          driver.assembler(-1);
          driver.insertRef($4);
          driver.assembler(-1);
      }
    | LOAD name {
          $$ = 2;
          driver.assembler(10);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | STORE name {
          $$ = 2;
          driver.assembler(11);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | INPUT name {
          $$ = 2;
          driver.assembler(12);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | OUTPUT name {
          $$ = 2;
          driver.assembler(13);
          driver.insertRef($2);
          driver.assembler(-1);
      }
    | STOP {
          $$ = 1;
          driver.assembler(14);
      }
    | inst_dir
    ;

directive
    : SECTION name {
          $$ = 0;
      }
    | SPACE {
          $$ = 1;
          driver.assembler(0);
      }
    | SPACE NUM {
          $$ = $2;
          for (int i = 0; i < $2; i++) driver.assembler(0);
      }
    | CONST NUM {
          $$ = 1;
          driver.assembler($2);
      }
    | inst_dir
    ;

inst_dir
    : name inst_dir {
          $$ = 1 + $2;
      }
    | name {
          $$ = 1;
      }
    ;

name
    : NAME {
          $$ = $1;
      }
    | INVALID {
          $$ = $1;
          int nLine = scanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          driver.printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            sb::errorType::lexical);
      }
    ;

end_line
    : ENDL end_line
    | ENDL
    ;

%%

void sb::Parser::error(const location_type &l, const std::string &errMsg) {
    UNUSED_VAR l;
    std::cerr << "Erro na linha " << scanner.getLine() + 1 << ": " 
              << errMsg << std::endl;
}

