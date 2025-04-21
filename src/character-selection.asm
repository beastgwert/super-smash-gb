INCLUDE "hardware.inc"
INCLUDE "character-selection-background.asm"
; INCLUDE "arena-background.asm"
INCLUDE "characters.asm"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	xor a
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off
	xor a
	ld [rLCDC], a

    call InitializeCharacterSelectionBackground
    call InitializeCharacters

    ld a, 0
    ld b, 160
    ld hl, _OAMRAM

ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    ; Initialize the player in OAM
    ld hl, _OAMRAM
    ld a, 16 + 16
    ld [hli], a
    ld a, 40 + 8
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a


	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

Done: 
    jp Done