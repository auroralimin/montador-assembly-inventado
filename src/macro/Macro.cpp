#include <string>
#include <iostream>
#include <fstream>

#include "DriverMacro.hpp"

int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "É necessário especificar: "
                     "<arquivo de entrada> <arquivo de saída> <arquivo original>"
                  << std::endl;
        return EXIT_FAILURE;
    }

    std::string src(argv[1]), dst(argv[2]), org(argv[3]);

    mac::Driver *driver = new mac::Driver(org);
    std::string str(src);
    
    dst = dst.substr(0, dst.find(".")) + ".mcr";
    
    std::ifstream stream(src);
    if (!stream.good()) {
        std::cerr << "Não foi possível abrir o arquivo:" << src << std::endl;
        exit(EXIT_FAILURE);
    }

    if (DEBUG) {
        std::cout << "Macro src = " << src
            << ", Macro dst = " << dst << std::endl;
    }
    driver->macroProcess(stream, dst);


    delete driver;

    return EXIT_SUCCESS;
}

