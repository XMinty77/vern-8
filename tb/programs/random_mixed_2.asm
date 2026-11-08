; random_mixed_2: random mixed code (seed 1007): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x4C
        IMF B, 0x1B
        IMF AR, 0x2A
        STF
        IMF AR, sub1
        CALL
        INVB
        IMF B, 0x01
        XNOR
        ADD
        IMF AR, sub0
        CALL
        SLDB 9
        IMF A, 2
        SST A, 15
L1:
        INVA
        CALL sub1
        INVB
        CLF
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        CALL sub0
        IHA 0xF
        CALL sub0
        MUL
        XOR
        LD B, 0x10
        IMF A, 4
        SST A, 15
L2:
        TAR
        SHL
        IHA 0x2
        SWAP
        LD B, A
        NOP
        LDB
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L2
        INVA
        NOP
        SHL
        XOR
        SLDA 5
        SLDB 2
        SUB
        SHR
        SHR
        SSTA 7
        NOP
        JLT L3
        .byte 0xCF
L3:
        JNEQ L4
        SSTA 0
        INVB
        SSTA 5
L4:
        CLF
        LDB
        JEQ L5
        LDB
        SHL
L5:
        IMF AR, sub1
        CALL
        JGTE L6
        LDA
L6:
        IMF AR, L7
        JF
        TAR
        ADD
        SUB
        LTE
L7:
        SWAP
        IMF B, 0xFF
        EQ
        AND
        JGT L8
        NOP
        SHR
        INVA
        IMF B, 0x7F
L8:
        STB
        STA
        SSTA 12
        IMF AR, sub1
        CALL
        DIV
        AHI 0xD
        INC
        SLDB 6
        ST A, B
        IHB 0xE
        CALL sub0
        HALT
sub0:
        SLDB 10
        GT
        IMF AR, L9
        JNEQ AR
        STB
L9:
        SHL
        XOR
        SSTB 11
        STB
        TAR
        SLDB 4
        IMF AR, L10
        JF
        STF
        XNOR
        SLDB 12
        IMF AR, 0x01
L10:
        IMF AR, sub1
        CALL
        SSTA 5
        CALL sub1
        CALL sub1
        IMF A, 0x80
        LDA
        JMP L11
        IMF B, 0x01
L11:
        RET
sub1:
        JMP L12
        SHR
L12:
        SSTA 2
        IMF AR, L13
        JGTE AR
        ST A, B
L13:
        IMF AR, 0xFF
        SLDB 8
        OR
        SUB
        LDB
        SSTA 11
        IMF AR, L14
        JF
        INVB
        NOP
L14:
        IMF AR, L15
        JF
        SSTA 11
L15:
        JFE L16, L17
        IMF B, 0xFF
        SLDA 1
        ST A, A
L17:
        TAR
        IHA 0xD
        SWAP
        NEQ
L16:
        RET
        HALT
