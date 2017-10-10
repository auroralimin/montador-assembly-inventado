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
            void preProcess    (const std::string src, std::string dst);
            void macroProcess  (const std::string src, std::string dst);
            void onePassProcess(const std::string src, std::string dst);

            friend PreParser;
        private:
            void preParse(std::istream &stream);
            void insertEqu(std::string label, int value);
            void insertLine(int nLine, std::string line);
            void deleteLine(int nLine);
            int getEqu(std::string label, int nLine);

            std::map<std::string, int> equMap;
            std::map<int, std::string> preMap;
            const int preLen = 4;
    };
}

#endif

