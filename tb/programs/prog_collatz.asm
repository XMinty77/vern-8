; prog_collatz: Collatz sequences for starting values 7, 9, 11, 15, 1 and 3 (all stay below
; 256): odd n -> 3n + 1 with MUL and INC, even n -> SHR 1; step counts stored.

.equ n, 0
.equ steps, 1
.equ out, 2
        IMF A, 0x60
        SST A, out
        IMF A, 7
        CALL coll
        IMF A, 9
        CALL coll
        IMF A, 11
        CALL coll
        IMF A, 15
        CALL coll
        IMF A, 1
        CALL coll
        IMF A, 3
        CALL coll
        HALT
coll:   SST A, n
        IMF A, 0
        SST A, steps
c_loop: SLD A, n
        IMF B, 1
        JEQ c_end
        AND                 ; A = n & 1
        IMF B, 0
        JEQ even
        SLD A, n
        IMF B, 3
        MUL
        INC
        JMP c_st
even:   SLD A, n
        IMF B, 1
        SHR
c_st:   SST A, n
        SLD A, steps
        INC
        SST A, steps
        JMP c_loop
c_end:  SLD A, out
        SLD B, steps
        ST B, A
        INC
        SST A, out
        RET
