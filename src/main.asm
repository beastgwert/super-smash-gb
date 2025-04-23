INCLUDE "hardware.inc"
INCLUDE "arena-background.asm"
INCLUDE "characters.asm"
INCLUDE "digits.asm"
INCLUDE "utils/sprobjs_lib.asm"
INCLUDE "character-selection.asm"
INCLUDE "utils/sgb-utils.asm"

SECTION "Header", ROM0[$100]

	jp CSSEntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
    call InitSound

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

    call InitializeDigits

    ; Initialize Sprite Object Library.
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
    ld hl, wShadowOAM + 56
    ld a, 56 + 16
    ld [hli], a
    ld a, 112 + 8
    ld [hli], a
    ld a, [CSSselectionState1]
    ld [hli], a
    xor a
    ld [hli], a

    ld a, 56 + 16
    ld [hli], a
    ld a, 56 + 8
    ld [hli], a
    ld a, [CSSselectionState2]
    ld [hli], a
    xor a
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
    ld [wCurKeys1], a
    ld [wCurKeys2], a

    ld [wFrameCounter1], a
    ld [wInverseVelocity1], a
    ld [wGravityCounter1], a
    ld [wSpriteChangeTimer1], a
    ld [wOriginalTile1], a
    ld [wSpeedCounter1], a
    ld [wPlayerStun1], a
    ld [wKBDirection1], a

    ld [wFrameCounter2], a
    ld [wInverseVelocity2], a
    ld [wGravityCounter2], a
    ld [wSpriteChangeTimer2], a
    ld [wOriginalTile2], a
    ld [wSpeedCounter2], a
    ld [wPlayerStun2], a
    ld [wKBDirection2], a

    ld [wPlayer1HP], a
    ld [wPlayer2HP], a
    ld [wPlayer1HPTens], a
    ld [wPlayer1HPOnes], a
    ld [wPlayer2HPTens], a
    ld [wPlayer2HPOnes], a

    ld a, 16
    ld [wPlayerHitbox1], a
    ld [wPlayerHitbox2], a

    ld a, 3
    ld [wPlayerLives1], a
    ld [wPlayerLives2], a

    call SetPlayer1Stats
    call SetPlayer2Stats

Main:
    call ResetShadowOAM

    ; Check the current keys every frame.
    call UpdateKeys

    ld de, wShadowOAM+56
    call UpdatePlayer1
    call CheckMovement1
    call UpdateSprite1

    ld de, wShadowOAM+60
    call UpdatePlayer2
    call CheckMovement2
    call UpdateSprite2

    call UpdatePlayerIndicators
    call UpdateHPDisplay
    call UpdateLivesDisplay

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

; Set player stats
SetPlayer1Stats:
    ld a, [CSSselectionState1]
    cp a, 0
    jp z, Krill1
    cp a, 4
    jp z, Omkar1
    cp a, 8
    jp z, Caleb1
    cp a, 12
    jp z, Michael1
Neil1:
    ld a, 10
    ld [wPlayer1AttackMin], a
    ld a, 4
    ld [wPlayer1AttackRange], a
    ld a, 2
    ld [wPlayer1Defense], a
    ld a, 1
    ld [wPlayer1Speed], a
    ret
Krill1:
    ld a, 30
    ld [wPlayer1AttackMin], a
    ld a, 32
    ld [wPlayer1AttackRange], a
    ld a, 0
    ld [wPlayer1Defense], a
    ld a, 5
    ld [wPlayer1Speed], a
    ret
Omkar1:
    ld a, 20
    ld [wPlayer1AttackMin], a
    ld a, 8
    ld [wPlayer1AttackRange], a
    ld a, 1
    ld [wPlayer1Defense], a
    ld a, 2
    ld [wPlayer1Speed], a
    ret
Caleb1:
    ld a, 6
    ld [wPlayer1AttackMin], a
    ld a, 4
    ld [wPlayer1AttackRange], a
    ld a, 6
    ld [wPlayer1Defense], a
    ld a, 4
    ld [wPlayer1Speed], a
    ret
Michael1:
    ld a, 14
    ld [wPlayer1AttackMin], a
    ld a, 4
    ld [wPlayer1AttackRange], a
    ld a, 3
    ld [wPlayer1Defense], a
    ld a, 3
    ld [wPlayer1Speed], a
    ret

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
    ; Check if player falls off screen
    jp c, ResetPlayer1
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

; Reset player when they lose a life
ResetPlayer1:
    ld a, [wPlayerLives1]
    dec a
    jp z, CSSEntryPoint
    ld [wPlayerLives1], a
    ld h, d
    ld l, e
    ld a, 0
    ld [hli], a
    ld [hl], 80 + 8
    xor a
    ld [wPlayer1HP], a
    ld [wFrameCounter1], a
    ld [wInverseVelocity1], a
    ld [wGravityCounter1], a
    ld [wSpriteChangeTimer1], a
    ld [wOriginalTile1], a
    ld [wSpeedCounter1], a
    ret

; Move if an arrow key was pressed
CheckMovement1:

; Check stun
ld a, [wPlayerStun1]
cp a, 0
jp z, CheckLeft1
dec a
ld [wPlayerStun1], a
ld hl, 1
add hl, de
ld a, [hl]
ld b, a
ld a, [wKBDirection1]
add a, b
ld [hl], a
ret

; Check the left button.
CheckLeft1:
    ld a, [wCurKeys1]
    and a, PADF_LEFT
    jp z, CheckRight1
Left1:
    ; Check if already facing left
    ld hl, 3
    add hl, de
    ld a, [hl]
    bit 5, a  ; Check if horizontal flip bit is already set
    jr nz, .alreadyFacingLeft
    
    ; If not already facing left, set the horizontal flip flag and adjust position
    or a, %00100000  ; Set horizontal flip bit (bit 5)
    ld [hl], a
    
    ; Adjust X position to account for sprite flip (move 4 pixels left)
    ld hl, 1
    add hl, de
    ld a, [hl]
    sub a, 4  ; Subtract 4 from X position
    ld [hl], a
    
.alreadyFacingLeft:
    ; Check the player speed
    ld a, [wSpeedCounter1]
    inc a
    ld [wSpeedCounter1], a
    ld b, a
    ld a, [wPlayer1Speed]
    cp a, b
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
    ; Check if already facing right
    ld hl, 3
    add hl, de
    ld a, [hl]
    bit 5, a  ; Check if horizontal flip bit is set
    jr z, .alreadyFacingRight
    
    ; If not already facing right, clear the horizontal flip flag and adjust position
    and a, %11011111  ; Clear horizontal flip bit (bit 5)
    ld [hl], a
    
    ; Adjust X position to account for sprite flip (move 4 pixels right)
    ld hl, 1
    add hl, de
    ld a, [hl]
    add a, 4  ; Add 4 to X position
    ld [hl], a
    
.alreadyFacingRight:
    ; Check the player speed
    ld a, [wSpeedCounter1]
    inc a
    ld [wSpeedCounter1], a
    ld b, a
    ld a, [wPlayer1Speed]
    cp a, b
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
    ; Do not move down if on the base tile
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsBased
    ret z
    ld h, d
    ld l, e
    ld a, [hl]
    add a, 2
    ld [hl], a
    ret

; When A is pressed, toggle between default sprite (tile 0) and attack sprite (tile 2)
CheckA1:
    ; First check if the timer is already active
    ld a, [wSpriteChangeTimer1]   ; Check if timer is active
    cp a, 0
    jp nz, DecrementAttackTimer1        ; If timer is not 0, just decrement it
    
    ; Timer is 0, check if A was pressed
    ld a, [wCurKeys1]             ; Load the current keys state
    and a, PADF_A                ; Check if A button is pressed (S on keyboard)
    ret z                        ; Return if A is not pressed
    
; Check attack
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, 8
    sub a, c
    ld c, a
    ld a, [hl]
    ld b, 3
    sub a, b
    ld b, a
    ; Check direction
    ld hl, 3
    add hl, de
    ld a, [hl]
    cp a, 0
    jp nz, FacesLeft1
    ; Faces right
    ld a, 6
    add a, b
    ld b, a
    ld a, 1
    ld [wKBDirection2], a
    jp CheckHit1
FacesLeft1:
    ld a, -1
    ld [wKBDirection2], a
CheckHit1:
    call HitsPlayer2
    jp nc, SetAttackSprite1

    ; Perform attack
    call CalculatePlayer1Attack
    ld a, [wPlayer2HP]
    add a, b
    cp a, 100
    jp c, NoOverflow1
    ld a, 99
NoOverflow1:
    ld [wPlayer2HP], a

    ; Apply knockback
    ld [wPlayerStun2], a
    xor a
    ld [wPlayerDirection2], a
    ld [wFrameCounter2], a
    ld [wGravityCounter2], a
    ld a, 1
    ld [wInverseVelocity2], a

    call PlayerHitSound

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
    ld a, [CSSselectionState1]
    add a, 2                      ; Set tile ID to 2 (attack sprite)
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
    ld a, [CSSselectionState1]                        ; Set tile ID to 0 (default sprite)
    ld [hli], a
    ret

; Check if a pixel intersects with player's hitbox
; @param b: pixel X
; @param c: pixel Y
; @return c (flag): set if player is hit
HitsPlayer1:
    ; check right X >= pixel X
    ld a, [wShadowOAM+57]
    cp a, b
    ccf
    ret nc
    ; check left X < pixel X
    sub a, 8
    cp a, b
    ret nc
    ; check bottom Y >= pixel Y
    ld a, [wShadowOAM+56]
    cp a, c
    ccf
    ret nc
    ; check top Y < pixel Y
    ld h, a
    ld a, [wPlayerHitbox1]
    ld b, a
    ld a, h
    sub a, b
    cp a, c
    ret

; @return b: damage inflicted
CalculatePlayer1Attack:
    ; Get random number in range
    call rand
    ld a, [wPlayer1AttackRange]
    dec a
    ld b, a
    ld a, c
    and a, b
    ld b, a
    ; Add to min attack
    ld a, [wPlayer1AttackMin]
    add a, b
    ld b, a
    ld c, a
    ; Apply defense
    ld a, [wPlayer2Defense]
    srl c
    bit 2, a
    jp z, NoDef501
    ; Subtract 1/2
    ld h, a
    ld a, b
    sub a, c
    ld b, a
    ld a, h
NoDef501:
    srl c
    bit 1, a
    jp z, NoDef251
    ; Subtract 1/4
    ld h, a
    ld a, b
    sub a, c
    ld b, a
    ld a, h
NoDef251:
    srl c
    bit 0, a
    ret z
    ; Subtract 1/8
    ld a, b
    sub a, c
    ld b, a
    ret

; Set player stats
SetPlayer2Stats:
    ld a, [CSSselectionState2]
    cp a, 0
    jp z, Krill2
    cp a, 4
    jp z, Omkar2
    cp a, 8
    jp z, Caleb2
    cp a, 12
    jp z, Michael2
Neil2:
    ld a, 10
    ld [wPlayer2AttackMin], a
    ld a, 4
    ld [wPlayer2AttackRange], a
    ld a, 2
    ld [wPlayer2Defense], a
    ld a, 1
    ld [wPlayer2Speed], a
    ret
Krill2:
    ld a, 30
    ld [wPlayer2AttackMin], a
    ld a, 32
    ld [wPlayer2AttackRange], a
    ld a, 0
    ld [wPlayer2Defense], a
    ld a, 5
    ld [wPlayer2Speed], a
    ret
Omkar2:
    ld a, 20
    ld [wPlayer2AttackMin], a
    ld a, 8
    ld [wPlayer2AttackRange], a
    ld a, 1
    ld [wPlayer2Defense], a
    ld a, 2
    ld [wPlayer2Speed], a
    ret
Caleb2:
    ld a, 6
    ld [wPlayer2AttackMin], a
    ld a, 4
    ld [wPlayer2AttackRange], a
    ld a, 6
    ld [wPlayer2Defense], a
    ld a, 4
    ld [wPlayer2Speed], a
    ret
Michael2:
    ld a, 14
    ld [wPlayer2AttackMin], a
    ld a, 4
    ld [wPlayer2AttackRange], a
    ld a, 3
    ld [wPlayer2Defense], a
    ld a, 3
    ld [wPlayer2Speed], a
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
    ; Check if player falls off screen
    jp c, ResetPlayer2
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

; Reset player when they lose a life
ResetPlayer2:
    ld a, [wPlayerLives2]
    dec a
    jp z, CSSEntryPoint
    ld [wPlayerLives2], a
    ld h, d
    ld l, e
    ld a, 0
    ld [hli], a
    ld [hl], 80 + 8
    xor a
    ld [wPlayer2HP], a
    ld [wFrameCounter2], a
    ld [wInverseVelocity2], a
    ld [wGravityCounter2], a
    ld [wSpriteChangeTimer2], a
    ld [wOriginalTile2], a
    ld [wSpeedCounter2], a
    ret

; Move if an arrow key was pressed
CheckMovement2:

; Check stun
ld a, [wPlayerStun2]
cp a, 0
jp z, CheckLeft2
dec a
ld [wPlayerStun2], a
ld hl, 1
add hl, de
ld a, [hl]
ld b, a
ld a, [wKBDirection2]
add a, b
ld [hl], a
ret

; Check the left button.
CheckLeft2:
    ld a, [wCurKeys2]
    and a, PADF_LEFT
    jp z, CheckRight2
Left2:
    ; Check if already facing left
    ld hl, 3
    add hl, de
    ld a, [hl]
    bit 5, a  ; Check if horizontal flip bit is already set
    jr nz, .alreadyFacingLeft
    
    ; If not already facing left, set the horizontal flip flag and adjust position
    or a, %00100000  ; Set horizontal flip bit (bit 5)
    ld [hl], a
    
    ; Adjust X position to account for sprite flip (move 4 pixels left)
    ld hl, 1
    add hl, de
    ld a, [hl]
    sub a, 4  ; Subtract 4 from X position
    ld [hl], a
    
.alreadyFacingLeft:
    ; Check the player speed
    ld a, [wSpeedCounter2]
    inc a
    ld [wSpeedCounter2], a
    ld b, a
    ld a, [wPlayer2Speed]
    cp a, b
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
    ; Check if already facing right
    ld hl, 3
    add hl, de
    ld a, [hl]
    bit 5, a  ; Check if horizontal flip bit is set
    jr z, .alreadyFacingRight
    
    ; If not already facing right, clear the horizontal flip flag and adjust position
    and a, %11011111  ; Clear horizontal flip bit (bit 5)
    ld [hl], a
    
    ; Adjust X position to account for sprite flip (move 4 pixels right)
    ld hl, 1
    add hl, de
    ld a, [hl]
    add a, 4  ; Add 4 to X position
    ld [hl], a
    
.alreadyFacingRight:
    ; Check the player speed
    ld a, [wSpeedCounter2]
    inc a
    ld [wSpeedCounter2], a
    ld b, a
    ld a, [wPlayer2Speed]
    cp a, b
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
    ; Do not move down if on the base tile
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a
    call IsBased
    ret z
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
    
    ; Check attack
    ld h, d
    ld l, e
    ld a, [hli]
    ld c, 8
    sub a, c
    ld c, a
    ld a, [hl]
    ld b, 3
    sub a, b
    ld b, a
    ; Check direction
    ld hl, 3
    add hl, de
    ld a, [hl]
    cp a, 0
    jp nz, FacesLeft2
    ; Faces right
    ld a, 6
    add a, b
    ld b, a
    ld a, 1
    ld [wKBDirection1], a
    jp CheckHit2
FacesLeft2:
    ld a, -1
    ld [wKBDirection1], a
CheckHit2:
    call HitsPlayer1
    jp nc, SetAttackSprite2

    ; Perform attack
    call CalculatePlayer2Attack
    ld a, [wPlayer1HP]
    add a, b
    cp a, 100
    jp c, NoOverflow2
    ld a, 99
NoOverflow2:
    ld [wPlayer1HP], a

    ; Apply knockback
    ld [wPlayerStun1], a
    xor a
    ld [wPlayerDirection1], a
    ld [wFrameCounter1], a
    ld [wGravityCounter1], a
    ld a, 1
    ld [wInverseVelocity1], a

    call PlayerHitSound

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
    ld a, [CSSselectionState2]    ; Set tile ID to 2 (attack sprite)
    add a, 2
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
    ld a, [CSSselectionState2]                        ; Set tile ID to 0 (default sprite)
    ld [hli], a
    xor a
    ret

; Check if a pixel intersects with player's hitbox
; @param b: pixel X
; @param c: pixel Y
; @return c (flag): set if player is hit
HitsPlayer2:
    ; check right X >= pixel X
    ld a, [wShadowOAM+61]
    cp a, b
    ccf
    ret nc
    ; check left X < pixel X
    sub a, 8
    cp a, b
    ret nc
    ; check bottom Y >= pixel Y
    ld a, [wShadowOAM+60]
    cp a, c
    ccf
    ret nc
    ; check top Y < pixel Y
    ld h, a
    ld a, [wPlayerHitbox2]
    ld b, a
    ld a, h
    sub a, b
    cp a, c
    ret

; @return b: damage inflicted
CalculatePlayer2Attack:
    ; Get random number in range
    call rand
    ld a, [wPlayer2AttackRange]
    dec a
    ld b, a
    ld a, c
    and a, b
    ld b, a
    ; Add to min attack
    ld a, [wPlayer2AttackMin]
    add a, b
    ld b, a
    ld c, a
    ; Apply defense
    ld a, [wPlayer1Defense]
    srl c
    bit 2, a
    jp z, NoDef502
    ; Subtract 1/2
    ld h, a
    ld a, b
    sub a, c
    ld b, a
    ld a, h
NoDef502:
    srl c
    bit 1, a
    jp z, NoDef252
    ; Subtract 1/4
    ld h, a
    ld a, b
    sub a, c
    ld b, a
    ld a, h
NoDef252:
    srl c
    bit 0, a
    ret z
    ; Subtract 1/8
    ld a, b
    sub a, c
    ld b, a
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

; Check if player is on the base platform
; @param b: X (bottom right)
; @param c: Y (bottom right)
; @return z: set if based
IsBased:
    ; Check bottom right
    call GetTileByPixel
    ld a, [hl]
    call IsBaseTile
    ret z

    ; Check bottom middle
    ld a, b
    sub a, 4
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsBaseTile
    ret z

    ; Check bottom left
    ld a, b
    sub a, 4
    ld b, a
    call GetTileByPixel
    ld a, [hl]
    call IsBaseTile

    ret

transferControls:
    ; Assume data is in register a
    ; ldh [rSB], a -- Commenting this portion out because we're not sending data
    ld a, $81 ; this is 81 beacuse it's the owner, set it to 80 for sub-routine
    ldh [rSC], a
    .waitTransfer
        ldh a, [rSC]
        and $80 ; check if transfer still in progress
        jr nz, .waitTransfer ; wait until done
    ldh a, [rSB]
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
    call transferControls
    ld [wCurKeys2], a
    call transferControls
    ld [wNewKeys2], a
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
    ; Byte at address $014C should always be 0
    ld hl, $014C
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
    ld bc, wShadowBG
    add hl, bc
    pop bc
    ret

; @param a: tile ID
; @return z: set if a is a wall.
IsWallTile:
    ; top platform
    cp a, $53
    ret z
    cp a, $54
    ret z
    ; left platform
    cp a, $7C
    ret z
    cp a, $7D
    ret z
    cp a, $7E
    ret z
    cp a, $7F
    ret z
    ; right platform
    cp a, $81
    ret z
    cp a, $82
    ret z
    cp a, $83
    ret z
    cp a, $84
    ret z
    ; base platform
    call IsBaseTile
    ret

; @param a: tile ID
; @return z: set if a is a base.
IsBaseTile:
    cp a, $B2
    ret z
    cp a, $B3
    ret z
    cp a, $B4
    ret z
    cp a, $B5
    ret z
    cp a, $B6
    ret z
    cp a, $B7
    ret z
    cp a, $B8
    ret z
    cp a, $B9
    ret z
    cp a, $BA
    ret z
    cp a, $BB
    ret z
    cp a, $BC
    ret z
    cp a, $BD
    ret 

UpdateSprite1:
    call CheckA1
    ret

UpdateSprite2:
    call CheckA2
    ret

UpdatePlayerIndicators:
    ; Player 1 indicator (at wShadowOAM + 48)
    ld hl, wShadowOAM+56      ; Player 1's OAM data
    ld a, [hli]            ; Get player 1's Y position
    sub a, 8               ; Position indicator 8 pixels above player
    ld b, a                ; Store Y position in B
    ld a, [hli]            ; Get player 1's X position
    ld c, a                ; Store X position in C
    
    ; Check if player 1 is flipped horizontally
    ld a, [hl]             ; Get player 1's tile number (skip)
    inc hl
    ld a, [hl]             ; Get player 1's attributes
    bit 5, a               ; Check horizontal flip bit
    jr z, .player1NotFlipped
    
    ; If player 1 is flipped, adjust indicator X position
    ld a, c
    add a, 4               ; Add 4 to X position to match the player's visual position
    ld c, a
    
.player1NotFlipped:
    ; Set player 1 indicator position and tile
    ld hl, wShadowOAM + 48 ; Player 1 indicator OAM data
    ld a, b                ; Y position
    ld [hli], a
    ld a, c                ; X position
    ld [hli], a
    ld a, 42               ; Tile number for player 1 indicator
    ld [hli], a
    xor a                  ; No attributes (no flip, etc.)
    ld [hli], a
    
    ; Player 2 indicator (at wShadowOAM + 52)
    ld hl, wShadowOAM + 60  ; Player 2's OAM data
    ld a, [hli]            ; Get player 2's Y position
    sub a, 8               ; Position indicator 8 pixels above player
    ld b, a                ; Store Y position in B
    ld a, [hli]            ; Get player 2's X position
    ld c, a                ; Store X position in C
    
    ; Check if player 2 is flipped horizontally
    ld a, [hl]             ; Get player 2's tile number (skip)
    inc hl
    ld a, [hl]             ; Get player 2's attributes
    bit 5, a               ; Check horizontal flip bit
    jr z, .player2NotFlipped
    
    ; If player 2 is flipped, adjust indicator X position
    ld a, c
    add a, 4               ; Add 4 to X position to match the player's visual position
    ld c, a
    
.player2NotFlipped:
    ld a, c
    sub a, 1               
    ld c, a
    
    ; Set player 2 indicator position and tile
    ld hl, wShadowOAM + 52 ; Player 2 indicator OAM data
    ld a, b                ; Y position
    ld [hli], a
    ld a, c                ; X position
    ld [hli], a
    ld a, 44               ; Tile number for player 2 indicator
    ld [hli], a
    xor a                  ; No attributes (no flip, etc.)
    ld [hl], a
    
    ret

; Update HP display for both players
UpdateHPDisplay::
    ; Convert Player 1 HP to digits
    ld a, [wPlayer1HP]
    ld hl, wPlayer1HPTens
    ld de, wPlayer1HPOnes
    call ConvertHPToDigits
    
    ; Convert Player 2 HP to digits
    ld a, [wPlayer2HP]
    ld hl, wPlayer2HPTens
    ld de, wPlayer2HPOnes
    call ConvertHPToDigits
    
    ; Find the next available OAM slots for HP digits (after the player sprites)
    ld hl, wShadowOAM + 8  ; Player 1 uses slots 0-3, Player 2 uses slots 4-7
    
    ; Display Player 1 HP (tens digit)
    ; Y position
    ld a, 16 + 137
    ld [hli], a
    ; X position
    ld a, 8 + 48
    ld [hli], a
    ; Tile number (0 = tile 20, 1 = tile 22, etc.)
    ld a, [wPlayer1HPTens]
    add a, a       ; Multiply by 2
    add a, 20      ; Add base tile number
    ld [hli], a
    ; Attributes (palette, flip, etc.)
    xor a
    ld [hli], a
    
    ; Display Player 1 HP (ones digit)
    ; Y position
    ld a, 16 + 137
    ld [hli], a
    ; X position
    ld a, 8 + 56       ; 8 pixels to the right of tens digit
    ld [hli], a
    ; Tile number
    ld a, [wPlayer1HPOnes]
    add a, a       ; Multiply by 2
    add a, 20      ; Add base tile number
    ld [hli], a
    ; Attributes
    xor a
    ld [hli], a
    
    ; Display Player 2 HP (tens digit)
    ; Y position
    ld a, 16 + 137
    ld [hli], a
    ; X position
    ld a, 8 + 112
    ld [hli], a
    ; Tile number
    ld a, [wPlayer2HPTens]
    add a, a       ; Multiply by 2
    add a, 20      ; Add base tile number
    ld [hli], a
    ; Attributes
    xor a
    ld [hli], a
    
    ; Display Player 2 HP (ones digit)
    ; Y position
    ld a, 16 + 137
    ld [hli], a
    ; X position
    ld a, 8 + 120      ; 8 pixels to the right of tens digit
    ld [hli], a
    ; Tile number
    ld a, [wPlayer2HPOnes]
    add a, a       ; Multiply by 2
    add a, 20      ; Add base tile number
    ld [hli], a
    ; Attributes
    xor a
    ld [hli], a
    
    ret

; Update lives display for both players
UpdateLivesDisplay::
    ; Reset the position in OAM for the hearts
    ld hl, wShadowOAM + 32
    
    ; Find the next available OAM slots for lives hearts (after the player sprites)
    ld hl, wShadowOAM + 24  ; Player 1 uses slots 0-3, Player 2 uses slots 4-7, HP uses 8-15, Lives use 16-23

    ; Display Player 1 lives (always 3 heart positions)
    ld a, [wPlayerLives1]
    ld b, a        ; Store lives count in b
    ld c, 0        ; Initialize counter

    ; Starting position for Player 1 hearts
    ld de, 14 + 8   ; Starting X coordinate for Player 1 hearts

.displayP1Hearts
    ; Check if we've displayed all 3 heart positions
    ld a, c
    cp 3
    jr z, .displayP2Lives  ; If we've displayed all 3 hearts, move to Player 2

    ; Y position
    ld a, 136 + 16
    ld [hli], a
    
    ; X position
    ld a, e
    ld [hli], a
    
    ; Add 8 pixels for next heart's X position
    ld a, e
    add a, 8
    ld e, a
    
    ; Determine tile number (heart tile is 40, blank tile is 57)
    ld a, c        ; Get current counter
    cp b           ; Compare with lives count
    jr nc, .blankTileP1  ; If counter >= lives, use blank tile
    
    ; Use heart tile
    ld a, 40
    jr .setTileP1
    
.blankTileP1
    ; Use blank tile
    ld a, 57
    
.setTileP1
    ld [hli], a
    
    ; Attributes (palette, flip, etc.)
    xor a
    ld [hli], a
    
    ; Increment counter and continue
    inc c
    jr .displayP1Hearts

.displayP2Lives
    ; Display Player 2 lives (always 3 heart positions)
    ld a, [wPlayerLives2]
    ld b, a        ; Store lives count in b
    ld c, 0        ; Reset counter

    ; Starting position for Player 2 hearts
    ld de, 8 + 78 ; Starting X coordinate for Player 2 hearts

.displayP2Hearts
    ; Check if we've displayed all 3 heart positions
    ld a, c
    cp 3
    jr z, .done    ; If we've displayed all 3 hearts, we're done

    ; Y position
    ld a, 136 + 16
    ld [hli], a
    
    ; X position
    ld a, e
    ld [hli], a
    
    ; Add 8 pixels for next heart's X position
    ld a, e
    add a, 8
    ld e, a
    
    ; Determine tile number (heart tile is 40, blank tile is 57)
    ld a, c        ; Get current counter
    cp b           ; Compare with lives count
    jr nc, .blankTileP2  ; If counter >= lives, use blank tile
    
    ; Use heart tile
    ld a, 40
    jr .setTileP2
    
.blankTileP2
    ; Use blank tile
    ld a, 57
    
.setTileP2
    ld [hli], a
    
    ; Attributes (palette, flip, etc.)
    xor a
    ld [hli], a
    
    ; Increment counter and continue
    inc c
    jr .displayP2Hearts

.done
    ret

; Convert HP value to tens and ones digits
; @param a: HP value (0-99)
; @param hl: Address to store tens digit
; @param de: Address to store ones digit
ConvertHPToDigits:
    ; Save HP value
    ld b, a
    
    ; Calculate tens digit by repeatedly subtracting 10
    ld c, 0
.divLoop
    cp 10
    jr c, .divDone
    sub 10
    inc c
    jr .divLoop
.divDone
    ; c now contains tens digit, a contains ones digit
    ld [hl], c
    ld [de], a
    ret

; Initialize sound
InitSound:
    ; Turn on sound
    ld a, %10000000
    ld [$FF26], a    ; Sound on/off register
    
    ; Set volume
    ld a, %01110111
    ld [$FF24], a    ; Channel control / volume
    
    ; Sound panning
    ld a, %11111111
    ld [$FF25], a    ; Sound output terminal
    ret

PlayerHitSound:
    ; Use noise channel (Channel 4) for the hit sound
    ; Set sound length
    ld a, %00111111  ; Fairly short sound
    ld [$FF20], a
    
    ; Volume envelope (start high, quick decay)
    ld a, %11110010  ; Start at volume 15, decrease at step 2 (faster decay)
    ld [$FF21], a
    
    ; Set noise parameters - lower bits = higher frequency
    ld a, %01110100  ; Medium-high frequency noise with some randomness
    ld [$FF22], a
    
    ; Trigger sound
    ld a, %10000000  ; Trigger bit
    ld [$FF23], a
    
    ; Also add a quick sound on Channel 1 for more impact
    ; No sweep
    ld a, %00000000
    ld [$FF10], a
    
    ; Set duty and length
    ld a, %00111000  ; 75% duty cycle (harsher sound), short length
    ld [$FF11], a
    
    ; Set envelope
    ld a, %11110001  ; Start at volume 15, fast decrease
    ld [$FF12], a
    
    ; Set frequency (lower)
    ld a, %00001000
    ld [$FF13], a
    
    ; Trigger and set upper freq bits
    ld a, %11000110  ; Trigger + don't loop + freq bits
    ld [$FF14], a
    
    ret

SECTION "Input Variables", WRAM0
wCurKeys1: db
wNewKeys1: db
wCurKeys2: db
wNewKeys2: db

SECTION "Player 1 Data", WRAM0
wPlayerDirection1: db
wFrameCounter1: db
wInverseVelocity1: db
wGravityCounter1: db
wSpeedCounter1: db
wSpriteChangeTimer1: db  ; Timer for sprite change
wOriginalTile1: db       ; Store the original tile ID
wPlayerHitbox1: db
wPlayerLives1: db
wPlayerStun1: db
wKBDirection1: db

SECTION "Player 1 Stats", WRAM0
wPlayer1AttackMin: db
wPlayer1AttackRange: db
wPlayer1Defense: db
wPlayer1Speed: db

SECTION "Player 2 Stats", WRAM0
wPlayer2AttackMin: db
wPlayer2AttackRange: db
wPlayer2Defense: db
wPlayer2Speed: db

SECTION "Player 2 Data", WRAM0
wPlayerDirection2: db
wFrameCounter2: db
wInverseVelocity2: db
wGravityCounter2: db
wSpeedCounter2: db
wSpriteChangeTimer2: db  ; Timer for sprite change
wOriginalTile2: db       ; Store the original tile ID
wPlayerHitbox2: db
wPlayerLives2: db
wPlayerStun2: db
wKBDirection2: db

SECTION "HP Data", WRAM0
wPlayer1HP:: db
wPlayer2HP:: db
wPlayer1HPTens:: db
wPlayer1HPOnes:: db
wPlayer2HPTens:: db
wPlayer2HPOnes:: db


SECTION "MathVariables", WRAM0
randstate:: ds 4

SECTION "Math", ROM0

;; From: https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54
; Generates a pseudorandom 16-bit integer in BC
; using the LCG formula from cc65 rand():
; x[i + 1] = x[i] * 0x01010101 + 0xB3B3B3B3
; @return A=B=state bits 31-24 (which have the best entropy),
; C=state bits 23-16, HL trashed
rand::
  ; Add 0xB3 then multiply by 0x01010101
  ld hl, randstate+0
  ld a, [hl]
  add a, $B3
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  ld c, a
  adc a, [hl]
  ld [hl], a
  ld b, a
  ret
