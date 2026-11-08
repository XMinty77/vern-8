; random_mixed_5: random mixed code (seed 1011): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0xBC
        IMF B, 0x6A
        IMF AR, 0xEF
        STF
        JGTE L1
        LDB
        NOP
        SUB
        ILB 0xC
L1:
        NOP
        NOR
        DIV
        SSTA 8
        SSTB 4
        IMF A, 5
        SST A, 15
L2:
        XNOR
        NAND
        SHR
        MUL
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L2
        CALL sub1
        IMF AR, sub2
        CALL
        INVB
        .byte 0xAE
        IMF A, 4
        SST A, 15
L3:
        IMF AR, sub1
        CALL
        LTE
        .byte 0xA1
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        ADD
        SLDA 4
        SSTB 8
        IMF A, 0x00
        STF
        STA
        IHA 0x1
        CALL sub1
        NAND
        XOR
        ILA 0x2
        SSTA 4
        SUB
        ILA 0x5
        LTE
        CALL sub2
        MUL
        ILA 0x2
        XNOR
        ALO 0x9
        SLDB 3
        JGTE L4
        LD B, B
        LD B, AR
        SSTA 13
        NOR
L4:
        NOP
        SUB
        NOP
        NOP
        JLT L5
        AHI 0x2
        ILB 0xD
        SSTA 13
L5:
        SSTA 1
        XOR
        LDA
        SHL
        GTE
        NOP
        INVA
        IHA 0x1
        TAR
        OR
        IMF AR, sub0
        CALL
        IMF B, 0xDE
        SLDB 9
        INVA
        SSTB 1
        NOP
        LD B, B
        XOR
        AHI 0xD
        JF L6
        SHR
        OR
L6:
        SLDB 7
        INVB
        IMF AR, L7
        JLT AR
        SUB
        LDB
        LD B, AR
        LDB
L7:
        HALT
sub0:
        NOP
        SSTB 11
        INVA
        ADD
        JEQ L8
        STF
L8:
        ST B, 0x62
        DIV
        IMF AR, sub2
        CALL
        JNEQ L9
        SUB
        ADD
        XNOR
        STA
L9:
        RET
sub1:
        CALL sub2
        IMF AR, sub2
        CALL
        ILB 0x3
        SWAP
        XNOR
        CALL sub2
        IMF AR, sub2
        CALL
        SLDA 7
        STF
        INVA
        JF L10
        XOR
        XNOR
L10:
        RET
sub2:
        ST B, B
        ADD
        JEQ L11
        STB
        SUB
L11:
        .byte 0xAE
        SSTA 3
        IMF B, 0x00
        LTE
        .byte 0xAA
        ALO 0x3
        SUB
        NOP
        JMP L12
        SLDA 10
        LD A, B
        SLDB 15
        DIV
L12:
        RET
        HALT
