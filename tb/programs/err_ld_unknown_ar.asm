; err_ld_unknown_ar: LDB with AR unknown while A, B and memory are known.

; expect: error

        IMF A, 0
        IMF B, 0
        SST A, 0
        LDB
        HALT
