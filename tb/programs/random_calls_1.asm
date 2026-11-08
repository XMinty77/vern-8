; random_calls_1: random call-heavy code (seed 1017): five to seven subroutines calling deeper ones,
; so the stack often overflows past depth 4 and RETs then fall through at
; depth 0; extra RETs in main at depth 0.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x3F
        IMF B, 0xA3
        IMF AR, 0x79
        STF
        RET
        NEQ
        IMF AR, sub6
        CALL
        SLDB 13
        IMF B, 0xEE
        JGTE L1
        ALO 0x3
        SWAP
        MUL
L1:
        CALL sub3
        IMF AR, sub5
        CALL
        IMF AR, sub0
        CALL
        IMF AR, 0x7F
        CALL sub2
        MUL
        JF L2
        SHR
        NOP
        INVB
        SSTB 11
L2:
        IMF AR, sub2
        CALL
        SLDB 0
        RET
        JEQ L3
        LD A, B
        LD B, A
L3:
        STA
        JFE L4, L5
        LD A, 0x8F
        .byte 0xCA
L5:
        SLDB 4
L4:
        LD B, 0xFF
        IMF AR, sub1
        CALL
        CALL sub1
        .byte 0xA2
        OR
        RET
        CALL sub5
        IMF A, 0x29
        LDA
        IMF AR, 0x7F
        RET
        RET
        AHI 0xE
        IMF AR, L6
        JEQ AR
        LDB
        ALO 0x1
L6:
        JFE L7, L8
        SSTA 1
L8:
        SLDB 11
        XOR
        OR
L7:
        HALT
sub0:
        IMF AR, 0x7F
        CALL sub2
        NOP
        XNOR
        LD B, 0x7F
        TAR
        RET
sub1:
        LDB
        IMF AR, sub3
        CALL
        INVA
        INVA
        IMF AR, sub6
        CALL
        NOP
        JNEQ L9
        SLDA 3
L9:
        RET
sub2:
        LD A, AR
        IMF AR, 0xBC
        CALL sub4
        IMF AR, sub3
        CALL
        JMP L10
        IHB 0xD
        ILA 0xF
        ST B, A
L10:
        RET
sub3:
        IMF AR, sub4
        CALL
        IMF AR, sub4
        CALL
        DIV
        SWAP
        IMF A, 0x7F
        SHL
        RET
sub4:
        DIV
        SLDA 13
        CALL sub5
        JNEQ L11
        IMF B, 0x00
L11:
        RET
sub5:
        SLDA 10
        SSTB 1
        IMF AR, sub6
        CALL
        OR
        CALL sub6
        CALL sub6
        RET
sub6:
        IMF AR, L12
        JF
        LD B, 0xFF
        AHI 0xC
        NOP
        SLDB 11
L12:
        SLDB 6
        LT
        RET
        HALT
