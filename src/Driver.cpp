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

    std::cout << "Arquivo pré-processado:" << std::endl;
    for (auto line : preMap) {
        std::cout << "    " << line.second << std::endl; 
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

void sb::Driver::insertLine(int nLine, std::string line) {
    preMap[nLine] = line;
}

int sb::Driver::getEqu(std::string label, int nLine) {
    std::map<std::string, int>::iterator it = equMap.find(label);
    
    if (it == equMap.end()) {
        std::cerr << "Erro semantico (linha: "
                  << nLine << ") : IF para rótulo não declarado." << std::endl;
    }

    return it->second;
}

void sb::Driver::deleteLine(int nLine) {
    std::map<int, std::string>::iterator it = preMap.find(nLine);
    
    if (it == preMap.end()) return;
    preMap.erase(it);
}

