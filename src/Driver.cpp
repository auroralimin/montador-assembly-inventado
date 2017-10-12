#include "Driver.hpp"

#include <cctype>
#include <fstream>

#include "MapException.hpp"

#define UNUSED_VAR (void)

void sb::Driver::preProcess(std::istream &srcStream, std::string dst) {
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

void sb::Driver::macroProcess(std::istream &srcStream, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR dst;
    //TODO: Implementar pre-processamento de macro
}

void sb::Driver::onePassProcess(std::istream &srcStream, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR dst;
    //TODO: Implementar o processamento em um passo
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

