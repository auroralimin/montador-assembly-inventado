#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <utility> 
#include <map>

#include "Scanner.hpp"
#include "Parser.hxx"

namespace sb{
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
            void writeBin(std::string dst);
            void insertRef(std::string label);
            void insertLabel(std::string label, int dec);
            void assembler(int value);
            void solveRef();
            void dataSection();
            void textSection();

            std::string src;
            int addr, text, data;
            std::vector<int> assembly;
            std::map<std::string, int> labelMap;
            std::map<std::string, std::vector<int> > refMap;
    };
}

#endif

