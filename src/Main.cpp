#include "Driver.hpp"

#include <string>
#include <iostream>

int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "É necessário especificar: "
                     "<argumento> <arquivo de entrada> <arquivo de saída>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string flag(argv[1]);
    sb::Driver driver;

    if (flag == "-p") {
        driver.preProcess(argv[2], argv[3]);
    }
    else if (flag == "-m") {
        driver.macroProcess(argv[2], argv[3]);
    }
    else if (flag == "-o") {
        driver.onePassProcess(argv[2], argv[3]);
    }
    else {
        std::cerr << "Argumento inválido. "
                     "Utilize -p para pré processamento,"
                     "-m para expansão de macros e "
                     "-o para montagem completa." << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

