; random_calls_4: random call-heavy code (seed 1058): five to seven subroutines calling deeper ones,
; so the stack often overflows past depth 4 and RETs then fall through at
; depth 0; extra RETs in main at depth 0.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x2E
        IMF B, 0x31
        IMF AR, 0x8B
        CLF
        CALL sub6
        INVB
        IMF AR, sub0
        CALL
        JGT L1
        IHA 0x3
L1:
        JFE L2, L3
        LDA
        IMF B, 0xFF
L3:
        SLDA 5
        AND
        DIV
L2:
        IMF B, 0x00
        SSTA 14
        JFE L4, L5
        .byte 0xD1
        SUB
L5:
        ST B, B
        SLDB 9
        NEQ
L4:
        SWAP
        LTE
        RET
        LDA
        CLF
        IMF AR, sub2
        CALL
        JNEQ L6
        AND
        ST A, A
        STB
L6:
        JMP L7
        IMF A, 0x00
        ST A, B
L7:
        RET
        IMF AR, sub6
        CALL
        ADD
        IMF AR, sub1
        CALL
        CALL sub5
        CALL sub1
        IMF AR, sub0
        CALL
        SWAP
        DIV
        .byte 0xD5
        CALL sub2
        AND
        CALL sub1
        CALL sub5
        CALL sub5
        HALT
sub0:
        IMF AR, sub2
        CALL
        CALL sub1
        IMF AR, L8
        JF
        DIV
L8:
        SLDB 10
        RET
sub1:
        NAND
        STB
        IMF AR, sub3
        CALL
        ALO 0xF
        IHB 0x7
        JF L9
        .byte 0xB7
L9:
        RET
sub2:
        IMF AR, sub3
        CALL
        NOP
        INVB
        NAND
        SHL
        LD B, B
        RET
sub3:
        LDB
        TAR
        IMF AR, sub4
        CALL
        SUB
        SLDB 7
        XOR
        INVA
        INVA
        STB
        RET
sub4:
        AHI 0x0
        ST A, AR
        CALL sub5
        IHA 0xD
        NOP
        IMF AR, sub5
        CALL
        STB
        RET
sub5:
        DIV
        ST A, 0x08
        CALL sub6
        JF L10
        IHB 0xC
        SHL
L10:
        RET
sub6:
        XOR
        JF L11
        SWAP
L11:
        JGTE L12
        TAR
        MUL
        LDA
        STB
L12:
        RET
        HALT
