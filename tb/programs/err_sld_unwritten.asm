; err_sld_unwritten: SLDB from a short address never written (M[7]); M[6] and M[8] were.

; expect: error

        IMF A, 0x99
        SST A, 6
        SST A, 8
        SLD B, 6
        SLD B, 7
        HALT
