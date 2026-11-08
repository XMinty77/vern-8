; err_partial_a: A has only its low nibble written (ILA) when ADD reads it; B is known.

; expect: error

        IMF B, 0x01
        ILA 0x5
        ADD
        HALT
