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
            void preProcess(const char *const filename);
            void macroProcess(const char *const filename);
            void onePassProcess(const char *const filename);

            friend PreParser;
        private:
            void preParse(std::istream &stream);
            void insertEqu(std::string label, int value);
            void insertLine(int nLine, std::string line);
            int getEqu(std::string label, int nLine);
            void deleteLine(int nLine);

            std::map<std::string, int> equMap;
            std::map<int, std::string> preMap;
    };
}

#endif

