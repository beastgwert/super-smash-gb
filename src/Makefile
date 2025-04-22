all:
	rgbasm -o main.o main.asm
	rgblink -o super-smash.gb main.o
	rgbfix -v -p 0xFF super-smash.gb
	rgbasm -o main-sub.o main-sub.asm
	rgblink -o super-smash-sub.gb main-sub.o
	rgbfix -v -p 0xFF super-smash-sub.gb

character-selection: 
	rgbasm -o character-selection.o character-selection.asm
	rgblink -o super-smash-char-select.gb character-selection.o
	rgbfix -v -p 0xFF super-smash-char-select.gb	

clean: 
	rm -rf *.gb
	rm -rf *.o 