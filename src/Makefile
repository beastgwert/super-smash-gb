all:
	rgbasm -o main.o main.asm
	rgblink -o super-smash.gb main.o
	rgbfix -v -p 0xFF super-smash.gb