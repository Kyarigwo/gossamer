export PATH := $(PATH):/home/bruce/.local/riscv/toolchain/bin
CC = riscv64-unknown-elf-gcc
CFLAGS = -nostdlib -mabi=ilp32 -march=rv32imac
DEBUG_FLAGS = -ggdb

OBJS = gossamer.S macros.S utilities.S words.S

all: gossamer

gossamer: $(OBJS)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(OBJS) -o gossamer

.PHONY: clean
clean:
	-rm gossamer
	-rm *.aux
	-rm *.fdb_latexmk
	-rm *.fls
	-rm *.log
	-rm *.synctex.gz
	-rm *.xdv