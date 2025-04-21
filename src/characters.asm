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

christopherTileData: INCBIN "generated/christopher.2bpp"
christopherTileDataEnd:

christopherAttackTileData: INCBIN "generated/christopher-attack.2bpp"
christopherAttackTileDataEnd:

neilTileData: INCBIN "generated/neil.2bpp"
neilTileDataEnd:

neilAttackTileData: INCBIN "generated/neil-attack.2bpp"
neilAttackTileDataEnd:

calebTileData: INCBIN "generated/caleb.2bpp"
calebTileDataEnd:

calebAttackTileData: INCBIN "generated/caleb-attack.2bpp"
calebAttackTileDataEnd:

InitializeCharacters::
    
    ; Load michael regular sprite data
    ld de, michaelTileData
    ld hl, CHARACTER_TILES_START + 16 * 12
    ld bc, michaelTileDataEnd - michaelTileData
    call Memcopy
    
    ld de, michaelAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 14 ; each tile is 16 bytes, and each character is two tiles
    ld bc, michaelAttackTileDataEnd - michaelAttackTileData
    call Memcopy
    
    ld de, omkarTileData
    ld hl, CHARACTER_TILES_START + 16 * 4
    ld bc, omkarTileDataEnd - omkarTileData
    call Memcopy
    
    ld de, omkarAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 6
    ld bc, omkarAttackTileDataEnd - omkarAttackTileData
    call Memcopy
    
    ld de, christopherTileData
    ld hl, CHARACTER_TILES_START + 16 * 0
    ld bc, christopherTileDataEnd - christopherTileData
    call Memcopy
    
    ld de, christopherAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 2
    ld bc, christopherAttackTileDataEnd - christopherAttackTileData
    call Memcopy

    ld de, neilTileData
    ld hl, CHARACTER_TILES_START + 16 * 16
    ld bc, neilTileDataEnd - neilTileData
    call Memcopy
    
    ld de, neilAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 18
    ld bc, neilAttackTileDataEnd - neilAttackTileData
    call Memcopy
    
    ld de, calebTileData
    ld hl, CHARACTER_TILES_START + 16 * 8
    ld bc, calebTileDataEnd - calebTileData
    call Memcopy
    
    ld de, calebAttackTileData
    ld hl, CHARACTER_TILES_START + 16 * 10
    ld bc, calebAttackTileDataEnd - calebAttackTileData
    call Memcopy
    
    ret
