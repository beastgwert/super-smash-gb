INCLUDE "hardware.inc"

RSRESET
DEF spriteTilesStart            RB _VRAM
DEF CHARACTER_TILES_START          RB 20*16 ; 5 characters, 4 tiles each
DEF DIGIT_TILES_START            RB 20*16 ; 10 digits, 2 tiles each (2nd tile is filler)
DEF HEART_TILES_START            RB 2*16 ; heart tile
DEF PLAYER_INDICATOR_START       RB 4*16 ; player indicator