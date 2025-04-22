INCLUDE "hardware.inc"
INCLUDE "utils/memory-utils.asm"

SECTION "ArenaBackgroundSection", ROM0

arenaMap: INCBIN "generated/arena.tilemap"
arenaMapEnd:
 
arenaTileData: INCBIN "generated/arena.2bpp"
arenaTileDataEnd:

InitializeBackground::
    ; Copy the tile data
	ld de, arenaTileData ; de contains the address where data will be copied from;
	ld hl, $8300 ; hl contains the address where data will be copied to;
	ld bc, arenaTileDataEnd - arenaTileData ; bc contains how many bytes we have to copy.
    call Memcopy

    ; Copy the tilemap with proper offset
    ; Since tiles are loaded at $9340, we need to add an offset to each tile number
    ; $9340 - $8000 = $1340 bytes offset, which is 152 tiles (152 * 16 = $980)
    ; So we need to add 152 (or $98) to each tile number in the tilemap
    
    ld de, arenaMap        ; Source: our tilemap data
    ld hl, $9800           ; Destination: the tilemap area in VRAM
    ld bc, arenaMapEnd - arenaMap  ; Length of our tilemap data
    call MemcopyOffset48  ; Return when done
    ret
