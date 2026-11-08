; alu_mul_2 (part 2 of 2)
; MUL: A = (A * B)[7:0], F = non-zero discarded high bits.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0xF
        IHB 0x7
        ILA 0x1
        IHA 0x8
        CLF
        MUL
        ILA 0xE
        CLF
        MUL
        ILA 0xF
        IHA 0xF
        CLF
        MUL
        ILB 0x0
        IHB 0x8
        ILA 0x0
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        MUL
        ILA 0xF
        CLF
        MUL
        IHA 0x1
        CLF
        MUL
        ILA 0xF
        IHA 0x7
        CLF
        MUL
        CLF
        MUL
        ILA 0x1
        IHA 0x8
        CLF
        MUL
        ILA 0xE
        IHA 0xF
        CLF
        MUL
        ILA 0xF
        IHA 0xF
        CLF
        MUL
        ILB 0x1
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        MUL
        ILA 0xF
        CLF
        MUL
        ILA 0x0
        IHA 0x1
        CLF
        MUL
        ILA 0xF
        IHA 0x7
        CLF
        MUL
        ILA 0x0
        IHA 0x8
        CLF
        MUL
        ILA 0x1
        CLF
        MUL
        ILA 0xE
        IHA 0xF
        CLF
        MUL
        ILA 0xF
        CLF
        MUL
        ILB 0xE
        IHB 0xF
        ILA 0x0
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        MUL
        ILA 0xF
        IHA 0x0
        CLF
        MUL
        ILA 0x0
        IHA 0x1
        CLF
        MUL
        ILA 0xF
        IHA 0x7
        CLF
        MUL
        ILA 0x0
        IHA 0x8
        CLF
        MUL
        ILA 0x1
        IHA 0x8
        CLF
        MUL
        CLF
        MUL
        ILA 0xF
        IHA 0xF
        CLF
        MUL
        ILB 0xF
        ILA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        MUL
        ILA 0xF
        IHA 0x0
        CLF
        MUL
        ILA 0x0
        IHA 0x1
        CLF
        MUL
        ILA 0xF
        IHA 0x7
        CLF
        MUL
        ILA 0x0
        CLF
        MUL
        ILA 0x1
        CLF
        MUL
        ILA 0xE
        IHA 0xF
        CLF
        MUL
        ILA 0xF
        IHA 0xF
        CLF
        MUL
        ILB 0x0
        IHB 0x1
        ILA 0x0
        IHA 0x1
        CLF
        MUL
        ILB 0x1
        ILA 0xF
        MUL
        ILB 0xF
        IHB 0x0
        ILA 0x1
        IHA 0x1
        STF
        MUL
        ILB 0x2
        ILA 0x0
        IHA 0x8
        MUL
        IHA 0x4
        MUL
        ILB 0xF
        ILA 0xF
        IHA 0x0
        STF
        MUL
        ILA 0x0
        IHA 0x1
        STF
        MUL
        ILB 0x3
        ILA 0x5
        IHA 0x5
        STF
        MUL
        ILA 0x6
        IHA 0x5
        MUL
        ILB 0x5
        IHB 0x5
        ILA 0x3
        MUL
        ILB 0x8
        IHB 0x0
        ILA 0x0
        IHA 0x2
        MUL
        ILA 0xF
        IHA 0x1
        MUL
        HALT
