; random_loops_1: random loop-heavy code (seed 1068): bounded loops (counter in M[F]) with random
; bodies, forward branches and subroutine calls inside loops.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x7D
        IMF B, 0xD9
        IMF AR, 0x48
        CLF
        IMF A, 4
        SST A, 15
L1:
        XNOR
        OR
        DIV
        LD B, AR
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        SLDB 2
        NOP
        IMF AR, sub0
        CALL
        JGT L2
        XOR
        NOP
        LD B, B
        NOP
L2:
        IMF AR, sub1
        CALL
        .byte 0xA5
        CALL sub1
        NOP
        IMF A, 3
        SST A, 15
L3:
        INC
        SSTB 10
        .byte 0xA1
        MUL
        SLDB 1
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        IMF A, 0x01
        LD B, A
        NOP
        IMF A, 2
        SST A, 15
L4:
        AHI 0x8
        ILB 0x0
        CALL sub1
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L4
        CALL sub1
        JNEQ L5
        TAR
        SHL
L5:
        IMF A, 3
        SST A, 15
L6:
        LDA
        AND
        .byte 0xB2
        IMF AR, sub0
        CALL
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L6
        IMF A, 5
        SST A, 15
L7:
        AND
        STF
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L7
        SLDB 14
        INVA
        IMF A, 2
        SST A, 15
L8:
        SLDB 14
        GT
        NAND
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L8
        HALT
sub0:
        IMF AR, sub1
        CALL
        NOP
        ST B, AR
        .byte 0xC1
        CALL sub1
        XNOR
        IMF AR, sub1
        CALL
        IMF AR, sub1
        CALL
        NOP
        TAR
        CALL sub1
        SWAP
        SLDB 13
        SHR
        SSTB 7
        CALL sub1
        JF L9
        XNOR
        IMF AR, 0x00
        LDA
        SWAP
L9:
        RET
sub1:
        JF L10
        XNOR
L10:
        ST B, AR
        JF L11
        SLDB 10
        LD A, 0x10
L11:
        XOR
        XOR
        IMF AR, L12
        JGTE AR
        NOR
        LDB
        SLDA 15
L12:
        IMF AR, 0x80
        JEQ L13
        GTE
        ADD
        SSTB 12
        DIV
L13:
        SLDB 7
        SSTB 12
        IMF AR, L14
        JF
        LD A, B
L14:
        RET
        HALT
