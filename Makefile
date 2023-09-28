export PATH := $(PATH):/home/bruce/.local/riscv/toolchain/bin
CC = riscv64-unknown-elf-gcc
CFLAGS = -nostdlib -mabi=ilp32 -march=rv32imac
DEBUG_FLAGS = -ggdb

all: gossamer

gossamer: gossamer.S macros.S utilities.S
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -o  gossamer gossamer.S utilities.S

clean:
	rm gossamer
	rm *.aux
