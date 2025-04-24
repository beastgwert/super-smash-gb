INCLUDE "hardware.inc"
; INCLUDE "arena-background.asm"
; INCLUDE "characters.asm"

; SECTION "Header", ROM0[$100]

; 	jp CSSTextEntryPoint

; 	ds $150 - @, 0 ; Make room for the header

CSSTextEntryPoint:

	; Do not turn the LCD off outside of VBlank
CSSTextWaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, CSSTextWaitVBlank

	; Turn the LCD off
	xor a
	ld [rLCDC], a

    ld b, 0
    call InitializeOpeningBackground
    call CSSTextInitializeData

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

CSSTextMain:
    ; Check the current keys every frame and move left or right.
    ldh a, [rLY]
	cp 144
	jp nc, CSSTextMain


CSSTextWaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, CSSTextWaitVBlank2
    call CSSTextUpdateGameState
    jp CSSTextMain


CSSTextInitializeData: 
    xor a
    ld [CSSFrameCounter], a
    ld a, %11011000 ; Different mapping for OBP1
    ld [rOBP1], a    ; Set Object Palette 1
    ret

CSSTextUpdateGameState: 
    ld hl, CSSFrameCounter
    inc [hl]
    ld a, [hl]
    cp a, %11111111
    jp z, CSSEntryPoint
    ret
