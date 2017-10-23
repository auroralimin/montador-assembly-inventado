#include <exception>

namespace sb {
    /**
     * @brief Exceção para elemento do mapa não encontrado
     */
    class MapException: public std::exception {
        virtual const char* what() const throw() {
            return "Elemento do mapa não encontrado.";
        }
    };
}

