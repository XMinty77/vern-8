; undef_known_f1: all 63 undefined opcodes in reverse order with F = 1, inside a subroutine
; at depth 2 (S0, S1 and D must not change), with AR = FF and A, B = FF/00.

        IMF A, 0xFF
        IMF B, 0x00
        STF
        CALL u1
        HALT
u1:     CALL u2
        RET
u2:     IMF AR, 0xFF
        .byte 0xDB
        .byte 0xDA
        .byte 0xD9
        .byte 0xD7
        .byte 0xD6
        .byte 0xD5
        .byte 0xD4
        .byte 0xD3
        .byte 0xD2
        .byte 0xD1
        .byte 0xD0
        .byte 0x9F
        .byte 0x9E
        .byte 0x9D
        .byte 0x9C
        .byte 0xCF
        .byte 0xCE
        .byte 0xCD
        .byte 0xCC
        .byte 0xCB
        .byte 0xCA
        .byte 0xC9
        .byte 0xC8
        .byte 0xC7
        .byte 0xC6
        .byte 0xC5
        .byte 0xC4
        .byte 0xC3
        .byte 0xC2
        .byte 0xC1
        .byte 0xC0
        .byte 0xBF
        .byte 0xBE
        .byte 0xBD
        .byte 0xBC
        .byte 0xBB
        .byte 0xBA
        .byte 0xB9
        .byte 0xB8
        .byte 0xB7
        .byte 0xB6
        .byte 0xB5
        .byte 0xB4
        .byte 0xB3
        .byte 0xB2
        .byte 0xB1
        .byte 0xB0
        .byte 0xAF
        .byte 0xAE
        .byte 0xAD
        .byte 0xAC
        .byte 0xAB
        .byte 0xAA
        .byte 0xA9
        .byte 0xA8
        .byte 0xA7
        .byte 0xA6
        .byte 0xA5
        .byte 0xA4
        .byte 0xA3
        .byte 0xA2
        .byte 0xA1
        .byte 0xA0
        RET
