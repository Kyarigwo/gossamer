export PATH := $(PATH):/home/bruce/.local/riscv/toolchain/bin


SRC_DIR = src
BIN_DIR = .
EXE = $(BIN_DIR)/gossamer

CC = riscv64-unknown-elf-gcc
CFLAGS = -nostdlib -mabi=ilp32 -march=rv32imac
DEBUG_FLAGS = -ggdb

SRC = $(wildcard $(SRC_DIR)/*.S)

.PHONY: all
all: $(EXE) # gossamer

$(EXE): $(SRC) $(SRC_DIR)/bootstrap.gossamer  $(SRC_DIR)/nucleus.gossamer
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(SRC) -o $(EXE)

.PHONY: clean
clean:
	-rm gossamer
	-rm *.aux
	-rm *.fdb_latexmk
	-rm *.fls
	-rm *.log
	-rm *.synctex.gz
	-rm *.xdv