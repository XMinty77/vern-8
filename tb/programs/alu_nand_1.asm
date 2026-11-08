; alu_nand_1 (part 1 of 2)
; NAND: A = ~(A & B), F kept.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: alternately 0 and 1, so keeping F is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        IHA 0x0
        STF
        NAND
        ILA 0x0
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        ILA 0x0
        IHA 0x8
        CLF
        NAND
        ILA 0x1
        IHA 0x8
        STF
        NAND
        ILA 0xE
        CLF
        NAND
        STF
        NAND
        ILB 0x1
        ILA 0x0
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        IHA 0x0
        STF
        NAND
        ILA 0x0
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        ILA 0x0
        IHA 0x8
        CLF
        NAND
        ILA 0x1
        IHA 0x8
        STF
        NAND
        CLF
        NAND
        STF
        NAND
        ILB 0x2
        ILA 0x0
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        ILA 0xF
        IHA 0x0
        STF
        NAND
        ILA 0x0
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        ILA 0x0
        IHA 0x8
        CLF
        NAND
        ILA 0x1
        IHA 0x8
        STF
        NAND
        ILA 0xE
        CLF
        NAND
        ILA 0xF
        STF
        NAND
        ILB 0xF
        ILA 0x0
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        ILA 0xF
        IHA 0x0
        STF
        NAND
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        IHA 0x8
        CLF
        NAND
        ILA 0x1
        IHA 0x8
        STF
        NAND
        CLF
        NAND
        ILA 0xF
        STF
        NAND
        ILB 0x0
        IHB 0x1
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        IHA 0x0
        STF
        NAND
        ILA 0x0
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        ILA 0x0
        IHA 0x8
        CLF
        NAND
        ILA 0x1
        IHA 0x8
        STF
        NAND
        ILA 0xE
        CLF
        NAND
        IHA 0xF
        STF
        NAND
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x0
        CLF
        NAND
        ILA 0x1
        IHA 0x0
        STF
        NAND
        ILA 0x2
        IHA 0x0
        CLF
        NAND
        ILA 0xF
        IHA 0x0
        STF
        NAND
        IHA 0x1
        CLF
        NAND
        IHA 0x7
        STF
        NAND
        CLF
        NAND
        HALT
