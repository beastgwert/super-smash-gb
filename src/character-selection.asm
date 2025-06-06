INCLUDE "hardware.inc"
INCLUDE "character-selection-background.asm"
INCLUDE "character-selection-text.asm"
; INCLUDE "arena-background.asm"
; INCLUDE "characters.asm"

; SECTION "Header", ROM0[$100]

; 	jp CSSEntryPoint

; 	ds $150 - @, 0 ; Make room for the header

CSSEntryPoint:
	; Do not turn the LCD off outside of VBlank
CSSWaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, CSSWaitVBlank

	; Turn the LCD off
	xor a
	ld [rLCDC], a

    call InitializeSound
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
    call UpdateMusic
    call CSSUpdateKeys
    ldh a, [rLY]
	cp 144
	jp nc, CSSMain

CSSWaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, CSSWaitVBlank2
    call CSSUpdateSelectionState1
    call CSSUpdateSelectionState2
    call CSSSetCharacterSelectionOAM
    call CSSSetCharacerSelectionOverview
    call CSSUpdateGameState
    call CSSCheckFinish
    jp CSSMain

CSSUpdateSelectionState1:
    ld a, [CSSselectingPlayer]
    cp 1
    jr z, .Return
    .CheckRight
        ld a, [CSSNewKeys1]
        and a, PADF_RIGHT
        jp z, .CheckLeft
    .Right
        ld a, [CSSselectionState1]
        add a, 4
        ld [CSSselectionState1], a
        jp .Return
    .CheckLeft
        ld a, [CSSNewKeys1]
        and a, PADF_LEFT
        jp z, .Return
    .Left
        ld a, [CSSselectionState1]
        sub a, 4
        ld [CSSselectionState1], a
        jp .Return
    .Return
        ; Take the mod of CSSselectionState1 and return
        ; We do CSSselectionState1 % 24
        ld a, [CSSselectionState1]
        cp 20
        jp nz, .no_overflow
        ld a, 0
        .no_overflow
        cp -4
        jp nz, .no_underflow
        ld a, 16
        .no_underflow
        ld [CSSselectionState1], a
        ret

CSSUpdateSelectionState2:
    .CheckRight
        ld a, [CSSNewKeys2]
        and a, PADF_RIGHT
        jp z, .CheckLeft
    .Right
        ld a, [CSSselectionState2]
        add a, 4
        ld [CSSselectionState2], a
        jp .Return
    .CheckLeft
        ld a, [CSSNewKeys2]
        and a, PADF_LEFT
        jp z, .Return
    .Left
        ld a, [CSSselectionState2]
        sub a, 4
        ld [CSSselectionState2], a
        jp .Return
    .Return
        ; Take the mod of CSSselectionState2 and return
        ; We do CSSselectionState2 % 24
        ld a, [CSSselectionState2]
        cp 20
        jp nz, .no_overflow
        ld a, 0
        .no_overflow
        cp -4
        jp nz, .no_underflow
        ld a, 16
        .no_underflow
        ld [CSSselectionState2], a
        ret


CSSSetCharacterSelectionOAM: 
    ; Check which player's turn it is
    ld a, [CSSselectingPlayer]
    cp 0
    jr z, .use_first_player
        ld a, [CSSselectionState2]
        ld b, a
        jr .finish_selection
    .use_first_player
        ld a, [CSSselectionState1]
        ld b, a
    .finish_selection

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
        xor a
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

    ; Combine with previous CSSCurKeys1 to make CSSNewKeys1
    ld a, [CSSCurKeys1]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [CSSNewKeys1], a
    ld a, b
    ld [CSSCurKeys1], a
    
    di
    call transferControls
    ld [CSSCurKeys2], a
    call transferControls
    ld [CSSNewKeys2], a
    ei


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
    ld [CSSCurKeys1], a
    ld [CSSNewKeys1], a
    ld [CSSCurKeys2], a
    ld [CSSNewKeys2], a
    ld [CSSselectionState1], a
    ld [CSSselectionState2], a
    ld [CSSFrameCounter], a
    ld [CSSselectingPlayer], a
    ld a, %11101000 ; Different mapping for OBP1
    ld [rOBP1], a    ; Set Object Palette 1
    ret

CSSUpdateGameState: 
    ld hl, CSSFrameCounter
    inc [hl]


CSSBouncingAnimation: 
    ld c, a
    ld a, [CSSFrameCounter]
    and a, %00010000
    srl a 
    srl a
    srl a
    ; srl a
    cpl
    inc a; 
    add a, c
    ret

CSSAttackingAnimation: 
    ld c, a
    ld a, [CSSFrameCounter]
    and a, %00100000
    srl a 
    srl a
    srl a
    srl a
    cpl
    add a, c
    ret


CSSCheckFinish: 
    ld a, [CSSselectingPlayer]
    cp 0
    jr z, .check_first_player_finish
        ld a, [CSSNewKeys2]
        and a, PADF_A
        jr z, .return_second_player
        jp WaitVBlank
        .return_second_player
        ret
    .check_first_player_finish
        ld a, [CSSNewKeys1]
        and a, PADF_A
        jp z, .return_first_player
        ; Set selecting player to 1
        ld a, 1
        ld [CSSselectingPlayer], a
        xor a
        ld [CSSselectionState2], a
        .return_first_player
        ret


CSSSetCharacerSelectionOverview: 
    ld hl, _OAMRAM + 20
    ld a, 114 + 16
    ld [hli], a
    ld a, 101 + 8
    ld [hli], a
    ld a, [CSSselectionState1]
    ld [hli], a
    xor a
    ld [hli], a

    ; If selecting player is 1, we display player 2's character
    ld a, [CSSselectingPlayer]
    cp 1
    jr nz, .return
        ld hl, _OAMRAM + 24
        ld a, 114 + 16
        ld [hli], a
        ld a, 129 + 8
        ld [hli], a
        ld a, [CSSselectionState2]
        ld [hli], a
        xor a
        ld a, %00100000
        ld [hli], a
    .return
    ret 

SECTION "CSS Input Variables", WRAM0
CSSCurKeys1: db
CSSNewKeys1: db
CSSCurKeys2: db
CSSNewKeys2: db

SECTION "CSS Selection State", WRAM0
CSSselectionState1: db
CSSselectionState2: db
CSSselectingPlayer: db

SECTION "CSS Game State", WRAM0
CSSFrameCounter: db
