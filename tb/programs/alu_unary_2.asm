; alu_unary_2 (part 2 of 3)
; INVA, INVB and INC over edge values and patterns, each with F = 0 and F = 1
; before the op. INVA/INVB keep F and the other register; INC sets F only on
; FF -> 00 and clears it otherwise (F preset to both values on every input).

        ILA 0xE
        IHA 0x0
        ILB 0xD
        IHB 0xC
        CLF
        INVA
        ILA 0xE
        IHA 0x0
        STF
        INVA
        ILB 0x0
        IHB 0x0
        ILA 0xC
        IHA 0x3
        CLF
        INVB
        ILB 0x0
        IHB 0x0
        STF
        INVB
        ILB 0x1
        IHB 0x0
        ILA 0xD
        CLF
        INVB
        ILB 0x1
        IHB 0x0
        STF
        INVB
        ILB 0x2
        IHB 0x0
        ILA 0xE
        CLF
        INVB
        ILB 0x2
        IHB 0x0
        STF
        INVB
        ILB 0xF
        IHB 0x0
        ILA 0x3
        CLF
        INVB
        ILB 0xF
        IHB 0x0
        STF
        INVB
        IHB 0x1
        ILA 0xC
        IHA 0x2
        CLF
        INVB
        ILB 0x0
        IHB 0x1
        STF
        INVB
        IHB 0x7
        ILA 0x3
        IHA 0x4
        CLF
        INVB
        ILB 0xF
        IHB 0x7
        STF
        INVB
        ILA 0xC
        IHA 0xB
        CLF
        INVB
        ILB 0x0
        IHB 0x8
        STF
        INVB
        ILB 0x1
        IHB 0x8
        ILA 0xD
        CLF
        INVB
        ILB 0x1
        IHB 0x8
        STF
        INVB
        IHB 0xF
        ILA 0x2
        IHA 0xC
        CLF
        INVB
        ILB 0xE
        IHB 0xF
        STF
        INVB
        ILB 0xF
        IHB 0xF
        ILA 0x3
        CLF
        INVB
        ILB 0xF
        IHB 0xF
        STF
        INVB
        ILB 0xA
        IHB 0xA
        ILA 0x6
        IHA 0x9
        CLF
        INVB
        ILB 0xA
        IHB 0xA
        STF
        INVB
        ILA 0x9
        IHA 0x6
        CLF
        INVB
        ILB 0x5
        IHB 0x5
        STF
        INVB
        ILB 0x0
        IHB 0xF
        ILA 0xC
        IHA 0xC
        CLF
        INVB
        ILB 0x0
        IHB 0xF
        STF
        INVB
        ILB 0x5
        IHB 0xA
        ILA 0x9
        IHA 0x9
        CLF
        INVB
        ILB 0x5
        IHB 0xA
        STF
        INVB
        ILB 0xE
        IHB 0x7
        ILA 0x2
        IHA 0x4
        CLF
        INVB
        ILB 0xE
        IHB 0x7
        STF
        INVB
        ILB 0xD
        IHB 0xF
        ILA 0x1
        IHA 0xC
        CLF
        INVB
        ILB 0xD
        IHB 0xF
        STF
        INVB
        HALT
