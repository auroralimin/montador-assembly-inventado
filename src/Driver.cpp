#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

#include "MapException.hpp"

#define UNUSED_VAR (void)

void sb::Driver::preProcess(std::istream &srcStream,
                            std::string src, std::string dst) {
    this->src = src;
    sb::PreScanner *preScanner = new sb::PreScanner(&srcStream);
    sb::PreParser *preParser = new sb::PreParser(*preScanner, *this);

    const int accept(0);
    if (preParser->parse() != accept) {
        std::cerr << "Erro imprevisto no pré-processamento." << std::endl;
        exit(EXIT_FAILURE);
    }

    writePreOutput(dst);

    return;
}

void sb::Driver::macroProcess(std::istream &srcStream,
                              std::string src, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR src;
    UNUSED_VAR dst;
    //TODO: Implementar pre-processamento de macro
}

void sb::Driver::onePassProcess(std::istream &srcStream,
                                std::string src, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR src;
    UNUSED_VAR dst;
    //TODO: Implementar o processamento em um passo
}

void sb::Driver::printError(int nLine, std::string begin, std::string msg,
                            sb::errorType type) {
    //TODO: Printar a linha corretamente
    const std::string bold   ("\e[1m");
    const std::string red    ("\033[1;31m");
    const std::string green  ("\033[1;32m");
    const std::string purple ("\033[1;35m");
    const std::string off    ("\e[0m");

    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    std::size_t col = line.find(begin);

    std::cout << bold << src << ":" << nLine << ":" << col + 1 << ":" << off;
    switch (type) {
        case sb::errorType::lexical:
            std::cout << red << " Erro léxico: " << off;
            break;
        case sb::errorType::sintatic:
            std::cout << red << " Erro sintático: " << off;
            break;
        case sb::errorType::semantic:
            std::cout << red << " Erro semântico: " << off;
            break;
        case sb::errorType::warning:
            std::cout << purple << " Aviso: " << off;
            break;
    }
    std::cout << bold << msg << off << std::endl;

    std::cout << line << std::endl << green;
    for (unsigned long i = 0; i < col; i++)
        std::cout << "~";
    std::cout << "^" << std::endl << off;
}

void sb::Driver::writePreOutput(std::string dst) {
    std::ofstream output;
    output.open(dst);
    for (auto line : preMap) {
        output << line.second << std::endl;
    }
    output.close();
}

void sb::Driver::insertEqu(std::string label, int value) {
    equMap[label] = value;
}

void sb::Driver::insertLine(int nLine, std::string line) {
    preMap[nLine] = line;
}

void sb::Driver::deleteLine(int nLine) {
    std::map<int, std::string>::iterator it = preMap.find(nLine);

    if (it == preMap.end()) return;
    preMap.erase(it);
}

int sb::Driver::getEqu(std::string label) {
    std::map<std::string, int>::iterator it = equMap.find(label);

    if (it == equMap.end()) {
        MapException e;
        throw e;
    }

    return it->second;
}

