# Compilador a ser utilizado
CC = g++

# "Flags" para a geração automática das dependências
DEP_FLAGS = -MT $@ -MMD -MP -MF $(DEP_PATH)/$*.d
# Diretivas que são utilizadas na compilação de cada objeto
DIRECTIVES = -std=c++11 -Wall -Wextra -c -I $(HEADER_PATH)

# Um caminho para guardar e acessar cada tipo de arquivo: .hpp (headers),
# .cpp (sources), .o (objects) e .d (dependencies), respectivamente
HEADER_PATH = include
SRC_PATH = src
BIN_PATH = bin
DEP_PATH = dep

# Uma lista de arquivos para cada tipo de arquivo:
# .cpp, .o e .d, respectivamente
CPP_FILES = $(wildcard $(SRC_PATH)/*.cpp)
OBJ_FILES = $(addprefix $(BIN_PATH)/,$(notdir $(CPP_FILES:.cpp=.o)))
DEP_FILES = $(wildcard $(DEP_PATH)/*.d)

# Nome do executável final
# MODIFIQUE AQUI NOMEANDO COM SEU NOME E MATRÍCULA
EXEC = montador

# Regra default:
all: $(EXEC)
# Regra de criação do executável final:
$(EXEC): $(OBJ_FILES)
	$(CC) -o $@ $^

# Regra de inferência para criação dos objetos de compilação:
$(BIN_PATH)/%.o: $(SRC_PATH)/%.cpp
# Tenta criar os diretórios dep e bin e ignora caso eles já existam
	@mkdir -p $(DEP_PATH) $(BIN_PATH)
# Gera os objetos usando diretivas de compilação e as respectivas dependências
	$(CC) $(DEP_FLAGS) -c -o $@ $< $(DIRECTIVES)

# Regra que inclui diretivas de debug na compilação
debug: DIRECTIVES += -ggdb -O0
debug: all

# Regra que inclui diretivas de compilação otimizada
release: DIRECTIVES += -Ofast -mtune=native
release: all

# Regra para limpar/deletar todos os arquivos e diretórios criados pelo make
clean:
	rm -rf $(BIN_PATH) $(DEP_PATH)
	rm -f $(EXEC)

# Regra para printar uma variável no terminal. Auxilia no debug do Makefile
print-% : ; @echo $* = $($*)

# Regra que estabelece que arquivos .d são "preciosos"
.PRECIOUS: $(DEP_PATH)/%.d
# Regra que torna as dependências "phony"
.PHONY: debug clean release

# Inclui as regras geradas pelos arquivos de dependência
-include $(DEP_FILES)

