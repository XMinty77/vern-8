; alu_add_2 (part 2 of 2)
; ADD: A = A + B, F = carry out.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0xF
        CLF
        ADD
        ILB 0x0
        IHB 0x8
        ILA 0x0
        IHA 0x0
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
        ILA 0xF
        IHA 0x7
        STF
        ADD
        ILA 0x0
        IHA 0x8
        ADD
        ILA 0x1
        IHA 0x8
        CLF
        ADD
        ILA 0xE
        IHA 0xF
        CLF
        ADD
        ILA 0xF
        IHA 0xF
        CLF
        ADD
        ILB 0x1
        ILA 0x0
        IHA 0x0
        ADD
        IHA 0x0
        STF
        ADD
        IHA 0x0
        STF
        ADD
        ILA 0xF
        IHA 0x0
        STF
        ADD
        IHA 0x1
        STF
        ADD
        ILA 0xF
        IHA 0x7
        ADD
        IHA 0x8
        CLF
        ADD
        IHA 0x8
        CLF
        ADD
        ILA 0xE
        IHA 0xF
        CLF
        ADD
        IHA 0xF
        CLF
        ADD
        ILB 0xE
        IHB 0xF
        IHA 0x0
        ADD
        ILA 0x1
        IHA 0x0
        STF
        ADD
        ILA 0x2
        IHA 0x0
        ADD
        ILA 0xF
        CLF
        ADD
        ILA 0x0
        IHA 0x1
        CLF
        ADD
        ILA 0xF
        IHA 0x7
        CLF
        ADD
        ILA 0x0
        IHA 0x8
        CLF
        ADD
        ILA 0x1
        IHA 0x8
        CLF
        ADD
        ILA 0xE
        IHA 0xF
        CLF
        ADD
        ILA 0xF
        CLF
        ADD
        ILB 0xF
        ILA 0x0
        IHA 0x0
        ADD
        ILA 0x1
        IHA 0x0
        ADD
        ILA 0x2
        CLF
        ADD
        ILA 0xF
        CLF
        ADD
        ILA 0x0
        IHA 0x1
        CLF
        ADD
        IHA 0x7
        CLF
        ADD
        ILA 0x0
        IHA 0x8
        CLF
        ADD
        ILA 0x1
        IHA 0x8
        CLF
        ADD
        ILA 0xE
        IHA 0xF
        CLF
        ADD
        ILA 0xF
        CLF
        ADD
        ILB 0x1
        IHB 0x0
        ILA 0xF
        IHA 0x7
        ADD
        ILB 0x0
        IHB 0x8
        ADD
        IHB 0x1
        IHA 0xF
        CLF
        ADD
        ILB 0x1
        IHB 0xF
        ILA 0xF
        CLF
        ADD
        ILB 0x5
        IHB 0x5
        ILA 0xA
        IHA 0xA
        ADD
        ILA 0xB
        IHA 0xA
        ADD
        ILB 0xF
        IHB 0xF
        ILA 0x1
        CLF
        ADD
        ILB 0x8
        IHB 0x0
        ILA 0x8
        ADD
        IHB 0x8
        ILA 0x8
        IHA 0x8
        ADD
        ILB 0x0
        IHB 0x4
        IHA 0xC
        CLF
        ADD
        HALT
