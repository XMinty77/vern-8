; err_partial_b_compare: EQ with B only high-nibble known (IHB); A is known.

; expect: error

        IMF A, 0x50
        IHB 0x5
        EQ
        HALT
