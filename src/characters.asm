INCLUDE "hardware.inc"

INCLUDE "utils/macros/constants.inc"

SECTION "Characters", ROM0

michaelTileData: INCBIN "generated/michael.2bpp"
michaelTileDataEnd:

michaelAttackTileData: INCBIN "generated/michael-attack.2bpp"
michaelAttackTileDataEnd:

InitializeCharacters::
    
    ; Load michael regular sprite data
    ld de, michaelTileData
    ld hl, CHARACTER_TILES_START
    ld bc, michaelTileDataEnd - michaelTileData
    call Memcopy
    
    ; Calculate the next position after michael sprites
    ld de, michaelAttackTileData
    ld hl, CHARACTER_TILES_START + (michaelTileDataEnd - michaelTileData)
    ld bc, michaelAttackTileDataEnd - michaelAttackTileData
    call Memcopy
    
    ret
