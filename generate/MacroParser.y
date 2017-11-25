%skeleton "lalr1.cc"
%require  "3.0"
%debug
%defines
%define api.namespace {mac}
%define parser_class_name {MacroParser}
%define api.value.type variant

%code requires {
     namespace mac {
	class MacroScanner;
	class Driver;
    }
}

%parse-param {MacroScanner &macroScanner}
%parse-param {Driver &driver}

%code{
    #include "DriverMacro.hpp"
   
    #include <exception>

    #include "MapException.hpp"

    #undef yylex
    #define yylex macroScanner.yylex

    #define UNUSED_VAR (void)

    bool onMacro = false;

    std::string tempMacro = "";
    std::string labelMacro = "";
}

%token               ENDL
%token               COMMA
%token               MACRO
%token               ENDMACRO
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

macro_processor
    : macro    macro_processor
    | macro
    | end_macro macro_processor
    | end_macro
    | line     macro_processor
    | line
    | end_line macro_processor
    | end_line
    ;
line
    :LABEL end_line {
	$$ = $1;
	
	if(onMacro){
		tempMacro.append($$);
		tempMacro.append("\n");
	}else{		

		driver.insertLine(macroScanner.getLine(), $$);
	}

      }
    | LABEL command end_line {
	$$ = $1 + " " + $2;
	if(onMacro){
		tempMacro.append($$);
		tempMacro.append("\n");
	}else{
		driver.insertLine(macroScanner.getLine(), $$);
	}              
      }
    | command end_line {
	$$ = $1;

	if(onMacro){
		tempMacro.append($$);
		tempMacro.append("\n");
	}else{
		try {
			$$ = driver.getMac($$);
			driver.insertLine(macroScanner.getLine(), $$);
		} catch (std::exception &e) {
			$$ = $1;
			driver.insertLine(macroScanner.getLine(), $$);
		}
	}
      }
    ;

command
    : name command {
          $$ = $1 + " " + $2;
      }
    | CONST { $$ = $1; }
    | CONST NUM {
          $$ = $1 + " " + std::to_string($2);
      }
    | CONST name {
          $$ = $1+ " " + $2;
      }
    | name {
          $$ = $1;
      }
    | NUM { $$ = std::to_string($1); }
    ;

name
    : NAME {
          $$ = $1;
      }
    | NAME COMMA {
          $$ = $1 + ",";
      }
    | INVALID {
          int nLine = macroScanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          driver.printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            mac::errorType::lexical);
          $$ = $1;
      }
    | INVALID COMMA {
          int nLine = macroScanner.getLine();
          nLine = driver.hasSubstr(nLine, $1) ? nLine : nLine + 1;
          driver.printError(nLine, $1, "Token inválido: \"" + $1 + "\".",
                            mac::errorType::lexical);
          $$ = $1 + ",";
      }
 
    ;

macro
    : LABEL MACRO {
	std::string label($1);
	label = label.substr(0, label.length() - 1);
	labelMacro = label;
	onMacro = true;
	
      }
    | LABEL end_line MACRO end_line {
	std::string label($1);
	label = label.substr(0, label.length() - 1);
	labelMacro = label;
	onMacro = true;
      }
    ;

end_macro
    : ENDMACRO {
	onMacro = false;
	driver.insertMac(labelMacro, tempMacro);
	labelMacro = "";
	tempMacro = "";
      }
    ;

end_line
    : ENDL end_line
    | ENDL
    ;

%%

void mac::MacroParser::error(const location_type &l, const std::string &errMsg) {
    UNUSED_VAR l;
    std::cerr << "Erro na linha " << macroScanner.getLine() + 1 << ": " 
              << errMsg << std::endl;
}

