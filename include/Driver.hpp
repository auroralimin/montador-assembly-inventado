#ifndef DRIVER_HPP
#define DRIVER_HPP

#include <string>

class Driver {
    public:
        Driver(std::string flag, std::string src, std::string dst);
        void preProcess();
        void macroProcess();
        void onePassProcess();
    private:
        std::string flag, src, dst;
};

#endif

