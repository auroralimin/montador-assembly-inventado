#ifndef SB_ERROR_HPP
#define SB_ERROR_HPP

#include <string>

namespace sb {
    /**
     * @enum sp::errorType
     * @brief Enum para os tipos de erro a serem mostrados
     */
    enum errorType {
        lexical,
        sintatic,
        semantic,
        warning
    };
 
    /**
     * @brief Classe responsável pelo tratamento e saída de erros
     * Essa classe possui funções para impressão de erros e guarda se
     * algum erro já foi detectado no código-fonte
     */
    class Error {
        public:
            /**
             * @brief Construtor da classe
             *
             * @param src é um std::string contendo o nome do arquivo de entrada
             */
            Error(std::string src);

            /**
             * @brief Imprime um erro inspirado na formatação do clang++
             * 
             * @param nLine é um int contendo o número da linha com o erro
             * @param begin é um std::string contendo onde na linha o erro\
             *        começou
             * @param msg é um std::string contendo o corpo da mensagem de erro
             * @para type é um sb::errorType contendo o tipo do erro
             */
            void printError(int nLine, std::string begin,
                            std::string msg, errorType type);

            /**
             * @brief Gera uma mensagem de erro para quantidade de operandos\
             *        inválida
             *
             * @param name é um std::string contendo o nome da instrução
             * @param n1 é um int contendo o número de operandos esperado
             * @param n2 é um int contendo o número de operandos obtido
             *
             * @retval eMsg < em todos os casos retorna a mensagem gerada
             */
            std::string instError(std::string name, int n1, int n2);
 
            /**
             * @brief Seta a flag de erros indicando que houve erro(s)
             */
            void hasError();

            /**
             * @brief Pega a flag que indica se houverão erros na montagem
             *
             * @retval true  < caso haja um ou mais erros
             * @retval false > caso não haja nenhum erro
             */
            bool getErrorFlag();
 
            /**
             * @brief Checa se uma substring esta contida em uma linha do código
             *
             * @param nLine é o int com o número da linha do código-fonte
             * @param substr é um std::string com a substring procurada
             *
             * @retval true  < caso tenha encontrado a substring
             * @retval false < caso não tenha encontrado a substring
             */
            bool hasSubstr(int nLine, std::string substr);

        private:
            std::string src; /**< nome do arquivo fonte */
            bool errorFlag; /**< flag que indica se um erro ocorreu */
    };
}

#endif
