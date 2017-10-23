#ifndef SB_PRE_SCANNER_HPP
#define SB_PRE_SCANNER_HPP

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "Parser.hxx"
#include "location.hh"

namespace sb {
    /**
     * @brief Classe responisável pelo scanner do montador
     * Essa classe utiliza-se de recursos do Flex (por vezes redefinindo-os)
     * para implementar a análise léxica do montador
     */
    class Scanner : public yyFlexLexer{
        public:
            using FlexLexer::yylex;

            /**
             * @brief Construtor da classe
             *
             * @param src é um std::string contendo o nome do arquivo de entrada
             */
            Scanner(std::istream *in) : yyFlexLexer(in) {};

            /**
             * @brief Destrutor virtual da classe
             */
            virtual ~Scanner() {};

            /**
             * @brief Redefinição de yylex
             */
            virtual int yylex(sb::Parser::semantic_type * const lval,
                              sb::Parser::location_type *location);

            /**
             * @brief Fornece a linha que está sendo analisada pelo scanner
             *
             * @retval line < em todos os casos retorna um inteiro com o número\
             *                da linha sendo analizada
             */
            int getLine();

        private:
            /**
             *
             * @brief Processa o um nome inválido
             *
             * @retval token::LABEL  < caso seja um rótulo inválido
             * @retval token::INVALID < caso seja um nome inválido
             */
            int processInvalidToken();

            sb::Parser::semantic_type *yylval = nullptr;
            /**< salva informações do token */
            int nLine = 0; /**< salva o número atual da linha */
    };
}

#endif

