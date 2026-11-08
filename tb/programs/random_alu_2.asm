; random_alu_2: random straight-line code (seed 1002): ALU and flag ops, nibble writes, IMF,
; short and long loads and stores in every assembler form, TAR, undefined opcodes,
; NOP. All data memory is filled first so any address can be read.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x7E
        IMF B, 0x89
        IMF AR, 0xC2
        STF
        MUL
        ADD
        ILA 0x7
        LDB
        IMF A, 0xFF
        SLDB 2
        ST B, A
        ILA 0x2
        .byte 0xC6
        IMF A, 0xFD
        STA
        .byte 0xA5
        INVB
        STA
        SSTA 1
        INC
        OR
        IHA 0x9
        EQ
        ADD
        NOP
        XOR
        NOP
        NOR
        IHB 0x4
        NAND
        XOR
        NOP
        NOP
        STF
        SLDB 4
        ILB 0x2
        NOP
        STB
        TAR
        LTE
        ADD
        SUB
        GT
        XNOR
        LD A, 0x96
        XOR
        .byte 0xBA
        IHB 0x0
        IMF A, 0x7F
        SLDA 13
        LDA
        AHI 0x0
        IMF A, 0x00
        LD B, B
        ADD
        ILB 0x2
        INVB
        SLDB 9
        NAND
        ILA 0x7
        .byte 0xAE
        IHA 0x7
        SWAP
        LT
        .byte 0xB0
        SLDA 5
        LDA
        XNOR
        SLDA 0
        GTE
        SSTA 3
        SHL
        OR
        LDA
        ST A, AR
        TAR
        SWAP
        STA
        ALO 0x9
        XOR
        INVA
        NOP
        DIV
        SHL
        SLDB 12
        SHR
        NEQ
        XNOR
        IMF AR, 0x01
        SSTB 3
        NOR
        NOP
        SUB
        SHR
        AHI 0x4
        LTE
        SHR
        NOP
        .byte 0xDB
        SLDB 1
        IMF A, 0x80
        INVB
        ST B, AR
        SLDB 13
        IHA 0x0
        SLDB 14
        SSTB 2
        OR
        SHR
        SLDA 12
        NOR
        GT
        STA
        INVB
        ALO 0xE
        IMF A, 0x01
        NOP
        SSTB 7
        SLDB 12
        INVB
        SLDB 10
        AHI 0x9
        LDB
        NOP
        IHA 0x6
        TAR
        ILB 0x9
        LD A, A
        INVB
        NEQ
        LTE
        IMF B, 0x80
        SLDB 0
        LD A, 0x8E
        ST A, A
        NEQ
        NAND
        AND
        SSTB 12
        SSTB 10
        SHR
        IMF A, 0xFF
        GT
        GT
        LDA
        SSTA 2
        LD B, A
        LDB
        SLDA 1
        LDA
        AND
        SLDB 12
        AHI 0xA
        IHB 0x5
        ADD
        SLDB 5
        INVB
        SHR
        SLDB 2
        NOP
        SSTB 14
        ILB 0x5
        SHL
        SLDB 2
        MUL
        SLDA 4
        SHR
        .byte 0xCC
        AHI 0x5
        SWAP
        OR
        LTE
        AND
        XNOR
        ADD
        DIV
        .byte 0xB6
        ILB 0x3
        IMF AR, 0x00
        LDA
        XNOR
        ST B, 0xFF
        INVB
        IMF B, 0x00
        INVA
        ADD
        ILB 0xC
        SHR
        HALT
        HALT
