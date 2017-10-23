#ifndef SB_DRIVER_HPP
#define SB_DRIVER_HPP

#include <string>
#include <cstddef>
#include <istream>
#include <utility> 
#include <tuple>
#include <map>

#include "Scanner.hpp"
#include "Error.hpp"
#include "Parser.hxx"

/**
 * @brief Define o escopo das implementações relacionadas ao trabalho de sb
 */
namespace sb{
    /**
     * @enum sp::sec
     * @brief Enum para os tipos de seção definidas no código fonte
     */
    enum sec {
        none = 0, /**< Para quando uma seção ainda não foi definida */
        data = 1, /**< Para quando definiu-se a seção data */
        text = 2  /**< Para quando definiu-se a seção text */
    };

    /**
     * @brief  Interface entre o Scanner e o Parser
     * Essa classe visa interfacear as classes Scanner e Parser bem como salvar
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
             * @brief Método que realiza a montagem de um código pré-processado
             *
             * @param srcStream é um std::istream contendo o stream carregado\
             *        com o código pré-processado
             * @param dst é um std::string contendo o nome do arquivo ao qual\
             *        o binátio montado será salvo
             */
            void onePassProcess(std::istream &srcStream, std::string dst);

            /**
             * @brief Injeção de amizade com a classe sb::Parser
             * @relates sb::Parser
             */
            friend Parser;

        private:
            /**
             * @brief Método que salva o binário montado em um arquivo
             *
             * @param dst é um std::string contendo o nome do arquivo ao qual\
             *        o binátio montado será salvo
             */
            void writeBin(std::string dst);

            /**
             * @brief Método que salva uma referência a um rótulo em um mapa
             *
             * @param label é um srd::vector contendo o nome do rótulo que foi\
             *         referenciado
             */
            void insertRef(std::string label);

            /**
             * @brief Método que salva em um vetor o valor numérico relacionado\
             *        a montagem de algum atributo terminal do código-fonte
             *
             * @param value é um int que contém o valor numérico da montagem
             * @param nLine é um int que contém a linha a qual o atributo\
             *        terminal pertencia no código-fonte
             */
            void assembler(int value, int nLine);

            /**
             * @brief Método que resolve as referências de rótulos seguindo a\
             *        lógica de um montador de passagem única
             *
             * @param error é um ponteiro para sb::Error que contém a instância\
             *        que irá mostrar erros casos eles ocorram
             */
            void solveRef(Error *error);

            /**
             * @brief Seta o endereço de início da seção data
             */
            void dataSection();

            /**
             * @brief Seta o endereço de início da seção text
             */
            void textSection();

            /**
             * @brief Seta a seção atual como de algum tipo definido por sb:sec
             *
             * @param s é um sb::sec contendo o tipo de seção
             */
            void setSection(sb::sec s);

            /**
             * @brief Obtem a seção atual
             *
             * @retval 0 > caso seção nula
             * @retval 1 > caso seção data
             * @retval 2 > caso seção text
             */
            int getSection();

            /**
             * @brief Salva o endereço de um rótulo e informações relacionadas
             *
             * @param label é um srd::string contendo o nome do rótulo
             * @param dec é um int contendo um offset negativo para o endereço\
             *        do rótulo
             * @param nLine é um int com o número da linha qua o rótulo está no\
             *        código-fonte
             * @param é um bool que informa se o rótulo é constante ou não
             *
             * @retval -1 > caso seja a primeira definição desse rótulo
             * @retval  n > caso haja redefinição de rótulo, sendo n o número\
             *              da linha onde o rótulo foi previamente definido
             */
            int insertLabel(std::string label, int dec, int nLine, bool c);

            std::string src; /**< nome do arquvo pré-processado do código */
            int addr; /**<  contador de endereços do montador */ 
            int text; /**<  guarda o endereço no qual a seção text começa */
            int data; /**<  guarda o endereço no qual a seção data começa*/
            std::vector<std::pair<int, int> > assembly 
            /**< contém os valores após a montagem*/;
            std::map<std::string, std::tuple<int, int, bool> > labelMap;
            /**< Contém  informações a respeito de rótulos */
            std::map<std::string, std::vector<int> > refMap; /**< mapa de uso */
            int cSec; /**< contém o tipo da seção atual */
    };
}

#endif

