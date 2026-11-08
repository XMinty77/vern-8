; alu_sub_2 (part 2 of 2)
; SUB: A = A - B, F = borrow.
; Every pair from the edge set {00 01 02 0F 10 7F 80 81 FE FF} for A and B, plus
; op-specific cases. Before each op F is preset: to the opposite of the expected result, so the write is visible.
; Only the nibbles that change between cases are rewritten.

        ILB 0xF
        IHB 0x7
        ILA 0x0
        IHA 0x1
        CLF
        SUB
        ILA 0xF
        IHA 0x7
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
        IHB 0x8
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
        CLF
        SUB
        ILA 0xF
        IHA 0x7
        CLF
        SUB
        ILA 0x0
        IHA 0x8
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
        ILB 0x1
        ILA 0x0
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
        CLF
        SUB
        IHA 0x7
        CLF
        SUB
        ILA 0x0
        IHA 0x8
        CLF
        SUB
        ILA 0x1
        IHA 0x8
        SUB
        ILA 0xE
        IHA 0xF
        STF
        SUB
        ILA 0xF
        IHA 0xF
        STF
        SUB
        ILB 0xE
        IHB 0xF
        ILA 0x0
        IHA 0x0
        SUB
        ILA 0x1
        CLF
        SUB
        ILA 0x2
        CLF
        SUB
        ILA 0xF
        CLF
        SUB
        ILA 0x0
        CLF
        SUB
        ILA 0xF
        IHA 0x7
        CLF
        SUB
        ILA 0x0
        CLF
        SUB
        ILA 0x1
        CLF
        SUB
        ILA 0xE
        IHA 0xF
        SUB
        ILA 0xF
        IHA 0xF
        STF
        SUB
        ILB 0xF
        ILA 0x0
        SUB
        CLF
        SUB
        CLF
        SUB
        ILA 0xF
        CLF
        SUB
        CLF
        SUB
        ILA 0xF
        IHA 0x7
        CLF
        SUB
        CLF
        SUB
        CLF
        SUB
        ILA 0xE
        IHA 0xF
        CLF
        SUB
        SUB
        IHB 0x7
        IHA 0x8
        STF
        SUB
        ILB 0x0
        IHB 0x8
        ILA 0xF
        IHA 0x7
        SUB
        ILB 0x1
        IHB 0x0
        ILA 0x0
        IHA 0x1
        SUB
        ILB 0xA
        IHB 0xA
        ILA 0x5
        IHA 0x5
        SUB
        ILB 0x5
        IHB 0x5
        ILA 0xA
        SUB
        ILB 0x0
        IHB 0x8
        ILA 0x0
        IHA 0x0
        SUB
        ILB 0x2
        IHB 0x4
        ILA 0x2
        IHA 0x4
        SUB
        ILB 0x1
        IHB 0x2
        IHA 0x2
        SUB
        HALT
