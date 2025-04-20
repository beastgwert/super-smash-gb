; ANCHOR: memory-utils
SECTION "MemoryUtilsSection", ROM0

; Copy bytes from one area to another.
; @param de: Source
; @param hl: Destination
; @param bc: Length
Memcopy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcopy
    ret

MemcopyOffset152::
    ld a, [de]             ; Load a tile number from our tilemap
    add a, 16             ; Add the offset (152 decimal = $98 hex)
    ld [hli], a            ; Store it in the VRAM tilemap and increment HL
    inc de                 ; Move to next source byte
    dec bc                 ; Decrease counter
    ld a, b                ; Check if counter is zero
    or a, c
    jp nz, MemcopyOffset152 ; If not zero, continue loop
    ret                    ; Return when done