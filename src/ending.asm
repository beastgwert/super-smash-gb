
EndingScreen: 
    ; Determine which player died
    ld a, [wPlayerLives1]
    cp 0
    jr z, .player_1_death
    ld d, 0
    jr EndingScreenWaitVBlank
    .player_1_death
    ld d, 1

EndingScreenWaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, EndingScreenWaitVBlank

	ld a, 0
	ld [rLCDC], a


EndingScreenSetBackground: 
    ld a, d
    cp 0
    jr z, .krill_won 
    call SetEndingBackgroundNeil
    jr .end_background_set
    .krill_won
    call SetEndingBackgroundKrill
    .end_background_set
    
    ld a, 0
    ld b, 160
    ld hl, _OAMRAM
EndingScreenClearOam:
    ld [hli], a
    dec b
    jp nz, EndingScreenClearOam


	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
	ld [rLCDC], a

	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a

EndingScreenMain: 
    call UpdateKeys
    call UpdateState
    ldh a, [rLY]
	cp 144
	jp nc, EndingScreenMain ;rerun if in vblank
    jr EndingScreenMain

UpdateState: 
    ld a, [wCurKeys2]
    and a, PADF_LEFT
    ret z
    xor a
    ld [wCurKeys1], a
    ld [wNewKeys1], a
    jp CSSEntryPoint

    
SECTION "Ending Screen Vars", WRAM0
winningCharacter: db


SECTION "EndingScreenBackgroundSection", ROMX

krillEndingMap: INCBIN "generated/ending_screen_krill.tilemap"
krillEndingMapEnd:

krillEndingTileData: INCBIN "generated/ending_screen_krill.2bpp"
krillEndingTileDataEnd: 

neilEndingMap: INCBIN "generated/ending_screen_neil.tilemap"
neilEndingMapEnd:

neilEndingTileData: INCBIN "generated/ending_screen_neil.2bpp"
neilEndingTileDataEnd: 


SetEndingBackgroundKrill:
    ; Copy the tile data
	ld de, krillEndingTileData ; de contains the address where data will be copied from;
	ld hl, $8300 ; hl contains the address where data will be copied to;
	ld bc, krillEndingTileDataEnd - krillEndingTileData ; bc contains how many bytes we have to copy.
    call Memcopy

    ; Copy the tilemap with proper offset
    ; Since tiles are loaded at $9340, we need to add an offset to each tile number
    ; $9340 - $8000 = $1340 bytes offset, which is 152 tiles (152 * 16 = $980)
    ; So we need to add 152 (or $98) to each tile number in the tilemap
    
    ld de, krillEndingMap        ; Source: our tilemap data
    ld hl, $9800           ; Destination: the tilemap area in VRAM
    ld bc, krillEndingMapEnd - krillEndingMap  ; Length of our tilemap data
    call MemcopyOffset48  ; Return when done
    ret

SetEndingBackgroundNeil:
    ; Copy the tile data
	ld de, neilEndingTileData ; de contains the address where data will be copied from;
	ld hl, $8300 ; hl contains the address where data will be copied to;
	ld bc, neilEndingTileDataEnd - neilEndingTileData ; bc contains how many bytes we have to copy.
    call Memcopy

    ; Copy the tilemap with proper offset
    ; Since tiles are loaded at $9340, we need to add an offset to each tile number
    ; $9340 - $8000 = $1340 bytes offset, which is 152 tiles (152 * 16 = $980)
    ; So we need to add 152 (or $98) to each tile number in the tilemap
    
    ld de, neilEndingMap        ; Source: our tilemap data
    ld hl, $9800           ; Destination: the tilemap area in VRAM
    ld bc, neilEndingMapEnd - neilEndingMap  ; Length of our tilemap data
    call MemcopyOffset48  ; Return when done
    ret

