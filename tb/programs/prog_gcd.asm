; prog_gcd: greatest common divisor two ways: Euclid with DIV remainders, and the
; subtraction-only version with JGT/JLT, for pairs including a zero and equal pairs.

.equ x, 0
.equ y, 1
.equ g1, 2
.equ out, 3
.equ k, 4
        IMF A, 0x20
        SST A, out
        IMF A, 252
        IMF B, 105
        CALL both           ; 21
        IMF A, 0xFF
        IMF B, 0x11
        CALL both           ; 17
        IMF A, 89
        IMF B, 55
        CALL both           ; 1
        IMF A, 0x80
        IMF B, 0x80
        CALL both
        IMF A, 0x30
        IMF B, 0x00
        CALL euclid         ; gcd(x, 0) = x
        HALT
both:   SST A, x
        SST B, y
        CALL euclid
        SLD A, x
        SLD B, y
        CALL subgcd
        RET
euclid: SST A, 9            ; a
        SST B, 10           ; b
        IMF A, 0
        EQ                  ; b == 0 ?
        SLD A, 9
        JF e_end
        DIV                 ; A = a / b, B = a % b
        SLD A, 10           ; (a, b) = (b, a % b)
        JMP euclid
e_end:  SST A, g1
        SLD A, out
        SLD B, g1
        ST B, A
        INC
        SST A, out
        RET
subgcd: SST A, x
        SST B, y
s_loop: SLD A, x
        SLD B, y
        JEQ s_end
        JLT s_less
        SUB
        SST A, x
        JMP s_loop
s_less: SWAP
        SUB
        SST A, y
        JMP s_loop
s_end:  SLD B, out
        SWAP
        ST B, A
        INC
        SST A, out
        RET
