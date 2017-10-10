#include <string>
#include <iostream>
#include <fstream>

#include "Driver.hpp"

enum PType {pre, mcr, o};

std::string process(const char *src, std::string dst, const PType pType);
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
        std::cerr << "Arquivo de entrada deve ser do tipo asm." << std::endl;
        exit(EXIT_FAILURE);
    }


    if (flag == "-p") {
        process(argv[2], dst, PType::pre);
    }
    else if (flag == "-m") {
        std::string pre = process(argv[2], dst, PType::pre);
        process(pre.c_str(), dst, PType::mcr);
    }
    else if (flag == "-o") {
        std::string pre = process(argv[2], dst, PType::pre);
        std::string mcr = process(pre.c_str(), dst, PType::mcr);
        process(mcr.c_str(), dst, PType::o);
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

std::string process(const char *src, std::string dst, const PType pType) {
    sb::Driver driver;
    std::string ext[3] = {".pre", ".mcr", ".o"};
    dst = createOutName(dst, ext[pType]);
    std::ifstream stream(src);
    checkStream(src, stream);

    switch (pType) {
        case pre:
            driver.preProcess(stream, dst);
            break;
        case mcr:
            std::cout << "Macro src = " << src
                      << ", Macro dst = " << dst << std::endl;
            driver.macroProcess(stream, dst);
            break;
        case o:
            std::cout << "OnePass src = " << src
                      << ", OnePass dst = " << dst << std::endl;
            driver.onePassProcess(stream, dst);
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
    const int preLen = ext.length();
    if (dst.compare(dst.length() - preLen, preLen, ext)) dst = dst + ext;
    return dst;
}

