; alu_sub_1 (part 1 of 2)
; SUB: A = A - B, F = borrow.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0x0
        IHB 0x0
        ILA 0x0
        IHA 0x0
        STF
        SUB
        ILA 0x1
        STF
        SUB
        ILA 0x2
        STF
        SUB
        ILA 0xF
        STF
        SUB
        ILA 0x0
        IHA 0x1
        STF
        SUB
        ILA 0xF
        IHA 0x7
        STF
        SUB
        ILA 0x0
        IHA 0x8
        STF
        SUB
        ILA 0x1
        STF
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        ILA 0xF
        STF
        SUB
        ILB 0x1
        ILA 0x0
        IHA 0x0
        SUB
        ILA 0x1
        IHA 0x0
        SUB
        ILA 0x2
        STF
        SUB
        ILA 0xF
        STF
        SUB
        ILA 0x0
        IHA 0x1
        STF
        SUB
        IHA 0x7
        STF
        SUB
        ILA 0x0
        IHA 0x8
        STF
        SUB
        ILA 0x1
        IHA 0x8
        STF
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        ILA 0xF
        STF
        SUB
        ILB 0x2
        ILA 0x0
        IHA 0x0
        SUB
        ILA 0x1
        IHA 0x0
        CLF
        SUB
        ILA 0x2
        IHA 0x0
        SUB
        ILA 0xF
        STF
        SUB
        ILA 0x0
        IHA 0x1
        STF
        SUB
        ILA 0xF
        IHA 0x7
        STF
        SUB
        ILA 0x0
        IHA 0x8
        STF
        SUB
        ILA 0x1
        IHA 0x8
        STF
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        ILA 0xF
        STF
        SUB
        ILB 0xF
        ILA 0x0
        IHA 0x0
        SUB
        IHA 0x0
        CLF
        SUB
        IHA 0x0
        CLF
        SUB
        ILA 0xF
        IHA 0x0
        SUB
        IHA 0x1
        STF
        SUB
        ILA 0xF
        IHA 0x7
        STF
        SUB
        IHA 0x8
        STF
        SUB
        IHA 0x8
        STF
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        IHA 0xF
        STF
        SUB
        ILB 0x0
        IHB 0x1
        IHA 0x0
        SUB
        ILA 0x1
        IHA 0x0
        CLF
        SUB
        ILA 0x2
        IHA 0x0
        CLF
        SUB
        ILA 0xF
        IHA 0x0
        CLF
        SUB
        ILA 0x0
        IHA 0x1
        SUB
        ILA 0xF
        IHA 0x7
        STF
        SUB
        ILA 0x0
        IHA 0x8
        STF
        SUB
        ILA 0x1
        IHA 0x8
        STF
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        ILA 0xF
        IHA 0xF
        STF
        SUB
        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x0
        SUB
        IHA 0x0
        CLF
        SUB
        IHA 0x0
        CLF
        SUB
        ILA 0xF
        IHA 0x0
        CLF
        SUB
        HALT
