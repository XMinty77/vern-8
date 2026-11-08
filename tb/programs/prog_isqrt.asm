; prog_isqrt: integer square roots of 0 to FF in steps of 0x0F by counting odd numbers
; (n - 1 - 3 - 5 ...), with SUB borrow (F) as the stop condition; roots to M[A0..].

.equ v, 0
.equ odd, 1
.equ r, 2
.equ out, 3
        IMF A, 0xA0
        SST A, out
        IMF A, 0
        SST A, v
top:    SLD A, v
        SST A, 4            ; remaining
        IMF A, 1
        SST A, odd
        IMF A, 0
        SST A, r
s_loop: SLD A, 4
        SLD B, odd
        SUB
        JF s_end            ; borrow: odd > remaining
        SST A, 4
        SLD A, r
        INC
        SST A, r
        SLD A, odd
        INC
        INC
        SST A, odd
        JMP s_loop
s_end:  SLD A, out
        SLD B, r
        ST B, A
        INC
        SST A, out
        SLD A, v
        IMF B, 0x0F
        ADD
        SST A, v
        JF done
        JMP top
done:   HALT
