#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <map>

#include "PreScanner.hpp"
#include "PreParser.hxx"

#define DEBUG false

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
        purple = 5
    };

    class Driver{
        public:
            Driver(std::string src);
            virtual ~Driver() {};
            void preProcess    (std::istream &srcStream, std::string dst);
            void macroProcess  (std::istream &srcStream, std::string dst);
            void onePassProcess(std::istream &srcStream, std::string dst);

            friend PreParser;
        private:
            bool hasSubstr(int nLine, std::string substr);
            void printError(int nLine, std::string begin,
                            std::string msg, errorType type);
            void writePreOutput(std::string dst);
            void insertEqu(std::string label, int value);
            void insertLine(int nLine, std::string line);
            void deleteLine(int nLine);
            int getEqu(std::string label);

            std::string src;
            std::map<std::string, int> equMap;
            std::map<int, std::string> preMap;
    };
}

#endif

