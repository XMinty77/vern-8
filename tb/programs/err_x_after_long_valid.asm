; err_x_after_long_valid: a long valid run (a 200-iteration loop and some stores and loads) that
; ends by loading a data address that was never written.

; expect: error

        IMF A, 0
        IMF B, 200
loop:   INC
        JNEQ loop
        SST B, 0
        ST A, 0x10
        SLD A, 0
        IMF AR, 0x20
        STB                 ; fine: B known
        LDA
        SWAP
        IMF AR, 0x21
        STA                 ; A came from B: known
        IMF AR, 0x22
        LDB
        HALT
