INCLUDE "hardware.inc"
INCLUDE "character-selection-background.asm"
; INCLUDE "arena-background.asm"
; INCLUDE "characters.asm"

; SECTION "Header", ROM0[$100]

; 	jp CSSEntryPoint

; 	ds $150 - @, 0 ; Make room for the header

CSSEntryPoint:
	; Shut down audio circuitry
	xor a
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
CSSWaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, CSSWaitVBlank

	; Turn the LCD off
	xor a
	ld [rLCDC], a

    ld b, 0
    call InitializeCharacterSelectionBackground
    call InitializeCharacters
    call CSSInitializeData

    ld a, 0
    ld b, 160
    ld hl, _OAMRAM

CSSClearOam:
    ld [hli], a
    dec b
    jp nz, CSSClearOam

    call CSSSetCharacterSelectionOAM

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a


	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

    ; Enable second joypad input
    ; call check_sgb

    ld a, P1F_GET_NONE
    ldh [rP1], a

CSSMain:
    ; Check the current keys every frame and move left or right.
    call CSSUpdateKeys
    ldh a, [rLY]
	cp 144
	jp nc, CSSMain

CSSWaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, CSSWaitVBlank2
    call CSSUpdateKeys
    call CSSUpdateCSSSelectionState
    call CSSUpdateGameState
    call CSSCheckFinish
    jp CSSMain

CSSUpdateCSSSelectionState:
    .CheckRight
        ld a, [CSSNewKeys]
        and a, PADF_RIGHT
        jp z, .CheckLeft
    .Right
        ld a, [CSSselectionState]
        add a, 4
        ld [CSSselectionState], a
        jp .Return
    .CheckLeft
        ld a, [CSSNewKeys]
        and a, PADF_LEFT
        jp z, .Return
    .Left
        ld a, [CSSselectionState]
        sub a, 4
        ld [CSSselectionState], a
        jp .Return
    .Return
        ; Take the mod of CSSselectionState and return
        ; We do CSSselectionState % 24
        ld a, [CSSselectionState]
        cp 24
        jp nz, .no_overflow
        ld a, 0
        .no_overflow
        cp -4
        jp nz, .no_underflow
        ld a, 20
        .no_underflow
        ld [CSSselectionState], a
        call CSSSetCharacterSelectionOAM
        ret





CSSSetCharacterSelectionOAM: 
    ld a, [CSSselectionState]
    ld b, a
    ; Load michael's normal sprite data
    ld hl, _OAMRAM
    ld a, 64 + 16
    call CSSBouncingAnimation
    ld [hli], a
    ld a, 112 + 8
    ld [hli], a
    ld a, 12
    cp b ; compare a with b
    jr nz, .michael_jmp 
    add a, 2
    ; Don't do the bouncing animation
    ld c, a
    ld a, 64 + 16
    ld de, _OAMRAM
    ld [de], a
    ld a, c
    .michael_jmp
        ld [hli], a
        ld [hli], a


    ; Load omkars's normal sprite data
    ld hl, _OAMRAM + 4
    ld a, 16 + 16
    call CSSBouncingAnimation
    ld [hli], a
    ld a, 110 + 8
    ld [hli], a
    ld a, 4
    cp b ; compare a with b
    jr nz, .omkar_jmp 
    add a, 2
    ; Don't do the bouncing animation
    ld c, a
    ld a, 16 + 16
    ld de, _OAMRAM + 4
    ld [de], a
    ld a, c
    .omkar_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ; Load krill's normal sprite data
    ld hl, _OAMRAM + 8
    ld a, 17 + 16
    call CSSBouncingAnimation
    ld [hli], a
    ld a, 30 + 8
    ld [hli], a
    ld a, 0
    cp b ; compare a with b
    jr nz, .krill_jmp 
        add a, 2
        ; Don't do the bouncing animation
        ld c, a
        ld a, 17 + 16
        ld de, _OAMRAM + 8
        ld [de], a
        ld a, c
    .krill_jmp
        ld [hli], a
        xor a
        ld [hli], a


    ; Load caleb's normal sprite data
    ld hl, _OAMRAM + 12
    ld a, 64 + 16
    call CSSBouncingAnimation
    ld [hli], a
    ld a, 31 + 8
    ld [hli], a
    ld a, 8
    cp b ; compare a with b
    jr nz, .caleb_jmp 
        add a, 2
        ; Don't do the bouncing animation
        ld c, a
        ld a, 64 + 16
        ld de, _OAMRAM + 12
        ld [de], a
        ld a, c
    .caleb_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ; Load neil's normal sprite data
    ld hl, _OAMRAM + 16
    ld a, 112 + 16
    call CSSBouncingAnimation
    ld [hli], a
    ld a, 30 + 8
    ld [hli], a
    ld a, 16
    cp b
    jr nz, .neil_jmp
    add a, 2
        ; Don't do the bouncing animation
        ld c, a
        ld a, 112 + 16
        ld de, _OAMRAM + 16
        ld [de], a
        ld a, c
    .neil_jmp
        ld [hli], a
        xor a
        ld [hli], a

    ret


; Source: https://gbdev.io/gb-asm-tutorial/part2/input.html
CSSUpdateKeys:
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

    ; Combine with previous CSSCurKeys to make CSSNewKeys
    ld a, [CSSCurKeys]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [CSSNewKeys], a
    ld a, b
    ld [CSSCurKeys], a
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

CSSInitializeData: 
    xor a
    ld [CSSCurKeys], a
    ld [CSSNewKeys], a
    ld [CSSselectionState], a
    ld [CSSFrameCounter], a
    ret

CSSUpdateGameState: 
    ld hl, CSSFrameCounter
    inc [hl]


CSSBouncingAnimation: 
    ld c, a
    ld a, [CSSFrameCounter]
    and a, %00100000
    srl a 
    srl a
    srl a
    srl a
    cpl
    inc a; 
    add a, c
    ret

CSSCheckFinish: 
    ld a, [CSSNewKeys]
    and a, PADF_A
    jp z, .Return
    jp WaitVBlank
    .Return
    ret

SECTION "CSS Input Variables", WRAM0
CSSCurKeys: db
CSSNewKeys: db

SECTION "CSS Selection State", WRAM0
CSSselectionState: db

SECTION "CSS Game State", WRAM0
CSSFrameCounter: db