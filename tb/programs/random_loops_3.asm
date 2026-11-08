; random_loops_3: random loop-heavy code (seed 1070): bounded loops (counter in M[F]) with random
; bodies, forward branches and subroutine calls inside loops.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0xC2
        IMF B, 0xD8
        IMF AR, 0x42
        STF
        IMF A, 2
        SST A, 15
L1:
        ADD
        CALL sub1
        ALO 0x6
        NOP
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        XOR
        IMF A, 5
        SST A, 15
L2:
        SLDB 1
        AHI 0xC
        SUB
        .byte 0xD2
        NOP
        ST A, 0xF7
        NOP
        ILA 0x0
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L2
        IMF A, 5
        SST A, 15
L3:
        SLDB 10
        TAR
        IMF AR, sub1
        CALL
        OR
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        IMF A, 3
        SST A, 15
L4:
        SSTA 7
        LD A, A
        .byte 0xCC
        AHI 0x4
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L4
        ILB 0x0
        SSTA 9
        SLDB 8
        NOP
        GTE
        ILA 0x5
        IMF A, 5
        SST A, 15
L5:
        SLDB 8
        ILB 0xA
        .byte 0xBD
        OR
        INC
        EQ
        CALL sub0
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L5
        IMF A, 2
        SST A, 15
L6:
        ILA 0x2
        SHR
        IMF A, 0x7F
        XNOR
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L6
        JLTE L7
        LD A, 0x1B
        IMF AR, 0x80
L7:
        IMF AR, L8
        JF
        ALO 0xC
        LDA
L8:
        HALT
sub0:
        XNOR
        XNOR
        DIV
        LTE
        INC
        CALL sub1
        SLDA 7
        IMF AR, sub1
        CALL
        GT
        ADD
        JF L9
        ILA 0x1
        ILB 0x7
L9:
        XNOR
        IMF AR, sub1
        CALL
        IMF AR, sub1
        CALL
        JEQ L10
        NOP
L10:
        SLDA 12
        SLDB 12
        SLDB 11
        IMF AR, sub1
        CALL
        RET
sub1:
        JNEQ L11
        SSTA 14
        ILB 0x5
L11:
        SSTB 7
        LDA
        STB
        NOP
        LT
        .byte 0xB3
        LTE
        IMF AR, L12
        JGTE AR
        SLDB 8
        NAND
        SHL
        TAR
L12:
        JGT L13
        ST A, A
        XNOR
        LD B, AR
L13:
        ILB 0x7
        NOR
        STB
        JF L14
        SLDB 13
        IHB 0xD
        ILA 0xE
L14:
        RET
        HALT
