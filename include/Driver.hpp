#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <utility> 
#include <map>

#include "Scanner.hpp"
#include "Parser.hxx"

#define DEBUG false
#define BOLD      "\e[1m"
#define OFF       "\e[0m"
#define COLOR(id) "\033[1;3" + std::to_string(id) + "m"

namespace sb{
    enum errorType {
        lexical,
        sintatic,
        semantic,
        warning
    };

    enum color {
        red = 1,
        green = 2,
        yellow = 3,
        blue = 4,
        magenta = 5,
        cyan = 6,
    };

    class Driver{
        public:
            Driver(std::string src);
            virtual ~Driver() {};
            void preProcess    (std::istream &srcStream, std::string dst);
            void macroProcess  (std::istream &srcStream, std::string dst);
            void onePassProcess(std::istream &srcStream, std::string dst);

            friend Parser;
        private:
            bool hasSubstr(int nLine, std::string substr);
            void printError(int nLine, std::string begin,
                            std::string msg, errorType type);
            void writeOutput(std::string dst);
            void insertRef(std::string label);
            void insertLabel(std::string label, int dec);
            void assembler(int value);
            void solveRef();

            std::string src;
            int addr;
            std::vector<int> assembly;
            std::map<std::string, int> labelMap;
            std::map<std::string, std::vector<int> > refMap;
    };
}

#endif

