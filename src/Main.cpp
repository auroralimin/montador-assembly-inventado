#include <string>
#include <iostream>
#include <fstream>

#include "Driver.hpp"

enum PType {
    pre,
    mcr,
    o
};

std::string process(sb::Driver *driver, const char *src,
                    std::string dst, PType pType);
void checkStream(std::string srcFile, std::ifstream &stream);
std::string createOutName(std::string dst, std::string ext);

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
    if (flag == "-p") {
        process(driver, argv[2], dst, PType::pre);
    }
    else if (flag == "-m") {
        std::string pre = process(driver, argv[2], dst, PType::pre);
        process(driver, pre.c_str(), dst, PType::mcr);
    }
    else if (flag == "-o") {
        std::string pre = process(driver, argv[2], dst, PType::pre);
        process(driver, pre.c_str(), dst, PType::o);
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

std::string process(sb::Driver *driver, const char *src,
                    std::string dst, PType pType) {
    std::string ext[3] = {".pre", ".mcr", ".o"};
    dst = createOutName(dst, ext[pType]);
    std::ifstream stream(src);
    checkStream(src, stream);

    switch (pType) {
        case pre:
            driver->preProcess(stream, dst);
            break;
        case mcr:
            if (DEBUG) {
                std::cout << "Macro src = " << src
                          << ", Macro dst = " << dst << std::endl;
            }
            driver->macroProcess(stream, dst);
            break;
        case o:
            if (DEBUG) {
                std::cout << "OnePass src = " << src
                          << ", OnePass dst = " << dst << std::endl;
            }
            driver->onePassProcess(stream, dst);
            break;
    }

    return dst;
}

void checkStream(std::string file, std::ifstream &stream) {
    if (!stream.good()) {
        std::cerr << "Não foi possível abrir o arquivo:"
                 << file << "." << std::endl;
        exit(EXIT_FAILURE);
    }
}

std::string createOutName(std::string dst, std::string ext) {
    const int eLen = ext.length(), dLen = dst.length();
    if ((dLen < eLen) || (dst.compare(dLen - eLen, eLen, ext))) dst = dst + ext;
    return dst;
}

