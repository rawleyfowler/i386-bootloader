SHELL=/bin/sh

.PHONY: all

all:
	@echo "Building"
	-nasm -felf32 -o bootloader.o bootloader.asm
	-gcc -m32 -c kernel.c -o kernel.o
	-ld -m elf_i386 --oformat binary -Ttext 0x7c00 -o t.o bootloader.o kernel.o
