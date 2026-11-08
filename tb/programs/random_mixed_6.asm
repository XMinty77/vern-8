; random_mixed_6: random mixed code (seed 1012): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x4B
        IMF B, 0x68
        IMF AR, 0x6C
        CLF
        IMF AR, sub0
        CALL
        SLDB 6
        ILA 0xC
        INC
        ILB 0x5
        IMF A, 5
        SST A, 15
L1:
        SLDB 7
        DIV
        .byte 0xD6
        INVB
        CALL sub2
        .byte 0xD5
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        JLTE L2
        IMF AR, 0x80
        IHB 0x3
L2:
        SLDA 11
        SSTA 0
        .byte 0xAE
        JEQ L3
        .byte 0xC2
        ILB 0x0
        NOP
L3:
        XOR
        SLDB 10
        CALL sub1
        DIV
        NOP
        NOP
        IMF A, 5
        SST A, 15
L4:
        NOP
        LD A, B
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L4
        IMF AR, sub2
        CALL
        IHB 0xE
        NOP
        NOP
        OR
        JFE L5, L6
        NAND
L6:
        LDA
        TAR
        AHI 0x4
L5:
        NOP
        TAR
        GT
        SLDB 0
        MUL
        LDA
        CALL sub0
        SLDB 0
        JMP L7
        OR
        INVA
        LT
        NOR
L7:
        GTE
        JGT L8
        SLDA 8
        XOR
        NOP
        ALO 0x8
L8:
        SLDA 1
        NOP
        JFE L9, L10
        LDA
        .byte 0xD7
        DIV
L10:
        SSTB 12
        .byte 0xA2
L9:
        GTE
        ILB 0xC
        LD A, A
        IMF AR, sub2
        CALL
        LD B, 0xFF
        IHB 0x9
        JF L11
        ST A, 0xFF
        DIV
        SSTA 5
L11:
        HALT
sub0:
        CALL sub1
        SSTA 4
        ILB 0x6
        ADD
        MUL
        SUB
        SLDB 6
        SSTA 1
        CALL sub2
        NOR
        LD B, AR
        IMF AR, sub1
        CALL
        XOR
        CALL sub2
        RET
sub1:
        AND
        ST B, B
        CALL sub2
        CLF
        TAR
        IMF A, 0x80
        MUL
        IMF AR, sub2
        CALL
        CALL sub2
        CALL sub2
        RET
sub2:
        JMP L12
        IHB 0x3
        IHB 0x0
        ST A, AR
L12:
        .byte 0xAB
        LDB
        SUB
        GTE
        JMP L13
        IMF AR, 0x80
L13:
        JGT L14
        MUL
        NAND
L14:
        RET
        HALT
