INCLUDE "hardware.inc"

RSRESET
DEF spriteTilesStart            RB _VRAM
DEF CHARACTER_TILES_START          RB 20*16 ; 5 characters, 4 tiles each
DEF DIGIT_TILES_START            RB 10*16 ; 10 digits, 1 tile each