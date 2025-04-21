all:
	rgbasm -o main.o main.asm
	rgblink -o super-smash.gb main.o
	rgbfix -v -p 0xFF super-smash.gb

character-selection: 
	rgbasm -o character-selection.o character-selection.asm
	rgblink -o super-smash-char-select.gb character-selection.o
	rgbfix -v -p 0xFF super-smash-char-select.gb	