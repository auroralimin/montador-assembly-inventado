# Compilador a ser utilizado
CC = clang++

# "Flags" para a geração automática das dependências
DEP_FLAGS = -MT $@ -MMD -MP -MF $(DEP_PATH)/$*.d
# Diretivas que são utilizadas na compilação de cada objeto
DIRECTIVES = -std=c++11 -Wall -Wextra -Wno-deprecated-register -c -I $(INC_PATH) -I $(INC_PATH)/$(PRE_PATH) -I $(INC_PATH)/$(MACRO_PATH)
# Diretivas que são utilizadas na "linkagem" dos objetos gerando o executável
LIBS =

# Um caminho para guardar e acessar cada tipo de arquivo: .hpp (headers),
# .cpp (sources), .o (objects) e .d (dependencies), respectivamente
INC_PATH = include
SRC_PATH = src
BIN_PATH = bin
DEP_PATH = dep
MACRO_PATH = macro
PRE_PATH = pre

# Caminho para arquivos Flex e Bison
GEN_PATH = generate

# Uma lista de arquivos para cada tipo de arquivo:
# .cpp, .o e .d, respectivamente
CPP_FILES = $(wildcard $(SRC_PATH)/*.cpp)
CPP_MACRO_FILES = $(wildcard $(SRC_PATH)/$(MACRO_PATH)/*.cpp)
CXX_PRE_FILES = $(wildcard $(SRC_PATH)/$(PRE_PATH)/*.cxx)
CXX_MACRO_FILES = $(wildcard $(SRC_PATH)/$(MACRO_PATH)/*.cxx)
OBJ_FILES = $(addprefix $(BIN_PATH)/,$(notdir $(CPP_FILES:.cpp=.o)))
OBJ_FILES += $(addprefix $(BIN_PATH)/, $(notdir $(CXX_PRE_FILES:.cxx=.o)))
OBJ_FILES_M = $(addprefix $(BIN_PATH)/,$(notdir $(CPP_MACRO_FILES:.cpp=.o)))
OBJ_FILES_M += $(addprefix $(BIN_PATH)/, $(notdir $(CXX_MACRO_FILES:.cxx=.o)))
DEP_FILES = $(wildcard $(DEP_PATH)/*.d)

# Nome dos arquivos Flex e Bison
PRE_SCANNER = PreScanner.l
PRE_PARSER = PreParser.y
MACRO_SCANNER = MacroScanner.l
MACRO_PARSER = MacroParser.y

# Nome do executável final
# MODIFIQUE AQUI NOMEANDO COM SEU NOME E MATRÍCULA
EXEC = montador
M_EXEC = macro_exec

# Regra default:
all:
	$(MAKE) generate
	$(MAKE) $(EXEC)
	$(MAKE) $(M_EXEC)

# Regra de criação do executável final:
$(EXEC): $(OBJ_FILES)
	$(CC) -o $@ $^ $(LIBS)

# Regra de criação do executável de macro
$(M_EXEC): $(OBJ_FILES_M)
	$(CC) -o $@ $^ $(LIBS)
	mv macro_exec $(SRC_PATH)/$(MACRO_PATH)

# Regra de inferência para criação dos objetos de compilação a partir de um .cpp
$(BIN_PATH)/%.o: $(SRC_PATH)/%.cpp
	@mkdir -p $(DEP_PATH) $(BIN_PATH)
	$(CC) $(DEP_FLAGS) -c -o $@ $< $(DIRECTIVES)

# Regra de inferência para criação dos objetos de compilação a partir de um .cxx do pre
$(BIN_PATH)/%.o: $(SRC_PATH)/$(PRE_PATH)/%.cxx
	@mkdir -p $(DEP_PATH) $(BIN_PATH)
	$(CC) $(DEP_FLAGS) -c -o $@ $< $(DIRECTIVES)

# Regra de inferência para criação dos objetos de compilação a partir de um .cpp da macro
$(BIN_PATH)/%.o: $(SRC_PATH)/$(MACRO_PATH)/%.cpp
	@mkdir -p $(DEP_PATH) $(BIN_PATH)
	$(CC) $(DEP_FLAGS) -c -o $@ $< $(DIRECTIVES)

# Regra de inferência para criação dos objetos de compilação a partir de um .cxx da macro
$(BIN_PATH)/%.o: $(SRC_PATH)/$(MACRO_PATH)/%.cxx
	@mkdir -p $(DEP_PATH) $(BIN_PATH)
	$(CC) $(DEP_FLAGS) -c -o $@ $< $(DIRECTIVES)

# Regra que inclui diretivas de debug na compilação
debug: DIRECTIVES += -ggdb -O0
debug: all

# Regra que inclui diretivas de compilação otimizada
release: DIRECTIVES += -Ofast -mtune=native
release: all

# Regra para limpar/deletar todos os arquivos e diretórios criados pelo make
clean:
	rm -rf $(BIN_PATH) $(DEP_PATH) $(INC_PATH)/$(PRE_PATH) $(INC_PATH)/$(MACRO_PATH) 
	rm -f $(EXEC) $(SRC_PATH)/$(MACRO_PATH)/$(M_EXEC) $(SRC_PATH)/$(PRE_PATH)/*.cxx $(SRC_PATH)/$(MACRO_PATH)/*.cxx $(INC_PATH)/*.hxx $(INC_PATH)/*.hh

# Gera o código do scanner e do parser e coloca-os nas pastas corretas
generate:
	bison -o $(PRE_PARSER:.y=.cxx) $(GEN_PATH)/$(PRE_PARSER)
	flex -o $(PRE_SCANNER:.l=.cxx) $(GEN_PATH)/$(PRE_SCANNER)
	mkdir -p $(SRC_PATH)/$(PRE_PATH) $(INC_PATH)/$(PRE_PATH)
	mv *.cxx $(SRC_PATH)/$(PRE_PATH)
	mv *.hxx *.hh $(INC_PATH)/$(PRE_PATH)

	bison -o $(MACRO_PARSER:.y=.cxx) $(GEN_PATH)/$(MACRO_PARSER)
	flex -o $(MACRO_SCANNER:.l=.cxx) $(GEN_PATH)/$(MACRO_SCANNER)
	mkdir -p $(SRC_PATH)/$(MACRO_PATH) $(INC_PATH)/$(MACRO_PATH)
	mv *.cxx $(SRC_PATH)/$(MACRO_PATH)
	mv *.hxx *.hh $(INC_PATH)/$(MACRO_PATH)

# Regra para printar uma variável no terminal. Auxilia no debug do Makefile
print-% : ; @echo $* = $($*)

# Regra que estabelece que arquivos .d são "preciosos"
.PRECIOUS: $(DEP_PATH)/%.d
# Regra que torna as dependências "phony"
.PHONY: debug clean release generate

# Inclui as regras geradas pelos arquivos de dependência
-include $(DEP_FILES)

