#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <utility> 
#include <map>

#include "Scanner.hpp"
#include "Error.hpp"
#include "Parser.hxx"

namespace sb{
    enum sec {
        none = 0,
        data = 1,
        text = 2
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
            void writeBin(std::string dst);
            void insertRef(std::string label);
            void assembler(int value, int nLine);
            void solveRef(Error *error);
            void dataSection();
            void textSection();
            void setSection(int s);
            int getSection();
            int insertLabel(std::string label, int dec, int nLine);

            std::string src;
            int addr, text, data;
            std::vector<std::pair<int, int> > assembly;
            std::map<std::string, std::pair<int, int> > labelMap;
            std::map<std::string, std::vector<int> > refMap;
            int cSec;
    };
}

#endif

