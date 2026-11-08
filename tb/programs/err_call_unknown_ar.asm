; err_call_unknown_ar: CALL with AR never written (A, B and F known).

; expect: error

        IMF A, 0x10
        IMF B, 0x20
        STF
        CALL
        HALT
