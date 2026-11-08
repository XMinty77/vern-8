; random_mixed_1: random mixed code (seed 1006): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x21
        IMF B, 0x44
        IMF AR, 0x7C
        STF
        IMF A, 2
        SST A, 15
L1:
        SLDA 9
        SLDA 12
        INVB
        NOP
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        TAR
        JLT L2
        XOR
L2:
        LDB
        NEQ
        AHI 0x5
        ILB 0xD
        STA
        NOP
        NOR
        SSTA 13
        JGTE L3
        IMF A, 0x7B
        EQ
        IHB 0x2
L3:
        OR
        ILA 0xC
        SLDA 15
        JMP L4
        AND
        NOP
        IMF B, 0xFF
        ADD
L4:
        XOR
        LD B, 0x08
        IMF AR, sub2
        CALL
        NOR
        JFE L5, L6
        ILA 0xA
L6:
        CLF
        INVA
        LDB
L5:
        IMF AR, L7
        JLTE AR
        SHR
        IHA 0x8
        LDB
L7:
        SHR
        JNEQ L8
        .byte 0xAA
        .byte 0xD3
L8:
        SLDB 10
        JF L9
        IMF A, 0x00
        SHL
L9:
        CALL sub1
        IMF AR, 0x01
        SLDB 15
        ILA 0xC
        JMP L10
        NOP
        SLDB 4
        XNOR
        ILB 0xD
L10:
        NAND
        ILA 0xE
        STB
        IMF AR, sub0
        CALL
        JEQ L11
        SLDA 6
        SLDA 12
L11:
        DIV
        NOP
        NOP
        SSTA 8
        IHB 0xA
        NAND
        IMF A, 4
        SST A, 15
L12:
        .byte 0xDA
        IMF AR, sub1
        CALL
        IMF AR, sub2
        CALL
        IHB 0xF
        NOP
        SSTB 13
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L12
        HALT
sub0:
        DIV
        INVA
        IMF AR, 0x80
        IMF AR, sub1
        CALL
        LT
        NOR
        GTE
        LDB
        IMF AR, sub1
        CALL
        INVA
        IMF AR, 0x01
        IHA 0xA
        SLDB 5
        GT
        LD B, AR
        STA
        RET
sub1:
        STF
        LT
        OR
        CALL sub2
        SSTA 12
        XNOR
        SLDB 14
        ILA 0x4
        SLDA 15
        GTE
        CLF
        ST B, AR
        IMF AR, sub2
        CALL
        IMF AR, sub2
        CALL
        ST B, 0x07
        RET
sub2:
        JGT L13
        IMF B, 0x77
        SSTA 0
        IHA 0xE
L13:
        IHB 0xE
        JF L14
        LDB
L14:
        GTE
        IMF AR, L15
        JF
        ALO 0x0
        SSTB 6
        SLDB 12
        ILA 0xF
L15:
        LDB
        RET
        HALT
