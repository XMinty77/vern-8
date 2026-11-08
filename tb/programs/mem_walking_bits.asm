; mem_walking_bits: walking one (01..80) stored at 55..5C and walking zero (FE..7F) at AA..B1,
; every data bit set and cleared alone, read back into A and B.

        IMF A, 0x01
        IMF AR, 0x55
        STA
        INV A
        IMF AR, 0xAA
        STA
        IMF A, 0x02
        IMF AR, 0x56
        STA
        INV A
        IMF AR, 0xAB
        STA
        IMF A, 0x04
        IMF AR, 0x57
        STA
        INV A
        IMF AR, 0xAC
        STA
        IMF A, 0x08
        IMF AR, 0x58
        STA
        INV A
        IMF AR, 0xAD
        STA
        IMF A, 0x10
        IMF AR, 0x59
        STA
        INV A
        IMF AR, 0xAE
        STA
        IMF A, 0x20
        IMF AR, 0x5A
        STA
        INV A
        IMF AR, 0xAF
        STA
        IMF A, 0x40
        IMF AR, 0x5B
        STA
        INV A
        IMF AR, 0xB0
        STA
        IMF A, 0x80
        IMF AR, 0x5C
        STA
        INV A
        IMF AR, 0xB1
        STA
        ; read everything back into both registers
        IMF AR, 0x55
        LDA
        IMF AR, 0xAA
        LDB
        IMF AR, 0x56
        LDA
        IMF AR, 0xAB
        LDB
        IMF AR, 0x57
        LDA
        IMF AR, 0xAC
        LDB
        IMF AR, 0x58
        LDA
        IMF AR, 0xAD
        LDB
        IMF AR, 0x59
        LDA
        IMF AR, 0xAE
        LDB
        IMF AR, 0x5A
        LDA
        IMF AR, 0xAF
        LDB
        IMF AR, 0x5B
        LDA
        IMF AR, 0xB0
        LDB
        IMF AR, 0x5C
        LDA
        IMF AR, 0xB1
        LDB
        HALT
