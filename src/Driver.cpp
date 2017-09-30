#include "Driver.hpp"

#include <iostream>

Driver::Driver(std::string flag, std::string src, std::string dst) {
    this->flag = flag;
    this->src = src;
    this->dst = dst;
}

void Driver::preProcess() {
    std::cout << "-p" << std::endl;
}

void Driver::macroProcess() {
    std::cout << "-m" << std::endl;
}

void Driver::onePassProcess() {
    std::cout << "-o" << std::endl;
}

