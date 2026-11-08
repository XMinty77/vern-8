; prog_bcd: binary to three decimal digits with DIV by 10 (quotient and remainder in one
; instruction) for 00, 09, 0A, 63, 64, FF and others; digits stored as ASCII.

.equ v, 0
.equ out, 1
        IMF A, 0x30
        SST A, out
        IMF A, 0
        CALL conv
        IMF A, 9
        CALL conv
        IMF A, 10
        CALL conv
        IMF A, 99
        CALL conv
        IMF A, 100
        CALL conv
        IMF A, 128
        CALL conv
        IMF A, 200
        CALL conv
        IMF A, 255
        CALL conv
        IMF A, 37
        CALL conv
        HALT
conv:   IMF B, 10
        DIV                 ; A = v / 10, B = ones
        SST A, v
        IMF A, 0x30
        ADD                 ; '0' + ones
        SST A, 3
        SLD A, v
        IMF B, 10
        DIV                 ; A = hundreds, B = tens
        SST A, v
        IMF A, 0x30
        ADD
        SST A, 4
        SLD A, v
        IMF B, 0x30
        ADD
        SLD B, out
        SWAP
        ST B, A             ; hundreds
        INC
        SLD B, 4
        ST B, A             ; tens
        INC
        SLD B, 3
        ST B, A             ; ones
        INC
        SST A, out
        RET
