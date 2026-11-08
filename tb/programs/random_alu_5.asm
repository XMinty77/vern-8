; random_alu_5: random straight-line code (seed 1005): ALU and flag ops, nibble writes, IMF,
; short and long loads and stores in every assembler form, TAR, undefined opcodes,
; NOP. All data memory is filled first so any address can be read.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0xE3
        IMF B, 0xD2
        IMF AR, 0x3F
        CLF
        LD B, A
        OR
        INVB
        IMF A, 0x98
        INC
        SLDB 6
        IMF B, 0x01
        NAND
        SHR
        GT
        NOP
        XOR
        TAR
        .byte 0xC2
        SSTA 13
        INVA
        ADD
        IHA 0xA
        XOR
        EQ
        IMF A, 0xFF
        .byte 0xC1
        IMF AR, 0x00
        EQ
        IMF B, 0x81
        EQ
        SLDA 14
        SLDA 15
        IMF B, 0x00
        LDB
        ALO 0x5
        IMF AR, 0x00
        NEQ
        NOP
        SSTA 3
        IHB 0xA
        LTE
        SLDB 9
        IMF B, 0x7F
        STF
        TAR
        SLDB 3
        SLDA 15
        IMF B, 0xFF
        IHA 0x5
        IMF B, 0x7F
        NOP
        AHI 0xC
        ST A, 0xFF
        ALO 0x5
        DIV
        LDB
        EQ
        ILA 0x3
        INC
        .byte 0xA0
        XNOR
        NOR
        ST A, 0x35
        .byte 0xA1
        ALO 0x5
        .byte 0xC7
        IMF AR, 0x7F
        IHB 0x9
        ALO 0x9
        .byte 0x9C
        EQ
        SLDB 11
        SHR
        SWAP
        IMF B, 0x80
        CLF
        CLF
        SLDA 3
        NEQ
        DIV
        IHB 0x7
        IHA 0xB
        OR
        DIV
        OR
        LD A, AR
        SHL
        ILB 0x5
        NOP
        LD B, AR
        SUB
        IMF A, 0x01
        LTE
        SLDB 12
        ADD
        .byte 0xAE
        STB
        AND
        INVA
        SSTA 1
        MUL
        OR
        OR
        .byte 0xA1
        ILB 0x0
        SLDA 5
        ALO 0xC
        LDB
        AHI 0x0
        INVA
        IMF AR, 0x00
        GT
        SUB
        SSTA 4
        SSTA 9
        IMF B, 0xFF
        IMF AR, 0x7F
        NOP
        NEQ
        STA
        ALO 0xE
        SLDB 7
        NAND
        NOR
        CLF
        IMF B, 0x7F
        INVA
        SSTA 8
        LD A, B
        LDA
        IHA 0x9
        LDB
        STF
        STB
        NOP
        .byte 0xCF
        ILB 0xF
        TAR
        .byte 0xA1
        LDA
        NAND
        XNOR
        AHI 0x4
        NOP
        NOP
        DIV
        LD B, AR
        INVA
        SSTB 4
        LD A, 0x04
        ALO 0xB
        SHR
        SLDB 12
        NEQ
        ALO 0x7
        TAR
        IMF AR, 0x00
        TAR
        TAR
        LTE
        LD B, AR
        SSTA 2
        SLDA 11
        SLDA 10
        LD B, A
        STA
        MUL
        LD B, A
        IMF AR, 0x80
        IHA 0x0
        DIV
        ILA 0x0
        GTE
        SLDA 14
        INVB
        LTE
        STA
        LD A, AR
        IHB 0x8
        GTE
        SLDB 4
        HALT
        HALT
