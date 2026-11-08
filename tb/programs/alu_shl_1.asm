; alu_shl_1 (part 1 of 2)
; SHL: A = A << B, A = 0 when B >= 8, F kept.
; A in {01 80 FF A5 00 5A}, B = 0 to 9, 0F, 10, 20, 7F, 80, FF (shift counts past 7
; must give 0, including counts whose low 3 bits are 0 such as 10 and 80).
; F alternates 0 and 1 before each op to show it is kept.

        ILB 0x0
        IHB 0x0
        ILA 0x1
        IHA 0x0
        CLF
        SHL
        ILB 0x1
        STF
        SHL
        ILB 0x2
        ILA 0x1
        CLF
        SHL
        ILB 0x3
        ILA 0x1
        STF
        SHL
        ILB 0x4
        ILA 0x1
        CLF
        SHL
        ILB 0x5
        ILA 0x1
        IHA 0x0
        STF
        SHL
        ILB 0x6
        ILA 0x1
        IHA 0x0
        CLF
        SHL
        ILB 0x7
        ILA 0x1
        IHA 0x0
        STF
        SHL
        ILB 0x8
        ILA 0x1
        IHA 0x0
        CLF
        SHL
        ILB 0x9
        ILA 0x1
        STF
        SHL
        ILB 0xF
        ILA 0x1
        CLF
        SHL
        ILB 0x0
        IHB 0x1
        ILA 0x1
        STF
        SHL
        IHB 0x2
        ILA 0x1
        CLF
        SHL
        ILB 0xF
        IHB 0x7
        ILA 0x1
        STF
        SHL
        ILB 0x0
        IHB 0x8
        ILA 0x1
        CLF
        SHL
        ILB 0xF
        IHB 0xF
        ILA 0x1
        STF
        SHL
        ILB 0x0
        IHB 0x0
        IHA 0x8
        CLF
        SHL
        ILB 0x1
        STF
        SHL
        ILB 0x2
        IHA 0x8
        CLF
        SHL
        ILB 0x3
        IHA 0x8
        STF
        SHL
        ILB 0x4
        IHA 0x8
        CLF
        SHL
        ILB 0x5
        IHA 0x8
        STF
        SHL
        ILB 0x6
        IHA 0x8
        CLF
        SHL
        ILB 0x7
        IHA 0x8
        STF
        SHL
        ILB 0x8
        IHA 0x8
        CLF
        SHL
        ILB 0x9
        IHA 0x8
        STF
        SHL
        ILB 0xF
        IHA 0x8
        CLF
        SHL
        ILB 0x0
        IHB 0x1
        IHA 0x8
        STF
        SHL
        IHB 0x2
        IHA 0x8
        CLF
        SHL
        ILB 0xF
        IHB 0x7
        IHA 0x8
        STF
        SHL
        ILB 0x0
        IHB 0x8
        IHA 0x8
        CLF
        SHL
        ILB 0xF
        IHB 0xF
        IHA 0x8
        STF
        SHL
        ILB 0x0
        IHB 0x0
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0x1
        STF
        SHL
        ILB 0x2
        ILA 0xF
        CLF
        SHL
        ILB 0x3
        ILA 0xF
        STF
        SHL
        ILB 0x4
        ILA 0xF
        CLF
        SHL
        ILB 0x5
        ILA 0xF
        STF
        SHL
        ILB 0x6
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0x7
        ILA 0xF
        IHA 0xF
        STF
        SHL
        ILB 0x8
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0x9
        ILA 0xF
        IHA 0xF
        STF
        SHL
        ILB 0xF
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0x0
        IHB 0x1
        ILA 0xF
        IHA 0xF
        STF
        SHL
        IHB 0x2
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0xF
        IHB 0x7
        ILA 0xF
        IHA 0xF
        STF
        SHL
        ILB 0x0
        IHB 0x8
        ILA 0xF
        IHA 0xF
        CLF
        SHL
        ILB 0xF
        IHB 0xF
        ILA 0xF
        IHA 0xF
        STF
        SHL
        HALT
