#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <cassert>

#define UNUSED_VAR (void)

void sb::Driver::preProcess(const char *const srcFile) {
    assert(srcFile != nullptr);
    std::ifstream stream(srcFile);
    if (!stream.good()) {
        std::cerr << "Arquivo de entrada inválido." << std::endl;
        exit(EXIT_FAILURE);
    }
    preParse(stream);
    return;
}

void sb::Driver::preParse(std::istream &stream) {
    sb::PreScanner *preScanner = new sb::PreScanner(&stream);
    sb::PreParser *preParser = new sb::PreParser(*preScanner, *this);
   
    const int accept(0);
    if (preParser->parse() != accept) {
        std::cerr << "Erro imprevisto no pré-processamento." << std::endl;
        exit(EXIT_FAILURE);
    }

    std::cout << std::endl;
    std::cout << "EQU map:" << std::endl;
    for (auto equ : equMap) {
        std::cout << equ.first << ": " << equ.second << "." << std::endl; 
    }
}

void sb::Driver::macroProcess(const char *const srcFile) {
    UNUSED_VAR srcFile;
    //TODO: Implementar pre-processamento de macro
}

void sb::Driver::onePassProcess(const char *const srcFile) {
    UNUSED_VAR srcFile;
    //TODO: Implementar o processamento em um passo
}

void sb::Driver::insertEqu(std::string label, int value) {
    equMap[label] = value;
}

