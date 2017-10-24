#ifndef MAC_MACRO_SCANNER_HPP
#define MAC_MACRO_SCANNER_HPP

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "macro/MacroParser.hxx"
#include "macro/location.hh"


namespace mac{
    /**
     * @brief Classe responisável pelo scanner de macro
     * Essa classe utiliza-se de recursos do Flex (por vezes redefinindo-os)
     * para implementar a análise léxica das macros e as expandir
     */
    class MacroScanner : public yyFlexLexer{
    public:
        using FlexLexer::yylex;
        
        /**
         * @brief Construtor da classe
         *
         * @param src é um std::string contendo o nome do arquivo de entrada
         */
        MacroScanner(std::istream *in) : yyFlexLexer(in) {};
        
        /**
         * @brief Destrutor virtual da classe
         */
        virtual ~MacroScanner() { };
        
        /**
         * @brief Redefinição de yylex
         */
        virtual int yylex(mac::MacroParser::semantic_type * const lval,
                          mac::MacroParser::location_type *location);
        
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
        
        mac::MacroParser::semantic_type *yylval = nullptr;
        /**< salva informações do token */
        int nLine = 0; /**< salva o número atual da linha */
    };
}

#endif

