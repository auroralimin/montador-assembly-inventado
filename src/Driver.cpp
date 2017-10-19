#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

#include "Error.hpp"
#include "OutFormat.hpp"
#include "MapException.hpp"

#define UNUSED_VAR (void)

sb::Driver::Driver(std::string src) : src(src) {}

void sb::Driver::preProcess(std::istream &srcStream, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR dst;
    //TODO: Integrar o pré-processamento
}

void sb::Driver::macroProcess(std::istream &srcStream, std::string dst) {
    UNUSED_VAR srcStream;
    UNUSED_VAR dst;
    //TODO: Implementar pre-processamento de macro
}

void sb::Driver::onePassProcess(std::istream &srcStream, std::string dst) {
    Error *error = new Error(src);
    sb::Scanner *scanner = new sb::Scanner(&srcStream);
    sb::Parser *parser = new sb::Parser(*scanner, *this, error);

    addr = 0;
    const int accept(0);
    if (parser->parse() != accept) {
        std::cerr << "Erro imprevisto na montagem." << std::endl;
        exit(EXIT_FAILURE);
    }

    solveRef();
    if (!error->getErrorFlag()) writeBin(dst);
}

bool sb::Driver::hasSubstr(int nLine, std::string substr) {
    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    return (line.find(substr) != std::string::npos);
}
void sb::Driver::writeBin(std::string dst) {
    std::ofstream out;
    out.open(dst);
    for (auto n : assembly) {
        out << n << " ";
    }
    out << std::endl;
    out.close();
}


void sb::Driver::insertRef(std::string label) {
    if (DEBUG) {
        const std::string cyan = COLOR(sb::color::cyan);
        std::cout << cyan << "Driver: " << OFF;
        std::cout << "Insere Ref: " << label << " " << addr << std::endl;
    }
    refMap[label].push_back(addr);
}

void sb::Driver::insertLabel(std::string label, int dec) {
    if (DEBUG) {
        const std::string cyan = COLOR(sb::color::cyan);
        std::cout << cyan << "Driver: " << OFF;
        std::cout << "Insere Label: " << label << " " << addr-dec << std::endl;
    }
    labelMap[label] = addr - dec;
}

void sb::Driver::assembler(int value) {
    assembly.push_back(value);
    addr++;
}

void sb::Driver::solveRef() {
    for (auto ref : refMap) {
        std::map<std::string, int>::iterator it = labelMap.find(ref.first);
        if (it != labelMap.end()) {
            for (auto n : ref.second) {
                assembly[n] = it->second;
            }
        }
    }
}

