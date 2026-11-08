; err_swap_unknown_b: SWAP is a plain move but still reads both registers: B unknown.

; expect: error

        IMF A, 0x12
        SWAP
        HALT
