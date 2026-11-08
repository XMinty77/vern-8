; flag_compare_1 (part 1 of 3)
; Flag ops EQ, NEQ, LT, GTE, GT, LTE over 20 operand pairs each: equal, off by one,
; 7F/80 (unsigned, not signed), nibble-order traps (10 vs 01, 0F vs F0), 00/FF extremes.
; F is preset to the opposite of the expected result before each compare.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        CLF
        EQ
        ILB 0x1
        EQ
        ILB 0x0
        ILA 0x1
        STF
        EQ
        IHB 0x8
        ILA 0xF
        IHA 0x7
        STF
        EQ
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        STF
        EQ
        IHB 0xF
        ILA 0xF
        IHA 0xF
        EQ
        ILB 0x0
        IHB 0x0
        EQ
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        STF
        EQ
        ILB 0x0
        IHB 0x8
        IHA 0x8
        EQ
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        CLF
        EQ
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        EQ
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        STF
        EQ
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        STF
        EQ
        ILB 0xE
        ILA 0xF
        STF
        EQ
        ILB 0x0
        IHA 0x0
        STF
        EQ
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        STF
        EQ
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        EQ
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        EQ
        IHB 0x0
        IHA 0x8
        STF
        EQ
        ILB 0xF
        IHB 0x3
        ILA 0x0
        IHA 0x4
        STF
        EQ
        ILB 0x0
        IHB 0x0
        IHA 0x0
        STF
        NEQ
        ILB 0x1
        NEQ
        ILB 0x0
        ILA 0x1
        CLF
        NEQ
        IHB 0x8
        ILA 0xF
        IHA 0x7
        CLF
        NEQ
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        CLF
        NEQ
        IHB 0xF
        ILA 0xF
        IHA 0xF
        NEQ
        ILB 0x0
        IHB 0x0
        NEQ
        ILB 0xF
        IHB 0xF
        ILA 0x0
        IHA 0x0
        CLF
        NEQ
        ILB 0x0
        IHB 0x8
        IHA 0x8
        NEQ
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0x7
        STF
        NEQ
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        NEQ
        ILB 0x0
        IHB 0x1
        ILA 0x1
        IHA 0x0
        CLF
        NEQ
        ILB 0xF
        IHB 0xF
        ILA 0xE
        IHA 0xF
        CLF
        NEQ
        ILB 0xE
        ILA 0xF
        CLF
        NEQ
        ILB 0x0
        IHA 0x0
        CLF
        NEQ
        ILB 0xF
        IHB 0x0
        ILA 0x0
        IHA 0xF
        CLF
        NEQ
        ILB 0x5
        IHB 0x5
        ILA 0x5
        IHA 0x5
        NEQ
        ILB 0x1
        IHB 0x8
        ILA 0x1
        IHA 0x0
        NEQ
        IHB 0x0
        IHA 0x8
        CLF
        NEQ
        HALT
