; ================================================================
; Fighting Game Background Music - Smash-like Theme 
; ================================================================

; Constants for note frequencies
DEF C3_LO  EQU $44
DEF C3_HI  EQU $06
DEF Db3_LO EQU $C3
DEF Db3_HI EQU $05
DEF D3_LO  EQU $4A
DEF D3_HI  EQU $05
DEF Eb3_LO EQU $D9
DEF Eb3_HI EQU $04
DEF E3_LO  EQU $70
DEF E3_HI  EQU $04
DEF F3_LO  EQU $0E
DEF F3_HI  EQU $04
DEF Gb3_LO EQU $B3
DEF Gb3_HI EQU $03
DEF G3_LO  EQU $5E
DEF G3_HI  EQU $03
DEF Ab3_LO EQU $0F
DEF Ab3_HI EQU $03
DEF A3_LO  EQU $C4
DEF A3_HI  EQU $02
DEF Bb3_LO EQU $7F
DEF Bb3_HI EQU $02
DEF B3_LO  EQU $3F
DEF B3_HI  EQU $02

DEF C4_LO  EQU $01
DEF C4_HI  EQU $02
DEF D4_LO  EQU $94
DEF D4_HI  EQU $01
DEF E4_LO  EQU $38
DEF E4_HI  EQU $01
DEF F4_LO  EQU $86
DEF F4_HI  EQU $00
DEF G4_LO  EQU $2F
DEF G4_HI  EQU $00

; Constants for note durations
DEF WHOLE     EQU 64
DEF HALF      EQU 32
DEF QUARTER   EQU 16
DEF EIGHTH    EQU 8
DEF SIXTEENTH EQU 4

; Music data structure
; Each note entry consists of:
; 1. Channel (0=Ch1, 1=Ch2, 2=Ch3, 3=Ch4)
; 2. Note frequency low byte
; 3. Note frequency high byte
; 4. Duration
; 5. Volume (0-15)
; 6. Effect (0=none, 1=slide up, 2=slide down, 3=vibrato)

; The format for the music data is:
; db channel, freq_lo, freq_hi, duration, volume, effect

SECTION "Music Data", ROM0
; Wave pattern data for Channel 3
WavePattern:
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db $00, $00, $00, $00, $00, $00, $00, $00

MusicData:
    ; Intro - dramatic build-up
    db 0, C3_LO, C3_HI, QUARTER, 13, 0    ; Channel 1 - Bass note
    db 1, C4_LO, C4_HI, QUARTER, 10, 0    ; Channel 2 - Higher note
    db 0, D3_LO, D3_HI, QUARTER, 13, 0
    db 1, D4_LO, D4_HI, QUARTER, 10, 0
    db 0, E3_LO, E3_HI, QUARTER, 13, 0
    db 1, E4_LO, E4_HI, QUARTER, 10, 0
    db 0, G3_LO, G3_HI, HALF, 15, 0
    db 1, G4_LO, G4_HI, HALF, 12, 0
    
    ; Main battle theme - Part 1 (more agressive rhythm)
    db 0, C3_LO, C3_HI, EIGHTH, 15, 0     ; Bass pattern
    db 3, $10, 0, EIGHTH, 15, 0           ; Noise hit
    db 0, G3_LO, G3_HI, EIGHTH, 15, 0
    db 1, C4_LO, C4_HI, EIGHTH, 10, 0
    db 0, C3_LO, C3_HI, EIGHTH, 15, 0
    db 0, G3_LO, G3_HI, EIGHTH, 15, 0
    db 1, E4_LO, E4_HI, EIGHTH, 12, 0
    db 3, $20, 0, EIGHTH, 15, 0
    
    db 0, D3_LO, D3_HI, EIGHTH, 15, 0
    db 3, $30, 0, EIGHTH, 15, 0
    db 0, A3_LO, A3_HI, EIGHTH, 15, 0
    db 1, D4_LO, D4_HI, EIGHTH, 10, 0
    db 0, D3_LO, D3_HI, EIGHTH, 15, 0
    db 0, A3_LO, A3_HI, EIGHTH, 15, 0
    db 1, F4_LO, F4_HI, EIGHTH, 12, 0
    db 3, $40, 0, EIGHTH, 15, 0
    
    ; Main battle theme - Part 2 (climactic section)
    db 0, G3_LO, G3_HI, EIGHTH, 15, 0
    db 1, G4_LO, G4_HI, EIGHTH, 13, 0
    db 3, $50, 0, EIGHTH, 15, 0
    db 0, F3_LO, F3_HI, EIGHTH, 15, 0
    db 1, F4_LO, F4_HI, EIGHTH, 13, 0
    db 0, E3_LO, E3_HI, EIGHTH, 15, 0
    db 1, E4_LO, E4_HI, EIGHTH, 13, 0
    db 3, $60, 0, EIGHTH, 15, 0
    
    db 0, D3_LO, D3_HI, EIGHTH, 15, 0
    db 1, D4_LO, D4_HI, EIGHTH, 13, 0
    db 0, E3_LO, E3_HI, EIGHTH, 15, 0
    db 1, E4_LO, E4_HI, EIGHTH, 13, 0
    db 0, F3_LO, F3_HI, EIGHTH, 15, 0
    db 1, F4_LO, F4_HI, EIGHTH, 13, 0
    db 3, $70, 0, EIGHTH, 15, 0
    db 0, G3_LO, G3_HI, QUARTER, 15, 1    ; Slide up effect
    db 1, G4_LO, G4_HI, QUARTER, 13, 1    ; Slide up effect
    
    db 0, 0, 0, QUARTER, 0, 0             ; End marker
    
SECTION "Music Variables", WRAM0
MusicPointer:    DS 2    ; 2 bytes for pointer
MusicDelay:      DS 1
CurrentChannel:  DS 1
CurrentNote:     DS 2    ; Lo, Hi
CurrentDuration: DS 1
CurrentVolume:   DS 1
CurrentEffect:   DS 1
MusicPlaying:    DS 1
VibratoCounter:  DS 1
VibratoDirection: DS 1

; ================================================================
; Sound initialization and playback routines
; ================================================================

SECTION "Music Code", ROM0
InitializeSound:
    ; Turn on sound
    ld a, %10000000
    ld [$FF26], a    ; Sound on/off
    
    ; Set maximum volume for both channels
    ld a, %01110111
    ld [$FF24], a    ; Volume control
    
    ; Output sound to both left and right
    ld a, %11111111
    ld [$FF25], a    ; Sound panning
    
    ; Initialize sweep register for Channel 1
    ld a, %00000000  ; No sweep initially
    ld [$FF10], a
    
    ; Initialize Channel 3 (wave)
    ; Load wave pattern
    ld hl, WavePattern
    ld de, $FF30     ; Wave pattern RAM
    ld bc, 16        ; 16 bytes to copy
.copyWaveLoop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyWaveLoop
    
    ; Initialize music variables
    ld hl, MusicData
    ld a, l
    ld [MusicPointer], a
    ld a, h
    ld [MusicPointer+1], a
    ld a, 1
    ld [MusicPlaying], a
    xor a
    ld [MusicDelay], a
    ld [VibratoCounter], a
    ld [VibratoDirection], a
    ret

; Call this function in your game loop to update music playback
UpdateMusic:
    ; Check if music is playing
    ld a, [MusicPlaying]
    cp 0
    ret z           ; Return if not playing
    
    ; Check if we need to play the next note
    ld a, [MusicDelay]
    cp 0
    jp z, .playNextNote
    
    ; Otherwise, decrement the delay and return
    dec a
    ld [MusicDelay], a
    
    ; Handle ongoing effects
    ld a, [CurrentEffect]
    cp 3
    jr z, .updateVibrato
    ret
    
.updateVibrato:
    ; Only update vibrato on certain frames
    ld a, [MusicDelay]
    and %00000011    ; Every 4 frames
    ret nz
    
    ; Get the current channel
    ld a, [CurrentChannel]
    cp 0
    jr z, .vibratoChannel1
    cp 1
    jr z, .vibratoChannel2
    ret
    
.vibratoChannel1:
    ; Apply vibrato to channel 1
    ld a, [VibratoDirection]
    cp 0
    jr z, .vibratoUp1
    
    ; Vibrato down
    ld a, [$FF13]
    sub 1
    ld [$FF13], a
    jr nc, .checkVibratoFlip
    ; Handle frequency underflow
    ld a, [$FF14]
    dec a
    ld [$FF14], a
    jr .checkVibratoFlip
    
.vibratoUp1:
    ; Vibrato up
    ld a, [$FF13]
    add 1
    ld [$FF13], a
    jr nc, .checkVibratoFlip
    ; Handle frequency overflow
    ld a, [$FF14]
    inc a
    and %00000111    ; Make sure not to modify trigger or other bits
    ld [$FF14], a
    
.checkVibratoFlip:
    ; Increment vibrato counter
    ld a, [VibratoCounter]
    inc a
    ld [VibratoCounter], a
    cp 4            ; Change direction every 4 updates
    jr nz, .doneVibrato
    
    ; Reset counter and flip direction
    xor a
    ld [VibratoCounter], a
    ld a, [VibratoDirection]
    xor 1
    ld [VibratoDirection], a
    
.doneVibrato:
    ret
    
.vibratoChannel2:
    ; Same logic for channel 2
    ld a, [VibratoDirection]
    cp 0
    jr z, .vibratoUp2
    
    ; Vibrato down
    ld a, [$FF18]
    sub 1
    ld [$FF18], a
    jr nc, .checkVibratoFlip
    ; Handle frequency underflow
    ld a, [$FF19]
    dec a
    ld [$FF19], a
    jr .checkVibratoFlip
    
.vibratoUp2:
    ; Vibrato up
    ld a, [$FF18]
    add 1
    ld [$FF18], a
    jr nc, .checkVibratoFlip
    ; Handle frequency overflow
    ld a, [$FF19]
    inc a
    and %00000111    ; Make sure not to modify trigger or other bits
    ld [$FF19], a
    jr .checkVibratoFlip
    
.playNextNote:
    ; Get the next note data from the music pointer
    ld a, [MusicPointer]
    ld l, a
    ld a, [MusicPointer+1]
    ld h, a
    
    ; Read channel
    ld a, [hl+]
    ld [CurrentChannel], a
    
    ; Read note frequency (lo)
    ld a, [hl+]
    ld [CurrentNote], a
    
    ; Read note frequency (hi)
    ld a, [hl+]
    ld [CurrentNote+1], a
    
    ; Read duration
    ld a, [hl+]
    ld [CurrentDuration], a
    
    ; Read volume
    ld a, [hl+]
    ld [CurrentVolume], a
    
    ; Read effect
    ld a, [hl+]
    ld [CurrentEffect], a
    
    ; Update music pointer
    ld a, l
    ld [MusicPointer], a
    ld a, h
    ld [MusicPointer+1], a
    
    ; Check for end marker (channel = 0, frequency = 0, duration = QUARTER, volume = 0)
    ld a, [CurrentChannel]
    cp 0
    jr nz, .notEndMarker
    
    ld a, [CurrentNote]
    cp 0
    jr nz, .notEndMarker
    
    ld a, [CurrentNote+1]
    cp 0
    jr nz, .notEndMarker
    
    ld a, [CurrentVolume]
    cp 0
    jr nz, .notEndMarker
    
    ; If we reach here, we've hit the end marker
    ; Reset to beginning of music
    ld hl, MusicData
    ld a, l
    ld [MusicPointer], a
    ld a, h
    ld [MusicPointer+1], a
    jp .playNextNote
    
.notEndMarker:
    ; Play the note on the appropriate channel
    ld a, [CurrentChannel]
    cp 0
    jr z, .playChannel1
    cp 1
    jr z, .playChannel2
    cp 2
    jp z, .playChannel3
    cp 3
    jp z, .playChannel4
    
    ; Default case, just set the delay
    ld a, [CurrentDuration]
    ld [MusicDelay], a
    ret
    
.playChannel1:
    ; Reset vibrato counter when playing a new note
    xor a
    ld [VibratoCounter], a
    ld [VibratoDirection], a
    
    ; Handle effects first to set up registers properly
    ld a, [CurrentEffect]
    cp 0
    jr z, .ch1NoEffect
    cp 1
    jr z, .ch1SlideUp
    cp 2
    jr z, .ch1SlideDown
    
.ch1NoEffect:
    ; No effect, set sweep to 0
    ld a, %00000000  ; No sweep
    ld [$FF10], a
    jr .ch1Continue
    
.ch1SlideUp:
    ; Slide up effect
    ld a, %01110111  ; Sweep time = 7, shift = 7 (max)
    ld [$FF10], a
    jr .ch1Continue
    
.ch1SlideDown:
    ; Slide down effect
    ld a, %00110111  ; Sweep time = 7, negative sweep, shift = 7
    ld [$FF10], a
    
.ch1Continue:
    ; Channel 1 (Square wave with sweep)
    ; Set duty cycle and sound length
    ld a, %10000000  ; 50% duty cycle, no length constraint
    ld [$FF11], a
    
    ; Set volume envelope
    ld a, [CurrentVolume]
    swap a           ; Move to high nibble
    or %00000111     ; No envelope
    ld [$FF12], a
    
    ; Set frequency
    ld a, [CurrentNote]
    ld [$FF13], a    ; Frequency lo
    
    ld a, [CurrentNote+1]
    or %10000000     ; Trigger + high bits
    ld [$FF14], a
    
    ; Set the delay
    ld a, [CurrentDuration]
    ld [MusicDelay], a
    ret
    
.playChannel2:
    ; Reset vibrato counter when playing a new note
    xor a
    ld [VibratoCounter], a
    ld [VibratoDirection], a
    
    ; Channel 2 (Square wave)
    ; Set duty cycle and sound length
    ld a, %10000000  ; 50% duty cycle, no length constraint
    ld [$FF16], a
    
    ; Set volume envelope
    ld a, [CurrentVolume]
    swap a           ; Move to high nibble
    or %00000111     ; No envelope
    ld [$FF17], a
    
    ; Set frequency
    ld a, [CurrentNote]
    ld [$FF18], a    ; Frequency lo
    
    ld a, [CurrentNote+1]
    or %10000000     ; Trigger + high bits
    ld [$FF19], a
    
    ; Set the delay
    ld a, [CurrentDuration]
    ld [MusicDelay], a
    ret
    
.playChannel3:
    ; Channel 3 (Wave)
    ; Enable wave channel
    ld a, %10000000  ; Sound on
    ld [$FF1A], a
    
    ; Set wave channel length
    ld a, %00000000  ; No length constraint
    ld [$FF1B], a
    
    ; Set volume
    ld a, [CurrentVolume]
    cp 15
    jr z, .ch3MaxVolume
    cp 0
    jr z, .ch3Mute
    
    ; Medium volume
    ld a, %01100000  ; 75% volume
    jr .ch3SetVolume
    
.ch3MaxVolume:
    ld a, %00100000  ; 100% volume
    jr .ch3SetVolume
    
.ch3Mute:
    ld a, %00000000  ; Mute
    
.ch3SetVolume:
    ld [$FF1C], a
    
    ; Set frequency
    ld a, [CurrentNote]
    ld [$FF1D], a    ; Frequency lo
    
    ld a, [CurrentNote+1]
    or %10000000     ; Trigger + high bits
    ld [$FF1E], a
    
    ; Set the delay
    ld a, [CurrentDuration]
    ld [MusicDelay], a
    ret
    
.playChannel4:
    ; Channel 4 (Noise)
    ; Set sound length
    ld a, %00111111  ; Short sound
    ld [$FF20], a
    
    ; Set volume envelope based on CurrentVolume
    ld a, [CurrentVolume]
    swap a           ; Move to high nibble
    or %00000001     ; Decreasing envelope
    ld [$FF21], a
    
    ; Use CurrentNote to determine noise parameters
    ld a, [CurrentNote]
    and %00001111    ; Use low nibble for shift clock frequency
    ld b, a
    
    ld a, [CurrentNote]
    swap a           ; Get high nibble
    and %00000111    ; Use for polynomial counter
    
    ; Combine values
    sla a            ; Move to bits 3-5
    sla a
    sla a
    or b             ; Combine with shift clock
    ld [$FF22], a
    
    ; Trigger sound
    ld a, %10000000
    ld [$FF23], a
    
    ; Set the delay
    ld a, [CurrentDuration]
    ld [MusicDelay], a
    ret