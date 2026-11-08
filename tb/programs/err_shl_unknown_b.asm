; err_shl_unknown_b: SHL with the shift count B unknown and A = 0 (the result would be 0
; for any count, but the read is still of an unknown value).

; expect: error

        IMF A, 0
        SHL
        HALT
