INCLUDE "hardware.inc"
INCLUDE "utils/memory-utils.asm"

SECTION "CharacterSelectionBackgroundSection", ROMX, BANK[1]

CharacterSelectionMap: INCBIN "generated/CharacterSelection.tilemap"
CharacterSelectionMapEnd:
 
CharacterSelectionTileData: INCBIN "generated/CharacterSelection.2bpp"
CharacterSelectionTileDataEnd:

InitializeCharacterSelectionBackground::
    ; Copy the tile data
	ld de, CharacterSelectionTileData ; de contains the address where data will be copied from;
	ld hl, $8100 ; hl contains the address where data will be copied to;
	ld bc, CharacterSelectionTileDataEnd - CharacterSelectionTileData ; bc contains how many bytes we have to copy.
    call Memcopy

    ; Copy the tilemap with proper offset
    ; Since tiles are loaded at $9340, we need to add an offset to each tile number
    ; $9340 - $8000 = $1340 bytes offset, which is 152 tiles (152 * 16 = $980)
    ; So we need to add 152 (or $98) to each tile number in the tilemap
    
    ld de, CharacterSelectionMap        ; Source: our tilemap data
    ld hl, $9800           ; Destination: the tilemap area in VRAM
    ld bc, CharacterSelectionMapEnd - CharacterSelectionMap  ; Length of our tilemap data
    call MemcopyOffset152  ; Return when done
    ret

