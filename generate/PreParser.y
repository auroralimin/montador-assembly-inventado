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
%token               EQU_IF
%token               END 0 "end of file"

%locations

%%

pre_processor
    : equ pre_processor {}
    | COLON pre_processor {
        std::cout << "Bison encontrou dois pontos." << std::endl; }
    | NAME pre_processor {
        std::cout << "Bison encontrou um nome: " << $1 << "." << std::endl; }
    | equ {}
    | COLON {
        std::cout << "Bison encontrou dois pontos." << "." << std::endl; }
    | NAME {
        std::cout << "Bison encontrou um nome: " << $1 << "." << std::endl; }
	;

equ
    : NAME COLON EQU_VAL {
        driver.insertEqu($1, $3); }
    ;

%%

void sb::PreParser::error(const location_type &l, const std::string &errMsg) {
   std::cerr << "Erro na linha " << l << ": " << errMsg << std::endl;
}

