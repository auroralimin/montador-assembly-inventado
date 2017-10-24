#include <string>
#include <iostream>
#include <fstream>

#include "Driver.hpp"

enum PType {
    pre,
    mcr,
    o
};

std::string process(sb::Driver *driver, std::string src,
                    std::string dst, PType pType);

int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "É necessário especificar: "
                     "<argumento> <arquivo de entrada> <arquivo de saída>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string flag(argv[1]), src(argv[2]), dst(argv[3]);
    const int asmLen = 4;

    if (src.compare(src.length() - asmLen, asmLen, ".asm")) {
        std::cerr << "Arquivo de entrada inválido." << std::endl;
        exit(EXIT_FAILURE);
    }

    sb::Driver *driver = new sb::Driver(argv[2]);
    std::string str(argv[2]);
    if (flag == "-p") {
        process(driver, str, dst, PType::pre);
    }
    else if (flag == "-m") {
        str = process(driver, str, dst, PType::pre);
        process(driver, str, dst, PType::mcr);
    }
    else if (flag == "-o") {
         str = process(driver, str, dst, PType::pre);
         str = process(driver, str, dst, PType::mcr);
         process(driver, str, dst, PType::o);
    }
    else {
        delete driver;
        std::cerr << "Argumento inválido. "
                     "Utilize -p para pré processamento,"
                     "-m para expansão de macros e "
                     "-o para montagem completa." << std::endl;
        return EXIT_FAILURE;
    }
    delete driver;

    return EXIT_SUCCESS;
}

std::string process(sb::Driver *driver, std::string src,
                    std::string dst, PType pType) {
    std::string ext[3] = {".pre", ".mcr", ".o"};
    dst = dst.substr(0, dst.find(".")) + ext[pType];
   
    std::ifstream stream(src);
    if (!stream.good()) {
        std::cerr << "Não foi possível abrir o arquivo:"
                 << src << "." << std::endl;
        exit(EXIT_FAILURE);
    }

    switch (pType) {
        case pre:
            driver->preProcess(stream, dst);
            break;
        case mcr:
            if (DEBUG) {
                std::cout << "Macro src = " << src
                          << ", Macro dst = " << dst << std::endl;
            }
            driver->macroProcess(src, dst);
            break;
        case o:
            if (DEBUG) {
                std::cout << "OnePass src = " << src
                          << ", OnePass dst = " << dst << std::endl;
            }
            driver->onePassProcess(src, dst);
            break;
    }

    return dst;
}

