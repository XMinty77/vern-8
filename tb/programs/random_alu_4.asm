; random_alu_4: random straight-line code (seed 1004): ALU and flag ops, nibble writes, IMF,
; short and long loads and stores in every assembler form, TAR, undefined opcodes,
; NOP. All data memory is filled first so any address can be read.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x92
        IMF B, 0xEA
        IMF AR, 0x5D
        CLF
        SLDA 6
        MUL
        GTE
        INVA
        OR
        XNOR
        NOP
        NOP
        INVA
        SSTB 4
        TAR
        AHI 0xC
        MUL
        DIV
        NOR
        SLDA 9
        STF
        SHR
        ILA 0xE
        INC
        STF
        AND
        ADD
        IHB 0xA
        SSTB 12
        .byte 0xD5
        SSTA 9
        IMF A, 0x01
        ILA 0x0
        NOR
        IMF AR, 0x10
        STA
        CLF
        GT
        LT
        IMF AR, 0x13
        SHL
        LD A, AR
        AHI 0x3
        SSTA 8
        NOR
        EQ
        SLDB 14
        SLDA 15
        ALO 0xC
        NOR
        DIV
        NEQ
        IHB 0x4
        SSTA 6
        AND
        NOP
        NOP
        LDA
        SSTA 14
        IMF AR, 0x7F
        INVA
        INVB
        IMF A, 0x80
        SHL
        IMF AR, 0x7F
        IMF A, 0x07
        ST B, B
        SSTA 0
        SLDB 11
        SWAP
        SSTB 0
        LDA
        ALO 0x3
        SHR
        STA
        ILA 0xB
        EQ
        NEQ
        IMF AR, 0x7F
        ADD
        LD A, AR
        XOR
        SLDA 2
        XNOR
        ADD
        ST A, 0x05
        SWAP
        INC
        IHB 0x7
        TAR
        .byte 0xC1
        IHA 0x8
        EQ
        IHB 0x0
        LD A, B
        .byte 0xAC
        SLDB 0
        XOR
        LD A, AR
        NOP
        .byte 0xC6
        SWAP
        ALO 0xA
        IMF B, 0x00
        ADD
        SHL
        IMF AR, 0x7F
        SLDB 12
        LD A, 0x05
        SLDA 5
        ILB 0x9
        ILB 0x6
        LD A, A
        MUL
        ST A, B
        SLDB 5
        TAR
        XNOR
        NOR
        SSTA 12
        ST B, A
        IMF AR, 0x7F
        SLDA 4
        SSTA 3
        AND
        NOP
        LD A, A
        DIV
        STB
        IHB 0xF
        IMF B, 0xFF
        XNOR
        IMF AR, 0x80
        NOP
        NAND
        AHI 0x0
        LT
        NOP
        SLDA 11
        IMF A, 0xFF
        SUB
        NOP
        TAR
        LT
        IMF B, 0x00
        IHB 0x7
        ILB 0x9
        NOR
        SWAP
        SSTA 14
        .byte 0xA5
        OR
        SLDA 6
        INC
        NOR
        NOR
        EQ
        ST B, AR
        IMF A, 0x00
        SWAP
        AHI 0x6
        SSTB 10
        IMF B, 0x80
        NOP
        LD B, 0x0B
        TAR
        MUL
        MUL
        SLDA 6
        ILB 0xF
        LD B, AR
        AHI 0x2
        AHI 0x5
        ALO 0x8
        .byte 0xB7
        NOP
        AHI 0x6
        HALT
        HALT
