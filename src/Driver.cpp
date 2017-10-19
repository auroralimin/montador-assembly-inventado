#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

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
    sb::Scanner *scanner = new sb::Scanner(&srcStream);
    sb::Parser *parser = new sb::Parser(*scanner, *this);

    addr = 0;
    const int accept(0);
    if (parser->parse() != accept) {
        std::cerr << "Erro imprevisto na montagem." << std::endl;
        exit(EXIT_FAILURE);
    }

    solveRef();

    std::ofstream out;
    out.open(dst);
    for (auto n : assembly) {
        out << n << " ";
    }
    out << std::endl;
    out.close();
}

bool sb::Driver::hasSubstr(int nLine, std::string substr) {
    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    return (line.find(substr) != std::string::npos);
}

void sb::Driver::printError(int nLine, std::string begin, std::string msg,
                            sb::errorType type) {
    const std::string red     = COLOR(sb::color::red);
    const std::string green   = COLOR(sb::color::green);
    const std::string magenta = COLOR(sb::color::magenta);

    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    std::size_t col = line.find(begin);

    std::cout << BOLD << src << ":" << nLine << ":" << col + 1 << ":" << OFF;
    switch (type) {
        case sb::errorType::lexical:
            std::cout << red << " Erro léxico: " << OFF;
            break;
        case sb::errorType::sintatic:
            std::cout << red << " Erro sintático: " << OFF;
            break;
        case sb::errorType::semantic:
            std::cout << red << " Erro semântico: " << OFF;
            break;
        case sb::errorType::warning:
            std::cout << magenta << " Aviso: " << OFF;
            break;
    }
    std::cout << BOLD << msg << OFF << std::endl;

    std::cout << line << std::endl << green;
    for (unsigned long i = 0; i < col; i++)
        std::cout << "~";
    std::cout << "^" << std::endl << OFF;
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
