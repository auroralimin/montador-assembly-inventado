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
    text = data = -1;
    const int accept(0);
    if (parser->parse() != accept) {
        std::cerr << "Erro imprevisto na montagem." << std::endl;
        exit(EXIT_FAILURE);
    }
    
    if (text == -1) {
        error->hasError();
        error->printError(0, "", "Seção TEXT faltante.",
                          sb::errorType::semantic);
    }
    solveRef();
    if (!error->getErrorFlag()) writeBin(dst);
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

int sb::Driver::insertLabel(std::string label, int dec, int nLine) {
    if (DEBUG) {
        const std::string cyan = COLOR(sb::color::cyan);
        std::cout << cyan << "Driver: " << OFF;
        std::cout << "Insere Label: " << label << " " << addr-dec << std::endl;
    }
    if (labelMap.find(label) != labelMap.end()) {
        int oldLine = labelMap.at(label).second;
        labelMap[label] = std::make_pair(addr - dec, nLine);
        return oldLine;
    }
    
    labelMap[label] = std::make_pair(addr - dec, nLine);
    return -1;
}

void sb::Driver::assembler(int value) {
    assembly.push_back(value);
    addr++;
}

void sb::Driver::solveRef() {
    for (auto ref : refMap) {
        std::map<std::string, std::pair<int, int> >::iterator it;
        it = labelMap.find(ref.first);
        if (it != labelMap.end()) {
            for (auto n : ref.second) {
                assembly[n] = it->second.first;
            }
        }
    }
}

void sb::Driver::dataSection() {
    data = addr;
}

void sb::Driver::textSection() {
    text = addr;
}

