; random_mixed_4: random mixed code (seed 1010): straight-line instructions plus forward
; conditional jumps in every form (J<cond>, JF, JFE, JMP), bounded loops and
; calls into random subroutines that may call further ones.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x73
        IMF B, 0x50
        IMF AR, 0x85
        STF
        ADD
        IHA 0xD
        ST A, A
        SHR
        SSTA 8
        JF L1
        LDA
        DIV
        NOP
L1:
        NOP
        XNOR
        JMP L2
        INVB
L2:
        IMF A, 0x00
        IMF A, 2
        SST A, 15
L3:
        SWAP
        LTE
        NOP
        CALL sub3
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L3
        NEQ
        SSTB 13
        INVB
        IMF B, 0x00
        IMF AR, L4
        JF
        LD B, 0x5D
        ADD
        SLDA 14
        INVB
L4:
        IMF A, 3
        SST A, 15
L5:
        SLDA 8
        SWAP
        CALL sub3
        IHA 0x0
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L5
        IMF A, 5
        SST A, 15
L6:
        LD A, AR
        INC
        .byte 0xCC
        IHB 0xA
        STF
        LT
        IMF B, 0x7F
        CALL sub3
        SLD A, 15
        IMF B, 0xFF
        ADD
        SST A, 15
        IMF B, 0
        JNEQ L6
        SLDB 3
        NOP
        SLDA 2
        LDB
        JGT L7
        IHB 0xC
        SLDA 8
        NOP
L7:
        SLDB 2
        SSTB 7
        SSTA 9
        CALL sub0
        SSTB 1
        ALO 0x7
        SLDB 9
        CALL sub3
        IHA 0xD
        IHB 0x2
        ALO 0x8
        SSTB 0
        JGT L8
        NOP
        MUL
        SWAP
        IMF AR, 0x01
L8:
        IMF AR, L9
        JF
        EQ
        STA
L9:
        STB
        .byte 0xB2
        HALT
sub0:
        LD B, AR
        JFE L10, L11
        NAND
        NOP
L11:
        AHI 0xD
        TAR
        SHR
L10:
        INC
        NOP
        CALL sub2
        RET
sub1:
        IMF AR, sub3
        CALL
        SLDA 6
        SLDB 1
        IMF AR, sub3
        CALL
        ILA 0x3
        CALL sub3
        NAND
        CALL sub3
        RET
sub2:
        IMF A, 0xF5
        INC
        ALO 0xF
        STA
        LD B, 0x6A
        CALL sub3
        .byte 0xAD
        NOR
        INVA
        NOP
        RET
sub3:
        GTE
        JFE L12, L13
        GTE
L13:
        MUL
L12:
        ILB 0x3
        NOP
        SSTB 6
        TAR
        JGT L14
        IMF A, 0x7F
L14:
        RET
        HALT
