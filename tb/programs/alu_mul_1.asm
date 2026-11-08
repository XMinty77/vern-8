; alu_mul_1 (part 1 of 2)
; MUL: A = (A * B)[7:0], F = non-zero discarded high bits.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        STF
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        STF
        MUL
        ILA 0xF
        STF
        MUL
        IHA 0x1
        STF
        MUL
        ILA 0xF
        IHA 0x7
        STF
        MUL
        IHA 0x8
        STF
        MUL
        ILA 0x1
        IHA 0x8
        STF
        MUL
        ILA 0xE
        IHA 0xF
        STF
        MUL
        ILA 0xF
        IHA 0xF
        STF
        MUL
        ILB 0x1
        STF
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        STF
        MUL
        ILA 0xF
        STF
        MUL
        ILA 0x0
        IHA 0x1
        STF
        MUL
        ILA 0xF
        IHA 0x7
        STF
        MUL
        ILA 0x0
        IHA 0x8
        STF
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0xE
        IHA 0xF
        STF
        MUL
        ILA 0xF
        STF
        MUL
        ILB 0x2
        ILA 0x0
        IHA 0x0
        STF
        MUL
        ILA 0x1
        STF
        MUL
        STF
        MUL
        ILA 0xF
        STF
        MUL
        ILA 0x0
        STF
        MUL
        ILA 0xF
        IHA 0x7
        STF
        MUL
        ILA 0x0
        IHA 0x8
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
        CLF
        MUL
        ILB 0xF
        ILA 0x0
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        STF
        MUL
        ILA 0xF
        IHA 0x0
        STF
        MUL
        ILA 0x0
        IHA 0x1
        STF
        MUL
        ILA 0xF
        IHA 0x7
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
        IHA 0xF
        CLF
        MUL
        ILB 0x0
        IHB 0x1
        ILA 0x0
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        STF
        MUL
        ILA 0xF
        IHA 0x0
        STF
        MUL
        IHA 0x1
        MUL
        ILA 0xF
        IHA 0x7
        CLF
        MUL
        IHA 0x8
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
        ILB 0xF
        IHB 0x7
        IHA 0x0
        MUL
        ILA 0x1
        STF
        MUL
        ILA 0x2
        IHA 0x0
        STF
        MUL
        ILA 0xF
        IHA 0x0
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
        HALT
