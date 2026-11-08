; flag_compare_2 (part 2 of 3)
; Flag ops EQ, NEQ, LT, GTE, GT, LTE over 20 operand pairs each: equal, off by one,
; 7F/80 (unsigned, not signed), nibble-order traps (10 vs 01, 0F vs F0), 00/FF extremes.
; F is preset to the opposite of the expected result before each compare.

        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        CLF
        NEQ
        ILB 0x0
        IHB 0x0
        IHA 0x0
        LT
        ILB 0x1
        LT
        ILB 0x0
        ILA 0x1
        LT
        IHB 0x8
        ILA 0xF
        IHA 0x7
        LT
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        LT
        IHB 0xF
        ILA 0xF
        IHA 0xF
        STF
        LT
        ILB 0x0
        IHB 0x0
        STF
        LT
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        LT
        ILB 0x0
        IHB 0x8
        IHA 0x8
        LT
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        STF
        LT
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        STF
        LT
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        LT
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        CLF
        LT
        ILB 0xE
        ILA 0xF
        LT
        ILB 0x0
        IHA 0x0
        LT
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        LT
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        STF
        LT
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        LT
        IHB 0x0
        IHA 0x8
        LT
        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        STF
        LT
        ILB 0x0
        IHB 0x0
        IHA 0x0
        GTE
        ILB 0x1
        GTE
        ILB 0x0
        ILA 0x1
        GTE
        IHB 0x8
        ILA 0xF
        IHA 0x7
        GTE
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        GTE
        IHB 0xF
        ILA 0xF
        IHA 0xF
        CLF
        GTE
        ILB 0x0
        IHB 0x0
        CLF
        GTE
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        GTE
        ILB 0x0
        IHB 0x8
        IHA 0x8
        GTE
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        CLF
        GTE
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        CLF
        GTE
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        GTE
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        STF
        GTE
        ILB 0xE
        ILA 0xF
        GTE
        ILB 0x0
        IHA 0x0
        GTE
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        GTE
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        CLF
        GTE
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        GTE
        IHB 0x0
        IHA 0x8
        GTE
        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        CLF
        GTE
        HALT
