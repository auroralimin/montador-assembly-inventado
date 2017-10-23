#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

#include "OutFormat.hpp"
#include "MapException.hpp"

sb::Driver::Driver(std::string src) : src(src) {}

void sb::Driver::onePassProcess(std::istream &srcStream, std::string dst) {
    Error *error = new Error(src);
    sb::Scanner *scanner = new sb::Scanner(&srcStream);
    sb::Parser *parser = new sb::Parser(*scanner, *this, error);

    addr = 0;
    text = data = -1;
    cSec = sb::sec::none;
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
    solveRef(error);
    if (!error->getErrorFlag()) writeBin(dst);
}

void sb::Driver::writeBin(std::string dst) {
    std::ofstream out;
    out.open(dst);
    for (auto n : assembly) {
        out << n.first << " ";
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

void sb::Driver::assembler(int value, int nLine) {
    assembly.push_back(std::make_pair(value, nLine));
    addr++;
}

void sb::Driver::solveRef(Error *error) {
    for (auto ref : refMap) {
        std::map<std::string, std::tuple<int, int, bool> >::iterator it;
        it = labelMap.find(ref.first);
        if (it != labelMap.end()) {
            for (auto n : ref.second) {
                int aAddr = assembly.at(n).first;
                int nLine = assembly.at(n).second;
                int lAddr = std::get<0>(it->second);

                if (DEBUG) {
                    const std::string cyan = COLOR(sb::color::cyan);
                    std::cout << cyan << "Driver: " << OFF;
                    std::cout << "lAddr " << ref.first << " " << lAddr
                              << std::endl;
                }
                assembly[n] = std::make_pair(lAddr + aAddr, nLine);

                int pAddr = assembly[n - 1].first;
                int pLine = assembly[n - 1].second;
                if (((pAddr > 4) && (pAddr < 9)) &&
                    ((lAddr < text) || ((text < data) && (lAddr >= data)))) {
                    error->printError(pLine, ref.first,
                                      "Pulo para seção inválida: \""
                                      + ref.first + "\".",
                                      sb::errorType::semantic);
                    error->hasError();
                } else if (std::get<2>(it->second)) {
                    if (pAddr == 9) { 
                        error->printError(nLine + 1, ref.first,
                                         "Modificação de constante: \""
                                          + ref.first + "\".",
                                          sb::errorType::semantic);
                        error->hasError();
                    } else if ((pAddr == 11) || (pAddr == 12)) { 
                        error->printError(nLine, ref.first,
                                         "Modificação de constante: \""
                                          + ref.first + "\".",
                                          sb::errorType::semantic);
                        error->hasError();
                    } else if ((pAddr == 4) && (assembly[lAddr].first == 0)) {
                        error->printError(nLine, ref.first,
                                         "Divisão por zero/inválido: \""
                                          + ref.first + "\".",
                                          sb::errorType::semantic);
                        error->hasError();
                    }
                }
            }
        } else {
            for (auto n : ref.second) {
                int nLine = assembly[n].second;
                error->printError(nLine, ref.first,
                                  "Declaração/Rótulo ausente: \""
                                  + ref.first + "\".", sb::errorType::semantic);

                int pAddr = assembly[n - 1].first;
                int pLine = assembly[n - 1].second;
                if ((pAddr > 4) && (pAddr < 9)) {
                    error->printError(pLine, ref.first,
                                      "Pulo para rótulo inválido: \""
                                      + ref.first + "\".",
                                      sb::errorType::semantic);
                }
            }
            error->hasError();
        }
    }
}

void sb::Driver::dataSection() {
    data = addr;
}

void sb::Driver::textSection() {
    text = addr;
}

void sb::Driver::setSection(sb::sec s) {
    cSec = s;
}

int sb::Driver::getSection() {
    return cSec;
}

int sb::Driver::insertLabel(std::string label, int dec, int nLine, bool c) {
    if (DEBUG) {
        const std::string cyan = COLOR(sb::color::cyan);
        std::cout << cyan << "Driver: " << OFF;
        std::cout << "Insere Label: " << label << " " << addr-dec << std::endl;
    }
    if (labelMap.find(label) != labelMap.end()) {
        int oldLine = std::get<1>(labelMap.at(label));
        labelMap[label] = std::make_tuple(addr - dec, nLine, c);
        return oldLine;
    }
    
    labelMap[label] = std::make_tuple(addr - dec, nLine, c);
    return -1;
}

