; random_calls_5: random call-heavy code (seed 1067): five to seven subroutines calling deeper ones,
; so the stack often overflows past depth 4 and RETs then fall through at
; depth 0; extra RETs in main at depth 0.

        ; fill all of data memory (M[a] = a, from FF down to 00) so any address can be read
        IMF A, 0xFF
        IMF B, 0xFF
fill:   TAR
        STA
        ADD                 ; a - 1, no carry only after a = 00
        JF fill
        IMF A, 0x37
        IMF B, 0x9E
        IMF AR, 0x14
        STF
        OR
        JF L1
        NAND
        ALO 0xB
        SSTA 1
L1:
        RET
        IMF AR, sub0
        CALL
        IMF AR, sub3
        CALL
        AHI 0x7
        CALL sub1
        RET
        CALL sub3
        INVB
        IMF AR, sub4
        CALL
        CALL sub5
        DIV
        CALL sub1
        IMF AR, sub0
        CALL
        JLT L2
        .byte 0xA6
        STB
L2:
        CALL sub0
        IMF AR, 0x01
        CALL sub4
        IMF A, 0xFF
        IMF AR, sub4
        CALL
        LD A, A
        JMP L3
        GTE
        STA
L3:
        JGTE L4
        IMF B, 0xCD
        LTE
        ST B, 0x39
        LD A, AR
L4:
        IMF AR, L5
        JF
        SHL
        ST A, 0xFF
        XOR
L5:
        CALL sub3
        DIV
        AHI 0xB
        SHL
        .byte 0xC4
        IMF AR, sub4
        CALL
        ILB 0x1
        IMF AR, sub4
        CALL
        CALL sub0
        HALT
sub0:
        AHI 0x9
        IMF AR, sub1
        CALL
        NOP
        CALL sub2
        .byte 0xBC
        CALL sub5
        .byte 0xA5
        ILB 0xA
        ALO 0xA
        RET
sub1:
        .byte 0xA4
        CALL sub2
        IMF AR, sub4
        CALL
        CALL sub4
        IMF AR, sub5
        CALL
        IMF A, 0xFF
        RET
sub2:
        CALL sub3
        AHI 0xF
        JLTE L6
        XOR
        ST B, A
        NOR
        SHL
L6:
        NOP
        STF
        RET
sub3:
        IMF AR, sub5
        CALL
        SLDB 4
        CALL sub5
        ADD
        STA
        .byte 0xBD
        IMF AR, sub5
        CALL
        INC
        IMF AR, sub4
        CALL
        RET
sub4:
        CALL sub5
        SLDB 11
        JGTE L7
        ALO 0x7
        IMF B, 0x80
        LD A, AR
        TAR
L7:
        GTE
        AND
        RET
sub5:
        JF L8
        ST A, AR
        SHL
        SWAP
L8:
        NOP
        DIV
        .byte 0xAE
        ST A, AR
        IHB 0x9
        JFE L9, L10
        INVA
        ILA 0x5
L10:
        NOP
L9:
        RET
        HALT
