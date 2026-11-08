; random_mixed_3: random mixed code (seed 1008): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x9D
        IMF B, 0x99
        IMF AR, 0xCA
        CLF
        SSTA 14
        JFE L1, L2
        ST A, A
L2:
        SHR
        INVB
        SUB
L1:
        NEQ
        INC
        ST A, B
        LDA
        ALO 0xA
        SLDB 11
        GTE
        INC
        STF
        INVB
        SSTB 1
        INVB
        AHI 0xB
        IMF A, 4
        SST A, 15
L3:
        IMF AR, sub1
        CALL
        NOR
        SLDA 0
        OR
        SSTB 11
        OR
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        LD B, AR
        CALL sub3
        ALO 0xD
        JLTE L4
        IHA 0x6
        INVA
        IMF AR, 0x80
L4:
        ADD
        STA
        STB
        JF L5
        SUB
        LDA
        AND
        GT
L5:
        IMF B, 0xFF
        OR
        NOP
        JF L6
        EQ
L6:
        TAR
        GT
        AND
        INVB
        DIV
        .byte 0xBF
        NOP
        JFE L7, L8
        NAND
        SLDA 0
        LD A, 0x10
L8:
        NOP
        NEQ
        MUL
L7:
        IMF A, 0x01
        IMF A, 4
        SST A, 15
L9:
        IMF AR, sub0
        CALL
        IMF AR, sub3
        CALL
        SWAP
        DIV
        XNOR
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L9
        XOR
        NEQ
        SSTA 10
        IMF AR, L10
        JF
        XOR
L10:
        XNOR
        CALL sub0
        JLT L11
        DIV
        SLDB 7
L11:
        HALT
sub0:
        CALL sub3
        INC
        CALL sub3
        SSTA 3
        SSTA 4
        CALL sub1
        .byte 0xD1
        SSTA 2
        SSTA 12
        RET
sub1:
        CALL sub2
        IMF AR, 0x9F
        ILA 0xF
        IMF A, 0x01
        CLF
        .byte 0xB8
        XNOR
        LDB
        IMF A, 0x80
        TAR
        RET
sub2:
        MUL
        INVA
        LD A, 0x10
        ADD
        CALL sub3
        JGT L12
        ILB 0xD
L12:
        IMF AR, sub3
        CALL
        RET
sub3:
        SSTA 3
        JGT L13
        SWAP
        EQ
        NEQ
L13:
        SLDA 9
        JLT L14
        LDA
        IMF B, 0x80
        AND
        AND
L14:
        RET
        HALT
