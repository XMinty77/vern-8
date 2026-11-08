; undef_from_reset: all 63 undefined opcodes executed straight from reset, with A, B, AR, F and
; data memory still unknown: an undefined opcode reads nothing, so this is
; valid and everything must stay unknown. Then NOP (the assembler form, 0xA0).

        .byte 0xA0
        .byte 0xA2
        .byte 0xA4
        .byte 0xA6
        .byte 0xA8
        .byte 0xAA
        .byte 0xAC
        .byte 0xAE
        .byte 0xB0
        .byte 0xB2
        .byte 0xB4
        .byte 0xB6
        .byte 0xB8
        .byte 0xBA
        .byte 0xBC
        .byte 0xBE
        .byte 0xC0
        .byte 0xC2
        .byte 0xC4
        .byte 0xC6
        .byte 0xC8
        .byte 0xCA
        .byte 0xCC
        .byte 0xCE
        .byte 0x9C
        .byte 0x9E
        .byte 0xD0
        .byte 0xD2
        .byte 0xD4
        .byte 0xD6
        .byte 0xD9
        .byte 0xDB
        .byte 0xA1
        .byte 0xA3
        .byte 0xA5
        .byte 0xA7
        .byte 0xA9
        .byte 0xAB
        .byte 0xAD
        .byte 0xAF
        .byte 0xB1
        .byte 0xB3
        .byte 0xB5
        .byte 0xB7
        .byte 0xB9
        .byte 0xBB
        .byte 0xBD
        .byte 0xBF
        .byte 0xC1
        .byte 0xC3
        .byte 0xC5
        .byte 0xC7
        .byte 0xC9
        .byte 0xCB
        .byte 0xCD
        .byte 0xCF
        .byte 0x9D
        .byte 0x9F
        .byte 0xD1
        .byte 0xD3
        .byte 0xD5
        .byte 0xD7
        .byte 0xDA
        NOP
        nop
        HALT
