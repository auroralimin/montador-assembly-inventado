#include <string>
#include <iostream>
#include <fstream>

#include "DriverMacro.hpp"

enum PType {
    mcr,
    o
};

std::string process(mac::Driver *driver, const char *src,
                    std::string dst, PType pType);
void checkStream(std::string srcFile, std::ifstream &stream);
std::string createOutName(std::string dst, std::string ext);

int main(int argc, char **argv) {
    if (argc < 3) {
        std::cerr << "É necessário especificar: "
                     "<arquivo de saída> <argumento>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string dst(argv[1]), flag(argv[2]);

    mac::Driver *driver = new mac::Driver(argv[2]);
    if (flag == "0") {
        process(driver, "macro_intermediario.txt", dst, PType::mcr);
    }
    else if (flag == "1") {
        std::string mcr = process(driver, "macro_intermediario.txt", dst, PType::mcr);
        process(driver, mcr.c_str(), dst, PType::o);
    }
    else {
        delete driver;
        std::cerr << "Erro" << std::endl;
        return EXIT_FAILURE;
    }
    delete driver;

    return EXIT_SUCCESS;
}

std::string process(mac::Driver *driver, const char *src,
                    std::string dst, PType pType) {
    std::string ext[2] = {".mcr", ".o"};
    dst = createOutName(dst, ext[pType]);
    std::ifstream stream(src);
    checkStream(src, stream);

    switch (pType) {
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
    
    //exclui o arquivo intermediario de macro
    system((std::string("rm -f macro_intermediario.txt")).c_str());
    
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

