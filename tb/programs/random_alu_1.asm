; random_alu_1: random straight-line code (seed 1001): ALU and flag ops, nibble writes, IMF,
; short and long loads and stores in every assembler form, TAR, undefined opcodes,
; NOP. All data memory is filled first so any address can be read.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0xCD
        IMF B, 0x5B
        IMF AR, 0xB9
        STF
        XOR
        ILB 0xC
        INVB
        .byte 0xCF
        SSTA 10
        SSTA 9
        LD B, AR
        ILA 0xC
        CLF
        LD A, 0x10
        LDA
        NOP
        NOR
        STA
        IMF A, 0x80
        ILB 0xF
        SLDB 1
        SHR
        STB
        INVA
        SWAP
        ILB 0x3
        LTE
        LDB
        STB
        ALO 0xA
        STB
        SWAP
        NAND
        SUB
        INC
        SHL
        .byte 0xD3
        OR
        AHI 0x2
        SHL
        IMF B, 0x01
        AHI 0x2
        ILB 0x9
        NOP
        .byte 0xBB
        ILB 0x6
        LD B, B
        MUL
        .byte 0xB8
        LD A, B
        EQ
        AHI 0xE
        DIV
        IMF AR, 0xFF
        SLDB 6
        STB
        INC
        SSTB 9
        SUB
        SLDA 3
        IMF A, 0x00
        NAND
        MUL
        SHR
        OR
        SHR
        IMF B, 0x7F
        INVA
        SUB
        OR
        ST B, 0x4E
        SHL
        IMF A, 0x80
        LD B, 0xFF
        ILA 0x8
        AND
        GT
        GT
        .byte 0xA3
        NOP
        IMF A, 0xCD
        .byte 0xBE
        LDA
        SSTB 11
        IMF AR, 0x7F
        LDB
        ALO 0xF
        EQ
        SSTB 7
        NOP
        IMF A, 0x62
        AND
        IMF A, 0x80
        .byte 0xD5
        SSTA 9
        MUL
        DIV
        GT
        NOP
        INVA
        ALO 0x5
        STB
        IHB 0x4
        INC
        SUB
        OR
        XNOR
        SLDA 15
        IMF AR, 0x01
        ALO 0xF
        INVA
        SSTB 7
        ALO 0xD
        STB
        DIV
        IMF A, 0x01
        ST B, A
        SWAP
        OR
        LDA
        STA
        IMF B, 0xFF
        ALO 0x2
        AND
        TAR
        STA
        ILB 0xC
        ST A, 0x06
        LD B, AR
        NAND
        NOP
        STB
        IMF AR, 0x00
        CLF
        NOP
        SLDA 11
        ALO 0xA
        SUB
        EQ
        AHI 0x8
        LD B, 0xFF
        MUL
        STB
        SHR
        SSTA 2
        LDB
        SSTB 8
        .byte 0xCA
        SHR
        ALO 0xB
        NOP
        IMF A, 0x68
        IMF A, 0x39
        IHB 0x8
        SLDB 15
        STB
        AND
        AND
        INVA
        .byte 0xAD
        .byte 0xBD
        NOR
        INVA
        XOR
        SHL
        SSTB 11
        LTE
        INVB
        IMF AR, 0xFF
        .byte 0xC4
        .byte 0xB4
        NOP
        IMF A, 0x13
        STA
        LDA
        INC
        SLDA 3
        HALT
        HALT
