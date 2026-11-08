; mem_long_extremes: LDA, LDB, STA, STB through AR at address extremes and boundaries
; (00 01 0F 10 11 7F 80 81 EF F0 FE FF): store, read back in another order,
; overwrite, store then load at once; aliasing of short (SLD/SST) and long
; addresses on 0 to F, and 0x10 not aliasing short address 0.

        ; STA at each address with a distinct value, AR set with IMF
        IMF AR, 0x00
        IMF A, 0x3C
        STA
        IMF AR, 0x01
        IMF A, 0x3D
        STA
        IMF AR, 0x0F
        IMF A, 0x33
        STA
        IMF AR, 0x10
        IMF A, 0x2C
        STA
        IMF AR, 0x11
        IMF A, 0x2D
        STA
        IMF AR, 0x7F
        IMF A, 0x43
        STA
        IMF AR, 0x80
        IMF A, 0xBC
        STA
        IMF AR, 0x81
        IMF A, 0xBD
        STA
        IMF AR, 0xEF
        IMF A, 0xD3
        STA
        IMF AR, 0xF0
        IMF A, 0xCC
        STA
        IMF AR, 0xFE
        IMF A, 0xC2
        STA
        IMF AR, 0xFF
        IMF A, 0xC3
        STA
        ; LDB from each, in reverse order
        IMF AR, 0xFF
        LDB
        IMF AR, 0xFE
        LDB
        IMF AR, 0xF0
        LDB
        IMF AR, 0xEF
        LDB
        IMF AR, 0x81
        LDB
        IMF AR, 0x80
        LDB
        IMF AR, 0x7F
        LDB
        IMF AR, 0x11
        LDB
        IMF AR, 0x10
        LDB
        IMF AR, 0x0F
        LDB
        IMF AR, 0x01
        LDB
        IMF AR, 0x00
        LDB
        ; STB overwrites, LDA reads back immediately
        IMF AR, 0x00
        IMF B, 0xFF
        STB
        LDA
        IMF AR, 0x01
        IMF B, 0xFE
        STB
        LDA
        IMF AR, 0x0F
        IMF B, 0xF0
        STB
        LDA
        IMF AR, 0x10
        IMF B, 0xEF
        STB
        LDA
        IMF AR, 0x11
        IMF B, 0xEE
        STB
        LDA
        IMF AR, 0x7F
        IMF B, 0x80
        STB
        LDA
        IMF AR, 0x80
        IMF B, 0x7F
        STB
        LDA
        IMF AR, 0x81
        IMF B, 0x7E
        STB
        LDA
        IMF AR, 0xEF
        IMF B, 0x10
        STB
        LDA
        IMF AR, 0xF0
        IMF B, 0x0F
        STB
        LDA
        IMF AR, 0xFE
        IMF B, 0x01
        STB
        LDA
        IMF AR, 0xFF
        IMF B, 0x00
        STB
        LDA
        ; short and long addressing alias on 0-F: SST then LD via AR, ST via AR then SLD
        IMF A, 0x11
        SST A, 0
        IMF AR, 0x00
        LDB
        IMF A, 0x22
        IMF AR, 0x0F
        STA
        SLD B, 15
        ; 0x10 is not short address 0: M[0x10] must still hold its value
        IMF AR, 0x10
        LDA
        SLD B, 0
        HALT
