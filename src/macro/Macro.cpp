#include <string>
#include <iostream>
#include <fstream>

#include "DriverMacro.hpp"

enum PType {
    mcr,
    o
};

std::string process(mac::Driver *driver, std::string src,
                    std::string dst, PType pType);

int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "É necessário especificar: "
                     "<arquivo de entrada> <arquivo de saída> <argumento>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string src(argv[1]), dst(argv[2]), flag(argv[3]);

    mac::Driver *driver = new mac::Driver(argv[1]);
    std::string str(argv[1]);
    if (flag == "0") {
        process(driver, str, dst, PType::mcr);
    }
    else if (flag == "1") {
        str = process(driver, str, dst, PType::mcr);
        process(driver, str, dst, PType::o);
    }
    else {
        delete driver;
        std::cerr << "Erro" << std::endl;
        return EXIT_FAILURE;
    }
    delete driver;

    return EXIT_SUCCESS;
}

std::string process(mac::Driver *driver, std::string src,
                    std::string dst, PType pType) {
    std::string ext[2] = {".mcr", ".o"};
    dst = dst.substr(0, dst.find(".")) + ext[pType];
    
    //Coloca endl no final do arquivo de entrada para evitar problemas
    std::ofstream oFile;
    oFile.open(src, std::ios_base::app);
    oFile << std::endl;
    oFile.close();

    std::ifstream stream(src);
    if (!stream.good()) {
        std::cerr << "Não foi possível abrir o arquivo:"
                 << src << "." << std::endl;
        exit(EXIT_FAILURE);
    }

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
            driver->onePassProcess(src, dst);
            break;
    }

    return dst;
}

