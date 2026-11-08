; err_ld_unwritten: LDA from a data address never written; other addresses were written.

; expect: error

        IMF A, 0x33
        ST A, 0x41
        ST A, 0x43
        LD B, 0x41
        LD B, 0x42
        HALT
