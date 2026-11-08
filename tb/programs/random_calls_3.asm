; random_calls_3: random call-heavy code (seed 1047): five to seven subroutines calling deeper ones,
; so the stack often overflows past depth 4 and RETs then fall through at
; depth 0; extra RETs in main at depth 0.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x3D
        IMF B, 0xB9
        IMF AR, 0xF2
        STF
        RET
        JF L1
        IMF A, 0x3B
        ADD
        SSTB 5
L1:
        OR
        AND
        IMF AR, sub2
        CALL
        CALL sub0
        IMF AR, L2
        JEQ AR
        SLDA 4
L2:
        CLF
        AND
        INC
        CALL sub0
        RET
        IMF A, 0xE2
        SLDA 11
        CALL sub0
        RET
        RET
        IMF AR, L3
        JF
        SUB
L3:
        INC
        RET
        CALL sub4
        IMF B, 0x00
        IMF AR, sub5
        CALL
        IHA 0x8
        IMF AR, sub1
        CALL
        IMF AR, sub4
        CALL
        CALL sub0
        ILA 0xD
        SLDA 8
        IHA 0x6
        IMF AR, sub2
        CALL
        SLDA 2
        IMF AR, sub3
        CALL
        CALL sub1
        IHB 0xA
        IMF AR, sub0
        CALL
        IMF AR, sub0
        CALL
        CALL sub5
        IMF AR, sub0
        CALL
        MUL
        IHA 0xF
        CALL sub5
        IMF AR, sub2
        CALL
        .byte 0xBB
        CALL sub3
        HALT
sub0:
        SLDB 1
        LDB
        IMF AR, sub2
        CALL
        IMF AR, sub1
        CALL
        IMF AR, sub1
        CALL
        SLDB 5
        IHB 0x0
        ST B, 0xFF
        RET
sub1:
        LD A, 0xFF
        NOP
        CALL sub2
        IMF AR, L4
        JGT AR
        ILA 0xA
        AHI 0x4
        IMF A, 0x7F
L4:
        RET
sub2:
        SLDB 12
        IMF AR, sub3
        CALL
        SUB
        IMF AR, sub5
        CALL
        MUL
        IMF AR, sub4
        CALL
        INC
        EQ
        LDA
        RET
sub3:
        SSTA 12
        ST B, A
        CALL sub4
        IMF AR, sub5
        CALL
        ILB 0x2
        INVB
        IMF A, 0x80
        OR
        CALL sub5
        RET
sub4:
        ADD
        XOR
        CALL sub5
        SWAP
        JFE L5, L6
        AHI 0xA
L6:
        NOP
L5:
        CALL sub5
        RET
sub5:
        .byte 0xB6
        AHI 0x1
        JFE L7, L8
        LD B, AR
L8:
        IHB 0xF
        TAR
        INC
L7:
        GT
        JMP L9
        SLDB 14
        ADD
        SLDA 14
        TAR
L9:
        RET
        HALT
