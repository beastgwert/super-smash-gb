INCLUDE "hardware.inc"
INCLUDE "arena-background.asm"
INCLUDE "characters.asm"
INCLUDE "utils/sprobjs_lib.asm"
INCLUDE "utils/sgb-utils.asm"

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

    call InitializeBackground

    call InitializeCharacters

    ; Initilize Sprite Object Library.
    call InitSprObjLib

    ; Reset hardware OAM
    xor a, a
    ld b, 160
    ld hl, wShadowOAM
.resetOAM
    ld [hli], a
    dec b
    jr nz, .resetOAM

    ; Initialize the player in OAM
    ld hl, wShadowOAM
    ld a, 16 + 16
    ld [hli], a
    ld a, 80 + 8
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a

    ld a, 16 + 16
    ld [hli], a
    ld a, 48 + 8
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

    ; Initialize global variables
    xor a
    ld [wFrameCounter1], a
    ld [wCurKeys1], a
    ld [wCurKeys2], a
    ld [wInverseVelocity1], a
    ld [wGravityCounter1], a
    ld [wSpriteChangeTimer1], a
    ld [wOriginalTile1], a
    ld [wSpeedCounter1], a
    ld [wFrameCounter2], a
    ld [wInverseVelocity2], a
    ld [wGravityCounter2], a
    ld [wSpriteChangeTimer2], a
    ld [wOriginalTile2], a
    ld [wSpeedCounter2], a

    ; Enable second joypad input
    call check_sgb

    ld a, P1F_GET_NONE
    ldh [rP1], a

Main:
    call ResetShadowOAM

    ; Check the current keys every frame.
    call UpdateKeys

    ld de, wShadowOAM
    call UpdatePlayer1
    call CheckMovement1
    call UpdateSprite1

    ld de, wShadowOAM+4
    call UpdatePlayer2
    call CheckMovement2
    call UpdateSprite2

    ldh a, [rLY]
	cp 144
	jp nc, Main ;rerun if in vblank
WaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, WaitVBlank2

    ld a, HIGH(wShadowOAM)
    call hOAMDMA

    jp Main

; Update the player's position based on their velocity
; @param de address in OAM
UpdatePlayer1:
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    jp nz, InAir1
    ; Set velocity to 0 if on ground
    ld a, [wPlayerDirection1]
    cp a, 0
    ret nz
InAir1:
    ld a, [wInverseVelocity1]
    cp a, 0
    jp nz, NonZeroVelocity1
    ld a, 4
    ld [wInverseVelocity1], a
    ld a, 1
    ld [wPlayerDirection1], a
NonZeroVelocity1:
    ld a, [wInverseVelocity1]
    ld b, a
    ld a, [wFrameCounter1]
    inc a
    cp a, b
    jp z, UpdatePosition1
    ld [wFrameCounter1], a
    ret
UpdatePosition1:
    xor a
    ld [wFrameCounter1], a
    ld a, [wPlayerDirection1]
    cp a, 0
    jp z, MovesUp1
    ld a, [wInverseVelocity1]
    cp a, 1
    jp z, MaximumVelocity1
    ; Check if gravity counter is correct
    ld a, [wGravityCounter1]
    inc a
    ld [wGravityCounter1], a
    ld b, a
    ld a, [wInverseVelocity1]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    jp nz, MaximumVelocity1
    xor a
    ld [wGravityCounter1], a
    ; Apply gravity
    ld a, [wInverseVelocity1]
    dec a
    ld [wInverseVelocity1], a
MaximumVelocity1:
    ; Move down
    ld h, d
    ld l, e
    ld a, [hl]
    add a, 2
    ld c, a
    ld [hli], a
    ld a, [hl]
    ld b, a
    ; Check if player hits ground
    call IsGrounded
    jp z, HitsGround1
    ret
HitsGround1:
    xor a
    ld [wInverseVelocity1], a
    ld [wFrameCounter1], a
    ld [wGravityCounter1], a
    ret
MovesUp1:
    ; Move up
    ld h, d
    ld l, e
    ld a, [hl]
    sub a, 2
    ld [hl], a
    ; Update velocity
    ld a, [wInverseVelocity1]
    cp a, 4
    jp z, HitsCeiling1
    ; Check if gravity counter is correct
    ld a, [wGravityCounter1]
    inc a
    ld [wGravityCounter1], a
    ld b, a
    ld a, [wInverseVelocity1]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    ret nz
ApplyGravity1:
    xor a
    ld [wGravityCounter1], a
    ; Apply gravity
    ld a, [wInverseVelocity1]
    inc a
    ld [wInverseVelocity1], a
    ret
HitsCeiling1:
    xor a
    ld [wInverseVelocity1], a
    ret

; Move if an arrow key was pressed
CheckMovement1:

; Check the left button.
CheckLeft1:
    ld a, [wCurKeys1]
    and a, PADF_LEFT
    jp z, CheckRight1
Left1:
    ; Set the horizontal flip flag (bit 5) in the sprite attributes
    ld hl, 3
    add hl, de
    ld a, [hl]
    or a, %00100000  ; Set horizontal flip bit (bit 5)
    ld [hl], a

    ; Check the player speed
    ld a, [wSpeedCounter1]
    inc a
    ld [wSpeedCounter1], a
    cp a, 2
    jp nz, CheckUp1
    xor a
    ld [wSpeedCounter1], a
    ; Move the player one pixel to the left.
    ld hl, 1
    add hl, de
    ld a, [hl]
    dec a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 0 + 7
    jp z, CheckUp1
    ld a, [hl]
    dec a
    ld [hl], a
    jp CheckUp1

; Check the right button.
CheckRight1:
    ld a, [wCurKeys1]
    and a, PADF_RIGHT
    jp z, CheckUp1
Right1:
    ; Clear the horizontal flip flag (bit 5) in the sprite attributes
    ld hl, 3
    add hl, de
    ld a, [hl]
    and a, %11011111  ; Clear horizontal flip bit (bit 5)
    ld [hl], a

    ; Check the player speed
    ld a, [wSpeedCounter1]
    inc a
    ld [wSpeedCounter1], a
    cp a, 2
    jp nz, CheckUp1
    xor a
    ld [wSpeedCounter1], a
    ; Move the player one pixel to the right.
    ld hl, 1
    add hl, de
    ld a, [hl]
    inc a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 161
    jp z, CheckUp1
    ld a, [hl]
    inc a
    ld [hl], a
    jp CheckUp1

; Check the up button.
CheckUp1:
    ld a, [wCurKeys1]
    and a, PADF_UP
    jp z, CheckDown1
Up1:
    ; Jump if on the ground
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    ret nz
    xor a
    ld [wPlayerDirection1], a
    ld [wFrameCounter1], a
    ld [wGravityCounter1], a
    ld a, 1
    ld [wInverseVelocity1], a
    ret

; Check the down button.
CheckDown1:
    ld a, [wCurKeys1]
    and a, PADF_DOWN
    ret z
Down1:
    ; Move down if on the ground
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    ret nz
    ld h, d
    ld l, e
    ld a, [hl]
    add a, 2
    ld [hl], a
    ret

; When A is pressed, toggle between default sprite (tile 0) and attack sprite (tile 2)
; After half a second, it will automatically switch back
CheckA1:
    ; First check if the timer is already active
    ld a, [wSpriteChangeTimer1]   ; Check if timer is active
    cp a, 0
    jp nz, DecrementAttackTimer1        ; If timer is not 0, just decrement it
    
    ; Timer is 0, check if A was pressed
    ld a, [wCurKeys1]             ; Load the current keys state
    and a, PADF_A                ; Check if A button is pressed (S on keyboard)
    ret z                        ; Return if A is not pressed
    
    ; A was pressed and timer is 0, switch to attack sprite
    jp SetAttackSprite1           ; Switch to attack sprite and start the timer

DecrementAttackTimer1:
    ; Timer is active, decrement it regardless of button state
    ld a, [wSpriteChangeTimer1]
    dec a                        ; Decrement timer
    ld [wSpriteChangeTimer1], a
    
    ; If timer reached 0, switch back to default sprite
    cp a, 0
    ret nz                       ; Return if timer is not yet 0
    
    ; Timer reached 0, switch back to default sprite
    jp SetDefaultSprite1
    
; Switch to attack tile (tile 2)
SetAttackSprite1:
    ld a, 1
    ld [wOriginalTile1], a        ; Mark that we're using the attack tile
    ld h, d            ; Point to OAM data for the sprite
    ld l, e
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    ld a, 2                      ; Set tile ID to 2 (attack sprite)
    ld [hli], a
    ld a, [hl]       ; Preserve the original attributes (flip flags, etc.)
    ld [hli], a
    
    ; Set timer for how long to display the attack sprite
    ; 30 frames ≈ 0.5 seconds at 60fps
    ld a, 60
    ld [wSpriteChangeTimer1], a
    ret

; Switch back to default tile (0)
SetDefaultSprite1:
    xor a
    ld [wOriginalTile1], a        ; Mark that we're using the default tile
    ld h, d            ; Point to OAM data for the sprite
    ld l, e
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    xor a                        ; Set tile ID to 0 (default sprite)
    ld [hli], a
    ret

; Update the player's position based on their velocity
; @param de address in OAM
UpdatePlayer2:
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    jp nz, InAir2
    ; Set velocity to 0 if on ground
    ld a, [wPlayerDirection2]
    cp a, 0
    ret nz
InAir2:
    ld a, [wInverseVelocity2]
    cp a, 0
    jp nz, NonZeroVelocity2
    ld a, 4
    ld [wInverseVelocity2], a
    ld a, 1
    ld [wPlayerDirection2], a
NonZeroVelocity2:
    ld a, [wInverseVelocity2]
    ld b, a
    ld a, [wFrameCounter2]
    inc a
    cp a, b
    jp z, UpdatePosition2
    ld [wFrameCounter2], a
    ret
UpdatePosition2:
    xor a
    ld [wFrameCounter2], a
    ld a, [wPlayerDirection2]
    cp a, 0
    jp z, MovesUp2
    ld a, [wInverseVelocity2]
    cp a, 1
    jp z, MaximumVelocity2
    ; Check if gravity counter is correct
    ld a, [wGravityCounter2]
    inc a
    ld [wGravityCounter2], a
    ld b, a
    ld a, [wInverseVelocity2]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    jp nz, MaximumVelocity2
    xor a
    ld [wGravityCounter2], a
    ; Apply gravity
    ld a, [wInverseVelocity2]
    dec a
    ld [wInverseVelocity2], a
MaximumVelocity2:
    ; Move down
    ld h, d
    ld l, e
    ld a, [hl]
    add a, 2
    ld c, a
    ld [hli], a
    ld a, [hl]
    ld b, a
    ; Check if player hits ground
    call IsGrounded
    jp z, HitsGround2
    ret
HitsGround2:
    xor a
    ld [wInverseVelocity2], a
    ld [wFrameCounter2], a
    ld [wGravityCounter2], a
    ret
MovesUp2:
    ; Move up
    ld h, d
    ld l, e
    ld a, [hl]
    sub a, 2
    ld [hl], a
    ; Update velocity
    ld a, [wInverseVelocity2]
    cp a, 4
    jp z, HitsCeiling2
    ; Check if gravity counter is correct
    ld a, [wGravityCounter2]
    inc a
    ld [wGravityCounter2], a
    ld b, a
    ld a, [wInverseVelocity2]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    ret nz
ApplyGravity2:
    xor a
    ld [wGravityCounter2], a
    ; Apply gravity
    ld a, [wInverseVelocity2]
    inc a
    ld [wInverseVelocity2], a
    ret
HitsCeiling2:
    xor a
    ld [wInverseVelocity2], a
    ret

; Move if an arrow key was pressed
CheckMovement2:

; Check the left button.
CheckLeft2:
    ld a, [wCurKeys2]
    and a, PADF_LEFT
    jp z, CheckRight2
Left2:
    ; Set the horizontal flip flag (bit 5) in the sprite attributes
    ld hl, 3
    add hl, de
    ld a, [hl]
    or a, %00100000  ; Set horizontal flip bit (bit 5)
    ld [hl], a

    ; Check the player speed
    ld a, [wSpeedCounter2]
    inc a
    ld [wSpeedCounter2], a
    cp a, 2
    jp nz, CheckUp2
    xor a
    ld [wSpeedCounter2], a
    ; Move the player one pixel to the left.
    ld hl, 1
    add hl, de
    ld a, [hl]
    dec a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 0 + 7
    jp z, CheckUp2
    ld a, [hl]
    dec a
    ld [hl], a
    jp CheckUp2

; Check the right button.
CheckRight2:
    ld a, [wCurKeys2]
    and a, PADF_RIGHT
    jp z, CheckUp2
Right2:
    ; Clear the horizontal flip flag (bit 5) in the sprite attributes
    ld hl, 3
    add hl, de
    ld a, [hl]
    and a, %11011111  ; Clear horizontal flip bit (bit 5)
    ld [hl], a

    ; Check the player speed
    ld a, [wSpeedCounter2]
    inc a
    ld [wSpeedCounter2], a
    cp a, 2
    jp nz, CheckUp2
    xor a
    ld [wSpeedCounter2], a
    ; Move the player one pixel to the right.
    ld hl, 1
    add hl, de
    ld a, [hl]
    inc a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 161
    jp z, CheckUp2
    ld a, [hl]
    inc a
    ld [hl], a
    jp CheckUp2

; Check the up button.
CheckUp2:
    ld a, [wCurKeys2]
    and a, PADF_UP
    jp z, CheckDown2
Up2:
    ; Jump if on the ground
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    ret nz
    xor a
    ld [wPlayerDirection2], a
    ld [wFrameCounter2], a
    ld [wGravityCounter2], a
    ld a, 1
    ld [wInverseVelocity2], a
    ret

; Check the down button.
CheckDown2:
    ld a, [wCurKeys2]
    and a, PADF_DOWN
    ret z
Down2:
    ; Move down if on the ground
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsGrounded
    ret nz
    ld h, d
    ld l, e
    ld a, [hl]
    add a, 2
    ld [hl], a
    ret

; When A is pressed, toggle between default sprite (tile 0) and attack sprite (tile 2)
; After half a second, it will automatically switch back
CheckA2:
    ; First check if the timer is already active
    ld a, [wSpriteChangeTimer2]   ; Check if timer is active
    cp a, 0
    jp nz, DecrementAttackTimer2        ; If timer is not 0, just decrement it
    
    ; Timer is 0, check if A was pressed
    ld a, [wCurKeys2]             ; Load the current keys state
    and a, PADF_A                ; Check if A button is pressed (S on keyboard)
    ret z                        ; Return if A is not pressed
    
    ; A was pressed and timer is 0, switch to attack sprite
    jp SetAttackSprite2           ; Switch to attack sprite and start the timer

DecrementAttackTimer2:
    ; Timer is active, decrement it regardless of button state
    ld a, [wSpriteChangeTimer2]
    dec a                        ; Decrement timer
    ld [wSpriteChangeTimer2], a
    
    ; If timer reached 0, switch back to default sprite
    cp a, 0
    ret nz                       ; Return if timer is not yet 0
    
    ; Timer reached 0, switch back to default sprite
    jp SetDefaultSprite2
    
; Switch to attack tile (tile 2)
SetAttackSprite2:
    ld a, 1
    ld [wOriginalTile2], a        ; Mark that we're using the attack tile
    ld h, d            ; Point to OAM data for the sprite
    ld l, e
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    ld a, 2                      ; Set tile ID to 2 (attack sprite)
    ld [hli], a
    ld a, [hl]       ; Preserve the original attributes (flip flags, etc.)
    ld [hli], a
    
    ; Set timer for how long to display the attack sprite
    ; 30 frames ≈ 0.5 seconds at 60fps
    ld a, 60
    ld [wSpriteChangeTimer2], a
    ret

; Switch back to default tile (0)
SetDefaultSprite2:
    xor a
    ld [wOriginalTile2], a        ; Mark that we're using the default tile
    ld h, d            ; Point to OAM data for the sprite
    ld l, e
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    xor a                        ; Set tile ID to 0 (default sprite)
    ld [hli], a
    ret

; Check if player is on the ground
; @param b: X (bottom right)
; @param c: Y (bottom right)
; @return z: set if grounded
IsGrounded:
    ; Check bottom right
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z

    ; Check bottom middle
    ld a, b
    sub a, 4
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z

    ; Check bottom left
    ld a, b
    sub a, 4
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile

    ret

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

    ; Combine with previous wCurKeys to make wNewKeys
    ld a, [wCurKeys1]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [wNewKeys1], a
    ld a, b
    ld [wCurKeys1], a

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
    ld a, [wCurKeys2]
    xor a, b ; A = keys that changed state
    and a, b ; A = keys that changed to pressed
    ld [wNewKeys2], a
    ld a, b
    ld [wCurKeys2], a
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

; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
GetTileByPixel:
    ld a, c
    and a, %111
    cp a, 0
    jp z, ContinueCalc
    cp a, 1
    jp z, ContinueCalc
    ld hl, 0
    ret
ContinueCalc:
    ; First, we need to divide by 8 to convert a pixel position to a tile position.
    ; After this we want to multiply the Y position by 32.
    ; These operations effectively cancel out so we only need to mask the Y value.
    ld a, c
    and a, %11111000
    ld l, a
    ld h, 0
    ; Now we have the position * 8 in hl
    add hl, hl ; position * 16
    add hl, hl ; position * 32
    ; Convert the X position to an offset.
    ld a, b
    srl a ; a / 2
    srl a ; a / 4
    srl a ; a / 8
    ; Add the two offsets together.
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Add the offset to the tilemap's base address, and we are done!
    push bc
    ld bc, $9800
    add hl, bc
    pop bc
    ret

; @param a: tile ID
; @return z: set if a is a wall.
IsWallTile:
    ; top platform
    cp a, $40
    ret z
    cp a, $41
    ret z
    cp a, $42
    ret z
    ; left platform
    cp a, $68
    ret z
    cp a, $69
    ret z
    cp a, $6A
    ret z
    ; right platform
    cp a, $6D
    ret z
    cp a, $6E
    ret z
    cp a, $6F
    ret z
    ; base platform
    call IsBaseTile
    ret

; @param a: tile ID
; @return z: set if a is a base.
IsBaseTile:
    cp a, $9E
    ret z
    cp a, $9F
    ret z
    cp a, $A0
    ret z
    cp a, $A1
    ret z
    cp a, $A2
    ret z
    cp a, $A3
    ret z
    cp a, $A4
    ret z
    cp a, $A5
    ret z
    cp a, $A6
    ret z
    cp a, $A7
    ret z
    cp a, $A8
    ret z
    cp a, $A9
    ret

UpdateSprite1:
    call CheckA1
    ret

UpdateSprite2:
    call CheckA2
    ret

SECTION "Input Variables", WRAM0
wCurKeys1: db
wNewKeys1: db
wCurKeys2: db
wNewKeys2: db

SECTION "Player 1 Data", WRAM0
wInverseVelocity1: db
wFrameCounter1: db
wPlayerDirection1: db
wGravityCounter1: db
wSpeedCounter1: db
wSpriteChangeTimer1: db  ; Timer for sprite change
wOriginalTile1: db       ; Store the original tile ID

SECTION "Player 2 Data", WRAM0
wInverseVelocity2: db
wFrameCounter2: db
wPlayerDirection2: db
wGravityCounter2: db
wSpeedCounter2: db
wSpriteChangeTimer2: db  ; Timer for sprite change
wOriginalTile2: db       ; Store the original tile ID