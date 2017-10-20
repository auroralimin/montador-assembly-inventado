#include "Error.hpp"

#include <fstream>
#include <iostream>

#include "OutFormat.hpp"

sb::Error::Error(std::string src) : src(src), errorFlag(false) {}

void sb::Error::printError(int nLine, std::string begin, std::string msg,
                            sb::errorType type) {
    const std::string red     = COLOR(sb::color::red);
    const std::string green   = COLOR(sb::color::green);
    const std::string magenta = COLOR(sb::color::magenta);

    std::ifstream f(src);
    std::string line;
    
    std::size_t col;
    if (nLine > 0) {
        for (int i = 1; i <= nLine; i++) std::getline(f, line);
        col = (begin == "") ? 0 : line.find(begin);
    } else {
        col = -1;
    }


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

    if (nLine > 0) {
        std::cout << line << std::endl << green;
        for (unsigned long i = 0; i < col; i++)
            std::cout << "~";
        std::cout << "^" << std::endl << OFF;
    }
}

std::string sb::Error::instError(std::string name, int n1, int n2) {
    return ("Instrução " + name + " com quantidade de operandos inválida:" \
            " Espera-se " + std::to_string(n1) + \
            ", obteve-se " + std::to_string(n2) + ".");
}

void sb::Error::hasError() {
    errorFlag = true;
}

bool sb::Error::getErrorFlag() {
    return errorFlag;
}

