; prog_rotate: rotate left of a byte by 0 to 8 places as (x << n) | (x >> (8 - n)), with
; the n = 0 and n = 8 cases giving x back through SHL/SHR by 8 = 0; results to
; M[30..] for two values.

.equ x, 0
.equ n, 1
.equ out, 2
        IMF A, 0x30
        SST A, out
        IMF A, 0x96
        CALL rots
        IMF A, 0x01
        CALL rots
        HALT
rots:   SST A, x
        IMF A, 0
        SST A, n
r_loop: SLD A, x
        SLD B, n
        SHL
        SST A, 3
        IMF A, 8
        SLD B, n
        SUB                 ; 8 - n
        SWAP
        SLD A, x
        SHR
        SLD B, 3
        OR
        SWAP
        SLD A, out
        ST B, A
        INC
        SST A, out
        SLD A, n
        INC
        SST A, n
        IMF B, 9
        JNEQ r_loop
        RET
