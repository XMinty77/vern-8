; random_alu_3: random straight-line code (seed 1003): ALU and flag ops, nibble writes, IMF,
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
        IMF B, 0xE2
        IMF AR, 0x92
        CLF
        SSTB 7
        SSTB 1
        ILB 0xA
        AHI 0x1
        SSTA 8
        SSTA 8
        GTE
        LDA
        .byte 0xD2
        GTE
        SWAP
        MUL
        SLDB 5
        LTE
        CLF
        XNOR
        INC
        AHI 0xA
        LD A, 0x0B
        NOP
        XOR
        AHI 0x0
        AHI 0xB
        IHB 0x5
        STB
        EQ
        ILA 0x3
        TAR
        ADD
        OR
        TAR
        NOP
        CLF
        NEQ
        IHA 0xF
        OR
        EQ
        .byte 0xB5
        NOP
        SLDA 9
        LDA
        ST B, 0x45
        STA
        SWAP
        LTE
        INVB
        XOR
        SSTA 10
        .byte 0xB6
        GTE
        MUL
        IMF B, 0x7F
        .byte 0xC9
        SLDB 9
        CLF
        SSTB 9
        INVA
        LD B, A
        IHB 0xC
        SLDA 14
        ST A, AR
        SLDA 15
        AND
        IMF B, 0xFF
        SLDA 14
        LTE
        XNOR
        LDB
        NAND
        AHI 0x8
        LTE
        SLDB 1
        ST B, 0xFF
        IMF AR, 0x01
        LD A, AR
        SWAP
        OR
        NOP
        IHA 0xC
        ALO 0x3
        NOP
        SLDA 4
        LD A, AR
        SLDB 15
        IHB 0xD
        SSTA 13
        AND
        DIV
        NAND
        IMF B, 0xBF
        IHB 0xD
        ILA 0xB
        LDA
        NAND
        INVA
        CLF
        ILB 0x0
        ALO 0x4
        ADD
        LD A, A
        SHR
        CLF
        LD A, 0x04
        AND
        NOR
        STA
        SLDB 5
        SLDB 13
        AHI 0xA
        SHL
        .byte 0xC4
        GTE
        STB
        OR
        STF
        GTE
        LTE
        IMF A, 0x00
        LD B, A
        SLDA 3
        NEQ
        SHR
        NEQ
        STB
        OR
        SSTB 10
        IMF AR, 0xFF
        SSTB 5
        NOP
        IMF AR, 0x80
        TAR
        STB
        IMF AR, 0x01
        OR
        ST B, 0x09
        NAND
        DIV
        .byte 0x9E
        IMF AR, 0x7F
        TAR
        SWAP
        IMF AR, 0x7F
        NAND
        AND
        LD A, AR
        NOP
        LD A, 0x0D
        SLDA 5
        STB
        MUL
        EQ
        LDB
        STF
        IMF A, 0x01
        SSTA 6
        TAR
        AHI 0x8
        SHR
        SWAP
        SSTB 1
        SSTB 8
        SSTA 1
        NOP
        IMF A, 0x27
        SSTA 0
        IMF AR, 0xFF
        ILB 0x2
        ALO 0x1
        IMF A, 0x80
        .byte 0xCB
        SLDA 0
        MUL
        XOR
        ADD
        NAND
        AHI 0xC
        NOP
        IMF A, 0x01
        HALT
        HALT
