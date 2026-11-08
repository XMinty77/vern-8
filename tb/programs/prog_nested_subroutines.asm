; prog_nested_subroutines: a small subroutine library with the save/restore convention: each routine
; saves A, B and its own locals in data memory before calling the next. Computes
; (a * b + c) / d and the remainder for a few inputs, four calls deep at most.

.equ va, 0
.equ vb, 1
.equ vc, 2
.equ vd, 3
.equ out, 4
.equ save1, 5
.equ save2, 6
.equ save3, 7
        IMF A, 0x40
        SST A, out
        IMF A, 12
        SST A, va
        IMF A, 10
        SST A, vb
        IMF A, 7
        SST A, vc
        IMF A, 9
        SST A, vd
        CALL calc
        IMF A, 15
        SST A, va
        IMF A, 17
        SST A, vb
        IMF A, 0
        SST A, vc
        IMF A, 16
        SST A, vd
        CALL calc
        IMF A, 0
        SST A, va
        IMF A, 99
        SST A, vb
        IMF A, 5
        SST A, vc
        IMF A, 1
        SST A, vd
        CALL calc
        IMF A, 16
        SST A, va
        IMF A, 16
        SST A, vb
        IMF A, 1
        SST A, vc
        IMF A, 0
        SST A, vd
        CALL calc
        HALT
calc:   CALL muladd         ; depth 2
        SST A, save1
        SLD B, vd
        CALL divide         ; depth 2
        SLD A, out
        SST B, save2        ; remainder
        SLD B, save1        ; quotient
        ST B, A
        INC
        SLD B, save2
        ST B, A
        INC
        SST A, out
        RET
muladd: SLD A, va
        SLD B, vb
        CALL mult           ; depth 3
        SLD B, vc
        CALL addit          ; depth 3
        RET
mult:   MUL
        RET
addit:  CALL addit2         ; depth 4
        RET
addit2: ADD
        RET
divide: SST A, save3        ; B = 0 leaves A and B, F = 1
        DIV
        JF dz
        SST A, save1
        RET
dz:     IMF A, 0xFF
        SST A, save1
        IMF B, 0xFF
        RET
