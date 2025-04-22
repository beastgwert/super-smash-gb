INCLUDE "hardware.inc"
; INCLUDE "sub-background.asm"
INCLUDE "utils/sprobjs_lib.asm"
; INCLUDE "utils/sgb-utils.asm"

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

    ; call InitializeSubBackground

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a

; 	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ; Initialize global variables
    xor a
;     ld [wFrameCounter1], a
    ld [wCurKeys1], a

Main:
    call UpdateKeys
    ldh a, [rLY]
	cp 144
	jp nc, Main ;rerun if in vblank
WaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, WaitVBlank2
    jp Main

transferControls:
    ; Assume data is in register a
    ldh [rSB], a
    ld a, $80 ; This is 80 because it's the subroutine
    ldh [rSC], a
    ; This is the "subroutine" so we'll wait for the transfer to be set up first
    .waitStart
        ldh a, [rSC]
        and $80
        jr z, .waitStart
    .waitTransfer
        ldh a, [rSC]
        and $80 ; check if transfer still in progress
        jr nz, .waitTransfer ; wait until done
    ; ldh a, [rSB] --- Commenting this portion out because we're receiving data
    ret


UpdateKeys:
    ; Poll half the controller
    ld a, P1F_GET_DPAD
    call .onenibble
    swap a ; A7-4 = unpressed directions; A3-0 = 1
    ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

    ; Poll the other half
    ld a, P1F_GET_BTN
    call .onenibble
    xor a, b ; A = pressed buttons + directions
    ld b, a ; B = pressed buttons + directions

    ; Combine with previous wCurKeys to make wNewKeys
    ld a, [wCurKeys1]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [wNewKeys1], a
    ld a, b
    ld [wCurKeys1], a

    ; Receive data from sub player
    di
    ld a, [wCurKeys1] ; put player 1 keys in SB
    call transferControls
    ld a, [wNewKeys1]
    call transferControls
    ei

    ld a, P1F_GET_NONE
    ldh [rP1], a

    ret
.onenibble
    ldh [rP1], a ; switch the key matrix
    call .knownret ; burn 10 cycles calling a known ret
    ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
    ldh a, [rP1]
    ldh a, [rP1] ; this read counts
    or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
    ret 


SECTION "Input Variables", WRAM0
wCurKeys1: db
wNewKeys1: db
