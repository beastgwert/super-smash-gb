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

    ld b, 0
    call InitializeCharacterSelectionBackground
    call InitializeCharacters
    call InitializeData


    ld a, 0
    ld b, 160
    ld hl, _OAMRAM

ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    call SetCharacterSelectionOAM

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a


	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

Main:
    ; Check the current keys every frame and move left or right.
    call UpdateKeys
    ldh a, [rLY]
	cp 144
	jp nc, Main

WaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, WaitVBlank2

    call UpdateKeys
    call UpdateSelectionState
    jp Main

UpdateSelectionState:
    .CheckRight
        ld a, [wNewKeys]
        and a, PADF_RIGHT
        jp z, .CheckLeft
    .Right
        ld a, [selectionState]
        add a, 4
        ld [selectionState], a
        jp .Return
    .CheckLeft
        ld a, [wNewKeys]
        and a, PADF_LEFT
        jp z, .Return
    .Left
        ld a, [selectionState]
        sub a, 4
        ld [selectionState], a
        jp .Return
    .Return
        ; Take the mod of selectionState and return
        ; We do selectionState % 24
        ld a, [selectionState]
        cp 24
        jp nz, .no_overflow
        ld a, 0
        .no_overflow
        cp -4
        jp nz, .no_underflow
        ld a, 20
        .no_underflow
        ld [selectionState], a
        call SetCharacterSelectionOAM
        ret





SetCharacterSelectionOAM: 
    ld a, [selectionState]
    ld b, a
    ; Load michael's normal sprite data
    ld hl, _OAMRAM
    ld a, 64 + 16
    ld [hli], a
    ld a, 112 + 8
    ld [hli], a
    ld a, 12
    cp b ; compare a with b
    jr nz, .michael_jmp 
    add a, 2
    .michael_jmp
        ld [hli], a
        ld [hli], a

    ; Load omkars's normal sprite data
    ld hl, _OAMRAM + 4
    ld a, 16 + 16
    ld [hli], a
    ld a, 110 + 8
    ld [hli], a
    ld a, 4
    cp b ; compare a with b
    jr nz, .omkar_jmp 
    add a, 2
    .omkar_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ; Load krill's normal sprite data
    ld hl, _OAMRAM + 8
    ld a, 17 + 16
    ld [hli], a
    ld a, 30 + 8
    ld [hli], a
    ld a, 0
    cp b ; compare a with b
    jr nz, .krill_jmp 
    add a, 2
    .krill_jmp
        ld [hli], a
        xor a
        ld [hli], a


    ; Load caleb's normal sprite data
    ld hl, _OAMRAM + 12
    ld a, 64 + 16
    ld [hli], a
    ld a, 31 + 8
    ld [hli], a
    ld a, 8
    cp b ; compare a with b
    jr nz, .caleb_jmp 
    add a, 2
    .caleb_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ; Load neil's normal sprite data
    ld hl, _OAMRAM + 16
    ld a, 112 + 16
    ld [hli], a
    ld a, 30 + 8
    ld [hli], a
    ld a, 16
    cp b
    jr nz, .neil_jmp
    add a, 2
    .neil_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ret


; Source: https://gbdev.io/gb-asm-tutorial/part2/input.html
UpdateKeys:
    ; Poll half the controller
    ld a, P1F_GET_BTN
    call .onenibble
    ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

    ; Poll the other half
    ld a, P1F_GET_DPAD
    call .onenibble
    swap a ; A7-4 = unpressed directions; A3-0 = 1
    xor a, b ; A = pressed buttons + directions
    ld b, a ; B = pressed buttons + directions

    ; And release the controller
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ; Combine with previous wCurKeys to make wNewKeys
    ld a, [wCurKeys]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [wNewKeys], a
    ld a, b
    ld [wCurKeys], a
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


InitializeData: 
    xor a
    ld [wCurKeys], a
    ld [wNewKeys], a
    ld [selectionState], a
    ret


SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db

SECTION "Selection State", WRAM0
selectionState: db