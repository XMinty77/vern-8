; alu_xnor_2 (part 2 of 2)
; XNOR: A = ~(A ^ B), F kept.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: alternately 0 and 1, so keeping F is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x8
        CLF
        XNOR
        ILA 0x1
        IHA 0x8
        STF
        XNOR
        ILA 0xE
        IHA 0xF
        CLF
        XNOR
        ILA 0xF
        IHA 0xF
        STF
        XNOR
        ILB 0x0
        IHB 0x8
        ILA 0x0
        IHA 0x0
        CLF
        XNOR
        ILA 0x1
        IHA 0x0
        STF
        XNOR
        ILA 0x2
        IHA 0x0
        CLF
        XNOR
        ILA 0xF
        IHA 0x0
        STF
        XNOR
        IHA 0x1
        CLF
        XNOR
        IHA 0x7
        STF
        XNOR
        IHA 0x8
        CLF
        XNOR
        ILA 0x1
        IHA 0x8
        STF
        XNOR
        CLF
        XNOR
        ILA 0xF
        IHA 0xF
        STF
        XNOR
        ILB 0x1
        IHA 0x0
        CLF
        XNOR
        ILA 0x1
        IHA 0x0
        STF
        XNOR
        ILA 0x2
        IHA 0x0
        CLF
        XNOR
        ILA 0xF
        IHA 0x0
        STF
        XNOR
        ILA 0x0
        IHA 0x1
        CLF
        XNOR
        ILA 0xF
        IHA 0x7
        STF
        XNOR
        ILA 0x0
        IHA 0x8
        CLF
        XNOR
        ILA 0x1
        IHA 0x8
        STF
        XNOR
        ILA 0xE
        CLF
        XNOR
        ILA 0xF
        IHA 0xF
        STF
        XNOR
        ILB 0xE
        IHB 0xF
        ILA 0x0
        IHA 0x0
        CLF
        XNOR
        STF
        XNOR
        ILA 0x2
        CLF
        XNOR
        ILA 0xF
        STF
        XNOR
        ILA 0x0
        IHA 0x1
        CLF
        XNOR
        ILA 0xF
        IHA 0x7
        STF
        XNOR
        ILA 0x0
        IHA 0x8
        CLF
        XNOR
        STF
        XNOR
        ILA 0xE
        IHA 0xF
        CLF
        XNOR
        STF
        XNOR
        ILB 0xF
        ILA 0x0
        IHA 0x0
        CLF
        XNOR
        ILA 0x1
        STF
        XNOR
        ILA 0x2
        CLF
        XNOR
        ILA 0xF
        STF
        XNOR
        ILA 0x0
        IHA 0x1
        CLF
        XNOR
        ILA 0xF
        IHA 0x7
        STF
        XNOR
        ILA 0x0
        IHA 0x8
        CLF
        XNOR
        ILA 0x1
        STF
        XNOR
        ILA 0xE
        IHA 0xF
        CLF
        XNOR
        ILA 0xF
        STF
        XNOR
        ILB 0x5
        IHB 0x5
        ILA 0xA
        IHA 0xA
        CLF
        XNOR
        ILB 0xA
        IHB 0xA
        ILA 0x5
        IHA 0x5
        STF
        XNOR
        ILB 0xF
        IHB 0x0
        IHA 0xF
        CLF
        XNOR
        ILB 0x3
        IHB 0xC
        ILA 0xC
        IHA 0x3
        STF
        XNOR
        ILB 0x5
        IHB 0xA
        ILA 0x5
        IHA 0xA
        CLF
        XNOR
        ILB 0xF
        IHB 0xF
        ILA 0xA
        IHA 0x5
        STF
        XNOR
        IHB 0x0
        ILA 0xF
        IHA 0x0
        CLF
        XNOR
        ILB 0x9
        IHB 0x9
        ILA 0x3
        IHA 0xC
        STF
        XNOR
        HALT
