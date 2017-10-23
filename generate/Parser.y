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
    bool isConst = false;
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
%token               PLUS
%token               END 0

/******************************************************************************/
/*                                  TYPES                                     */
/*----------------------------------------------------------------------------*/
%type <std::pair<int, std::string> > label
%type <int>                          command
%type <int>                          instruction
%type <int>                          section
%type <int>                          inst_name
%type <int>                          directive
%type <std::pair<int, std::string> > inst_dir
%type <std::pair<int, std::string> > addr
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
    : label end_line
    | command end_line 
    | double_label end_line {
          mError->printError(scanner.getLine(), "", 
                             "Dois rótulos na mesma linha: \"" + $1 + "\".",
                             sb::errorType::sintatic);
          mError->hasError();
      }
    ;

label
    : LABEL end_line command{
          $$ = std::make_pair(0, $1); 
          int old = driver.insertLabel($1, $3, scanner.getLine(), isConst);
          isConst = false;
          if (old > 0) {
              std::string eMsg;
              eMsg = "Declaração/Rótulo repetido: aparição anterior de \""
                     + $1 + "\" foi na linha " + std::to_string(old) + ".";
              mError->printError(scanner.getLine(), "", eMsg, 
                                 sb::errorType::semantic);
              mError->hasError();
          }
      }
    | LABEL command {
          $$ = std::make_pair(0, $1); 
          int old = driver.insertLabel($1, $2, scanner.getLine(), isConst);
          isConst = false;
          if (old > 0) {
              std::string eMsg;
              eMsg = "Declaração/Rótulo repetido: aparição anterior de \""
                     + $1 + "\" foi na linha " + std::to_string(old) + ".";
              mError->printError(scanner.getLine(), "", eMsg, 
                                 sb::errorType::semantic);
              mError->hasError();
          }
      }
 
    ;

command
    : instruction {
          if (driver.getSection() == sec::data) {
              std::string eMsg;
              eMsg = "Instrução na seção errada: deveria estar na seção TEXT.";
              mError->printError(scanner.getLine(), "", eMsg,
                                 sb::errorType::semantic);
              mError->hasError();
          }
          $$ = $1;
      }
    | directive {
          if (driver.getSection() == sec::text) {
              std::string eMsg;
              eMsg = "Diretiva na seção errada: deveria estar na seção DATA.";
              mError->printError(scanner.getLine() + 1, "", eMsg,
                                 sb::errorType::semantic);
              mError->hasError();
          }
          $$ = $1;
      }
    | section { $$ = $1; }
    | inst_dir {
          std::string str = $1.second;
          str = str.substr(0, str.find(" "));

          if (driver.getSection() == sec::data) {
              mError->printError(scanner.getLine(), str,
                                 "Diretiva inválida: \"" + str + "\".",
                                 sb::errorType::semantic);
          } else {
              mError->printError(scanner.getLine(), str,
                                 "Instrução inválida: \"" + str + "\".",
                                 sb::errorType::semantic);
          }
          mError->hasError();
    }
    ;
   
instruction
    : inst_name {
          int nArgs = args[$1-1];
          $$ = 1;
          if (nArgs == 0) {
              driver.assembler($1, scanner.getLine());
          } else {
              mError->printError(scanner.getLine(), "", 
                                 mError->instError(instructions[$1-1],nArgs,0),
                                 sb::errorType::sintatic);
              mError->hasError();
          }
      }
    | inst_name addr {
          int nArgs = args[$1-1];
          $$ = 2;
          if (nArgs == 1) {
              int nLine = scanner.getLine();
              driver.assembler($1, nLine);
              driver.insertRef($2.second);
              driver.assembler($2.first, nLine);
          } else {
              mError->printError(scanner.getLine(), $2.second, 
                                 mError->instError(instructions[$1-1],nArgs,1),
                                 sb::errorType::sintatic);
              mError->hasError();
          }
      }
    | COPY addr COMMA addr {
          $$ = 3;
          int nLine = scanner.getLine() - 1;
          driver.assembler(9, nLine);
          driver.insertRef($2.second);
          driver.assembler($2.first, nLine);
          driver.insertRef($4.second);
          driver.assembler($4.first, nLine);
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
    ;

addr
    : name { $$ = std::make_pair(0, $1); }
    | name PLUS NUM { $$ = std::make_pair($3, $1); }
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

section
    : SECTION TEXT {
          driver.textSection();
          driver.setSection(sb::sec::text);
          $$ = 0;
      }
    | SECTION DATA {
          driver.dataSection();
          driver.setSection(sb::sec::data);
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
    ;

directive
    : SPACE {
          $$ = 1;
          driver.assembler(0, scanner.getLine());
      }
    | SPACE NUM {
          $$ = $2;
          for (int i = 0; i < $2; i++) driver.assembler(0, scanner.getLine());
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
          isConst = true;
          driver.assembler($2, scanner.getLine());
      }
    | CONST names {
          $$ = 0;
          isConst = true;
          driver.assembler(-1, scanner.getLine());
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
          nLine = mError->hasSubstr(nLine, $1) ? nLine : nLine + 1;
          mError->printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            sb::errorType::lexical);
          mError->hasError();
      }
    ;

names
    : name names { $$ = $1 + " " + $2; }
    | name { $$ = $1; }
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

