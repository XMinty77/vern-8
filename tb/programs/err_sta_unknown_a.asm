; err_sta_unknown_a: STA with A unknown and AR known.

; expect: error

        IMF AR, 0x80
        STA
        HALT
