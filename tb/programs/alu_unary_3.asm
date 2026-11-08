; alu_unary_3 (part 3 of 3)
; INVA, INVB and INC over edge values and patterns, each with F = 0 and F = 1
; before the op. INVA/INVB keep F and the other register; INC sets F only on
; FF -> 00 and clears it otherwise (F preset to both values on every input).

        ILB 0xF
        IHB 0xE
        ILA 0x3
        IHA 0xD
        CLF
        INVB
        ILB 0xF
        IHB 0xE
        STF
        INVB
        ILB 0xE
        IHB 0x0
        ILA 0x2
        IHA 0x3
        CLF
        INVB
        ILB 0xE
        IHB 0x0
        STF
        INVB
        ILA 0x0
        IHA 0x0
        ILB 0x3
        IHB 0xC
        CLF
        INC
        ILA 0x0
        STF
        INC
        ILB 0x2
        INC
        ILA 0x1
        STF
        INC
        ILB 0x1
        INC
        ILA 0x2
        STF
        INC
        ILA 0xF
        ILB 0xC
        INC
        ILA 0xF
        IHA 0x0
        STF
        INC
        ILB 0x3
        IHB 0xD
        INC
        ILA 0x0
        STF
        INC
        ILA 0xF
        IHA 0x7
        ILB 0xC
        IHB 0xB
        INC
        ILA 0xF
        IHA 0x7
        STF
        INC
        ILB 0x3
        IHB 0x4
        INC
        ILA 0x0
        STF
        INC
        ILB 0x2
        INC
        ILA 0x1
        STF
        INC
        ILA 0xE
        IHA 0xF
        ILB 0xD
        IHB 0x3
        INC
        ILA 0xE
        STF
        INC
        ILB 0xC
        INC
        ILA 0xF
        IHA 0xF
        INC
        ILA 0xA
        IHA 0xA
        ILB 0x9
        IHB 0x6
        CLF
        INC
        ILA 0xA
        STF
        INC
        ILA 0x5
        IHA 0x5
        ILB 0x6
        IHB 0x9
        INC
        ILA 0x5
        STF
        INC
        ILA 0x0
        IHA 0xF
        ILB 0x3
        IHB 0x3
        INC
        ILA 0x0
        STF
        INC
        ILA 0x5
        IHA 0xA
        ILB 0x6
        IHB 0x6
        INC
        ILA 0x5
        STF
        INC
        ILA 0xE
        IHA 0x7
        ILB 0xD
        IHB 0xB
        INC
        ILA 0xE
        STF
        INC
        ILA 0xD
        IHA 0xF
        ILB 0xE
        IHB 0x3
        INC
        ILA 0xD
        STF
        INC
        ILA 0xF
        IHA 0xE
        ILB 0xC
        IHB 0x2
        INC
        ILA 0xF
        IHA 0xE
        STF
        INC
        ILA 0xE
        IHA 0x0
        ILB 0xD
        IHB 0xC
        INC
        ILA 0xE
        STF
        INC
        HALT
