INCLUDE "hardware.inc"

SECTION "ArenaBackgroundSection", ROM0

arenaMap: INCBIN "generated/arena.tilemap"
arenaMapEnd:
 
arenaTileData: INCBIN "generated/arena.2bpp"
arenaTileDataEnd: