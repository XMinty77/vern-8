; random_calls_2: random call-heavy code (seed 1031): five to seven subroutines calling deeper ones,
; so the stack often overflows past depth 4 and RETs then fall through at
; depth 0; extra RETs in main at depth 0.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x73
        IMF B, 0x9D
        IMF AR, 0x88
        CLF
        NOP
        EQ
        ST B, B
        IMF AR, L1
        JF
        IHA 0x0
L1:
        INVB
        STA
        SLDA 15
        IMF AR, sub0
        CALL
        LD B, AR
        NOR
        JMP L2
        ILA 0x7
L2:
        ALO 0x7
        CALL sub6
        SHR
        SHL
        JMP L3
        NOR
        SLDB 11
L3:
        CALL sub3
        LD A, A
        LDA
        IMF AR, sub5
        CALL
        CALL sub6
        LD A, 0xFF
        IMF AR, sub0
        CALL
        .byte 0xA5
        CALL sub2
        RET
        RET
        RET
        STA
        CALL sub4
        RET
        SLDB 2
        LTE
        JF L4
        SLDB 14
        AND
        IMF A, 0x7F
        INC
L4:
        LD A, A
        NEQ
        RET
        IMF AR, sub3
        CALL
        NAND
        RET
        LTE
        INC
        SWAP
        JGTE L5
        SWAP
        STB
        IMF A, 0x00
        IHB 0xA
L5:
        ADD
        CALL sub0
        HALT
sub0:
        MUL
        NOR
        CALL sub2
        NOR
        LD B, B
        ALO 0xB
        RET
sub1:
        SHL
        CALL sub3
        IMF B, 0x01
        STF
        SSTB 12
        IMF AR, sub3
        CALL
        RET
sub2:
        CALL sub3
        IMF A, 0x80
        LT
        JLT L6
        NEQ
        SLDA 9
L6:
        RET
sub3:
        IMF AR, sub4
        CALL
        SLDA 9
        JF L7
        XOR
        SSTB 7
        IHB 0x9
        SLDA 5
L7:
        RET
sub4:
        AHI 0xB
        CALL sub5
        IMF A, 0x00
        LD B, B
        ILB 0xF
        RET
sub5:
        MUL
        IMF B, 0x00
        IMF AR, sub6
        CALL
        SLDA 6
        IMF AR, sub6
        CALL
        NOP
        RET
sub6:
        SHL
        SSTA 3
        STA
        JF L8
        ST A, 0x3D
L8:
        .byte 0xC9
        NOP
        RET
        HALT
