#include "Driver.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

#include "MapException.hpp"

#define UNUSED_VAR (void)

#define BOLD      "\e[1m"
#define OFF       "\e[0m"
#define COLOR(id) "\033[1;3" + std::to_string(id) + "m"

sb::Driver::Driver(std::string src) : src(src) {}

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

void sb::Driver::macroProcess(std::string src, std::string dst) {
    // chama o programa que abre as macros
    system((std::string("./src/macro/macro_exec ") + src + " " + dst + " 0").c_str());
    
    return;
}

void sb::Driver::onePassProcess(std::string src, std::string dst) {
    // chama o programa que abre as macros
    system((std::string("./src/macro/macro_exec ") + src + " " + dst + " 1").c_str());
}

bool sb::Driver::hasSubstr(int nLine, std::string substr) {
    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    return (line.find(substr) != std::string::npos);
}

void sb::Driver::printError(int nLine, std::string begin, std::string msg,
                            sb::errorType type) {
    const std::string red    = COLOR(sb::color::red);
    const std::string green  = COLOR(sb::color::green);
    const std::string purple = COLOR(sb::color::purple);

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
            std::cout << purple << " Aviso: " << OFF;
            break;
    }
    std::cout << BOLD << msg << OFF << std::endl;

    std::cout << line << std::endl << green;
    for (unsigned long i = 0; i < col; i++)
        std::cout << "~";
    std::cout << "^" << std::endl << OFF;
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

