; undef_known_f0: all 63 undefined opcodes (A0-CF, 9C-9F, D0-D7, D9-DB) as .byte, with A, B,
; AR, F = 0 and the short data memory known: each must be a NOP (PC + 1, no
; register, flag, stack or memory change).

        IMF A, 0x12
        IMF B, 0x34
        SST A, 0
        SST B, 15
        IMF AR, 0x56
        CLF
        .byte 0xA0
        .byte 0xA1
        .byte 0xA2
        .byte 0xA3
        .byte 0xA4
        .byte 0xA5
        .byte 0xA6
        .byte 0xA7
        .byte 0xA8
        .byte 0xA9
        .byte 0xAA
        .byte 0xAB
        .byte 0xAC
        .byte 0xAD
        .byte 0xAE
        .byte 0xAF
        .byte 0xB0
        .byte 0xB1
        .byte 0xB2
        .byte 0xB3
        .byte 0xB4
        .byte 0xB5
        .byte 0xB6
        .byte 0xB7
        .byte 0xB8
        .byte 0xB9
        .byte 0xBA
        .byte 0xBB
        .byte 0xBC
        .byte 0xBD
        .byte 0xBE
        .byte 0xBF
        .byte 0xC0
        .byte 0xC1
        .byte 0xC2
        .byte 0xC3
        .byte 0xC4
        .byte 0xC5
        .byte 0xC6
        .byte 0xC7
        .byte 0xC8
        .byte 0xC9
        .byte 0xCA
        .byte 0xCB
        .byte 0xCC
        .byte 0xCD
        .byte 0xCE
        .byte 0xCF
        .byte 0x9C
        .byte 0x9D
        .byte 0x9E
        .byte 0x9F
        .byte 0xD0
        .byte 0xD1
        .byte 0xD2
        .byte 0xD3
        .byte 0xD4
        .byte 0xD5
        .byte 0xD6
        .byte 0xD7
        .byte 0xD9
        .byte 0xDA
        .byte 0xDB
        SLD A, 15
        SLD B, 0
        HALT
