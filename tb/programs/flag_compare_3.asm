; flag_compare_3 (part 3 of 3)
; Flag ops EQ, NEQ, LT, GTE, GT, LTE over 20 operand pairs each: equal, off by one,
; 7F/80 (unsigned, not signed), nibble-order traps (10 vs 01, 0F vs F0), 00/FF extremes.
; F is preset to the opposite of the expected result before each compare.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        STF
        GT
        ILB 0x1
        STF
        GT
        ILB 0x0
        ILA 0x1
        GT
        IHB 0x8
        ILA 0xF
        IHA 0x7
        GT
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        GT
        IHB 0xF
        ILA 0xF
        IHA 0xF
        GT
        ILB 0x0
        IHB 0x0
        GT
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        GT
        ILB 0x0
        IHB 0x8
        IHA 0x8
        STF
        GT
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        STF
        GT
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        GT
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        GT
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        STF
        GT
        ILB 0xE
        ILA 0xF
        GT
        ILB 0x0
        IHA 0x0
        GT
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        GT
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        GT
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        STF
        GT
        IHB 0x0
        IHA 0x8
        GT
        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        CLF
        GT
        ILB 0x0
        IHB 0x0
        IHA 0x0
        CLF
        LTE
        ILB 0x1
        CLF
        LTE
        ILB 0x0
        ILA 0x1
        LTE
        IHB 0x8
        ILA 0xF
        IHA 0x7
        LTE
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        LTE
        IHB 0xF
        ILA 0xF
        IHA 0xF
        LTE
        ILB 0x0
        IHB 0x0
        LTE
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        LTE
        ILB 0x0
        IHB 0x8
        IHA 0x8
        CLF
        LTE
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        CLF
        LTE
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        LTE
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        LTE
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        CLF
        LTE
        ILB 0xE
        ILA 0xF
        LTE
        ILB 0x0
        IHA 0x0
        LTE
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        LTE
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        LTE
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        CLF
        LTE
        IHB 0x0
        IHA 0x8
        LTE
        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        STF
        LTE
        HALT
