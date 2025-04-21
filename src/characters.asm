INCLUDE "hardware.inc"

INCLUDE "utils/macros/constants.inc"

SECTION "Characters", ROM0

michaelTileData: INCBIN "generated/michael.2bpp"
michaelTileDataEnd:

michaelAttackTileData: INCBIN "generated/michael-attack.2bpp"
michaelAttackTileDataEnd:

omkarTileData: INCBIN "generated/omkar.2bpp"
omkarTileDataEnd:

omkarAttackTileData: INCBIN "generated/omkar-attack.2bpp"
omkarAttackTileDataEnd:

InitializeCharacters::
    
    ; Load michael regular sprite data
    ld de, michaelTileData
    ld hl, CHARACTER_TILES_START
    ld bc, michaelTileDataEnd - michaelTileData
    call Memcopy
    
    ; Calculate the next position after michael sprites
    ld de, michaelAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 2 ; each tile is 16 bytes, and each character is two tiles
    ld bc, michaelAttackTileDataEnd - michaelAttackTileData
    call Memcopy
    
    ; Load omkar regular sprite data
    ld de, omkarTileData
    ld hl, CHARACTER_TILES_START + 16 * 4
    ld bc, omkarTileDataEnd - omkarTileData
    call Memcopy
    
    ; Calculate the next position after omkar sprites
    ld de, omkarAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 6
    ld bc, omkarAttackTileDataEnd - omkarAttackTileData
    call Memcopy
    
    ret
