; alu_unary_1 (part 1 of 3)
; INVA, INVB and INC over edge values and patterns, each with F = 0 and F = 1
; before the op. INVA/INVB keep F and the other register; INC sets F only on
; FF -> 00 and clears it otherwise (F preset to both values on every input).

        ILA 0x0
        IHA 0x0
        ILB 0x3
        IHB 0xC
        CLF
        INVA
        ILA 0x0
        IHA 0x0
        STF
        INVA
        ILA 0x1
        IHA 0x0
        ILB 0x2
        CLF
        INVA
        ILA 0x1
        IHA 0x0
        STF
        INVA
        ILA 0x2
        IHA 0x0
        ILB 0x1
        CLF
        INVA
        ILA 0x2
        IHA 0x0
        STF
        INVA
        ILA 0xF
        IHA 0x0
        ILB 0xC
        CLF
        INVA
        ILA 0xF
        IHA 0x0
        STF
        INVA
        IHA 0x1
        ILB 0x3
        IHB 0xD
        CLF
        INVA
        ILA 0x0
        IHA 0x1
        STF
        INVA
        IHA 0x7
        ILB 0xC
        IHB 0xB
        CLF
        INVA
        ILA 0xF
        IHA 0x7
        STF
        INVA
        ILB 0x3
        IHB 0x4
        CLF
        INVA
        ILA 0x0
        IHA 0x8
        STF
        INVA
        ILA 0x1
        IHA 0x8
        ILB 0x2
        CLF
        INVA
        ILA 0x1
        IHA 0x8
        STF
        INVA
        IHA 0xF
        ILB 0xD
        IHB 0x3
        CLF
        INVA
        ILA 0xE
        IHA 0xF
        STF
        INVA
        ILA 0xF
        IHA 0xF
        ILB 0xC
        CLF
        INVA
        ILA 0xF
        IHA 0xF
        STF
        INVA
        ILA 0xA
        IHA 0xA
        ILB 0x9
        IHB 0x6
        CLF
        INVA
        ILA 0xA
        IHA 0xA
        STF
        INVA
        ILB 0x6
        IHB 0x9
        CLF
        INVA
        ILA 0x5
        IHA 0x5
        STF
        INVA
        ILA 0x0
        IHA 0xF
        ILB 0x3
        IHB 0x3
        CLF
        INVA
        ILA 0x0
        IHA 0xF
        STF
        INVA
        ILA 0x5
        IHA 0xA
        ILB 0x6
        IHB 0x6
        CLF
        INVA
        ILA 0x5
        IHA 0xA
        STF
        INVA
        ILA 0xE
        IHA 0x7
        ILB 0xD
        IHB 0xB
        CLF
        INVA
        ILA 0xE
        IHA 0x7
        STF
        INVA
        ILA 0xD
        IHA 0xF
        ILB 0xE
        IHB 0x3
        CLF
        INVA
        ILA 0xD
        IHA 0xF
        STF
        INVA
        ILA 0xF
        IHA 0xE
        ILB 0xC
        IHB 0x2
        CLF
        INVA
        ILA 0xF
        IHA 0xE
        STF
        INVA
        HALT
