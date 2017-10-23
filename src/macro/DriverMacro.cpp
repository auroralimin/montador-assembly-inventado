#include "DriverMacro.hpp"

#include <cctype>
#include <fstream>
#include <iostream>

#include "MapException.hpp"

#define UNUSED_VAR (void)

#define BOLD      "\e[1m"
#define OFF       "\e[0m"
#define COLOR(id) "\033[1;3" + std::to_string(id) + "m"

mac::Driver::Driver(std::string src) : src(src) {}

void mac::Driver::macroProcess(std::istream &srcStream, std::string dst) {
    
    mac::MacroScanner *macroScanner = new mac::MacroScanner(&srcStream);
    mac::MacroParser *macroParser = new mac::MacroParser(*macroScanner, *this);
    
    const int accept(0);
    if (macroParser->parse() != accept) {
        std::cerr << "Erro imprevisto no processamento de macros." << std::endl;
        exit(EXIT_FAILURE);
    }
    
    writeMacroOutput(dst);
    
    return;
}

void mac::Driver::onePassProcess(std::istream &srcStream, std::string dst) {
    // cria arquivo intermediário
    std::ofstream file;
    file.open("mont_intermediario.txt");
    file << srcStream.rdbuf();
    file.close();
    
    // chama o programa que abre as macros
    system((std::string("./src/montador/mont_exec ") + dst).c_str());
    
    return;
}

bool mac::Driver::hasSubstr(int nLine, std::string substr) {
    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    return (line.find(substr) != std::string::npos);
}

void mac::Driver::printError(int nLine, std::string begin, std::string msg,
                            mac::errorType type) {
    const std::string red    = COLOR(mac::color::red);
    const std::string green  = COLOR(mac::color::green);
    const std::string purple = COLOR(mac::color::purple);

    std::ifstream f(src);
    std::string line;
    for (int i = 1; i <= nLine; i++) std::getline(f, line);

    std::size_t col = line.find(begin);

    std::cout << BOLD << src << ":" << nLine << ":" << col + 1 << ":" << OFF;
    switch (type) {
        case mac::errorType::lexical:
            std::cout << red << " Erro léxico: " << OFF;
            break;
        case mac::errorType::sintatic:
            std::cout << red << " Erro sintático: " << OFF;
            break;
        case mac::errorType::semantic:
            std::cout << red << " Erro semântico: " << OFF;
            break;
        case mac::errorType::warning:
            std::cout << purple << " Aviso: " << OFF;
            break;
    }
    std::cout << BOLD << msg << OFF << std::endl;

    std::cout << line << std::endl << green;
    for (unsigned long i = 0; i < col; i++)
        std::cout << "~";
    std::cout << "^" << std::endl << OFF;
}

void mac::Driver::writeMacroOutput(std::string dst) {
    std::ofstream output;
    output.open(dst);
    for (auto line : wmacMap) {
            output << line.second << std::endl;
    }
    output.close();
}

void mac::Driver::insertMac(std::string label, std::string value) {
    macMap[label] = value;
}

void mac::Driver::insertLine(int nLine, std::string line) {
    wmacMap[nLine] = line;
}

void mac::Driver::deleteLine(int nLine) {
    std::map<int, std::string>::iterator it = wmacMap.find(nLine);

    if (it == wmacMap.end()) return;
    wmacMap.erase(it);
}

std::string mac::Driver::getMac(std::string label) {
    std::map<std::string, std::string>::iterator it = macMap.find(label);

    if (it == macMap.end()) {
        MapException e;
        throw e;
    }

    return it->second;
}

