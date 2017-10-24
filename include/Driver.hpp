#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <cstdlib>
#include <map>

#include "PreScanner.hpp"
#include "pre/PreParser.hxx"

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
        void macroProcess  (std::string src, std::string dst);
        void onePassProcess(std::string src, std::string dst);
        
        friend PreParser;
    private:
        
        void insertEqu(std::string label, int value);
        int getEqu(std::string label);
        void printError(int nLine, std::string begin,
                        std::string msg, errorType type);
        bool hasSubstr(int nLine, std::string substr);
        void insertLine(int nLine, std::string line);
        
        void writePreOutput(std::string dst);
        void deleteLine(int nLine);
        
        std::string src;
        std::map<std::string, int> equMap;
        std::map<int, std::string> preMap;
    };
}

#endif

