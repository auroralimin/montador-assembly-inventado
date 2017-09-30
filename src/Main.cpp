#include "Driver.hpp"

#include <string>
#include <iostream>

int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "É necessário especificar: "
                     "<argumento> <arquivo de entrada> <arquivo de saída>"
                  << std::endl;
        return 1;
    }

    std::string flag(argv[1]), src(argv[2]), dst(argv[3]);
    Driver driver(flag, src, dst);

    if (flag == "-p") {
        driver.preProcess();
    }
    else if (flag == "-m") {
        driver.macroProcess();
    }
    else if (flag == "-o") {
        driver.onePassProcess();
    }
    else {
        std::cerr << "Argumento inválido. "
                     "Utilize -p para pré processamento,"
                     "-m para expansão de macros e "
                     "-o para montagem completa." << std::endl;
        return 1;
    }

    return 0;
}

