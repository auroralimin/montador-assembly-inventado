#include <exception>

namespace sb {
    class MapException: public std::exception {
        virtual const char* what() const throw() {
            return "Elemento do mapa não encontrado.";
        }
    };
}

namespace mac {
    class MapException: public std::exception {
        virtual const char* what() const throw() {
            return "Elemento do mapa não encontrado.";
        }
    };
}

