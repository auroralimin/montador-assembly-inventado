# Assembler

Esse trabalho foi implementado como requisito da disciplina Software Básico da Universidade de Brasília (UnB).
Ele consiste em um Montador do assembly inventado especificado na próxima seção.

Para implementá-lo, foram utilizadas as bibliotecas/utilitários Bison e Flex, responsável pera geração de código dos scanners e parser implementados. Para evitar conflitos da biblioteca, estão sendo gerados executaveis diferentes para cada processo da montagem, todos chamados pelo executavel montador (que é o que deve ser utilizado para testar o projeto, como explicado em seções abaixo.

Vale lembrar que pelo código dos scanners e parser ser gerado, ele não é tão legível quanto o resto das classes implementadas na mão do projeto. Caso deseje ter um entendimento melhor de como os mesmos foram gerados, analise os arquivos .l e .y que constam na pasta generate.

## Assembly inventado
A linguagem de montagem utilizada será a linguagem simbólica hipotética apresentada em sala de aula.
Esta linguagem e formada por um conjunto de apenas 14 instruções.

<table>
  <tr><td colspan="5" align="center">                      <strong>Instruções</strong>                                 </td></tr>
  <tr>
    <td> <strong>Mneumônico</strong> </td>
    <td> <strong>Operandos</strong>  </td>
    <td> <strong>Código</strong>     </td>
    <td> <strong>Tamanho</strong>    </td>
    <td> <strong>Descrição</strong>  </td>
  </tr>
  <tr><td>     ADD    </td><td>     1     </td><td>    1   </td><td>     2    </td><td>      ACC <- ACC + MEM[OP]      </td></tr>
  <tr><td>     SUB    </td><td>     1     </td><td>    2   </td><td>     2    </td><td>      ACC <- ACC - MEM[OP]      </td></tr>
  <tr><td>     MULT   </td><td>     1     </td><td>    3   </td><td>     2    </td><td>      ACC <- ACC * MEM[OP]      </td></tr>
  <tr><td>     DIV    </td><td>     1     </td><td>    4   </td><td>     2    </td><td>      ACC <- ACC / MEM[OP]      </td></tr>
  <tr><td>     JMP    </td><td>     1     </td><td>    5   </td><td>     2    </td><td>             PC <- OP           </td></tr>
  <tr><td>    JMPN    </td><td>     1     </td><td>    6   </td><td>     2    </td><td>       Se ACC < 0, PC <- OP     </td></tr>
  <tr><td>    JMPP    </td><td>     1     </td><td>    7   </td><td>     2    </td><td>       Se ACC > 0, PC <- OP     </td></tr>
  <tr><td>    JMPZ    </td><td>     1     </td><td>    8   </td><td>     2    </td><td>       Se ACC = 0, PC <- OP     </td></tr>
  <tr><td>    COPY    </td><td>     2     </td><td>    9   </td><td>     3    </td><td>      MEM[OP2] <- MEM[OP1]      </td></tr>
  <tr><td>    LOAD    </td><td>     1     </td><td>    10  </td><td>     2    </td><td>         ACC <- MEM[OP]         </td></tr>
  <tr><td>    STORE   </td><td>     1     </td><td>    11  </td><td>     2    </td><td>         MEM[OP] <- ACC         </td></tr>
  <tr><td>    INPUT   </td><td>     1     </td><td>    12  </td><td>     2    </td><td>         MEM[OP] <- STDIN       </td></tr>
  <tr><td>    OUTPUT  </td><td>     1     </td><td>    13  </td><td>     2    </td><td>        STDOUT <- MEM[OP]       </td></tr>
  <tr><td>     STOP   </td><td>     0     </td><td>    14  </td><td>     1    </td><td>       Encerrar execução        </td></tr>
</table>

<table>
  <tr><td colspan="5" align="center">                      <strong>Diretivas</strong>                 </td></tr>
  <tr>
    <td> <strong>Mneumônico</strong> </td>
    <td> <strong>Operandos</strong>  </td>
    <td> <strong>Tamanho</strong>    </td>
    <td> <strong>Descrição</strong>  </td>
  </tr>
  <tr><td>   SECTION  </td><td>     1     </td><td>     0    </td><td>  Marcar inıcio de seção de
                                                                        codigo (TEXT) ou dados (DATA)  </td></tr>
  <tr><td>    SPACE   </td><td>    0/1    </td><td> Variável </td><td>  Reservar 1 ou mais enderecos
                                                                        de memoria nao-inicializada
                                                                        para armazenamento de uma
                                                                        palavra                        </td></tr>
  <tr><td>    CONST   </td><td>     1     </td><td>     1    </td><td>  Reservar memoria para
                                                                        armazenamento de uma constante
                                                                        inteira de 16 bits em base
                                                                        decimal ou hexadecimal         </td></tr>
  <tr><td>     EQU    </td><td>     1     </td><td>     0    </td><td>  Cria um sinônimo textual para
                                                                        um sımbolo                     </td></tr>
  <tr><td>      IF    </td><td>     1     </td><td>     0    </td><td>  Instrue o montador a incluir a
                                                                        <strong>linha seguinte</strong>
                                                                        do codigo somente se o valor do
                                                                        operando for 1                  </td></tr>
  <tr><td>    MACRO   </td><td>     0     </td><td>     0    </td><td>  Marcar inıcio de suma MACRO.
                                                                        Sempre dentro da seçao TEXT e
                                                                        antes do codigo principal     </td></tr>
  <tr><td>     END    </td><td>     0     </td><td>     0    </td><td>  Marcar o fim de uma MACRO     </td></tr>
</table>

## Especificação

O montador deve:
 - não ser "case sensitive";
 - não ter ordem fixa para as secoes de TEXT e DATA;
 - gerar um arquivo de de saıda em formato de texto;
 - desconsiderar tabulacoes, quebras de linhas e espacos desnecessarios;
 - considerar que a diretiva CONST aceita números positivos ou negativos, inteiros ou hexadecimais;
 - ser capaz de trabalhar com vetores
 - aceitar comentarios indicados pelo sımbolo “;”;
 - considerar que o comando COPY deve utilizar uma vırgula e um espaco entre os operandos;
 - ser capaz de aceitar MACROS;
 - poder criar um rotulo, dar quebra de linha e continuar a linha depois;
 - identificar  erros  durante  a  montagem, mostrando a(s)  linha(s) e o tipo do erro (léxixo, sintático ou semântico)
 
 ## Estrutura do projeto
 
<table>
  <tr>
    <td><strong>Fase</strong></td>
    <td><strong>Flag</strong></td>
    <td><strong>Tarefa</strong></td>
    <td><strong>Erros a serem identificados</strong></td>
  </tr>
  <tr>
    <td rowspan="4">Pré processamento</td>
    <td rowspan="3">-p</td>
    <td>Desconsiderar tabulações, quebra de linhas e espaços desnecessários</td>
    <td rowspan="4">-</td>
  </tr>
  <tr>
    <td>Retirar Comentários</td>
  </tr>
  <tr>
    <td>Resolver "ECHO IF"</td>
  </tr>
  <tr>
    <td>-m</td>
    <td>Expandir macros</td>
  </tr>
  <tr>
    <td rowspan="15">Passagem única</td>
    <td rowspan="15">-o</td>
    <td rowspan="1">Scanner</td>
    <td>Tokens inválidos</td>
  </tr>
  <tr>
    <td rowspan="4">Parser</td>
    <td>Seção inválida</td>
  </tr>
  <tr>
    <td>Dois rótulos na mesma linha</td>
  </tr>
  <tr>
    <td>Instruções com a quantidade de operando inválida</td>
  </tr>
  <tr>
    <td>Tipo de argumento inválido</td>
  </tr>
  <tr>
    <td rowspan="10">Análise semântica</td>
  </tr>
  <td>Diretivas inválidas (supõe mneumônico desconhecido na seção DATA) </td>
  </tr>
  <tr>
    <td>Instruções inválidas (supõe mneumônico desconhecido na seção TEXT) </td>
  </tr>
  <tr>
    <td>Declarações e rótulos ausentes</td>
  </tr>
  <tr>
    <td>Seção TEXT faltante</td>
  </tr>
  <tr>
    <td>Declarações e rótulos repetidos</td>
  </tr>
  <tr>
    <td>Pulo para rótulos inválidos</td>
  </tr>
  <tr>
    <td>Pulo para seção errada</td>
  </tr>
  <tr>
    <td>Diretivas ou instruções na seção errada</td>
  </tr>
  <tr>
    <td>Divisão por zero (para constante)</td>
  </tr>
  <tr>
    <td>Modificação de um valor constante</td>
  </tr>
</table>  

## Como compilar
  
    $ make
    
## Como gerar a documentação

    $ make doc

## Como executar

### Pre-processador sem macros

    $ ./assembler -p <seu programa>.asm <arquivo de saída>.pre

### Pre-processador com macros

    $ ./assembler -m <seu programa>.asm <arquivo de saída>.mcr
  
### Montador completo

    $ ./assembler -o <seu programa>.asm <arquivo de saída>.o
    
## Dependências

Como mencionado acima, esse projeto depende do Bison e do Flex. O uso de ambos foi autorizado pelo professor da disciplina e ambos geralmente já vem incluídos nos pacotes de utilitários essenciais (build essentials).

Ressalta-se a necessidade do Bison com versão 3.o ou superior e do Flex com versão 2.5 ou superior. Por serem utilitários GNU padrões, se necessário é possível atualizar ambos de forma padrão (com apt-get em distribuições Ubuntu, por exemplo).

## Diretrizes do projeto

O código será escrito com o padrão "Camel Case". 
Como padrão, as variáveis, abstrações e nomes no código serão dadas em inglês e toda a documentaço será feita em português. 

A linguagem de programação utilizada é o C++ e o projeto segue diretrizes (*[Guidelines][GUIDELINES]*)
para programar nessa linguagem feitas pelos desenvolvedores da Google.

[GUIDELINES]: https://google.github.io/styleguide/cppguide.html

