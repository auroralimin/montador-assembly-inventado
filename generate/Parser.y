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
        class Error;
    }
}

%parse-param {Scanner &scanner}
%parse-param {Driver &driver}
%parse-param {Error *mError}

%code{
    #include "Driver.hpp"
    #include "Error.hpp"
   
    #include <exception>
    #include <utility>

    #include "MapException.hpp"

    #undef yylex
    #define yylex scanner.yylex

    #define UNUSED_VAR (void)
    #define N_OP(name, n1, n2)\
 
    const int args[14] = {1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 0};
    const std::string instructions[14] = {"ADD", "SUB", "MULT", "DIV",
                                          "JMP", "JMPN", "JMPP", "JMPZ",
                                          "COPY", "LOAD", "STORE",
                                          "INPUT", "OUTPUT", "STOP"};
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

%token               TEXT
%token               DATA
%token               ENDL
%token               COMMA
%token               END 0

/******************************************************************************/
/*                                  TYPES                                     */
/*----------------------------------------------------------------------------*/
%type <int>                          command
%type <int>                          instruction
%type <int>                          inst_name
%type <int>                          directive
%type <std::pair<int, std::string> > inst_dir
%type <std::string>                  double_label
%type <std::string>                  name
%type <std::string>                  names

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
    | double_label end_line {
          mError->printError(scanner.getLine(), "", 
                             "Dois rótulos na mesma linha: \"" + $1 + "\".",
                             sb::errorType::sintatic);
          mError->hasError();
      }
    | error end_line {
        mError->printError(scanner.getLine() - 1, "", "Linha inválida.",
                           sb::errorType::sintatic);
        mError->hasError();
    }
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
    : inst_name {
          int nArgs = args[$1-1];
          $$ = 1;
          if (nArgs == 0) {
              driver.assembler($1);
          } else {
              mError->printError(scanner.getLine(), "", 
                                 mError->instError(instructions[$1-1],nArgs,0),
                                 sb::errorType::sintatic);
              mError->hasError();
          }
      }
    | inst_name name {
          int nArgs = args[$1-1];
          $$ = 2;
          if (nArgs == 1) {
              driver.assembler($1);
              driver.insertRef($2);
              driver.assembler(-1);
          } else {
              mError->printError(scanner.getLine(), $2, 
                                 mError->instError(instructions[$1-1],nArgs,1),
                                 sb::errorType::sintatic);
              mError->hasError();
          }
      }
    | COPY name COMMA name {
          $$ = 3;
          driver.assembler(9);
          driver.insertRef($2);
          driver.assembler(-1);
          driver.insertRef($4);
          driver.assembler(-1);
      }
    | inst_name NUM {
          std::string eMsg = "Tipo de argumento inválido: \"" +
                             std::to_string($2) + "\" não é um rótulo.";
          mError->printError(scanner.getLine(), std::to_string($2),
                             eMsg, sb::errorType::sintatic);
          mError->hasError();

      }
    | inst_name inst_dir {
          int nArgs = args[$1-1];
          std::string str = $2.second;
          str = str.substr(0, str.find(" "));
          std::string eMsg = mError->instError(instructions[$1 - 1],
                                               nArgs, $2.first);
          mError->printError(scanner.getLine(), str, 
                             eMsg,sb::errorType::sintatic);
          mError->hasError();
      }
    | inst_dir {
          std::string str = $1.second;
          std::string inst = str.substr(0, str.find(" "));
          mError->printError(scanner.getLine(), inst,
                             "Instrução/Diretiva inválida: \"" + inst + "\".",
                             sb::errorType::sintatic);
          mError->hasError();
    }
    ;

inst_name
    : ADD     { $$ = 1;  }
    | SUB     { $$ = 2;  }
    | MULT    { $$ = 3;  }
    | DIV     { $$ = 4;  }
    | JMP     { $$ = 5;  }
    | JMPN    { $$ = 6;  }
    | JMPP    { $$ = 7;  }
    | JMPZ    { $$ = 8;  }
    | LOAD    { $$ = 10; }
    | STORE   { $$ = 11; }
    | INPUT   { $$ = 12; }
    | OUTPUT  { $$ = 13; }
    | STOP    { $$ = 14; }
    ;

directive
    : SECTION TEXT {
          driver.textSection();
          $$ = 0;
      }
    | SECTION DATA {
          driver.dataSection();
          $$ = 0;
      }
    | SECTION inst_dir {
          $$ = 0;
          std::string str = $2.second;
          str = str.substr(0, str.find(" "));
          std::string eMsg = "Tipo de argumento inválido: ";
          std::string eMsg2 = "espera-se \"TEXT\" ou \"DATA\", obteu-se \""
                              + $2.second + "\".";
          mError->printError(scanner.getLine(), str,
                             eMsg + eMsg2, sb::errorType::sintatic);
          mError->hasError();
      }
    | SECTION {
          $$ = 0;
          std::string eMsg;
          eMsg = "Seção inválida: é necessário informar se é TEXT ou DATA.";
          mError->printError(scanner.getLine(), "", eMsg,
                             sb::errorType::sintatic);
          mError->hasError();
      }
    | SPACE {
          $$ = 1;
          driver.assembler(0);
      }
    | SPACE NUM {
          $$ = $2;
          for (int i = 0; i < $2; i++) driver.assembler(0);
      }
    | SPACE names {
          $$ = 0;
          std::string str = $2;
          str = str.substr(0, str.find(" "));
          std::string eMsg = "Tipo de argumento inválido: \"" + $2 +
                             "\" não é um número.";
          mError->printError(scanner.getLine(), str,
                             eMsg, sb::errorType::sintatic);
          mError->hasError();
      }
    | CONST NUM {
          $$ = 1;
          driver.assembler($2);
      }
    | CONST names {
          $$ = 0;
          std::string str = $2;
          str = str.substr(0, str.find(" "));
          std::string eMsg = "Tipo de argumento inválido: \"" + $2 +
                             "\" não é um número.";
          mError->printError(scanner.getLine(), str,
                             eMsg, sb::errorType::sintatic);
          mError->hasError();
      }
    ;

inst_dir
    : name inst_dir { $$ = std::make_pair($2.first + 1, $1 + " " + $2.second); }
    | name { $$ = std::make_pair(1, $1); }
    | COMMA inst_dir { $$ = std::make_pair($2.first + 1, ", " + $2.second); }
    | COMMA { $$ = std::make_pair(1, ","); }
    | NUM inst_dir {
          $$ = std::make_pair($2.first + 1,
                              std::to_string($1) + ", " + $2.second);
      }
    | NUM { $$ = std::make_pair(1, std::to_string($1)); }
    ;

double_label
    : LABEL LABEL { $$ = $1 + " " + $2; }
    | inst_dir LABEL LABEL { $$ = $2 + " " + $3; }
    | LABEL inst_dir LABEL { $$ = $1 + " " + $3; }
    | LABEL LABEL inst_dir { $$ = $1 + ", " + $2; }
    | inst_dir LABEL inst_dir LABEL { $$ = $2 + ", " + $4; }
    | inst_dir LABEL LABEL inst_dir { $$ = $2 + ", " + $3; }
    | inst_dir LABEL inst_dir LABEL inst_dir {$$ = $2 + ", " + $4; }

name
    : NAME {
          $$ = $1;
      }
    | INVALID {
          $$ = $1;
          int nLine = scanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          mError->printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            sb::errorType::lexical);
          mError->hasError();
      }
    ;

names
    : name names
    | name
    ;

end_line
    : ENDL end_line
    | ENDL
    ;

%%

void sb::Parser::error(const location_type &l, const std::string &errMsg) {
    UNUSED_VAR l;
    UNUSED_VAR errMsg;
}

