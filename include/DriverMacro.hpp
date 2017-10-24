#ifndef MAC_DRIVER_HPP
#define MAC_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <cstdlib>
#include <map>

#include "MacroScanner.hpp"
#include "macro/MacroParser.hxx"

#define DEBUG false

namespace mac{
    
    /**
     * @enum sp::errorType
     * @brief Enum para os tipos de erros definidos
     */
    enum errorType {
        lexical,
        sintatic,
        semantic,
        warning
    };
    
    /**
     * @enum sp::color
     * @brief Enum para as cores dos erros
     */
    enum color {
        red = 1,
        green = 2,
        purple = 5
    };
    
    /**
     * @brief  Interface entre o MacroScanner e o MacroParser
     * Essa classe visa interfacear as classes MacroScanner e MacroParser bem como salvar
     * as informações necessárias durante a montagem.
     */
    class Driver{
    public:
        /**
         * @brief Construtor da classe
         *
         * @param src é um std::string contendo o nome do arquivo de entrada
         */
        Driver(std::string src);
        
        /**
         * @brief Destrutor virtual da classe
         */
        virtual ~Driver() {};
        
        /**
         * @brief Método que realiza a expansão de macros de um código pré-processado
         *
         * @param srcStream é um std::istream contendo o stream carregado\
         *        com o código pré-processado
         * @param dst é um std::string contendo o nome do arquivo ao qual\
         *        o arquivo com as macros expandidas será salvo
         */
        void macroProcess  (std::istream &srcStream, std::string dst);
        
        /**
         * @brief Método que realiza a montagem de um código pré-processado
         *
         * @param src é um std::string contendo o nome do arquivo\
         *        que foi pré-processado e teve as macros expandidas
         * @param dst é um std::string contendo o nome do arquivo ao qual\
         *        o binário montado será salvo
         */
        void onePassProcess(std::string src, std::string dst);
        
        /**
         * @brief Injeção de amizade com a classe mac::Parser
         * @relates mac::Parser
         */
        friend MacroParser;
    private:
        
        /**
         * @brief Método que salva uma macro baseada na sua label
         *
         * @param label é a label que identifica a macro
         * @param value é a string com as linhas da macro
         */
        void insertMac(std::string label, std::string value);
        
        /**
         * @brief Método que pega a macro da memória
         *
         * @param label label que identifica a macro
         */
        std::string getMac(std::string label);
        
        /**
         * @brief Método que printa erro
         *
         * @param nLine numero da linha do erro
         * @param begin onde começou o erro
         * @param msg mensagem do erro
         * @param type tipo do erro
         */
        void printError(int nLine, std::string begin,
                        std::string msg, errorType type);
        
        /**
         * @brief Método que verifica se a linha possui substring
         *
         * @param nLine numero da linha
         * @param substr substring
         */
        bool hasSubstr(int nLine, std::string substr);
        
        /**
         * @brief Método que insere uma linha no arquivo de saída
         *
         * @param nLine numero da linha
         * @param line string que vai ser salva
         */
        void insertLine(int nLine, std::string line);
        
        /**
         * @brief Método que gera o nome e escreve o output
         *
         * @param dst é um std::string contendo o nome do arquivo ao qual\
         *        será salvo
         */
        void writeMacroOutput(std::string dst);
        
        /**
         * @brief Método que deleta uma linha do arquivo
         *
         * @param nLine numero da linha
         */
        void deleteLine(int nLine);
        
        std::string src; /**< nome do arquvo pré-processado do código */
        std::map<std::string, std::string> macMap; /**< map com as macros */
        std::map<int, std::string> wmacMap; /**< map com as macros expandidas */
    };
}

#endif

