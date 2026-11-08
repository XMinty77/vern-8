; prog_factorial: factorials 1! to 6! with MUL into M[40..]: 5! = 120 fits, 6! = 720 sets F
; (non-zero discarded bits) and ends the loop. Also the MUL F for 2^8 exactly.

.equ n, 0
.equ f, 1
        IMF A, 1
        SST A, n
        SST A, f
loop:   SLD A, f
        SLD B, n
        MUL
        JF over
        SST A, f
        SLD A, n
        IMF B, 0x3F
        ADD
        SLD B, f
        ST B, A
        SLD A, n
        INC
        SST A, n
        JMP loop
over:   SST A, 2            ; 720 mod 256 = 0xD0
        IMF A, 0x10
        IMF B, 0x10
        MUL                 ; 0x100: A = 0, F = 1
        IMF A, 0x0F
        IMF B, 0x11
        MUL                 ; 0xFF: F = 0
        HALT
