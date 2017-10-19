#ifndef SB_OUT_FORMAT_HPP
#define SB_OUT_FORMAT_HPP

#define DEBUG false
#define BOLD      "\e[1m"
#define OFF       "\e[0m"
#define COLOR(id) "\033[1;3" + std::to_string(id) + "m"

namespace sb {
    enum color {
        red = 1,
        green = 2,
        yellow = 3,
        blue = 4,
        magenta = 5,
        cyan = 6,
    };
}

#endif
