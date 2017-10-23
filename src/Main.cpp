#include <string>
#include <iostream>
#include <fstream>

#include "Driver.hpp"
#include "OutFormat.hpp"

int main(int argc, char **argv) {
    if (argc < 3) {
        std::cerr << "É necessário especificar: "
                     "<arquivo de entrada> <arquivo de saída>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string src(argv[1]), dst(argv[2]);
    sb::Driver *driver = new sb::Driver(src);

    const std::string ext = ".o";
    const int eLen = ext.length(), dLen = dst.length();
    if ((dLen < eLen) || (dst.compare(dLen - eLen, eLen, ext))) dst = dst + ext;

    //Coloca endl no final do arquivo de entrada para evitar problemas
    std::ofstream oFile;
    oFile.open(src, std::ios_base::app);
    oFile << std::endl;
    oFile.close();

    std::ifstream stream(src);
    if (!stream.good()) {
        std::cerr << "Não foi possível abrir o arquivo:" << src
                  << "." << std::endl;
        exit(EXIT_FAILURE);
    }

    if (DEBUG) {
        std::cout << "OnePass src = " << src
            << ", OnePass dst = " << dst << std::endl;
    }
    driver->onePassProcess(stream, dst);

    delete driver;

    return EXIT_SUCCESS;
}

