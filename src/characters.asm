INCLUDE "hardware.inc"

INCLUDE "utils/macros/constants.inc"

SECTION "Characters", ROM0

michaelTileData: INCBIN "generated/michael.2bpp"
michaelTileDataEnd:
InitializeCharacters::
    
    ld de, michaelTileData
    ld hl, CHARACTER_TILES_START
    ld bc, michaelTileDataEnd - michaelTileData
    call Memcopy
    ret

