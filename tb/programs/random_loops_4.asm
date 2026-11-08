; random_loops_4: random loop-heavy code (seed 1071): bounded loops (counter in M[F]) with random
; bodies, forward branches and subroutine calls inside loops.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x1D
        IMF B, 0xA9
        IMF AR, 0xAF
        CLF
        LDA
        STB
        IMF A, 4
        SST A, 15
L1:
        INVA
        NOR
        NOP
        SSTB 2
        ADD
        CALL sub0
        CALL sub0
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L1
        IMF A, 5
        SST A, 15
L2:
        SSTA 8
        TAR
        SWAP
        LD B, 0xFF
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L2
        DIV
        JGTE L3
        IMF AR, 0x4A
        .byte 0xB1
        ST B, AR
L3:
        ALO 0xE
        IMF A, 2
        SST A, 15
L4:
        NOP
        SHL
        IMF AR, 0x25
        LD A, B
        TAR
        DIV
        LD A, A
        INC
        IHB 0xB
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L4
        NOR
        IMF AR, sub1
        CALL
        IMF AR, L5
        JF
        SSTB 1
        OR
L5:
        JNEQ L6
        .byte 0xBC
L6:
        JGT L7
        XNOR
        .byte 0xD4
        STA
        IHB 0xB
L7:
        ILB 0x9
        IMF A, 4
        SST A, 15
L8:
        SLDB 12
        SLDA 8
        LD A, A
        CALL sub1
        .byte 0xB0
        SUB
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L8
        IMF A, 3
        SST A, 15
L9:
        LD A, AR
        IMF A, 0x7F
        .byte 0xCF
        GT
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L9
        HALT
sub0:
        JMP L10
        DIV
L10:
        SSTB 9
        CALL sub1
        SHR
        JGT L11
        SHL
        IMF A, 0x80
L11:
        IMF AR, L12
        JF
        SWAP
L12:
        SWAP
        IMF B, 0xFF
        JFE L13, L14
        INC
L14:
        SSTB 6
        STA
        GT
L13:
        JGT L15
        LD A, AR
        MUL
        ILA 0x8
L15:
        RET
sub1:
        IMF A, 0x00
        JF L16
        INC
L16:
        OR
        XNOR
        JF L17
        OR
        IMF AR, 0x9A
        SLDB 15
L17:
        JF L18
        ADD
        IMF B, 0x7F
        INVA
        XOR
L18:
        SWAP
        SSTB 4
        EQ
        SSTA 11
        LD B, AR
        SSTA 1
        IMF AR, L19
        JF
        IMF AR, 0x7F
L19:
        INVA
        RET
        HALT
