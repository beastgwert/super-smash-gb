INCLUDE "hardware.inc"
INCLUDE "arena-background.asm"
INCLUDE "characters.asm"
INCLUDE "utils/sprobjs_lib.asm"

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
    ld [wFrameCounter], a
    ld [wCurKeys], a
    ld [wNewKeys], a
    ld [wInverseVelocity], a
    ld [wGravityCounter], a
    ld [wSpriteChangeTimer], a
    ld [wOriginalTile], a

Main:
    call ResetShadowOAM

    ; Check the current keys every frame and move left or right.
    call UpdateKeys

    call UpdatePlayer

    call CheckMovement

    ldh a, [rLY]
	cp 144
	jp nc, Main
WaitVBlank2:
	ldh a, [rLY]
	cp 144
	jp c, WaitVBlank2

    ld a, HIGH(wShadowOAM)
    call hOAMDMA

    call UpdateSprite

    jp Main

; Update the player's position based on their velocity
UpdatePlayer:
    ld a, [wShadowOAM+1]
    ld b, a
    ld a, [wShadowOAM]
    ld c, a
    call IsGrounded
    jp nz, InAir
    ; Set velocity to 0 if on ground
    ld a, [wPlayerDirection]
    cp a, 0
    ret nz
InAir:
    ld a, [wInverseVelocity]
    cp a, 0
    jp nz, NonZeroVelocity
    ld a, 4
    ld [wInverseVelocity], a
    ld a, 1
    ld [wPlayerDirection], a
NonZeroVelocity:
    ld a, [wInverseVelocity]
    ld d, a
    ld a, [wFrameCounter]
    inc a
    cp a, d
    jp z, UpdatePosition
    ld [wFrameCounter], a
    ret
UpdatePosition:
    xor a
    ld [wFrameCounter], a
    ld a, [wPlayerDirection]
    cp a, 0
    jp z, MovesUp
    ld a, [wInverseVelocity]
    cp a, 1
    jp z, MaximumVelocity
    ; Check if gravity counter is correct
    ld a, [wGravityCounter]
    inc a
    ld [wGravityCounter], a
    ld b, a
    ld a, [wInverseVelocity]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    jp nz, MaximumVelocity
    xor a
    ld [wGravityCounter], a
    ; Apply gravity
    ld a, [wInverseVelocity]
    dec a
    ld [wInverseVelocity], a
MaximumVelocity:
    ; Move down
    ld a, [wShadowOAM]
    add a, 2
    ld c, a
    ld [wShadowOAM], a
    ld a, [wShadowOAM+1]
    ld b, a
    ; Check if player hits ground
    call IsGrounded
    jp z, HitsGround
    ret
HitsGround:
    xor a
    ld [wInverseVelocity], a
    ld [wFrameCounter], a
    ld [wGravityCounter], a
    ret
MovesUp:
    ld a, [wShadowOAM+1]
    sub a, 8
    ld b, a
    ld a, [wShadowOAM]
    sub a, 16 + 1
    ld c, a
    ; Check if player hits ceiling
    call CheckCollision
    jp z, HitsCeiling
    ; Move up
    ld a, [wShadowOAM]
    sub a, 2
    ld [wShadowOAM], a
    ; Update velocity
    ld a, [wInverseVelocity]
    cp a, 4
    jp z, HitsCeiling
    ; Check if gravity counter is correct
    ld a, [wGravityCounter]
    inc a
    ld [wGravityCounter], a
    ld b, a
    ld a, [wInverseVelocity]
    ld c, a
    ld a, 6
    sub a, c
    cp a, b
    ret nz
ApplyGravity:
    xor a
    ld [wGravityCounter], a
    ; Apply gravity
    ld a, [wInverseVelocity]
    inc a
    ld [wInverseVelocity], a
    ret
HitsCeiling:
    xor a
    ld [wInverseVelocity], a
    ret

; Check if player is on the ground
; @param b: X (bottom right)
; @param c: Y (bottom right)
; @return z: set if grounded
IsGrounded:
    ; Check if it collides with a wall
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z

    ; Check for bottom left corner
    ld a, b
    sub a, 8
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile

    ret

; Move if an arrow key was pressed
CheckMovement:

; Check the left button.
CheckLeft:
    ld a, [wCurKeys]
    and a, PADF_LEFT
    jp z, CheckRight
Left:
    ; Set the horizontal flip flag (bit 5) in the sprite attributes
    ld a, [wShadowOAM + 3]
    or a, %00100000  ; Set horizontal flip bit (bit 5)
    ld [wShadowOAM + 3], a

    ; Move the player one pixel to the left.
    ld a, [wShadowOAM + 1]
    dec a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 0 + 7
    jp z, CheckUp
    ; Check for collision with wall
    sub a, 8
    ld b, a
    ld a, [wShadowOAM]
    sub a, 16
    ld c, a
    call CheckCollision
    jp z, CheckUp
    ld a, [wShadowOAM + 1]
    dec a
    ld [wShadowOAM + 1], a
    jp CheckUp

; Check the right button.
CheckRight:
    ld a, [wCurKeys]
    and a, PADF_RIGHT
    jp z, CheckUp
Right:
    ; Clear the horizontal flip flag (bit 5) in the sprite attributes
    ld a, [wShadowOAM + 3]
    and a, %11011111  ; Clear horizontal flip bit (bit 5)
    ld [wShadowOAM + 3], a

    ; Move the player one pixel to the right.
    ld a, [wShadowOAM + 1]
    inc a
    ; If we've already hit the edge of the playfield, don't move.
    cp a, 161
    jp z, CheckUp
    ; Check for collision with wall
    sub a, 8
    ld b, a
    ld a, [wShadowOAM]
    sub a, 16
    ld c, a
    call CheckCollision
    jp z, CheckUp
    ld a, [wShadowOAM + 1]
    inc a
    ld [wShadowOAM + 1], a
    jp CheckUp

; Check the up button.
CheckUp:
    ld a, [wCurKeys]
    and a, PADF_UP
    ret z
Up:
    ; Jump if on the ground
    ld a, [wShadowOAM+1]
    ld b, a
    ld a, [wShadowOAM]
    ld c, a
    call IsGrounded
    ret nz
    xor a
    ld [wPlayerDirection], a
    ld [wFrameCounter], a
    ld [wGravityCounter], a
    ld a, 1
    ld [wInverseVelocity], a
    ret

; Check the A button.
; When A is pressed, toggle between default sprite (tile 0) and alternate sprite (tile 2)
CheckA:
    ld a, [wCurKeys]     ; Load the current keys state
    and a, PADF_A        ; Check if A button is pressed
    ret z                ; Return if A is not pressed
AButtonPressed:
    ; Handle sprite switching with timer
    ld a, [wSpriteChangeTimer]   ; Check if timer is active
    cp a, 0
    jp z, SwitchSprite           ; If timer is 0, switch the sprite
    dec a                        ; Otherwise, decrement timer
    ld [wSpriteChangeTimer], a
    ret

; Switch between sprite tiles based on current state
SwitchSprite:
    ld a, [wOriginalTile]        ; Check which tile is currently shown
    cp a, 0                      ; Is it the default tile (0)?
    jp z, SetOriginalTile        ; If yes, switch to alternate tile (2)
    
    ; Switch back to default tile (0)
    ld a, 0
    ld [wOriginalTile], a        ; Mark that we're using the default tile
    ld hl, _OAMRAM               ; Point to OAM data for the sprite
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    xor a                        ; Set tile ID to 0 (default sprite)
    ld [hli], a
    ld [hli], a                  ; Set attributes
    jp SetTimer

; Switch to alternate tile (tile 2)
SetOriginalTile:
    ld a, 1
    ld [wOriginalTile], a        ; Mark that we're using the alternate tile
    ld hl, _OAMRAM               ; Point to OAM data for the sprite
    ld a, [hl]                   ; Preserve Y position
    ld [hli], a
    ld a, [hl]                   ; Preserve X position
    ld [hli], a
    ld a, 2                      ; Set tile ID to 2 (alternate sprite)
    ld [hli], a
    ld a, [_OAMRAM + 3]          ; Preserve the original attributes (flip flags, etc.)
    ld [hli], a

; Set the timer for how long to display the current sprite
; Timer decrements each frame (~60fps), so 30 = ~0.5 seconds
SetTimer:
    ld a, 20                     ; Set timer (adjust this value for desired duration)
                                 ; 10 frames ≈ 1/6 second at 60fps
                                 ; For 0.5 seconds, use value 30
    ld [wSpriteChangeTimer], a
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

; Check if a player's bounding box collides with a wall
; @param b: X (upper left)
; @param c: Y (upper left)
; @return z: set if collision
CheckCollision:
    ret
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ld a, b
    add a, 7
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ld a, c
    add a, 8
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ld a, c
    add a, 7
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ld a, b
    sub a, 7
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ld a, c
    sub a, 7
    ld c, a
    call GetTileByPixel
    ld a, [hl]
    call IsWallTile
    ret z
    ret

; Convert a pixel position to a tilemap address
; hl = $9800 + X + Y * 32
; @param b: X
; @param c: Y
; @return hl: tile address
GetTileByPixel:
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
    ld de, $9800
    add hl, de
    ret

; @param a: tile ID
; @return z: set if a is a wall.
IsWallTile:
    ; top platform
    cp a, $30
    ret z
    cp a, $31
    ret z
    cp a, $32
    ret z
    ; left platform
    cp a, $58
    ret z
    cp a, $59
    ret z
    cp a, $5A
    ret z
    ; right platform
    cp a, $5D
    ret z
    cp a, $5E
    ret z
    cp a, $5F
    ret z
    ; base platform
    cp a, $8E
    ret z
    cp a, $8F
    ret z
    cp a, $90
    ret z
    cp a, $91
    ret z
    cp a, $92
    ret z
    cp a, $93
    ret z
    cp a, $94
    ret z
    cp a, $95
    ret z
    cp a, $96
    ret z
    cp a, $97
    ret z
    cp a, $98
    ret z
    cp a, $99
    ret z
    ; cp a, $01
    ret

UpdateSprite:
    call CheckA
    ret

SECTION "Player Tiles", ROM0
Player:
    dw `00333300
    dw `03000030
    dw `03000030
    dw `03000030
    dw `03000030
    dw `00333300
    dw `00033000
    dw `00033000
    dw `00033000
    dw `33333333
    dw `00033000
    dw `00033000
    dw `00033000
    dw `00333300
    dw `03300330
    dw `33000033
PlayerEnd:

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db

SECTION "Player Data", WRAM0
wInverseVelocity: db
wFrameCounter: db
wPlayerDirection: db
wGravityCounter: db
wSpriteChangeTimer: db  ; Timer for sprite change
wOriginalTile: db       ; Store the original tile ID