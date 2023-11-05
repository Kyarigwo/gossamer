export PATH := $(PATH):/home/bruce/.local/riscv/toolchain/bin

SRC_DIR = src
GOSSAMER_SRC_DIR = $(SRC_DIR)/gossamer
PRIMARY_WORDS_SRC_DIR = $(SRC_DIR)/primary_words

BIN_DIR = .
EXE = $(BIN_DIR)/gossamer

CC = riscv64-unknown-elf-gcc
CFLAGS = -nostdlib -mabi=ilp32 -march=rv32imac
DEBUG_FLAGS = -ggdb

ASM_SRC = $(wildcard $(SRC_DIR)/*.S)
GOSSAMER_SRC = $(wildcard $(GOSSAMER_SRC_DIR)/*.gossamer)
PRIMARY_WORDS_SRC = $(wildcard $(PRIMARY_WORDS_SRC_DIR)/*.S)

.PHONY: all
all: $(EXE) # gossamer

$(EXE): $(ASM_SRC) $(PRIMARY_WORDS_SRC) $(GOSSAMER_SRC_DIR)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(PRIMARY_WORDS_SRC) $(ASM_SRC) -o $(EXE)

.PHONY: clean
clean:
	-rm gossamer
	-rm *.aux
	-rm *.fdb_latexmk
	-rm *.fls
	-rm *.log
	-rm *.synctex.gz
	-rm *.xdv