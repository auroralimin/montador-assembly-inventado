#include "Driver.hpp"

#include <cctype>
#include <fstream>

#define UNUSED_VAR (void)

void sb::Driver::preProcess(const std::string src, std::string dst) {
    std::ifstream stream(src.c_str());
    if (!stream.good()) {
        std::cerr << "Arquivo de entrada inválido." << std::endl;
        exit(EXIT_FAILURE);
    }
    preParse(stream);

    std::ofstream output;
    if (dst.compare(dst.length() - preLen, preLen, ".pre")) dst = dst + ".pre";
    output.open(dst);
    for (auto line : preMap) {
        output << line.second << std::endl; 
    }
    output.close();

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
}

void sb::Driver::macroProcess(const std::string src, std::string dst) {
    UNUSED_VAR src;
    UNUSED_VAR dst;
    //TODO: Implementar pre-processamento de macro
}

void sb::Driver::onePassProcess(const std::string src, std::string dst) {
    UNUSED_VAR src;
    UNUSED_VAR dst;
    //TODO: Implementar o processamento em um passo
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

int sb::Driver::getEqu(std::string label, int nLine) {
    std::map<std::string, int>::iterator it = equMap.find(label);
    
    if (it == equMap.end()) {
        std::cerr << "Erro semantico (linha: "
                  << nLine << ") : IF para rótulo não declarado." << std::endl;
    }

    return it->second;
}

