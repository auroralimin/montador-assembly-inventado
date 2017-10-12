#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <map>

#include "PreScanner.hpp"
#include "PreParser.hxx"

namespace sb{
    class Driver{
        public:
            Driver() = default;
            virtual ~Driver() {};
            void preProcess    (std::istream &srcStream, std::string dst);
            void macroProcess  (std::istream &srcStream, std::string dst);
            void onePassProcess(std::istream &srcStream, std::string dst);

            friend PreParser;
        private:
            void writePreOutput(std::string dst);
            void insertEqu(std::string label, int value);
            void insertLine(int nLine, std::string line);
            void deleteLine(int nLine);
            int getEqu(std::string label);

            std::map<std::string, int> equMap;
            std::map<int, std::string> preMap;
    };
}

#endif

