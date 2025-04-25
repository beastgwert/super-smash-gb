INCLUDE "hardware.inc"
; INCLUDE "sub-background.asm"
; INCLUDE "utils/sprobjs_lib.asm"
; INCLUDE "utils/sgb-utils.asm"


; The idea behind this a.i: 

; This is going to be a finite state machine that's going to be 
; developed as a decision tree. 

; At each point in time, the cpu can be in either of the 3 stages: 

; Attacking - If the opponent is in range of the cpu, it attacks
; Chasing - If the opponent is not in the range of the cpu, it chases the cpu
; Defending - If the cpu is falling out of bounds, it tries to get on the platform: 
        

; Specifics on defending: 

; We can let the platform be the box --> if we're outside of this box, we try to come inside

DEF BORDER_X EQU 40
DEF BORDER_Y EQU 98
DEF BORDER_HEIGHT EQU 80
DEF BORDER_WIDTH EQU 98
DEF player_1_y EQU 56
DEF player_1_x EQU 57
DEF player_2_y EQU 60
DEF player_2_x EQU 61

RIGHT_KEY: 
    ld a, [wCurKeys2]
    or a, PADF_RIGHT
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret

LEFT_KEY: 
    ld a, [wCurKeys2]
    or a, PADF_LEFT
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret

UP_KEY: 
    ld a, [wCurKeys2]
    or a, PADF_UP
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret

DOWN_KEY: 
    ld a, [wCurKeys2]
    or a, PADF_DOWN
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret

ATTACK_KEY: 
    ld a, [wCurKeys2]
    or a, PADF_A
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret

DASH_KEY:
    ld a, [wCurKeys2]
    or a, PADF_B
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ret



Defense: 
    xor d ; if d is 1 by the end of this, we have to defend ourself
    ld a, [wShadowOAM + player_2_x]
    cp BORDER_X
    jr c, .out_left
    jr .check_down
    .out_left
        ; We have to go right
        ld d, 1
        call RIGHT_KEY
        call UP_KEY
    .check_down
        ld a, [wShadowOAM + player_2_y]
        cp BORDER_Y
        jr nc, .out_down ; if a is greater than border_y
        jr .check_right
    .out_down
        ld d, 1
        call UP_KEY
    .check_right
        ld a, [wShadowOAM + player_2_x]
        cp BORDER_X + BORDER_WIDTH
        jr nc, .out_right
        jr .check_up
    .out_right
        ld d, 1
        call LEFT_KEY
        call UP_KEY
    .check_up
        ld a, [wShadowOAM + player_2_y]
        cp BORDER_Y - BORDER_HEIGHT
        jr c, .out_up
        jr .finish_comp
    .out_up
        call DOWN_KEY
    .finish_comp
    ld a, d
    cp 1
    ret

ProximityCheck: 
    jr nc, .no_swap
        ; Swap
        ld c, a
        ld a, b
        ld b, c
    .no_swap
    sub a, b
    cp 2
    jr c, .too_close
        ld d, 0
        jr .return
    .too_close
        ld d, 1
    .return
    ret

Attack: 
    ld de, wShadowOAM + player_2_y
    call CheckA2_virtual
    jr c, .perform_attack
        ; check if we can get attacked
        ld de, wShadowOAM + player_1_y
        call CheckA1_virtual
        jr nc, .return
        call DASH_KEY
        .return
        ret
    .perform_attack
        call ATTACK_KEY

HeightDiffCheck: 
    ld a, [wShadowOAM + player_2_y]
    ld b, a
    ld a, [wShadowOAM + player_1_y]
    cp b

    ld d, 0

    jr nc, .no_swap
        ld c, a
        ld a, b
        ld b, c
    .no_swap
    sub a, b
    cp 10
    jr nc, .return
        ld d, 1
    .return 
    ret

Chase: 
    ld de, wShadowOAM + player_2_y
    call CheckA2_virtual
    ret c ; We're in the proximity of hitting -> no need to move

    ld a, [wShadowOAM + player_2_x]
    ld b, a
    ld a, [wShadowOAM + player_1_x]
    cp b

    ; Now we check if we're too close to hitting
    call ProximityCheck

    ld a, [wShadowOAM + player_2_x]
    ld b, a
    ld a, [wShadowOAM + player_1_x]
    cp b

    jr c, .left_wards
        ld a, d
        cp 1
        jr z, .true_left
        .true_right
        call RIGHT_KEY
        jr .check_vertical
    .left_wards
        ld a, d
        cp 1
        jr z, .true_right
        .true_left
        call LEFT_KEY
    .check_vertical


    ld a, [wShadowOAM + player_2_y]
    ld b, a
    ld a, [wShadowOAM + player_1_y]
    cp b

    call HeightDiffCheck

    ld a, d
    cp 1
    ret z

    ld a, [wShadowOAM + player_2_y]
    ld b, a
    ld a, [wShadowOAM + player_1_y]
    cp b

    jr c, .up_wards
        call DOWN_KEY
        ret
    .up_wards
        call UP_KEY
        ret



RepetitionCheck: ; If the cpu is stuck in a position (x axis check)
    ld a, [wShadowOAM + player_2_x]
    srl a
    srl a
    ; srl a
    ld b, a
    ld a, [player_2_last_x]
    srl a
    srl a
    ; srl a
    cp b
    jr nz, .return
        ; Dash
        xor a
        ld [wCurKeys2], a
        ld [wNewKeys2], a
        call DASH_KEY
    .return
    ret

Brain: 
    
    xor a
    ld [wCurKeys2], a
    ld [wNewKeys2], a
    ; First check if we're out of bounds
    call Defense 
    ret z ; Only defend when needed, no chase
    call Chase
    call Attack
    ld a, [call_counter]
    bit 4, a
    jr z, .return
        ; ld a, PADF_UP
        ; ld [wNewKeys2], a
        call RepetitionCheck
        ld a, [wShadowOAM + player_2_x]
        ld [player_2_last_x], a
    .return
    ld hl, call_counter
    inc [hl]
    ret

SECTION "Knowledge", WRAM0
player_2_last_x: db
call_counter: db
