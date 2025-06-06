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

heartTileData:
    dw `00000000
    dw `03303300
    dw `32232230
    dw `32222230
    dw `32222230
    dw `03222300
    dw `00323000
    dw `00030000
heartTileDataEnd:

P1TileData:
    dw `00000000
    dw `00000000
    dw `00000000
    dw `33303000
    dw `30303000
    dw `33303000
    dw `30003000
    dw `30003000
P1TileDataEnd:

P2TileData:
    dw `00000000
    dw `00000000
    dw `00000000
    dw `33303330
    dw `30300030
    dw `33303330
    dw `30003000
    dw `30003330
P2TileDataEnd:
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

    ld de, heartTileData
    ld hl, HEART_TILES_START
    ld bc, heartTileDataEnd - heartTileData
    call Memcopy
    
    ld de, P1TileData
    ld hl, PLAYER_INDICATOR_START
    ld bc, P1TileDataEnd - P1TileData
    call Memcopy
    
    ld de, P2TileData
    ld hl, PLAYER_INDICATOR_START + 16 * 2
    ld bc, P2TileDataEnd - P2TileData
    call Memcopy
    ret
