; alu_swap
; SWAP: A and B exchange in one cycle (both read before either is written).
; Three SWAPs in a row per pair, F alternating and kept.

        ILA 0x0
        IHA 0x0
        ILB 0xF
        IHB 0xF
        CLF
        SWAP
        SWAP
        SWAP
        STF
        SWAP
        SWAP
        SWAP
        ILA 0x2
        IHA 0x1
        ILB 0x4
        IHB 0x3
        CLF
        SWAP
        SWAP
        SWAP
        ILA 0x0
        IHA 0x8
        ILB 0x1
        IHB 0x0
        STF
        SWAP
        SWAP
        SWAP
        ILA 0xF
        IHA 0x7
        ILB 0xF
        IHB 0x7
        CLF
        SWAP
        SWAP
        SWAP
        ILA 0x5
        IHA 0xA
        ILB 0xA
        IHB 0x5
        STF
        SWAP
        SWAP
        SWAP
        ILA 0x0
        IHA 0x0
        ILB 0x0
        IHB 0x0
        CLF
        SWAP
        SWAP
        SWAP
        ILA 0xE
        IHA 0xF
        ILB 0x1
        STF
        SWAP
        SWAP
        SWAP
        HALT
