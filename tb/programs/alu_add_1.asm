; alu_add_1 (part 1 of 2)
; ADD: A = A + B, F = carry out.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        STF
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0x2
        STF
        ADD
        ILA 0xF
        STF
        ADD
        ILA 0x0
        IHA 0x1
        STF
        ADD
        ILA 0xF
        IHA 0x7
        STF
        ADD
        ILA 0x0
        IHA 0x8
        STF
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0xE
        IHA 0xF
        STF
        ADD
        ILA 0xF
        STF
        ADD
        ILB 0x1
        ILA 0x0
        IHA 0x0
        STF
        ADD
        STF
        ADD
        STF
        ADD
        ILA 0xF
        STF
        ADD
        STF
        ADD
        ILA 0xF
        IHA 0x7
        STF
        ADD
        STF
        ADD
        STF
        ADD
        ILA 0xE
        IHA 0xF
        STF
        ADD
        ADD
        ILB 0x2
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0x2
        STF
        ADD
        ILA 0xF
        STF
        ADD
        ILA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x7
        STF
        ADD
        ILA 0x0
        STF
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0xE
        IHA 0xF
        ADD
        ILA 0xF
        IHA 0xF
        CLF
        ADD
        ILB 0xF
        ILA 0x0
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0x2
        IHA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x0
        STF
        ADD
        ILA 0x0
        STF
        ADD
        IHA 0x7
        STF
        ADD
        ILA 0x0
        STF
        ADD
        ILA 0x1
        STF
        ADD
        ILA 0xE
        IHA 0xF
        ADD
        ILA 0xF
        IHA 0xF
        CLF
        ADD
        ILB 0x0
        IHB 0x1
        ILA 0x0
        ADD
        ILA 0x1
        IHA 0x0
        STF
        ADD
        ILA 0x2
        IHA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x0
        STF
        ADD
        ILA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x7
        STF
        ADD
        ILA 0x0
        STF
        ADD
        ILA 0x1
        IHA 0x8
        STF
        ADD
        ILA 0xE
        IHA 0xF
        ADD
        ILA 0xF
        IHA 0xF
        CLF
        ADD
        ILB 0xF
        IHB 0x7
        ILA 0x0
        ADD
        ILA 0x1
        IHA 0x0
        STF
        ADD
        ILA 0x2
        IHA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x0
        STF
        ADD
        ILA 0x0
        IHA 0x1
        STF
        ADD
        IHA 0x7
        STF
        ADD
        ILA 0x0
        IHA 0x8
        STF
        ADD
        ILA 0x1
        IHA 0x8
        ADD
        ILA 0xE
        IHA 0xF
        CLF
        ADD
        HALT
