; random_loops_2: random loop-heavy code (seed 1069): bounded loops (counter in M[F]) with random
; bodies, forward branches and subroutine calls inside loops.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0xEC
        IMF B, 0xA1
        IMF AR, 0xF6
        STF
        IMF A, 5
        SST A, 15
L1:
        IMF AR, sub0
        CALL
        SHL
        INC
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        JMP L2
        LDA
        SLDB 11
        LDA
        OR
L2:
        OR
        IMF A, 5
        SST A, 15
L3:
        SSTA 4
        TAR
        DIV
        OR
        INVB
        IMF AR, 0x01
        ST A, 0xFF
        NAND
        NOP
        NOP
        AND
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        INVB
        JGTE L4
        AHI 0x5
        GT
        .byte 0xAB
        XOR
L4:
        NOP
        INVB
        IMF A, 4
        SST A, 15
L5:
        AND
        IMF B, 0x01
        .byte 0xA2
        LD A, AR
        INVA
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L5
        IMF A, 4
        SST A, 15
L6:
        ILA 0xF
        XOR
        INVA
        CALL sub1
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L6
        TAR
        IMF AR, L7
        JF
        AND
        SHL
        LTE
L7:
        SLDB 5
        IMF A, 5
        SST A, 15
L8:
        SLDA 13
        SHR
        LD B, A
        CALL sub0
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L8
        IMF AR, L9
        JF
        ALO 0xE
L9:
        EQ
        JGTE L10
        INVA
        LTE
        NEQ
        IMF AR, 0x00
L10:
        HALT
sub0:
        .byte 0xD5
        STF
        SSTA 13
        SHR
        SWAP
        NOP
        NOP
        ILB 0xF
        JF L11
        SLDA 1
        SLDB 0
L11:
        DIV
        LDB
        OR
        JEQ L12
        NOR
        SLDB 10
        SWAP
L12:
        .byte 0xA8
        IMF AR, sub1
        CALL
        .byte 0xAC
        SLDA 8
        LDB
        JF L13
        ADD
        SHL
        XOR
L13:
        RET
sub1:
        SSTB 3
        DIV
        INVB
        JGTE L14
        XNOR
        INC
L14:
        XOR
        .byte 0x9D
        JFE L15, L16
        .byte 0xB4
        NAND
        IMF A, 0xE7
L16:
        OR
L15:
        NOP
        SHR
        NOP
        GTE
        .byte 0xCA
        LD A, AR
        JF L17
        GTE
L17:
        JNEQ L18
        ST B, AR
L18:
        RET
        HALT
