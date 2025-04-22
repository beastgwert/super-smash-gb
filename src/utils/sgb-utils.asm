SECTION "SGBUtilsSection", ROM0

; Source: https://gbdev.gg8.se/forums/viewtopic.php?id=225

;; Point hl to SGB command
;; don't interrupt this sequence,
;; e.g. by reading keypad
ld a, [hl] ;; length field in packet header
send_sgb:
and a, $07
ret z
ld b, a
for_length:
push bc
xor a, a
ld [$FF00 + $00], a
ld a, $30
ld [$FF00 + $00], a
ld b, $10 ;; 0x10 bytes per packet
outer:
ld e, $08 ;; 0x08 bits per byte
ldi a, [hl]
ld d, a
inner:
bit 0, d  ;; set P14 or P15 according to current data bit to send
ld a, $10
jr nz, Mystery
ld a, $20
Mystery:
ld [$FF00 + $00], a
ld a, $30
ld [$FF00 + $00], a
rr d
dec e
jr nz, inner
dec b
jr nz, outer
ld a, $20
ld [$FF00 + $00], a
ld a, $30
ld [$FF00 + $00], a
call delay_loop
pop bc
dec b
jr nz, for_length
ret

delay_loop:
ld de, $1B58
loop:
nop
nop
nop
dec de
ld a, d
or a, e
jr nz, loop
ret

check_sgb:
ld hl, MLT_REQ_ON
call send_sgb
call delay_loop
ld a, [$FF00 + $00] ;; read joypad ID
and a, $03
cp a, $03
jr nz, is_sgb ;; should not be joypad 1
;; simulate reading joypad state
;; to get SGB to apply MLT_REQ
ld a, $20      ;; P14 low
ld [$FF00 + $00], a
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
call delay_loop
call delay_loop
ld a, $30      ;; P14, P15 low
ld [$FF00 + $00], a
call delay_loop
call delay_loop
ld a, $10      ;; P15 low
ld [$FF00 + $00], a
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
call delay_loop
call delay_loop
ld a, $30      ;; P14, P15 low
ld [$FF00 + $00], a
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
ld a, [$FF00 + $00]
call delay_loop
call delay_loop
ld a, [$FF00 + $00] ;; read joypad ID
and a, $03
cp a, $03
jr nz, is_sgb ;; should not be 1
call send_mlt_req_off
and a, a
ret
is_sgb:
call send_mlt_req_off
scf
ret

send_mlt_req_off:
ld hl, MLT_REQ_OFF
call send_sgb
jp delay_loop
MLT_REQ_OFF:
db $89, $00, $00, $00, $00, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $00, $00
MLT_REQ_ON:
db $89, $01, $00, $00, $00, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $00, $00