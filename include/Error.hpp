#ifndef SB_ERROR_HPP
#define SB_ERROR_HPP

#include <string>

namespace sb {
    enum errorType {
        lexical,
        sintatic,
        semantic,
        warning
    };
 
    class Error {
        public:
            Error(std::string src);
            void printError(int nLine, std::string begin,
                            std::string msg, errorType type);
            std::string instError(std::string name, int n1, int n2);
            void hasError();
            bool getErrorFlag();

        private:
            std::string src;
            bool errorFlag;
    };
}

#define BOLD      "\e[1m"
#define OFF       "\e[0m"
#define COLOR(id) "\033[1;3" + std::to_string(id) + "m"

#endif
