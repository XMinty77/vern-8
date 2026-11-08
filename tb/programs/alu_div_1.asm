; alu_div_1 (part 1 of 3)
; DIV: A = A / B, B = A % B, F = 0; B = 0 leaves A and B unchanged and sets F.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        CLF
        DIV
        ILA 0x1
        CLF
        DIV
        ILA 0x2
        CLF
        DIV
        ILA 0xF
        CLF
        DIV
        ILA 0x0
        IHA 0x1
        CLF
        DIV
        ILA 0xF
        IHA 0x7
        CLF
        DIV
        ILA 0x0
        IHA 0x8
        CLF
        DIV
        ILA 0x1
        CLF
        DIV
        ILA 0xE
        IHA 0xF
        CLF
        DIV
        ILA 0xF
        CLF
        DIV
        ILB 0x1
        ILA 0x0
        IHA 0x0
        DIV
        ILB 0x1
        ILA 0x1
        STF
        DIV
        ILB 0x1
        ILA 0x2
        STF
        DIV
        ILB 0x1
        ILA 0xF
        STF
        DIV
        ILB 0x1
        ILA 0x0
        IHA 0x1
        STF
        DIV
        ILB 0x1
        ILA 0xF
        IHA 0x7
        STF
        DIV
        ILB 0x1
        ILA 0x0
        IHA 0x8
        STF
        DIV
        ILB 0x1
        ILA 0x1
        STF
        DIV
        ILB 0x1
        ILA 0xE
        IHA 0xF
        STF
        DIV
        ILB 0x1
        ILA 0xF
        STF
        DIV
        ILB 0x2
        ILA 0x0
        IHA 0x0
        STF
        DIV
        ILB 0x2
        ILA 0x1
        STF
        DIV
        ILB 0x2
        ILA 0x2
        STF
        DIV
        ILB 0x2
        ILA 0xF
        STF
        DIV
        ILB 0x2
        ILA 0x0
        IHA 0x1
        STF
        DIV
        ILB 0x2
        ILA 0xF
        IHA 0x7
        STF
        DIV
        ILB 0x2
        ILA 0x0
        IHA 0x8
        STF
        DIV
        ILB 0x2
        ILA 0x1
        IHA 0x8
        STF
        DIV
        ILB 0x2
        ILA 0xE
        IHA 0xF
        STF
        DIV
        ILB 0x2
        IHA 0xF
        STF
        DIV
        ILB 0xF
        ILA 0x0
        IHA 0x0
        STF
        DIV
        ILB 0xF
        ILA 0x1
        STF
        DIV
        ILB 0xF
        ILA 0x2
        STF
        DIV
        ILB 0xF
        ILA 0xF
        STF
        DIV
        ILB 0xF
        ILA 0x0
        IHA 0x1
        STF
        DIV
        ILB 0xF
        ILA 0xF
        IHA 0x7
        STF
        DIV
        ILB 0xF
        ILA 0x0
        IHA 0x8
        STF
        DIV
        ILB 0xF
        ILA 0x1
        IHA 0x8
        STF
        DIV
        ILB 0xF
        ILA 0xE
        IHA 0xF
        STF
        DIV
        ILB 0xF
        ILA 0xF
        IHA 0xF
        STF
        DIV
        IHB 0x1
        ILA 0x0
        IHA 0x0
        STF
        DIV
        IHB 0x1
        ILA 0x1
        STF
        DIV
        HALT
