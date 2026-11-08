; flag_clf_stf: CLF and STF: from F unknown after reset, from 0, from 1, repeated; and
; every non-flag instruction keeps F at both 0 and 1 (nibble writes, TAR, all
; loads and stores, INVA, INVB, SWAP, logic ops, shifts, JMP, JF not taken,
; CALL, RET, RET at depth 0, undefined opcodes).

        STF                 ; from unknown
        STF
        CLF
        CLF
        STF
        CLF
        IMF A, 0x3C
        IMF B, 0x03
        IMF AR, 0x20
        STF
        CALL keep
        CLF
        CALL keep
        RET                 ; depth 0: only PC + 1
        STF
        RET
        CLF
        HALT

keep:   ILA 0x1
        IHA 0x2
        ILB 0x3
        IHB 0x0
        ALO 0x0
        AHI 0x2
        TAR
        IMF AR, 0x30
        STA
        STB
        LDA
        LDB
        SSTA 1
        SSTB 2
        SLDA 2
        SLDB 1
        INVA
        INVB
        SWAP
        AND
        NAND
        OR
        NOR
        XOR
        XNOR
        IMF B, 1
        SHL
        SHR
        IMF AR, k2
        JMP
k2:     IMF AR, k3
        JF                  ; F = 1 jumps to k3, F = 0 falls through to it
k3:     .byte 0xA0
        .byte 0xD0
        .byte 0x9C
        IMF AR, k4
        CALL
        RET                 ; returns from keep
k4:     RET                 ; returns to the RET above
