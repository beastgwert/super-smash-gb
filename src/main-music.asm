; Game Boy chord progression framework
; Plays a series of three-note chords with timing control

SECTION "Sound Framework", ROM0

; Note frequency constants (Game Boy frequency register values)
; Formula: 2048 - (131072 / frequency_in_Hz)
; Lower register values = higher frequencies

; Octave 2 (very low frequencies, very high register values)
DEF C2     EQU $02D    ; 65Hz
DEF D2     EQU $107    ; 73Hz
DEF E2     EQU $1CA    ; 82Hz
DEF F2     EQU $223    ; 87Hz
DEF G2     EQU $2C7    ; 98Hz
DEF A2     EQU $359    ; 110Hz
DEF B2     EQU $3DA    ; 123Hz

; Octave 2 Sharps
DEF CS2    EQU $09C    ; 69Hz
DEF DS2    EQU $16B    ; 78Hz
DEF FS2    EQU $277    ; 93Hz
DEF GS2    EQU $312    ; 104Hz
DEF AS2    EQU $39C    ; 117Hz

; Octave 3 (lowest frequencies, highest register values)
DEF C3     EQU $418    ; 131Hz (2048 - 131072/131 = 2048 - 1000 = 1048 = $418)
DEF D3     EQU $484    ; 147Hz (2048 - 131072/147 = 2048 - 892 = 1156 = $484)
DEF E3     EQU $4E6    ; 165Hz (2048 - 131072/165 = 2048 - 794 = 1254 = $4E6)
DEF F3     EQU $513    ; 175Hz (2048 - 131072/175 = 2048 - 749 = 1299 = $513)
DEF G3     EQU $563    ; 196Hz (2048 - 131072/196 = 2048 - 669 = 1379 = $563)
DEF A3     EQU $5AC    ; 220Hz (2048 - 131072/220 = 2048 - 596 = 1452 = $5AC)
DEF B3     EQU $5ED    ; 247Hz (2048 - 131072/247 = 2048 - 531 = 1517 = $5ED)

; Octave 3 Sharps
DEF CS3    EQU $451    ; 139Hz
DEF DS3    EQU $4B8    ; 156Hz
DEF FS3    EQU $53C    ; 185Hz
DEF GS3    EQU $58A    ; 208Hz
DEF AS3    EQU $5CE    ; 233Hz

; Octave 4 (middle frequencies, medium register values)
DEF C4     EQU $60C    ; 262Hz (2048 - 131072/262 = 2048 - 500 = 1548 = $60C)
DEF D4     EQU $642    ; 294Hz (2048 - 131072/294 = 2048 - 446 = 1602 = $642)
DEF E4     EQU $673    ; 330Hz (2048 - 131072/330 = 2048 - 397 = 1651 = $673)
DEF F4     EQU $688    ; 349Hz (2048 - 131072/349 = 2048 - 376 = 1672 = $688)
DEF G4     EQU $6B2    ; 392Hz (2048 - 131072/392 = 2048 - 334 = 1714 = $6B2)
DEF A4     EQU $6D6    ; 440Hz (2048 - 131072/440 = 2048 - 298 = 1750 = $6D6)
DEF B4     EQU $6F7    ; 494Hz (2048 - 131072/494 = 2048 - 265 = 1783 = $6F7)

; Octave 4 Sharps
DEF CS4    EQU $627    ; 277Hz
DEF DS4    EQU $65B    ; 311Hz
DEF FS4    EQU $69E    ; 370Hz
DEF GS4    EQU $6C4    ; 415Hz
DEF AS4    EQU $6E7    ; 466Hz

; Octave 5 (highest frequencies, lowest register values)
DEF C5     EQU $705    ; 523Hz (2048 - 131072/523 = 2048 - 251 = 1797 = $705)
DEF D5     EQU $721    ; 587Hz (2048 - 131072/587 = 2048 - 223 = 1825 = $721)
DEF E5     EQU $739    ; 659Hz (2048 - 131072/659 = 2048 - 199 = 1849 = $739)
DEF F5     EQU $744    ; 698Hz (2048 - 131072/698 = 2048 - 188 = 1860 = $744)
DEF G5     EQU $759    ; 784Hz (2048 - 131072/784 = 2048 - 167 = 1881 = $759)
DEF A5     EQU $76B    ; 880Hz (2048 - 131072/880 = 2048 - 149 = 1899 = $76B)
DEF B5     EQU $77B    ; 988Hz (2048 - 131072/988 = 2048 - 133 = 1915 = $77B)

; Octave 5 Sharps
DEF CS5    EQU $713    ; 554Hz
DEF DS5    EQU $72D    ; 622Hz
DEF FS5    EQU $74F    ; 740Hz
DEF GS5    EQU $762    ; 831Hz
DEF AS5    EQU $773    ; 932Hz

; Octave 6 (very high frequencies, very low register values)
DEF C6     EQU $783    ; 1046Hz
DEF D6     EQU $791    ; 1175Hz
DEF E6     EQU $79D    ; 1319Hz
DEF F6     EQU $7A3    ; 1397Hz
DEF G6     EQU $7AD    ; 1568Hz
DEF A6     EQU $7B6    ; 1760Hz
DEF B6     EQU $7BE    ; 1976Hz

DEF XX EQU $000    ; Silent note

; Each chord: note1(2 bytes), note2(2 bytes), note3(2 bytes)
ChordProgression:

    ; Introduction
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX

    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX

    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX

    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw E4, XX, XX
    dw F4, XX, XX
    dw FS4, XX, XX
    dw G4, XX, XX
    dw GS4, XX, XX
    


    ; Section 1
    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3

    dw DS4, C5, DS5
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3

    dw E4, B4, E5
    dw E4, B4, E5
    dw GS2, E3, GS3
    dw E4, B4, E5
    dw G2, E3, G3
    dw G2, E3, G3
    dw CS4, AS4, CS5
    dw G2, E3, G3

    dw D4, A4, D5
    dw D4, A4, D5
    dw F2, A2, F3
    dw D4, A4, D5
    dw E2, A2, E3
    dw E2, A2, E3
    dw C4, A4, C5
    dw E2, A2, E3

    dw B3, F4, B4
    dw B3, F4, B4
    dw D2, B2, D3
    dw B3, F4, B4
    dw DS2, B2, DS3
    dw DS2, B2, DS3
    dw A3, FS4, B4
    dw DS2, B2, DS3

    dw GS3, E4, GS4 
    dw GS3, E4, GS4 
    dw E2, B2, E3
    dw GS3, E4, GS4 
    dw GS2, E3, GS3
    dw GS2, E3, GS3
    dw E4, B4, D5
    dw GS2, E3, GS3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3

    dw FS4, DS5, FS5
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3

    dw G4, E5, G5
    dw G4, E5, G5
    dw G2, E3, G3
    dw G4, E5, G5
    dw GS2, B2, GS3
    dw GS2, B2, GS3
    dw E4, B4, D5
    dw GS2, B2, GS3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, C3, A3
    dw C4, E4, C5
    dw F2, A2, F3
    dw F2, A2, F3
    dw B3, DS4, A4
    dw F2, A2, F3

    dw A3, C4, E4
    dw A3, C4, E4
    dw E2, C3, E3
    dw A3, C4, E4
    dw E2, B3, E3
    dw E2, B3, E3
    dw B3, D4, GS4
    dw E2, B3, E3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3



    ; Section 2
    dw E4, G4, E5
    dw E4, G4, E5
    dw E3, G3, D4
    dw E4, G4, D5
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, B4
    dw E3, G3, B3

    dw F4, A4, XX
    dw F4, A4, XX
    dw C3, F3, A3
    dw F4, A4, XX
    dw C3, F3, B3
    dw C3, F3, B3
    dw F4, A4, C5
    dw C3, F3, C4

    dw D4, F4, D5
    dw D4, F4, D5
    dw D3, F3, C4
    dw D4, F4, C5
    dw D3, F3, B3
    dw D3, F3, B3
    dw D4, F4, A4
    dw D3, F3, A3

    dw E4, G4, XX
    dw E4, G4, XX
    dw C3, E3, G3
    dw E4, G4, XX
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, D5
    dw E3, G3, D4

    dw E4, GS4, E5
    dw E4, GS4, E5
    dw E3, GS3, D4
    dw E4, GS4, D5
    dw E3, GS3, C4
    dw E3, GS3, C4
    dw E4, G4, B4
    dw E3, G3, B3

    dw F4, A4, XX
    dw F4, A4, XX
    dw C3, F3, A3
    dw F4, A4, XX
    dw C3, F3, B3
    dw C3, F3, B3
    dw F4, A4, C5
    dw C3, F3, C4

    dw DS4, FS4, D5
    dw DS4, FS4, D5
    dw DS3, FS3, C4
    dw DS4, FS4, C5
    dw DS3, FS3, B3
    dw DS3, FS3, B3
    dw DS4, FS4, A4
    dw DS3, FS3, A3

    dw E4, G4, XX
    dw E4, G4, XX
    dw C3, E3, G3
    dw E4, G4, XX
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, D5
    dw E3, G3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A3, C4, DS4
    dw A3, C4, DS4
    dw B4, D5, GS5
    dw B3, D4, GS4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw E4, G4, C4
    dw E4, G4, C4
    dw D5, F5, B5
    dw D4, F4, B4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw B3, D4, G4
    dw B3, D4, G4
    dw A4, C5, F5
    dw A3, C4, F4

    dw A4, C5, F5
    dw A4, C5, F5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw G3, AS3, DS4
    dw G3, AS3, DS4
    dw GS4, B4, E5
    dw GS3, B3, E4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A3, C4, F4
    dw AS3, CS4, FS4
    dw B4, C5, G5
    dw C4, DS4, GS4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw E4, G4, C5
    dw E4, G4, C5
    dw D5, F5, B5
    dw D4, F4, B4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw C4, DS4, GS4
    dw B3, D4, G4
    dw AS4, CS5, FS5
    dw A3, C4, F4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw B3, D4, G4
    dw B3, D4, G4
    dw A4, C5, F5
    dw A3, C4, F4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E3, G3, C4
    dw E3, G3, C4
    dw F4, A4, D5
    dw F3, A3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw B3, D4, GS4
    dw B3, D4, GS4
    dw A4, C5, FS5
    dw A3, C4, FS4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E3, G3, C4
    dw E3, G3, C4
    dw F4, A4, D5
    dw F3, A3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw C4, E4, A4
    dw C4, E4, A4
    dw B4, D5, GS5
    dw B3, D4, GS4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E4, G4, C5
    dw E4, G4, C5
    dw D5, F5, B5
    dw D4, F4, B4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A4, C5, F5
    dw A4, C5, F5
    dw G5, B5, E6
    dw G4, B4, E5

    dw F5, A5, D6
    dw F5, A5, D6
    dw E4, G4, C5
    dw E5, G5, C6
    dw D4, F4, B4
    dw D4, F4, B4
    dw C5, E5, A5
    dw C4, E4, A4

    dw B4, D5, G5
    dw B4, D5, G5
    dw G4, B4, E5
    dw G4, B4, E5
    dw E4, G4, C5
    dw E4, G4, C5
    dw C4, E4, A4
    dw C4, E4, A4

    dw A3, C4, F4
    dw A3, C4, F4
    dw F3, A3, D4
    dw F3, A3, D4
    dw D3, F3, B4
    dw D3, F3, B4
    dw E3, GS3, E4
    dw E3, GS3, E4



    ; Section 2.5 (same as Section 1)
    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3

    dw DS4, C5, DS5
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3

    dw E4, B4, E5
    dw E4, B4, E5
    dw GS2, E3, GS3
    dw E4, B4, E5
    dw G2, E3, G3
    dw G2, E3, G3
    dw CS4, AS4, CS5
    dw G2, E3, G3

    dw D4, A4, D5
    dw D4, A4, D5
    dw F2, A2, F3
    dw D4, A4, D5
    dw E2, A2, E3
    dw E2, A2, E3
    dw C4, A4, C5
    dw E2, A2, E3

    dw B3, F4, B4
    dw B3, F4, B4
    dw D2, B2, D3
    dw B3, F4, B4
    dw DS2, B2, DS3
    dw DS2, B2, DS3
    dw A3, FS4, B4
    dw DS2, B2, DS3

    dw GS3, E4, GS4 
    dw GS3, E4, GS4 
    dw E2, B2, E3
    dw GS3, E4, GS4 
    dw GS2, E3, GS3
    dw GS2, E3, GS3
    dw E4, B4, D5
    dw GS2, E3, GS3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3

    dw FS4, DS5, FS5
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3

    dw G4, E5, G5
    dw G4, E5, G5
    dw G2, E3, G3
    dw G4, E5, G5
    dw GS2, B2, GS3
    dw GS2, B2, GS3
    dw E4, B4, D5
    dw GS2, B2, GS3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, C3, A3
    dw C4, E4, C5
    dw F2, A2, F3
    dw F2, A2, F3
    dw B3, DS4, A4
    dw F2, A2, F3

    dw A3, C4, E4
    dw A3, C4, E4
    dw E2, C3, E3
    dw A3, C4, E4
    dw E2, B3, E3
    dw E2, B3, E3
    dw B3, D4, GS4
    dw E2, B3, E3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3



    ; Section 3 (same as Section 2)
    dw E4, G4, E5
    dw E4, G4, E5
    dw E3, G3, D4
    dw E4, G4, D5
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, B4
    dw E3, G3, B3

    dw F4, A4, XX
    dw F4, A4, XX
    dw C3, F3, A3
    dw F4, A4, XX
    dw C3, F3, B3
    dw C3, F3, B3
    dw F4, A4, C5
    dw C3, F3, C4

    dw D4, F4, D5
    dw D4, F4, D5
    dw D3, F3, C4
    dw D4, F4, C5
    dw D3, F3, B3
    dw D3, F3, B3
    dw D4, F4, A4
    dw D3, F3, A3

    dw E4, G4, XX
    dw E4, G4, XX
    dw C3, E3, G3
    dw E4, G4, XX
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, D5
    dw E3, G3, D4

    dw E4, GS4, E5
    dw E4, GS4, E5
    dw E3, GS3, D4
    dw E4, GS4, D5
    dw E3, GS3, C4
    dw E3, GS3, C4
    dw E4, G4, B4
    dw E3, G3, B3

    dw F4, A4, XX
    dw F4, A4, XX
    dw C3, F3, A3
    dw F4, A4, XX
    dw C3, F3, B3
    dw C3, F3, B3
    dw F4, A4, C5
    dw C3, F3, C4

    dw DS4, FS4, D5
    dw DS4, FS4, D5
    dw DS3, FS3, C4
    dw DS4, FS4, C5
    dw DS3, FS3, B3
    dw DS3, FS3, B3
    dw DS4, FS4, A4
    dw DS3, FS3, A3

    dw E4, G4, XX
    dw E4, G4, XX
    dw C3, E3, G3
    dw E4, G4, XX
    dw E3, G3, C4
    dw E3, G3, C4
    dw E4, G4, D5
    dw E3, G3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A3, C4, DS4
    dw A3, C4, DS4
    dw B4, D5, GS5
    dw B3, D4, GS4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw E4, G4, C4
    dw E4, G4, C4
    dw D5, F5, B5
    dw D4, F4, B4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw B3, D4, G4
    dw B3, D4, G4
    dw A4, C5, F5
    dw A3, C4, F4

    dw A4, C5, F5
    dw A4, C5, F5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw G3, AS3, DS4
    dw G3, AS3, DS4
    dw GS4, B4, E5
    dw GS3, B3, E4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A3, C4, F4
    dw AS3, CS4, FS4
    dw B4, C5, G5
    dw C4, DS4, GS4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw E4, G4, C5
    dw E4, G4, C5
    dw D5, F5, B5
    dw D4, F4, B4

    dw C5, E5, A5
    dw C5, E5, A5
    dw C4, E4, A4
    dw C5, E5, A5
    dw C4, DS4, GS4
    dw B3, D4, G4
    dw AS4, CS5, FS5
    dw A3, C4, F4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw B3, D4, G4
    dw B3, D4, G4
    dw A4, C5, F5
    dw A3, C4, F4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E3, G3, C4
    dw E3, G3, C4
    dw F4, A4, D5
    dw F3, A3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw B3, D4, GS4
    dw B3, D4, GS4
    dw A4, C5, FS5
    dw A3, C4, FS4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E3, G3, C4
    dw E3, G3, C4
    dw F4, A4, D5
    dw F3, A3, D4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw C4, E4, A4
    dw C4, E4, A4
    dw B4, D5, GS5
    dw B3, D4, GS4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw E4, G4, C5
    dw E4, G4, C5
    dw D5, F5, B5
    dw D4, F4, B4

    dw GS4, B4, E5
    dw GS4, B4, E5
    dw GS3, B3, E4
    dw GS4, B4, E5
    dw A4, C5, F5
    dw A4, C5, F5
    dw G5, B5, E6
    dw G4, B4, E5

    dw F5, A5, D6
    dw F5, A5, D6
    dw E4, G4, C5
    dw E5, G5, C6
    dw D4, F4, B4
    dw D4, F4, B4
    dw C5, E5, A5
    dw C4, E4, A4

    dw B4, D5, G5
    dw B4, D5, G5
    dw G4, B4, E5
    dw G4, B4, E5
    dw E4, G4, C5
    dw E4, G4, C5
    dw C4, E4, A4
    dw C4, E4, A4

    dw A3, C4, F4
    dw A3, C4, F4
    dw F3, A3, D4
    dw F3, A3, D4
    dw D3, F3, B4
    dw D3, F3, B4
    dw E3, GS3, E4
    dw E3, GS3, E4



    ; Section 3.5 (same as Section 1)
    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3
    dw A2, E2, A3
    dw F4, C5, F5
    dw A2, E2, A3

    dw DS4, C5, DS5
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3
    dw A2, F2, A3
    dw DS4, C5, DS5
    dw A2, F2, A3

    dw E4, B4, E5
    dw E4, B4, E5
    dw GS2, E3, GS3
    dw E4, B4, E5
    dw G2, E3, G3
    dw G2, E3, G3
    dw CS4, AS4, CS5
    dw G2, E3, G3

    dw D4, A4, D5
    dw D4, A4, D5
    dw F2, A2, F3
    dw D4, A4, D5
    dw E2, A2, E3
    dw E2, A2, E3
    dw C4, A4, C5
    dw E2, A2, E3

    dw B3, F4, B4
    dw B3, F4, B4
    dw D2, B2, D3
    dw B3, F4, B4
    dw DS2, B2, DS3
    dw DS2, B2, DS3
    dw A3, FS4, B4
    dw DS2, B2, DS3

    dw GS3, E4, GS4 
    dw GS3, E4, GS4 
    dw E2, B2, E3
    dw GS3, E4, GS4 
    dw GS2, E3, GS3
    dw GS2, E3, GS3
    dw E4, B4, D5
    dw GS2, E3, GS3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, A4
    dw A2, E2, A3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3
    dw A2, E2, A3
    dw C4, E4, C5
    dw A2, E2, A3

    dw F4, C5, F5
    dw F4, C5, F5
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3
    dw A2, F2, A3
    dw F4, C5, F5
    dw A2, F2, A3

    dw FS4, DS5, FS5
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3
    dw A2, DS2, A3
    dw FS4, DS5, FS5
    dw A2, DS2, A3

    dw G4, E5, G5
    dw G4, E5, G5
    dw G2, E3, G3
    dw G4, E5, G5
    dw GS2, B2, GS3
    dw GS2, B2, GS3
    dw E4, B4, D5
    dw GS2, B2, GS3

    dw C4, E4, C5
    dw C4, E4, C5
    dw A2, C3, A3
    dw C4, E4, C5
    dw F2, A2, F3
    dw F2, A2, F3
    dw B3, DS4, A4
    dw F2, A2, F3

    dw A3, C4, E4
    dw A3, C4, E4
    dw E2, C3, E3
    dw A3, C4, E4
    dw E2, B3, E3
    dw E2, B3, E3
    dw B3, D4, GS4
    dw E2, B3, E3

    dw C4, E4, A4
    dw C4, E4, A4
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3
    dw A2, E3, A3
    dw C4, E4, A4
    dw A2, E3, A3

    ; End marker
    dw $FFFF, $FFFF, $FFFF

; Sound system variables in WRAM
SECTION "Sound Variables", WRAM0
ChordTimer:           ds 1    ; Current chord timer
CurrentChordPtrLow:   ds 1    ; Pointer to current chord (low byte)
CurrentChordPtrHigh:  ds 1    ; Pointer to current chord (high byte)
SoundInitialized:     ds 1    ; Flag to track if sound is initialized
NoteStaccatoTimer:    ds 1

SECTION "Sound Code", ROM0

; Initialize sound system - call once at startup
InitSound:
    ; Enable sound
    ld a, $80
    ldh [rAUDENA], a    
    
    ld a, $77
    ldh [rAUDVOL], a    ; Max volume both speakers
    
    ld a, $FF
    ldh [rAUDTERM], a   ; Enable all channels on both speakers
    
    ; Initialize wave data for channel 3
    ld hl, WaveData
    ld de, _AUD3WAVERAM
    ld bc, 16
    call Memcopy
    
    ; Initialize progression variables
    ld a, LOW(ChordProgression)
    ld [CurrentChordPtrLow], a
    ld a, HIGH(ChordProgression)
    ld [CurrentChordPtrHigh], a
    xor a
    ld [ChordTimer], a
    ld a, 1
    ld [SoundInitialized], a

    ; Set staccato length
    ld a, 3
    ld [NoteStaccatoTimer], a
    
    ret

UpdateStaccato:
    ld a, [NoteStaccatoTimer]
    or a
    ret z

    dec a
    ld [NoteStaccatoTimer], a
    ret nz

    ; Time to silence all channels
    call SilenceChannel1
    call SilenceChannel2
    call SilenceChannel3
    ret

; Call this every frame from your main loop
UpdateChords:
    ; Check if sound is initialized
    ld a, [SoundInitialized]
    or a
    ret z

    call UpdateStaccato
    
    ; Decrement timer
    ld a, [ChordTimer]
    or a
    jr z, PlayNextChord
    dec a
    ld [ChordTimer], a
    ret

PlayNextChord:
    ; Get current chord pointer into HL
    ld a, [CurrentChordPtrLow]
    ld l, a
    ld a, [CurrentChordPtrHigh]
    ld h, a
    
    ; Check for end marker
    ld a, [hl+]
    ld b, a
    ld a, [hl]
    or b
    cp $FF
    jr nz, LoadChord
    
    ; Reset to beginning of progression
    ld a, LOW(ChordProgression)
    ld [CurrentChordPtrLow], a
    ld a, HIGH(ChordProgression)
    ld [CurrentChordPtrHigh], a

LoadChord:
    ; Reload HL with current chord pointer
    ld a, [CurrentChordPtrLow]
    ld l, a
    ld a, [CurrentChordPtrHigh]
    ld h, a
    
    ; Load note 1 (Channel 1)
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a             ; BC = note1 frequency
    call PlayNote1
    
    ; Load note 2 (Channel 2)  
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a             ; BC = note2 frequency
    call PlayNote2
    
    ; Load note 3 (Channel 3)
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a             ; BC = note3 frequency
    call PlayNote3
    
    ; Set fixed duration
    ld a, 6
    ld [ChordTimer], a
    
    ; Update chord pointer for next time
    ld a, l
    ld [CurrentChordPtrLow], a
    ld a, h
    ld [CurrentChordPtrHigh], a
    
    ret

; Play note on Channel 1 (square wave)
PlayNote1:
    ; Check for silent note
    ld a, b
    or c
    jr z, SilenceChannel1
    
    ld a, $00           ; No sweep
    ldh [rAUD1SWEEP], a
    
    ld a, $30           ; Duty 11, envelope F0, length enable
    ldh [rAUD1LEN], a

    ; ld a, $20           ; Set length data
    ; ldh [rAUD1LEN], a
    
    ld a, c             ; Low byte of frequency
    ldh [rAUD1LOW], a
    
    ld a, b
    and $07             ; Mask upper 3 bits
    or $80              ; Trigger + length enable
    ldh [rAUD1HIGH], a
    ret

SilenceChannel1:
    xor a
    ldh [rAUD1LEN], a   ; Disable channel
    ret

; Play note on Channel 2 (square wave)
PlayNote2:
    ; Check for silent note
    ld a, b
    or c
    jr z, SilenceChannel2
    
    ld a, $30           ; Duty 11, envelope F0, length enable
    ldh [rAUD2LEN], a

    ; ld a, $20           ; Set length data
    ; ldh [rAUD2LEN], a
    
    ld a, c             ; Low byte of frequency
    ldh [rAUD2LOW], a
    
    ld a, b
    and $07             ; Mask upper 3 bits
    or $80              ; Trigger + length enable
    ldh [rAUD2HIGH], a
    ret

SilenceChannel2:
    xor a
    ldh [rAUD2LEN], a   ; Disable channel
    ret

; Play note on Channel 3 (wave)
PlayNote3:
    ; Check for silent note
    ld a, b
    or c
    jr z, SilenceChannel3
    
    ld a, $80           ; Enable wave channel
    ldh [rAUD3ENA], a

    ld a, $F0           ; Set length data
    ldh [rAUD3LEN], a
    
    ld a, $20           ; Volume level 1
    ldh [rAUD3LEVEL], a
    
    ld a, c             ; Low byte of frequency
    ldh [rAUD3LOW], a
    
    ld a, b
    and $07             ; Mask upper 3 bits  
    or $C0              ; Trigger + length enable
    ldh [rAUD3HIGH], a
    ret

SilenceChannel3:
    xor a
    ldh [rAUD3LEVEL], a  ; Set volume to 0 (mute)
    ret

; Smoother sine-like wave data for channel 3
WaveData:
    db $08, $9A, $CE, $ED, $DC, $B9, $64, $10
    db $01, $46, $9B, $CD, $DE, $EC, $A9, $80

; Example usage in your main loop:
; MainLoop:
;     call UpdateChords    ; Call this every frame
;     ; ... your other game logic ...
;     jr MainLoop